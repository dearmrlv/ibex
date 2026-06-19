#!/usr/bin/env bash
set -euo pipefail

RUN_DIR="$(cd "$1" && pwd)"
SEED="$2"
HANG_ON_IMEM="$3"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EVAL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
IBEX_ROOT="$(cd "$EVAL_DIR/../../.." && pwd)"
CORE_IBEX_DIR="$IBEX_ROOT/dv/uvm/core_ibex"
TB_OUT="$RUN_DIR/sim/ibex_dv_out"
TB_DIR="$TB_OUT/build/tb"
COVERAGE_DIR="$RUN_DIR/coverage"
COVFILE="$COVERAGE_DIR/cov.ccf"
if [[ "$HANG_ON_IMEM" == "on" ]]; then
  XRUN_TIMEOUT_S="${XRUN_TIMEOUT_S:-7200}"
  UVM_TEST_TIMEOUT_S="${UVM_TEST_TIMEOUT_S:-7200}"
else
  XRUN_TIMEOUT_S="${XRUN_TIMEOUT_S:-1800}"
  UVM_TEST_TIMEOUT_S="${UVM_TEST_TIMEOUT_S:-120}"
fi

cat > "$COVFILE" <<EOF
include_ccf $IBEX_ROOT/dv/uvm/core_ibex/xcelium_2009_cover.ccf
deselect_coverage -remove_empty_instances
EOF

pushd "$CORE_IBEX_DIR" >/dev/null
# shellcheck disable=SC1091
source ./setup_env.sh
popd >/dev/null
export IBEX_ROOT PRJ_DIR="$IBEX_ROOT" LOWRISC_IP_DIR="$IBEX_ROOT/vendor/lowrisc_ip"
export DUT_TOP=ibex_top dv_root="$IBEX_ROOT/vendor/lowrisc_ip/dv"
export BSDCOV_EVAL_DIR="$EVAL_DIR"
export EXTRA_COSIM_CFLAGS="${EXTRA_COSIM_CFLAGS:-}"
unset BSD_COV_XRUN_BASE_FILELIST BSD_COV_EXTRA_XRUN_FILELISTS
unset BSDCOV_REUSE_TB_DIR BSDCOV_PROJECT_DIR BSDCOV_SIM_DIR
export VERDI_HOME="${VERDI_HOME:-/home/lvzhengyang/workspace/synopsys/verdi/T-2022.06}"
export BSD_COV_EXTRA_XRUN_COMPILE_OPTS="-access +rwc -loadpli1 debpli:novas_pli_boot"
export BSD_COV_XRUN_COVFILE="$COVFILE"
if [[ "$HANG_ON_IMEM" == "on" ]]; then
  stop_pc="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["stop_pc"].replace("0x", ""))' "$RUN_DIR/bin/image_layout.json")"
  export BSD_COV_XRUN_BASE_FILELIST="$EVAL_DIR/rtl/ibex_dv.f"
  export BSD_COV_EXTRA_XRUN_COMPILE_OPTS="${BSD_COV_EXTRA_XRUN_COMPILE_OPTS} +define+BSDCOV_EVAL_IMEM_LAST_ADDR=32\\'h${stop_pc}"
else
  unset BSD_COV_XRUN_BASE_FILELIST
fi
printf '%s\n' "$RUN_DIR/sv/eval_stop.sv" > "$RUN_DIR/sv/eval_stop.f"
export BSD_COV_EXTRA_XRUN_FILELISTS="$RUN_DIR/sv/eval_stop.f"

set +e
(
  cd "$CORE_IBEX_DIR"
  make -B --keep-going GOAL=rtl_tb_compile OUT="$TB_OUT" \
    IBEX_CONFIG=opentitan SIMULATOR=xlm ISS=spike TEST=empty ITERATIONS=1 \
    SEED="$SEED" WAVES=0 COV=1 VERBOSE=0
) >"$RUN_DIR/logs/rtl_tb_compile.log" 2>&1
compile_rc=$?
set -e
echo "$compile_rc" > "$RUN_DIR/compile.exit_code"
[[ "$compile_rc" -eq 0 ]] || return "$compile_rc" 2>/dev/null || exit "$compile_rc"

UCLI="$RUN_DIR/sim/xrun.ucli.cmd"
cat > "$UCLI" <<EOF
set assert_output_stop_level none
set assert_stop_level never
call fsdbDumpfile {"$RUN_DIR/fsdb/eval.fsdb"}
call fsdbDumpvars {0} {core_ibex_tb_top} {"+mda"} {"+struct"} {"+parameter"}
call fsdbDumpSVA
run
exit
EOF

XRUN="${CADENCE_XRUN:-/home/lvzhengyang/workspace/cadence/xrun}"
set +e
(
  cd "$CORE_IBEX_DIR"
  timeout --signal=TERM --kill-after=15s "${XRUN_TIMEOUT_S}s" \
  "$XRUN" -64bit -R -xmlibdirpath "$TB_DIR" -licqueue \
    -svseed "$SEED" -svrnc rand_struct -nokey -l "$RUN_DIR/sim/rtl_sim.log" \
    +UVM_TESTNAME=core_ibex_base_test +UVM_VERBOSITY=UVM_LOW \
    +bin="$RUN_DIR/bin/eval.bin" +signature_addr=8ffffffc \
    +test_timeout_s="$UVM_TEST_TIMEOUT_S" +disable_cosim=1 \
    +ibex_tracer_file_base="$RUN_DIR/sim/trace_core" \
    -covmodeldir "$COVERAGE_DIR/model" -covworkdir "$COVERAGE_DIR" \
    -covscope coverage -covtest "eval.$SEED" -covoverwrite \
    +enable_ibex_fcov=1 -covfile "$COVFILE" -input "$UCLI"
) >"$RUN_DIR/logs/launch_rtl.log" 2>&1
rc=$?
set -e
echo "$rc" > "$RUN_DIR/xrun.exit_code"

mapfile -t coverage_ucds < <(find "$COVERAGE_DIR" -type f -name '*.ucd' | sort)
if [[ "${#coverage_ucds[@]}" -gt 0 ]]; then
  python3 - "$IBEX_ROOT" "$RUN_DIR" "${coverage_ucds[@]}" <<'PY'
import shutil, sys
from pathlib import Path
ibex_root, run_dir = Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve()
sys.path.insert(0, str(ibex_root / "dv/bsdcov_whole_mc/scripts"))
from _launch_sim import _run_imc_report
report = _run_imc_report(repo_root=ibex_root, run_dir=run_dir, prefix_idx=1,
    ucds=[Path(x).resolve() for x in sys.argv[3:]], module="ibex_top", dry_run=False)
if report is None or not report.exists(): raise RuntimeError("IMC did not produce a report")
lines = report.read_text(encoding="utf-8", errors="ignore").splitlines()
(run_dir / "coverage/cov_report.txt").write_text(
    "\n".join(x for x in lines if x.startswith(("Legend:", "name ", "---", "ibex_top "))) + "\n")
cg = report.with_name("cov_report_cg.txt")
if cg.exists(): shutil.copy2(cg, run_dir / "coverage/cov_report_cg.txt")
PY
fi
exit "$rc"
