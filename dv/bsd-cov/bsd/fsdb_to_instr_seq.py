#!/usr/bin/env python3
"""Extract a valid Ibex instruction sequence from a JasperGold FSDB trace."""

from __future__ import annotations

import argparse
import glob
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

OPTIONAL_SIGNALS = {
    "new_id": (
        "ibex_top.u_ibex_core.instr_first_cycle_id",
        "ibex_top.u_ibex_core.if_stage_i.instr_new_id_d",
        "ibex_top.u_ibex_core.if_stage_i.instr_new_id_o",
    ),
    "rst_ni": (
        "ibex_top.rst_ni",
    ),
}

VC_RE = re.compile(r"xtag:\s*\((\d+)\s+(\d+)\)\s+val:\s+([^\s]+)")
PROP_RE = re.compile(r"(AST_BSDCOV_[A-Za-z0-9_]+)")


@dataclass(frozen=True, order=True)
class Xtag:
    major: int
    minor: int

    def label(self) -> str:
        return f"({self.major} {self.minor})"


@dataclass(frozen=True)
class Instruction:
    time: Xtag
    pc: int
    word: int
    asm: str


@dataclass(frozen=True)
class Extraction:
    sequence: list[Instruction]
    sample_mode: str
    reset_started: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Extract valid ID-stage instructions from an Ibex JasperGold FSDB trace."
    )
    parser.add_argument("--fsdb", type=Path, help="single FSDB trace to extract")
    parser.add_argument(
        "--batch",
        help="directory or glob of FSDB traces to extract",
    )
    parser.add_argument("--out", type=Path, help="output .S file for --fsdb")
    parser.add_argument(
        "--out-dir",
        type=Path,
        default=Path("dv/bsd-cov/bsd/instr_seq"),
        help="output directory for generated .S files",
    )
    parser.add_argument(
        "--verdi-home",
        type=Path,
        default=Path(os.environ.get("VERDI_HOME", DEFAULT_VERDI_HOME)),
        help="Verdi installation directory containing fsdbdebug",
    )
    return parser.parse_args()


def sign_extend(value: int, bits: int) -> int:
    sign = 1 << (bits - 1)
    return value - (1 << bits) if value & sign else value


def reg(idx: int) -> str:
    return f"x{idx}"


