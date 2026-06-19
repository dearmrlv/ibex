#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BSDCOV_RUN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
IBEX_ROOT="$(cd "$BSDCOV_RUN_DIR/../../.." && pwd)"
REPO_ROOT="$(cd "$IBEX_ROOT/../.." && pwd)"
REFERENCE_DIR="$IBEX_ROOT/dv/bsdcov_whole_mc"
PROJ_DIR="$BSDCOV_RUN_DIR/bsdproj"
PYTHON_BIN="${BSDCOV_PYTHON:-python3}"

log_step() {
  echo
  echo "================================================================"
  echo "$*"
  echo "================================================================"
}

extract_one() {
  local label="$1"
  local outputs="$2"

  log_step "BSD-COV EXTRACT: $label"
  echo "  module        : ibex_wb_stage"
  echo "  dut_inst_hier : ibex_top.u_ibex_core.wb_stage_i"
  echo "  output_signals: $outputs"

  "$PYTHON_BIN" "$REPO_ROOT/main.py" bsdcov extract \
    --module ibex_wb_stage \
    --dut-inst-hier ibex_top.u_ibex_core.wb_stage_i \
    --output-signals "$outputs" \
    --force \
    "$PROJ_DIR"
}

log_step "RESET BSD-COV PROJECT"
rm -rf "$PROJ_DIR"

log_step "BSD-COV PREP"
"$PYTHON_BIN" "$REPO_ROOT/main.py" bsdcov prep \
  --sim-dut-inst core_ibex_tb_top.dut.u_ibex_top \
  --dut-top ibex_top \
  --dut-f "$REFERENCE_DIR/dut.f" \
  --parameter-file "$REFERENCE_DIR/parameters.txt" \
  --force \
  "$PROJ_DIR"

extract_one \
  "wb_stage.combined_ctrl" \
  "ready_wb_o,rf_write_wb_o,outstanding_load_wb_o,outstanding_store_wb_o,perf_instr_ret_wb_o,perf_instr_ret_compressed_wb_o,perf_instr_ret_compressed_wb_spec_o,rf_we_wb_o,instr_done_wb_o"

log_step "VALIDATE EXTRACTED CONES"
"$PYTHON_BIN" - "$PROJ_DIR" <<'PY'
from __future__ import annotations

import re
import sys
from pathlib import Path

proj = Path(sys.argv[1]).resolve()
expected = frozenset({
    "ready_wb_o", "rf_write_wb_o", "outstanding_load_wb_o",
    "outstanding_store_wb_o", "perf_instr_ret_wb_o",
    "perf_instr_ret_compressed_wb_o",
    "perf_instr_ret_compressed_wb_spec_o", "rf_we_wb_o",
    "instr_done_wb_o",
})

found = []
for manifest in sorted(proj.glob("cones/ibex_wb_stage-*/ibex_wb_stage-*/cone_manifest.yaml")):
    text = manifest.read_text(encoding="utf-8", errors="ignore")
    if not re.search(r'^status:\s*success\s*$', text, re.MULTILINE):
        raise SystemExit(f"ERROR: unsuccessful cone manifest: {manifest}")
    if not re.search(r'^target_module:\s*"ibex_wb_stage"\s*$', text, re.MULTILINE):
        raise SystemExit(f"ERROR: wrong target module: {manifest}")
    endpoint_block = text.split("boundaries:", 1)[0]
    names = frozenset(re.findall(r'^\s+- name:\s*"([^"]+)"', endpoint_block, re.MULTILINE))
    if names != expected:
        raise SystemExit(f"ERROR: unexpected endpoint set in {manifest}: {sorted(names)}")
    diagnostic_match = re.search(r'^diagnostics:\s*\n\s+count:\s*(\d+)', text, re.MULTILINE)
    if diagnostic_match is None or int(diagnostic_match.group(1)) != 0:
        raise SystemExit(f"ERROR: cone has diagnostics: {manifest}")
    count_match = re.search(r'^endpoints:\s*\n\s+count:\s*(\d+)', text, re.MULTILINE)
    expected_count = len(expected)
    if count_match is None or int(count_match.group(1)) != expected_count:
        raise SystemExit(f"ERROR: endpoint count mismatch: {manifest}")
    boundary_match = re.search(r'^boundaries:\s*\n\s+count:\s*(\d+)', text, re.MULTILINE)
    node_count = len(re.findall(r'^    - name:', text.split("instances:", 1)[1].split("diagnostics:", 1)[0], re.MULTILINE))
    found.append((manifest.parent, manifest, int(boundary_match.group(1)), node_count))

if len(found) != 1:
    raise SystemExit(f"ERROR: expected exactly one ibex_wb_stage cone, found {len(found)}")

cone_dir, manifest, boundaries, nodes = found[0]
print("[PASS] wb_stage.combined_ctrl")
print(f"  cone_dir   : {cone_dir}")
print(f"  endpoints  : {len(expected)}")
print(f"  boundaries : {boundaries}")
print(f"  nodes      : {nodes}")
print(f"  manifest   : {manifest}")
PY

log_step "BSD-COV WRITEBACK CONE EXTRACTION COMPLETE"
echo "Project: $PROJ_DIR"
echo "IO dump bind filelist: $PROJ_DIR/db/io_dump.f"
