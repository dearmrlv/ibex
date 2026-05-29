#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../../../.." && pwd)"

RUN_TAG="${RUN_TAG:-bsd_cov_sim_stall_ld_hz_001_bind}"
TEST_NAME="${TEST_NAME:-bsd_cov_sim_stall_ld_hz_001_bind}"
JOBS="${JOBS:-4}"
XRUN_WRAPPER="${XRUN_WRAPPER:-/home/lvzhengyang/workspace/cadence/xrun}"
VERDI_HOME="${VERDI_HOME:-/home/lvzhengyang/workspace/synopsys/verdi/T-2022.06}"

OUT_DIR="${SCRIPT_DIR}/out/stall_ld_hz_001"
BIND_SV="${SCRIPT_DIR}/bsd_bind/bind.sv"
BIND_FILELIST="${OUT_DIR}/bsd_bind.f"
RAW_INSTR="${SCRIPT_DIR}/instr_seq/AST_BSDCOV_R_stall_ld_hz_001.instr.S"
WRAPPED_ASM="${OUT_DIR}/${TEST_NAME}.S"
CONFIG="${OUT_DIR}/${TEST_NAME}.yaml"
TESTLIST="${OUT_DIR}/testlist.yaml"
SUMMARY="${OUT_DIR}/assertion_summary.txt"
IBEX_DV_ROOT="${REPO_ROOT}/designs/ibex/dv/uvm/core_ibex"
RAW_OUT="${REPO_ROOT}/exp/ibex_riscvdv/${RUN_TAG}/raw/${TEST_NAME}/seed_888/out"
TEST_DIR="${RAW_OUT}/run/tests/${TEST_NAME}.888"
FSDB_UCLI="${OUT_DIR}/ucli.fsdb.cmd"
FSDB_WAVE="${TEST_DIR}/waves.fsdb"

mkdir -p "${OUT_DIR}"

if [[ ! -x "${XRUN_WRAPPER}" ]]; then
  echo "ERROR: xrun wrapper is missing or not executable: ${XRUN_WRAPPER}" >&2
  exit 1
fi
if [[ ! -f "${BIND_SV}" ]]; then
  echo "ERROR: missing bind file: ${BIND_SV}" >&2
  exit 1
fi
if [[ ! -f "${RAW_INSTR}" ]]; then
  echo "ERROR: missing instruction sequence: ${RAW_INSTR}" >&2
  exit 1
fi

cat > "${FSDB_UCLI}" <<EOF
call fsdbDumpfile {"${FSDB_WAVE}"}
call fsdbDumpvars {0} {core_ibex_tb_top} {"+mda"} {"+struct"} {"+parameter"}
call fsdbDumpSVA
run
quit
EOF

printf '%s\n' "${BIND_SV}" > "${BIND_FILELIST}"
cat > "${TESTLIST}" <<EOF
- test: bsd_cov_unused_riscvdv_dummy
  description: >
    Unused dummy riscv-dv entry for directed BSD-Cov bind simulations.
  gen_opts: >
    +instr_cnt=1
  iterations: 1
  gen_test: riscv_instr_base_test
  rtl_test: core_ibex_base_test
EOF

python3 - "${REPO_ROOT}" "${RAW_INSTR}" "${WRAPPED_ASM}" "${CONFIG}" "${BIND_FILELIST}" "${XRUN_WRAPPER}" "${TEST_NAME}" "${FSDB_UCLI}" <<'PY'
from pathlib import Path
import re
import sys

repo_root = Path(sys.argv[1]).resolve()
raw_instr = Path(sys.argv[2]).resolve()
wrapped_asm = Path(sys.argv[3]).resolve()
config = Path(sys.argv[4]).resolve()
bind_filelist = Path(sys.argv[5]).resolve()
xrun_wrapper = Path(sys.argv[6]).resolve()
test_name = sys.argv[7]
fsdb_ucli = Path(sys.argv[8]).resolve()

words: list[str] = []
for line in raw_instr.read_text(encoding="utf-8").splitlines():
    stripped = line.strip()
    if stripped.startswith(".word"):
        words.append(stripped)

if not words:
    raise SystemExit(f"No .word instructions found in {raw_instr}")

asm_lines = [
    '#include "riscv_test.h"',
    '#include "test_macros.h"',
    "",
    "RVTEST_RV64M",
    "RVTEST_CODE_BEGIN",
    "",
    "main:",
    f"  # BSD-Cov source: {raw_instr}",
]
for word in words:
    asm_lines.append(f"  {word}")
asm_lines.extend([
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
])
wrapped_asm.write_text("\n".join(asm_lines), encoding="utf-8")

sys.path.insert(0, str(repo_root))
from src.bsdcov.sequences.ibex_directed_install import (  # noqa: E402
    install_directed_source,
    patch_directed_testlist,
)

installed = install_directed_source(repo_root, wrapped_asm, test_name)
directed_testlist = patch_directed_testlist(repo_root, test_name)

