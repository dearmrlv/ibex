#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import json
import os
import shutil
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

from _candidate import extract_candidate
from _common import atomic_json, load_json, resolve_existing
from _coverage import (METRICS, find_ucds, improves, merged_report, parse_report,
                       write_curve_csv, write_curve_svg)
from _formal import discover_properties, emit_env_filelist, emit_formal_imem, prove_property
from _image import (append_candidate, candidate_signature, disassemble,
                    generated_words, write_image, write_sequence_csv)
from _simulate import mark_rejected, simulate


@dataclass
class FlowContext:
    args: argparse.Namespace
    run_dir: Path
    state: dict[str, Any]
    paths: dict[str, Path]
    config: dict[str, Any]
    assertion_fs: list[Path]


def arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Iterative BSD-Cov instruction generator")
    parser.add_argument("--proj", type=Path)
    parser.add_argument("--init-bin", type=Path)
    parser.add_argument("-f", dest="assertion_fs", action="append", type=Path,
                        help="assertion filelist; may be specified multiple times")
    parser.add_argument("--seed", type=int, default=1)
    parser.add_argument("--retry-limit", type=int, default=5)
    parser.add_argument("--prove-timeout", type=int, default=300)
    parser.add_argument("--timeout-strikes", type=int, default=3)
    parser.add_argument("--candidate-window", type=int, default=32)
    parser.add_argument("--max-accepted", type=int, default=100)
    parser.add_argument("--max-generated-words", type=int, default=4096)
    parser.add_argument("--run-tag")
    parser.add_argument("--resume", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--jg", type=Path,
                        default=Path(os.environ.get("JG", "/home/lvzhengyang/workspace/cadence/jg")))
    return parser.parse_args()


def initial_state(config: dict[str, Any]) -> dict[str, Any]:
    return {"version": 1, "status": "running", "accepted": 0, "iteration": 0,
            "epoch": 0, "current_image": "images/initial.bin", "accepted_runs": [],
            "seen_candidates": [], "properties": {}, "coverage": {},
            "coverage_rows": [],
            "config": config}


def property_rows(state: dict[str, Any]) -> list[dict[str, Any]]:
    return [{"property": name, **value}
            for name, value in sorted(state["properties"].items())]


def write_reports(run_dir: Path, state: dict[str, Any]) -> None:
    rows = property_rows(state)
    path = run_dir / "assertions/status.csv"
    path.parent.mkdir(parents=True, exist_ok=True)
    fields = ["property", "status", "retries", "timeouts", "last_reason"]
    with path.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=fields, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)


def coverage_row(iteration: int, image: Path, retired: int,
                 coverage: dict[str, Any], prop: str) -> dict[str, Any]:
    row: dict[str, Any] = {"accepted_iteration": iteration,
                           "bin_instruction_count": 40 + len(generated_words(image)),
                           "image_word_count": image.stat().st_size // 4,
                           "generated_word_count": len(generated_words(image)),
                           "retired_instruction_count": retired, "property": prop}
    for metric in METRICS:
        row[f"{metric}_covered"] = coverage[metric]["covered"]
        row[f"{metric}_total"] = coverage[metric]["total"]
        row[f"{metric}_percent"] = coverage[metric]["percent"]
    return row


def update_coverage_curve(run_dir: Path, state: dict[str, Any], row: dict[str, Any] | None = None) -> None:
    if row is not None:
        state.setdefault("coverage_rows", []).append(row)
    rows = state.get("coverage_rows", [])
    if not rows:
        return
    write_curve_csv(run_dir / "coverage/coverage_curve.csv", rows)
    write_curve_svg(run_dir / "coverage/coverage_curve.svg", rows, run_dir.name)


