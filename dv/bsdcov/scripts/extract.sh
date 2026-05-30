#!/usr/bin/env bash
set -euo pipefail

BSDCOV_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ROOT="$(cd "$BSDCOV_DIR/../../../.." && pwd)"

python3 "$ROOT/main.py" bsdcov extract \
  --module ibex_id_stage \
  --output-signals stall_mem,stall_multdiv,stall_branch,stall_jump \
  --force \
  "$BSDCOV_DIR/bsdcovproj"