directed_text = directed_testlist.read_text(encoding="utf-8")
directed_text = directed_text.replace(
    "    +bsd_cov_hazard_stall_trace\n",
    f"    +bsd_cov_hazard_stall_trace -input {fsdb_ucli}\n",
)
directed_testlist.write_text(directed_text, encoding="utf-8")

rel_installed = "${BSD_COV_ROOT}/" + str(installed.relative_to(repo_root))
rel_filelist = "${BSD_COV_ROOT}/" + str(bind_filelist.relative_to(repo_root))
rel_xrun = str(xrun_wrapper)

config_text = f"""design: ibex
method: riscvdv
experiment: ibex_bsd_cov_bind_stall_ld_hz_001

ibex_dv_root: ${{BSD_COV_ROOT}}/designs/ibex/dv/uvm/core_ibex
setup_env: ${{BSD_COV_ROOT}}/designs/ibex/dv/uvm/core_ibex/setup_env.sh

make:
  ibex_config: opentitan
  simulator: xlm
  iss: spike
  waves: 0
  cov: 0
  verbose: 0
  xrun: {rel_xrun}
  extra_xrun_filelists:
    - {rel_filelist}

run:
  start_seed: 888
  num_seeds: 1

budget:
  primary_axis: generated_instr_count
  generated_instr_budget: {len(words)}
  per_seed_generated_instr: {len(words)}

sampling:
  mode: per_seed
  trigger_type: generated
  step: {len(words)}

methods:
  - id: {test_name}
    name: {test_name}
    type: directed_asm
    test: {test_name}
    description: BSD-Cov bind smoke simulation for R_stall_ld_hz_001.
    requested_instr_cnt: {len(words)}
    directed_test_src: {rel_installed}
    sim_opts: >
      +bsd_cov_hazard_stall_trace -input {fsdb_ucli}
"""
config.write_text(config_text, encoding="utf-8")
PY

echo "Generated config: ${CONFIG}"
echo "Generated bind filelist: ${BIND_FILELIST}"
echo "Generated testlist: ${TESTLIST}"
echo "Generated FSDB UCLI: ${FSDB_UCLI}"
echo "Running ${RUN_TAG} with ${JOBS} job(s)..."

rm -rf "${REPO_ROOT}/exp/ibex_riscvdv/${RUN_TAG}"

set +e
(
  cd "${IBEX_DV_ROOT}" &&
  source setup_env.sh &&
  export CADENCE_XRUN="${XRUN_WRAPPER}" &&
  export BSD_COV_EXTRA_XRUN_FILELISTS="${BIND_FILELIST}" &&
  export BSD_COV_EXTRA_XRUN_COMPILE_OPTS="-access +rwc -loadpli1 debpli:novas_pli_boot" &&
  export VERDI_HOME="${VERDI_HOME}" &&
  export IBEX_ROOT="${REPO_ROOT}/designs/ibex" &&
  export PRJ_DIR="${REPO_ROOT}/designs/ibex" &&
  export LOWRISC_IP_DIR="${REPO_ROOT}/designs/ibex/vendor/lowrisc_ip" &&
  export dv_root="${REPO_ROOT}/designs/ibex/vendor/lowrisc_ip/dv" &&
  export DUT_TOP=ibex_top &&
  export EXTRA_COSIM_CFLAGS="${EXTRA_COSIM_CFLAGS:-}" &&
  export PYTHONPATH="$(python3 -c 'from scripts.setup_imports import get_pythonpath; get_pythonpath()')" &&
  make --keep-going \
    GOAL=compile_directed_tests \
    OUT="${RAW_OUT}" \
    IBEX_CONFIG=opentitan \
    SIMULATOR=xlm \
    ISS=spike \
    TEST="${TEST_NAME}" \
    ITERATIONS=1 \
    SEED=888 \
    WAVES=0 \
    COV=0 \
    VERBOSE=0 \
    RISCV_DV_TESTLIST="${TESTLIST}" &&
  make --keep-going -B \
    GOAL=rtl_tb_compile \
    OUT="${RAW_OUT}" \
    IBEX_CONFIG=opentitan \
    SIMULATOR=xlm \
    ISS=spike \
    TEST="${TEST_NAME}" \
    ITERATIONS=1 \
    SEED=888 \
    WAVES=0 \
    COV=0 \
    VERBOSE=0 \
    RISCV_DV_TESTLIST="${TESTLIST}" &&
  scripts/run_rtl.py \
    --dir-metadata "${RAW_OUT}/metadata" \
    --test-dot-seed "${TEST_NAME}.888" &&
  scripts/check_logs.py \
    --dir-metadata "${RAW_OUT}/metadata" \
    --test-dot-seed "${TEST_NAME}.888"
)
RUN_STATUS=$?
set -e

