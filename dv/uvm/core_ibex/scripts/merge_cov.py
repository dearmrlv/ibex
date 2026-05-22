#!/usr/bin/env python3
"""Helper-scripts to merge coverage databases across multiple tests."""

# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0


import argparse
import logging
import os
import shlex
import shutil
import sys
import pathlib3x as pathlib
from typing import Set

from metadata import RegressionMetadata, LockedMetadata
from setup_imports import _OT_LOWRISC_IP
from scripts_lib import run_one


def _is_xlm_real_run_db(ucd_path: pathlib.Path) -> bool:
    """Return true for first-class Xcelium run databases.

    The coverage output tree can also contain merged databases and manual probe
    artifacts. Feeding those back into the next merge can make IMC select a
    stale merged DB as the primary model and drop block/branch/statement data.
    """
    path_str = ucd_path.as_posix()
    if '/run/tests/' in path_str and '/coverage/' in path_str:
        return True

    if '/run/coverage/fcov/default/' in path_str:
        return True

    return False


def _xlm_run_dir(ucd_path: pathlib.Path) -> pathlib.Path:
    return ucd_path.parent


def _sort_xlm_cov_dbs(cov_dbs: Set[pathlib.Path]) -> list[pathlib.Path]:
    """Sort code coverage DBs before functional coverage DBs for IMC merge."""
    return sorted(
        cov_dbs,
        key=lambda p: (
            1 if '/run/coverage/fcov/default/' in p.as_posix() else 0,
            p.as_posix()))


def find_cov_dbs(start_dir: pathlib.Path, simulator: str) -> Set[pathlib.Path]:
    """Gather a set of the coverage databases."""
    cov_dbs = set()

    if simulator == 'xlm':
        for p in start_dir.glob('**/*.ucd'):
            if not _is_xlm_real_run_db(p):
                logging.info(f"Ignoring non-run Xcelium coverage database at {p}")
                continue
            logging.info(f"Found coverage database (ucd) at {p}")
            cov_dbs.add(p)
    if simulator == 'vcs':
        for p in start_dir.glob('**/test.vdb'):
            logging.info(f"Found coverage database (vdb) at {p}")
            cov_dbs.add(p)

    if not cov_dbs:
        logging.info(f"No coverage found for {simulator}")
        return 1

    return cov_dbs


def merge_cov_vcs(md: RegressionMetadata, cov_dirs: Set[pathlib.Path]) -> int:
    cmd = (['urg', '-full64',
            '-format', 'both',
            '-dbname', str(md.dir_cov/'merged.vdb'),
            '-report', str(md.dir_cov/'report'),
            '-log', str(md.dir_cov/'merge.log'),
            '-dir'] +
           [str(cov_dir) for cov_dir in list(cov_dirs)])

    with LockedMetadata(md.dir_metadata, __file__) as md:
        md.cov_merge_log = md.dir_cov / 'merge.log'
        md.cov_merge_stdout = md.dir_cov / 'merge.log.stdout'
        md.cov_merge_cmds = [cmd]

    with open(md.cov_merge_stdout, 'wb') as fd:
        logging.info("Generating merged coverage directory")
        return run_one(md.verbose, cmd, redirect_stdstreams=fd)


def _wrap_imc_cmd_for_pty(cmd):
    """Run IMC through a pseudo-terminal when available.

    The local IMC launcher uses `docker exec -it`, which fails when stdout and
    stderr are redirected to log files unless a TTY is present.
    """
    if shutil.which('script') is None:
        return cmd

    return ['script', '-q', '-e', '-c', shlex.join(cmd), '/dev/null']


