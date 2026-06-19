#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_INIT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
IBEX_ROOT="$(cd "$COMMON_INIT_DIR/../../.." && pwd)"
CORE_IBEX_DIR="$IBEX_ROOT/dv/uvm/core_ibex"
BUILD_DIR="$COMMON_INIT_DIR/build"
RUNS_DIR="$COMMON_INIT_DIR/runs"
SEED="${SEED:-1}"
RUN_TAG=""
XRUN_TIMEOUT_S="${XRUN_TIMEOUT_S:-180}"

usage() { echo "Usage: $0 [--seed N] [--run-tag NAME]"; }
while [[ $# -gt 0 ]]; do
  case "$1" in
    --seed) SEED="$2"; shift 2 ;;
    --run-tag) RUN_TAG="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERROR: unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[[ -s "$BUILD_DIR/common_init.bin" ]] || "$SCRIPT_DIR/build.sh"
[[ -n "$RUN_TAG" ]] || RUN_TAG="run.$(date -u +%Y%m%dT%H%M%SZ).seed${SEED}"
RUN_DIR="$RUNS_DIR/$RUN_TAG"
TB_OUT="$RUN_DIR/ibex_dv_out"
TB_DIR="$TB_OUT/build/tb"
COVERAGE_DIR="$RUN_DIR/coverage"
COVFILE="$COVERAGE_DIR/cov.ccf"
mkdir -p "$RUN_DIR/logs" "$RUN_DIR/fsdb" "$COVERAGE_DIR"

cat > "$COVFILE" <<EOF
include_ccf $IBEX_ROOT/dv/uvm/core_ibex/xcelium_2009_cover.ccf
deselect_coverage -remove_empty_instances
EOF
printf '%s\n' "$COMMON_INIT_DIR/src/common_init_stop.sv" > "$BUILD_DIR/common_init_stop.f"

pushd "$CORE_IBEX_DIR" >/dev/null
# shellcheck disable=SC1091
source ./setup_env.sh
popd >/dev/null

export IBEX_ROOT PRJ_DIR="$IBEX_ROOT" LOWRISC_IP_DIR="$IBEX_ROOT/vendor/lowrisc_ip"
export DUT_TOP=ibex_top dv_root="$IBEX_ROOT/vendor/lowrisc_ip/dv"
export BSDCOV_COMMON_INIT_DIR="$COMMON_INIT_DIR"
export EXTRA_COSIM_CFLAGS="${EXTRA_COSIM_CFLAGS:-}"
unset BSDCOV_REUSE_TB_DIR BSDCOV_PROJECT_DIR BSDCOV_SIM_DIR
export VERDI_HOME="${VERDI_HOME:-/home/lvzhengyang/workspace/synopsys/verdi/T-2022.06}"
export BSD_COV_EXTRA_XRUN_FILELISTS="$BUILD_DIR/common_init_stop.f"
export BSD_COV_EXTRA_XRUN_COMPILE_OPTS="-access +rwc -loadpli1 debpli:novas_pli_boot"
export BSD_COV_XRUN_COVFILE="$COVFILE"
export BSD_COV_XRUN_BASE_FILELIST="$COMMON_INIT_DIR/rtl/ibex_dv.f"

set +e
(
  cd "$CORE_IBEX_DIR"
  make -B --keep-going GOAL=rtl_tb_compile OUT="$TB_OUT" \
    IBEX_CONFIG=opentitan SIMULATOR=xlm ISS=spike TEST=empty ITERATIONS=1 \
    SEED="$SEED" WAVES=0 COV=1 VERBOSE=0
) >"$RUN_DIR/logs/rtl_tb_compile.log" 2>&1
compile_rc=$?
set -e
if [[ "$compile_rc" -ne 0 ]]; then
  echo "$compile_rc" > "$RUN_DIR/compile.exit_code"
  echo "ERROR: Ibex testbench compilation failed; see $RUN_DIR/logs/rtl_tb_compile.log" >&2
  exit "$compile_rc"
fi

UCLI="$RUN_DIR/xrun.ucli.cmd"
cat > "$UCLI" <<EOF
call fsdbDumpfile {"$RUN_DIR/fsdb/common_init.fsdb"}
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
    -svseed "$SEED" -svrnc rand_struct -nokey \
    -l "$RUN_DIR/rtl_sim.log" \
    +UVM_TESTNAME=core_ibex_base_test +UVM_VERBOSITY=UVM_LOW \
    +bin="$BUILD_DIR/common_init.bin" +signature_addr=8ffffffc \
    +test_timeout_s=60 +disable_cosim=1 \
    +ibex_tracer_file_base="$RUN_DIR/trace_core" \
    -covmodeldir "$COVERAGE_DIR/model" -covworkdir "$COVERAGE_DIR" \
    -covscope coverage -covtest "common_init.$SEED" -covoverwrite \
    +enable_ibex_fcov=1 -covfile "$COVFILE" -input "$UCLI"
) >"$RUN_DIR/logs/launch_rtl.log" 2>&1
rc=$?
set -e
echo "$rc" > "$RUN_DIR/xrun.exit_code"

mapfile -t coverage_ucds < <(find "$COVERAGE_DIR" -type f -name '*.ucd' | sort)
if [[ "${#coverage_ucds[@]}" -gt 0 ]]; then
  python3 - "$IBEX_ROOT" "$RUN_DIR" "${coverage_ucds[@]}" <<'PY'
import shutil
import sys
from pathlib import Path

ibex_root = Path(sys.argv[1]).resolve()
run_dir = Path(sys.argv[2]).resolve()
ucds = [Path(arg).resolve() for arg in sys.argv[3:]]
sys.path.insert(0, str(ibex_root / "dv/bsdcov_whole_mc/scripts"))
from _launch_sim import _run_imc_report

report = _run_imc_report(
    repo_root=ibex_root, run_dir=run_dir, prefix_idx=1,
    ucds=ucds, module="ibex_top", dry_run=False,
)
if report is None or not report.exists():
    raise RuntimeError("IMC did not produce a coverage report")
coverage = run_dir / "coverage"
full_report = coverage / "report_full"
if full_report.exists():
    shutil.rmtree(full_report)
shutil.copytree(report.parent, full_report)
lines = report.read_text(encoding="utf-8", errors="ignore").splitlines()
dut_lines = [line for line in lines if line.startswith(("Legend:", "name ", "---", "ibex_top "))]
(coverage / "cov_report.txt").write_text("\n".join(dut_lines) + "\n", encoding="utf-8")
cg_report = report.with_name("cov_report_cg.txt")
if cg_report.exists():
    shutil.copy2(cg_report, coverage / "cov_report_cg.txt")
PY
fi

check_rc=0
python3 "$SCRIPT_DIR/check_result.py" "$RUN_DIR" || check_rc=$?
ln -sfn "$RUN_TAG" "$RUNS_DIR/latest"
echo "Run directory: $RUN_DIR"
exit "$check_rc"
