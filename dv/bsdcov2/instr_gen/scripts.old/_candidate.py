#!/usr/bin/env python3
from __future__ import annotations

import csv
import os
import re
from bisect import bisect_right
from dataclasses import dataclass
from pathlib import Path

from _common import run
from _image import IMAGE_BASE, read_words

DEFAULT_VERDI = Path("/home/lvzhengyang/workspace/synopsys/verdi/T-2022.06")
SIGNALS = {
    "clk": ("imem_if_inst.u_fml_imem.clk_i",),
    "rvalid": ("imem_if_inst.u_fml_imem.rvalid_o",),
    "addr": ("imem_if_inst.u_fml_imem.addr_in_proc",
             "imem_if_inst.u_fml_imem.addr_q"),
    "err": ("imem_if_inst.u_fml_imem.err_o",),
    "data": ("imem_if_inst.u_fml_imem.data_o",),
}
VC_RE = re.compile(r"xtag:\s*\((\d+)\s+(\d+)\)\s+val:\s+([^\s]+)")


@dataclass(frozen=True, order=True)
class Time:
    major: int
    minor: int


class Wave:
    def __init__(self, changes: list[tuple[Time, str]]) -> None:
        self.times = [item[0] for item in changes]
        self.values = [item[1] for item in changes]

    def at(self, time: Time) -> str | None:
        index = bisect_right(self.times, time) - 1
        return self.values[index] if index >= 0 else None


def _environment(verdi: Path) -> dict[str, str]:
    ugo = verdi / "share/ugo/linux64/bin/ugo_dist/ugo"
    old = os.environ.get("LD_LIBRARY_PATH", "")
    return {"VERDI_HOME": str(verdi),
            "LD_LIBRARY_PATH": f"{ugo}:{old}" if old else str(ugo)}


def _debug(tool: Path, env: dict[str, str], args: list[str], cwd: Path) -> str:
    return run([str(tool), *args], env=env, cwd=cwd).stdout


def extract_candidate(fsdb: Path, current_image: Path, output_csv: Path,
                      window: int, verdi: Path = DEFAULT_VERDI) -> list[tuple[int, int]]:
    tool = verdi / "platform/linux64/bin/fsdbdebug"
    if not tool.is_file():
        raise FileNotFoundError(f"fsdbdebug not found: {tool}")
    output_csv.parent.mkdir(parents=True, exist_ok=True)
    debug_cwd = output_csv.parent
    env = _environment(verdi)
    hierarchy = _debug(tool, env, ["-hier_tree", str(fsdb)], debug_cwd)
    tokens = set(re.findall(r"[A-Za-z_$][A-Za-z0-9_$.\\\[\]:/]*", hierarchy))
    resolved: dict[str, str] = {}
    for name, suffixes in SIGNALS.items():
        matches = sorted(token.strip(";,()") for token in tokens
                         if any(token.strip(";,()").endswith(suffix)
                                for suffix in suffixes))
        if len(matches) != 1:
            raise RuntimeError(f"expected one FSDB signal ending in {suffixes}; found {matches}")
        resolved[name] = matches[0]
    waves: dict[str, Wave] = {}
    for name, signal in resolved.items():
        text = _debug(tool, env, ["-vc", "-vname", signal, str(fsdb)], debug_cwd)
        changes = [(Time(int(a), int(b)), value.lower())
                   for a, b, value in VC_RE.findall(text)]
        if not changes:
            raise RuntimeError(f"no value changes for {signal}")
        waves[name] = Wave(changes)
    rising: list[Time] = []
    previous = None
    for time, value in zip(waves["clk"].times, waves["clk"].values):
        if previous == "0" and value == "1":
            rising.append(time)
        previous = value
    observed: list[tuple[int, int]] = []
    for time in rising:
        if waves["rvalid"].at(time) != "1" or waves["err"].at(time) != "0":
            continue
        address_bits, data_bits = waves["addr"].at(time), waves["data"].at(time)
        if not address_bits or not data_bits or set(address_bits + data_bits) - {"0", "1"}:
            raise RuntimeError("CEX instruction response contains X/Z")
        observed.append((int(address_bits, 2), int(data_bits, 2)))

    known = read_words(current_image)
    start = IMAGE_BASE + current_image.stat().st_size
    new: dict[int, int] = {}
    for address, word in observed:
        if address in known:
            if known[address] != word:
                raise RuntimeError(f"CEX changes known word at 0x{address:08x}")
            continue
        if address < start:
            raise RuntimeError(f"CEX references an unrecorded hole at 0x{address:08x}")
        if address in new and new[address] != word:
            raise RuntimeError(f"CEX has conflicting words at 0x{address:08x}")
        new[address] = word
    if not new:
        raise RuntimeError("CEX contains no new instruction words")
    candidate = sorted(new.items())
    if len(candidate) > window:
        raise RuntimeError(f"CEX has {len(candidate)} new words; window is {window}")
    for index, (address, _word) in enumerate(candidate):
        expected = start + index * 4
        if address != expected:
            raise RuntimeError(f"CEX instruction addresses are sparse: expected "
                               f"0x{expected:08x}, got 0x{address:08x}")
    with output_csv.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.writer(stream)
        writer.writerow(["address", "instruction"])
        for address, word in candidate:
            writer.writerow([f"0x{address:08x}", f"0x{word:08x}"])
    return candidate
