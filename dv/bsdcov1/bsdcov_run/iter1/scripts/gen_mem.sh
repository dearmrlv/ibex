#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ITER_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BSDCOV1_DIR="$(cd "$ITER_DIR/../.." && pwd)"
BSDCOV_BIN="${BSDCOV_BIN:-$BSDCOV1_DIR/cpu_init/build/init_only.bin}"
BSDCOV_PYTHON="${BSDCOV_PYTHON:-python3}"

IMEM_SV="$ITER_DIR/fml/env/imem.sv"
BASE_ADDR="0x80000000"

$BSDCOV_PYTHON $SCRIPT_DIR/_bin2imem_sv.py $BSDCOV_BIN -o $IMEM_SV \
  --base-addr $BASE_ADDR