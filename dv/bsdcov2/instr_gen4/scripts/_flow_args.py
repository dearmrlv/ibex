#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import tempfile
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Sequence


SCRIPT_DIR = Path(__file__).resolve().parent


def atomic_json(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=path.parent,
                                     delete=False) as stream:
        json.dump(value, stream, indent=2, sort_keys=True)
        stream.write("\n")
        temporary = Path(stream.name)
    temporary.replace(path)


def load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def resolve_existing(path: Path, description: str) -> Path:
    result = path.expanduser().resolve()
    if not result.is_file():
        raise FileNotFoundError(f"{description} does not exist: {result}")
    return result


@dataclass(frozen=True)
class FlowConfig:
    init_bin: str
    seed: int
    target_sample_num: int
    retry_limit: int
    prove_timeout: int
    max_epochs: int
    max_generated_words: int
    jg: str
    created_at: str

    @classmethod
    def from_args(cls, args: argparse.Namespace) -> "FlowConfig":
        init_bin = resolve_existing(args.init_bin, "initial binary")
        return cls(
            init_bin=str(init_bin),
            seed=args.seed,
            target_sample_num=args.target_sample_num,
            retry_limit=args.retry_limit,
            prove_timeout=args.prove_timeout,
            max_epochs=args.max_epochs,
            max_generated_words=args.max_generated_words,
            jg=str(args.jg.expanduser().resolve()),
            created_at=datetime.now(timezone.utc).isoformat(),
        )

    @classmethod
    def from_state(cls, state: dict[str, Any]) -> "FlowConfig":
        config = dict(state["config"])
        config.pop("proj", None)
        config.pop("assertion_filelists", None)
        config.setdefault("target_sample_num", -1)
        if config["target_sample_num"] == 0:
            config["target_sample_num"] = -1
        return cls(**config)

    def to_json(self) -> dict[str, Any]:
        return asdict(self)


@dataclass(frozen=True)
class FlowPaths:
    root: Path
    bsdcov2: Path
    run_dir: Path
    fml: Path
    eval: Path
    ibex: Path
    images: Path
    baseline: Path
    iterations: Path
    coverage: Path
    assert_dir: Path
    formal: Path
    final: Path
    logs: Path

    @classmethod
    def from_run_dir(cls, run_dir: Path) -> "FlowPaths":
        root = SCRIPT_DIR.parent
        bsdcov2 = root.parent
        return cls(
            root=root,
            bsdcov2=bsdcov2,
            run_dir=run_dir,
            fml=bsdcov2 / "bsdcov_run/fml",
            eval=bsdcov2 / "eval",
            ibex=bsdcov2.parent.parent,
            images=run_dir / "images",
            baseline=run_dir / "baseline",
            iterations=run_dir / "iterations",
            coverage=run_dir / "coverage",
            assert_dir=run_dir / "assertions",
            formal=run_dir / "formal",
            final=run_dir / "final",
            logs=run_dir / "logs",
        )

    def make_run_dirs(self) -> None:
        for path in (self.images, self.baseline, self.iterations, self.coverage,
                     self.assert_dir, self.formal, self.final, self.logs):
            path.mkdir(parents=True, exist_ok=True)


@dataclass
class FlowRuntime:
    args: argparse.Namespace
    config: FlowConfig
    paths: FlowPaths
    state: dict[str, Any]
    dry_run: bool = False
    resume: bool = False


def initial_state(config: FlowConfig) -> dict[str, Any]:
    return {
        "version": 1,
        "status": "running",
        "accepted": 0,
        "iteration": 0,
        "epoch": 0,
        "current_image": "images/initial.bin",
        "sim_checkpoint": None,
        "accepted_runs": [],
        "seen_candidates": [],
        "properties": {},
        "coverage": {},
        "coverage_rows": [],
        "config": config.to_json(),
    }


class FlowArgs:
    def __init__(self, script_dir: Path = SCRIPT_DIR):
        self.script_dir = script_dir

    def arguments(self, argv: Sequence[str] | None = None) -> argparse.Namespace:
        parser = argparse.ArgumentParser(description="Iterative BSD-Cov instruction generator")
        parser.add_argument("--init-bin", type=Path)
        parser.add_argument("--seed", type=int, default=1)
        parser.add_argument("--target-sample-num", type=int, default=-1,
                            help="disappeared values per SigSet merged epoch target; -1 means all")
        parser.add_argument("--retry-limit", type=int, default=5)
        parser.add_argument("--prove-timeout", type=int, default=300)
        parser.add_argument("--max-epochs", type=int, default=100)
        parser.add_argument("--max-generated-words", type=int, default=4096)
        parser.add_argument("--run-tag")
        parser.add_argument("--resume", action="store_true")
        parser.add_argument("--dry-run", action="store_true")
        parser.add_argument("--jg", type=Path,
                            default=Path(os.environ.get("JG", "/home/lvzhengyang/workspace/cadence/jg")))
        return parser.parse_args(argv)

    def validate(self, args: argparse.Namespace) -> None:
        positive = {
            "retry-limit": args.retry_limit,
            "prove-timeout": args.prove_timeout,
            "max-generated-words": args.max_generated_words,
        }
        invalid = [name for name, value in positive.items() if value <= 0]
        if invalid or args.max_epochs < 0 or args.target_sample_num == 0 or args.target_sample_num < -1:
            raise ValueError("numeric limits must be positive (max-epochs may be zero): " +
                             ", ".join(invalid or ["max-epochs/target-sample-num"]))
        if args.resume:
            if not args.run_tag:
                raise ValueError("--resume requires --run-tag")
            return
        if args.init_bin is None:
            raise ValueError("new runs require --init-bin")

    def prepare(self, args: argparse.Namespace) -> FlowRuntime:
        self.validate(args)
        tag = args.run_tag or datetime.now(timezone.utc).strftime("run.%Y%m%dT%H%M%SZ.seed") + str(args.seed)
        run_dir = self.script_dir.parent / "runs" / tag
        paths = FlowPaths.from_run_dir(run_dir)

        if args.resume:
            if not run_dir.is_dir():
                raise FileNotFoundError(f"resume run does not exist: {run_dir}")
            state = load_json(run_dir / "state.json")
            config = FlowConfig.from_state(state)
            return FlowRuntime(args=args, config=config, paths=paths, state=state,
                               dry_run=args.dry_run, resume=True)

        if run_dir.exists():
            raise FileExistsError(f"run already exists: {run_dir}")
        config = FlowConfig.from_args(args)
        paths.make_run_dirs()
        state = initial_state(config)
        atomic_json(run_dir / "config.json", config.to_json())
        atomic_json(run_dir / "state.json", state)
        return FlowRuntime(args=args, config=config, paths=paths, state=state,
                           dry_run=args.dry_run, resume=False)
