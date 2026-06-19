#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
from pathlib import Path
from typing import Any

from _common import load_json, run
from _common import atomic_json
from _image import COMMON_END, GENERATED_START, IMAGE_BASE, generated_words, read_words, write_sequence_csv

COMMON_INIT_LAST_WORD = 0x00000F93


def _ibex_root(eval_dir: Path) -> Path:
    return eval_dir.parent.parent.parent


def _script_root() -> Path:
    return Path(__file__).resolve().parent.parent


def _run_shell(command: str, *, cwd: Path, env: dict[str, str], log: Path,
               timeout: int | None = None, check: bool = True) -> subprocess.CompletedProcess[str]:
    merged = os.environ.copy()
    merged.update(env)
    proc = subprocess.run(["/bin/bash", "-lc", command], cwd=cwd, env=merged, text=True,
                          stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                          timeout=timeout, check=False)
    log.parent.mkdir(parents=True, exist_ok=True)
    log.write_text(proc.stdout, encoding="utf-8", errors="ignore")
    if check and proc.returncode:
        raise RuntimeError(f"command failed ({proc.returncode}); see {log}")
    return proc


def _base_env(ibex_root: Path, instr_gen: Path, covfile: Path) -> dict[str, str]:
    return {
        "IBEX_ROOT": str(ibex_root),
        "PRJ_DIR": str(ibex_root),
        "LOWRISC_IP_DIR": str(ibex_root / "vendor/lowrisc_ip"),
        "DUT_TOP": "ibex_top",
        "dv_root": str(ibex_root / "vendor/lowrisc_ip/dv"),
        "BSDCOV_INSTR_GEN_DIR": str(instr_gen),
        "VERDI_HOME": os.environ.get("VERDI_HOME", "/home/lvzhengyang/workspace/synopsys/verdi/T-2022.06"),
        "BSD_COV_XRUN_BASE_FILELIST": str(instr_gen / "rtl/ibex_dv.f"),
        "BSD_COV_EXTRA_XRUN_FILELISTS": str(instr_gen / "rtl/instr_gen_extra.f"),
        "BSD_COV_EXTRA_XRUN_COMPILE_OPTS": "-access +rwc -loadpli1 debpli:novas_pli_boot",
        "BSD_COV_XRUN_COVFILE": str(covfile),
        "EXTRA_COSIM_CFLAGS": os.environ.get("EXTRA_COSIM_CFLAGS", ""),
        "CADENCE_XRUN": os.environ.get("CADENCE_XRUN", "/home/lvzhengyang/workspace/cadence/xrun"),
    }


def _write_covfile(path: Path, ibex_root: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        f"include_ccf {ibex_root}/dv/uvm/core_ibex/xcelium_2009_cover.ccf\n"
        "deselect_coverage -remove_empty_instances\n",
        encoding="utf-8",
    )


def _compile_snapshot(*, shared_dir: Path, eval_dir: Path, seed: int) -> Path:
    ibex_root = _ibex_root(eval_dir)
    instr_gen = _script_root()
    core_ibex = ibex_root / "dv/uvm/core_ibex"
    requested_shared_dir = shared_dir
    digest = hashlib.sha1(str(requested_shared_dir.resolve()).encode("utf-8")).hexdigest()[:12]
    shared_dir = instr_gen / ".work" / f"tb.{digest}"
    tb_out = shared_dir / "ibex_dv_out"
    tb_dir = tb_out / "build/tb"
    marker = shared_dir / "compile.ok"
    covfile = shared_dir / "coverage/cov.ccf"
    if marker.exists() and tb_dir.exists():
        requested_shared_dir.mkdir(parents=True, exist_ok=True)
        (requested_shared_dir / "tb_dir.txt").write_text(str(tb_dir) + "\n", encoding="utf-8")
        return tb_dir
    shared_dir.mkdir(parents=True, exist_ok=True)
    requested_shared_dir.mkdir(parents=True, exist_ok=True)
    _write_covfile(covfile, ibex_root)
    env = _base_env(ibex_root, instr_gen, covfile)
    setup = core_ibex / "setup_env.sh"
    command = (
        f"source {setup} && "
        f"make -B --keep-going GOAL=rtl_tb_compile OUT={tb_out} "
        "IBEX_CONFIG=opentitan SIMULATOR=xlm ISS=spike TEST=empty ITERATIONS=1 "
        f"SEED={seed} WAVES=0 COV=1 VERBOSE=0"
    )
    _run_shell(command, cwd=core_ibex, env=env,
               log=shared_dir / "logs/rtl_tb_compile.log", timeout=7200)
    if not tb_dir.exists():
        raise RuntimeError(f"compiled snapshot not found: {tb_dir}")
    marker.write_text("ok\n", encoding="utf-8")
    (requested_shared_dir / "tb_dir.txt").write_text(str(tb_dir) + "\n", encoding="utf-8")
    (requested_shared_dir / "compile.ok").write_text("ok\n", encoding="utf-8")
    return tb_dir


