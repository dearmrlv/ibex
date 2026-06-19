#!/usr/bin/env python3
from __future__ import annotations

import json
import sys
from pathlib import Path


def main() -> int:
    run = Path(sys.argv[1]).resolve()
    result = json.loads((run / "result.json").read_text())
    generated_range = "empty"
    if result["generated_start"]:
        generated_range = f'{result["generated_start"]}..{result["generated_end"]}'
    print()
    print(f'BSD-COV instruction evaluation: {result["status"].upper()}')
    print(f"Run                  : {run}")
    print(f'Input instructions   : {result["generated_instruction_count"]}')
    print(f"Generated range      : {generated_range}")
    print(f'Stop PC              : {result["stop_pc"]}')
    print(f'Stop instruction     : {result["stop_instruction"]}')
    print(f'Retired target       : {"yes" if result["retirement_marker"] else "no"}')
    print(f'Hang on imem         : {result["hang_on_imem"]}')
    if result["hang_on_imem"] == "on":
        print(f'IMEM response range  : {result["imem_response_start"]}..{result["imem_response_end"]}')
        print(f'Blocked request seen : {"yes" if result["blocked_request_seen"] else "no"}')
    print(f'Binary               : {result["binary"]}')
    print(f'Formal imem          : {result["imem_sv"]}')
    print(f'FSDB                 : {result["fsdb"]}')
    print(f'Coverage report      : {result["coverage_report"]}')
    report = Path(result["coverage_report"])
    if report.exists():
        print("\nDUT Coverage")
        print(report.read_text(encoding="utf-8", errors="ignore").rstrip())
    if result["failures"]:
        print("\nFailures             : " + ", ".join(result["failures"]))
        print(f"Simulation log       : {run / 'sim/rtl_sim.log'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
