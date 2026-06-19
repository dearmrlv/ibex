#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
import sys
import time
import uuid
from pathlib import Path
from typing import Any

from _cov_collection import CovData, find_ucds
from _flow_args import FlowRuntime, atomic_json, load_json
from _fsdb_wrapper import FSDBWrapper
from _sim_bin import COMMON_END, IMAGE_BASE, SimBin

COMMON_INIT_LAST_WORD = 0x00000F93
PROMPT_TIMEOUT_S = 120
ACCEPTED_CHECKPOINT = ":bsdcov_accepted_ckpt"


def _tcl_brace(value: str | Path) -> str:
    return "{" + str(value).replace("}", "\\}") + "}"


class XrunSession:
    def __init__(self, command: str, cwd: Path, env: dict[str, str],
                 log: Path, bootstrap: Path):
        self.command = command
        self.cwd = cwd
        self.env = env
        self.log = log
        self.bootstrap = bootstrap
        self.command_dir = bootstrap.parent / "xrun_cmds"
        self.done_dir = bootstrap.parent / "xrun_done"
        self.ready = bootstrap.parent / "xrun_ready"
        self.process: subprocess.Popen[bytes] | None = None

    def start(self) -> None:
        if self.process is not None:
            return
        merged = os.environ.copy()
        merged.update(self.env)
        self.log.parent.mkdir(parents=True, exist_ok=True)
        self.command_dir.mkdir(parents=True, exist_ok=True)
        self.done_dir.mkdir(parents=True, exist_ok=True)
        self._write_bootstrap()
        stream = self.log.open("ab")
        self.process = subprocess.Popen(
            ["/bin/bash", "-lc", self.command],
            cwd=self.cwd,
            env=merged,
            stdin=subprocess.DEVNULL,
            stdout=stream,
            stderr=subprocess.STDOUT,
        )
        stream.close()
        self._wait_ready(PROMPT_TIMEOUT_S)

    def run_tcl(self, script: str, timeout: int = PROMPT_TIMEOUT_S) -> str:
        if self.process is None:
            raise RuntimeError("xrun session is not running")
        job_id = f"job_{uuid.uuid4().hex}"
        pending = self.command_dir / f".{job_id}.tcl.tmp"
        job = self.command_dir / f"{job_id}.tcl"
        done = self.done_dir / f"{job_id}.done"
        payload = script.rstrip() + "\n"
        self._append_log(f"\nBSDCOV_TCL_BEGIN {job_id}\n{payload}BSDCOV_TCL_END {job_id}\n")
        pending.write_text(payload, encoding="utf-8")
        pending.rename(job)
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            if self.process.poll() is not None:
                raise RuntimeError(
                    f"xrun session exited with code {self.process.returncode}; "
                    f"last output:\n{self._tail_log()}"
                )
            if done.is_file():
                text = done.read_text(encoding="utf-8", errors="ignore")
                self._append_log(f"\nBSDCOV_TCL_DONE {job_id}\n{text}\n")
                lines = text.splitlines()
                rc_line = lines[0].strip() if lines else ""
                if rc_line != "BSDCOV_RC 0":
                    raise RuntimeError(
                        f"xrun Tcl command failed: {rc_line}\n{text}\n"
                        f"last output:\n{self._tail_log()}\n"
                        f"Tcl command was:\n{script.rstrip()}"
                    )
                return "\n".join(lines[1:]) + ("\n" if len(lines) > 1 else "")
            time.sleep(0.1)
        raise TimeoutError(
            f"xrun Tcl command timed out after {timeout}s; last output:\n"
            f"{self._tail_log()}\nTcl command was:\n{script.rstrip()}"
        )

    def close(self) -> None:
        if self.process is None:
            return
        if self.process.poll() is None:
            try:
                self.run_tcl("exit", timeout=30)
                self.process.wait(timeout=30)
            except Exception:
                self.process.kill()
                self.process.wait(timeout=30)
        self.process = None

    def _write_bootstrap(self) -> None:
        self.ready.unlink(missing_ok=True)
        script = f"""
set bsdcov_cmd_dir {_tcl_brace(self.command_dir)}
set bsdcov_done_dir {_tcl_brace(self.done_dir)}
set bsdcov_ready {_tcl_brace(self.ready)}
set fp [open $bsdcov_ready w]
puts $fp ready
close $fp

proc bsdcov_poll_commands {{}} {{
  global bsdcov_cmd_dir bsdcov_done_dir
  set jobs [lsort [glob -nocomplain -directory $bsdcov_cmd_dir *.tcl]]
  foreach job $jobs {{
    set stem [file rootname [file tail $job]]
    set done [file join $bsdcov_done_dir "$stem.done"]
    set rc [catch {{uplevel #0 [list source $job]}} result]
    set fp [open $done w]
    puts $fp "BSDCOV_RC $rc"
    puts $fp $result
    close $fp
    file delete -force $job
  }}
  after 100 bsdcov_poll_commands
}}

bsdcov_poll_commands
vwait bsdcov_forever
"""
        self.bootstrap.write_text(script.lstrip(), encoding="utf-8")

    def _wait_ready(self, timeout: int) -> None:
        if self.process is None:
            raise RuntimeError("xrun session is not running")
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            if self.process.poll() is not None:
                raise RuntimeError(
                    f"xrun session exited before Tcl bootstrap became ready; "
                    f"code={self.process.returncode}; last output:\n{self._tail_log()}"
                )
            if self.ready.is_file():
                return
            time.sleep(0.1)
        raise TimeoutError(
            f"xrun Tcl bootstrap did not become ready within {timeout}s; "
            f"last output:\n{self._tail_log()}"
        )

    def _append_log(self, text: str) -> None:
        self.log.parent.mkdir(parents=True, exist_ok=True)
        with self.log.open("a", encoding="utf-8", errors="ignore") as stream:
            stream.write(text)

    def _tail_log(self, size: int = 12000) -> str:
        if not self.log.is_file():
            return ""
        with self.log.open("rb") as stream:
            if self.log.stat().st_size > size:
                stream.seek(-size, os.SEEK_END)
            return stream.read().decode("utf-8", errors="ignore")


