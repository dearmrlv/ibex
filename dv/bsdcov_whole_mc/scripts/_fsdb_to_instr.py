#!/usr/bin/env python3
"""Extract Ibex instruction hex words from a JasperGold FSDB trace."""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path


DEFAULT_VERDI_HOME = Path("/home/lvzhengyang/workspace/synopsys/verdi/T-2022.06")

SIGNALS = {
    "valid": "ibex_top.u_ibex_core.instr_valid_id",
    "instr": "ibex_top.u_ibex_core.instr_rdata_id",
    "pc": "ibex_top.u_ibex_core.pc_id",
    "fetch_err": "ibex_top.u_ibex_core.instr_fetch_err",
    "illegal_c": "ibex_top.u_ibex_core.illegal_c_insn_id",
    "illegal": "ibex_top.u_ibex_core.illegal_insn_id",
}

IMEM_SIGNALS = {
    "rvalid": "ibex_top.instr_rvalid_i",
    "instr": "ibex_top.instr_rdata_i",
    "err": "ibex_top.instr_err_i",
    "addr": "ibex_top.instr_addr_o",
}

CORE_IMEM_SIGNALS = {
    "rvalid": "ibex_top.u_ibex_core.instr_rvalid_i",
    "instr": "ibex_top.u_ibex_core.instr_rdata_i",
    "err": "ibex_top.u_ibex_core.instr_err_i",
}

OPTIONAL_SIGNALS = {
    "new_id": (
        "ibex_top.u_ibex_core.instr_first_cycle_id",
        "ibex_top.u_ibex_core.if_stage_i.instr_new_id_d",
        "ibex_top.u_ibex_core.if_stage_i.instr_new_id_o",
    ),
}

VC_RE = re.compile(r"xtag:\s*\((\d+)\s+(\d+)\)\s+val:\s+([^\s]+)")


@dataclass(frozen=True, order=True)
class Xtag:
    major: int
    minor: int


@dataclass(frozen=True)
class Instruction:
    time: Xtag
    pc: int
    word: int


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Extract valid ID-stage Ibex instruction hex words from a JasperGold FSDB trace."
    )
    parser.add_argument("--fsdb", type=Path, required=True, help="input JasperGold FSDB trace")
    parser.add_argument("--out", type=Path, required=True, help="output text file, one 8-digit hex word per line")
    parser.add_argument(
        "--mode",
        choices=("core-imem-input", "imem-input", "id-stage"),
        default="core-imem-input",
        help="instruction source to extract from; default: core-imem-input",
    )
    parser.add_argument(
        "--verdi-home",
        type=Path,
        default=Path(os.environ.get("VERDI_HOME", DEFAULT_VERDI_HOME)),
        help="Verdi installation directory containing platform/linux64/bin/fsdbdebug",
    )
    return parser.parse_args()


def fsdbdebug_path(verdi_home: Path) -> Path:
    tool = verdi_home / "platform/linux64/bin/fsdbdebug"
    if not tool.exists():
        raise FileNotFoundError(f"fsdbdebug not found: {tool}")
    return tool


def fsdb_env(verdi_home: Path) -> dict[str, str]:
    env = os.environ.copy()
    env["VERDI_HOME"] = str(verdi_home)
    ugo_lib = verdi_home / "share/ugo/linux64/bin/ugo_dist/ugo"
    old_ld = env.get("LD_LIBRARY_PATH")
    env["LD_LIBRARY_PATH"] = f"{ugo_lib}:{old_ld}" if old_ld else str(ugo_lib)
    return env


def read_signal(tool: Path, env: dict[str, str], fsdb: Path, signal: str) -> list[tuple[Xtag, str]]:
    cmd = [str(tool), "-vc", "-vname", signal, str(fsdb)]
    proc = subprocess.run(
        cmd,
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        check=False,
    )
    if "Signal not found" in proc.stdout or "No such" in proc.stdout:
        raise RuntimeError(f"signal not found in {fsdb}: {signal}")

    changes: list[tuple[Xtag, str]] = []
    for major, minor, value in VC_RE.findall(proc.stdout):
        changes.append((Xtag(int(major), int(minor)), value))

    if not changes:
        raise RuntimeError(f"no value changes found for {signal} in {fsdb}")
    return sorted(changes)


def try_read_signal(
    tool: Path,
    env: dict[str, str],
    fsdb: Path,
    signals: tuple[str, ...],
) -> tuple[str, list[tuple[Xtag, str]]] | None:
    for signal in signals:
        try:
            return signal, read_signal(tool, env, fsdb, signal)
        except RuntimeError:
            continue
    return None


def value_at(changes: list[tuple[Xtag, str]], time: Xtag) -> str | None:
    current: str | None = None
    for change_time, value in changes:
        if change_time > time:
            break
        current = value
    return current


def is_bit(value: str | None, bit: str) -> bool:
    return value == bit


