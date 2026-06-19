#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IBEX_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
CORE_IBEX_DIR="$IBEX_ROOT/dv/uvm/core_ibex"
CALLER_PWD="$PWD"
CALLER_CADENCE_XRUN="${CADENCE_XRUN:-}"

# Make the RISC-V toolchain, Spike pkg-config paths, and Cadence variables
# available to every launch_sim sub-step.  setup_env.sh uses relative paths, so
# source it from core_ibex, then restore the caller cwd.  Otherwise relative
# --instr-seq paths such as riscvdv/assembly/*.chunks.f get resolved from the
# wrong directory.
if [[ -f "$CORE_IBEX_DIR/setup_env.sh" ]]; then
  pushd "$CORE_IBEX_DIR" >/dev/null
  # shellcheck disable=SC1091
  source ./setup_env.sh
  popd >/dev/null
  cd "$CALLER_PWD"
fi

# Use the local Cadence wrapper by default.  This keeps both the Ibex DV
# compile_tb.py path and the direct xrun -R path on the same license/tool setup.
REAL_CADENCE_XRUN="${CADENCE_XRUN:-/home/lvzhengyang/workspace/cadence/xrun}"
if [[ -n "$CALLER_CADENCE_XRUN" ]]; then
  REAL_CADENCE_XRUN="$CALLER_CADENCE_XRUN"
fi
if [[ ! -x "$REAL_CADENCE_XRUN" ]]; then
  echo "ERROR: CADENCE_XRUN wrapper is not executable: $REAL_CADENCE_XRUN" >&2
  exit 1
fi

BSDCOV_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
if [[ "${BSDCOV_USE_XRUN_INTERPOSER:-0}" == "1" ]]; then
  # Interpose a tiny wrapper so BSD-Cov can add simulation-only guards without
  # touching the Ibex DV compile flow.  Only xrun -R invocations get these
  # plusargs.  Keep this opt-in for Xcelium 20.09; direct use of the Cadence csh
  # wrapper is more robust for the compile stage.
  WRAPPER_DIR="$BSDCOV_DIR/.tmp"
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
else
  export CADENCE_XRUN="$REAL_CADENCE_XRUN"
fi

PYTHON_BIN="${BSDCOV_PYTHON:-}"
if [[ -z "$PYTHON_BIN" ]]; then
  if [[ -x "$IBEX_ROOT/.venv/bin/python" ]]; then
    PYTHON_BIN="$IBEX_ROOT/.venv/bin/python"
    export VIRTUAL_ENV="$IBEX_ROOT/.venv"
    export PATH="$IBEX_ROOT/.venv/bin:$PATH"
  elif command -v uv >/dev/null 2>&1; then
    cd "$CALLER_PWD"
    exec uv run --project "$IBEX_ROOT" python "$SCRIPT_DIR/_launch_sim.py" "$@"
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

cd "$CALLER_PWD"
exec "$PYTHON_BIN" "$SCRIPT_DIR/_launch_sim.py" "$@"
