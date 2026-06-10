#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ITER_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEFAULT_FSDB="$ITER_DIR/fml/fsdb/1.p.u_ibex_core.id_stage_i.u_bsdcov_regions_ibex_id_stage_02cf625a91.AST_BSDCOV_ibex_id_stage_02cf625a91_R_unique_006.U2.103.fsdb"
FSDB="${BSDCOV_GENBIN_FSDB:-$DEFAULT_FSDB}"
OUT_DIR="${BSDCOV_GENBIN_OUT_DIR:-$ITER_DIR/bin4sim}"
OUT_BIN="${BSDCOV_GENBIN_OUT_BIN:-$OUT_DIR/fsdb_image.bin}"

mkdir -p "$OUT_DIR"
exec "${BSDCOV_PYTHON:-python3}" "$SCRIPT_DIR/_fsdb2bin.py" \
  --fsdb "$FSDB" --out-bin "$OUT_BIN" \
  --base-addr "${BSDCOV_GENBIN_BASE_ADDR:-0x80000000}"