def prepare(args: argparse.Namespace) -> tuple[Path, dict[str, Any], dict[str, Path]]:
    root = SCRIPT_DIR.parent
    bsdcov2 = root.parent
    if args.resume and not args.run_tag:
        raise ValueError("--resume requires --run-tag")
    tag = args.run_tag or datetime.now(timezone.utc).strftime("run.%Y%m%dT%H%M%SZ.seed") + str(args.seed)
    run_dir = root / "runs" / tag
    if args.resume:
        if not run_dir.is_dir():
            raise FileNotFoundError(f"resume run does not exist: {run_dir}")
        state = load_json(run_dir / "state.json")
        saved = state["config"]
        proj = Path(saved["proj"])
        init_bin = Path(saved["init_bin"])
        return run_dir, state, {
            "root": root, "bsdcov2": bsdcov2, "proj": proj,
            "init": init_bin, "fml": bsdcov2 / "bsdcov_run/fml",
            "eval": bsdcov2 / "eval", "ibex": bsdcov2.parent.parent,
        }
    if args.proj is None or args.init_bin is None or not args.assertion_fs:
        raise ValueError("new runs require --proj, --init-bin, and at least one -f")
    proj = args.proj.resolve()
    if not (proj / "config.toml").is_file():
        raise FileNotFoundError(f"not a BSD-Cov project: {proj}")
    init_bin = resolve_existing(args.init_bin, "initial binary")
    assertion_fs = [resolve_existing(path, "assertion filelist") for path in args.assertion_fs]
    if run_dir.exists():
        raise FileExistsError(f"run already exists: {run_dir}")
    for child in ("images", "baseline", "iterations", "coverage", "assertions", "formal", "final", "logs"):
        (run_dir / child).mkdir(parents=True, exist_ok=True)
    config = {"proj": str(proj), "init_bin": str(init_bin),
              "assertion_filelists": [str(path) for path in assertion_fs],
              "seed": args.seed, "retry_limit": args.retry_limit,
              "prove_timeout": args.prove_timeout, "timeout_strikes": args.timeout_strikes,
              "candidate_window": args.candidate_window,
              "max_accepted": args.max_accepted,
              "max_generated_words": args.max_generated_words,
              "created_at": datetime.now(timezone.utc).isoformat()}
    write_image(init_bin, [], run_dir / "images/initial.bin")
    state = initial_state(config)
    atomic_json(run_dir / "config.json", config)
    atomic_json(run_dir / "state.json", state)
    return run_dir, state, {"root": root, "bsdcov2": bsdcov2, "proj": proj,
                            "init": init_bin, "fml": bsdcov2 / "bsdcov_run/fml",
                            "eval": bsdcov2 / "eval", "ibex": bsdcov2.parent.parent}


def finalize(run_dir: Path, state: dict[str, Any]) -> None:
    current = run_dir / state["current_image"]
    final_bin = run_dir / "images/final.bin"
    shutil.copy2(current, final_bin)
    write_sequence_csv(final_bin, run_dir / "images/final.instructions.csv")
    tool = disassemble(final_bin, run_dir / "images/final.disasm")
    state["status"] = "complete"
    state["disassembler"] = tool
    atomic_json(run_dir / "state.json", state)
    update_coverage_curve(run_dir, state)
    if not (run_dir / "coverage/coverage_curve.csv").is_file():
        raise RuntimeError("missing coverage_curve.csv")
    if not (run_dir / "coverage/coverage_curve.svg").is_file():
        raise RuntimeError("missing coverage_curve.svg")
    atomic_json(run_dir / "final/run_summary.json", {
        "status": "complete", "accepted": state["accepted"],
        "iterations": state["iteration"],
        "generated_words": len(generated_words(final_bin)),
        "properties": state["properties"], "coverage": state["coverage"],
        "final_bin": str(final_bin),
        "coverage_curve_csv": str(run_dir / "coverage/coverage_curve.csv"),
        "coverage_curve_svg": str(run_dir / "coverage/coverage_curve.svg"),
    })
    write_reports(run_dir, state)
    latest = run_dir.parent / "latest"
    latest.unlink(missing_ok=True)
    latest.symlink_to(run_dir.name)


def validate_args(args: argparse.Namespace) -> None:
    positive = {
        "retry-limit": args.retry_limit,
        "prove-timeout": args.prove_timeout,
        "timeout-strikes": args.timeout_strikes,
        "candidate-window": args.candidate_window,
        "max-generated-words": args.max_generated_words,
    }
    invalid = [name for name, value in positive.items() if value <= 0]
    if invalid or args.max_accepted < 0:
        raise ValueError("numeric limits must be positive (max-accepted may be zero): " +
                         ", ".join(invalid or ["max-accepted"]))


