#!/usr/bin/env python3
from __future__ import annotations

import os
import logging
import select
import shutil
import subprocess
import termios
import time
import uuid
from pathlib import Path

from jinja2 import Environment, FileSystemLoader, StrictUndefined

from _assert_stat import AssertCex, AssertCollection, AssertStat, ProofStatus
from _flow_args import FlowRuntime
from _fsdb_wrapper import FSDBWrapper
from _sim_bin import SimBin

ELABORATE = r"""elaborate -top ibex_top \
  -parameter RV32E 0 \
  -parameter RV32M {ibex_pkg::RV32MSingleCycle} \
  -parameter RV32B {ibex_pkg::RV32BOTEarlGrey} \
  -parameter RV32ZC {ibex_pkg::RV32ZcaZcbZcmp} \
  -parameter RegFile {ibex_pkg::RegFileFF} \
  -parameter BranchTargetALU 1 \
  -parameter WritebackStage 1 \
  -parameter ICache 1 \
  -parameter ICacheECC 1 \
  -parameter ICacheScramble 1 \
  -parameter ICacheTweakInfection 0 \
  -parameter BranchPredictor 0 \
  -parameter DbgTriggerEn 1 \
  -parameter DbgHwBreakNum 1 \
  -parameter SecureIbex 1 \
  -parameter LockstepOffset 1 \
  -parameter PMPEnable 1 \
  -parameter PMPGranularity 0 \
  -parameter PMPNumRegions 16 \
  -parameter MHPMCounterNum 10 \
  -parameter MHPMCounterWidth 32 \
  -parameter DmBaseAddr {32'h1A110000} \
  -parameter DmAddrMask {32'h00000FFF} \
  -parameter DmHaltAddr {32'h80000000} \
  -parameter DmExceptionAddr {32'h80000008}"""

TEMPLATE_DIR = Path(__file__).resolve().parent / "fml_template"
FIXED_IMEM_START = 0x80000080
LOGGER = logging.getLogger(__name__)

STATIC_ENV_FILES = (
    "instr_vld.sv",
    "dmem_policy.sv",
    "dmem.sv",
    "top_asm.sv",
)


def _hx(value: int) -> str:
    return f"32'h{value:08x}"


def _tcl_quote(value: str | Path) -> str:
    return "{" + str(value).replace("}", "\\}") + "}"


class JGIMem:
    def __init__(self):
        self.bin: SimBin | None = None

    def update(self, bin: SimBin) -> None:
        self.bin = bin.copy()

    def gen_sv(self, output: Path) -> Path:
        if self.bin is None:
            raise RuntimeError("Jasper imem has not been initialized")
        words = self.bin.words()
        start = self.bin.next_addr()
        environment = Environment(
            loader=FileSystemLoader(TEMPLATE_DIR),
            undefined=StrictUndefined,
            autoescape=False,
            keep_trailing_newline=True,
        )
        template = environment.get_template("env/imem.sv.jinja")
        fixed_words = [
            {"address": _hx(address), "instruction": _hx(word)}
            for address, word in sorted(words.items())
            if address >= FIXED_IMEM_START
        ]
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(template.render(
            symbolic_start=_hx(start),
            fixed_words=fixed_words,
        ), encoding="utf-8")
        return output

class JGRst:
    def __init__(self, sim_hier: str = "core_ibex_tb_top.dut.u_ibex_top"):
        self.fsdb: FSDBWrapper | None = None
        self.jg_rst_file: Path | None = None
        self.sim_hier = sim_hier

    def update(self, fsdb: FSDBWrapper) -> None:
        if not fsdb.from_sim:
            raise ValueError("Jasper reset source must be a simulation FSDB")
        self.fsdb = fsdb

    def tcl(self, work_dir: Path) -> str:
        if self.fsdb is None:
            raise RuntimeError("Jasper reset source has not been initialized")
        self.jg_rst_file = work_dir / "init_state.rst"
        return f"""set init_state [file join $work_dir init_state.rst]
reset -clear
reset -fsdb {_tcl_quote(self.fsdb.filepath)} -hier_path {_tcl_quote(self.sim_hier)} -non_resettable_regs 0
get_reset_info -save_values $init_state -all -comments
reset -clear
reset -init_state $init_state"""