def _layout_for_image(image: Path) -> dict[str, Any]:
    words = read_words(image)
    generated = generated_words(image)
    if generated:
        stop_pc, stop_instruction = generated[-1]
    else:
        stop_pc, stop_instruction = COMMON_END, COMMON_INIT_LAST_WORD
    return {
        "image_base": f"0x{IMAGE_BASE:08x}",
        "common_init_start": "0x80000080",
        "common_init_end": f"0x{COMMON_END:08x}",
        "generated_instruction_count": len(generated),
        "generated_start": f"0x{generated[0][0]:08x}" if generated else None,
        "generated_end": f"0x{generated[-1][0]:08x}" if generated else None,
        "stop_pc": f"0x{stop_pc:08x}",
        "stop_instruction": f"0x{stop_instruction:08x}",
        "hang_on_imem": "on",
        "imem_response_start": "0x80000080",
        "imem_response_end": f"0x{stop_pc:08x}",
        "image_end": f"0x{IMAGE_BASE + image.stat().st_size - 1:08x}",
        "binary_size_bytes": image.stat().st_size,
        "image_word_count": image.stat().st_size // 4,
        "bin_instruction_count": (COMMON_END - 0x80000080) // 4 + 1 + len(generated),
        "recorded_word_count": len(words),
    }


def _run_xrun(*, run_dir: Path, tb_dir: Path, eval_dir: Path, seed: int,
              layout: dict[str, Any], timeout: int) -> subprocess.CompletedProcess[str]:
    ibex_root = _ibex_root(eval_dir)
    instr_gen = _script_root()
    core_ibex = ibex_root / "dv/uvm/core_ibex"
    covfile = run_dir / "coverage/cov.ccf"
    _write_covfile(covfile, ibex_root)
    env = _base_env(ibex_root, instr_gen, covfile)
    ucli = run_dir / "sim/xrun.ucli.cmd"
    ucli.parent.mkdir(parents=True, exist_ok=True)
    ucli.write_text(
        "set assert_output_stop_level none\n"
        "set assert_stop_level never\n"
        f"call fsdbDumpfile {{\"{run_dir / 'fsdb/eval.fsdb'}\"}}\n"
        "call fsdbDumpvars {0} {core_ibex_tb_top} {\"+mda\"} {\"+struct\"} {\"+parameter\"}\n"
        "call fsdbDumpSVA\n"
        "run\n"
        "exit\n",
        encoding="utf-8",
    )
    xrun = env["CADENCE_XRUN"]
    stop_pc = layout["stop_pc"].replace("0x", "")
    stop_instruction = layout["stop_instruction"].replace("0x", "")
    command = (
        f"timeout --signal=TERM --kill-after=15s {timeout}s "
        f"{xrun} -64bit -R -xmlibdirpath {tb_dir} -licqueue "
        f"-svseed {seed} -svrnc rand_struct -nokey -l {run_dir / 'sim/rtl_sim.log'} "
        "+UVM_TESTNAME=core_ibex_base_test +UVM_VERBOSITY=UVM_LOW "
        f"+bin={run_dir / 'bin/eval.bin'} +signature_addr=8ffffffc "
        "+test_timeout_s=7200 +disable_cosim=1 "
        f"+ibex_tracer_file_base={run_dir / 'sim/trace_core'} "
        f"+bsdcov_imem_last_addr={stop_pc} "
        f"+bsdcov_stop_pc={stop_pc} "
        f"+bsdcov_stop_instruction={stop_instruction} "
        f"-covmodeldir {run_dir / 'coverage/model'} -covworkdir {run_dir / 'coverage'} "
        f"-covscope coverage -covtest eval.{seed} -covoverwrite "
        f"+enable_ibex_fcov=1 -covfile {covfile} -input {ucli}"
    )
    return _run_shell(command, cwd=core_ibex, env=env,
                      log=run_dir / "logs/launch_rtl.log", timeout=timeout + 120,
                      check=False)