def merge_cov_xlm(md: RegressionMetadata, cov_dbs: Set[pathlib.Path]) -> int:
    """Merge xcelium-generated coverage using the OT scripts.

    The vendored-in OpenTitan IP contains .tcl scripts that can merge xcelium
    coverage using the Cadence 'imc' Integrated-Metrics-Centre tool.
    """
    xcelium_scripts = _OT_LOWRISC_IP/'dv/tools/xcelium'

    imc_cmd = ["imc", "-64bit", "-licqueue"]
    merge_cmd = _wrap_imc_cmd_for_pty(
        imc_cmd + ["-exec", str(xcelium_scripts/"cov_merge.tcl"),
                   "-logfile", str(md.dir_cov/'merge.log')])
    report_cmd = _wrap_imc_cmd_for_pty(
        imc_cmd + ["-load", str(md.dir_cov_merged),
                   "-init", str(md.ibex_dv_root/"waivers"/"coverage_waivers_xlm.tcl"),
                   "-exec", str(xcelium_scripts/"cov_report.tcl"),
                   "-logfile", str(md.dir_cov/'report.log')])

    # Update the metadata file with the commands we're about to run
    with LockedMetadata(md.dir_metadata, __file__) as md:

        md.cov_merge_db_list = md.dir_cov / 'cov_db_runfile'
        md.cov_merge_log = md.dir_cov / 'merge.log'
        md.cov_merge_stdout = md.dir_cov / 'merge.log.stdout'
        md.cov_merge_cmds = [merge_cmd]

        md.cov_report_log = md.dir_cov / 'report.log'
        md.cov_report_stdout = md.dir_cov / 'report.log.stdout'
        md.cov_report_cmds = [report_cmd]


    sorted_cov_dbs = _sort_xlm_cov_dbs(cov_dbs)
    run_dirs = [_xlm_run_dir(d) for d in sorted_cov_dbs]
    cov_dir_parents = ' '.join(str(d.parent) for d in run_dirs)

    # Finally, set an environment variable containing all the directories that
    # should be merged (this is how the list gets passed down to the TCL script
    # that handles them)
    xlm_cov_dirs = {
        'cov_merge_db_dir': str(md.dir_cov_merged),
        'cov_report_dir': str(md.dir_cov_report),
        'cov_db_dirs': cov_dir_parents,
        'cov_db_runfile': str(md.cov_merge_db_list),
        "DUT_TOP": md.dut_cov_rtl_path
    }
    xlm_env = os.environ.copy()
    xlm_env.update(xlm_cov_dirs)
    xlm_env['LC_ALL'] = 'C'
    xlm_env['LANG'] = 'C'
    logging.info(f"xlm_cov_dirs : {xlm_cov_dirs}")

    # Dump the list of databases to a file, which will be read by the .tcl script
    # (This prevents the argument list from getting too long when using lots of iterations)
    with open(md.cov_merge_db_list, 'w') as fd:
        # > The runs in <runfile> should be listed one per line.
        fd.write(('\n'.join(str(d) for d in run_dirs))+'\n')

    # First do the merge
    md.dir_cov_merged.mkdir(exist_ok=True, parents=True)
    with open(md.cov_merge_stdout, 'wb') as fd:
        merge_ret = run_one(verbose=md.verbose,
                            cmd=md.cov_merge_cmds[0],
                            redirect_stdstreams=fd,
                            env=xlm_env)
    if merge_ret:
        return merge_ret

    with open(md.dir_cov_merged/'runs.txt', 'w') as fd:
        fd.write(('\n'.join(str(d) for d in run_dirs))+'\n')

    # Then do the reporting
    os.makedirs(md.dir_cov_report, exist_ok=True)
    with open(md.cov_report_stdout, 'wb') as fd:
        report_ret = run_one(verbose=md.verbose,
                             cmd=md.cov_report_cmds[0],
                             redirect_stdstreams=fd,
                             env=xlm_env)

    return report_ret


def main():
    '''Entry point when run as a script'''
    parser = argparse.ArgumentParser()
    parser.add_argument('--dir-metadata', type=pathlib.Path, required=True)
    args = parser.parse_args()
    md = RegressionMetadata.construct_from_metadata_dir(args.dir_metadata)

    if md.simulator not in ['xlm', 'vcs']:
        raise ValueError(f'Unsupported simulator for merging coverage: {args.simulator}')

    md.dir_cov.mkdir(exist_ok=True, parents=True)

    # Compile a list of all the coverage databases
    cov_dbs = find_cov_dbs(md.dir_run, md.simulator)

    merge_funs = {
        'vcs': merge_cov_vcs,
        'xlm': merge_cov_xlm
    }
    return merge_funs[md.simulator](md, cov_dbs)


if __name__ == '__main__':
    try:
        sys.exit(main())
    except RuntimeError as err:
        sys.stderr.write('Error: {}\n'.format(err))
        sys.exit(1)
