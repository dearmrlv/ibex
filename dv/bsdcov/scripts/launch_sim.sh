#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IBEX_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Use the local Cadence wrapper by default.  This keeps both the Ibex DV
# compile_tb.py path and the direct xrun -R path on the same license/tool setup.
REAL_CADENCE_XRUN="${CADENCE_XRUN:-/home/lvzhengyang/workspace/cadence/xrun}"
if [[ ! -x "$REAL_CADENCE_XRUN" ]]; then
  echo "ERROR: CADENCE_XRUN wrapper is not executable: $REAL_CADENCE_XRUN" >&2
  exit 1
fi

# Interpose a tiny wrapper so BSD-Cov can add simulation-only guards without
# touching the Ibex DV compile flow.  Only xrun -R invocations get these plusargs.
# The real xrun wrapper remains /home/lvzhengyang/workspace/cadence/xrun unless
# CADENCE_XRUN was explicitly set by the user.
WRAPPER_DIR="$IBEX_ROOT/dv/bsdcov/.tmp"
mkdir -p "$WRAPPER_DIR"
BSDCOV_XRUN_WRAPPER="$WRAPPER_DIR/xrun.bsdcov"
cat > "$BSDCOV_XRUN_WRAPPER" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

REAL_XRUN="${BSDCOV_REAL_XRUN:?BSDCOV_REAL_XRUN is not set}"
is_runtime=0
for arg in "$@"; do
  if [[ "$arg" == "-R" ]]; then
    is_runtime=1
    break
  fi
done

extra=()
if [[ "$is_runtime" == 1 ]]; then
  extra+=("+signature_addr=${BSDCOV_SIGNATURE_ADDR:-8ffffffc}")
  extra+=("+test_timeout_s=${BSDCOV_RTL_TIMEOUT_S:-300}")
  if [[ "${BSDCOV_DISABLE_COSIM:-1}" != "0" ]]; then
    extra+=("+disable_cosim=1")
  fi
fi

exec "$REAL_XRUN" "$@" "${extra[@]}"
EOF
chmod +x "$BSDCOV_XRUN_WRAPPER"

export BSDCOV_REAL_XRUN="$REAL_CADENCE_XRUN"
export CADENCE_XRUN="$BSDCOV_XRUN_WRAPPER"

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
