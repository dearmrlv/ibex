#!/usr/bin/env python3
from __future__ import annotations

import csv
from enum import Enum
from pathlib import Path
from typing import Any, Iterable

from _fsdb_wrapper import FSDBTime, FSDBWave, FSDBWrapper
from _sim_bin import InstrWrapper, SimBin

SIGNALS = {
    "clk": ("imem_if_inst.u_fml_imem.clk_i",),
    "rvalid": ("imem_if_inst.u_fml_imem.rvalid_o",),
    "addr": ("imem_if_inst.u_fml_imem.addr_in_proc",
             "imem_if_inst.u_fml_imem.addr_q"),
    "err": ("imem_if_inst.u_fml_imem.err_o",),
    "data": ("imem_if_inst.u_fml_imem.data_o",),
}


class ProofStatus(str, Enum):
    PENDING = "pending"
    PROVEN = "proven"
    TIMEOUT = "timeout"
    CEX = "cex"
    ERROR = "error"


class AssertCex:
    def __init__(self, fsdb: FSDBWrapper, current_bin: SimBin,
                 output_csv: Path | None = None):
        if not fsdb.from_fml:
            raise ValueError("assertion CEX requires a formal FSDB")
        self.fsdb = fsdb
        self.current_bin = current_bin.copy()
        self.output_csv = output_csv
        self._instr_seq: list[InstrWrapper] | None = None

    def to_instr_seq(self) -> list[InstrWrapper]:
        if self._instr_seq is None:
            self._instr_seq = self._extract()
            if self.output_csv is not None:
                self._write_csv(self.output_csv, self._instr_seq)
        return list(self._instr_seq)

    def empty(self) -> bool:
        try:
            return not self.to_instr_seq()
        except RuntimeError:
            return True

    def to_dict(self) -> dict[str, Any]:
        return {
            "fsdb": self.fsdb.to_dict(),
            "output_csv": str(self.output_csv) if self.output_csv else None,
        }

    def _extract(self) -> list[InstrWrapper]:
        cwd = self.output_csv.parent if self.output_csv else self.fsdb.filepath.parent
        waves = {name: self.fsdb.read_wave(*suffixes, cwd=cwd)
                 for name, suffixes in SIGNALS.items()}
        observed = self._sample_responses(waves)
        known = self.current_bin.words()
        start = self.current_bin.next_addr()
        prefix: dict[int, int] = {}
        expected = start
        saw_gap = False
        for address, word in observed:
            if address in known:
                if known[address] != word:
                    raise RuntimeError(f"CEX changes known word at 0x{address:08x}")
                continue
            if address < start:
                raise RuntimeError(f"CEX references an unrecorded hole at 0x{address:08x}")
            if saw_gap:
                continue
            if address in prefix:
                if prefix[address] != word:
                    raise RuntimeError(f"CEX has conflicting words at 0x{address:08x}")
                continue
            if address != expected:
                if prefix:
                    saw_gap = True
                    continue
                raise RuntimeError(f"CEX instruction addresses are sparse: expected "
                                   f"0x{expected:08x}, got 0x{address:08x}")
            prefix[address] = word
            expected += 4
        if not prefix:
            raise RuntimeError("CEX contains no new instruction words")
        candidate = [InstrWrapper(address, word) for address, word in sorted(prefix.items())]
        return candidate

    @staticmethod
    def _sample_responses(waves: dict[str, FSDBWave]) -> list[tuple[int, int]]:
        rising: list[FSDBTime] = []
        previous = None
        for time, value in waves["clk"].changes:
            if previous == "0" and value == "1":
                rising.append(time)
            previous = value
        observed: list[tuple[int, int]] = []
        for time in rising:
            if waves["rvalid"].at(time) != "1" or waves["err"].at(time) != "0":
                continue
            address_bits = waves["addr"].at(time)
            data_bits = waves["data"].at(time)
            if not address_bits or not data_bits:
                raise RuntimeError("CEX instruction response has no address or data")
            if set(address_bits + data_bits) - {"0", "1"}:
                raise RuntimeError("CEX instruction response contains X/Z")
            observed.append((int(address_bits, 2), int(data_bits, 2)))
        return observed

    @staticmethod
    def _write_csv(path: Path, instr_seq: Iterable[InstrWrapper]) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("w", newline="", encoding="utf-8") as stream:
            writer = csv.writer(stream)
            writer.writerow(["address", "instruction"])
            for instr in instr_seq:
                writer.writerow(instr.to_csv_row())