def make_context(args: argparse.Namespace) -> FlowContext:
    validate_args(args)
    run_dir, state, paths = prepare(args)
    config = state["config"]
    assertion_fs = [Path(path) for path in config["assertion_filelists"]]
    return FlowContext(args=args, run_dir=run_dir, state=state, paths=paths,
                       config=config, assertion_fs=assertion_fs)


def current_instr_bin(ctx: FlowContext) -> Path:
    return ctx.run_dir / ctx.state["current_image"]


def get_instr_num(instr_bin: Path) -> int:
    return 40 + len(generated_words(instr_bin))


def record_state(ctx: FlowContext) -> None:
    atomic_json(ctx.run_dir / "state.json", ctx.state)


def sim(ctx: FlowContext, instr_bin: Path, run_dir: Path) -> tuple[Path, dict[str, Any], dict[str, Any]]:
    result = simulate(image=instr_bin, run_dir=run_dir, seed=ctx.config["seed"],
                      eval_dir=ctx.paths["eval"], shared_dir=ctx.run_dir / "sim_shared")
    report = run_dir / "coverage/cov_report.txt"
    coverage = parse_report(report)
    sim_fsdb = run_dir / "fsdb/eval.fsdb"
    return sim_fsdb, coverage, result


def ensure_initial_sim(ctx: FlowContext, instr_bin: Path) -> tuple[Path, dict[str, Any]]:
    if ctx.state["accepted_runs"]:
        accepted_run = ctx.run_dir / ctx.state["accepted_runs"][-1]
        return accepted_run / "fsdb/eval.fsdb", ctx.state["coverage"]

    sim_fsdb, coverage, result = sim(ctx, instr_bin, ctx.run_dir / "baseline/sim")
    ctx.state["coverage"] = coverage
    ctx.state["accepted_runs"] = [str((ctx.run_dir / "baseline/sim").relative_to(ctx.run_dir))]
    update_coverage_curve(ctx.run_dir, ctx.state,
                          coverage_row(0, instr_bin, result["retired_instruction_count"],
                                       coverage, "baseline"))
    record_state(ctx)
    return sim_fsdb, coverage


def jgenv_imem_update(ctx: FlowContext, instr_bin: Path, formal_dir: Path) -> Path:
    formal_dir.mkdir(parents=True, exist_ok=True)
    imem = formal_dir / "imem.sv"
    emit_formal_imem(instr_bin, imem, ctx.config["candidate_window"])
    emit_env_filelist(formal_dir / "env.f", ctx.paths["fml"], imem)
    return formal_dir / "env.f"


def jgenv_reset_update(_ctx: FlowContext, sim_fsdb: Path) -> Path:
    return sim_fsdb


def get_asserts(ctx: FlowContext, instr_bin: Path, sim_fsdb: Path) -> dict[str, dict[str, Any]]:
    if not ctx.state["properties"]:
        formal_root = ctx.run_dir / "formal/epoch_0000"
        env_f = jgenv_imem_update(ctx, instr_bin, formal_root)
        properties = discover_properties(
            jg=ctx.args.jg.resolve(), dut_f=ctx.paths["fml"] / "dut.f",
            env_f=env_f, assertion_fs=ctx.assertion_fs, fsdb=sim_fsdb,
            sim_hier="core_ibex_tb_top.dut.u_ibex_top",
            work_dir=formal_root / "discover", timeout=ctx.config["prove_timeout"],
            seed=ctx.config["seed"])
        ctx.state["properties"] = {name: {"status": "pending", "retries": 0,
                                          "timeouts": 0, "last_reason": ""}
                                   for name in properties}
        record_state(ctx)
    return ctx.state["properties"]


def select_one(asserts: dict[str, dict[str, Any]]) -> tuple[str, dict[str, Any]] | None:
    terminal = {"proven", "achieved", "retry_exhausted", "timeout_exhausted", "error"}
    for name, prop_state in sorted(asserts.items()):
        if prop_state["status"] not in terminal:
            return name, prop_state
    return None


def is_deprecated(prop_state: dict[str, Any]) -> bool:
    return prop_state["status"] in {"proven", "achieved", "retry_exhausted",
                                    "timeout_exhausted", "error"}