def decode_rv32(word: int) -> str:
    opcode = word & 0x7F
    rd = (word >> 7) & 0x1F
    funct3 = (word >> 12) & 0x7
    rs1 = (word >> 15) & 0x1F
    rs2 = (word >> 20) & 0x1F
    funct7 = (word >> 25) & 0x7F

    if opcode == 0x03:
        imm = sign_extend(word >> 20, 12)
        name = {0: "lb", 1: "lh", 2: "lw", 4: "lbu", 5: "lhu"}.get(funct3, "load?")
        return f"{name} {reg(rd)}, {imm}({reg(rs1)})"

    if opcode == 0x23:
        imm = sign_extend((((word >> 25) & 0x7F) << 5) | ((word >> 7) & 0x1F), 12)
        name = {0: "sb", 1: "sh", 2: "sw"}.get(funct3, "store?")
        return f"{name} {reg(rs2)}, {imm}({reg(rs1)})"

    if opcode == 0x0F:
        if funct3 == 0:
            return "fence"
        if funct3 == 1:
            return "fence.i"
        return "misc-mem?"

    if opcode == 0x13:
        imm = sign_extend(word >> 20, 12)
        if funct3 == 0:
            return f"addi {reg(rd)}, {reg(rs1)}, {imm}"
        if funct3 == 2:
            return f"slti {reg(rd)}, {reg(rs1)}, {imm}"
        if funct3 == 3:
            return f"sltiu {reg(rd)}, {reg(rs1)}, {imm}"
        if funct3 == 4:
            return f"xori {reg(rd)}, {reg(rs1)}, {imm}"
        if funct3 == 6:
            return f"ori {reg(rd)}, {reg(rs1)}, {imm}"
        if funct3 == 7:
            return f"andi {reg(rd)}, {reg(rs1)}, {imm}"
        if funct3 == 1 and funct7 == 0:
            return f"slli {reg(rd)}, {reg(rs1)}, {rs2}"
        if funct3 == 5 and funct7 == 0:
            return f"srli {reg(rd)}, {reg(rs1)}, {rs2}"
        if funct3 == 5 and funct7 == 0x20:
            return f"srai {reg(rd)}, {reg(rs1)}, {rs2}"

    if opcode == 0x33:
        r_ops = {
            (0x00, 0): "add",
            (0x20, 0): "sub",
            (0x00, 1): "sll",
            (0x00, 2): "slt",
            (0x00, 3): "sltu",
            (0x00, 4): "xor",
            (0x00, 5): "srl",
            (0x20, 5): "sra",
            (0x00, 6): "or",
            (0x00, 7): "and",
            (0x01, 0): "mul",
            (0x01, 1): "mulh",
            (0x01, 2): "mulhsu",
            (0x01, 3): "mulhu",
            (0x01, 4): "div",
            (0x01, 5): "divu",
            (0x01, 6): "rem",
            (0x01, 7): "remu",
        }
        name = r_ops.get((funct7, funct3))
        if name:
            return f"{name} {reg(rd)}, {reg(rs1)}, {reg(rs2)}"

    if opcode == 0x37:
        return f"lui {reg(rd)}, 0x{word & 0xfffff000:08x}"

    if opcode == 0x17:
        return f"auipc {reg(rd)}, 0x{word & 0xfffff000:08x}"

    if opcode == 0x63:
        imm = sign_extend(
            (((word >> 31) & 0x1) << 12)
            | (((word >> 7) & 0x1) << 11)
            | (((word >> 25) & 0x3F) << 5)
            | (((word >> 8) & 0xF) << 1),
            13,
        )
        name = {0: "beq", 1: "bne", 4: "blt", 5: "bge", 6: "bltu", 7: "bgeu"}.get(
            funct3, "branch?"
        )
        return f"{name} {reg(rs1)}, {reg(rs2)}, {imm}"

    if opcode == 0x6F:
        imm = sign_extend(
            (((word >> 31) & 0x1) << 20)
            | (((word >> 12) & 0xFF) << 12)
            | (((word >> 20) & 0x1) << 11)
            | (((word >> 21) & 0x3FF) << 1),
            21,
        )
        return f"jal {reg(rd)}, {imm}"

    if opcode == 0x67:
        imm = sign_extend(word >> 20, 12)
        return f"jalr {reg(rd)}, {imm}({reg(rs1)})"

    if opcode == 0x73:
        if word == 0x00000073:
            return "ecall"
        if word == 0x00100073:
            return "ebreak"
        csr = word >> 20
        csr_ops = {
            1: "csrrw",
            2: "csrrs",
            3: "csrrc",
            5: "csrrwi",
            6: "csrrsi",
            7: "csrrci",
        }
        name = csr_ops.get(funct3, "system?")
        if funct3 in (1, 2, 3):
            return f"{name} {reg(rd)}, 0x{csr:x}, {reg(rs1)}"
        if funct3 in (5, 6, 7):
            return f"{name} {reg(rd)}, 0x{csr:x}, {rs1}"

    return "unknown"


def fsdbdebug_path(verdi_home: Path) -> Path:
    tool = verdi_home / "platform/linux64/bin/fsdbdebug"
    if not tool.exists():
        raise FileNotFoundError(f"fsdbdebug not found: {tool}")
    return tool


def fsdb_env(verdi_home: Path) -> dict[str, str]:
    env = os.environ.copy()
    env["VERDI_HOME"] = str(verdi_home)
    libstdcpp = verdi_home / "etc/lib/libstdc++/linux64"
    old_ld = env.get("LD_LIBRARY_PATH")
    env["LD_LIBRARY_PATH"] = f"{libstdcpp}:{old_ld}" if old_ld else str(libstdcpp)
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


def reset_started_before(
    rst_wave: list[tuple[Xtag, str]] | None,
    first_instruction_time: Xtag | None,
) -> str:
    if rst_wave is None:
        return "unknown"

    saw_reset = False
    for time, value in rst_wave:
        if first_instruction_time is not None and time > first_instruction_time:
            break
        if value == "0":
            saw_reset = True
            break

    return "yes" if saw_reset else "no"


