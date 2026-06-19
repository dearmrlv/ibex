#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
from pathlib import Path


METRICS = ["block", "branch", "statement", "expression", "toggle", "statement_dup", "fsm", "assertion", "covergroup"]
MONOTONIC_COVERED_METRICS = {"block", "branch", "statement", "expression", "statement_dup", "fsm", "assertion"}
DIAGNOSTIC_COVERED_METRICS = set(METRICS) - MONOTONIC_COVERED_METRICS


def final_sample(path: Path) -> dict[str, str]:
    rows = list(csv.DictReader(path.open(encoding="utf-8", errors="ignore")))
    if not rows:
        raise RuntimeError(f"no coverage rows in {path}")
    return rows[-1]


def pct(row: dict[str, str], metric: str) -> float | None:
    value = row.get(f"{metric}_pct", "")
    try:
        return float(value)
    except ValueError:
        return None


def int_value(row: dict[str, str], field: str) -> int | None:
    value = row.get(field, "")
    try:
        return int(value)
    except ValueError:
        return None


def validate_coverage_rows(rows: list[dict[str, str]]) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []
    base = rows[0]
    for row in rows[1:]:
        case = row["case"]
        for metric in METRICS:
            total_field = f"{metric}_total"
            covered_field = f"{metric}_covered"
            base_total = int_value(base, total_field)
            total = int_value(row, total_field)
            if base_total is not None and total is not None and total != base_total:
                errors.append(f"{case}: {metric} total mismatch: baseline={base_total}, {case}={total}")
            base_covered = int_value(base, covered_field)
            covered = int_value(row, covered_field)
            if base_covered is not None and covered is not None and covered < base_covered:
                msg = f"{case}: {metric} covered count decreased: baseline={base_covered}, {case}={covered}"
                if metric in MONOTONIC_COVERED_METRICS:
                    errors.append(msg)
                elif metric in DIAGNOSTIC_COVERED_METRICS:
                    warnings.append(msg)
    return errors, warnings


def main() -> int:
    parser = argparse.ArgumentParser(description="Summarize final coverage rows from BSD-Cov whole-flow runs.")
    parser.add_argument("--baseline", type=Path, required=True)
    parser.add_argument("--bsdcov", type=Path, required=True)
    parser.add_argument("--baseline-extra", type=Path, required=True)
    parser.add_argument("--out-dir", type=Path, required=True)
    args = parser.parse_args()

    inputs = [
        ("baseline", args.baseline),
        ("baseline_plus_bsdcov", args.bsdcov),
        ("baseline_extra_same_budget", args.baseline_extra),
    ]
    rows: list[dict[str, str]] = []
    for label, sample_path in inputs:
        sample = final_sample(sample_path)
        row = {
            "case": label,
            "instruction_count": sample.get("instruction_count", ""),
            "samples_csv": str(sample_path.resolve()),
        }
        for metric in METRICS:
            row[f"{metric}_pct"] = sample.get(f"{metric}_pct", "")
            row[f"{metric}_covered"] = sample.get(f"{metric}_covered", "")
            row[f"{metric}_total"] = sample.get(f"{metric}_total", "")
        rows.append(row)

    validation_errors, validation_warnings = validate_coverage_rows(rows)

    args.out_dir.mkdir(parents=True, exist_ok=True)
    csv_path = args.out_dir / "coverage_compare.csv"
    fieldnames = ["case", "instruction_count", "samples_csv"] + [f"{metric}_pct" for metric in METRICS]
    with csv_path.open("w", encoding="utf-8", newline="") as fd:
        writer = csv.DictWriter(fd, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows({key: row.get(key, "") for key in fieldnames} for row in rows)

    base = rows[0]
    lines = ["# BSD-Cov Whole-Flow Coverage Comparison", "", "| Case | Instr | " + " | ".join(METRICS) + " |", "|---|---:|" + "|".join("---:" for _ in METRICS) + "|"]
    for row in rows:
        vals = [row["case"], row["instruction_count"]] + [row.get(f"{metric}_pct", "") for metric in METRICS]
        lines.append("| " + " | ".join(vals) + " |")
    lines.extend(["", "## Delta vs Baseline", "", "| Case | " + " | ".join(METRICS) + " |", "|---|" + "|".join("---:" for _ in METRICS) + "|"])
    for row in rows[1:]:
        vals = [row["case"]]
        for metric in METRICS:
            a = pct(base, metric)
            b = pct(row, metric)
            vals.append("" if a is None or b is None else f"{b - a:+.2f}")
        lines.append("| " + " | ".join(vals) + " |")
    md_path = args.out_dir / "coverage_compare.md"
    if validation_errors:
        lines.extend(["", "## Validation Errors", ""])
        lines.extend(f"- {err}" for err in validation_errors)
    if validation_warnings:
        lines.extend(["", "## Validation Warnings", ""])
        lines.extend(f"- {warning}" for warning in validation_warnings)
    md_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {csv_path}")
    print(f"Wrote {md_path}")
    if validation_errors:
        raise RuntimeError("coverage comparison validation failed:\n" + "\n".join(validation_errors))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