def find_cex(ctx: FlowContext, a: str, retry: int, iteration_dir: Path,
             sim_fsdb: Path) -> dict[str, Any]:
    formal_dir = iteration_dir / "formal"
    env_f = jgenv_imem_update(ctx, current_instr_bin(ctx), formal_dir)
    result = prove_property(
        jg=ctx.args.jg.resolve(), dut_f=ctx.paths["fml"] / "dut.f",
        env_f=env_f, assertion_fs=ctx.assertion_fs, fsdb=sim_fsdb,
        sim_hier="core_ibex_tb_top.dut.u_ibex_top", work_dir=formal_dir,
        timeout=ctx.config["prove_timeout"],
        seed=ctx.config["seed"] + ctx.state["iteration"],
        property_name=a, retry_index=retry)
    atomic_json(iteration_dir / "formal/result.json", result)
    return result


def fsdb2instrs(ctx: FlowContext, cex_fsdb: Path, instr_bin: Path,
                iteration_dir: Path) -> list[dict[str, Any]]:
    instrs = extract_candidate(cex_fsdb, instr_bin,
                               iteration_dir / "candidate/words.csv",
                               ctx.config["candidate_window"])
    signature = candidate_signature(instrs)
    if signature in ctx.state["seen_candidates"]:
        raise RuntimeError("duplicate candidate")
    ctx.state["seen_candidates"].append(signature)
    return instrs


def eval_candidate(ctx: FlowContext, instr_bin: Path, instrs: list[dict[str, Any]],
                   a: str, iteration_dir: Path) -> tuple[bool, Path, Path, dict[str, Any], dict[str, Any]]:
    candidate_image = iteration_dir / "candidate/candidate.bin"
    append_candidate(instr_bin, instrs, candidate_image)
    if len(generated_words(candidate_image)) > ctx.config["max_generated_words"]:
        raise RuntimeError("generated-word limit would be exceeded")

    sim_dir = iteration_dir / "simulation"
    sim_fsdb, _candidate_coverage, sim_result = sim(ctx, candidate_image, sim_dir)
    accepted_ucds = [ucd for relative in ctx.state["accepted_runs"]
                     for ucd in find_ucds(ctx.run_dir / relative)]
    candidate_ucds = accepted_ucds + find_ucds(sim_dir)
    report = merged_report(ctx.paths["ibex"], iteration_dir, candidate_ucds,
                           ctx.state["iteration"])
    new_coverage = parse_report(report)
    gain, delta = improves(ctx.state["coverage"], new_coverage)
    atomic_json(iteration_dir / "coverage_delta.json",
                {"improves": gain, "delta": delta, "coverage": new_coverage})
    if not gain:
        raise RuntimeError("no cumulative coverage-bin increase")

    accepted_image = ctx.run_dir / f"images/accepted_{ctx.state['accepted'] + 1:04d}.bin"
    shutil.copy2(candidate_image, accepted_image)
    ctx.state["accepted"] += 1
    ctx.state["current_image"] = str(accepted_image.relative_to(ctx.run_dir))
    ctx.state["accepted_runs"].append(str(sim_dir.relative_to(ctx.run_dir)))
    ctx.state["coverage"] = new_coverage
    update_coverage_curve(ctx.run_dir, ctx.state,
                          coverage_row(ctx.state["accepted"], accepted_image,
                                       sim_result["retired_instruction_count"],
                                       new_coverage, a))
    return True, accepted_image, sim_fsdb, new_coverage, sim_result


def retire_assert(asserts: dict[str, dict[str, Any]], deprecated_asserts: list[str],
                  a: str, reason: str) -> None:
    asserts[a]["last_reason"] = reason
    if a not in deprecated_asserts:
        deprecated_asserts.append(a)


