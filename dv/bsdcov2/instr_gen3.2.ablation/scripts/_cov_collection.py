#!/usr/bin/env python3
from __future__ import annotations

import csv
import html
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable

METRICS = ("block", "branch", "statement", "expression", "toggle", "fsm", "covergroup")
HEADER_NAMES = {
    "Block": "block",
    "Branch": "branch",
    "Statement": "statement",
    "Expression": "expression",
    "Toggle": "toggle",
    "Fsm": "fsm",
    "CoverGroup": "covergroup",
}


@dataclass(frozen=True)
class CovUnitData:
    covered: int
    total: int
    percent: float

    def __post_init__(self) -> None:
        if self.covered < 0 or self.total < 0:
            raise ValueError("coverage counts must be non-negative")
        if self.covered > self.total:
            raise ValueError(f"covered bins exceed total bins: {self.covered}/{self.total}")
        if self.percent < 0.0 or self.percent > 100.0:
            raise ValueError(f"coverage percent is outside [0, 100]: {self.percent}")

    @classmethod
    def from_dict(cls, value: dict[str, Any]) -> "CovUnitData":
        return cls(covered=int(value["covered"]), total=int(value["total"]),
                   percent=float(value["percent"]))

    def to_dict(self) -> dict[str, int | float]:
        return {"covered": self.covered, "total": self.total, "percent": self.percent}

    def higher_than(self, other: "CovUnitData") -> bool:
        self._check_model(other)
        return self.covered > other.covered

    def delta(self, other: "CovUnitData") -> int:
        self._check_model(other)
        return self.covered - other.covered

    def _check_model(self, other: "CovUnitData") -> None:
        if self.total != other.total:
            raise ValueError(f"coverage model total changed: {other.total} -> {self.total}")


@dataclass(frozen=True)
class CovData:
    block: CovUnitData
    branch: CovUnitData
    statement: CovUnitData
    expression: CovUnitData
    toggle: CovUnitData
    fsm: CovUnitData
    covergroup: CovUnitData

    @classmethod
    def from_report(cls, path: Path, module: str = "ibex_top") -> "CovData":
        return cls.from_dict(parse_report(path, module))

    @classmethod
    def from_dict(cls, value: dict[str, Any]) -> "CovData":
        missing = set(METRICS) - set(value)
        if missing:
            raise ValueError(f"coverage data is missing metrics: {sorted(missing)}")
        return cls(**{metric: CovUnitData.from_dict(value[metric]) for metric in METRICS})

    def to_dict(self) -> dict[str, dict[str, int | float]]:
        return {metric: self.metric(metric).to_dict() for metric in METRICS}

    def metric(self, name: str) -> CovUnitData:
        if name not in METRICS:
            raise KeyError(f"unknown coverage metric: {name}")
        return getattr(self, name)

    def higher_than(self, other: "CovData") -> bool:
        return any(value > 0 for value in self.delta(other).values())

    def delta(self, other: "CovData") -> dict[str, int]:
        return {metric: self.metric(metric).delta(other.metric(metric)) for metric in METRICS}


class CovCollection:
    def __init__(self, data: Iterable[tuple[int, CovData] | list[Any]] | None = None):
        self.data: list[tuple[int, CovData]] = []
        for item in data or []:
            self.append(item)

    def append(self, data: tuple[int, CovData] | list[Any]) -> None:
        if len(data) != 2:
            raise ValueError(f"coverage point must contain instruction count and coverage: {data}")
        num_instr, coverage = data
        num_instr = int(num_instr)
        if num_instr < 0:
            raise ValueError(f"instruction count must be non-negative: {num_instr}")
        if not isinstance(coverage, CovData):
            raise TypeError(f"coverage point requires CovData, got {type(coverage).__name__}")
        if self.data and num_instr < self.data[-1][0]:
            raise ValueError(f"instruction count decreased: {self.data[-1][0]} -> {num_instr}")
        if self.data and num_instr == self.data[-1][0] and coverage == self.data[-1][1]:
            return
        self.data.append((num_instr, coverage))

    def report(self, rpt_dir: Path, title: str = "BSD-Cov instruction coverage") -> tuple[Path, Path]:
        if not self.data:
            raise RuntimeError("cannot report an empty coverage collection")
        rpt_dir.mkdir(parents=True, exist_ok=True)
        csv_path = rpt_dir / "coverage_curve.csv"
        svg_path = rpt_dir / "coverage_curve.svg"
        _write_curve_csv(csv_path, self.data)
        _write_curve_svg(svg_path, self.data, title)
        return csv_path, svg_path


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
        if metric is None or metric in parsed:
            continue
        counts = [int(value) for value in re.findall(r"\d+", fraction)]
        if len(counts) < 2:
            raise RuntimeError(f"invalid {metric} coverage count in {path}: {fraction}")
        parsed[metric] = {"percent": float(percent), "covered": counts[0], "total": counts[1]}

    missing = set(METRICS) - set(parsed)
    if missing:
        raise RuntimeError(f"coverage report is missing metrics {sorted(missing)}: {path}")
    return parsed


