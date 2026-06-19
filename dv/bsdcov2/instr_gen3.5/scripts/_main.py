#!/usr/bin/env python3
from __future__ import annotations

import copy
import csv
import logging
import re
import sys
from pathlib import Path
from typing import Any

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

from _assert_stat import AssertCollection, AssertStat, ProofStatus
from _cov_collection import CovCollection, CovData, find_ucds, merged_report
from _flow_args import FlowArgs, FlowRuntime, atomic_json
from _fsdb_wrapper import FSDBWrapper
from _jgenv import JGEnv
from _runtime_timer import RuntimeTimer
from _sim_bin import SimBin, candidate_signature
from _sim_tool import SimTool

TARGETS_EXTRACT_DIR = SCRIPT_DIR / "targets/extract"
sys.path.insert(0, str(TARGETS_EXTRACT_DIR))
from _sig_note import SigSet  # type: ignore

TERMINAL = {"proven", "achieved", "retry_exhausted", "timeout", "error"}
METRICS = ("block", "branch", "statement", "expression", "toggle", "fsm", "covergroup")
logger = logging.getLogger(__name__)
PREFERRED_ASSERTION_HASHES = (
    "30580b05e2",  # id_stage_i.controller_i
    "fdc807b957",  # id_stage_i.decoder_i
    "cd81751b83",  # id_stage_i
    "82e0a9c345",  # if_stage_i
    "90f34ed154",  # ibex_top.u_ibex_core
    "25d34ae008",  # load_store_unit_i
)
ASSERT_KEY_RE = re.compile(
    r"^(?P<hier>.*)\.u_bsdcov_sig_note_epoch_\d+_sig_note_"
    r"(?P<hash>[0-9a-fA-F]+)\.AST_BSDCOV_merge_(?P=hash)$"
)


IBEX_PARAMETERS = {
    "RV32E": 0,
    "RV32M": "{ibex_pkg::RV32MSingleCycle}",
    "RV32B": "{ibex_pkg::RV32BOTEarlGrey}",
    "RV32ZC": "{ibex_pkg::RV32ZcaZcbZcmp}",
    "RegFile": "{ibex_pkg::RegFileFF}",
    "BranchTargetALU": 1,
    "WritebackStage": 1,
    "ICache": 1,
    "ICacheECC": 1,
    "ICacheScramble": 1,
    "ICacheTweakInfection": 0,
    "BranchPredictor": 0,
    "DbgTriggerEn": 1,
    "DbgHwBreakNum": 1,
    "SecureIbex": 1,
    "LockstepOffset": 1,
    "PMPEnable": 1,
    "PMPGranularity": 0,
    "PMPNumRegions": 16,
    "MHPMCounterNum": 10,
    "MHPMCounterWidth": 32,
    "DmBaseAddr": "32'h1A110000",
    "DmAddrMask": "32'h00000FFF",
    "DmHaltAddr": "32'h80000000",
    "DmExceptionAddr": "32'h80000008",
}


def save(runtime: FlowRuntime) -> None:
    atomic_json(runtime.paths.run_dir / "state.json", runtime.state)
    path = runtime.paths.assert_dir / "status.csv"
    path.parent.mkdir(parents=True, exist_ok=True)
    fields = ["property", "status", "retries", "timeouts", "last_reason"]
    with path.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=fields, extrasaction="ignore")
        writer.writeheader()
        for name, value in sorted(runtime.state.get("properties", {}).items()):
            writer.writerow({"property": name, **value})


def stable_assertion_key(name: str) -> str:
    match = ASSERT_KEY_RE.match(name)
    if not match:
        return name
    return f"{match.group('hier')}::sig_note_{match.group('hash').lower()}"


def assertion_priority(name: str) -> tuple[int, str]:
    lowered = name.lower()
    for index, value in enumerate(PREFERRED_ASSERTION_HASHES):
        if value in lowered:
            return index, name
    return len(PREFERRED_ASSERTION_HASHES), name


