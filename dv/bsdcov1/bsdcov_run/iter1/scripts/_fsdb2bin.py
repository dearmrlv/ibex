#!/usr/bin/env python3
"""Build a flat Ibex instruction-memory image from a JasperGold FSDB."""

from __future__ import annotations

import argparse
import csv
import json
import os
import re
import shutil
import subprocess
import sys
from bisect import bisect_right
from dataclasses import dataclass
from pathlib import Path

DEFAULT_VERDI_HOME = Path("/home/lvzhengyang/workspace/synopsys/verdi/T-2022.06")
SIGNAL_SUFFIXES = {
    "clk": "imem_if_inst.u_fml_imem.clk_i",
    "rvalid": "imem_if_inst.u_fml_imem.rvalid_o",
    "addr": "imem_if_inst.u_fml_imem.addr_in_proc",
    "err": "imem_if_inst.u_fml_imem.err_o",
    "data": "imem_if_inst.u_fml_imem.data_o",
}
VC_RE = re.compile(r"xtag:\s*\((\d+)\s+(\d+)\)\s+val:\s+([^\s]+)")


@dataclass(frozen=True, order=True)
class Xtag:
    major: int
    minor: int


@dataclass(frozen=True)
class Record:
    time: Xtag
    address: int
    instruction: int


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--fsdb", type=Path, required=True)
    parser.add_argument("--out-bin", type=Path, required=True)
    parser.add_argument("--base-addr", type=lambda value: int(value, 0), default=0x80000000)
    parser.add_argument("--verdi-home", type=Path,
                        default=Path(os.environ.get("VERDI_HOME", DEFAULT_VERDI_HOME)))
    return parser.parse_args()


def fsdb_env(verdi_home: Path) -> dict[str, str]:
    env = os.environ.copy()
    env["VERDI_HOME"] = str(verdi_home)
    ugo = verdi_home / "share/ugo/linux64/bin/ugo_dist/ugo"
    old = env.get("LD_LIBRARY_PATH")
    env["LD_LIBRARY_PATH"] = f"{ugo}:{old}" if old else str(ugo)
    return env


def run_debug(tool: Path, env: dict[str, str], args: list[str]) -> str:
    proc = subprocess.run([str(tool), *args], env=env, stdout=subprocess.PIPE,
                          stderr=subprocess.STDOUT, text=True, check=False)
    if proc.returncode:
        raise RuntimeError(f"fsdbdebug failed ({proc.returncode}):\n{proc.stdout[-4000:]}")
    return proc.stdout


def discover_signals(tool: Path, env: dict[str, str], fsdb: Path) -> dict[str, str]:
    hierarchy = run_debug(tool, env, ["-hier_tree", str(fsdb)])
    tokens = set(re.findall(r"[A-Za-z_$][A-Za-z0-9_$.\\\[\]:/]*", hierarchy))
    resolved = {}
    for key, suffix in SIGNAL_SUFFIXES.items():
        matches = sorted(token.strip(";,()") for token in tokens
                         if token.strip(";,()").endswith(suffix))
        if len(matches) != 1:
            raise RuntimeError(f"expected one match for {suffix}, found {len(matches)}: {matches}")
        resolved[key] = matches[0]
    return resolved


def read_signal(tool: Path, env: dict[str, str], fsdb: Path,
                signal: str) -> list[tuple[Xtag, str]]:
    output = run_debug(tool, env, ["-vc", "-vname", signal, str(fsdb)])
    changes = [(Xtag(int(a), int(b)), value.lower())
               for a, b, value in VC_RE.findall(output)]
    if not changes:
        raise RuntimeError(f"no value changes found for {signal}")
    return sorted(changes)


class Wave:
    def __init__(self, changes: list[tuple[Xtag, str]]) -> None:
        self.times = [item[0] for item in changes]
        self.values = [item[1] for item in changes]

    def at(self, time: Xtag) -> str | None:
        index = bisect_right(self.times, time) - 1
        return self.values[index] if index >= 0 else None


def known_int(value: str | None, name: str, width: int) -> int:
    if value is None or len(value) != width or any(bit not in "01" for bit in value):
        raise RuntimeError(f"{name} is not a known {width}-bit value: {value!r}")
    return int(value, 2)