def run_instruction_generation_flow(ctx: FlowContext) -> None:
    instr_bin = current_instr_bin(ctx)
    sim_fsdb, coverage = ensure_initial_sim(ctx, instr_bin)
    coverage_collection = ctx.state.setdefault("coverage_rows", [])
    num_bin_instr = get_instr_num(instr_bin)
    del coverage_collection, num_bin_instr

    jgenv_imem_update(ctx, instr_bin, ctx.run_dir / "formal/epoch_0000")
    sim_fsdb = jgenv_reset_update(ctx, sim_fsdb)
    asserts = get_asserts(ctx, instr_bin, sim_fsdb)
    deprecated_asserts: list[str] = []

    if not asserts:
        return

    while asserts and ctx.state["accepted"] < ctx.config["max_accepted"]:
        ctx.state["epoch"] += 1
        selected = select_one(asserts)
        if selected is None:
            break

        a, prop_state = selected
        if is_deprecated(prop_state):
            retire_assert(asserts, deprecated_asserts, a, prop_state["status"])
            continue

        retry = 0
        accepted_for_property = False
        while retry < ctx.config["retry_limit"]:
            ctx.state["iteration"] += 1
            iteration_dir = ctx.run_dir / f"iterations/{ctx.state['iteration']:04d}"
            iteration_dir.mkdir(parents=True, exist_ok=True)
            instr_bin = current_instr_bin(ctx)
            sim_fsdb = jgenv_reset_update(ctx, ctx.run_dir / ctx.state["accepted_runs"][-1] /
                                          "fsdb/eval.fsdb")
            result = find_cex(ctx, a, retry, iteration_dir, sim_fsdb)
            status = result["status"]

            if status in {"proven", "pass"}:
                prop_state.update(status="proven", last_reason=status)
                retire_assert(asserts, deprecated_asserts, a, status)
                break

            if status in {"timeout", "inconclusive", "undetermined"}:
                prop_state["timeouts"] += 1
                prop_state["last_reason"] = status
                prop_state["status"] = ("timeout_exhausted" if prop_state["timeouts"] >=
                                        ctx.config["timeout_strikes"] else "timeout_deferred")
                if prop_state["status"] == "timeout_exhausted":
                    retire_assert(asserts, deprecated_asserts, a, status)
                break

            cex_fsdb = result.get("cex_fsdb")
            if status not in {"cex", "ar_cex"} or not cex_fsdb:
                prop_state.update(status="error", last_reason=f"unexpected Jasper status {status}")
                retire_assert(asserts, deprecated_asserts, a, prop_state["last_reason"])
                break

            try:
                instrs = fsdb2instrs(ctx, Path(cex_fsdb), instr_bin, iteration_dir)
                if not instrs:
                    retry += 1
                    prop_state["retries"] += 1
                    prop_state["last_reason"] = "empty candidate"
                    continue

                _accepted, instr_bin, sim_fsdb, new_coverage, _sim_result = eval_candidate(
                    ctx, instr_bin, instrs, a, iteration_dir)
                coverage = new_coverage
                jgenv_imem_update(ctx, instr_bin, iteration_dir / "formal/accepted")
                sim_fsdb = jgenv_reset_update(ctx, sim_fsdb)
                prop_state.update(status="achieved", last_reason="coverage increased")
                accepted_for_property = True
                del coverage
                break
            except Exception as exc:
                retry += 1
                prop_state["retries"] += 1
                prop_state["last_reason"] = str(exc)
                atomic_json(iteration_dir / "rejection.json", {"reason": str(exc)})
                mark_rejected(iteration_dir / "simulation")

        if retry == ctx.config["retry_limit"] and not accepted_for_property:
            prop_state["status"] = "retry_exhausted"
            retire_assert(asserts, deprecated_asserts, a, "retry_exhausted")

        record_state(ctx)
        write_reports(ctx.run_dir, ctx.state)


def main() -> int:
    args = arguments()
    ctx = make_context(args)
    if args.dry_run:
        print(f"Validated instruction-generation run: {ctx.run_dir}")
        return 0

    run_instruction_generation_flow(ctx)
    if not ctx.state["properties"]:
        finalize(ctx.run_dir, ctx.state)
        print(f"No AST_BSDCOV properties found; final image: {ctx.run_dir / 'images/final.bin'}")
        return 0

    finalize(ctx.run_dir, ctx.state)
    summary = load_json(ctx.run_dir / "final/run_summary.json")
    print(f"Instruction generation complete: {summary['final_bin']}")
    print(f"accepted={summary['accepted']} generated_words={summary['generated_words']} "
          f"iterations={summary['iterations']} properties={len(summary['properties'])}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except KeyboardInterrupt:
        print("Interrupted; rerun with --resume --run-tag <tag>", file=sys.stderr)
        raise SystemExit(130)
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