def extract_sequence(fsdb: Path, verdi_home: Path) -> Extraction:
    tool = fsdbdebug_path(verdi_home)
    env = fsdb_env(verdi_home)

    waves = {name: read_signal(tool, env, fsdb, signal) for name, signal in SIGNALS.items()}
    optional_new_id = try_read_signal(tool, env, fsdb, OPTIONAL_SIGNALS["new_id"])
    optional_rst = try_read_signal(tool, env, fsdb, OPTIONAL_SIGNALS["rst_ni"])

    sample_times = sorted({time for wave in waves.values() for time, _ in wave})
    if optional_new_id is not None:
        new_id_signal, new_id_wave = optional_new_id
        sample_times = sorted(set(sample_times) | {time for time, _ in new_id_wave})
        sample_mode = f"all-changes gated by new-id ({new_id_signal})"
    else:
        sample_mode = "all-changes (new-id signal unavailable)"

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

        sequence.append(Instruction(time=time, pc=pc, word=word, asm=decode_rv32(word)))
        last_pair = pair

    first_time = sequence[0].time if sequence else None
    rst_wave = optional_rst[1] if optional_rst is not None else None
    return Extraction(
        sequence=sequence,
        sample_mode=sample_mode,
        reset_started=reset_started_before(rst_wave, first_time),
    )


def property_name(fsdb: Path) -> str:
    match = PROP_RE.search(fsdb.name)
    if match:
        return match.group(1)
    return fsdb.stem


def output_path_for(fsdb: Path, out_dir: Path) -> Path:
    return out_dir / f"{property_name(fsdb)}.S"


def render_assembly(fsdb: Path, extraction: Extraction) -> str:
    sequence = extraction.sequence
    lines = [
        '#include "riscv_test.h"',
        '#include "test_macros.h"',
        "",
        "RVTEST_RV64M",
        "RVTEST_CODE_BEGIN",
        "",
        "main:",
        f"  # Source FSDB: {fsdb}",
        f"  # Extracted valid instructions: {len(sequence)}",
        f"  # Sample mode: {extraction.sample_mode}",
        f"  # Reset-started trace: {extraction.reset_started}",
    ]

    if sequence:
        for idx, instr in enumerate(sequence):
            lines.append(
                f"  .word 0x{instr.word:08x}  # {idx}: pc=0x{instr.pc:08x} "
                f"time={instr.time.label()} {instr.asm}"
            )
    else:
        lines.append("  # No valid non-error, non-illegal ID-stage instruction was found.")

    lines.extend(
        [
            "",
            "  j pass",
            "",
            "RVTEST_CODE_END",
            "",
            "pass:",
            "  RVTEST_PASS",
            "",
            "fail:",
            "  RVTEST_FAIL",
            "",
            "  .data",
            "RVTEST_DATA_BEGIN",
            "",
            "  TEST_DATA",
            "",
            "RVTEST_DATA_END",
            "",
        ]
    )
    return "\n".join(lines)


def write_sequence(fsdb: Path, out: Path, verdi_home: Path) -> bool:
    extraction = extract_sequence(fsdb, verdi_home)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(render_assembly(fsdb, extraction), encoding="utf-8")
    print(f"{fsdb} -> {out} ({len(extraction.sequence)} instruction(s))")
    return bool(extraction.sequence)


def expand_batch(batch: str) -> list[Path]:
    batch_path = Path(batch)
    if batch_path.is_dir():
        return sorted(batch_path.glob("*.fsdb"))
    return sorted(Path(path) for path in glob.glob(batch))


def main() -> int:
    args = parse_args()
    if not args.fsdb and not args.batch:
        print("ERROR: provide --fsdb or --batch", file=sys.stderr)
        return 2
    if args.fsdb and args.batch:
        print("ERROR: use only one of --fsdb or --batch", file=sys.stderr)
        return 2

    failures = 0

    try:
        if args.fsdb:
            fsdb = args.fsdb.resolve()
            out = args.out.resolve() if args.out else output_path_for(fsdb, args.out_dir).resolve()
            if not write_sequence(fsdb, out, args.verdi_home):
                failures += 1
        else:
            fsdbs = expand_batch(args.batch)
            if not fsdbs:
                print(f"ERROR: no FSDB files matched {args.batch}", file=sys.stderr)
                return 2
            for fsdb in fsdbs:
                out = output_path_for(fsdb.resolve(), args.out_dir).resolve()
                if not write_sequence(fsdb.resolve(), out, args.verdi_home):
                    failures += 1
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1

    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
