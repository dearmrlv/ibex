#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

RETIRED = re.compile(
    r"BSDCOV_EVAL_RETIRED (?:time_ps=(\d+) )?pc=0x([0-9a-fA-F]{8}) insn=0x([0-9a-fA-F]{8})"
)
BLOCKED = re.compile(r"BSDCOV_EVAL_RETIRED .* blocked_req_seen=([01])")
ERROR_HANDLED = re.compile(
    r"BSDCOV_EVAL_ERROR_HANDLED (?:time_ps=(\d+) )?.*?error_count=(\d+).*?wait_cycles=(\d+)"
)
SIM_STOP_TIME = re.compile(
    r"Simulation (?:stopped|complete) via \$(?:stop|finish)\(\d+\) at time (\d+) PS"
)
TRACE = re.compile(
    r"^\s*\d+\s+\d+\s+([0-9a-fA-F]{8})\s+([0-9a-fA-F]{8})\s+",
    re.MULTILINE,
)


def main() -> int:
    run = Path(sys.argv[1]).resolve()
    layout = json.loads((run / "bin/image_layout.json").read_text())
    metadata_path = run / "bin/simulation_metadata.json"
    metadata = json.loads(metadata_path.read_text()) if metadata_path.exists() else {}
    incremental = metadata.get("checkpoint_mode") == "restart"
    logs = []
    for path in (run / "sim/rtl_sim.log", run / "logs/launch_rtl.log"):
        if path.exists():
            logs.append(path.read_text(encoding="utf-8", errors="ignore"))
    text = "\n".join(logs)
    trace_text = "\n".join(
        path.read_text(encoding="utf-8", errors="ignore")
        for path in sorted((run / "sim").glob("trace_core*.log"))
    )
    trace = [(int(pc, 16), int(insn, 16)) for pc, insn in TRACE.findall(trace_text)]
    retired_matches = RETIRED.findall(text)
    markers = [(int(pc, 16), int(insn, 16))
               for _time_ps, pc, insn in retired_matches]
    blocked_values = [value == "1" for value in BLOCKED.findall(text)]
    error_matches = ERROR_HANDLED.findall(text)
    error_handled_markers = [(int(count), int(wait))
                             for _time_ps, count, wait in error_matches]
    error_handled = bool(error_handled_markers)
    snapshot_time_ps = None
    marker_times = [int(time_ps) for time_ps, _pc, _insn in retired_matches if time_ps]
    error_times = [int(time_ps) for time_ps, _count, _wait in error_matches if time_ps]
    stop_times = [int(value) for value in SIM_STOP_TIME.findall(text)]
    if stop_times:
        snapshot_time_ps = stop_times[-1]
    elif error_times:
        snapshot_time_ps = error_times[-1]
    elif marker_times:
        snapshot_time_ps = marker_times[-1]
    stop_pc = int(layout["stop_pc"], 16)
    stop_instruction = int(layout["stop_instruction"], 16)
    exit_path = run / "xrun.exit_code"
    exit_code = int(exit_path.read_text().strip()) if exit_path.exists() else -1
    fsdb = run / "fsdb/eval.fsdb"
    report = run / "coverage/cov_report.txt"
    ucds = sorted((run / "coverage").rglob("*.ucd"))
    failures = []
    if exit_code in (124, 137, -9, -15, -31):
        failures.append("simulation_timeout")
    elif exit_code != 0: failures.append("xrun_exit")
    if incremental:
        if not error_handled and (stop_pc, stop_instruction) not in markers:
            failures.append("missing_or_wrong_retirement_marker")
    elif not error_handled and (
        not markers or any(marker != (stop_pc, stop_instruction) for marker in markers)
    ):
        failures.append("missing_or_wrong_retirement_marker")
    if not incremental and not error_handled and (not trace or trace[-1] != (stop_pc, stop_instruction)):
        failures.append("wrong_last_retired_instruction")
    if any(pc > stop_pc for pc, _insn in trace): failures.append("retired_beyond_stop_pc")
    if not fsdb.exists() or fsdb.stat().st_size == 0: failures.append("missing_fsdb")
    if (run / "fsdb/eval.fsdb.lock").exists(): failures.append("incomplete_fsdb")
    if snapshot_time_ps is None: failures.append("missing_snapshot_time")
    if not ucds: failures.append("missing_coverage_database")
    report_text = report.read_text(encoding="utf-8", errors="ignore") if report.exists() else ""
    if "ibex_top" not in report_text: failures.append("missing_dut_coverage_report")
    if "core_ibex_tb_top" in report_text: failures.append("testbench_in_published_coverage")
    bounded_marker = (
        "BSDCOV_EVAL_MEM_DRIVER" in text or
        "BSDCOV_EVAL_IMEM_LAST_ADDR" in text
    )
    if layout["hang_on_imem"] == "on" and not bounded_marker:
        failures.append("bounded_imem_not_enabled")

    if error_handled and exit_code != 124 and "xrun_exit" in failures:
        failures.remove("xrun_exit")

    assertion_failures = len(re.findall(r"assert(?:ion)?.*fail", text, re.IGNORECASE))
    result = {
        "status": ("pass_with_error_handled"
                   if error_handled and not failures else
                   "pass" if not failures else "fail"),
        "run_tag": run.name,
        "generated_instruction_count": layout["generated_instruction_count"],
        "generated_start": layout["generated_start"],
        "generated_end": layout["generated_end"],
        "stop_pc": layout["stop_pc"],
        "stop_instruction": layout["stop_instruction"],
        "hang_on_imem": layout["hang_on_imem"],
        "imem_response_start": layout["imem_response_start"],
        "imem_response_end": layout["imem_response_end"],
        "bounded_imem_marker": bounded_marker,
        "blocked_request_seen": any(blocked_values),
        "error_handled_marker": error_handled,
        "error_handled_count": error_handled_markers[-1][0] if error_handled else 0,
        "post_error_wait_cycles": error_handled_markers[-1][1] if error_handled else 0,
        "snapshot_time_ps": snapshot_time_ps,
        "xrun_exit_code": exit_code,
        "retirement_marker": bool(markers),
        "retired_instruction_count": len(trace),
        "last_retired_pc": f"0x{trace[-1][0]:08x}" if trace else None,
        "last_retired_instruction": f"0x{trace[-1][1]:08x}" if trace else None,
        "assertion_failure_mentions": assertion_failures,
        "binary": str(run / "bin/eval.bin"),
        "imem_sv": str(run / "sv/imem.sv"),
        "fsdb": str(fsdb),
        "coverage_report": str(report),
        "failures": failures,
    }
    (run / "result.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    return 0 if not failures else 1


if __name__ == "__main__":
    raise SystemExit(main())