class JGEnv:
    def __init__(self, runtime: FlowRuntime):
        self.runtime = runtime
        self.imem = JGIMem()
        self.rst = JGRst()
        self.epoch_assertion_fs: list[Path] = []
        self.jg = Path(runtime.config.jg)
        self._process: subprocess.Popen[bytes] | None = None
        self._pty_master: int | None = None
        self._session_dir: Path | None = None

    def get_asserts(self) -> AssertCollection:
        work_dir = self.runtime.paths.formal / "discover"
        self._require_session()
        work_dir.mkdir(parents=True, exist_ok=True)
        tcl = work_dir / "discover.tcl"
        self._emit_job_tcl(tcl, work_dir, property_name=None, retry_index=0)
        self._run_job(tcl, work_dir, self.runtime.config.prove_timeout + 600)
        properties = work_dir / "properties.txt"
        if not properties.is_file():
            raise RuntimeError(f"Jasper did not produce {properties}")
        names = sorted({line.strip() for line in properties.read_text(encoding="utf-8").splitlines()
                        if line.strip()})
        return AssertCollection(AssertStat(name) for name in names)

    def set_epoch_assertion_filelists(self, paths: list[Path]) -> None:
        self.epoch_assertion_fs = [path.expanduser().resolve() for path in paths]

    def call_proof(self, assertion: AssertStat) -> None:
        if self.imem.bin is None:
            raise RuntimeError("Jasper imem has not been initialized")
        if self.rst.fsdb is None:
            raise RuntimeError("Jasper reset source has not been initialized")
        iteration = int(self.runtime.state.get("iteration", 0))
        if iteration <= 0:
            raise ValueError("proof requires a positive state iteration")
        work_dir = self.runtime.paths.iterations / f"{iteration:04d}" / "formal"
        stored = self.runtime.state.get("properties", {}).get(assertion.name, {})
        retry_index = max(
            len(assertion.cexs),
            len(stored.get("cexs", [])),
            int(stored.get("retries", 0)),
        )
        self._require_session()
        work_dir.mkdir(parents=True, exist_ok=True)
        tcl = work_dir / "prove.tcl"
        self._emit_job_tcl(tcl, work_dir, assertion.name, retry_index)
        traces_before = {
            path.resolve(): path.stat().st_mtime_ns
            for path in (work_dir / "traces").glob("**/*.fsdb")
        }
        try:
            self._run_job(tcl, work_dir, self.runtime.config.prove_timeout + 15)
        except TimeoutError:
            assertion.set_status(ProofStatus.TIMEOUT)
            return
        except Exception:
            assertion.set_status(ProofStatus.ERROR)
            raise
        status_file = work_dir / "status.txt"
        raw_status = status_file.read_text(encoding="utf-8").strip().lower() \
            if status_file.is_file() else "error"
        if raw_status in {"proven", "pass"}:
            assertion.set_status(ProofStatus.PROVEN)
            return
        if raw_status in {"timeout", "inconclusive", "undetermined"}:
            assertion.set_status(ProofStatus.TIMEOUT)
            return
        if raw_status not in {"cex", "ar_cex"}:
            assertion.set_status(ProofStatus.ERROR)
            return
        traces = sorted(
            (path for path in (work_dir / "traces").glob("**/*.fsdb")
             if path.resolve() not in traces_before or
             path.stat().st_mtime_ns > traces_before[path.resolve()]),
            key=lambda path: path.stat().st_mtime_ns)
        if not traces:
            assertion.set_status(ProofStatus.CEX)
            return
        output_csv = work_dir.parent / "candidate/words.csv"
        cex = AssertCex(FSDBWrapper.from_formal(traces[-1]), self.imem.bin, output_csv)
        assertion.add_cex(cex)

    def _prepare_env(self, work_dir: Path) -> Path:
        work_dir.mkdir(parents=True, exist_ok=True)
        env_dir = work_dir / "env"
        env_dir.mkdir(parents=True, exist_ok=True)

        shutil.copy2(TEMPLATE_DIR / "dut.f", work_dir / "dut.f")
        for filename in STATIC_ENV_FILES:
            shutil.copy2(TEMPLATE_DIR / "env" / filename, env_dir / filename)

        imem_sv = self.imem.gen_sv(env_dir / "imem.sv")
        symbolic_start = self.imem.bin.next_addr()
        environment = Environment(
            loader=FileSystemLoader(TEMPLATE_DIR),
            undefined=StrictUndefined,
            autoescape=False,
            keep_trailing_newline=True,
        )
        ctrlflow = environment.get_template("env/ctrlflow.sv.jinja")
        (env_dir / "ctrlflow.sv").write_text(ctrlflow.render(
            symbolic_start=_hx(symbolic_start),
        ), encoding="utf-8")

        env_files = [
            env_dir / "instr_vld.sv",
            env_dir / "ctrlflow.sv",
            env_dir / "dmem_policy.sv",
            env_dir / "dmem.sv",
            imem_sv,
            env_dir / "top_asm.sv",
        ]
        env_filelist = environment.get_template("env.f.jinja")
        env_f = work_dir / "env.f"
        env_f.write_text(env_filelist.render(
            env_files=[str(path.resolve()) for path in env_files],
        ), encoding="utf-8")
        return env_f

    def _emit_job_tcl(self, output: Path, work_dir: Path,
                      property_name: str | None, retry_index: int) -> None:
        if property_name is None:
            property_block = """set fd [open [file join $work_dir properties.txt] w]
foreach p [lsort [get_property_list -include {type assert}]] {
  if {[string match "*AST_BSDCOV_*" $p] &&
      [string match "*u_ibex_core*" $p] &&
      ![string match "*u_shadow_core*" $p]} { puts $fd $p }
}
close $fd"""
        else:
            if retry_index == 0:
                search = f"""prove -property $target_prop -asserts -force -engine_mode auto \\
  -per_property_time_limit {self.runtime.config.prove_timeout}s -dump_trace \\
  -dump_trace_type fsdb -dump_trace_dir [file join $work_dir traces]"""
            else:
                seed = self.runtime.config.seed + iteration_seed(self.runtime, retry_index)
                search = f"""assert -set_store_trace unlimited $target_prop
hunt -clear
hunt -config -strategy bsdcov_retry_{retry_index} -mode state_swarm \\
  -target_type assert -max_jobs 1 -max_trace_length 300 -seed {seed}
hunt -run -strategy bsdcov_retry_{retry_index} -property $target_prop \\
  -time_limit {self.runtime.config.prove_timeout}s -force -dump_trace \\
  -dump_trace_type fsdb -dump_trace_dir [file join $work_dir traces]"""
            property_block = f"""set target_prop {_tcl_quote(property_name)}
{search}
set status [get_status $target_prop]
set fd [open [file join $work_dir status.txt] w]
puts $fd $status
close $fd
report -property $target_prop -results -detailed \\
  -file [file join $work_dir property_report.txt] -force"""
        output.write_text(f"""set work_dir {_tcl_quote(work_dir)}
file mkdir $work_dir
file mkdir [file join $work_dir traces]
{property_block}
""", encoding="utf-8")

    def _require_session(self) -> None:
        if self._process is None or self._process.poll() is not None:
            raise RuntimeError("Jasper session is not running; call restart_session() first")

    def is_running(self) -> bool:
        return self._process is not None and self._process.poll() is None

    def restart_session(self, *, advance_epoch: bool = True) -> None:
        if self.imem.bin is None or self.rst.fsdb is None:
            raise RuntimeError("Jasper imem/reset source has not been initialized")
        self.close()
        epoch = int(self.runtime.state.get("epoch", 0)) + (1 if advance_epoch else 0)
        if epoch <= 0:
            raise RuntimeError("cannot restart Jasper session for epoch 0")
        self.runtime.state["epoch"] = epoch
        session_dir = self.runtime.paths.formal / "epochs" / f"{epoch:04d}"
        session_dir.mkdir(parents=True, exist_ok=True)
        env_f = self._prepare_env(session_dir)
        setup = session_dir / "setup.tcl"
        analyze = " \\\n  ".join([f"-f {_tcl_quote(session_dir / 'dut.f')}",
                       f"-f {_tcl_quote(env_f)}"] +
                      [f"-f {_tcl_quote(path)}" for path in self.epoch_assertion_fs])
        setup.write_text(f"""clear -all
analyze -sv12 \\
  {analyze}
{ELABORATE}
clock clk_i
set_trace_show_reset false
set_prove_dump_trace_type assert
set work_dir {_tcl_quote(session_dir)}
{self.rst.tcl(session_dir)}
""", encoding="utf-8")
        project = session_dir / "jgproject"
        shutil.rmtree(project, ignore_errors=True)
        master, slave = os.openpty()
        attributes = termios.tcgetattr(slave)
        attributes[3] &= ~termios.ECHO
        termios.tcsetattr(slave, termios.TCSANOW, attributes)
        process = subprocess.Popen(
            [str(self.jg), "-fpv", "-no_gui", "-proj", str(project)],
            cwd=session_dir, stdin=slave, stdout=slave, stderr=slave,
            start_new_session=True)
        os.close(slave)
        os.set_blocking(master, False)
        self._process = process
        self._pty_master = master
        self._session_dir = session_dir
        try:
            self._run_job(setup, session_dir, self.runtime.config.prove_timeout + 1200,
                          log_name="setup.log")
        except Exception:
            self.close()
            raise

    def _run_job(self, tcl: Path, work_dir: Path, timeout: int,
                 log_name: str = "jasper.log") -> None:
        if self._process is None or self._pty_master is None:
            raise RuntimeError("Jasper session is not running")
        token = f"BSDCOV_DONE_{uuid.uuid4().hex}"
        result_file = work_dir / f".{token}.result"
        wrapper = work_dir / f".{token}.tcl"
        wrapper.write_text(f"""set __bsdcov_rc [catch {{source {_tcl_quote(tcl)}}} __bsdcov_result]
set __bsdcov_fd [open {_tcl_quote(result_file)} w]
puts $__bsdcov_fd $__bsdcov_rc
puts $__bsdcov_fd $__bsdcov_result
close $__bsdcov_fd
puts {token}
flush stdout
""", encoding="utf-8")
        os.write(self._pty_master, f"source {_tcl_quote(wrapper)}\n".encode())
        output = bytearray()
        deadline = time.monotonic() + timeout
        marker = token.encode()
        failure: Exception | None = None
        while marker not in output or not result_file.is_file():
            if self._process.poll() is not None:
                break
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                failure = TimeoutError(f"Jasper job timed out after {timeout}s: {tcl}")
                break
            ready, _, _ = select.select([self._pty_master], [], [], min(1.0, remaining))
            if not ready:
                continue
            try:
                chunk = os.read(self._pty_master, 65536)
            except BlockingIOError:
                continue
            except OSError:
                break
            if not chunk:
                break
            output.extend(chunk)
        log = work_dir / log_name
        log.write_bytes(bytes(output))
        if failure is not None:
            self._log_jasper_failure(log, output)
            self.close()
            raise failure
        if marker not in output or not result_file.is_file():
            code = self._process.poll()
            self._log_jasper_failure(log, output)
            raise RuntimeError(f"Jasper session exited unexpectedly ({code}); see {log}")
        lines = result_file.read_text(encoding="utf-8", errors="replace").splitlines()
        if not lines or lines[0] != "0":
            detail = "\n".join(lines[1:]) if len(lines) > 1 else "unknown Tcl error"
            self._log_jasper_failure(log, output)
            raise RuntimeError(f"Jasper Tcl job failed: {detail}; see {log}")
        wrapper.unlink(missing_ok=True)
        result_file.unlink(missing_ok=True)

    @staticmethod
    def _log_jasper_failure(log: Path, output: bytearray) -> None:
        text = bytes(output).decode("utf-8", errors="replace").rstrip()
        if text:
            LOGGER.error("JasperGold output (%s):\n%s", log, text)
        else:
            LOGGER.error("JasperGold produced no terminal output; see %s", log)

    def close(self) -> None:
        process = self._process
        master = self._pty_master
        self._process = None
        self._pty_master = None
        self._session_dir = None
        if process is not None and process.poll() is None:
            if master is not None:
                try:
                    os.write(master, b"exit\n")
                    process.wait(timeout=10)
                except (OSError, subprocess.TimeoutExpired):
                    process.terminate()
                    try:
                        process.wait(timeout=5)
                    except subprocess.TimeoutExpired:
                        process.kill()
                        process.wait()
        if master is not None:
            try:
                os.close(master)
            except OSError:
                pass


def iteration_seed(runtime: FlowRuntime, retry_index: int) -> int:
    return int(runtime.state.get("iteration", 0)) + retry_index
