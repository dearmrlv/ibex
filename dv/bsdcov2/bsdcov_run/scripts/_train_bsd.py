#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import shutil
import sys
import tempfile
from concurrent.futures import ProcessPoolExecutor, as_completed
from datetime import datetime, timezone
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[6]
sys.path.insert(0, str(REPO_ROOT))

from src.stages.cook import _read_training_samples, _train_real_bsd  # noqa: E402


def positive_int(value: str) -> int:
    parsed = int(value)
    if parsed < 1:
        raise argparse.ArgumentTypeError("must be at least 1")
    return parsed


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Train BSD models for all cones in a project")
    parser.add_argument("--proj", type=Path, required=True)
    parser.add_argument("--jobs", type=positive_int, required=True)
    parser.add_argument("--threads", type=positive_int, required=True)
    return parser.parse_args()


def sync_samples(cone: Path) -> None:
    src = cone / "io_dump" / f"{cone.name}.io_samples.csv"
    dst = cone / f"{cone.name}.io_samples.csv"
    if not src.is_file():
        raise RuntimeError(f"missing IO samples: {src}")
    with tempfile.NamedTemporaryFile("wb", dir=cone, delete=False) as fd:
        temp = Path(fd.name)
        with src.open("rb") as source:
            shutil.copyfileobj(source, fd)
    temp.replace(dst)


def update_status(cone: Path, data: dict[str, object]) -> None:
    status = cone / "status.toml"
    text = status.read_text(encoding="utf-8") if status.exists() else ""
    marker = "\n[bsd]\n"
    if marker in text:
        text = text.split(marker, 1)[0].rstrip() + "\n"
    lines = ["", "[bsd]", f'updated_at = "{datetime.now(timezone.utc).isoformat()}"',
             'status = "trained"', 'model = "thirdparty_bsd"']
    for key in ("raw_rows", "clean_rows", "dropped_x_rows", "unique_inputs", "conflicts", "threads"):
        lines.append(f"{key} = {int(data[key])}")
    lines.append(f'bsd_f = "{data["bsd_f"]}"')
    status.write_text(text.rstrip() + "\n" + "\n".join(lines) + "\n", encoding="utf-8")


def train_one(cone_text: str, bsd_root_text: str, threads: int, replay_samples: int) -> dict[str, object]:
    cone = Path(cone_text)
    try:
        sync_samples(cone)
        result = _read_training_samples(cone)
        if result.conflicts:
            raise RuntimeError(f"cannot train BSD: {result.conflicts} conflicting input rows")
        files = _train_real_bsd(cone, result, bsd_root=Path(bsd_root_text), threads=threads,
                                replay_samples=replay_samples, force=True)
        bsd_f = next((path for path in files if path.suffix == ".f"), None)
        if bsd_f is None:
            raise RuntimeError("BSD trainer did not generate a filelist")
        data: dict[str, object] = {
            "cone": cone.name, "status": "success", "raw_rows": result.raw_rows,
            "clean_rows": result.clean_rows, "dropped_x_rows": result.dropped_x_rows,
            "unique_inputs": result.unique_inputs, "conflicts": result.conflicts,
            "threads": threads, "bsd_f": str(bsd_f), "log": str(cone / "bsd" / "train.log"),
        }
        update_status(cone, data)
        return data
    except Exception as exc:
        return {"cone": cone.name, "status": "failed", "error": str(exc),
                "log": str(cone / "bsd" / "train.log")}


def main() -> int:
    args = parse_args()
    proj = args.proj.resolve()
    cones = sorted(path for path in (proj / "cones").glob("*/*") if path.is_dir())
    if not cones:
        raise SystemExit(f"ERROR: no cones found under {proj}")
    bsd_root = Path(os.environ.get("BSDCOV_BSD_ROOT", REPO_ROOT / "thirdparty/BSD")).resolve()
    if not bsd_root.is_dir():
        raise SystemExit(f"ERROR: BSD source directory not found: {bsd_root}")
    replay_samples = positive_int(os.environ.get("BSDCOV_BSD_REPLAY_SAMPLES", "16"))
    print(f"Training {len(cones)} cone(s): jobs={args.jobs}, threads/job={args.threads}, "
          f"max_threads={args.jobs * args.threads}")

    results: list[dict[str, object]] = []
    with ProcessPoolExecutor(max_workers=args.jobs) as pool:
        futures = {pool.submit(train_one, str(cone), str(bsd_root), args.threads,
                               replay_samples): cone for cone in cones}
        for future in as_completed(futures):
            result = future.result()
            results.append(result)
            if result["status"] == "success":
                print(f"[PASS] {result['cone']}: clean_rows={result['clean_rows']} "
                      f"unique_inputs={result['unique_inputs']}")
            else:
                print(f"[FAIL] {result['cone']}: {result['error']}")

    results.sort(key=lambda item: str(item["cone"]))
    log_dir = proj / "logs" / "train_bsd"
    log_dir.mkdir(parents=True, exist_ok=True)
    summary = {"project": str(proj), "bsd_root": str(bsd_root), "jobs": args.jobs,
               "threads": args.threads, "cones": results}
    summary_path = log_dir / "summary.json"
    summary_path.write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    print(f"Summary: {summary_path}")
    return 1 if any(item["status"] != "success" for item in results) else 0


if __name__ == "__main__":
    raise SystemExit(main())
