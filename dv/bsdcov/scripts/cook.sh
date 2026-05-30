#!/usr/bin/env bash
set -euo pipefail

BSDCOV_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ROOT="$(cd "$BSDCOV_DIR/../../../.." && pwd)"

BSDCOV_JG=/home/lvzhengyang/workspace/cadence/jg \
python3 "$ROOT/main.py" bsdcov cook \
  --force \
  "$BSDCOV_DIR/bsdcovproj"
