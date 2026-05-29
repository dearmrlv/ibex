#!/usr/bin/env bash
set -euo pipefail

BSDCOV_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ROOT="$(cd "$BSDCOV_DIR/../../../.." && pwd)"

python3 "$ROOT/main.py" bsdcov prep \
  --sim-dut-inst core_ibex_tb_top.dut.u_ibex_top \
  --dut-top ibex_top \
  --dut-f "$BSDCOV_DIR/dut.f" \
  --parameter-file "$BSDCOV_DIR/parameters.txt" \
  --force \
  "$BSDCOV_DIR/bsdcovproj"
