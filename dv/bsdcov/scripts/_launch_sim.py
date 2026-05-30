#!/usr/bin/env python3
"""Launch BSD-Cov Ibex simulations for generated instruction chunks.

This internal Python implementation is normally entered through
``dv/bsdcov/scripts/launch_sim.sh``.  It intentionally implements the
"independent standalone chunks + cumulative prefix coverage merge" workflow:

* each ``--instr-seq`` .S file is compiled and simulated as its own standalone
  test;
* chunk simulations may run independently;
* coverage samples are produced by prefix-merging chunk coverage databases in the
  user-provided order;
* BSD-Cov IO samples dumped by bind/interface files are collected per chunk and
  merged into cook-ready CSVs.

This is cumulative test-suite coverage, not a single continuously-running
processor state sampled at runtime.
"""

from __future__ import annotations

import argparse
import csv
import json
import math
import os
import re
import shlex
import shutil
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable

METRICS = [
    "block",
    "branch",
    "statement",
    "expression",
    "toggle",
    "statement_dup",
    "fsm",
    "assertion",
    "covergroup",
]

COVERAGE_RE = re.compile(r"(?P<pct>\d+(?:\.\d+)?)%\s*\((?P<body>[^)]*)\)")
ASM_DIRECTIVES = {
    ".align", ".balign", ".byte", ".dword", ".end", ".equ", ".file", ".globl",
    ".global", ".half", ".incbin", ".option", ".org", ".pushsection", ".popsection",
    ".quad", ".section", ".set", ".size", ".space", ".string", ".text", ".type",
    ".word", ".zero",
}
IO_SAMPLE_PREFIX = "bsdcov_trace_"
IO_SAMPLE_SUFFIX = ".io_samples.csv"


@dataclass(frozen=True)
class ChunkSpec:
    index: int
    asm: Path
    seed: int
    sample_instruction_count: int
    test_name: str


@dataclass
class ChunkResult:
    index: int
    test_name: str
    seed: int
    asm: str
    chunk_dir: str
    binary: str
    rtl_sim_log: str
    rtl_trace: str
    cosim_log: str
    coverage_ucds: list[str]
    status: str
    elapsed_s: float
    static_instr_count: int
    static_main_instr_count: int


def _repo_root() -> Path:
    return Path(__file__).resolve().parents[3]


def _bsdcov_dir() -> Path:
    return Path(__file__).resolve().parents[1]


def _timestamp_tag() -> str:
    return datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")


def _positive_int(value: str) -> int:
    try:
        parsed = int(value, 0)
    except ValueError as err:
        raise argparse.ArgumentTypeError(f"expected integer, got {value!r}") from err
    if parsed <= 0:
        raise argparse.ArgumentTypeError(f"expected positive integer, got {value!r}")
    return parsed


def _nonnegative_int(value: str) -> int:
    try:
        parsed = int(value, 0)
    except ValueError as err:
        raise argparse.ArgumentTypeError(f"expected integer, got {value!r}") from err
    if parsed < 0:
        raise argparse.ArgumentTypeError(f"expected non-negative integer, got {value!r}")
    return parsed


def _resolve_python(repo_root: Path, override: Path | None) -> Path:
    if override is not None:
        python = override.expanduser()
        if not python.exists():
            raise RuntimeError(f"requested Python executable does not exist: {python}")
        return python
    venv_python = repo_root / ".venv" / "bin" / "python"
    if venv_python.exists():
        return venv_python
    return Path(sys.executable)


def _build_pythonpath(repo_root: Path) -> str:
    core_ibex = repo_root / "dv" / "uvm" / "core_ibex"
    riscvdv_root = repo_root / "vendor" / "google_riscv-dv"
    paths = [
        repo_root,
        repo_root / "util",
        core_ibex / "scripts",
        core_ibex / "riscv_dv_extension",
        core_ibex / "yaml",
        riscvdv_root,
        riscvdv_root / "scripts",
        riscvdv_root / "pygen",
        riscvdv_root / "pygen" / "pygen_src",
    ]
    existing = os.environ.get("PYTHONPATH", "")
    if existing:
        paths.extend(Path(item) for item in existing.split(os.pathsep) if item)
    return os.pathsep.join(str(path) for path in paths)


def _base_env(repo_root: Path, bind_flists: list[Path], python: Path) -> dict[str, str]:
    env = os.environ.copy()
    venv_bin = repo_root / ".venv" / "bin"
    if venv_bin.exists():
        env["VIRTUAL_ENV"] = str(repo_root / ".venv")
        env["PATH"] = str(venv_bin) + os.pathsep + env.get("PATH", "")
    else:
        env["PATH"] = str(python.parent) + os.pathsep + env.get("PATH", "")
    env["PYTHONPATH"] = _build_pythonpath(repo_root)
    env.setdefault("IBEX_ROOT", str(repo_root))
    env.setdefault("PRJ_DIR", str(repo_root))
    env.setdefault("LOWRISC_IP_DIR", str(repo_root / "vendor" / "lowrisc_ip"))
    env.setdefault("DUT_TOP", "ibex_top")
    env.setdefault("dv_root", str(repo_root / "vendor" / "lowrisc_ip" / "dv"))
    env.setdefault("EXTRA_COSIM_CFLAGS", "")
    if bind_flists:
        env["BSD_COV_EXTRA_XRUN_FILELISTS"] = " ".join(str(p) for p in bind_flists)
    return env