def parse_binary(value: str | None) -> int | None:
    if value is None or not value or any(ch not in "01" for ch in value):
        return None
    return int(value, 2)


def low_bits(value: str | None, width: int) -> str | None:
    if value is None or len(value) < width:
        return None
    return value[-width:]


def extract_id_stage_sequence(fsdb: Path, verdi_home: Path) -> list[Instruction]:
    tool = fsdbdebug_path(verdi_home)
    env = fsdb_env(verdi_home)

    waves = {name: read_signal(tool, env, fsdb, signal) for name, signal in SIGNALS.items()}
    optional_new_id = try_read_signal(tool, env, fsdb, OPTIONAL_SIGNALS["new_id"])

    sample_times = sorted({time for wave in waves.values() for time, _ in wave})
    if optional_new_id is not None:
        _, new_id_wave = optional_new_id
        sample_times = sorted(set(sample_times) | {time for time, _ in new_id_wave})

    sequence: list[Instruction] = []
    last_pair: tuple[int, int] | None = None

    for time in sample_times:
        if optional_new_id is not None and not is_bit(value_at(new_id_wave, time), "1"):
            continue
        if not is_bit(value_at(waves["valid"], time), "1"):
            continue
        if not is_bit(value_at(waves["fetch_err"], time), "0"):
            continue
        if not is_bit(value_at(waves["illegal_c"], time), "0"):
            continue
        if not is_bit(value_at(waves["illegal"], time), "0"):
            continue

        pc = parse_binary(value_at(waves["pc"], time))
        word = parse_binary(value_at(waves["instr"], time))
        if pc is None or word is None:
            continue

        pair = (pc, word)
        if pair == last_pair:
            continue

        sequence.append(Instruction(time=time, pc=pc, word=word))
        last_pair = pair

    return sequence


def extract_imem_input_sequence(fsdb: Path, verdi_home: Path) -> list[Instruction]:
    tool = fsdbdebug_path(verdi_home)
    env = fsdb_env(verdi_home)

    waves = {name: read_signal(tool, env, fsdb, signal) for name, signal in IMEM_SIGNALS.items()}
    sample_times = sorted({time for wave in waves.values() for time, _ in wave})

    sequence: list[Instruction] = []
    last_pair: tuple[int, int] | None = None

    for time in sample_times:
        if not is_bit(value_at(waves["rvalid"], time), "1"):
            continue
        if not is_bit(value_at(waves["err"], time), "0"):
            continue

        addr = parse_binary(value_at(waves["addr"], time))
        word = parse_binary(value_at(waves["instr"], time))
        if addr is None or word is None:
            continue

        pair = (addr, word)
        if pair == last_pair:
            continue

        sequence.append(Instruction(time=time, pc=addr, word=word))
        last_pair = pair

    return sequence


def extract_core_imem_input_sequence(fsdb: Path, verdi_home: Path) -> list[Instruction]:
    tool = fsdbdebug_path(verdi_home)
    env = fsdb_env(verdi_home)

    waves = {name: read_signal(tool, env, fsdb, signal) for name, signal in CORE_IMEM_SIGNALS.items()}
    sample_times = sorted({time for wave in waves.values() for time, _ in wave})

    sequence: list[Instruction] = []

    for time in sample_times:
        if not is_bit(value_at(waves["rvalid"], time), "1"):
            continue
        if not is_bit(value_at(waves["err"], time), "0"):
            continue

        word = parse_binary(low_bits(value_at(waves["instr"], time), 32))
        if word is None:
            continue

        sequence.append(Instruction(time=time, pc=0, word=word))

    return sequence


def extract_sequence(fsdb: Path, verdi_home: Path, mode: str) -> list[Instruction]:
    if mode == "core-imem-input":
        return extract_core_imem_input_sequence(fsdb, verdi_home)
    if mode == "imem-input":
        return extract_imem_input_sequence(fsdb, verdi_home)
    if mode == "id-stage":
        return extract_id_stage_sequence(fsdb, verdi_home)
    raise ValueError(f"unsupported extraction mode: {mode}")


def write_hex_words(fsdb: Path, out: Path, verdi_home: Path, mode: str) -> int:
    sequence = extract_sequence(fsdb, verdi_home, mode)
    out.parent.mkdir(parents=True, exist_ok=True)
    text = "".join(f"{instr.word:08x}\n" for instr in sequence)
    out.write_text(text, encoding="utf-8")
    print(f"{fsdb} -> {out} ({len(sequence)} instruction(s), mode={mode})")
    return len(sequence)


def main() -> int:
    args = parse_args()
    try:
        fsdb = args.fsdb.resolve()
        out = args.out.resolve()
        if not fsdb.exists():
            print(f"ERROR: FSDB does not exist: {fsdb}", file=sys.stderr)
            return 2
        write_hex_words(fsdb, out, args.verdi_home, args.mode)
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