def extract(waves: dict[str, Wave]) -> tuple[list[Record], int]:
    rising_edges = []
    previous = None
    for time, value in zip(waves["clk"].times, waves["clk"].values):
        if previous == "0" and value == "1":
            rising_edges.append(time)
        previous = value
    records = []
    skipped_error = 0
    for time in rising_edges:
        if waves["rvalid"].at(time) != "1":
            continue
        err = waves["err"].at(time)
        if err == "1":
            skipped_error += 1
            continue
        if err != "0":
            raise RuntimeError(f"err_o is unknown at {time}: {err!r}")
        address = known_int(waves["addr"].at(time), "addr_in_proc", 32)
        instruction = known_int(waves["data"].at(time), "data_o", 32)
        if address & 3:
            raise RuntimeError(f"unaligned instruction address at {time}: 0x{address:08x}")
        records.append(Record(time, address, instruction))
    return records, skipped_error


def deduplicate(records: list[Record]) -> tuple[dict[int, int], int]:
    words = {}
    duplicates = 0
    for record in records:
        old = words.get(record.address)
        if old is not None and old != record.instruction:
            raise RuntimeError(f"conflict at 0x{record.address:08x}: 0x{old:08x} vs 0x{record.instruction:08x}")
        duplicates += old is not None
        words[record.address] = record.instruction
    return words, duplicates


def write_dump(path: Path, image: Path, base: int, words: dict[int, int]) -> str:
    objdump = shutil.which("riscv32-unknown-elf-objdump") or shutil.which("riscv64-unknown-elf-objdump")
    if objdump:
        proc = subprocess.run([objdump, "-D", "-b", "binary", "-m", "riscv:rv32",
                               "--adjust-vma", hex(base), str(image)],
                              stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                              text=True, check=False)
        if not proc.returncode:
            path.write_text(proc.stdout, encoding="utf-8")
            return objdump
    path.write_text("".join(f"0x{addr:08x}: 0x{word:08x}\n"
                            for addr, word in sorted(words.items())), encoding="utf-8")
    return "hex-word-fallback"


def main() -> int:
    args = parse_args()
    fsdb = args.fsdb.resolve()
    out_bin = args.out_bin.resolve()
    tool = args.verdi_home / "platform/linux64/bin/fsdbdebug"
    if not fsdb.is_file():
        raise FileNotFoundError(f"FSDB does not exist: {fsdb}")
    if not tool.is_file():
        raise FileNotFoundError(f"fsdbdebug does not exist: {tool}")
    out_bin.parent.mkdir(parents=True, exist_ok=True)
    env = fsdb_env(args.verdi_home)
    signals = discover_signals(tool, env, fsdb)
    waves = {key: Wave(read_signal(tool, env, fsdb, signal))
             for key, signal in signals.items()}
    records, skipped_error = extract(waves)
    words, duplicates = deduplicate(records)
    if not words:
        raise RuntimeError("no successful instruction-memory responses were extracted")
    minimum, maximum = min(words), max(words)
    if minimum < args.base_addr:
        raise RuntimeError(f"address 0x{minimum:08x} is below base 0x{args.base_addr:08x}")
    image = bytearray(maximum + 4 - args.base_addr)
    for address, instruction in words.items():
        offset = address - args.base_addr
        image[offset:offset + 4] = instruction.to_bytes(4, "little")
    out_bin.write_bytes(image)

    stem = out_bin.with_suffix("")
    csv_path = stem.with_suffix(".records.csv")
    json_path = stem.with_suffix(".summary.json")
    dump_path = stem.with_suffix(".dump")
    with csv_path.open("w", newline="", encoding="utf-8") as fd:
        writer = csv.writer(fd)
        writer.writerow(["time_major", "time_minor", "address", "instruction"])
        for record in records:
            writer.writerow([record.time.major, record.time.minor,
                             f"0x{record.address:08x}", f"0x{record.instruction:08x}"])
    dump_tool = write_dump(dump_path, out_bin, args.base_addr, words)
    summary = {
        "status": "success", "fsdb": str(fsdb), "binary": str(out_bin),
        "base_address": f"0x{args.base_addr:08x}",
        "minimum_observed_address": f"0x{minimum:08x}",
        "maximum_observed_address": f"0x{maximum:08x}",
        "response_records": len(records), "unique_words": len(words),
        "duplicate_records": duplicates, "skipped_error_responses": skipped_error,
        "image_bytes": len(image), "observed_bytes": len(words) * 4,
        "zero_fill_bytes": len(image) - len(words) * 4,
        "signals": signals, "dump_tool": dump_tool,
    }
    json_path.write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(summary, indent=2))
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        sys.exit(1)
