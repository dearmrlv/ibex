#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BSDCOV_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT="$(cd "$BSDCOV_DIR/../../../.." && pwd)"
IBEX_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
CORE_IBEX_DIR="$IBEX_ROOT/dv/uvm/core_ibex"

SEED="${SEED:-1688}"
BASELINE_INSTR="${BASELINE_INSTR:-1000}"
JOBS="${JOBS:-4}"
FML_JOBS="${FML_JOBS:-8}"
CONTINUE_ON_ASSERT="${CONTINUE_ON_ASSERT:-1}"
RAND_TIMEOUT_S="${RAND_INSTR_TIMEOUT_S:-${RAND_TIMEOUT_S:-3600}}"
RUN_TAG="${RUN_TAG:-w.$(date -u +%H%M%S).s${SEED}.n${BASELINE_INSTR}}"
RUN_DIR="$BSDCOV_DIR/runs/$RUN_TAG"
PROJ_DIR="$RUN_DIR/big_proj"
REPORT_DIR="$RUN_DIR/reports"

CADENCE_XRUN="${CADENCE_XRUN:-/home/lvzhengyang/workspace/cadence/xrun}"
BSDCOV_XRUN="${BSDCOV_XRUN:-$CADENCE_XRUN}"
BSDCOV_JG="${BSDCOV_JG:-/home/lvzhengyang/workspace/cadence/jg}"
if [[ -x "$IBEX_ROOT/.venv/bin/python" ]]; then
  PYTHON_BIN="${BSDCOV_PYTHON:-$IBEX_ROOT/.venv/bin/python}"
else
  PYTHON_BIN="${BSDCOV_PYTHON:-$(command -v python3)}"
fi

mkdir -p "$RUN_DIR" "$REPORT_DIR"
cd "$BSDCOV_DIR"

log_step() {
  echo
  echo "================================================================"
  echo "$*"
  echo "================================================================"
}

latest_sim_run() {
  local sim_dir="$1"
  if [[ -L "$sim_dir/latest" || -e "$sim_dir/latest" ]]; then
    readlink -f "$sim_dir/latest" 2>/dev/null || true
    return
  fi
  if [[ -f "$sim_dir/latest.txt" ]]; then
    cat "$sim_dir/latest.txt"
    return
  fi
}

run_status_from_csv() {
  local runs_csv="$1"
  if [[ ! -f "$runs_csv" ]]; then
    echo ""
    return
  fi
  "$PYTHON_BIN" - "$runs_csv" <<'PY'
import csv
import sys
from pathlib import Path

path = Path(sys.argv[1])
rows = list(csv.DictReader(path.open(encoding="utf-8", errors="ignore")))
print(rows[-1].get("status", "") if rows else "")
PY
}

first_fsdb_from_run() {
  local run="$1"
  find "$run/fsdb" -maxdepth 1 -type f -name '*.fsdb' | sort | head -1
}

continue_on_assert_args() {
  if [[ "$CONTINUE_ON_ASSERT" != "0" ]]; then
    echo "--continue-on-assert"
  fi
}

write_covfile() {
  local covfile="$1"
  mkdir -p "$(dirname "$covfile")"
  cat > "$covfile" <<'EOF'
select_coverage -all -module ibex_top...
deselect_coverage -all -module *BSDCOV*
deselect_coverage -all -module *BSD_COV*
deselect_coverage -all -module *bsdcov*
deselect_coverage -all -module *bsd_cov*
deselect_coverage -all -module *io_dump*
deselect_coverage -all -module *trace_if*
deselect_coverage -remove_empty_instances
EOF
}