def _read_list_file(path: Path) -> list[Path]:
    out: list[Path] = []
    for raw in path.read_text(encoding="utf-8", errors="ignore").splitlines():
        line = raw.split("#", 1)[0].strip()
        if line:
            out.append(Path(line).expanduser())
    return out


def _expand_instr_seq(items: list[Path]) -> list[Path]:
    out: list[Path] = []
    for item in items:
        path = item.expanduser()
        if not path.is_absolute():
            path = (Path.cwd() / path).resolve()
        if path.suffix in {".f", ".list"} or path.name.endswith(".chunks.f"):
            for sub in _read_list_file(path):
                if not sub.is_absolute():
                    sub = (path.parent / sub).resolve()
                out.append(sub)
        else:
            out.append(path)
    if not out:
        raise RuntimeError("at least one --instr-seq .S or .chunks.f is required")
    for path in out:
        if not path.exists():
            raise RuntimeError(f"instruction sequence does not exist: {path}")
        if path.suffix != ".S":
            raise RuntimeError(f"instruction sequence must be a .S file: {path}")
    return out


def _resolve_bind_flists(items: list[Path]) -> list[Path]:
    out: list[Path] = []
    for item in items:
        path = item.expanduser()
        if not path.is_absolute():
            path = (Path.cwd() / path).resolve()
        if not path.exists():
            raise RuntimeError(f"bind filelist does not exist: {path}")
        out.append(path)
    return out


def _run(cmd: list[str], *, cwd: Path, env: dict[str, str], log: Path | None = None,
         dry_run: bool = False) -> None:
    cmd_text = shlex.join(str(x) for x in cmd)
    if log is not None:
        log.parent.mkdir(parents=True, exist_ok=True)
        with log.open("a", encoding="utf-8") as fd:
            fd.write(f"$ {cmd_text}\n")
    if dry_run:
        return
    if log is None:
        subprocess.run(cmd, cwd=str(cwd), env=env, check=True)
        return
    with log.open("ab") as fd:
        result = subprocess.run(cmd, cwd=str(cwd), env=env,
                                stdout=fd, stderr=subprocess.STDOUT, check=False)
    if result.returncode != 0:
        raise RuntimeError(f"command failed with exit code {result.returncode}; see {log}: {cmd_text}")


def _run_shell(command: str, *, cwd: Path, env: dict[str, str], log: Path,
               dry_run: bool = False) -> None:
    log.parent.mkdir(parents=True, exist_ok=True)
    with log.open("a", encoding="utf-8") as fd:
        fd.write(f"$ {command}\n")
    if dry_run:
        return
    with log.open("ab") as fd:
        result = subprocess.run(["/bin/bash", "-lc", command], cwd=str(cwd), env=env,
                                stdout=fd, stderr=subprocess.STDOUT, check=False)
    if result.returncode != 0:
        raise RuntimeError(f"shell command failed with exit code {result.returncode}; see {log}: {command}")


def _source_setup_prefix(core_ibex: Path) -> str:
    setup = core_ibex / "setup_env.sh"
    if setup.exists():
        return f"source {shlex.quote(str(setup))} && "
    return ""


def _compile_tb(*, repo_root: Path, run_dir: Path, bind_flists: list[Path], python: Path,
                simulator: str, iss: str, seed: int, force_compile: bool,
                dry_run: bool) -> Path:
    core_ibex = repo_root / "dv" / "uvm" / "core_ibex"
    out_dir = run_dir / "ibex_dv_out"
    env = _base_env(repo_root, bind_flists, python)
    make_args = [
        "make", "--keep-going", "GOAL=rtl_tb_compile", f"OUT={out_dir}",
        "IBEX_CONFIG=opentitan", f"SIMULATOR={simulator}", f"ISS={iss}",
        "TEST=empty", "ITERATIONS=1", f"SEED={seed}", "WAVES=0", "COV=1", "VERBOSE=0",
    ]
    if force_compile:
        make_args.insert(2, "-B")
    command = _source_setup_prefix(core_ibex) + shlex.join(make_args)
    _run_shell(command, cwd=core_ibex, env=env, log=run_dir / "logs" / "rtl_tb_compile.log",
               dry_run=dry_run)
    return out_dir / "build" / "tb"