def improves(old: CovData | dict[str, Any], new: CovData | dict[str, Any]) -> tuple[bool, dict[str, int]]:
    old_data = old if isinstance(old, CovData) else CovData.from_dict(old)
    new_data = new if isinstance(new, CovData) else CovData.from_dict(new)
    delta = new_data.delta(old_data)
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


def _write_curve_csv(path: Path, data: list[tuple[int, CovData]]) -> None:
    fields = ["bin_instruction_count"]
    for metric in METRICS:
        fields.extend([f"{metric}_covered", f"{metric}_total", f"{metric}_percent"])
    with path.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=fields)
        writer.writeheader()
        for num_instr, coverage in data:
            row: dict[str, int | float] = {"bin_instruction_count": num_instr}
            for metric in METRICS:
                unit = coverage.metric(metric)
                row[f"{metric}_covered"] = unit.covered
                row[f"{metric}_total"] = unit.total
                row[f"{metric}_percent"] = unit.percent
            writer.writerow(row)


def _write_curve_svg(path: Path, data: list[tuple[int, CovData]], title: str) -> None:
    width, height = 1100, 650
    left, right, top, bottom = 90, 260, 55, 80
    plot_w = width - left - right
    plot_h = height - top - bottom
    xs = [float(num_instr) for num_instr, _coverage in data]
    x_min, x_max = min(xs), max(xs)
    if x_min == x_max:
        x_min -= 1.0
        x_max += 1.0
    all_y = [coverage.metric(metric).percent
             for _num_instr, coverage in data for metric in METRICS]
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
        "block": "#1f77b4", "branch": "#d62728", "statement": "#2ca02c",
        "expression": "#9467bd", "toggle": "#ff7f0e", "fsm": "#17becf",
        "covergroup": "#111111",
    }
    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
        f'viewBox="0 0 {width} {height}">',
        '<rect width="100%" height="100%" fill="white"/>',
        f'<text x="{left}" y="32" font-family="sans-serif" font-size="20" '
        f'font-weight="700">{html.escape(title)}</text>',
        f'<line x1="{left}" y1="{top + plot_h}" x2="{left + plot_w}" '
        f'y2="{top + plot_h}" stroke="#333"/>',
        f'<line x1="{left}" y1="{top}" x2="{left}" y2="{top + plot_h}" stroke="#333"/>',
    ]
    for index in range(6):
        y_value = y_min + (y_max - y_min) * index / 5
        y = sy(y_value)
        parts.append(f'<line x1="{left}" y1="{y:.2f}" x2="{left + plot_w}" '
                     f'y2="{y:.2f}" stroke="#e6e6e6"/>')
        parts.append(f'<text x="{left - 12}" y="{y + 4:.2f}" text-anchor="end" '
                     f'font-family="sans-serif" font-size="12">{y_value:.1f}</text>')
    for index in range(6):
        x_value = x_min + (x_max - x_min) * index / 5
        x = sx(x_value)
        parts.append(f'<line x1="{x:.2f}" y1="{top + plot_h}" x2="{x:.2f}" '
                     f'y2="{top + plot_h + 6}" stroke="#333"/>')
        parts.append(f'<text x="{x:.2f}" y="{top + plot_h + 24}" text-anchor="middle" '
                     f'font-family="sans-serif" font-size="12">{x_value:.0f}</text>')
    parts.append(f'<text x="{left + plot_w / 2:.2f}" y="{height - 24}" '
                 f'text-anchor="middle" font-family="sans-serif" font-size="14">'
                 'binary instruction count</text>')
    parts.append(f'<text x="20" y="{top + plot_h / 2:.2f}" '
                 f'transform="rotate(-90 20 {top + plot_h / 2:.2f})" text-anchor="middle" '
                 f'font-family="sans-serif" font-size="14">coverage percent</text>')

    for index, metric in enumerate(METRICS):
        points = " ".join(
            f'{sx(float(num_instr)):.2f},{sy(coverage.metric(metric).percent):.2f}'
            for num_instr, coverage in data)
        color = colors[metric]
        parts.append(f'<polyline fill="none" stroke="{color}" stroke-width="2.5" '
                     f'points="{points}"/>')
        for num_instr, coverage in data:
            parts.append(f'<circle cx="{sx(float(num_instr)):.2f}" '
                         f'cy="{sy(coverage.metric(metric).percent):.2f}" r="3" fill="{color}"/>')
        legend_y = top + 24 + index * 24
        legend_x = left + plot_w + 35
        parts.append(f'<line x1="{legend_x}" y1="{legend_y}" x2="{legend_x + 28}" '
                     f'y2="{legend_y}" stroke="{color}" stroke-width="3"/>')
        parts.append(f'<text x="{legend_x + 38}" y="{legend_y + 5}" '
                     f'font-family="sans-serif" font-size="13">{metric}</text>')
    parts.append("</svg>")
    path.write_text("\n".join(parts) + "\n", encoding="utf-8")