def _publish_coverage_report(*, ibex_root: Path, run_dir: Path) -> None:
    ucds = sorted((run_dir / "coverage").rglob("*.ucd"))
    if not ucds:
        return
    existing = sorted((run_dir / "coverage").glob("prefix_*/report/cov_report.txt"))
    if existing:
        report = existing[-1]
        lines = report.read_text(encoding="utf-8", errors="ignore").splitlines()
        (run_dir / "coverage/cov_report.txt").write_text(
            "\n".join(x for x in lines if x.startswith(("Legend:", "name ", "---", "ibex_top "))) + "\n",
            encoding="utf-8",
        )
        cg = report.with_name("cov_report_cg.txt")
        if cg.exists():
            shutil.copy2(cg, run_dir / "coverage/cov_report_cg.txt")
        return
    scripts = ibex_root / "dv/bsdcov_whole_mc/scripts"
    import sys
    sys.path.insert(0, str(scripts))
    from _launch_sim import _run_imc_report  # type: ignore
    report = _run_imc_report(repo_root=ibex_root, run_dir=run_dir, prefix_idx=1,
                             ucds=ucds, module="ibex_top", dry_run=False)
    if report is None or not report.exists():
        candidates = sorted((run_dir / "coverage").glob("prefix_*/report/cov_report.txt"))
        report = candidates[-1] if candidates else None
    if report is None or not report.exists():
        raise RuntimeError("IMC did not produce a report")
    lines = report.read_text(encoding="utf-8", errors="ignore").splitlines()
    (run_dir / "coverage/cov_report.txt").write_text(
        "\n".join(x for x in lines if x.startswith(("Legend:", "name ", "---", "ibex_top "))) + "\n",
        encoding="utf-8",
    )
    cg = report.with_name("cov_report_cg.txt")
    if cg.exists():
        shutil.copy2(cg, run_dir / "coverage/cov_report_cg.txt")


def _prune_rejected(run_dir: Path) -> None:
    keep = {"result.json", "rejection.json", "coverage_delta.json"}
    for child in ("fsdb", "coverage", "sim", "bin"):
        shutil.rmtree(run_dir / child, ignore_errors=True)
    for path in list((run_dir / "logs").glob("*")):
        if path.name not in keep and path.is_file() and path.stat().st_size > 200_000:
            path.write_text(path.read_text(encoding="utf-8", errors="ignore")[-200_000:],
                            encoding="utf-8")


def mark_rejected(run_dir: Path) -> None:
    _prune_rejected(run_dir)


def simulate(*, image: Path, run_dir: Path, seed: int, eval_dir: Path,
             timeout: int = 7500, shared_dir: Path | None = None) -> dict[str, Any]:
    for child in ("input", "bin", "sv", "sim", "fsdb", "coverage", "logs"):
        (run_dir / child).mkdir(parents=True, exist_ok=True)
    sequence = run_dir / "input/instr_seq.csv"
    write_sequence_csv(image, sequence)
    shutil.copy2(image, run_dir / "bin/eval.bin")
    layout = _layout_for_image(image)
    atomic_json(run_dir / "bin/image_layout.json", layout)
    # Keep a small compatibility placeholder for existing debug scripts.
    (run_dir / "sv/imem.sv").write_text("// instr_gen uses runtime TB memory plusargs for simulation.\n",
                                        encoding="utf-8")

    if shared_dir is None:
        digest = hashlib.sha1(str(run_dir.resolve()).encode("utf-8")).hexdigest()[:12]
        shared_dir = _script_root() / ".work" / f"tb.{digest}"
    tb_dir = _compile_snapshot(shared_dir=shared_dir, eval_dir=eval_dir, seed=seed)
    sim = _run_xrun(run_dir=run_dir, tb_dir=tb_dir, eval_dir=eval_dir, seed=seed,
                    layout=layout, timeout=timeout)
    (run_dir / "xrun.exit_code").write_text(str(sim.returncode) + "\n", encoding="utf-8")
    _publish_coverage_report(ibex_root=_ibex_root(eval_dir), run_dir=run_dir)

    check = eval_dir / "scripts/_check_result.py"
    check_proc = run(["python3", str(check), str(run_dir)],
                     log=run_dir / "logs/check_result.log", check=False)
    result_path = run_dir / "result.json"
    if not result_path.exists():
        raise RuntimeError(f"simulation did not produce {result_path}")
    result = load_json(result_path)
    result["driver_exit_code"] = sim.returncode
    result["check_exit_code"] = check_proc.returncode
    result["shared_tb_dir"] = str(tb_dir)
    result["bin_instruction_count"] = layout["bin_instruction_count"]
    failures = list(result.get("failures", []))
    assertion_only_exit = (
        failures == ["xrun_exit"] and
        bool(result.get("retirement_marker")) and
        int(result.get("assertion_failure_mentions", 0)) > 0 and
        Path(result["fsdb"]).is_file() and
        Path(result["coverage_report"]).is_file()
    )
    if assertion_only_exit:
        result["status"] = "pass_with_assertions"
        result["accepted_nonzero_exit"] = True
        atomic_json(result_path, result)
    elif sim.returncode or check_proc.returncode or result.get("status") != "pass":
        raise RuntimeError(f"simulation failed; see {run_dir / 'logs'}")
    return result