def _compile_asm(*, repo_root: Path, python: Path, asm: Path, chunk_dir: Path, seed: int,
                 isa: str, mabi: str, iss: str, dry_run: bool) -> Path:
    riscvdv_root = repo_root / "vendor" / "google_riscv-dv"
    core_ibex = repo_root / "dv" / "uvm" / "core_ibex"
    out_dir = chunk_dir / "asm_compile"
    env = _base_env(repo_root, [], python)
    cmd = [
        str(python), str(riscvdv_root / "run.py"), "--asm_test", str(asm),
        "--target", isa, "--custom_target", str(core_ibex / "riscv_dv_extension"),
        "--csr_yaml", str(core_ibex / "riscv_dv_extension" / "csr_description.yaml"),
        "--mabi", mabi, "--isa", isa, "--iss", iss, "--seed", str(seed),
        "--output", str(out_dir), "--gcc_opts=-mno-strict-align",
    ]
    _run(cmd, cwd=repo_root, env=env, log=chunk_dir / "compile_asm.log", dry_run=dry_run)
    binary = out_dir / "directed_asm_test" / (asm.stem + ".bin")
    if not dry_run and not binary.exists():
        raise RuntimeError(f"compiled binary was not produced: {binary}")
    return binary


def _xrun_binary(repo_root: Path) -> str:
    if os.environ.get("CADENCE_XRUN"):
        return os.environ["CADENCE_XRUN"]
    wrapper = Path("/home/lvzhengyang/workspace/cadence/xrun")
    if wrapper.exists():
        return str(wrapper)
    return "xrun"


def _run_rtl_chunk(*, repo_root: Path, tb_dir: Path, chunk: ChunkSpec, chunk_dir: Path,
                   binary: Path, simulator: str, rtl_test: str, dry_run: bool) -> None:
    if simulator != "xlm":
        raise RuntimeError("launch_sim.sh currently implements direct RTL launch for --simulator xlm only")
    env = _base_env(repo_root, [], Path(sys.executable))
    xrun = _xrun_binary(repo_root)
    trace_base = chunk_dir / "trace_core"
    cov_dir = chunk_dir / "coverage"
    cmd = [
        xrun, "-64bit", "-R", "-xmlibdirpath", str(tb_dir), "-licqueue",
        "-svseed", str(chunk.seed), "-svrnc", "rand_struct", "-nokey", "-l",
        str(chunk_dir / "rtl_sim.log"), f"+UVM_TESTNAME={rtl_test}", "+UVM_VERBOSITY=UVM_LOW",
        f"+bin={binary}", f"+ibex_tracer_file_base={trace_base}",
        f"+cosim_log_file={chunk_dir / 'cosim.log'}", "-covmodeldir", str(cov_dir),
        "-covworkdir", str(chunk_dir), "-covscope", "coverage", "-covtest",
        f"{chunk.test_name}.{chunk.seed}", "-covoverwrite", "+enable_ibex_fcov=1",
        "+bsdcov_io_dump", f"+bsdcov_trace_base={chunk_dir / 'bsdcov_trace'}",
    ]
    _run(cmd, cwd=repo_root / "dv" / "uvm" / "core_ibex", env=env,
         log=chunk_dir / "launch_rtl.log", dry_run=dry_run)


def is_asm_instruction(line: str) -> bool:
    line = line.split("#", 1)[0].strip()
    if not line:
        return False
    if line.endswith(":"):
        return False
    if ":" in line:
        _, line = line.split(":", 1)
        line = line.strip()
        if not line:
            return False
    first = line.split(None, 1)[0]
    return first not in ASM_DIRECTIVES and not first.startswith(".")


def count_static_asm(test_s: Path) -> tuple[int, int]:
    total = 0
    main = 0
    in_main = False
    for line in test_s.read_text(encoding="utf-8", errors="ignore").splitlines():
        stripped = line.strip()
        if stripped.startswith("main:") or stripped == "main:":
            in_main = True
        if is_asm_instruction(line):
            total += 1
            if in_main:
                main += 1
    return total, main


def _collect_chunk_ucds(chunk_dir: Path) -> list[Path]:
    return sorted(chunk_dir.glob("coverage/**/*.ucd"))