def property_state(runtime: FlowRuntime, assertion: AssertStat) -> dict[str, Any]:
    return runtime.state.setdefault("properties", {}).setdefault(assertion.name, {
        "status": "pending", "retries": 0, "timeouts": 0,
        "last_reason": "", "cexs": [],
    })


def restore_coverage(runtime: FlowRuntime) -> CovCollection:
    points = []
    for row in runtime.state.get("coverage_rows", []):
        if "coverage" in row:
            coverage = CovData.from_dict(row["coverage"])
        else:
            coverage = CovData.from_dict({
                metric: {key: row[f"{metric}_{key}"]
                         for key in ("covered", "total", "percent")}
                for metric in METRICS
            })
        points.append((int(row["bin_instruction_count"]), coverage))
    return CovCollection(points)


def record_coverage(runtime: FlowRuntime, collection: CovCollection,
                    num_instr: int, coverage: CovData) -> None:
    collection.append([num_instr, coverage])
    runtime.state["coverage_rows"] = [
        {"bin_instruction_count": count, "coverage": value.to_dict()}
        for count, value in collection.data
    ]
    timer = RuntimeTimer(runtime)
    with timer.stage("CoverageCollection", "coverage_curve_report"):
        collection.report(runtime.paths.coverage, runtime.paths.run_dir.name)
    save(runtime)


def restore_asserts(runtime: FlowRuntime, jgenv: JGEnv) -> AssertCollection:
    stored = runtime.state.get("properties", {})
    if stored:
        return AssertCollection(
            AssertStat(name) for name, value in sorted(
                stored.items(), key=lambda item: assertion_priority(item[0]))
            if value.get("status", "pending") not in TERMINAL
        )
    asserts = jgenv.get_asserts()
    proven_keys = set(runtime.state.get("proven_assertion_keys", []))
    if proven_keys:
        kept: list[AssertStat] = []
        skipped: list[str] = []
        for assertion in asserts:
            key = stable_assertion_key(assertion.name)
            if key in proven_keys:
                skipped.append(assertion.name)
            else:
                kept.append(assertion)
        if skipped:
            runtime.state["skipped_proven_assertions"] = (
                int(runtime.state.get("skipped_proven_assertions", 0)) + len(skipped)
            )
            runtime.state.setdefault("skipped_proven_assertion_names", []).extend(skipped)
            logger.info("skipped %d previously proven assertion(s)", len(skipped))
        asserts = AssertCollection(sorted(kept, key=lambda assertion: assertion_priority(assertion.name)))
    else:
        asserts = AssertCollection(sorted(asserts, key=lambda assertion: assertion_priority(assertion.name)))
    runtime.state["properties"] = {
        assertion.name: {"status": "pending", "retries": 0, "timeouts": 0,
                         "last_reason": "", "cexs": []}
        for assertion in asserts
    }
    save(runtime)
    return asserts


def remaining_disappears(sigset: SigSet) -> int:
    return sum(len(signal.disappear_vals) for signal in sigset.signals)


def has_active_properties(runtime: FlowRuntime) -> bool:
    return any(
        value.get("status", "pending") not in TERMINAL
        for value in runtime.state.get("properties", {}).values()
    )


def make_sigset(runtime: FlowRuntime, sim_fsdb: FSDBWrapper) -> SigSet:
    return SigSet(
        fsdb=sim_fsdb.filepath,
        dut_f=runtime.paths.root / "scripts/fml_template/dut.f",
        dut_top="ibex_top",
        sim_dut_top="core_ibex_tb_top.dut.u_ibex_top",
        parameters=IBEX_PARAMETERS,
        defines=["SYNTHESIS"],
    )


