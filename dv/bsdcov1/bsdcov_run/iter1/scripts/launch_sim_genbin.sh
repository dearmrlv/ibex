#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ITER_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BSDCOV1_DIR="$(cd "$ITER_DIR/../.." && pwd)"
IBEX_ROOT="$(cd "$BSDCOV1_DIR/../.." && pwd)"
CORE_IBEX_DIR="$IBEX_ROOT/dv/uvm/core_ibex"
BIN="${BSDCOV_GENBIN_BIN:-$ITER_DIR/bin4sim/fsdb_image.bin}"
SIM_DIR="${BSDCOV_GENBIN_SIM_DIR:-$ITER_DIR/sim_genbin}"
TB_OUT="$SIM_DIR/ibex_dv_out"
TB_DIR="$TB_OUT/build/tb"
XRUN="${BSDCOV_XRUN:-/home/lvzhengyang/workspace/cadence/xrun}"
SEED="${BSDCOV_SEED:-1}"
TIMEOUT_S="${BSDCOV_XRUN_TIMEOUT_S:-300}"
TIMEOUT_CYCLES="${BSDCOV_GENBIN_TIMEOUT_CYCLES:-10000}"
REGION_FILELIST="${BSDCOV_GENBIN_FILELIST:-$ITER_DIR/bsdproj/results/bsdcov.f}"
COVERAGE_DIR="$SIM_DIR/coverage"
COVFILE="$COVERAGE_DIR/cov.ccf"

if [[ ! -s "$BIN" ]]; then
  echo "ERROR: generated binary does not exist or is empty: $BIN" >&2
  echo "Run ./scripts/gen_bin.sh first." >&2
  exit 2
fi
if [[ ! -x "$XRUN" ]]; then
  echo "ERROR: xrun is not executable: $XRUN" >&2
  exit 2
fi
if [[ ! -s "$REGION_FILELIST" ]]; then
  echo "ERROR: BSD-Cov region filelist does not exist or is empty: $REGION_FILELIST" >&2
  exit 2
