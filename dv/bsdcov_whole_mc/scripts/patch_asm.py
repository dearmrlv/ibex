#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


HEX_RE = re.compile(r"^(?:0x)?([0-9a-fA-F]{4}|[0-9a-fA-F]{8})$")


def read_words(path: Path) -> list[str]:
    words: list[str] = []
    for raw in path.read_text(encoding="utf-8", errors="ignore").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        match = HEX_RE.match(line)
        if not match:
            continue
        word = match.group(1).lower()
        words.append(word)
    return words


def find_insert_anchor(lines: list[str], src: Path) -> int:
    test_done_idx = None
    for idx, line in enumerate(lines):
        if re.match(r"^\s*test_done\s*:", line):
            test_done_idx = idx
            break
    if test_done_idx is None:
        raise RuntimeError(f"could not find test_done label in {src}")

    for idx in range(max(0, test_done_idx - 20), test_done_idx):
        stripped = lines[idx].split("#", 1)[0].strip()
        if re.search(r"\bla\s+x5,\s*test_done\b", stripped):
            return idx

    for idx in range(test_done_idx + 1, len(lines)):
        line = lines[idx]
        if re.match(r"^\S.*:\s*$", line) and not re.match(r"^\s*[0-9]+:", line):
            break
        stripped = line.split("#", 1)[0].strip()
        if re.match(r"^(?:c\.)?ecall(?:\s|$)", stripped):
            return idx
    raise RuntimeError(f"could not find final ecall in test_done block in {src}")


def patch_asm(src: Path, dst: Path, words: list[str]) -> tuple[int, int]:
    lines = src.read_text(encoding="utf-8", errors="ignore").splitlines()
    anchor = find_insert_anchor(lines, src)

    injected = [
        "                # BSD-Cov instruction sequence inserted before final ecall",
        "                .balign    4",
    ]
    for word in words:
        directive = ".2byte" if len(word) == 4 else ".word"
        injected.append(f"                {directive:<11}0x{word}")
    injected.append("                # End BSD-Cov instruction sequence")

    patched = lines[:anchor] + injected + lines[anchor:]
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text("\n".join(patched) + "\n", encoding="utf-8")
    return len(words), anchor + 1


def main() -> int:
    parser = argparse.ArgumentParser(description="Insert extracted BSD-Cov instruction words into a riscv-dv .S file.")
    parser.add_argument("--input-asm", type=Path, required=True)
    parser.add_argument("--words", type=Path, required=True)
    parser.add_argument("--output-asm", type=Path, required=True)
    parser.add_argument("--chunk-list", type=Path, required=True)
    parser.add_argument("--metadata", type=Path, required=True)
    args = parser.parse_args()

    words = read_words(args.words)
    inserted, anchor_line = patch_asm(args.input_asm, args.output_asm, words)
    args.chunk_list.parent.mkdir(parents=True, exist_ok=True)
    args.chunk_list.write_text(str(args.output_asm.resolve()) + "\n", encoding="utf-8")
    args.metadata.parent.mkdir(parents=True, exist_ok=True)
    args.metadata.write_text(
        json.dumps(
            {
                "input_asm": str(args.input_asm.resolve()),
                "words": str(args.words.resolve()),
                "output_asm": str(args.output_asm.resolve()),
                "chunk_list": str(args.chunk_list.resolve()),
                "inserted_instruction_words": inserted,
                "insert_anchor": "before_test_done_jump_or_final_ecall",
                "insert_anchor_line": anchor_line,
            },
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )
    print(f"Inserted {inserted} BSD-Cov instruction word(s): {args.output_asm}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