def write_epoch_targets(runtime: FlowRuntime, sigset: SigSet) -> tuple[Path | None, dict[str, Any]]:
    epoch = int(runtime.state.get("epoch", 0)) + 1
    total = remaining_disappears(sigset)
    sample_num = runtime.config.target_sample_num
    if total == 0:
        return None, {
            "epoch": epoch,
            "remaining_disappeared_values": 0,
            "selected_disappeared_values": 0,
        }
    select_num = 0 if sample_num == -1 else min(sample_num, total)
    selected = sigset.select_disappears(select_num, seed=runtime.config.seed + epoch)
    selected_total = remaining_disappears(selected)
    sva = runtime.paths.assert_dir / f"epoch_{epoch:04d}.sig_note.sv"
    filelist = runtime.paths.assert_dir / f"epoch_{epoch:04d}.sig_note.f"
    selected.dump_sva(sva)
    filelist.write_text(str(sva.resolve()) + "\n", encoding="utf-8")
    summary = {
        "epoch": epoch,
        "remaining_disappeared_values": total,
        "selected_disappeared_values": selected_total,
        "signal_count": len(sigset.signals),
        "diagnostics_count": len(sigset.diagnostics),
        "sva": str(sva),
        "filelist": str(filelist),
    }
    runtime.state.setdefault("target_epochs", []).append(summary)
    save(runtime)
    return filelist, summary


def cumulative_coverage(runtime: FlowRuntime, sim_tool: SimTool) -> CovData:
    accepted_ucds = [
        ucd for relative in runtime.state["accepted_runs"]
        for ucd in find_ucds(runtime.paths.run_dir / relative)
    ]
    iteration = int(runtime.state["iteration"])
    timer = RuntimeTimer(runtime)
    with timer.stage("CoverageCollection", "imc_cumulative_merge", iteration=iteration):
        report = merged_report(runtime.paths.ibex,
                               runtime.paths.iterations / f"{iteration:04d}",
                               accepted_ucds + sim_tool.find_ucds(), iteration)
    return CovData.from_report(report)


def initial_sim(runtime: FlowRuntime, sim_tool: SimTool, init_bin: SimBin,
                coverage_collection: CovCollection) -> tuple[FSDBWrapper, CovData | None]:
    if runtime.state["accepted_runs"]:
        accepted_run = runtime.paths.run_dir / runtime.state["accepted_runs"][-1]
        stored_coverage = runtime.state.get("coverage") or None
        return (FSDBWrapper.from_simulation(accepted_run / "fsdb/eval.fsdb"),
                CovData.from_dict(stored_coverage) if stored_coverage else None)
    sim_fsdb, coverage = sim_tool.sim(init_bin)
    runtime.state["accepted_runs"] = [
        str(sim_tool.last_run_dir.relative_to(runtime.paths.run_dir))
    ]
    if coverage is not None:
        runtime.state["coverage"] = coverage.to_dict()
        record_coverage(runtime, coverage_collection, init_bin.get_instr_num(), coverage)
    else:
        runtime.state["coverage"] = {}
        save(runtime)
    return sim_fsdb, coverage


def record_proof(runtime: FlowRuntime, assertion: AssertStat) -> dict[str, Any]:
    state = property_state(runtime, assertion)
    existing_cexs = list(state.get("cexs", []))
    new_cexs = [str(cex.fsdb.filepath) for cex in assertion.cexs]
    merged_cexs = existing_cexs + [cex for cex in new_cexs if cex not in existing_cexs]
    state.update(status=assertion.proof_status.value,
                 last_reason=assertion.proof_status.value,
                 cexs=merged_cexs)
    save(runtime)
    return state


def build_candidate(runtime: FlowRuntime, instr_bin: SimBin,
                    assertion: AssertStat) -> tuple[SimBin | None, str]:
    try:
        instr_seq = assertion.latest_cex.to_instr_seq() if assertion.latest_cex else []
    except RuntimeError as exc:
        return None, f"invalid CEX: {exc}"
    signature = candidate_signature(instr_seq) if instr_seq else ""
    if not instr_seq or signature in runtime.state["seen_candidates"]:
        return None, "invalid, empty, or duplicate candidate"
    candidate_bin = instr_bin.copy()
    candidate_bin.add_instr_seq(instr_seq)
    if len(candidate_bin.generated_instrs()) > runtime.config.max_generated_words:
        return None, "generated-word limit would be exceeded"
    runtime.state["seen_candidates"].append(signature)
    save(runtime)
    return candidate_bin, ""