def _run_one_chunk(repo_root: Path, python: Path, tb_dir: Path, chunk: ChunkSpec,
                   chunks_root: Path, simulator: str, rtl_test: str, isa: str,
                   mabi: str, iss: str, dry_run: bool) -> ChunkResult:
    started = time.perf_counter()
    chunk_dir = chunks_root / f"chunk_{chunk.index:04d}"
    chunk_dir.mkdir(parents=True, exist_ok=True)
    shutil.copy2(chunk.asm, chunk_dir / chunk.asm.name) if not dry_run else None
    static_total, static_main = count_static_asm(chunk.asm)
    binary = _compile_asm(repo_root=repo_root, python=python, asm=chunk.asm,
                          chunk_dir=chunk_dir, seed=chunk.seed, isa=isa, mabi=mabi,
                          iss=iss, dry_run=dry_run)
    rtl_error: Exception | None = None
    try:
        _run_rtl_chunk(repo_root=repo_root, tb_dir=tb_dir, chunk=chunk, chunk_dir=chunk_dir,
                       binary=binary, simulator=simulator, rtl_test=rtl_test, dry_run=dry_run)
    except Exception as err:
        rtl_error = err
        (chunk_dir / "error.txt").write_text(str(err) + "\n", encoding="utf-8")
    ucds = _collect_chunk_ucds(chunk_dir)
    status = "pass" if rtl_error is None and (dry_run or ucds) else "missing_coverage"
    if rtl_error is not None:
        status = "fail_with_coverage" if ucds else "fail"
    trace_candidates = sorted(chunk_dir.glob("trace_core*.log"))
    return ChunkResult(
        index=chunk.index, test_name=chunk.test_name, seed=chunk.seed, asm=str(chunk.asm),
        chunk_dir=str(chunk_dir), binary=str(binary), rtl_sim_log=str(chunk_dir / "rtl_sim.log"),
        rtl_trace=str(trace_candidates[0]) if trace_candidates else "",
        cosim_log=str(chunk_dir / "cosim.log"), coverage_ucds=[str(p) for p in ucds],
        status=status, elapsed_s=time.perf_counter() - started,
        static_instr_count=static_total, static_main_instr_count=static_main,
    )


def _empty_cov_row() -> dict[str, Any]:
    row: dict[str, Any] = {}
    for metric in METRICS:
        row[f"{metric}_pct"] = ""
        row[f"{metric}_covered"] = ""
        row[f"{metric}_total"] = ""
        row[f"{metric}_uncovered"] = ""
    return row


def parse_cov_report(path: Path, module: str = "ibex_top") -> dict[str, dict[str, Any]]:
    parsed: dict[str, dict[str, Any]] = {metric: {"pct": "", "covered": "", "total": "", "uncovered": ""} for metric in METRICS}
    for line in path.read_text(encoding="utf-8", errors="ignore").splitlines():
        if not line.startswith(module + " "):
            continue
        groups = re.findall(r"n/a|\d+(?:\.\d+)?%\s*\([^)]+\)", line)
        if len(groups) == 7:
            metric_order = ["block", "expression", "toggle", "statement", "fsm", "assertion", "covergroup"]
        elif len(groups) == 8:
            metric_order = ["block", "branch", "expression", "toggle", "statement", "fsm", "assertion", "covergroup"]
        elif len(groups) >= 9:
            metric_order = ["block", "branch", "statement", "expression", "toggle", "statement_dup", "fsm", "assertion", "covergroup"]
            groups = groups[:9]
        else:
            return parsed
        for metric, token in zip(metric_order, groups):
            if token == "n/a":
                continue
            match = COVERAGE_RE.match(token)
            if not match:
                continue
            nums = [int(x) for x in match.group("body").split("/") if x.isdigit()]
            parsed[metric]["pct"] = float(match.group("pct"))
            if len(nums) >= 2:
                parsed[metric]["covered"] = nums[0]
                parsed[metric]["total"] = nums[1]
            if len(nums) >= 3:
                parsed[metric]["uncovered"] = nums[2]
        return parsed
    return parsed


def _run_imc_report(*, repo_root: Path, run_dir: Path, prefix_idx: int,
                    ucds: list[Path], module: str, dry_run: bool) -> Path | None:
    if not ucds:
        return None
    point_dir = run_dir / "coverage" / f"prefix_{prefix_idx:04d}"
    if point_dir.exists() and not dry_run:
        shutil.rmtree(point_dir)
    merged_dir = point_dir / "merged"
    report_dir = point_dir / "report"
    runfile = point_dir / "cov_db_runfile"
    merged_dir.mkdir(parents=True, exist_ok=True)
    report_dir.mkdir(parents=True, exist_ok=True)
    run_dirs: list[Path] = []
    seen: set[Path] = set()
    for ucd in ucds:
        run_dir_ucd = ucd.parent
        if run_dir_ucd not in seen:
            seen.add(run_dir_ucd)
            run_dirs.append(run_dir_ucd)
    runfile.write_text("\n".join(str(p) for p in run_dirs) + "\n", encoding="utf-8")
    core_ibex = repo_root / "dv" / "uvm" / "core_ibex"
    xcelium_scripts = repo_root / "vendor" / "lowrisc_ip" / "dv" / "tools" / "xcelium"
    waivers = core_ibex / "waivers" / "coverage_waivers_xlm.tcl"
    env = _base_env(repo_root, [], Path(sys.executable))
    env.update({
        "cov_merge_db_dir": str(merged_dir), "cov_report_dir": str(report_dir),
        "cov_db_dirs": " ".join(str(p.parent) for p in run_dirs),
        "cov_db_runfile": str(runfile), "DUT_TOP": module,
    })
    merge_inner = ["imc", "-64bit", "-licqueue", "-exec", str(xcelium_scripts / "cov_merge.tcl"), "-logfile", str(point_dir / "merge.log")]
    report_inner = ["imc", "-64bit", "-licqueue", "-load", str(merged_dir), "-init", str(waivers), "-exec", str(xcelium_scripts / "cov_report.tcl"), "-logfile", str(point_dir / "report.log")]
    setup = _source_setup_prefix(core_ibex)
    _run_shell(setup + "script -q -e -c " + shlex.quote(shlex.join(merge_inner)) + " /dev/null", cwd=core_ibex, env=env, log=point_dir / "imc_merge.stdout.log", dry_run=dry_run)
    _run_shell(setup + "script -q -e -c " + shlex.quote(shlex.join(report_inner)) + " /dev/null", cwd=core_ibex, env=env, log=point_dir / "imc_report.stdout.log", dry_run=dry_run)
    report = report_dir / "cov_report.txt"
    return report if dry_run or report.exists() else None