fi
while IFS= read -r source; do
  [[ -z "$source" || "$source" == \#* ]] && continue
  if [[ ! -f "$source" ]]; then
    echo "ERROR: region bind source listed by $REGION_FILELIST does not exist: $source" >&2
    exit 2
  fi
done < "$REGION_FILELIST"

rm -rf "$SIM_DIR"
mkdir -p "$SIM_DIR/logs" "$SIM_DIR/fsdb" "$COVERAGE_DIR"

cat > "$COVFILE" <<EOF
include_ccf $IBEX_ROOT/dv/uvm/core_ibex/xcelium_2009_cover.ccf
EOF
while IFS= read -r source; do
  [[ -z "$source" || "$source" == \#* ]] && continue
  module_name="$(sed -nE 's/^[[:space:]]*module[[:space:]]+([A-Za-z_][A-Za-z0-9_$]*).*/\1/p' "$source" | head -1)"
  if [[ -z "$module_name" ]]; then
    echo "ERROR: cannot find module declaration in region bind source: $source" >&2
    exit 2
  fi
  echo "deselect_coverage -betf -module $module_name" >> "$COVFILE"
done < "$REGION_FILELIST"
echo "deselect_coverage -remove_empty_instances" >> "$COVFILE"

pushd "$CORE_IBEX_DIR" >/dev/null
# shellcheck disable=SC1091
source ./setup_env.sh
popd >/dev/null

export IBEX_ROOT PRJ_DIR="$IBEX_ROOT" LOWRISC_IP_DIR="$IBEX_ROOT/vendor/lowrisc_ip"
export DUT_TOP=ibex_top dv_root="$IBEX_ROOT/vendor/lowrisc_ip/dv"
export EXTRA_COSIM_CFLAGS="${EXTRA_COSIM_CFLAGS:-}"
export CADENCE_XRUN="$XRUN"
export VERDI_HOME="${VERDI_HOME:-/home/lvzhengyang/workspace/synopsys/verdi/T-2022.06}"
export BSD_COV_EXTRA_XRUN_COMPILE_OPTS="-access +rwc -loadpli1 debpli:novas_pli_boot"
export BSD_COV_EXTRA_XRUN_FILELISTS="$REGION_FILELIST"
export BSD_COV_XRUN_COVFILE="$COVFILE"
unset BSDCOV_REUSE_TB_DIR BSDCOV_PROJECT_DIR BSDCOV_SIM_DIR

set +e
(
  cd "$CORE_IBEX_DIR"
  make -B --keep-going GOAL=rtl_tb_compile OUT="$TB_OUT" \
    IBEX_CONFIG=opentitan SIMULATOR=xlm ISS=spike TEST=empty ITERATIONS=1 \
    SEED="$SEED" WAVES=0 COV=1 VERBOSE=0
) >"$SIM_DIR/logs/rtl_tb_compile.log" 2>&1
compile_rc=$?
set -e
if [[ "$compile_rc" -ne 0 ]]; then
  printf '{"status":"failed","stage":"compile","exit_code":%d}\n' "$compile_rc" > "$SIM_DIR/result.json"
  echo "ERROR: testbench compilation failed; see $SIM_DIR/logs/rtl_tb_compile.log" >&2
  exit "$compile_rc"
fi

UCLI="$SIM_DIR/xrun.ucli.cmd"
cat > "$UCLI" <<EOF
call fsdbDumpfile {"$SIM_DIR/fsdb/genbin.fsdb"}
call fsdbDumpvars {0} {core_ibex_tb_top} {"+mda"} {"+struct"} {"+parameter"}
call fsdbDumpSVA
set assert_output_stop_level none
set assert_stop_level never
run
exit
EOF

set +e
(
  cd "$CORE_IBEX_DIR"
  timeout --signal=TERM --kill-after=15s "${TIMEOUT_S}s" \
    "$XRUN" -64bit -R -xmlibdirpath "$TB_DIR" -licqueue \
    -svseed "$SEED" -svrnc rand_struct -nokey -l "$SIM_DIR/rtl_sim.log" \
    +UVM_TESTNAME=core_ibex_base_test +UVM_VERBOSITY=UVM_LOW \
    +bin="$BIN" +signature_addr=8ffffffc +test_timeout_s=60 \
    +timeout_in_cycles="$TIMEOUT_CYCLES" \
    +disable_cosim=1 +ibex_tracer_file_base="$SIM_DIR/trace_core" \
    +max_quit_count=0 +UVM_MAX_QUIT_COUNT=0,NO \
    -covmodeldir "$COVERAGE_DIR/model" -covworkdir "$COVERAGE_DIR" \
    -covscope coverage -covtest "genbin.$SEED" -covoverwrite \
    +enable_ibex_fcov=1 -covfile "$COVFILE" -input "$UCLI"
) >"$SIM_DIR/logs/launch_rtl.log" 2>&1
xrun_rc=$?
set -e
echo "$xrun_rc" > "$SIM_DIR/xrun.exit_code"

mapfile -t coverage_ucds < <(find "$COVERAGE_DIR" -type f -name '*.ucd' | sort)
if [[ "${#coverage_ucds[@]}" -gt 0 ]]; then
  python3 - "$IBEX_ROOT" "$SIM_DIR" "${coverage_ucds[@]}" <<'PY'
import shutil
import sys
from pathlib import Path

ibex_root = Path(sys.argv[1]).resolve()
sim_dir = Path(sys.argv[2]).resolve()
ucds = [Path(arg).resolve() for arg in sys.argv[3:]]
scripts = ibex_root / "dv/bsdcov_whole_mc/scripts"
sys.path.insert(0, str(scripts))
from _launch_sim import _run_imc_report  # noqa: E402

report = _run_imc_report(
    repo_root=ibex_root,
    run_dir=sim_dir,
    prefix_idx=1,
    ucds=ucds,
    module="ibex_top",
    dry_run=False,
)
if report is None or not report.exists():
    raise RuntimeError("IMC did not produce a coverage report")
coverage = sim_dir / "coverage"
shutil.copy2(report, coverage / "cov_report.txt")
full_report_dir = coverage / "report_full"
if full_report_dir.exists():
    shutil.rmtree(full_report_dir)
shutil.copytree(report.parent, full_report_dir)
lines = report.read_text(encoding="utf-8", errors="ignore").splitlines()
dut_lines = [line for line in lines if line.startswith("Legend:") or
             line.startswith("name ") or line.startswith("---") or
             line.startswith("ibex_top ")]
(coverage / "cov_report.txt").write_text("\n".join(dut_lines) + "\n", encoding="utf-8")
cg_report = report.with_name("cov_report_cg.txt")
if cg_report.exists():
    shutil.copy2(cg_report, coverage / "cov_report_cg.txt")
PY
fi

python3 - "$SIM_DIR" "$BIN" "$REGION_FILELIST" "$xrun_rc" <<'PY'
import json
import re
import sys
from pathlib import Path

sim = Path(sys.argv[1])
binary = Path(sys.argv[2]).resolve()
region_filelist = Path(sys.argv[3]).resolve()
rc = int(sys.argv[4])
logs = [sim / "rtl_sim.log", sim / "logs/launch_rtl.log"]
text = "\n".join(path.read_text(encoding="utf-8", errors="ignore")
                 for path in logs if path.exists())
traces = [path for path in sorted(sim.glob("trace_core*.log")) if path.stat().st_size]
fsdb = sim / "fsdb/genbin.fsdb"
has_fsdb = fsdb.is_file() and fsdb.stat().st_size > 0
coverage_dir = sim / "coverage"
coverage_ucds = sorted(coverage_dir.rglob("*.ucd"))
coverage_report = coverage_dir / "cov_report.txt"
coverage_text = coverage_report.read_text(encoding="utf-8", errors="ignore") if coverage_report.exists() else ""
coverage_has_dut = "ibex_top" in coverage_text
coverage_excludes_tb = "core_ibex_tb_top" not in coverage_text
coverage_excludes_bsdcov = "bsdcov_regions_" not in coverage_text
coverage_totals = {}
coverage_code_model_aligned = False
dut_line = next((line for line in coverage_text.splitlines() if line.startswith("ibex_top ")), "")
metric_names = ["block", "branch", "statement", "expression", "toggle", "statement_duplicate", "fsm", "assertion", "covergroup"]
metric_counts = re.findall(r"\((\d+)/(\d+)(?:/\d+)?\)", dut_line)
for name, (_, total) in zip(metric_names, metric_counts):
    coverage_totals[name] = int(total)
expected_code_totals = {
    "block": 13980,
    "branch": 7002,
    "statement": 14419,
    "expression": 5733,
    "toggle": 36321,
    "fsm": 138,
}
coverage_code_model_aligned = all(
    coverage_totals.get(name) == total for name, total in expected_code_totals.items()
)
assertion_times = []
for match in re.finditer(r"\(time\s+(\d+)\s+PS\)\s+Assertion .* has failed", text):
    assertion_times.append(int(match.group(1)))
compile_streams = sim / "ibex_dv_out/build/tb/compile_tb_stdstreams.log"
compile_text = compile_streams.read_text(encoding="utf-8", errors="ignore") if compile_streams.exists() else ""
region_filelist_compiled = str(region_filelist) in compile_text
records = binary.with_suffix(".records.csv")
first_record = None
initial_record_observed = False
if records.exists():
    import csv
    with records.open(newline="", encoding="utf-8") as fd:
        first_record = next(csv.DictReader(fd), None)
if first_record and traces:
    address = first_record["address"].removeprefix("0x").lower()
    instruction = first_record["instruction"].removeprefix("0x").lower()
    trace_text = "\n".join(path.read_text(encoding="utf-8", errors="ignore").lower()
                             for path in traces)
    initial_record_observed = address in trace_text and instruction in trace_text
result = {
    "status": "success" if traces and has_fsdb and initial_record_observed and region_filelist_compiled and coverage_ucds and coverage_has_dut and coverage_excludes_tb and coverage_excludes_bsdcov and coverage_code_model_aligned else "failed",
    "binary": str(binary),
    "region_filelist": str(region_filelist),
    "region_filelist_compiled": region_filelist_compiled,
    "coverage_ucds": [str(path) for path in coverage_ucds],
    "coverage_report": str(coverage_report),
    "coverage_has_dut": coverage_has_dut,
    "coverage_excludes_tb": coverage_excludes_tb,
    "coverage_excludes_bsdcov": coverage_excludes_bsdcov,
    "coverage_totals": coverage_totals,
    "coverage_expected_code_totals": expected_code_totals,
    "coverage_code_model_aligned": coverage_code_model_aligned,
    "coverage_scope_note": "Code coverage excludes SystemVerilog bind modules and TB. Xcelium 20.09 cumulative assertion and covergroup metrics may include bound/TB objects.",
    "xrun_exit_code": rc,
    "timed_out": rc in (124, 137, 143),
    "test_pass": "Test done due to RISCV-DV handshake (payload=TEST_PASS)" in text,
    "illegal_instruction_reported": "illegal instruction" in text.lower(),
    "trap_reported": "trap" in text.lower(),
    "assertion_failure_count": len(assertion_times),
    "first_assertion_failure_time_ps": min(assertion_times) if assertion_times else None,
    "last_assertion_failure_time_ps": max(assertion_times) if assertion_times else None,
    "assertion_failures_continued": len(set(assertion_times)) > 1,
    "first_extracted_record": first_record,
    "first_extracted_record_observed": initial_record_observed,
    "trace_files": [str(path) for path in traces],
    "fsdb": str(fsdb),
    "fsdb_bytes": fsdb.stat().st_size if fsdb.exists() else 0,
}
(sim / "result.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
(coverage_dir / "coverage_summary.json").write_text(json.dumps({
    "status": "success" if coverage_ucds and coverage_has_dut and coverage_excludes_tb and coverage_excludes_bsdcov and coverage_code_model_aligned else "failed",
    "dut": "ibex_top",
    "ucds": [str(path) for path in coverage_ucds],
    "report": str(coverage_report),
    "excludes_testbench": coverage_excludes_tb,
    "excludes_bsdcov_regions": coverage_excludes_bsdcov,
    "totals": coverage_totals,
    "expected_code_totals": expected_code_totals,
    "code_model_aligned": coverage_code_model_aligned,
    "scope_note": "Block/branch/statement/expression/toggle/FSM exclude bind modules and TB. Assertion/covergroup are retained but are not strictly DUT-only on Xcelium 20.09.",
}, indent=2) + "\n", encoding="utf-8")
print(json.dumps(result, indent=2))
sys.exit(0 if result["status"] == "success" else 1)
PY