write_fml_tcl() {
  local tcl="$1"
  local sim_fsdb="$2"
  local out_root="$3"
  cat > "$tcl" <<EOF
clear -all

set fml_dir [file normalize "$BSDCOV_DIR/fml"]
cd \$fml_dir

set trace_name  "bsd_cov_region_asserts"
set trace_dir   [file normalize "$out_root/traces_fsdb.\$trace_name"]
set report_dir  [file normalize "$out_root/reports"]

file delete -force \$trace_dir
file mkdir \$trace_dir
file mkdir \$report_dir

puts "INFO: FSDB dir     = \$trace_dir"
puts "INFO: report dir   = \$report_dir"
puts "INFO: target set   = AST_BSDCOV_* region assertions"

analyze -sv12 \\
  -f "$BSDCOV_DIR/fml/dut.f" \\
  -f "$PROJ_DIR/results/bsdcov.f" \\
  -f "$BSDCOV_DIR/fml/env.f"

elaborate -top ibex_top \\
  -parameter RV32E                 0 \\
  -parameter RV32M                 {ibex_pkg::RV32MSingleCycle} \\
  -parameter RV32B                 {ibex_pkg::RV32BOTEarlGrey} \\
  -parameter RV32ZC                {ibex_pkg::RV32ZcaZcbZcmp} \\
  -parameter RegFile               {ibex_pkg::RegFileFF} \\
  -parameter BranchTargetALU       1 \\
  -parameter WritebackStage        1 \\
  -parameter ICache                1 \\
  -parameter ICacheECC             1 \\
  -parameter ICacheScramble        1 \\
  -parameter ICacheTweakInfection  0 \\
  -parameter BranchPredictor       0 \\
  -parameter DbgTriggerEn          1 \\
  -parameter DbgHwBreakNum         1 \\
  -parameter SecureIbex            1 \\
  -parameter LockstepOffset        1 \\
  -parameter PMPEnable             1 \\
  -parameter PMPGranularity        0 \\
  -parameter PMPNumRegions         16 \\
  -parameter MHPMCounterNum        10 \\
  -parameter MHPMCounterWidth      32 \\
  -parameter DmBaseAddr            {32'h1A110000} \\
  -parameter DmAddrMask            {32'h00000FFF} \\
  -parameter DmHaltAddr            {32'h80000000} \\
  -parameter DmExceptionAddr       {32'h80000008}

clock clk_i
set sim_fsdb [file normalize "$sim_fsdb"]
set sim_dut_hier "core_ibex_tb_top.dut.u_ibex_top"

set_trace_show_reset false

reset -clear
reset -sequence -fsdb \$sim_fsdb \\
  -hier_path \$sim_dut_hier \\
  -non_resettable_regs 0

report -summary -file [file join \$report_dir "fpv_setup_summary.\$trace_name.txt"] -force

set_prove_dump_trace_type assert
set per_prop_time 300s

set target_props {}
foreach p [get_property_list -include {type assert}] {
  if {[string match "*AST_BSDCOV_*" \$p]} {
    lappend target_props \$p
  }
}

if {[llength \$target_props] == 0} {
  puts "ERROR: no generated BSD-Cov region coverage matched AST_BSDCOV_*"
  exit 1
}

puts "INFO: BSD-Cov region assertion count = [llength \$target_props]"

set max_traces_per_prop 10
set max_hunt_rounds     10
set hunt_round_time     300s

set multi_trace_root [file normalize [file join \$trace_dir "multi_cex"]]
file delete -force \$multi_trace_root
file mkdir \$multi_trace_root

foreach p \$target_props {
  assert -set_store_trace unlimited \$p
}

proc bsdcov_prop_status {p} {
  set info [get_property_info -list {status} \$p]
  return [lindex \$info 0]
}

proc bsdcov_prop_num_traces {p} {
  set info [get_property_info -list {num_traces} \$p]
  set n [lindex \$info 0]
  if {\$n eq ""} {
    return 0
  }
  return \$n
}

proc bsdcov_prop_trace_ids {p} {
  set info [get_property_info -list {trace_id} \$p]
  return [lindex \$info 0]
}

set prove_trace_dir [file normalize [file join \$multi_trace_root "round_00_prove"]]
file mkdir \$prove_trace_dir

puts "INFO: multi-CEX round 0: prove initial CEX traces"

prove -property \$target_props -asserts -force \\
  -per_property_time_limit \$per_prop_time \\
  -dump_trace \\
  -dump_trace_type fsdb \\
  -dump_trace_dir \$prove_trace_dir

for {set round 1} {\$round <= \$max_hunt_rounds} {incr round} {
  set need_more {}

  foreach p \$target_props {
    set st [bsdcov_prop_status \$p]
    set nt [bsdcov_prop_num_traces \$p]

    if {(\$st eq "cex" || \$st eq "ar_cex") && \$nt < \$max_traces_per_prop} {
      lappend need_more \$p
    }
  }

  if {[llength \$need_more] == 0} {
    puts "INFO: all CEX properties reached max trace target = \$max_traces_per_prop"
    break
  }

  set round_dir [file normalize [file join \$multi_trace_root [format "round_%02d_hunt" \$round]]]
  file mkdir \$round_dir

  puts "INFO: multi-CEX hunt round \$round"
  puts "INFO: properties needing more traces = [llength \$need_more]"
  puts "INFO: dump dir = \$round_dir"

  hunt -clear

  hunt -config -strategy [format "bsdcov_multi_cex_%02d" \$round] \\
    -mode state_swarm \\
    -target_type assert \\
    -max_jobs $FML_JOBS \\
    -max_trace_length 300 \\
    -seed \$round

  hunt -run \\
    -strategy [format "bsdcov_multi_cex_%02d" \$round] \\
    -property \$need_more \\
    -time_limit \$hunt_round_time \\
    -force \\
    -dump_trace \\
    -dump_trace_type fsdb \\
    -dump_trace_dir \$round_dir

  hunt -report -detailed \\
    -start_time \\
    -engine_config \\
    -engine_stats \\
    -sort_by cex
}

set trace_summary_file [open [file join \$report_dir "trace_summary.\$trace_name.tsv"] w]
puts \$trace_summary_file "property\tstatus\tnum_traces\ttrace_ids"

foreach p \$target_props {
  set st  [bsdcov_prop_status \$p]
  set nt  [bsdcov_prop_num_traces \$p]
  set tids [bsdcov_prop_trace_ids \$p]
  puts \$trace_summary_file "\$p\t\$st\t\$nt\t\$tids"
}

close \$trace_summary_file

report -property \$target_props -results -detailed \\
  -file [file join \$report_dir "fpv_report.\$trace_name.txt"] -force

report -property \$target_props -csv -include_type \\
  -file [file join \$report_dir "fpv_report.\$trace_name.csv"] -force

set cex_file [open [file join \$report_dir "cex_properties.\$trace_name.list"] w]
foreach p \$target_props {
  set st [get_status \$p]
  if {\$st eq "cex" || \$st eq "ar_cex"} {
    puts \$cex_file \$p
  }
}
close \$cex_file
exit
EOF
}

log_step "1. Generate baseline riscv-dv assembly (${BASELINE_INSTR} instr)"
"$SCRIPT_DIR/rand_instr.sh" \
  --seed "$SEED" \
  --num "$BASELINE_INSTR" \
  --chunk-size "$BASELINE_INSTR" \
  --timeout-s "$RAND_TIMEOUT_S" \
  --out-dir "$RUN_DIR/riscvdv" \
  --force

BASELINE_CHUNKS="$RUN_DIR/riscvdv/assembly/seq.${SEED}.${BASELINE_INSTR}.chunks.f"
BASELINE_ASM="$RUN_DIR/riscvdv/assembly/seq.${SEED}.${BASELINE_INSTR}.S"
test -f "$BASELINE_CHUNKS"
test -f "$BASELINE_ASM"

COVFILE="$RUN_DIR/coverage/cov.ccf"
write_covfile "$COVFILE"

log_step "2. Prep and extract BSD-Cov project"
python3 "$ROOT/main.py" bsdcov prep \
  --sim-dut-inst core_ibex_tb_top.dut.u_ibex_top \
  --dut-top ibex_top \
  --dut-f "$BSDCOV_DIR/dut.f" \
  --parameter-file "$BSDCOV_DIR/parameters.txt" \
  --force \
  "$PROJ_DIR"

python3 "$ROOT/main.py" bsdcov extract \
  --module ibex_if_stage \
  --dut-inst-hier ibex_top.u_ibex_core.if_stage_i \
  --output-signals instr_req_o,instr_intg_err_o,if_busy_o \
  --force \
  "$PROJ_DIR"

log_step "3. Run baseline simulation with IO-dump bind and FSDB"
export BSDCOV_SIM_DIR="$RUN_DIR/sim"
export BSDCOV_PROJECT_DIR="$PROJ_DIR"
export CADENCE_XRUN
export BSDCOV_XRUN
"$SCRIPT_DIR/launch_sim.sh" \
  --instr-seq "$BASELINE_CHUNKS" \
  --bind-flist "$PROJ_DIR/db/io_dump.f" \
  --covfile "$COVFILE" \
  --cov-update "$BASELINE_INSTR" \
  --fsdb \
  $(continue_on_assert_args) \
  --jobs 1 \
  --run-tag baseline_${BASELINE_INSTR}

BASELINE_RUN="$(latest_sim_run "$RUN_DIR/sim")"
if [[ -z "$BASELINE_RUN" || ! -d "$BASELINE_RUN" ]]; then
  echo "ERROR: baseline simulation did not create a latest run" >&2
  exit 1
fi
BASELINE_SAMPLES="$BASELINE_RUN/coverage/samples.csv"
BASELINE_FSDB="$(first_fsdb_from_run "$BASELINE_RUN")"
if [[ -z "$BASELINE_FSDB" || ! -f "$BASELINE_FSDB" ]]; then
  echo "ERROR: baseline simulation did not produce an FSDB" >&2
  exit 1
fi

log_step "4. Cook BSD-Cov project"
if [[ -f "$CORE_IBEX_DIR/setup_env.sh" ]]; then
  pushd "$CORE_IBEX_DIR" >/dev/null
  # shellcheck disable=SC1091
  source ./setup_env.sh
  popd >/dev/null
  cd "$BSDCOV_DIR"
fi
if [[ -z "${RISCV_OBJDUMP:-}" && -n "${RISCV_TOOLCHAIN:-}" ]]; then
  RISCV_OBJDUMP="$RISCV_TOOLCHAIN/bin/riscv32-unknown-elf-objdump"
fi
export BSDCOV_XRUN
export BSDCOV_JG
python3 "$ROOT/main.py" bsdcov cook --force "$PROJ_DIR"

if [[ ! -s "$PROJ_DIR/results/bsdcov.f" ]]; then
  echo "ERROR: cook did not generate $PROJ_DIR/results/bsdcov.f" >&2
  exit 1
fi

log_step "5. Run JasperGold multi-CEX and dump FSDB traces"
FML_OUT="$RUN_DIR/fml"
FML_TCL="$FML_OUT/fpv.load_fsdb.multi_cex.autogen.tcl"
JG_PROJ_DIR="$FML_OUT/jgproject"
mkdir -p "$FML_OUT"
write_fml_tcl "$FML_TCL" "$BASELINE_FSDB" "$FML_OUT"
(
  cd "$FML_OUT"
  "$BSDCOV_JG" -proj "$JG_PROJ_DIR" -fpv -tcl "$FML_TCL" -batch
)

FSDB_ROOT="$FML_OUT/traces_fsdb.bsd_cov_region_asserts/multi_cex"
if [[ ! -d "$FSDB_ROOT" ]]; then
  echo "ERROR: JasperGold did not produce multi-CEX FSDB root: $FSDB_ROOT" >&2
  exit 1
fi

log_step "6. Extract instruction words from formal FSDB traces"
INSTR_DIR="$RUN_DIR/cex_instr"
"$PYTHON_BIN" "$SCRIPT_DIR/batch_fsdb_to_instr.py" \
  --fsdb-root "$FSDB_ROOT" \
  --out-dir "$INSTR_DIR" \
  --fsdb-to-instr "$SCRIPT_DIR/fsdb_to_instr.sh" \
  --mode imem-input \
  --jobs "$JOBS"

BSDCOV_WORDS="$INSTR_DIR/bsd_cov_words.txt"
BSDCOV_WORD_COUNT="$(grep -Ec '^[0-9a-fA-F]{8}$' "$BSDCOV_WORDS" || true)"
if [[ "$BSDCOV_WORD_COUNT" -le 0 ]]; then
  echo "ERROR: no BSD-Cov instruction words were extracted" >&2
  exit 1
fi

log_step "7. Patch baseline assembly with BSD-Cov instruction words"
PATCHED_ASM="$RUN_DIR/assembly/seq.${SEED}.${BASELINE_INSTR}.bsdcov_hacked.S"
PATCHED_CHUNKS="$RUN_DIR/assembly/seq.${SEED}.${BASELINE_INSTR}.bsdcov_hacked.chunks.f"
"$PYTHON_BIN" "$SCRIPT_DIR/patch_asm.py" \
  --input-asm "$BASELINE_ASM" \
  --words "$BSDCOV_WORDS" \
  --output-asm "$PATCHED_ASM" \
  --chunk-list "$PATCHED_CHUNKS" \
  --metadata "$RUN_DIR/assembly/patch_metadata.json"

TOTAL_BSDCOV_INSTR=$((BASELINE_INSTR + BSDCOV_WORD_COUNT))

log_step "8. Run patched Baseline+BSD-Cov simulation"
"$SCRIPT_DIR/launch_sim.sh" \
  --instr-seq "$PATCHED_CHUNKS" \
  --covfile "$COVFILE" \
  --cov-update "$TOTAL_BSDCOV_INSTR" \
  $(continue_on_assert_args) \
  --jobs 1 \
  --run-tag baseline_${BASELINE_INSTR}_plus_bsdcov_${BSDCOV_WORD_COUNT}

BSDCOV_RUN="$(latest_sim_run "$RUN_DIR/sim")"
BSDCOV_SAMPLES="$BSDCOV_RUN/coverage/samples.csv"

log_step "9. Generate and run same-prefix baseline-extra comparison"
BASELINE_EXTRA_SEED="$SEED"
BASELINE_EXTRA_REQUESTED_WORD_COUNT="$BSDCOV_WORD_COUNT"
BASELINE_EXTRA_MIN_GEN_COUNT=12
BASELINE_EXTRA_TARGET_GEN_COUNT=$((BASELINE_EXTRA_REQUESTED_WORD_COUNT * 2))
if (( BASELINE_EXTRA_TARGET_GEN_COUNT < BASELINE_EXTRA_MIN_GEN_COUNT )); then
  BASELINE_EXTRA_GEN_COUNT="$BASELINE_EXTRA_MIN_GEN_COUNT"
else
  BASELINE_EXTRA_GEN_COUNT="$BASELINE_EXTRA_TARGET_GEN_COUNT"
fi
EXTRA_OUT_DIR="$RUN_DIR/riscvdv_baseline_extra/seed_${BASELINE_EXTRA_SEED}"
"$SCRIPT_DIR/rand_instr.sh" \
  --seed "$BASELINE_EXTRA_SEED" \
  --num "$BASELINE_EXTRA_GEN_COUNT" \
  --chunk-size "$BASELINE_EXTRA_GEN_COUNT" \
  --timeout-s "$RAND_TIMEOUT_S" \
  --out-dir "$EXTRA_OUT_DIR" \
  --force

BASELINE_EXTRA_ASM="$EXTRA_OUT_DIR/assembly/seq.${BASELINE_EXTRA_SEED}.${BASELINE_EXTRA_GEN_COUNT}.S"
BASELINE_EXTRA_COMPILE="$RUN_DIR/baseline_extra_compile"
"$PYTHON_BIN" "$IBEX_ROOT/vendor/google_riscv-dv/run.py" \
  --asm_test "$BASELINE_EXTRA_ASM" \
  --target rv32imc \
  --custom_target "$CORE_IBEX_DIR/riscv_dv_extension" \
  --csr_yaml "$CORE_IBEX_DIR/riscv_dv_extension/csr_description.yaml" \
  --mabi ilp32 \
  --isa rv32imc \
  --iss spike \
  --seed "$BASELINE_EXTRA_SEED" \
  --output "$BASELINE_EXTRA_COMPILE" \
  --gcc_opts=-mno-strict-align

BASELINE_EXTRA_OBJECT="$BASELINE_EXTRA_COMPILE/directed_asm_test/$(basename "${BASELINE_EXTRA_ASM%.S}").o"
BASELINE_EXTRA_CANDIDATE_WORDS="$RUN_DIR/assembly/baseline_extra_words.candidate.txt"
BASELINE_EXTRA_WORDS="$RUN_DIR/assembly/baseline_extra_words.txt"
"$PYTHON_BIN" "$SCRIPT_DIR/objdump_main_words.py" \
  --objdump "$RISCV_OBJDUMP" \
  --object "$BASELINE_EXTRA_OBJECT" \
  --out "$BASELINE_EXTRA_CANDIDATE_WORDS"

BASELINE_EXTRA_CANDIDATE_WORD_COUNT="$(grep -Ec '^[0-9a-fA-F]{4}([0-9a-fA-F]{4})?$' "$BASELINE_EXTRA_CANDIDATE_WORDS" || true)"
if (( BASELINE_EXTRA_CANDIDATE_WORD_COUNT < BASELINE_EXTRA_REQUESTED_WORD_COUNT )); then
  echo "ERROR: expected at least ${BASELINE_EXTRA_REQUESTED_WORD_COUNT} same-seed baseline-extra candidate words, got ${BASELINE_EXTRA_CANDIDATE_WORD_COUNT}" >&2
  exit 1
fi

grep -E '^[0-9a-fA-F]{4}([0-9a-fA-F]{4})?$' "$BASELINE_EXTRA_CANDIDATE_WORDS" \
  | head -n "$BASELINE_EXTRA_REQUESTED_WORD_COUNT" \
  > "$BASELINE_EXTRA_WORDS"

BASELINE_EXTRA_WORD_COUNT="$(grep -Ec '^[0-9a-fA-F]{4}([0-9a-fA-F]{4})?$' "$BASELINE_EXTRA_WORDS" || true)"
if [[ "$BASELINE_EXTRA_WORD_COUNT" -ne "$BASELINE_EXTRA_REQUESTED_WORD_COUNT" ]]; then
  echo "ERROR: expected ${BASELINE_EXTRA_REQUESTED_WORD_COUNT} truncated same-seed baseline-extra instruction words, got ${BASELINE_EXTRA_WORD_COUNT}" >&2
  exit 1
fi

BASELINE_EXTRA_PATCHED_ASM="$RUN_DIR/assembly/seq.${SEED}.${BASELINE_INSTR}.baseline_extra_hacked.S"
BASELINE_EXTRA_PATCHED_CHUNKS="$RUN_DIR/assembly/seq.${SEED}.${BASELINE_INSTR}.baseline_extra_hacked.chunks.f"
"$PYTHON_BIN" "$SCRIPT_DIR/patch_asm.py" \
  --input-asm "$BASELINE_ASM" \
  --words "$BASELINE_EXTRA_WORDS" \
  --output-asm "$BASELINE_EXTRA_PATCHED_ASM" \
  --chunk-list "$BASELINE_EXTRA_PATCHED_CHUNKS" \
  --metadata "$RUN_DIR/assembly/baseline_extra_patch_metadata.json"

TOTAL_BASELINE_EXTRA_INSTR=$((BASELINE_INSTR + BASELINE_EXTRA_WORD_COUNT))
"$SCRIPT_DIR/launch_sim.sh" \
  --instr-seq "$BASELINE_EXTRA_PATCHED_CHUNKS" \
  --covfile "$COVFILE" \
  --cov-update "$TOTAL_BASELINE_EXTRA_INSTR" \
  $(continue_on_assert_args) \
  --jobs 1 \
  --run-tag baseline_${BASELINE_INSTR}_plus_extra_${BASELINE_EXTRA_WORD_COUNT}_seed_${BASELINE_EXTRA_SEED}

BASELINE_EXTRA_RUN="$(latest_sim_run "$RUN_DIR/sim")"
BASELINE_EXTRA_STATUS="$(run_status_from_csv "$BASELINE_EXTRA_RUN/runs.csv")"
echo "Baseline-extra status: ${BASELINE_EXTRA_STATUS}"
if [[ "$BASELINE_EXTRA_STATUS" != "pass" ]]; then
  echo "ERROR: same-prefix baseline-extra run did not pass: ${BASELINE_EXTRA_STATUS}" >&2
  exit 1
fi
BASELINE_EXTRA_SAMPLES="$BASELINE_EXTRA_RUN/coverage/samples.csv"
BASELINE_EXTRA_SEED_USED="$BASELINE_EXTRA_SEED"

log_step "10. Merge baseline coverage into the final BSD-Cov / baseline-extra results"
FINAL_COVERAGE_DIR="$RUN_DIR/coverage/final_merged"
FINAL_BSDCOV_DIR="$FINAL_COVERAGE_DIR/baseline_plus_bsdcov"
FINAL_BASELINE_EXTRA_DIR="$FINAL_COVERAGE_DIR/baseline_plus_extra"

"$PYTHON_BIN" "$SCRIPT_DIR/final_merge_cov.py" \
  --source-run-dir "$BASELINE_RUN" \
  --source-run-dir "$BSDCOV_RUN" \
  --out-dir "$FINAL_BSDCOV_DIR" \
  --instruction-count "$TOTAL_BSDCOV_INSTR" \
  --case-name "baseline_plus_bsdcov_final" \
  --module ibex_top \
  --repo-root "$IBEX_ROOT"

"$PYTHON_BIN" "$SCRIPT_DIR/final_merge_cov.py" \
  --source-run-dir "$BASELINE_RUN" \
  --source-run-dir "$BASELINE_EXTRA_RUN" \
  --out-dir "$FINAL_BASELINE_EXTRA_DIR" \
  --instruction-count "$TOTAL_BASELINE_EXTRA_INSTR" \
  --case-name "baseline_extra_same_budget_final" \
  --module ibex_top \
  --repo-root "$IBEX_ROOT"

FINAL_BSDCOV_SAMPLES="$FINAL_BSDCOV_DIR/samples.csv"
FINAL_BASELINE_EXTRA_SAMPLES="$FINAL_BASELINE_EXTRA_DIR/samples.csv"

log_step "11. Write coverage comparison report"
"$PYTHON_BIN" "$SCRIPT_DIR/coverage_compare.py" \
  --baseline "$BASELINE_SAMPLES" \
  --bsdcov "$FINAL_BSDCOV_SAMPLES" \
  --baseline-extra "$FINAL_BASELINE_EXTRA_SAMPLES" \
  --out-dir "$REPORT_DIR"

cat > "$RUN_DIR/manifest.txt" <<EOF
run_tag=$RUN_TAG
baseline_instr=$BASELINE_INSTR
seed=$SEED
continue_on_assert=$CONTINUE_ON_ASSERT
rand_timeout_s=$RAND_TIMEOUT_S
covfile=$COVFILE
baseline_run=$BASELINE_RUN
baseline_fsdb=$BASELINE_FSDB
project=$PROJ_DIR
fml_out=$FML_OUT
fsdb_root=$FSDB_ROOT
bsdcov_words=$BSDCOV_WORDS
bsdcov_word_count=$BSDCOV_WORD_COUNT
patched_asm=$PATCHED_ASM
bsdcov_run=$BSDCOV_RUN
bsdcov_final_merged_dir=$FINAL_BSDCOV_DIR
bsdcov_final_samples=$FINAL_BSDCOV_SAMPLES
baseline_extra_seed=$BASELINE_EXTRA_SEED_USED
baseline_extra_requested_word_count=$BASELINE_EXTRA_REQUESTED_WORD_COUNT
baseline_extra_generation_word_count=$BASELINE_EXTRA_GEN_COUNT
baseline_extra_candidate_word_count=$BASELINE_EXTRA_CANDIDATE_WORD_COUNT
baseline_extra_words=$BASELINE_EXTRA_WORDS
baseline_extra_word_count=$BASELINE_EXTRA_WORD_COUNT
baseline_extra_run=$BASELINE_EXTRA_RUN
baseline_extra_final_merged_dir=$FINAL_BASELINE_EXTRA_DIR
baseline_extra_final_samples=$FINAL_BASELINE_EXTRA_SAMPLES
coverage_report=$REPORT_DIR/coverage_compare.md
EOF

echo
echo "BSD-Cov whole flow complete."
echo "Run directory : $RUN_DIR"
echo "Report        : $REPORT_DIR/coverage_compare.md"
