#!/usr/bin/env python3
from __future__ import annotations

import argparse
import concurrent.futures
import csv
import re
import subprocess
from pathlib import Path


HEX_RE = re.compile(r"^(?:0x)?([0-9a-fA-F]{8})$")


def is_safe_rv32_word(word: str) -> bool:
    value = int(word, 16)
    if value & 0b11 != 0b11:
        return False
    opcode = value & 0x7f
    funct3 = (value >> 12) & 0x7
    funct7 = (value >> 25) & 0x7f
    if opcode in {0x17, 0x37}:  # AUIPC, LUI
        return True
    if opcode == 0x13:  # OP-IMM
        if funct3 == 0x1:
            return funct7 == 0x00
        if funct3 == 0x5:
            return funct7 in {0x00, 0x20}
        return True
    if opcode == 0x33:  # OP
        if funct3 in {0x0, 0x5}:
            return funct7 in {0x00, 0x20}
        return funct7 == 0x00
    return False


def safe_name(path: Path) -> str:
    return re.sub(r"[^A-Za-z0-9_.-]+", "_", str(path))


def extract_one(script: Path, fsdb: Path, out_dir: Path, mode: str) -> dict[str, str | int]:
    out = out_dir / (safe_name(fsdb.with_suffix("").name) + ".instr.txt")
    log = out.with_suffix(".log")
    cmd = [str(script), "--fsdb", str(fsdb), "--out", str(out), "--mode", mode]
    with log.open("w", encoding="utf-8") as fd:
        proc = subprocess.run(cmd, text=True, stdout=fd, stderr=subprocess.STDOUT, check=False)
    count = 0
    if out.exists():
        count = sum(1 for line in out.read_text(encoding="utf-8", errors="ignore").splitlines() if HEX_RE.match(line.strip()))
    return {
        "fsdb": str(fsdb),
        "out": str(out),
        "log": str(log),
        "status": "pass" if proc.returncode == 0 else "fail",
        "returncode": proc.returncode,
        "instructions": count,
    }


def merge_words(files: list[Path], out: Path, *, safe_rv32_control_free: bool) -> int:
    seen: set[str] = set()
    words: list[str] = []
    for path in files:
        if not path.exists():
            continue
        for raw in path.read_text(encoding="utf-8", errors="ignore").splitlines():
            match = HEX_RE.match(raw.strip())
            if not match:
                continue
            word = match.group(1).lower()
            if safe_rv32_control_free and not is_safe_rv32_word(word):
                continue
            if word not in seen:
                seen.add(word)
                words.append(word)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text("".join(f"{word}\n" for word in words), encoding="utf-8")
    return len(words)


def main() -> int:
    parser = argparse.ArgumentParser(description="Extract and merge instruction words from JasperGold FSDB traces.")
    parser.add_argument("--fsdb-root", type=Path, required=True)
    parser.add_argument("--out-dir", type=Path, required=True)
    parser.add_argument("--fsdb-to-instr", type=Path, required=True)
    parser.add_argument("--mode", choices=("core-imem-input", "imem-input", "id-stage"), default="core-imem-input")
    parser.add_argument(
        "--safe-rv32-control-free",
        action="store_true",
        help="Merge only conservative RV32 non-control-flow, non-memory, non-system words.",
    )
    parser.add_argument("--jobs", type=int, default=4)
    args = parser.parse_args()

    fsdbs = sorted(args.fsdb_root.rglob("*.fsdb"))
    args.out_dir.mkdir(parents=True, exist_ok=True)
    rows: list[dict[str, str | int]] = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=max(1, args.jobs)) as pool:
        futures = [pool.submit(extract_one, args.fsdb_to_instr.resolve(), fsdb.resolve(), args.out_dir, args.mode) for fsdb in fsdbs]
        for future in concurrent.futures.as_completed(futures):
            rows.append(future.result())
    rows.sort(key=lambda row: str(row["fsdb"]))

    manifest = args.out_dir / "manifest.csv"
    with manifest.open("w", encoding="utf-8", newline="") as fd:
        writer = csv.DictWriter(fd, fieldnames=["fsdb", "out", "log", "status", "returncode", "instructions"])
        writer.writeheader()
        writer.writerows(rows)

    merged_count = merge_words(
        [Path(str(row["out"])) for row in rows if row["status"] == "pass"],
        args.out_dir / "bsd_cov_words.txt",
        safe_rv32_control_free=args.safe_rv32_control_free,
    )
    print(f"FSDB traces: {len(fsdbs)}")
    print(f"Successful extractions: {sum(1 for row in rows if row['status'] == 'pass')}")
    print(f"Unique instruction words: {merged_count}")
    print(f"Merged words: {args.out_dir / 'bsd_cov_words.txt'}")
    return 0 if fsdbs else 1


if __name__ == "__main__":
    raise SystemExit(main())
