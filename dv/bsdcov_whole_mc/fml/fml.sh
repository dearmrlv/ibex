#!/usr/bin/env bash
set -euo pipefail

TCL="${1:-fpv.load_fsdb.multi_cex.autogen.tcl}"
JG="${BSDCOV_JG:-/home/lvzhengyang/workspace/cadence/jg}"

if [[ ! -f "$TCL" ]]; then
  echo "ERROR: $TCL does not exist." >&2
  echo "Run ../scripts/whole_flow.sh, or pass an explicit Tcl file to fml.sh." >&2
  exit 1
fi

"$JG" -fpv -tcl "$TCL" -batch