class SimTool:
    def __init__(self, runtime: FlowRuntime, timeout: int = 7500):
        self.runtime = runtime
        self.timeout = timeout
        self.xrun = Path(os.environ.get("CADENCE_XRUN", "/home/lvzhengyang/workspace/cadence/xrun"))
        self.shared_dir = runtime.paths.run_dir / "sim_shared"
        self.last_result: dict[str, Any] | None = None
        self.last_run_dir: Path | None = None
        self.session: XrunSession | None = None
        self.checkpoint_valid = False
        self.pending_checkpoint: tuple[Path, dict[str, Any], int] | None = None

    def run_dir_for_next_sim(self) -> Path:
        if not self.runtime.state.get("accepted_runs"):
            return self.runtime.paths.baseline / "sim"
        iteration = int(self.runtime.state.get("iteration", 0))
        if iteration <= 0:
            raise ValueError("candidate simulation requires a positive state iteration")
        return self.runtime.paths.iterations / f"{iteration:04d}" / "simulation"

    def sim(self, instr_bin: SimBin, parent_bin: SimBin | None = None) -> tuple[FSDBWrapper, CovData]:
        run_dir = self.run_dir_for_next_sim()
        if run_dir.exists() and any(run_dir.iterdir()):
            raise FileExistsError(f"simulation run already exists: {run_dir}")
        self._prepare_run(run_dir, instr_bin)
        tb_dir = self._compile_snapshot()
        layout = load_json(run_dir / "bin/image_layout.json")
        if parent_bin is None:
            process = self._run_xrun_fresh(run_dir, tb_dir, layout)
            metadata = {
                "checkpoint": None,
                "checkpoint_mode": "fresh",
                "parent_checkpoint": None,
                "patch_start": None,
            }
        else:
            patch_start = parent_bin.next_addr()
            self._ensure_checkpoint(parent_bin, tb_dir)
            process = self._run_xrun_restart_artifact(run_dir, tb_dir, layout,
                                                      ACCEPTED_CHECKPOINT,
                                                      patch_start)
            self._collect_restart_coverage(run_dir)
            metadata = {
                "checkpoint": ACCEPTED_CHECKPOINT,
                "checkpoint_mode": "restart",
                "parent_checkpoint": ACCEPTED_CHECKPOINT,
                "patch_start": f"0x{patch_start:08x}",
            }
            self.pending_checkpoint = (run_dir, layout, patch_start)
        atomic_json(run_dir / "bin/simulation_metadata.json", metadata)
        (run_dir / "xrun.exit_code").write_text(f"{process.returncode}\n", encoding="utf-8")
        if find_ucds(run_dir):
            self._publish_coverage_report(run_dir)
        result = self._check_result(run_dir, process.returncode, tb_dir, metadata)
        self.last_result = result
        self.last_run_dir = run_dir
        fsdb = FSDBWrapper.from_simulation(
            Path(result["fsdb"]),
            snapshot_time_ps=result.get("snapshot_time_ps"))
        try:
            coverage = CovData.from_report(Path(result["coverage_report"]))
        except RuntimeError:
            if parent_bin is None:
                raise
            coverage = CovData.from_dict(self.runtime.state["coverage"])
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
        self._restart_checkpoint()

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
        cache_key = "\n".join([
            str(self.runtime.paths.root.resolve()),
            "ibex-opentitan-xlm-cov-fsdb-v1",
            str(self.runtime.config.seed),
        ])
        digest = hashlib.sha1(cache_key.encode()).hexdigest()[:12]
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

    def _run_xrun_fresh(self, run_dir: Path, tb_dir: Path,
                        layout: dict[str, Any]) -> subprocess.CompletedProcess[str]:
        covfile = run_dir / "coverage/cov.ccf"
        self._write_covfile(covfile)
        ucli = run_dir / "sim/xrun.ucli.cmd"
        ucli.write_text(
            "set assert_output_stop_level none\n"
            "set assert_stop_level never\n"
            f"call fsdbDumpfile {{\"{run_dir / 'fsdb/eval.fsdb'}\"}}\n"
            "call fsdbDumpvars {0} {core_ibex_tb_top} {\"+mda\"} {\"+struct\"} {\"+parameter\"}\n"
            "call fsdbDumpSVA\n"
            "run\n"
            "catch {call fsdbDumpflush}\n"
            "catch {call fsdbDumpoff}\n"
            "catch {call fsdbDumpFinish}\n"
            "exit\n", encoding="utf-8")
        control = self._runtime_control_path()
        stop_pc = layout["stop_pc"].removeprefix("0x")
        stop_instruction = layout["stop_instruction"].removeprefix("0x")
        command = self._xrun_command(run_dir, tb_dir, covfile, ucli, stop_pc,
                                     stop_instruction, control)
        return self._run_shell(command, self.runtime.paths.ibex / "dv/uvm/core_ibex",
                               self._base_env(covfile), run_dir / "logs/launch_rtl.log",
                               self.timeout + 120, check=False)

    def _run_xrun_restart_artifact(self, run_dir: Path, tb_dir: Path,
                                   layout: dict[str, Any],
                                   parent_checkpoint: str,
                                   patch_start: int) -> subprocess.CompletedProcess[str]:
        covfile = run_dir / "coverage/cov.ccf"
        self._write_covfile(covfile)
        self._clear_default_covwork()
        control = self._write_runtime_control(run_dir, layout, patch_start)
        epoch = int(self.runtime.state.get("iteration", 0))
        ucli = run_dir / "sim/xrun.ucli.cmd"
        ucli.write_text(
            "set assert_output_stop_level none\n"
            "set assert_stop_level never\n"
            f"restart {parent_checkpoint}\n"
            "catch {stop -delete bsdcov_runtime_applied}\n"
            f"stop -create -name bsdcov_runtime_applied -condition "
            f"{{#core_ibex_tb_top.u_bsdcov_runtime_ctrl.applied_epoch == {epoch}}}\n"
            "run\n"
            "catch {stop -delete bsdcov_runtime_applied}\n"
            f"call fsdbDumpfile {{\"{run_dir / 'fsdb/eval.fsdb'}\"}}\n"
            "call fsdbDumpvars {0} {core_ibex_tb_top} {\"+mda\"} {\"+struct\"} {\"+parameter\"}\n"
            "call fsdbDumpSVA\n"
            "run\n"
            "catch {call fsdbDumpflush}\n"
            "catch {call fsdbDumpoff}\n"
            "catch {call fsdbDumpFinish}\n"
            "exit\n", encoding="utf-8")
        stop_pc = layout["stop_pc"].removeprefix("0x")
        stop_instruction = layout["stop_instruction"].removeprefix("0x")
        command = self._xrun_command(run_dir, tb_dir, covfile, ucli, stop_pc,
                                     stop_instruction, control)
        return self._run_shell(command, self.runtime.paths.ibex / "dv/uvm/core_ibex",
                               self._base_env(covfile), run_dir / "logs/launch_rtl.log",
                               self.timeout + 120, check=False)

    def _clear_default_covwork(self) -> None:
        default_covwork = self.runtime.paths.ibex / "dv/uvm/core_ibex/cov_work"
        shutil.rmtree(default_covwork / "scope", ignore_errors=True)

    def _collect_restart_coverage(self, run_dir: Path) -> None:
        default_covwork = self.runtime.paths.ibex / "dv/uvm/core_ibex/cov_work"
        scope = default_covwork / "scope"
        if not scope.is_dir():
            return
        ucd_dirs = sorted(
            {path.parent for path in scope.rglob("*.ucd")},
            key=lambda path: path.stat().st_mtime,
            reverse=True)
        if not ucd_dirs:
            return
        src = ucd_dirs[0]
        dst = run_dir / "coverage" / "coverage" / src.name
        if dst.exists():
            shutil.rmtree(dst)
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(src), str(dst))
        model_dir = run_dir / "coverage" / "model"
        for model in sorted(model_dir.glob("*.ucm")):
            shutil.copy2(model, dst / model.name)

    def _ensure_checkpoint(self, parent_bin: SimBin, tb_dir: Path) -> None:
        if self.checkpoint_valid:
            return
        if self.session is None:
            bootstrap_dir = self.shared_dir / "checkpoint_bootstrap"
            if bootstrap_dir.exists():
                shutil.rmtree(bootstrap_dir)
            self._prepare_run(bootstrap_dir, parent_bin)
            layout = load_json(bootstrap_dir / "bin/image_layout.json")
            self._start_checkpoint_session(bootstrap_dir, tb_dir, layout)
            self._run_until_stop(bootstrap_dir)
        self._save_checkpoint()

    def _start_checkpoint_session(self, run_dir: Path, tb_dir: Path,
                                  layout: dict[str, Any]) -> None:
        covfile = run_dir / "coverage/cov.ccf"
        self._write_covfile(covfile)
        self._clear_default_covwork()
        self._write_runtime_sentinel()
        control = self._runtime_control_path()
        stop_pc = layout["stop_pc"].removeprefix("0x")
        stop_instruction = layout["stop_instruction"].removeprefix("0x")
        bootstrap = run_dir / "logs/xrun_bootstrap.tcl"
        command = (
            f"{self.xrun} -64bit -R -input {bootstrap} -xmlibdirpath {tb_dir} -licqueue "
            f"-svseed {self.runtime.config.seed} -svrnc rand_struct -nokey "
            f"-l {run_dir / 'sim/rtl_sim.log'} "
            "+UVM_TESTNAME=core_ibex_base_test +UVM_VERBOSITY=UVM_LOW "
            f"+bin={run_dir / 'bin/eval.bin'} +signature_addr=8ffffffc "
            "+test_timeout_s=7200 +disable_cosim=1 "
            f"+ibex_tracer_file_base={run_dir / 'sim/trace_core'} "
            f"+bsdcov_imem_last_addr={stop_pc} +bsdcov_stop_pc={stop_pc} "
            f"+bsdcov_stop_instruction={stop_instruction} "
            f"+bsdcov_runtime_control={control} "
            "-covoverwrite "
        )
        self.session = XrunSession(command, self.runtime.paths.ibex / "dv/uvm/core_ibex",
                                   self._base_env(covfile),
                                   run_dir / "logs/xrun_session.log", bootstrap)
        self.session.start()
        self._session().run_tcl(
            "set assert_output_stop_level none\n"
            "set assert_stop_level never\n"
            "catch {stop -delete bsdcov_runtime_applied}\n",
            timeout=600)

    def _load_runtime_image(self, run_dir: Path, layout: dict[str, Any],
                            patch_start: int) -> None:
        epoch = int(self.runtime.state.get("iteration", 0))
        self._write_runtime_control(run_dir, layout, patch_start)
        text = self._session().run_tcl(
            "catch {stop -delete bsdcov_runtime_applied}\n"
            "stop -create -name bsdcov_runtime_applied "
            f"-condition {{#core_ibex_tb_top.u_bsdcov_runtime_ctrl.applied_epoch == {epoch}}}\n"
            "run\n"
            "catch {stop -delete bsdcov_runtime_applied}\n",
            timeout=600)
        self._append_run_log(run_dir, text)

    def _run_until_stop(self, run_dir: Path) -> None:
        text = self._session().run_tcl("run", timeout=self.timeout)
        self._append_run_log(run_dir, text)

    def _save_checkpoint(self) -> None:
        text = self._session().run_tcl(
            "run -clean\n"
            f"save -simulation -overwrite {ACCEPTED_CHECKPOINT}\n",
            timeout=1200)
        checkpoint_log = self.shared_dir / "checkpoint.log"
        checkpoint_log.parent.mkdir(parents=True, exist_ok=True)
        with checkpoint_log.open("a", encoding="utf-8", errors="ignore") as stream:
            stream.write(text)
            if not text.endswith("\n"):
                stream.write("\n")
        self.checkpoint_valid = True

    def _restart_checkpoint(self) -> None:
        if not self.checkpoint_valid or self.session is None:
            return
        self._session().run_tcl(
            f"restart {ACCEPTED_CHECKPOINT}\n"
            "set assert_output_stop_level none\n"
            "set assert_stop_level never\n"
            "catch {stop -delete bsdcov_runtime_applied}\n",
            timeout=900)

    def commit_checkpoint(self) -> str:
        if self.pending_checkpoint is None:
            raise RuntimeError("no pending accepted simulation to checkpoint")
        run_dir, layout, patch_start = self.pending_checkpoint
        if self.session is None or not self.checkpoint_valid:
            raise RuntimeError("checkpoint session is not ready")
        self._restart_checkpoint()
        self._load_runtime_image(run_dir, layout, patch_start)
        self._run_until_stop(run_dir)
        self._save_checkpoint()
        self.pending_checkpoint = None
        return ACCEPTED_CHECKPOINT

    def close(self) -> None:
        if self.session is not None:
            self.session.close()
            self.session = None

    def _session(self) -> XrunSession:
        if self.session is None:
            raise RuntimeError("xrun session has not been started")
        return self.session

    @staticmethod
    def _append_run_log(run_dir: Path, text: str) -> None:
        if not text:
            return
        log = run_dir / "sim/rtl_sim.log"
        log.parent.mkdir(parents=True, exist_ok=True)
        with log.open("a", encoding="utf-8", errors="ignore") as stream:
            stream.write(text)
            if not text.endswith("\n"):
                stream.write("\n")

    def _xrun_command(self, run_dir: Path, tb_dir: Path, covfile: Path, ucli: Path,
                      stop_pc: str, stop_instruction: str, control: Path) -> str:
        return (
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
            f"+bsdcov_runtime_control={control} "
            f"-covmodeldir {run_dir / 'coverage/model'} "
            f"-covworkdir {run_dir / 'coverage'} -covscope coverage "
            f"-covtest eval.{self.runtime.config.seed} -covoverwrite "
            f"+enable_ibex_fcov=1 -covfile {covfile} -input {ucli}"
        )

    def _runtime_control_path(self) -> Path:
        path = self.shared_dir / "runtime_control.txt"
        path.parent.mkdir(parents=True, exist_ok=True)
        if not path.exists():
            self._write_runtime_sentinel()
        return path

    def _write_runtime_sentinel(self) -> None:
        path = self.shared_dir / "runtime_control.txt"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(
            "-1\n"
            "none\n"
            "00000000\n"
            "00000000\n"
            "00000000\n"
            "00000000\n",
            encoding="utf-8")

    def _write_runtime_control(self, run_dir: Path, layout: dict[str, Any],
                               patch_start: int) -> Path:
        path = self._runtime_control_path()
        epoch = int(self.runtime.state.get("iteration", 0))
        stop_pc = int(layout["stop_pc"], 16)
        stop_instruction = int(layout["stop_instruction"], 16)
        temporary = path.with_suffix(".tmp")
        temporary.write_text(
            f"{epoch}\n"
            f"{run_dir / 'bin/eval.bin'}\n"
            f"{patch_start:08x}\n"
            f"{stop_pc:08x}\n"
            f"{stop_pc:08x}\n"
            f"{stop_instruction:08x}\n",
            encoding="utf-8")
        temporary.replace(path)
        return path

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
                      tb_dir: Path, metadata: dict[str, Any]) -> dict[str, Any]:
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
        result.update(metadata)
        failures = list(result.get("failures", []))
        assertion_only_exit = (
            failures == ["xrun_exit"] and result.get("retirement_marker") and
            int(result.get("assertion_failure_mentions", 0)) > 0 and
            Path(result["fsdb"]).is_file() and Path(result["coverage_report"]).is_file())
        if assertion_only_exit:
            result["status"] = "pass_with_assertions"
            result["accepted_nonzero_exit"] = True
            atomic_json(result_path, result)
        elif result.get("status") == "pass_with_error_handled":
            atomic_json(result_path, result)
        elif driver_exit_code or process.returncode or result.get("status") != "pass":
            raise RuntimeError(f"simulation failed; see {run_dir / 'logs'}")
        atomic_json(result_path, result)
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
