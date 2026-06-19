#!/usr/bin/env python3
from __future__ import annotations

import csv
import hashlib
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable, Sequence

IMAGE_BASE = 0x80000000
COMMON_END = 0x8000011C
GENERATED_START = 0x80000120
COMMON_INSTR_NUM = ((COMMON_END - IMAGE_BASE) // 4) - 31


def _parse_int(value: int | str, field: str) -> int:
    if isinstance(value, int):
        return value
    text = value.strip().replace("_", "")
    base = 16 if text.lower().startswith("0x") else 10
    try:
        return int(text, base)
    except ValueError as exc:
        raise ValueError(f"invalid {field}: {value!r}") from exc


def _check_word(value: int, field: str) -> None:
    if value < 0 or value > 0xFFFFFFFF:
        raise ValueError(f"{field} is not a 32-bit value: 0x{value:x}")


def _check_addr(addr: int) -> None:
    _check_word(addr, "address")
    if addr % 4:
        raise ValueError(f"address is not word aligned: 0x{addr:08x}")


@dataclass(frozen=True, order=True)
class InstrWrapper:
    addr: int
    instr: int

    def __post_init__(self) -> None:
        _check_addr(self.addr)
        _check_word(self.instr, "instruction")

    def __repr__(self) -> str:
        return (f"InstrWrapper(addr=0x{self.addr:08x}, "
                f"instr=0x{self.instr:08x})")

    @classmethod
    def from_tuple(cls, item: tuple[int | str, int | str]) -> "InstrWrapper":
        addr, instr = item
        return cls(_parse_int(addr, "address"), _parse_int(instr, "instruction"))

    @classmethod
    def from_dict(cls, item: dict[str, Any]) -> "InstrWrapper":
        addr = item.get("addr", item.get("address"))
        instr = item.get("instr", item.get("instruction", item.get("word")))
        if addr is None or instr is None:
            raise ValueError(f"instruction dict needs addr/address and instr/instruction: {item}")
        return cls(_parse_int(addr, "address"), _parse_int(instr, "instruction"))

    @classmethod
    def from_csv_row(cls, row: Sequence[str]) -> "InstrWrapper":
        if len(row) < 2:
            raise ValueError(f"instruction CSV row needs at least two columns: {row}")
        return cls(_parse_int(row[0], "address"), _parse_int(row[1], "instruction"))

    @classmethod
    def coerce(cls, item: Any) -> "InstrWrapper":
        if isinstance(item, InstrWrapper):
            return item
        if isinstance(item, dict):
            return cls.from_dict(item)
        if isinstance(item, tuple) and len(item) == 2:
            return cls.from_tuple(item)
        if isinstance(item, list) and len(item) == 2:
            return cls.from_tuple((item[0], item[1]))
        raise TypeError(f"cannot convert to InstrWrapper: {item!r}")

    def to_tuple(self) -> tuple[int, int]:
        return self.addr, self.instr

    def to_csv_row(self) -> list[str]:
        return [f"0x{self.addr:08x}", f"0x{self.instr:08x}"]


class SimBin:
    def __init__(self, content: Iterable[InstrWrapper | tuple[int, int] | dict[str, Any]]):
        self.content = [InstrWrapper.coerce(item) for item in content]
        self._validate_content()
        self.addr_min = self.content[0].addr if self.content else None
        self.addr_max = self.content[-1].addr if self.content else None

    @classmethod
    def from_init_bin(cls, path: Path) -> "SimBin":
        return cls(_words_from_bytes(base_prefix(path)))

    @classmethod
    def from_file(cls, path: Path) -> "SimBin":
        return cls(_words_from_bytes(path.read_bytes()))

    def _validate_content(self) -> None:
        if not self.content:
            return
        expected = self.content[0].addr
        seen: set[int] = set()
        for instr in self.content:
            if instr.addr in seen:
                raise ValueError(f"duplicate instruction address: 0x{instr.addr:08x}")
            if instr.addr != expected:
                raise ValueError(f"non-contiguous image address 0x{instr.addr:08x}; "
                                 f"expected 0x{expected:08x}")
            seen.add(instr.addr)
            expected += 4

    def copy(self) -> "SimBin":
        return SimBin(list(self.content))

    def get_instr_num(self) -> int:
        return COMMON_INSTR_NUM + len(self.generated_instrs())

    def generated_instrs(self) -> list[InstrWrapper]:
        return [instr for instr in self.content if instr.addr >= GENERATED_START]

    def words(self) -> dict[int, int]:
        return {instr.addr: instr.instr for instr in self.content}

    def next_addr(self) -> int:
        if not self.content:
            return IMAGE_BASE
        return self.content[-1].addr + 4

    def add_instr_seq(self, instr_seq: Iterable[InstrWrapper | tuple[int, int] | dict[str, Any]]) -> None:
        expected = self.next_addr()
        seen = self.words()
        new_instrs = [InstrWrapper.coerce(item) for item in instr_seq]
        for instr in new_instrs:
            if instr.addr != expected:
                raise ValueError(f"instruction sequence address 0x{instr.addr:08x}; "
                                 f"expected 0x{expected:08x}")
            if instr.addr in seen:
                raise ValueError(f"instruction overwrites 0x{instr.addr:08x}")
            expected += 4
        self.content.extend(new_instrs)
        self._validate_content()
        self.addr_min = self.content[0].addr if self.content else None
        self.addr_max = self.content[-1].addr if self.content else None

    def gen_file(self, path: Path) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        data = bytearray()
        expected = IMAGE_BASE
        for instr in self.content:
            if instr.addr != expected:
                raise ValueError(f"cannot write sparse image at 0x{instr.addr:08x}; "
                                 f"expected 0x{expected:08x}")
            data.extend(instr.instr.to_bytes(4, "little"))
            expected += 4
        path.write_bytes(data)

    def write_sequence_csv(self, path: Path) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("w", newline="", encoding="utf-8") as stream:
            writer = csv.writer(stream)
            for instr in self.generated_instrs():
                writer.writerow(instr.to_csv_row())


def _words_from_bytes(data: bytes) -> list[InstrWrapper]:
    if len(data) % 4:
        raise ValueError(f"image data is not word aligned: {len(data)} bytes")
    return [
        InstrWrapper(IMAGE_BASE + offset, int.from_bytes(data[offset:offset + 4], "little"))
        for offset in range(0, len(data), 4)
    ]


def base_prefix(initial: Path) -> bytes:
    data = initial.read_bytes()
    needed = GENERATED_START - IMAGE_BASE
    if len(data) < needed:
        raise RuntimeError(f"initial image has {len(data)} bytes; need at least {needed}")
    return data[:needed]


def read_words(image: Path) -> dict[int, int]:
    return {instr.addr: instr.instr for instr in _words_from_bytes(image.read_bytes())}


def generated_words(image: Path) -> list[tuple[int, int]]:
    return [instr.to_tuple() for instr in SimBin.from_file(image).generated_instrs()]


def write_image(initial: Path, generated: Iterable[InstrWrapper | tuple[int, int] | dict[str, Any]],
                output: Path) -> None:
    image = SimBin.from_init_bin(initial)
    image.add_instr_seq(generated)
    image.gen_file(output)


def append_candidate(current: Path, candidate: Iterable[InstrWrapper | tuple[int, int] | dict[str, Any]],
                     output: Path) -> None:
    image = SimBin.from_file(current)
    image.add_instr_seq(candidate)
    image.gen_file(output)


def write_sequence_csv(image: Path, output: Path) -> None:
    SimBin.from_file(image).write_sequence_csv(output)


def candidate_signature(candidate: Iterable[InstrWrapper | tuple[int, int] | dict[str, Any]]) -> str:
    digest = hashlib.sha256()
    for instr in [InstrWrapper.coerce(item) for item in candidate]:
        digest.update(instr.addr.to_bytes(4, "big"))
        digest.update(instr.instr.to_bytes(4, "big"))
    return digest.hexdigest()
