#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${BSDCOV_PYTHON:-python3}" "$SCRIPT_DIR/_gen_io.py" "$@"
