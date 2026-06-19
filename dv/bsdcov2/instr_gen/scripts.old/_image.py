#!/usr/bin/env python3
from __future__ import annotations

import csv
import hashlib
import shutil
from pathlib import Path

IMAGE_BASE = 0x80000000
COMMON_END = 0x8000011C
GENERATED_START = 0x80000120


def base_prefix(initial: Path) -> bytes:
    data = initial.read_bytes()
    needed = GENERATED_START - IMAGE_BASE
    if len(data) < needed:
        raise RuntimeError(f"initial image has {len(data)} bytes; need at least {needed}")
    return data[:needed]


def read_words(image: Path) -> dict[int, int]:
    data = image.read_bytes()
    if len(data) % 4:
        raise RuntimeError(f"image is not word aligned: {image}")
    return {IMAGE_BASE + offset: int.from_bytes(data[offset:offset + 4], "little")
            for offset in range(0, len(data), 4)}


def generated_words(image: Path) -> list[tuple[int, int]]:
    return [(address, word) for address, word in read_words(image).items()
            if address >= GENERATED_START]


def write_image(initial: Path, generated: list[tuple[int, int]], output: Path) -> None:
    expected = GENERATED_START
    data = bytearray(base_prefix(initial))
    for address, word in generated:
        if address != expected:
            raise RuntimeError(f"non-contiguous generated address 0x{address:08x}; "
                               f"expected 0x{expected:08x}")
        data.extend(int(word).to_bytes(4, "little"))
        expected += 4
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(data)


def append_candidate(current: Path, candidate: list[tuple[int, int]], output: Path) -> None:
    words = read_words(current)
    expected = IMAGE_BASE + len(current.read_bytes())
    data = bytearray(current.read_bytes())
    for address, word in candidate:
        if address != expected:
            raise RuntimeError(f"candidate starts or continues at 0x{address:08x}; "
                               f"expected 0x{expected:08x}")
        if address in words:
            raise RuntimeError(f"candidate overwrites 0x{address:08x}")
        data.extend(word.to_bytes(4, "little"))
        expected += 4
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(data)


def write_sequence_csv(image: Path, output: Path) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.writer(stream)
        for address, word in generated_words(image):
            writer.writerow([f"0x{address:08x}", f"0x{word:08x}"])


def candidate_signature(candidate: list[tuple[int, int]]) -> str:
    digest = hashlib.sha256()
    for address, word in candidate:
        digest.update(address.to_bytes(4, "big"))
        digest.update(word.to_bytes(4, "big"))
    return digest.hexdigest()


def disassemble(image: Path, output: Path) -> str:
    tool = shutil.which("riscv32-unknown-elf-objdump") or shutil.which(
        "riscv64-unknown-elf-objdump")
    if not tool:
        output.write_text("".join(
            f"0x{address:08x}: 0x{word:08x}\n"
            for address, word in sorted(read_words(image).items())), encoding="utf-8")
        return "hex-word-fallback"
    from _common import run
    proc = run([tool, "-D", "-b", "binary", "-m", "riscv:rv32",
                "--adjust-vma", hex(IMAGE_BASE), str(image)], check=False)
    output.write_text(proc.stdout, encoding="utf-8")
    return tool if proc.returncode == 0 else "objdump-failed"

