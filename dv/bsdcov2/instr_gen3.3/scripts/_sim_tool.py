#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Any

from _cov_collection import CovData, find_ucds
from _flow_args import FlowRuntime, atomic_json, load_json
from _fsdb_wrapper import FSDBWrapper
from _runtime_timer import RuntimeTimer
from _sim_bin import COMMON_END, IMAGE_BASE, SimBin

COMMON_INIT_LAST_WORD = 0x00000F93


class SimTool:
    def __init__(self, runtime: FlowRuntime, timeout: int = 7500):
        self.runtime = runtime
        self.timeout = timeout
        self.xrun = Path(os.environ.get("CADENCE_XRUN", "/home/lvzhengyang/workspace/cadence/xrun"))
        self.shared_dir = runtime.paths.run_dir / "sim_shared"
        self.last_result: dict[str, Any] | None = None
        self.last_run_dir: Path | None = None
        self.timer = RuntimeTimer(runtime)

    def run_dir_for_next_sim(self) -> Path:
        if not self.runtime.state.get("accepted_runs"):
            return self.runtime.paths.baseline / "sim"
        iteration = int(self.runtime.state.get("iteration", 0))
        if iteration <= 0:
            raise ValueError("candidate simulation requires a positive state iteration")
        return self.runtime.paths.iterations / f"{iteration:04d}" / "simulation"

    def sim(self, instr_bin: SimBin) -> tuple[FSDBWrapper, CovData | None]:
        run_dir = self.run_dir_for_next_sim()
        if run_dir.exists() and any(run_dir.iterdir()):
            raise FileExistsError(f"simulation run already exists: {run_dir}")
        self._prepare_run(run_dir, instr_bin)
        with self.timer.stage("Simulation", "xrun_compile_snapshot"):
            tb_dir = self._compile_snapshot()
        layout = load_json(run_dir / "bin/image_layout.json")
        with self.timer.stage("Simulation", "xrun_run", run_dir=str(run_dir)):
            process = self._run_xrun(run_dir, tb_dir, layout)
        (run_dir / "xrun.exit_code").write_text(f"{process.returncode}\n", encoding="utf-8")
        if self.runtime.config.disable_per_sim_imc_report:
            (run_dir / "coverage/cov_report.skipped").write_text(
                "per-simulation IMC report disabled\n", encoding="utf-8")
        else:
            with self.timer.stage("CoverageCollection", "imc_report", run_dir=str(run_dir)):
                self._publish_coverage_report(run_dir)
        result = self._check_result(run_dir, process.returncode, tb_dir)
        self.last_result = result
        self.last_run_dir = run_dir
        fsdb = FSDBWrapper.from_simulation(Path(result["fsdb"]))
        coverage = None if result.get("coverage_report_skipped") else CovData.from_report(
            Path(result["coverage_report"]))
        return fsdb, coverage

    def find_ucds(self, run_dir: Path | None = None) -> list[Path]:
        owner = run_dir or self.last_run_dir
        if owner is None:
            return []
        return find_ucds(owner)

    def mark_rejected(self, run_dir: Path | None = None) -> None:
        owner = run_dir or self.last_run_dir
        if owner is None:
            return
        for child in ("fsdb", "coverage", "sim", "bin"):
            shutil.rmtree(owner / child, ignore_errors=True)
        logs = owner / "logs"
        if logs.is_dir():
            for path in logs.iterdir():
                if path.is_file() and path.stat().st_size > 200_000:
                    text = path.read_text(encoding="utf-8", errors="ignore")
                    path.write_text(text[-200_000:], encoding="utf-8")

    def image_layout(self, instr_bin: SimBin) -> dict[str, Any]:
        generated = instr_bin.generated_instrs()
        if generated:
            stop_pc, stop_instruction = generated[-1].addr, generated[-1].instr
        else:
            stop_pc, stop_instruction = COMMON_END, COMMON_INIT_LAST_WORD
        image_size = len(instr_bin.content) * 4
        return {
            "image_base": f"0x{IMAGE_BASE:08x}",
            "common_init_start": "0x80000080",
            "common_init_end": f"0x{COMMON_END:08x}",
            "generated_instruction_count": len(generated),
            "generated_start": f"0x{generated[0].addr:08x}" if generated else None,
            "generated_end": f"0x{generated[-1].addr:08x}" if generated else None,
            "stop_pc": f"0x{stop_pc:08x}",
            "stop_instruction": f"0x{stop_instruction:08x}",
            "hang_on_imem": "on",
            "imem_response_start": "0x80000080",
            "imem_response_end": f"0x{stop_pc:08x}",
            "image_end": f"0x{IMAGE_BASE + image_size - 1:08x}",
            "binary_size_bytes": image_size,
            "image_word_count": len(instr_bin.content),
            "bin_instruction_count": instr_bin.get_instr_num(),
            "recorded_word_count": len(instr_bin.content),
        }

    def _prepare_run(self, run_dir: Path, instr_bin: SimBin) -> None:
        for child in ("input", "bin", "sv", "sim", "fsdb", "coverage", "logs"):
            (run_dir / child).mkdir(parents=True, exist_ok=True)
        instr_bin.write_sequence_csv(run_dir / "input/instr_seq.csv")
        instr_bin.gen_file(run_dir / "bin/eval.bin")
        atomic_json(run_dir / "bin/image_layout.json", self.image_layout(instr_bin))
        (run_dir / "sv/imem.sv").write_text(
            "// instr_gen uses runtime TB memory plusargs for simulation.\n", encoding="utf-8")

    def _compile_snapshot(self) -> Path:
        digest = hashlib.sha1(str(self.shared_dir.resolve()).encode()).hexdigest()[:12]
        cache = self.runtime.paths.root / ".work" / f"tb.{digest}"
        tb_out = cache / "ibex_dv_out"
        tb_dir = tb_out / "build/tb"
        marker = cache / "compile.ok"
        self.shared_dir.mkdir(parents=True, exist_ok=True)
        if marker.is_file() and tb_dir.is_dir():
            (self.shared_dir / "tb_dir.txt").write_text(f"{tb_dir}\n", encoding="utf-8")
            return tb_dir

        cache.mkdir(parents=True, exist_ok=True)
        covfile = cache / "coverage/cov.ccf"
        self._write_covfile(covfile)
        core_ibex = self.runtime.paths.ibex / "dv/uvm/core_ibex"
        command = (
            f"source {core_ibex / 'setup_env.sh'} && "
            f"make -B --keep-going GOAL=rtl_tb_compile OUT={tb_out} "
            "IBEX_CONFIG=opentitan SIMULATOR=xlm ISS=spike TEST=empty ITERATIONS=1 "
            f"SEED={self.runtime.config.seed} WAVES=0 COV=1 VERBOSE=0"
        )
        self._run_shell(command, core_ibex, self._base_env(covfile),
                        cache / "logs/rtl_tb_compile.log", 7200)
        if not tb_dir.is_dir():
            raise RuntimeError(f"compiled snapshot not found: {tb_dir}")
        marker.write_text("ok\n", encoding="utf-8")
        (self.shared_dir / "compile.ok").write_text("ok\n", encoding="utf-8")
        (self.shared_dir / "tb_dir.txt").write_text(f"{tb_dir}\n", encoding="utf-8")
        return tb_dir

    def _run_xrun(self, run_dir: Path, tb_dir: Path,
                  layout: dict[str, Any]) -> subprocess.CompletedProcess[str]:
        covfile = run_dir / "coverage/cov.ccf"
        self._write_covfile(covfile)
        ucli = run_dir / "sim/xrun.ucli.cmd"
        ucli.write_text(
            "set assert_output_stop_level none\n"
            "set assert_stop_level never\n"
            f"call fsdbDumpfile {{\"{run_dir / 'fsdb/eval.fsdb'}\"}}\n"
            "call fsdbDumpvars {0} {core_ibex_tb_top} {\"+mda\"} {\"+struct\"} {\"+parameter\"}\n"
            "call fsdbDumpSVA\nrun\nexit\n", encoding="utf-8")
        stop_pc = layout["stop_pc"].removeprefix("0x")
        stop_instruction = layout["stop_instruction"].removeprefix("0x")
        command = (
            f"timeout --signal=TERM --kill-after=15s {self.timeout}s "
            f"{self.xrun} -64bit -R -xmlibdirpath {tb_dir} -licqueue "
            f"-svseed {self.runtime.config.seed} -svrnc rand_struct -nokey "
            f"-l {run_dir / 'sim/rtl_sim.log'} "
            "+UVM_TESTNAME=core_ibex_base_test +UVM_VERBOSITY=UVM_LOW "
            f"+bin={run_dir / 'bin/eval.bin'} +signature_addr=8ffffffc "
            "+test_timeout_s=7200 +disable_cosim=1 "
            f"+ibex_tracer_file_base={run_dir / 'sim/trace_core'} "
            f"+bsdcov_imem_last_addr={stop_pc} +bsdcov_stop_pc={stop_pc} "
            f"+bsdcov_stop_instruction={stop_instruction} "
            f"-covmodeldir {run_dir / 'coverage/model'} "
            f"-covworkdir {run_dir / 'coverage'} -covscope coverage "
            f"-covtest eval.{self.runtime.config.seed} -covoverwrite "
            f"+enable_ibex_fcov=1 -covfile {covfile} -input {ucli}"
        )
        return self._run_shell(command, self.runtime.paths.ibex / "dv/uvm/core_ibex",
                               self._base_env(covfile), run_dir / "logs/launch_rtl.log",
                               self.timeout + 120, check=False)

    def _publish_coverage_report(self, run_dir: Path) -> None:
        ucds = find_ucds(run_dir)
        if not ucds:
            raise RuntimeError(f"simulation produced no UCD: {run_dir}")
        scripts = self.runtime.paths.ibex / "dv/bsdcov_whole_mc/scripts"
        sys.path.insert(0, str(scripts))
        from _launch_sim import _run_imc_report  # type: ignore
        report = _run_imc_report(repo_root=self.runtime.paths.ibex, run_dir=run_dir,
                                 prefix_idx=1, ucds=ucds, module="ibex_top", dry_run=False)
        if report is None or not report.is_file():
            raise RuntimeError("IMC did not produce a coverage report")
        lines = report.read_text(encoding="utf-8", errors="ignore").splitlines()
        published = "\n".join(line for line in lines
                               if line.startswith(("Legend:", "name ", "---", "ibex_top ")))
        (run_dir / "coverage/cov_report.txt").write_text(published + "\n", encoding="utf-8")
        cg = report.with_name("cov_report_cg.txt")
        if cg.is_file():
            shutil.copy2(cg, run_dir / "coverage/cov_report_cg.txt")

    def _check_result(self, run_dir: Path, driver_exit_code: int,
                      tb_dir: Path) -> dict[str, Any]:
        check = self.runtime.paths.root / "scripts/_check_result.py"
        process = subprocess.run(["python3", str(check), str(run_dir)], text=True,
                                 stdout=subprocess.PIPE, stderr=subprocess.STDOUT, check=False)
        (run_dir / "logs/check_result.log").write_text(process.stdout, encoding="utf-8")
        result_path = run_dir / "result.json"
        if not result_path.is_file():
            raise RuntimeError(f"simulation did not produce {result_path}")
        result = load_json(result_path)
        result["driver_exit_code"] = driver_exit_code
        result["check_exit_code"] = process.returncode
        result["shared_tb_dir"] = str(tb_dir)
        failures = list(result.get("failures", []))
        assertion_only_exit = (
            failures == ["xrun_exit"] and result.get("retirement_marker") and
            int(result.get("assertion_failure_mentions", 0)) > 0 and
            Path(result["fsdb"]).is_file() and (
                result.get("coverage_report_skipped") or
                Path(result["coverage_report"]).is_file()))
        if assertion_only_exit:
            result["status"] = "pass_with_assertions"
            result["accepted_nonzero_exit"] = True
            atomic_json(result_path, result)
        elif result.get("status") == "pass_with_error_handled":
            atomic_json(result_path, result)
        elif driver_exit_code or process.returncode or result.get("status") != "pass":
            raise RuntimeError(f"simulation failed; see {run_dir / 'logs'}")
        return result

    def _write_covfile(self, path: Path) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(
            f"include_ccf {self.runtime.paths.ibex}/dv/uvm/core_ibex/xcelium_2009_cover.ccf\n"
            "deselect_coverage -remove_empty_instances\n", encoding="utf-8")

    def _base_env(self, covfile: Path) -> dict[str, str]:
        ibex = self.runtime.paths.ibex
        root = self.runtime.paths.root
        return {
            "IBEX_ROOT": str(ibex), "PRJ_DIR": str(ibex),
            "LOWRISC_IP_DIR": str(ibex / "vendor/lowrisc_ip"), "DUT_TOP": "ibex_top",
            "dv_root": str(ibex / "vendor/lowrisc_ip/dv"),
            "BSDCOV_INSTR_GEN_DIR": str(root),
            "VERDI_HOME": os.environ.get("VERDI_HOME", "/home/lvzhengyang/workspace/synopsys/verdi/T-2022.06"),
            "BSD_COV_XRUN_BASE_FILELIST": str(root / "rtl/ibex_dv.f"),
            "BSD_COV_EXTRA_XRUN_FILELISTS": str(root / "rtl/instr_gen_extra.f"),
            "BSD_COV_EXTRA_XRUN_COMPILE_OPTS": "-access +rwc -loadpli1 debpli:novas_pli_boot",
            "BSD_COV_XRUN_COVFILE": str(covfile),
            "EXTRA_COSIM_CFLAGS": os.environ.get("EXTRA_COSIM_CFLAGS", ""),
            "CADENCE_XRUN": str(self.xrun),
        }

    @staticmethod
    def _run_shell(command: str, cwd: Path, env: dict[str, str], log: Path,
                   timeout: int, check: bool = True) -> subprocess.CompletedProcess[str]:
        merged = os.environ.copy()
        merged.update(env)
        process = subprocess.run(["/bin/bash", "-lc", command], cwd=cwd, env=merged,
                                 text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                 timeout=timeout, check=False)
        log.parent.mkdir(parents=True, exist_ok=True)
        log.write_text(process.stdout, encoding="utf-8", errors="ignore")
        if check and process.returncode:
            raise RuntimeError(f"command failed ({process.returncode}); see {log}")
        return process
