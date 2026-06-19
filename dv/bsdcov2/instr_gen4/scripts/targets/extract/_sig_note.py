#!/usr/bin/env python3
from __future__ import annotations

import fnmatch
import csv
import hashlib
import json
import os
import random
import re
import subprocess
import tempfile
from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterable, Sequence


DEFAULT_VERDI = Path("/home/lvzhengyang/workspace/synopsys/verdi/T-2022.06")
CPP_DIR = Path(__file__).resolve().parent / "cpp"
VAR_RE = re.compile(r"^Var:\s+\S+\s+(\S+)\s+l:(-?\d+)\s+r:(-?\d+)\s+", re.MULTILINE)
VC_RE = re.compile(r"xtag:\s*\(\d+\s+\d+\)\s+val:\s+([^\s]+)")


def _sv_identifier(value: str) -> str:
    result = re.sub(r"[^A-Za-z0-9_$]", "_", value)
    if not result or result[0].isdigit():
        result = "sig_" + result
    return result


def _normalize_bits(value: str, width: int) -> str | None:
    text = value.strip().lower().replace("_", "")
    if "'" in text:
        text = text.split("'", 1)[1]
    if text.startswith("0b"):
        text = text[2:]
    elif text.startswith("b"):
        text = text[1:]
    if any(char in text for char in "xz?"):
        return None
    if not text or any(char not in "01" for char in text):
        return None
    return text[-width:].zfill(width)


@dataclass(frozen=True)
class SigDisappear:
    name: str = ""
    val: str = ""
    enum_name: str = ""

    def __str__(self) -> str:
        return f"{self.name} == {self.val}"

    def to_state(self) -> dict[str, str]:
        return {"name": self.name, "val": self.val, "enum_name": self.enum_name}

    @classmethod
    def from_state(cls, state: dict[str, str]) -> "SigDisappear":
        return cls(
            name=state.get("name", ""),
            val=state.get("val", ""),
            enum_name=state.get("enum_name", ""),
        )


@dataclass
class SigNote:
    name: str = ""
    instance: str = ""
    module: str = ""
    width: int = 0
    type: str = ""
    rtl_instance: str = ""
    legal_values: list[SigDisappear] = field(default_factory=list)
    disappear_vals: list[SigDisappear] = field(default_factory=list)

    @property
    def hier_name(self) -> str:
        return f"{self.instance}.{self.name}" if self.instance else self.name

    @property
    def rtl_hier_name(self) -> str:
        return f"{self.rtl_instance}.{self.name}" if self.rtl_instance else self.name

    def to_state(self) -> dict:
        return {
            "name": self.name,
            "instance": self.instance,
            "module": self.module,
            "width": self.width,
            "type": self.type,
            "rtl_instance": self.rtl_instance,
            "legal_values": [value.to_state() for value in self.legal_values],
            "disappear_vals": [value.to_state() for value in self.disappear_vals],
        }

    @classmethod
    def from_state(cls, state: dict) -> "SigNote":
        note_cls = OneBit if state.get("type") == "OneBit" else FsmState
        return note_cls(
            name=state.get("name", ""),
            instance=state.get("instance", ""),
            module=state.get("module", ""),
            width=int(state.get("width", 0)),
            rtl_instance=state.get("rtl_instance", ""),
            legal_values=[SigDisappear.from_state(value)
                          for value in state.get("legal_values", [])],
            disappear_vals=[SigDisappear.from_state(value)
                            for value in state.get("disappear_vals", [])],
        )


class OneBit(SigNote):
    def __init__(self, **kwargs):
        super().__init__(type="OneBit", **kwargs)


class FsmState(SigNote):
    def __init__(self, **kwargs):
        super().__init__(type="FsmState", **kwargs)


