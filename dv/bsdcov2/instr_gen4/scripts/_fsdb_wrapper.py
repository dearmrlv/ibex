#!/usr/bin/env python3
from __future__ import annotations

import os
import re
import subprocess
from bisect import bisect_right
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import Any, Iterable

DEFAULT_VERDI = Path("/home/lvzhengyang/workspace/synopsys/verdi/T-2022.06")
VC_RE = re.compile(r"xtag:\s*\((\d+)\s+(\d+)\)\s+val:\s+([^\s]+)")
TOKEN_RE = re.compile(r"[A-Za-z_$][A-Za-z0-9_$.\\\[\]:/]*")


class FSDBSource(str, Enum):
    SIM = "sim"
    FML = "fml"


@dataclass(frozen=True, order=True)
class FSDBTime:
    major: int
    minor: int

    def __post_init__(self) -> None:
        if self.major < 0 or self.minor < 0:
            raise ValueError(f"FSDB time must be non-negative: ({self.major}, {self.minor})")


class FSDBWave:
    def __init__(self, changes: Iterable[tuple[FSDBTime, str]]):
        ordered = sorted(changes, key=lambda item: item[0])
        if not ordered:
            raise ValueError("FSDB wave has no value changes")
        self.times = [item[0] for item in ordered]
        self.values = [item[1].lower() for item in ordered]

    @property
    def changes(self) -> list[tuple[FSDBTime, str]]:
        return list(zip(self.times, self.values))

    def at(self, time: FSDBTime) -> str | None:
        index = bisect_right(self.times, time) - 1
        return self.values[index] if index >= 0 else None


class FSDBWrapper:
    def __init__(self, filepath: Path, source: FSDBSource | str,
                 verdi: Path = DEFAULT_VERDI,
                 snapshot_time_ps: int | None = None):
        self.filepath = filepath.expanduser().resolve()
        try:
            self.source = source if isinstance(source, FSDBSource) else FSDBSource(source)
        except ValueError as exc:
            raise ValueError(f"unknown FSDB source: {source!r}") from exc
        self.verdi = verdi.expanduser().resolve()
        if snapshot_time_ps is not None and snapshot_time_ps < 0:
            raise ValueError(f"snapshot_time_ps must be non-negative: {snapshot_time_ps}")
        self.snapshot_time_ps = snapshot_time_ps
        if self.filepath.suffix.lower() != ".fsdb":
            raise ValueError(f"FSDB path must end in .fsdb: {self.filepath}")
        self.require_exists()

    @classmethod
    def from_simulation(cls, filepath: Path, verdi: Path = DEFAULT_VERDI,
                        snapshot_time_ps: int | None = None) -> "FSDBWrapper":
        return cls(filepath, FSDBSource.SIM, verdi, snapshot_time_ps=snapshot_time_ps)

    @classmethod
    def from_formal(cls, filepath: Path, verdi: Path = DEFAULT_VERDI) -> "FSDBWrapper":
        return cls(filepath, FSDBSource.FML, verdi)

    @classmethod
    def from_dict(cls, value: dict[str, Any]) -> "FSDBWrapper":
        return cls(Path(value["filepath"]), FSDBSource(value["source"]),
                   Path(value.get("verdi", DEFAULT_VERDI)),
                   snapshot_time_ps=value.get("snapshot_time_ps"))

    @property
    def from_sim(self) -> bool:
        return self.source is FSDBSource.SIM

    @property
    def from_fml(self) -> bool:
        return self.source is FSDBSource.FML

    def exists(self) -> bool:
        return self.filepath.is_file()

    def require_exists(self) -> Path:
        if not self.filepath.is_file():
            raise FileNotFoundError(f"FSDB does not exist: {self.filepath}")
        return self.filepath

    def to_dict(self) -> dict[str, str | int]:
        result: dict[str, str | int] = {
            "filepath": str(self.filepath),
            "source": self.source.value,
            "verdi": str(self.verdi),
        }
        if self.snapshot_time_ps is not None:
            result["snapshot_time_ps"] = self.snapshot_time_ps
        return result

    def hierarchy(self, cwd: Path | None = None) -> str:
        return self._debug(["-hier_tree", str(self.filepath)], cwd)

    def resolve_signal(self, *suffixes: str, cwd: Path | None = None) -> str:
        if not suffixes:
            raise ValueError("at least one signal suffix is required")
        hierarchy = self.hierarchy(cwd)
        tokens = {token.strip(";,()") for token in TOKEN_RE.findall(hierarchy)}
        matches = sorted(token for token in tokens
                         if any(token.endswith(suffix) for suffix in suffixes))
        if len(matches) != 1:
            raise RuntimeError(f"expected one FSDB signal ending in {suffixes}; found {matches}")
        return matches[0]

    def read_changes(self, signal: str, cwd: Path | None = None) -> list[tuple[FSDBTime, str]]:
        text = self._debug(["-vc", "-vname", signal, str(self.filepath)], cwd)
        changes = [(FSDBTime(int(major), int(minor)), value.lower())
                   for major, minor, value in VC_RE.findall(text)]
        if not changes:
            raise RuntimeError(f"no value changes for FSDB signal {signal}")
        return changes

    def read_wave(self, *suffixes: str, cwd: Path | None = None) -> FSDBWave:
        signal = self.resolve_signal(*suffixes, cwd=cwd)
        return FSDBWave(self.read_changes(signal, cwd=cwd))

    def _debug(self, args: list[str], cwd: Path | None) -> str:
        tool = self.verdi / "platform/linux64/bin/fsdbdebug"
        if not tool.is_file():
            raise FileNotFoundError(f"fsdbdebug not found: {tool}")
        work_dir = (cwd or self.filepath.parent).expanduser().resolve()
        work_dir.mkdir(parents=True, exist_ok=True)
        process = subprocess.run([str(tool), *args], cwd=work_dir,
                                 env=self._environment(), text=True,
                                 stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                 check=False)
        if process.returncode != 0:
            raise RuntimeError(f"fsdbdebug failed with exit code {process.returncode}:\n"
                               f"{process.stdout}")
        return process.stdout

    def _environment(self) -> dict[str, str]:
        environment = os.environ.copy()
        ugo = self.verdi / "share/ugo/linux64/bin/ugo_dist/ugo"
        old = environment.get("LD_LIBRARY_PATH", "")
        environment["VERDI_HOME"] = str(self.verdi)
        environment["LD_LIBRARY_PATH"] = f"{ugo}:{old}" if old else str(ugo)
        return environment