def write_csv(path: Path, rows: list[dict[str, Any]], fieldnames: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as fd:
        writer = csv.DictWriter(fd, fieldnames=fieldnames, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)


def _numeric(value: Any) -> float | None:
    if value in (None, ""):
        return None
    try:
        return float(value)
    except (TypeError, ValueError):
        return None


def write_svg(path: Path, rows: list[dict[str, Any]], title: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    width, height = 1100, 680
    left, right, top, bottom = 88, 24, 36, 72
    plot_w = width - left - right
    plot_h = height - top - bottom
    xs = [_numeric(row.get("instruction_count")) for row in rows]
    xs = [x for x in xs if x is not None]
    max_x = max(xs) if xs else 1.0
    colors = {"block": "#2563eb", "branch": "#dc2626", "statement": "#16a34a", "expression": "#9333ea", "toggle": "#ea580c", "statement_dup": "#0891b2", "fsm": "#4d7c0f", "assertion": "#be123c", "covergroup": "#475569"}

    def pt(row: dict[str, Any], metric: str) -> tuple[float, float] | None:
        x_val = _numeric(row.get("instruction_count"))
        y_val = _numeric(row.get(f"{metric}_pct"))
        if x_val is None or y_val is None:
            return None
        return left + (x_val / max_x) * plot_w, top + (100.0 - y_val) / 100.0 * plot_h

    lines = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">', '<rect width="100%" height="100%" fill="white"/>', f'<line x1="{left}" y1="{top + plot_h}" x2="{left + plot_w}" y2="{top + plot_h}" stroke="#111827"/>', f'<line x1="{left}" y1="{top}" x2="{left}" y2="{top + plot_h}" stroke="#111827"/>', f'<text x="{width / 2}" y="{height - 20}" text-anchor="middle" font-family="sans-serif" font-size="18">Instruction Count</text>', f'<text x="24" y="{height / 2}" transform="rotate(-90 24 {height / 2})" text-anchor="middle" font-family="sans-serif" font-size="18">Coverage (%)</text>', f'<text x="{left}" y="24" font-family="sans-serif" font-size="20">{title}</text>']
    for idx in range(5):
        value = max_x * idx / 4
        x = left + (value / max_x) * plot_w
        lines.append(f'<line x1="{x:.1f}" y1="{top}" x2="{x:.1f}" y2="{top + plot_h + 6}" stroke="#e5e7eb"/>')
        lines.append(f'<text x="{x:.1f}" y="{top + plot_h + 24}" text-anchor="middle" font-family="sans-serif" font-size="14">{int(round(value)):,}</text>')
    for tick in range(0, 101, 20):
        y = top + (100 - tick) / 100 * plot_h
        lines.append(f'<line x1="{left - 6}" y1="{y:.1f}" x2="{left + plot_w}" y2="{y:.1f}" stroke="#e5e7eb"/>')
        lines.append(f'<text x="{left - 12}" y="{y + 5:.1f}" text-anchor="end" font-family="sans-serif" font-size="14">{tick}</text>')
    for metric in METRICS:
        pts = [(left, top + plot_h)]
        pts.extend(p for p in (pt(row, metric) for row in rows) if p is not None)
        if len(pts) <= 1:
            continue
        points = " ".join(f"{x:.1f},{y:.1f}" for x, y in pts)
        lines.append(f'<polyline fill="none" stroke="{colors[metric]}" stroke-width="2.2" points="{points}"/>')
    legend_x, legend_y = left + 18, top + 18
    for idx, metric in enumerate(METRICS):
        x = legend_x + (idx % 3) * 220
        y = legend_y + (idx // 3) * 24
        lines.append(f'<line x1="{x}" y1="{y}" x2="{x + 28}" y2="{y}" stroke="{colors[metric]}" stroke-width="3"/>')
        lines.append(f'<text x="{x + 36}" y="{y + 5}" font-family="sans-serif" font-size="14">{metric}</text>')
    lines.append("</svg>")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def _write_latest_link(sim_dir: Path, run_dir: Path) -> None:
    latest = sim_dir / "latest"
    try:
        if latest.is_symlink() or latest.exists():
            latest.unlink()
        latest.symlink_to(run_dir, target_is_directory=True)
    except OSError:
        (sim_dir / "latest.txt").write_text(str(run_dir) + "\n", encoding="utf-8")


def _io_sample_cone_name(path: Path) -> str | None:
    name = path.name
    if not (name.startswith(IO_SAMPLE_PREFIX) and name.endswith(IO_SAMPLE_SUFFIX)):
        return None
    return name[len(IO_SAMPLE_PREFIX):-len(IO_SAMPLE_SUFFIX)]


def _find_canonical_io_sample_path(bsdcov_dir: Path, cone_name: str) -> Path | None:
    cones_root = bsdcov_dir / "bsdcovproj" / "cones"
    if not cones_root.exists():
        return None
    matches = sorted(cones_root.glob(f"*/{cone_name}/{cone_name}.io_samples.csv"))
    if matches:
        return matches[0]
    matches = sorted(cones_root.rglob(f"{cone_name}.io_samples.csv"))
    return matches[0] if matches else None


def _merge_one_io_sample(cone_name: str, inputs: list[tuple[int, Path]], output: Path) -> tuple[int, list[dict[str, Any]]]:
    output.parent.mkdir(parents=True, exist_ok=True)
    header: str | None = None
    total_rows = 0
    manifest_rows: list[dict[str, Any]] = []
    with output.open("w", encoding="utf-8", newline="") as out_fd:
        for chunk_idx, src in inputs:
            rows_this_file = 0
            with src.open("r", encoding="utf-8", errors="ignore", newline="") as in_fd:
                first = in_fd.readline()
                if not first:
                    manifest_rows.append({"cone_name": cone_name, "chunk_index": chunk_idx, "rows": 0, "source": str(src), "note": "empty file"})
                    continue
                if header is None:
                    header = first
                    out_fd.write(header)
                elif first.strip() != header.strip():
                    raise RuntimeError(f"IO sample header mismatch for {cone_name}: {src}")
                for line in in_fd:
                    if not line.strip():
                        continue
                    out_fd.write(line)
                    rows_this_file += 1
            total_rows += rows_this_file
            manifest_rows.append({"cone_name": cone_name, "chunk_index": chunk_idx, "rows": rows_this_file, "source": str(src), "note": ""})
        if header is None:
            out_fd.write("\n")
    return total_rows, manifest_rows


def merge_io_samples(*, bsdcov_dir: Path, run_dir: Path, results: list[ChunkResult], update_cone_samples: bool) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    by_cone: dict[str, list[tuple[int, Path]]] = {}
    for result in sorted(results, key=lambda r: r.index):
        chunk_dir = Path(result.chunk_dir)
        for sample in sorted(chunk_dir.glob(f"{IO_SAMPLE_PREFIX}*{IO_SAMPLE_SUFFIX}")):
            cone_name = _io_sample_cone_name(sample)
            if cone_name is not None:
                by_cone.setdefault(cone_name, []).append((result.index, sample))
    merged_rows: list[dict[str, Any]] = []
    manifest_rows: list[dict[str, Any]] = []
    run_io_dir = run_dir / "io_samples"
    for cone_name, inputs in sorted(by_cone.items()):
        merged_path = run_io_dir / f"{cone_name}.io_samples.csv"
        total_rows, per_file_rows = _merge_one_io_sample(cone_name, inputs, merged_path)
        manifest_rows.extend(per_file_rows)
        canonical_path = _find_canonical_io_sample_path(bsdcov_dir, cone_name)
        canonical_updated = False
        if update_cone_samples and canonical_path is not None:
            canonical_path.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(merged_path, canonical_path)
            canonical_updated = True
        merged_rows.append({"cone_name": cone_name, "merged_io_samples": str(merged_path), "canonical_io_samples": str(canonical_path) if canonical_path else "", "canonical_updated": 1 if canonical_updated else 0, "num_source_files": len(inputs), "num_rows": total_rows})
    if merged_rows:
        write_csv(run_io_dir / "manifest.csv", merged_rows, ["cone_name", "merged_io_samples", "canonical_io_samples", "canonical_updated", "num_source_files", "num_rows"])
        write_csv(run_io_dir / "sources.csv", manifest_rows, ["cone_name", "chunk_index", "rows", "source", "note"])
    return merged_rows, manifest_rows


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Launch BSD-Cov Ibex simulations for instruction chunks.")
    parser.add_argument("--instr-seq", action="append", type=Path, required=True, help="Instruction .S file, or a .chunks.f/.f list. Can be repeated.")
    parser.add_argument("--bind-flist", action="append", type=Path, default=[], help="Optional bind filelist, e.g. bsdcovproj/sim_bind.f. Can be repeated.")
    parser.add_argument("--cov-update", type=_positive_int, required=True, help="Instruction interval represented by each chunk in cumulative coverage samples.")
    parser.add_argument("--jobs", type=_positive_int, default=1, help="Parallel RTL simulations. Default: 1")
    parser.add_argument("--run-tag", default=None, help="Run tag under dv/bsdcov/sim/runs. Default: timestamped tag.")
    parser.add_argument("--python", type=Path, default=None, help="Python executable for Ibex/riscv-dv scripts. Default: <repo>/.venv/bin/python if present.")
    parser.add_argument("--seed", type=_nonnegative_int, default=1)
    parser.add_argument("--simulator", default="xlm")
    parser.add_argument("--iss", default="spike")
    parser.add_argument("--isa", default="rv32imc")
    parser.add_argument("--mabi", default="ilp32")
    parser.add_argument("--rtl-test", default="core_ibex_base_test")
    parser.add_argument("--cov-module", default="ibex_top")
    parser.add_argument("--force-compile", action="store_true")
    parser.add_argument("--skip-cov-merge", action="store_true")
    parser.add_argument("--exclude-fail", action="store_true", help="Exclude failing chunks from cumulative coverage merge. By default, fail_with_coverage chunks are included.")
    parser.add_argument("--no-update-cone-samples", action="store_true", help="Do not overwrite bsdcovproj/cones/.../*.io_samples.csv with merged samples.")
    parser.add_argument("--dry-run", action="store_true")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = _repo_root()
    bsdcov_dir = _bsdcov_dir()
    python = _resolve_python(repo_root, args.python)
    instr_seqs = _expand_instr_seq(args.instr_seq)
    bind_flists = _resolve_bind_flists(args.bind_flist)
    run_tag = args.run_tag or f"run.{_timestamp_tag()}.n{len(instr_seqs)}.step{args.cov_update}"
    sim_dir = bsdcov_dir / "sim"
    run_dir = sim_dir / "runs" / run_tag
    run_dir.mkdir(parents=True, exist_ok=True)
    (run_dir / "logs").mkdir(parents=True, exist_ok=True)
    (run_dir / "chunks").mkdir(parents=True, exist_ok=True)
    (run_dir / "coverage").mkdir(parents=True, exist_ok=True)
    chunks = [ChunkSpec(index=idx, asm=asm, seed=args.seed + idx, sample_instruction_count=(idx + 1) * args.cov_update, test_name=f"bsdcov_chunk_{idx:04d}") for idx, asm in enumerate(instr_seqs)]
    config = {"created_at": datetime.now(timezone.utc).isoformat(), "semantics": "independent_standalone_chunks_prefix_coverage", "repo_root": str(repo_root), "python": str(python), "run_tag": run_tag, "cov_update": args.cov_update, "jobs": args.jobs, "simulator": args.simulator, "iss": args.iss, "isa": args.isa, "mabi": args.mabi, "rtl_test": args.rtl_test, "exclude_fail": args.exclude_fail, "update_cone_samples": not args.no_update_cone_samples, "instr_seq": [str(p) for p in instr_seqs], "bind_flist": [str(p) for p in bind_flists]}
    (run_dir / "config.json").write_text(json.dumps(config, indent=2) + "\n", encoding="utf-8")
    tb_dir = _compile_tb(repo_root=repo_root, run_dir=run_dir, bind_flists=bind_flists, python=python, simulator=args.simulator, iss=args.iss, seed=args.seed, force_compile=args.force_compile, dry_run=args.dry_run)
    results: list[ChunkResult] = []
    with ThreadPoolExecutor(max_workers=args.jobs) as ex:
        future_map = {ex.submit(_run_one_chunk, repo_root, python, tb_dir, chunk, run_dir / "chunks", args.simulator, args.rtl_test, args.isa, args.mabi, args.iss, args.dry_run): chunk for chunk in chunks}
        for fut in as_completed(future_map):
            chunk = future_map[fut]
            try:
                result = fut.result()
            except Exception as err:
                chunk_dir = run_dir / "chunks" / f"chunk_{chunk.index:04d}"
                chunk_dir.mkdir(parents=True, exist_ok=True)
                (chunk_dir / "error.txt").write_text(str(err) + "\n", encoding="utf-8")
                ucds = _collect_chunk_ucds(chunk_dir)
                result = ChunkResult(index=chunk.index, test_name=chunk.test_name, seed=chunk.seed, asm=str(chunk.asm), chunk_dir=str(chunk_dir), binary="", rtl_sim_log=str(chunk_dir / "rtl_sim.log"), rtl_trace="", cosim_log=str(chunk_dir / "cosim.log"), coverage_ucds=[str(p) for p in ucds], status="fail_with_coverage" if ucds else "fail", elapsed_s=0.0, static_instr_count=0, static_main_instr_count=0)
            print(f"chunk {result.index:04d}: {result.status}")
            results.append(result)
    results.sort(key=lambda r: r.index)
    write_csv(run_dir / "runs.csv", [asdict(r) for r in results], ["index", "test_name", "seed", "status", "asm", "chunk_dir", "binary", "rtl_sim_log", "rtl_trace", "cosim_log", "elapsed_s", "static_instr_count", "static_main_instr_count", "coverage_ucds"])
    io_merged_rows: list[dict[str, Any]] = []
    io_source_rows: list[dict[str, Any]] = []
    if not args.dry_run:
        io_merged_rows, io_source_rows = merge_io_samples(bsdcov_dir=bsdcov_dir, run_dir=run_dir, results=results, update_cone_samples=not args.no_update_cone_samples)
    sample_rows: list[dict[str, Any]] = []
    cumulative_ucds: list[Path] = []
    coverage_included_count = 0
    for result, chunk in zip(results, chunks):
        result_ucds = [Path(p) for p in result.coverage_ucds]
        include_for_cov = bool(result_ucds) and not (args.exclude_fail and result.status.startswith("fail"))
        if include_for_cov:
            cumulative_ucds.extend(result_ucds)
            coverage_included_count += 1
        row: dict[str, Any] = {"sample_idx": result.index + 1, "instruction_count": chunk.sample_instruction_count, "num_chunks": result.index + 1, "chunk_status": result.status, "coverage_included": 1 if include_for_cov else 0, "cov_report": ""}
        row.update(_empty_cov_row())
        if not args.skip_cov_merge and cumulative_ucds:
            try:
                report = _run_imc_report(repo_root=repo_root, run_dir=run_dir, prefix_idx=result.index + 1, ucds=cumulative_ucds, module=args.cov_module, dry_run=args.dry_run)
                if report:
                    row["cov_report"] = str(report)
                    cov = parse_cov_report(report, args.cov_module) if report.exists() else {}
                    for metric in METRICS:
                        data = cov.get(metric, {}) if cov else {}
                        row[f"{metric}_pct"] = data.get("pct", "")
                        row[f"{metric}_covered"] = data.get("covered", "")
                        row[f"{metric}_total"] = data.get("total", "")
                        row[f"{metric}_uncovered"] = data.get("uncovered", "")
            except Exception as err:
                row["chunk_status"] = f"coverage_merge_failed: {err}"
        sample_rows.append(row)
    sample_fields = ["sample_idx", "instruction_count", "num_chunks", "chunk_status", "coverage_included", "cov_report"]
    for metric in METRICS:
        sample_fields.extend([f"{metric}_pct", f"{metric}_covered", f"{metric}_total", f"{metric}_uncovered"])
    write_csv(run_dir / "coverage" / "samples.csv", sample_rows, sample_fields)
    summary = {"run_tag": run_tag, "num_chunks": len(chunks), "num_pass": sum(1 for r in results if r.status == "pass"), "num_fail": sum(1 for r in results if r.status.startswith("fail")), "num_fail_with_coverage": sum(1 for r in results if r.status == "fail_with_coverage"), "num_missing_coverage": sum(1 for r in results if r.status == "missing_coverage"), "exclude_fail": args.exclude_fail, "num_coverage_included": coverage_included_count, "num_io_sample_cones": len(io_merged_rows), "num_io_sample_source_files": len(io_source_rows), "samples_csv": str(run_dir / "coverage" / "samples.csv"), "runs_csv": str(run_dir / "runs.csv"), "io_samples_manifest": str(run_dir / "io_samples" / "manifest.csv") if io_merged_rows else ""}
    (run_dir / "coverage" / "coverage_summary.csv").write_text("metric,value\n" + "".join(f"{k},{v}\n" for k, v in summary.items()), encoding="utf-8")
    write_svg(run_dir / "coverage" / "coverage.svg", sample_rows, f"BSD-Cov cumulative coverage: {run_tag}")
    _write_latest_link(sim_dir, run_dir)
    print(f"Run directory: {run_dir}")
    print(f"Runs CSV     : {run_dir / 'runs.csv'}")
    print(f"Samples CSV  : {run_dir / 'coverage' / 'samples.csv'}")
    print(f"Coverage SVG : {run_dir / 'coverage' / 'coverage.svg'}")
    if io_merged_rows:
        print(f"IO Samples   : {run_dir / 'io_samples' / 'manifest.csv'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