def continuation_probe(runtime: FlowRuntime, sim_tool: SimTool,
                       candidate_bin: SimBin) -> tuple[bool, str, dict[str, Any]]:
    probe_bin = candidate_bin.copy()
    probe_addr = probe_bin.next_addr()
    probe_bin.add_instr_seq([(probe_addr, 0x00000013)])
    probe_dir = (runtime.paths.iterations /
                 f"{int(runtime.state['iteration']):04d}" / "probe_continuation")
    try:
        sim_tool.sim_at(probe_bin, probe_dir, update_last=False)
    except Exception as exc:
        return False, f"continuation probe failed: {exc}", {}
    result_path = probe_dir / "result.json"
    result = {}
    if result_path.is_file():
        import json
        result = json.loads(result_path.read_text())
    retired = result.get("retirement_marker")
    next_fetch = result.get("next_fetch_marker")
    error_handled = result.get("error_handled_marker")
    last_pc = result.get("last_retired_pc")
    ok = bool(retired and next_fetch and not error_handled and last_pc == f"0x{probe_addr:08x}")
    if ok:
        return True, "continuation probe passed", result
    return False, (
        "continuation probe did not retire appended nop"
        f" (retired={retired} next_fetch={next_fetch}"
        f" error_handled={error_handled} last_pc={last_pc})"
    ), result


def accept_candidate(runtime: FlowRuntime, sim_tool: SimTool, jgenv: JGEnv,
                     assertion: AssertStat, candidate_bin: SimBin,
                     sim_fsdb: FSDBWrapper, coverage: CovData | None,
                     reason: str = "coverage increased") -> SimBin:
    runtime.state["accepted"] += 1
    accepted_bin = runtime.paths.images / f"accepted_{runtime.state['accepted']:04d}.bin"
    candidate_bin.gen_file(accepted_bin)
    runtime.state["current_image"] = str(accepted_bin.relative_to(runtime.paths.run_dir))
    runtime.state["accepted_runs"].append(
        str(sim_tool.last_run_dir.relative_to(runtime.paths.run_dir)))
    if coverage is not None:
        runtime.state["coverage"] = coverage.to_dict()
    property_state(runtime, assertion).update(
        status="achieved", last_reason=reason)
    jgenv.imem.update(candidate_bin)
    jgenv.rst.update(sim_fsdb)
    save(runtime)
    return candidate_bin


def reject_candidate(runtime: FlowRuntime, sim_tool: SimTool,
                     assertion: AssertStat, reason: str) -> None:
    state = property_state(runtime, assertion)
    state["retries"] += 1
    state["last_reason"] = reason
    if not reason.startswith("invalid"):
        sim_tool.mark_rejected()
    assertion.set_status(ProofStatus.PENDING)
    save(runtime)


def deprecate(runtime: FlowRuntime, asserts: AssertCollection,
              deprecated_asserts: list[AssertStat], assertion: AssertStat,
              retry: int) -> None:
    state = property_state(runtime, assertion)
    if retry >= runtime.config.retry_limit:
        state.update(status="retry_exhausted", last_reason="retry_exhausted")
    elif assertion.is_proven():
        state.update(status="proven", last_reason="proven")
        key = stable_assertion_key(assertion.name)
        keys = runtime.state.setdefault("proven_assertion_keys", [])
        if key not in keys:
            keys.append(key)
    elif assertion.is_timeout():
        state.update(status="timeout", last_reason="timeout")
    elif assertion.proof_status is ProofStatus.ERROR:
        state.update(status="error", last_reason="Jasper error")
    deprecated_asserts.append(asserts.pop(assertion))
    save(runtime)


