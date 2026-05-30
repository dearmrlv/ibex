#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IBEX_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

PYTHON_BIN="${BSDCOV_PYTHON:-}"
if [[ -z "$PYTHON_BIN" ]]; then
  if [[ -x "$IBEX_ROOT/.venv/bin/python" ]]; then
    PYTHON_BIN="$IBEX_ROOT/.venv/bin/python"
    export VIRTUAL_ENV="$IBEX_ROOT/.venv"
    export PATH="$IBEX_ROOT/.venv/bin:$PATH"
  elif command -v uv >/dev/null 2>&1; then
    cd "$IBEX_ROOT"
    exec uv run python "$SCRIPT_DIR/_launch_sim.py" "$@"
  else
    PYTHON_BIN="$(command -v python3)"
  fi
else
  PYTHON_DIR="$(cd "$(dirname "$PYTHON_BIN")" && pwd)"
  export PATH="$PYTHON_DIR:$PATH"
  if [[ "$PYTHON_DIR" == */.venv/bin ]]; then
    export VIRTUAL_ENV="${PYTHON_DIR%/bin}"
  fi
fi

exec "$PYTHON_BIN" "$SCRIPT_DIR/_launch_sim.py" "$@"