class SigSet:
    def __init__(
        self,
        fsdb: Path,
        dut_f: Path | Sequence[Path],
        dut_top: str,
        sim_dut_top: str,
        *,
        parameters: dict[str, str | int | bool] | None = None,
        defines: Sequence[str] | None = None,
        include_dirs: Sequence[Path] | None = None,
        bind_instance: str | None = None,
        clock: str = "clk_i",
        reset: str = "rst_ni",
        reset_active_low: bool = True,
        extractor_bin: Path | None = None,
        verdi: Path = DEFAULT_VERDI,
    ):
        self.fsdb = Path(fsdb).expanduser().resolve()
        self.dut_f = [Path(item).expanduser().resolve() for item in
                      ([dut_f] if isinstance(dut_f, (str, Path)) else dut_f)]
        self.dut_top = dut_top
        self.sim_dut_top = sim_dut_top.rstrip(".")
        self.parameters = dict(parameters or {})
        self.defines = list(defines or [])
        self.include_dirs = [Path(item).expanduser().resolve() for item in (include_dirs or [])]
        self.bind_instance = bind_instance
        self.clock = clock
        self.reset = reset
        self.reset_active_low = reset_active_low
        self.extractor_bin = Path(extractor_bin).expanduser().resolve() if extractor_bin else None
        self.verdi = Path(verdi).expanduser().resolve()
        self.signals: list[SigNote] = []
        self.diagnostics: list[str] = []
        self.extract()

    @classmethod
    def _from_selection(cls, source: "SigSet", signals: Iterable[SigNote]) -> "SigSet":
        result = cls.__new__(cls)
        result.__dict__ = dict(source.__dict__)
        result.signals = list(signals)
        result.diagnostics = list(source.diagnostics)
        return result

    @classmethod
    def from_state(cls, state: dict, fsdb: Path | None = None) -> "SigSet":
        result = cls.__new__(cls)
        result.fsdb = Path(fsdb or state["fsdb"]).expanduser().resolve()
        result.dut_f = [Path(item).expanduser().resolve()
                        for item in state.get("dut_f", [])]
        result.dut_top = state.get("dut_top", "")
        result.sim_dut_top = state.get("sim_dut_top", "").rstrip(".")
        result.parameters = dict(state.get("parameters", {}))
        result.defines = list(state.get("defines", []))
        result.include_dirs = [Path(item).expanduser().resolve()
                               for item in state.get("include_dirs", [])]
        result.bind_instance = state.get("bind_instance")
        result.clock = state.get("clock", "clk_i")
        result.reset = state.get("reset", "rst_ni")
        result.reset_active_low = bool(state.get("reset_active_low", True))
        extractor = state.get("extractor_bin")
        result.extractor_bin = Path(extractor).expanduser().resolve() if extractor else None
        result.verdi = Path(state.get("verdi", DEFAULT_VERDI)).expanduser().resolve()
        result.signals = [SigNote.from_state(item) for item in state.get("signals", [])]
        result.diagnostics = list(state.get("diagnostics", []))
        return result

    def to_state(self) -> dict:
        return {
            "version": 1,
            "fsdb": str(self.fsdb),
            "dut_f": [str(path) for path in self.dut_f],
            "dut_top": self.dut_top,
            "sim_dut_top": self.sim_dut_top,
            "parameters": self.parameters,
            "defines": self.defines,
            "include_dirs": [str(path) for path in self.include_dirs],
            "bind_instance": self.bind_instance,
            "clock": self.clock,
            "reset": self.reset,
            "reset_active_low": self.reset_active_low,
            "extractor_bin": str(self.extractor_bin) if self.extractor_bin else None,
            "verdi": str(self.verdi),
            "diagnostics": list(self.diagnostics),
            "signals": [signal.to_state() for signal in self.signals],
        }

    def extract(self) -> None:
        if not self.fsdb.is_file():
            raise FileNotFoundError(f"FSDB does not exist: {self.fsdb}")
        missing = [path for path in self.dut_f if not path.is_file()]
        if missing:
            raise FileNotFoundError(f"DUT filelist does not exist: {missing[0]}")
        inventory = self._run_rtl_extractor()
        fsdb_inventory = self._fsdb_inventory()
        pending: list[tuple[SigNote, str]] = []
        for item in inventory["signals"]:
            if item["name"] in (self.clock, self.reset):
                continue
            rtl_instance = item["instance"]
            suffix = rtl_instance[len(self.dut_top):].lstrip(".") \
                if rtl_instance == self.dut_top or rtl_instance.startswith(self.dut_top + ".") \
                else rtl_instance
            sim_instance = self.sim_dut_top + (("." + suffix) if suffix else "")
            fsdb_name = f"{sim_instance}.{item['name']}"
            fsdb_width = fsdb_inventory.get(fsdb_name)
            if fsdb_width is None:
                self.diagnostics.append(f"FSDB signal not found: {fsdb_name}")
                continue
            width = int(item["width"])
            if fsdb_width != width:
                self.diagnostics.append(
                    f"FSDB width mismatch: {fsdb_name}: rtl={width} fsdb={fsdb_width}")
                continue
            values = [SigDisappear(fsdb_name, value["literal"], value.get("name", ""))
                      for value in item["values"]]
            note_cls = OneBit if item["type"] == "OneBit" else FsmState
            note = note_cls(name=item["name"], instance=sim_instance,
                            module=item["module"], width=width,
                            rtl_instance=rtl_instance, legal_values=values)
            pending.append((note, fsdb_name))
        observed_by_name = self._observed_values_batch(
            [(fsdb_name, note.width) for note, fsdb_name in pending]
        )
        notes: list[SigNote] = []
        for note, fsdb_name in pending:
            observed = observed_by_name.get(fsdb_name, set())
            note.disappear_vals = [value for value in note.legal_values
                                   if _normalize_bits(value.val, note.width) not in observed]
            notes.append(note)
        self.signals = sorted(notes, key=lambda signal: signal.hier_name)

    def update_from_fsdb(self, fsdb: Path | None = None) -> None:
        if fsdb is not None:
            self.fsdb = Path(fsdb).expanduser().resolve()
            if not self.fsdb.is_file():
                raise FileNotFoundError(f"FSDB does not exist: {self.fsdb}")
        observed_by_name = self._observed_values_batch(
            [(signal.hier_name, signal.width) for signal in self.signals]
        )
        for signal in self.signals:
            observed = observed_by_name.get(signal.hier_name, set())
            signal.disappear_vals = [value for value in signal.legal_values
                                     if _normalize_bits(value.val, signal.width) not in observed]

    def update_from_fsdb_incremental(self, fsdb: Path | None = None) -> None:
        if fsdb is not None:
            self.fsdb = Path(fsdb).expanduser().resolve()
            if not self.fsdb.is_file():
                raise FileNotFoundError(f"FSDB does not exist: {self.fsdb}")
        observed_by_name = self._observed_values_batch(
            [(signal.hier_name, signal.width) for signal in self.signals]
        )
        for signal in self.signals:
            observed = observed_by_name.get(signal.hier_name, set())
            signal.disappear_vals = [
                value for value in signal.disappear_vals
                if _normalize_bits(value.val, signal.width) not in observed
            ]

    def find_sig(self, name: str) -> SigNote | None:
        return next((signal for signal in self.signals if signal.hier_name == name), None)

    def find_sig_wildcard(self, name: str) -> list[SigNote]:
        return [signal for signal in self.signals if fnmatch.fnmatchcase(signal.hier_name, name)]

    def random_select_disappears(self, N: int, seed: int | None = None) -> "SigSet":
        return self.select_disappears(N, seed=seed)

    def select_disappears(self, N: int = 0, seed: int | None = None) -> "SigSet":
        if N < 0:
            raise ValueError("N must be non-negative")
        candidates = [(signal, missing) for signal in self.signals
                      for missing in signal.disappear_vals]
        if N == 0:
            selected = candidates
        elif N > len(candidates):
            raise ValueError(f"requested {N} missing values, only {len(candidates)} are available")
        else:
            selected = random.Random(seed).sample(candidates, N)
        by_name: dict[str, SigNote] = {}
        for signal, missing in selected:
            if signal.hier_name not in by_name:
                clone_cls = OneBit if isinstance(signal, OneBit) else FsmState
                by_name[signal.hier_name] = clone_cls(
                    name=signal.name, instance=signal.instance, module=signal.module,
                    width=signal.width, rtl_instance=signal.rtl_instance,
                    legal_values=list(signal.legal_values), disappear_vals=[])
            by_name[signal.hier_name].disappear_vals.append(missing)
        return self._from_selection(self, sorted(by_name.values(), key=lambda signal: signal.hier_name))

    def dump_sva(self, file: Path) -> Path:
        output = Path(file).expanduser().resolve()
        pairs = [(signal, missing) for signal in self.signals
                 for missing in signal.disappear_vals
                 if signal.name not in (self.clock, self.reset)]
        if not pairs:
            raise ValueError("cannot emit SVA: SigSet has no missing signal values")
        groups: dict[str, list[tuple[SigNote, SigDisappear]]] = {}
        for signal, missing in pairs:
            groups.setdefault(signal.rtl_instance, []).append((signal, missing))

        lines = ["// AUTO-GENERATED by BSD-Cov SigSet.dump_sva.", ""]
        for group_index, (rtl_instance, group_pairs) in enumerate(sorted(groups.items())):
            digest = hashlib.sha1(rtl_instance.encode("utf-8")).hexdigest()[:10]
            module_name = f"bsdcov_sig_note_{_sv_identifier(output.stem)}_{digest}"
            property_name = f"AST_BSDCOV_merge_{digest}"
            unique_signals = {signal.name: signal for signal, _ in group_pairs}
            ports: dict[str, str] = {}
            used: set[str] = {_sv_identifier(self.clock), _sv_identifier(self.reset)}
            for signal in unique_signals.values():
                base = _sv_identifier(signal.name)
                port = base
                index = 1
                while port in used:
                    port = f"{base}_{index}"
                    index += 1
                used.add(port)
                ports[signal.name] = port
            ordered = list(unique_signals.values())
            lines += [f"module {module_name} (", f"  input logic {self.clock},",
                      f"  input logic {self.reset},"]
            for index, signal in enumerate(ordered):
                comma = "," if index + 1 < len(ordered) else ""
                width = "" if signal.width == 1 else f"[{signal.width - 1}:0] "
                lines.append(f"  input logic {width}{ports[signal.name]}{comma}")
            lines += [");", ""]
            for index, (signal, missing) in enumerate(group_pairs):
                lines.append(f"  wire fire_{index} = ({ports[signal.name]} == {missing.val});")
            lines += ["", f"  {property_name}: assert property (",
                      f"    @(posedge {self.clock}) disable iff " +
                      (f"(!{self.reset})" if self.reset_active_low else f"({self.reset})"),
                      "      !(" + " || ".join(f"fire_{index}" for index in range(len(group_pairs))) + ")",
                      "  );", "", "endmodule", ""]
            lines += [f"bind {rtl_instance}",
                      f"{module_name} u_{module_name} (" ,
                      f"  .{self.clock}({self.clock}),",
                      f"  .{self.reset}({self.reset}),"]
            for index, signal in enumerate(ordered):
                comma = "," if index + 1 < len(ordered) else ""
                lines.append(f"  .{ports[signal.name]}({signal.name}){comma}")
            lines += [");", ""]
            if group_index + 1 < len(groups):
                lines.append("")
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text("\n".join(lines), encoding="utf-8")
        return output

    def _run_rtl_extractor(self) -> dict:
        executable = self.extractor_bin or self._ensure_extractor()
        request = {
            "filelists": [str(path) for path in self.dut_f],
            "top": self.dut_top,
            "parameters": {key: int(value) if isinstance(value, bool) else value
                           for key, value in self.parameters.items()},
            "defines": self.defines,
            "include_dirs": [str(path) for path in self.include_dirs],
        }
        with tempfile.TemporaryDirectory(prefix="bsdcov-sig-extract-") as directory:
            request_path = Path(directory) / "request.json"
            request_path.write_text(json.dumps(request, indent=2) + "\n", encoding="utf-8")
            process = subprocess.run([str(executable), "--request", str(request_path)],
                                     text=True, stdout=subprocess.PIPE,
                                     stderr=subprocess.PIPE, check=False)
        if process.returncode != 0:
            raise RuntimeError(f"RTL signal extraction failed:\n{process.stderr}{process.stdout}")
        return json.loads(process.stdout)

    def _ensure_extractor(self) -> Path:
        build = CPP_DIR / "build"
        executable = build / "bsdcov_sig_extract"
        if executable.is_file():
            return executable
        for command in (["cmake", "-S", str(CPP_DIR), "-B", str(build)],
                        ["cmake", "--build", str(build), "-j"]):
            process = subprocess.run(command, text=True, stdout=subprocess.PIPE,
                                     stderr=subprocess.STDOUT, check=False)
            if process.returncode != 0:
                raise RuntimeError(f"failed to build RTL signal extractor:\n{process.stdout}")
        if not executable.is_file():
            raise RuntimeError(f"extractor build did not produce {executable}")
        return executable

    def _tool_environment(self) -> dict[str, str]:
        environment = os.environ.copy()
        environment["VERDI_HOME"] = str(self.verdi)
        ugo = self.verdi / "share/ugo/linux64/bin/ugo_dist/ugo"
        old = environment.get("LD_LIBRARY_PATH", "")
        environment["LD_LIBRARY_PATH"] = f"{ugo}:{old}" if old else str(ugo)
        return environment

    def _run_fsdbdebug(self, args: list[str]) -> str:
        tool = self.verdi / "platform/linux64/bin/fsdbdebug"
        process = subprocess.run([str(tool), *args, str(self.fsdb)],
                                 env=self._tool_environment(), text=True,
                                 stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                 check=False)
        if process.returncode != 0:
            raise RuntimeError(f"fsdbdebug failed:\n{process.stdout}")
        return process.stdout

    def _fsdbreport_path(self, signal: str) -> str:
        return "/" + signal.replace(".", "/")

    def _run_fsdbreport_values(self, signals: Sequence[tuple[str, int]],
                               batch_index: int) -> dict[str, set[str]]:
        if not signals:
            return {}
        tool = self.verdi / "platform/linux64/bin/fsdbreport"
        with tempfile.TemporaryDirectory(prefix=f"bsdcov-fsdbreport-{batch_index}-") as directory:
            csv_path = Path(directory) / "values.csv"
            aliases = [f"s{idx}" for idx in range(len(signals))]
            command = [str(tool), str(self.fsdb), "-s"]
            for alias, (signal, _) in zip(aliases, signals):
                command += [self._fsdbreport_path(signal), "-a", alias, "-of", "b"]
            command += ["-csv", "-o", str(csv_path), "-nolog"]
            process = subprocess.run(command, env=self._tool_environment(), text=True,
                                     stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                     check=False)
            if process.returncode != 0 or not csv_path.is_file():
                raise RuntimeError(f"fsdbreport failed:\n{process.stdout}")
            if re.search(r"signal not found|not found, abort|read fsdb failed", process.stdout, re.I):
                raise RuntimeError(f"fsdbreport reported a missing signal:\n{process.stdout}")
            with csv_path.open(newline="", encoding="utf-8", errors="ignore") as fd:
                rows = list(csv.reader(fd))
        result = {signal: set() for signal, _ in signals}
        if not rows:
            return result
        header = [item.strip() for item in rows[0]]
        if header[1:] != aliases:
            raise RuntimeError(f"unexpected fsdbreport header: {header}")
        for row in rows[1:]:
            for index, (signal, width) in enumerate(signals):
                if index + 1 >= len(row):
                    continue
                bits = _normalize_bits(row[index + 1], width)
                if bits is not None:
                    result[signal].add(bits)
        return result

    def _observed_values_batch(self, signals: Sequence[tuple[str, int]],
                               batch_size: int = 128) -> dict[str, set[str]]:
        result = {signal: set() for signal, _ in signals}
        for start in range(0, len(signals), batch_size):
            batch = signals[start:start + batch_size]
            for signal, values in self._run_fsdbreport_values(batch, start // batch_size).items():
                result[signal].update(values)
        return result

    def _fsdb_inventory(self) -> dict[str, int]:
        hierarchy = self._run_fsdbdebug(["-hier_tree"])
        return {name: abs(int(left) - int(right)) + 1
                for name, left, right in VAR_RE.findall(hierarchy)
                if name == self.sim_dut_top or name.startswith(self.sim_dut_top + ".")}

    def _observed_values(self, signal: str, width: int) -> set[str]:
        output = self._run_fsdbdebug(["-vc", "-vname", signal])
        return {bits for raw in VC_RE.findall(output)
                if (bits := _normalize_bits(raw, width)) is not None}
