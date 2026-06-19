#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import json
import re
from pathlib import Path

IMAGE_BASE = 0x80000000
GENERATED_START = 0x80000120
COMMON_INIT_END = 0x8000011C
COMMON_INIT_LAST_WORD = 0x00000F93


def parse_hex(text: str, what: str, line_no: int) -> int:
    value = text.strip().replace("_", "")
    if value.lower().startswith("0x"):
        value = value[2:]
    if not value or not re.fullmatch(r"[0-9a-fA-F]+", value):
        raise ValueError(f"line {line_no}: invalid hexadecimal {what}: {text!r}")
    result = int(value, 16)
    if result > 0xFFFFFFFF:
        raise ValueError(f"line {line_no}: {what} exceeds 32 bits: {text!r}")
    return result


def parse_sequence(path: Path) -> list[tuple[int, int]]:
    records: list[tuple[int, int]] = []
    for line_no, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        line = raw.strip()
        if not line or line.startswith("#") or line.startswith("//"):
            continue
        parts = [part.strip() for part in line.split(",")]
        if len(parts) != 2:
            raise ValueError(f"line {line_no}: expected '<addr>, <instr>'")
        addr = parse_hex(parts[0], "address", line_no)
        instr = parse_hex(parts[1], "instruction", line_no)
        expected = GENERATED_START + len(records) * 4
        if addr != expected:
            raise ValueError(
                f"line {line_no}: expected address 0x{expected:08x}, got 0x{addr:08x}"
            )
        records.append((addr, instr))
    return records


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--base-bin", type=Path, required=True)
    parser.add_argument("--instr-seq-file", type=Path, required=True)
    parser.add_argument("--output-bin", type=Path, required=True)
    parser.add_argument("--normalized-csv", type=Path, required=True)
    parser.add_argument("--layout-json", type=Path, required=True)
    parser.add_argument("--hang-on-imem", choices=("on", "off"), required=True)
    args = parser.parse_args()

    records = parse_sequence(args.instr_seq_file)
    base = bytearray(args.base_bin.read_bytes())
    required_prefix_size = GENERATED_START - IMAGE_BASE
    if len(base) < required_prefix_size:
        raise RuntimeError(
            f"base image is only {len(base)} bytes; expected at least {required_prefix_size}"
        )
    base = base[:required_prefix_size]

    for _addr, word in records:
        base.extend(word.to_bytes(4, "little"))

    stop_pc, stop_instruction = records[-1] if records else (
        COMMON_INIT_END,
        COMMON_INIT_LAST_WORD,
    )

    args.output_bin.parent.mkdir(parents=True, exist_ok=True)
    args.output_bin.write_bytes(base)
    args.normalized_csv.parent.mkdir(parents=True, exist_ok=True)
    with args.normalized_csv.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.writer(stream)
        writer.writerow(["address", "instruction"])
        for addr, word in records:
            writer.writerow([f"0x{addr:08x}", f"0x{word:08x}"])

    layout = {
        "image_base": f"0x{IMAGE_BASE:08x}",
        "common_init_start": "0x80000080",
        "common_init_end": f"0x{COMMON_INIT_END:08x}",
        "generated_instruction_count": len(records),
        "generated_start": f"0x{records[0][0]:08x}" if records else None,
        "generated_end": f"0x{records[-1][0]:08x}" if records else None,
        "stop_pc": f"0x{stop_pc:08x}",
        "stop_instruction": f"0x{stop_instruction:08x}",
        "hang_on_imem": args.hang_on_imem,
        "imem_response_start": "0x80000080" if args.hang_on_imem == "on" else None,
        "imem_response_end": f"0x{stop_pc:08x}" if args.hang_on_imem == "on" else None,
        "image_end": f"0x{IMAGE_BASE + len(base) - 1:08x}",
        "binary_size_bytes": len(base),
    }
    args.layout_json.write_text(json.dumps(layout, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(layout, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