def finalize(runtime: FlowRuntime, instr_bin: SimBin,
             coverage_collection: CovCollection,
             deprecated_asserts: list[AssertStat]) -> None:
    final_bin = runtime.paths.images / "final.bin"
    instr_bin.gen_file(final_bin)
    instr_bin.write_sequence_csv(runtime.paths.images / "final.instructions.csv")
    timer = RuntimeTimer(runtime)
    coverage_curve_csv = None
    coverage_curve_svg = None
    if coverage_collection.data:
        with timer.stage("CoverageCollection", "final_coverage_curve_report"):
            coverage_curve_csv, coverage_curve_svg = coverage_collection.report(
                runtime.paths.coverage, runtime.paths.run_dir.name)
    runtime.state["status"] = "complete"
    save(runtime)
    atomic_json(runtime.paths.final / "run_summary.json", {
        "status": "complete",
        "accepted": runtime.state["accepted"],
        "iterations": runtime.state["iteration"],
        "generated_words": len(instr_bin.generated_instrs()),
        "deprecated_assertions": len(deprecated_asserts),
        "proven_assertion_keys": runtime.state.get("proven_assertion_keys", []),
        "skipped_proven_assertions": runtime.state.get("skipped_proven_assertions", 0),
        "properties": runtime.state["properties"],
        "coverage": runtime.state["coverage"],
        "final_bin": str(final_bin),
        "coverage_curve_csv": str(coverage_curve_csv) if coverage_curve_csv else None,
        "coverage_curve_svg": str(coverage_curve_svg) if coverage_curve_svg else None,
    })
    latest = runtime.paths.run_dir.parent / "latest"
    latest.unlink(missing_ok=True)
    latest.symlink_to(runtime.paths.run_dir.name)


