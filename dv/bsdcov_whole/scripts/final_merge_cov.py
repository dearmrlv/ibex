#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import json
import shutil
import sys
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

from _launch_sim import METRICS, _run_imc_report, parse_cov_report  # noqa: E402


def _repo_root() -> Path:
    return Path(__file__).resolve().parents[3]


def _latest_ucds(run_dir: Path) -> list[Path]:
    prefix_dirs = sorted(run_dir.glob("coverage/prefix_*/merged"))
    if prefix_dirs:
        merged_dir = prefix_dirs[-1]
        ucds = sorted(merged_dir.glob("*.ucd"))
        if ucds:
            return ucds
    return sorted(run_dir.glob("**/*.ucd"))


def _write_csv(path: Path, rows: list[dict[str, object]], fieldnames: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as fd:
        writer = csv.DictWriter(fd, fieldnames=fieldnames, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)


def main() -> int:
    parser = argparse.ArgumentParser(description="Merge baseline and final run coverage databases into one final coverage row.")
    parser.add_argument("--source-run-dir", action="append", type=Path, required=True)
    parser.add_argument("--out-dir", type=Path, required=True)
    parser.add_argument("--instruction-count", type=int, required=True)
    parser.add_argument("--module", default="ibex_top")
    parser.add_argument("--case-name", default="merged")
    parser.add_argument("--repo-root", type=Path, default=_repo_root())
    args = parser.parse_args()

    out_dir = args.out_dir.expanduser().resolve()
    if out_dir.exists():
        shutil.rmtree(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    ucds: list[Path] = []
    source_run_dirs: list[str] = []
    for run_dir in args.source_run_dir:
        resolved = run_dir.expanduser().resolve()
        source_run_dirs.append(str(resolved))
        run_ucds = _latest_ucds(resolved)
        if not run_ucds:
            raise RuntimeError(f"no UCDs found under {resolved}")
        ucds.extend(run_ucds)

    report = _run_imc_report(
        repo_root=args.repo_root.expanduser().resolve(),
        run_dir=out_dir,
        prefix_idx=1,
        ucds=ucds,
        module=args.module,
        dry_run=False,
    )
    if report is None or not report.exists():
        raise RuntimeError(f"IMC coverage report was not produced under {out_dir}")

    final_report = out_dir / "cov_report.txt"
    shutil.copy2(report, final_report)

    cov = parse_cov_report(report, args.module)
    sample_row: dict[str, object] = {
        "sample_idx": 1,
        "instruction_count": args.instruction_count,
        "num_chunks": 1,
        "chunk_status": "pass",
        "coverage_included": 1,
        "cov_report": str(report),
    }
    for metric in METRICS:
        data = cov.get(metric, {})
        sample_row[f"{metric}_pct"] = data.get("pct", "")
        sample_row[f"{metric}_covered"] = data.get("covered", "")
        sample_row[f"{metric}_total"] = data.get("total", "")
        sample_row[f"{metric}_uncovered"] = data.get("uncovered", "")

    sample_fields = ["sample_idx", "instruction_count", "num_chunks", "chunk_status", "coverage_included", "cov_report"]
    for metric in METRICS:
        sample_fields.extend([f"{metric}_pct", f"{metric}_covered", f"{metric}_total", f"{metric}_uncovered"])
    _write_csv(out_dir / "samples.csv", [sample_row], sample_fields)

    summary = {"case_name": args.case_name, "instruction_count": args.instruction_count, "module": args.module, "source_run_dirs": source_run_dirs, "source_ucds": [str(p) for p in ucds], "cov_report": str(final_report), "samples_csv": str(out_dir / "samples.csv")}
    (out_dir / "coverage_summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {final_report}")
    print(f"Wrote {out_dir / 'samples.csv'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
