#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
import subprocess
from pathlib import Path


LABEL_RE = re.compile(r"^\s*[0-9a-fA-F]+\s+<([^>]+)>:")
INSN_RE = re.compile(r"^\s*[0-9a-fA-F]+:\s+([0-9a-fA-F]{4}|[0-9a-fA-F]{8})\s")


def main() -> int:
    parser = argparse.ArgumentParser(description="Extract main-section instruction encodings from a RISC-V object.")
    parser.add_argument("--objdump", type=Path, required=True)
    parser.add_argument("--object", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()

    result = subprocess.run(
        [str(args.objdump), "-d", str(args.object)],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(f"objdump failed with exit code {result.returncode}: {result.stderr.strip()}")

    in_main = False
    words: list[str] = []
    for line in result.stdout.splitlines():
        label = LABEL_RE.match(line)
        if label:
            name = label.group(1)
            if name == "main":
                in_main = True
                continue
            if name == "test_done" and in_main:
                break
            continue
        if not in_main:
            continue
        match = INSN_RE.match(line)
        if match:
            words.append(match.group(1).lower())

    if not words:
        raise RuntimeError(f"no instruction encodings found between main and test_done in {args.object}")

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text("".join(f"{word}\n" for word in words), encoding="utf-8")
    print(f"Extracted {len(words)} instruction encoding(s): {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
