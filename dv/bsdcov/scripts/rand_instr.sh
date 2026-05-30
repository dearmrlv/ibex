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
    exec uv run python "$SCRIPT_DIR/_rand_instr.py" --num-of-sub-program 0 "$@"
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

# BSD-Cov chunk generation uses independent standalone tests.  Default to no
# riscv-dv sub-programs to avoid the pyflow callstack path, which is broken in
# this vendored riscv-dv revision.  A user-provided --num-of-sub-program later
# on the command line overrides this default through argparse's normal last-wins
# behavior.
exec "$PYTHON_BIN" "$SCRIPT_DIR/_rand_instr.py" --num-of-sub-program 0 "$@"
