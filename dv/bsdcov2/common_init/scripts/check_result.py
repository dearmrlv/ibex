#!/usr/bin/env python3
"""Validate an Ibex common-initialization simulation run."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

DONE_MARKER = "BSDCOV_COMMON_INIT_RETIRED pc=0x8000011c outstanding=0 blocked_req_seen=1"
TRACE_PC = re.compile(
    r"^\s*\d+\s+\d+\s+([0-9a-fA-F]{8})\s+",
    re.MULTILINE,
)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("run_dir", type=Path)
    args = parser.parse_args()
    run_dir = args.run_dir.resolve()

    log_text = "\n".join(
        path.read_text(encoding="utf-8", errors="ignore")
        for path in (run_dir / "rtl_sim.log", run_dir / "logs/launch_rtl.log")
        if path.exists()
    )
    traces = sorted(run_dir.glob("trace_core*.log"))
    trace_text = "\n".join(
        path.read_text(encoding="utf-8", errors="ignore") for path in traces
    )
    pcs = [int(value, 16) for value in TRACE_PC.findall(trace_text)]
    exit_path = run_dir / "xrun.exit_code"
    exit_code = int(exit_path.read_text().strip()) if exit_path.exists() else -1

    fsdb = run_dir / "fsdb/common_init.fsdb"
    ucds = sorted((run_dir / "coverage").rglob("*.ucd"))
    report = run_dir / "coverage/cov_report.txt"
    report_text = report.read_text(encoding="utf-8", errors="ignore") if report.exists() else ""

    failures = []
    if DONE_MARKER not in log_text:
        failures.append("missing_retirement_marker")
    if not pcs or pcs[-1] != 0x8000011C:
        failures.append("wrong_last_retired_pc")
    if any(pc >= 0x80000120 for pc in pcs):
        failures.append("executed_beyond_common_prefix")
    if exit_code != 0:
        failures.append("xrun_exit")
    if not fsdb.exists() or fsdb.stat().st_size == 0:
        failures.append("missing_fsdb")
    if (run_dir / "fsdb/common_init.fsdb.lock").exists():
        failures.append("incomplete_fsdb")
    if not ucds:
        failures.append("missing_coverage_database")
    if "ibex_top" not in report_text:
        failures.append("missing_dut_coverage_report")
    if "core_ibex_tb_top" in report_text:
        failures.append("testbench_in_published_coverage")

    result = {
        "status": "pass" if not failures else "fail",
        "xrun_exit_code": exit_code,
        "retirement_marker": DONE_MARKER in log_text,
        "last_retired_pc": f"0x{pcs[-1]:08x}" if pcs else "",
        "retired_instruction_count": len(pcs),
        "fsdb": str(fsdb) if fsdb.exists() else "",
        "fsdb_bytes": fsdb.stat().st_size if fsdb.exists() else 0,
        "coverage_ucds": [str(path) for path in ucds],
        "coverage_report": str(report) if report.exists() else "",
        "failures": failures,
    }
    (run_dir / "result.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result, indent=2))
    return 0 if not failures else 1


if __name__ == "__main__":
    raise SystemExit(main())