def main() -> int:
    logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")
    flow_args = FlowArgs()
    runtime = flow_args.prepare(flow_args.arguments())
    init_bin = (SimBin.from_file(runtime.paths.run_dir / runtime.state["current_image"])
                if runtime.resume else SimBin.from_init_bin(Path(runtime.config.init_bin)))
    if not runtime.resume:
        init_bin.gen_file(runtime.paths.images / "initial.bin")
    if runtime.dry_run:
        logger.info("Validated instruction-generation run: %s", runtime.paths.run_dir)
        return 0

    deprecated_asserts: list[AssertStat] = []
    coverage_collection = restore_coverage(runtime)
    sim_tool = SimTool(runtime)
    jgenv = JGEnv(runtime)
    timer = RuntimeTimer(runtime)
    try:
        sim_fsdb, coverage = initial_sim(runtime, sim_tool, init_bin, coverage_collection)
        instr_bin = init_bin.copy()
        with timer.stage("RTLReach", "sigset_initial_extract"):
            sigset = make_sigset(runtime, sim_fsdb)
        resume_current_epoch = runtime.resume and has_active_properties(runtime)

        while int(runtime.state.get("epoch", 0)) < runtime.config.max_epochs:
            remaining = remaining_disappears(sigset)
            if remaining == 0:
                logger.info("No disappeared signal values remain; finishing")
                break

            if resume_current_epoch:
                if not runtime.state.get("target_epochs"):
                    raise RuntimeError("resume has active properties but no target epoch")
                epoch_summary = runtime.state["target_epochs"][-1]
                epoch_filelist = Path(epoch_summary["filelist"])
                if not epoch_filelist.is_file():
                    raise FileNotFoundError(f"resume assertion filelist missing: {epoch_filelist}")
                logger.info("resuming epoch=%s remaining_disappeared_values=%s selected=%s",
                            epoch_summary["epoch"],
                            epoch_summary["remaining_disappeared_values"],
                            epoch_summary["selected_disappeared_values"])
            else:
                with timer.stage("RTLReach", "write_epoch_targets"):
                    epoch_filelist, epoch_summary = write_epoch_targets(runtime, sigset)
                if epoch_filelist is None:
                    break
                logger.info("epoch=%s remaining_disappeared_values=%s selected=%s",
                            epoch_summary["epoch"],
                            epoch_summary["remaining_disappeared_values"],
                            epoch_summary["selected_disappeared_values"])
            with timer.stage("RTLReach", "formal_env_update"):
                jgenv.imem.update(instr_bin)
                jgenv.rst.update(sim_fsdb)
            jgenv.set_epoch_assertion_filelists([epoch_filelist])
            if not resume_current_epoch:
                runtime.state["properties"] = {}
                save(runtime)
            with timer.stage("Formal", "jasper_restart_session",
                             epoch=epoch_summary["epoch"]):
                jgenv.restart_session(advance_epoch=not resume_current_epoch)
            with timer.stage("Formal", "jasper_get_asserts",
                             epoch=epoch_summary["epoch"]):
                asserts = restore_asserts(runtime, jgenv)
            resume_current_epoch = False
            if asserts.empty():
                logger.info("epoch=%s produced no Jasper-visible assertions",
                            epoch_summary["epoch"])
                break

            accepted_this_epoch = False
            deprecated_asserts_epoch: list[AssertStat] = []
            while (not asserts.empty() and
                   not accepted_this_epoch):
                a = asserts.select_one()
                retry = 0
                while retry < runtime.config.retry_limit:
                    runtime.state["iteration"] += 1
                    with timer.stage("Formal", "jasper_call_proof",
                                     iteration=runtime.state["iteration"],
                                     property=a.name):
                        jgenv.call_proof(a)
                    proof_status = {
                        ProofStatus.PROVEN: "proven",
                        ProofStatus.TIMEOUT: "timeout",
                        ProofStatus.CEX: "cex_found",
                    }.get(a.proof_status)
                    if proof_status is not None:
                        logger.info("property=%s status=%s", a.name, proof_status)
                    state = record_proof(runtime, a)
                    if a.is_proven() or a.proof_status is ProofStatus.ERROR:
                        break
                    if a.is_timeout():
                        state["timeouts"] += 1
                        state["last_reason"] = "timeout"
                        save(runtime)
                        break

                    with timer.stage("RTLReach", "build_candidate",
                                     iteration=runtime.state["iteration"],
                                     property=a.name):
                        candidate_bin, reason = build_candidate(runtime, instr_bin, a)
                    if candidate_bin is None:
                        reject_candidate(runtime, sim_tool, a, reason)
                        retry += 1
                        continue
                    candidate_fsdb, candidate_coverage = sim_tool.sim(candidate_bin)
                    candidate_sigset = None
                    accept_reason = "coverage increased"
                    if runtime.config.disable_per_sim_imc_report:
                        before_targets = remaining_disappears(sigset)
                        with timer.stage("RTLReach", "sigset_update_from_fsdb",
                                         iteration=runtime.state["iteration"]):
                            candidate_sigset = copy.deepcopy(sigset)
                            candidate_sigset.update_from_fsdb(candidate_fsdb.filepath)
                        after_targets = remaining_disappears(candidate_sigset)
                        runtime.state.setdefault("target_acceptance_checks", []).append({
                            "iteration": runtime.state["iteration"],
                            "before": before_targets,
                            "after": after_targets,
                            "delta": before_targets - after_targets,
                        })
                        save(runtime)
                        parent_next_addr = instr_bin.next_addr()
                        last_retired_pc = None
                        retirement_marker = False
                        if sim_tool.last_result is not None:
                            value = sim_tool.last_result.get("last_retired_pc")
                            if isinstance(value, str) and value.startswith("0x"):
                                last_retired_pc = int(value, 16)
                            retirement_marker = bool(
                                sim_tool.last_result.get("retirement_marker"))
                            next_fetch_marker = bool(
                                sim_tool.last_result.get("next_fetch_marker"))
                        else:
                            next_fetch_marker = False
                        suffix_progress = (
                            last_retired_pc is not None and
                            last_retired_pc >= parent_next_addr
                        )
                        candidate_makes_progress = (
                            after_targets < before_targets or suffix_progress
                        )
                        accept_candidate_now = (
                            retirement_marker and next_fetch_marker and
                            candidate_makes_progress
                        )
                        new_coverage = None
                        if not retirement_marker:
                            accept_reason = "candidate did not retire stop instruction"
                        elif not next_fetch_marker:
                            accept_reason = "candidate did not request next append address"
                        elif not candidate_makes_progress:
                            accept_reason = "no target decrease or suffix progress"
                        else:
                            probe_ok, probe_reason, probe_result = continuation_probe(
                                runtime, sim_tool, candidate_bin)
                            runtime.state.setdefault("continuation_probe_checks", []).append({
                                "iteration": runtime.state["iteration"],
                                "ok": probe_ok,
                                "reason": probe_reason,
                                "last_retired_pc": probe_result.get("last_retired_pc"),
                                "retirement_marker": probe_result.get("retirement_marker"),
                                "next_fetch_marker": probe_result.get("next_fetch_marker"),
                                "error_handled_marker": probe_result.get("error_handled_marker"),
                            })
                            save(runtime)
                            accept_candidate_now = probe_ok
                            accept_reason = (
                                "target decreased" if after_targets < before_targets else
                                "state extended"
                            ) if probe_ok else probe_reason
                    else:
                        if runtime.config.disable_per_epoch_coverage_merge:
                            new_coverage = candidate_coverage
                        else:
                            new_coverage = cumulative_coverage(runtime, sim_tool)
                        if new_coverage is None:
                            raise RuntimeError("candidate coverage is unavailable")
                        accept_candidate_now = (
                            coverage is None or new_coverage.higher_than(coverage)
                        )

                    if accept_candidate_now:
                        instr_bin = accept_candidate(runtime, sim_tool, jgenv, a,
                                                     candidate_bin, candidate_fsdb,
                                                     new_coverage, accept_reason)
                        sim_fsdb = candidate_fsdb
                        coverage = new_coverage
                        if new_coverage is not None:
                            record_coverage(runtime, coverage_collection,
                                            instr_bin.get_instr_num(), new_coverage)
                        if candidate_sigset is not None:
                            sigset = candidate_sigset
                        else:
                            with timer.stage("RTLReach", "sigset_update_from_fsdb",
                                             iteration=runtime.state["iteration"]):
                                sigset.update_from_fsdb(sim_fsdb.filepath)
                        accepted_this_epoch = True
                        break
                    reject_candidate(runtime, sim_tool, a,
                                     accept_reason if runtime.config.disable_per_sim_imc_report
                                     else "no cumulative coverage-bin increase")
                    retry += 1
                deprecate(runtime, asserts, deprecated_asserts_epoch, a, retry)
                if not accepted_this_epoch and not asserts.empty() and not jgenv.is_running():
                    with timer.stage("Formal", "jasper_restart_session",
                                     epoch=epoch_summary["epoch"],
                                     reason="after_timeout"):
                        jgenv.restart_session(advance_epoch=False)
            deprecated_asserts.extend(deprecated_asserts_epoch)
            if not accepted_this_epoch:
                logger.info("epoch=%s exhausted without accepted CEX",
                            epoch_summary["epoch"])
                break

        finalize(runtime, instr_bin, coverage_collection, deprecated_asserts)
    finally:
        jgenv.close()
    logger.info("Instruction generation complete: %s",
                runtime.paths.images / "final.bin")
    logger.info("Summary: %s", runtime.paths.final / "run_summary.json")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except KeyboardInterrupt:
        logger.warning("Interrupted; rerun with --resume --run-tag <tag>")
        raise SystemExit(130)
    except Exception as exc:
        logger.error("%s", exc)
        raise SystemExit(1)