class AssertStat:
    def __init__(self, name: str, src_file: Path | None = None, expr: str = "",
                 proof_status: ProofStatus | str = ProofStatus.PENDING,
                 cexs: Iterable[AssertCex] | None = None):
        if not name.strip():
            raise ValueError("assertion name must not be empty")
        self.name = name
        self.src_file = src_file.expanduser().resolve() if src_file else None
        self.expr = expr
        self.proof_status = (proof_status if isinstance(proof_status, ProofStatus)
                             else ProofStatus(proof_status))
        self.cexs = list(cexs or [])
        if self.proof_status is ProofStatus.CEX and not self.cexs:
            raise ValueError("CEX assertion status requires at least one CEX")

    @classmethod
    def from_dict(cls, value: dict[str, Any],
                  cexs: Iterable[AssertCex] | None = None) -> "AssertStat":
        restored_cexs = list(cexs or [])
        serialized_cexs = value.get("cexs", [])
        if serialized_cexs and len(restored_cexs) != len(serialized_cexs):
            raise ValueError("restoring assertion CEX history requires matching AssertCex objects")
        src_file = Path(value["src_file"]) if value.get("src_file") else None
        return cls(name=value["name"], src_file=src_file, expr=value.get("expr", ""),
                   proof_status=value.get("proof_status", ProofStatus.PENDING.value),
                   cexs=restored_cexs)

    def is_pending(self) -> bool:
        return self.proof_status is ProofStatus.PENDING

    def is_proven(self) -> bool:
        return self.proof_status is ProofStatus.PROVEN

    def is_timeout(self) -> bool:
        return self.proof_status is ProofStatus.TIMEOUT

    def has_cex(self) -> bool:
        return bool(self.cexs)

    @property
    def latest_cex(self) -> AssertCex | None:
        return self.cexs[-1] if self.cexs else None

    def add_cex(self, cex: AssertCex) -> None:
        if self.is_proven():
            raise ValueError(f"cannot add a CEX to proven assertion {self.name}")
        self.cexs.append(cex)
        self.proof_status = ProofStatus.CEX

    def set_status(self, status: ProofStatus | str) -> None:
        new_status = status if isinstance(status, ProofStatus) else ProofStatus(status)
        if new_status is ProofStatus.CEX and not self.cexs:
            raise ValueError("cannot set CEX status without a CEX")
        if new_status is ProofStatus.PROVEN and self.cexs:
            raise ValueError("cannot mark an assertion with CEX history as proven")
        self.proof_status = new_status

    def to_dict(self) -> dict[str, Any]:
        return {
            "name": self.name,
            "proof_status": self.proof_status.value,
            "src_file": str(self.src_file) if self.src_file else None,
            "expr": self.expr,
            "cexs": [cex.to_dict() for cex in self.cexs],
        }


class AssertCollection:
    TERMINAL = {ProofStatus.PROVEN, ProofStatus.TIMEOUT, ProofStatus.ERROR}

    def __init__(self, asserts: Iterable[AssertStat] | None = None):
        self.asserts = list(asserts or [])
        names = [assertion.name for assertion in self.asserts]
        if len(names) != len(set(names)):
            raise ValueError("assertion collection contains duplicate names")

    def empty(self) -> bool:
        return not self.asserts

    def select_one(self) -> AssertStat:
        selectable = [assertion for assertion in self.asserts
                      if assertion.proof_status not in self.TERMINAL]
        if not selectable:
            raise LookupError("assertion collection has no selectable assertion")
        return selectable[0]

    def find(self, name: str) -> AssertStat | None:
        for assertion in self.asserts:
            if assertion.name == name:
                return assertion
        return None

    def pop(self, assertion: AssertStat) -> AssertStat:
        for index, current in enumerate(self.asserts):
            if current is assertion or current.name == assertion.name:
                return self.asserts.pop(index)
        raise KeyError(f"assertion is not in collection: {assertion.name}")

    def __len__(self) -> int:
        return len(self.asserts)

    def __iter__(self):
        return iter(self.asserts)