RUN_DIR="${REPO_ROOT}/exp/ibex_riscvdv/${RUN_TAG}"
RUNS_CSV="${RUN_DIR}/sim/runs.csv"
METHOD_RUNS_CSV="${RUN_DIR}/methods/${TEST_NAME}/runs.csv"

LOGS=()
RUNS_FOR_LOGS=""
if [[ -f "${RUNS_CSV}" ]]; then
  RUNS_FOR_LOGS="${RUNS_CSV}"
elif [[ -f "${METHOD_RUNS_CSV}" ]]; then
  RUNS_FOR_LOGS="${METHOD_RUNS_CSV}"
fi

if [[ -n "${RUNS_FOR_LOGS}" ]]; then
  while IFS= read -r log; do
    LOGS+=("${log}")
  done < <(python3 - "${RUNS_FOR_LOGS}" <<'PY'
import csv
import sys
from pathlib import Path

with Path(sys.argv[1]).open(newline="") as fd:
    for row in csv.DictReader(fd):
        test_dir = Path(row.get("test_dir", ""))
        log = test_dir / "rtl_sim.log"
        if log.exists():
            print(log)
PY
  )
fi
while IFS= read -r log; do
  LOGS+=("${log}")
done < <(find "${RUN_DIR}" -path '*/rtl_sim.log' -type f 2>/dev/null | sort)
if [[ -f "${TEST_DIR}/rtl_sim.log" ]]; then
  LOGS+=("${TEST_DIR}/rtl_sim.log")
fi

LOGS_UNIQ=()
for log in "${LOGS[@]}"; do
  seen=0
  for existing in "${LOGS_UNIQ[@]}"; do
    [[ "${existing}" == "${log}" ]] && seen=1 && break
  done
  [[ "${seen}" == 0 ]] && LOGS_UNIQ+=("${log}")
done

{
  echo "run_tag: ${RUN_TAG}"
  echo "run_status: ${RUN_STATUS}"
  echo "config: ${CONFIG}"
  echo "bind_filelist: ${BIND_FILELIST}"
  echo "bind_sv: ${BIND_SV}"
  echo "raw_instr: ${RAW_INSTR}"
  echo "fsdb_ucli: ${FSDB_UCLI}"
  echo "fsdb_wave: ${FSDB_WAVE}"
  if [[ -s "${FSDB_WAVE}" ]]; then
    echo "fsdb_status: GENERATED"
    ls -lh "${FSDB_WAVE}"
  else
    echo "fsdb_status: MISSING_OR_EMPTY"
  fi
  echo "runs_csv: ${RUNS_CSV}"
  echo
  if [[ -f "${RUNS_CSV}" ]]; then
    echo "runs.csv:"
    cat "${RUNS_CSV}"
    echo
  elif [[ -f "${METHOD_RUNS_CSV}" ]]; then
    echo "method runs.csv:"
    cat "${METHOD_RUNS_CSV}"
    echo
  else
    echo "runs.csv: missing"
    echo
  fi

  echo "compile_logs:"
  if find "${RUN_DIR}" -type f \( -name 'compile_tb*.log' -o -name 'compile.directed.log' \) -print -quit 2>/dev/null | grep -q .; then
    find "${RUN_DIR}" -type f \( -name 'compile_tb*.log' -o -name 'compile.directed.log' \) | sort
  else
    echo "  none"
  fi
  echo

  if [[ "${#LOGS_UNIQ[@]}" -eq 0 ]]; then
    echo "assertion_status: UNKNOWN_NO_RTL_LOG"
  else
    echo "rtl_logs:"
    printf '  %s\n' "${LOGS_UNIQ[@]}"
    echo
    echo "target_region_matches:"
    if grep -H -E 'AST_BSDCOV_R_stall_ld_hz_001|COV_BSDCOV_R_stall_ld_hz_001|R_stall_ld_hz_001' "${LOGS_UNIQ[@]}"; then
      echo
      if grep -q 'BSD-Cov region assertion failed: R_stall_ld_hz_001' "${LOGS_UNIQ[@]}"; then
        echo "target_assertion_status: TRIGGERED"
      else
        echo "target_assertion_status: REFERENCED_ONLY"
      fi
    else
      echo "  none"
      echo
      echo "target_assertion_status: NOT_OBSERVED"
    fi
    echo
    echo "all_bsd_cov_assertion_failures:"
    if grep -H 'BSD-Cov region assertion failed:' "${LOGS_UNIQ[@]}"; then
      echo
      echo "any_assertion_status: TRIGGERED"
    else
      echo "  none"
      echo
      echo "any_assertion_status: NOT_OBSERVED"
    fi
  fi
} > "${SUMMARY}"

cat "${SUMMARY}"

if [[ "${#LOGS_UNIQ[@]}" -eq 0 ]]; then
  exit 1
fi
if [[ "${RUN_STATUS}" -ne 0 ]] && ! grep -q -E 'R_stall_ld_hz_001|BSD-Cov region assertion failed' "${LOGS_UNIQ[@]}"; then
  exit "${RUN_STATUS}"
fi
