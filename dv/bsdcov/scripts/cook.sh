#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BSDCOV_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
IBEX_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
ROOT="$(cd "$BSDCOV_DIR/../../../.." && pwd)"
CORE_IBEX_DIR="$IBEX_ROOT/dv/uvm/core_ibex"
CALLER_PWD="$PWD"

# Reuse the same Ibex DV environment as launch_sim.sh so cook's NearRegion
# Xcelium evaluator sees the configured xrun wrapper, RISC-V toolchain, and
# Spike/pkg-config paths.  setup_env.sh uses relative paths, so source it from
# core_ibex and then restore the caller cwd.
if [[ -f "$CORE_IBEX_DIR/setup_env.sh" ]]; then
  pushd "$CORE_IBEX_DIR" >/dev/null
  # shellcheck disable=SC1091
  source ./setup_env.sh
  popd >/dev/null
  cd "$CALLER_PWD"
fi

# bsdcov cook uses BSDCOV_XRUN first, then CADENCE_XRUN.  If the Ibex DV setup
# provided CADENCE_XRUN, make it explicit for the NearRegion evaluator while
# still allowing the user to override BSDCOV_XRUN from the environment.
if [[ -z "${BSDCOV_XRUN:-}" && -n "${CADENCE_XRUN:-}" ]]; then
  export BSDCOV_XRUN="$CADENCE_XRUN"
fi

# Keep existing user overrides; only provide the repository-local default for
# the common local JasperGold wrapper used by this flow.
export BSDCOV_JG="${BSDCOV_JG:-/home/lvzhengyang/workspace/cadence/jg}"

python3 "$ROOT/main.py" bsdcov cook \
  --force \
  "$BSDCOV_DIR/bsdcovproj"
