#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGETS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CPP_DIR="$TARGETS_DIR/extract/cpp"
BUILD_DIR="${BSDCOV_SIG_EXTRACT_BUILD_DIR:-$CPP_DIR/build}"
JOBS="${JOBS:-$(nproc 2>/dev/null || echo 4)}"

if [[ ! -f "$CPP_DIR/CMakeLists.txt" ]]; then
  echo "ERROR: CMakeLists.txt not found under $CPP_DIR" >&2
  exit 1
fi

cmake -S "$CPP_DIR" -B "$BUILD_DIR"
cmake --build "$BUILD_DIR" -j "$JOBS"

BIN="$BUILD_DIR/bsdcov_sig_extract"
if [[ ! -x "$BIN" ]]; then
  echo "ERROR: expected extractor binary was not produced: $BIN" >&2
  exit 1
fi

echo "Built: $BIN"
