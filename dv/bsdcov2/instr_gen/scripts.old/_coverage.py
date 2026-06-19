#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
import csv
import html
from pathlib import Path
from typing import Any

METRICS = ("block", "branch", "statement", "expression", "toggle", "fsm", "covergroup")
HEADER_NAMES = {
    "Block": "block", "Branch": "branch", "Statement": "statement",
    "Expression": "expression", "Toggle": "toggle", "Fsm": "fsm",
    "CoverGroup": "covergroup",
}


def parse_report(path: Path, module: str = "ibex_top") -> dict[str, dict[str, float | int]]:
    lines = path.read_text(encoding="utf-8", errors="ignore").splitlines()
    header = next((line for line in lines if line.startswith("name ")), None)
    row = next((line for line in lines if line.split()[:1] == [module]), None)
    if not header or not row:
        raise RuntimeError(f"cannot find {module} coverage row in {path}")
    columns = [HEADER_NAMES.get(name) for name in
               re.findall(r"([A-Za-z]+)\*? Covered", header)]
    values = re.findall(r"([0-9.]+)%\s*\(([^)]*)\)", row)
    parsed: dict[str, dict[str, float | int]] = {}
    for metric, (percent, fraction) in zip(columns, values):
        if metric is None or metric in parsed:  # Skip Assertion and duplicate Statement.
            continue
        nums = [int(value) for value in re.findall(r"\d+", fraction)]
        parsed[metric] = {"percent": float(percent), "covered": nums[0],
                          "total": nums[1] if len(nums) > 1 else 0}
    missing = set(METRICS) - set(parsed)
    if missing:
        raise RuntimeError(f"coverage report is missing metrics {sorted(missing)}: {path}")
    return parsed


def improves(old: dict[str, dict[str, Any]], new: dict[str, dict[str, Any]]) -> tuple[bool, dict[str, int]]:
    delta = {metric: int(new[metric]["covered"]) - int(old[metric]["covered"])
             for metric in METRICS}
    return any(value > 0 for value in delta.values()), delta


def find_ucds(run_dir: Path) -> list[Path]:
    return sorted((run_dir / "coverage").glob("**/*.ucd"))


def merged_report(ibex_root: Path, owner_run: Path, ucds: list[Path], index: int) -> Path:
    scripts = ibex_root / "dv/bsdcov_whole_mc/scripts"
    sys.path.insert(0, str(scripts))
    from _launch_sim import _run_imc_report  # type: ignore
    report = _run_imc_report(repo_root=ibex_root, run_dir=owner_run,
                             prefix_idx=index, ucds=ucds,
                             module="ibex_top", dry_run=False)
    if report is None or not report.exists():
        raise RuntimeError("IMC did not produce cumulative coverage report")
    return report


def write_curve_csv(path: Path, rows: list[dict[str, Any]]) -> None:
    fields = ["accepted_iteration", "bin_instruction_count", "image_word_count",
              "generated_word_count", "retired_instruction_count", "property"]
    for metric in METRICS:
        fields.extend([f"{metric}_covered", f"{metric}_total", f"{metric}_percent"])
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=fields, extrasaction="ignore")
        writer.writeheader()
        for row in rows:
            writer.writerow(row)


def write_curve_svg(path: Path, rows: list[dict[str, Any]], title: str) -> None:
    if not rows:
        raise RuntimeError("cannot render an empty coverage curve")
    width, height = 1100, 650
    left, right, top, bottom = 90, 260, 55, 80
    plot_w = width - left - right
    plot_h = height - top - bottom
    xs = [float(row["bin_instruction_count"]) for row in rows]
    x_min, x_max = min(xs), max(xs)
    if x_min == x_max:
        x_min -= 1.0
        x_max += 1.0
    all_y = []
    for row in rows:
        for metric in METRICS:
            all_y.append(float(row[f"{metric}_percent"]))
    y_min = max(0.0, min(all_y) - 1.0)
    y_max = min(100.0, max(all_y) + 1.0)
    if y_min == y_max:
        y_min = max(0.0, y_min - 1.0)
        y_max = min(100.0, y_max + 1.0)

    def sx(value: float) -> float:
        return left + (value - x_min) * plot_w / (x_max - x_min)

    def sy(value: float) -> float:
        return top + (y_max - value) * plot_h / (y_max - y_min)

    colors = {
        "block": "#1f77b4",
        "branch": "#d62728",
        "statement": "#2ca02c",
        "expression": "#9467bd",
        "toggle": "#ff7f0e",
        "fsm": "#17becf",
        "covergroup": "#111111",
    }
    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
        '<rect width="100%" height="100%" fill="white"/>',
        f'<text x="{left}" y="32" font-family="sans-serif" font-size="20" font-weight="700">{html.escape(title)}</text>',
        f'<line x1="{left}" y1="{top + plot_h}" x2="{left + plot_w}" y2="{top + plot_h}" stroke="#333"/>',
        f'<line x1="{left}" y1="{top}" x2="{left}" y2="{top + plot_h}" stroke="#333"/>',
    ]
    for i in range(6):
        y_value = y_min + (y_max - y_min) * i / 5
        y = sy(y_value)
        parts.append(f'<line x1="{left}" y1="{y:.2f}" x2="{left + plot_w}" y2="{y:.2f}" stroke="#e6e6e6"/>')
        parts.append(f'<text x="{left - 12}" y="{y + 4:.2f}" text-anchor="end" font-family="sans-serif" font-size="12">{y_value:.1f}</text>')
    for i in range(6):
        x_value = x_min + (x_max - x_min) * i / 5
        x = sx(x_value)
        parts.append(f'<line x1="{x:.2f}" y1="{top + plot_h}" x2="{x:.2f}" y2="{top + plot_h + 6}" stroke="#333"/>')
        parts.append(f'<text x="{x:.2f}" y="{top + plot_h + 24}" text-anchor="middle" font-family="sans-serif" font-size="12">{x_value:.0f}</text>')
    parts.append(f'<text x="{left + plot_w / 2:.2f}" y="{height - 24}" text-anchor="middle" font-family="sans-serif" font-size="14">binary instruction words</text>')
    parts.append(f'<text x="20" y="{top + plot_h / 2:.2f}" transform="rotate(-90 20 {top + plot_h / 2:.2f})" text-anchor="middle" font-family="sans-serif" font-size="14">coverage percent</text>')
    for idx, metric in enumerate(METRICS):
        points = " ".join(
            f'{sx(float(row["bin_instruction_count"])):.2f},{sy(float(row[f"{metric}_percent"])):.2f}'
            for row in rows)
        color = colors[metric]
        parts.append(f'<polyline fill="none" stroke="{color}" stroke-width="2.5" points="{points}"/>')
        for row in rows:
            parts.append(f'<circle cx="{sx(float(row["bin_instruction_count"])):.2f}" cy="{sy(float(row[f"{metric}_percent"])):.2f}" r="3" fill="{color}"/>')
        ly = top + 24 + idx * 24
        lx = left + plot_w + 35
        parts.append(f'<line x1="{lx}" y1="{ly}" x2="{lx + 28}" y2="{ly}" stroke="{color}" stroke-width="3"/>')
        parts.append(f'<text x="{lx + 38}" y="{ly + 5}" font-family="sans-serif" font-size="13">{metric}</text>')
    parts.append("</svg>")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(parts) + "\n", encoding="utf-8")
