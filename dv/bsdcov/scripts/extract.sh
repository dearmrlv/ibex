#!/usr/bin/env bash
set -euo pipefail

BSDCOV_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ROOT="$(cd "$BSDCOV_DIR/../../../.." && pwd)"

python3 "$ROOT/main.py" bsdcov extract \
  --module ibex_id_stage \
  --dut-inst-hier u_ibex_core.id_stage_i \
  --output-signals stall_mem,stall_multdiv,stall_branch,stall_jump \
  --force \
  "$BSDCOV_DIR/bsdcovproj"
