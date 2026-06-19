#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/test.sh [--fsdb <eval.fsdb>] [--no-fsdb]

Environment:
  BSDCOV_SIG_EXTRACT_BUILD_DIR  Override C++ build directory
  VERDI_HOME                    Override Verdi home
  JOBS                          Build parallelism
EOF
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGETS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SCRIPTS_ROOT="$(cd "$TARGETS_DIR/.." && pwd)"
INSTR_GEN_DIR="$(cd "$SCRIPTS_ROOT/.." && pwd)"
EXTRACT_DIR="$TARGETS_DIR/extract"
CPP_DIR="$EXTRACT_DIR/cpp"
BUILD_DIR="${BSDCOV_SIG_EXTRACT_BUILD_DIR:-$CPP_DIR/build}"
EXTRACTOR_BIN="$BUILD_DIR/bsdcov_sig_extract"
VERDI_HOME="${VERDI_HOME:-/home/lvzhengyang/workspace/synopsys/verdi/T-2022.06}"
FSDB=""
NO_FSDB=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --fsdb)
      [[ $# -ge 2 ]] || { echo "ERROR: --fsdb requires a path" >&2; exit 2; }
      FSDB="$2"
      shift 2
      ;;
    --no-fsdb)
      NO_FSDB=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ "$NO_FSDB" == 1 && -n "$FSDB" ]]; then
  echo "ERROR: --fsdb and --no-fsdb are mutually exclusive" >&2
  exit 2
fi

"$SCRIPT_DIR/build.sh"

python3 -m py_compile "$EXTRACT_DIR/_sig_note.py"

REQ_DIR="$(mktemp -d)"
trap 'rm -rf "$REQ_DIR"' EXIT
REQ_JSON="$REQ_DIR/request.json"
OUT_JSON="$REQ_DIR/signals.json"
DUT_F="$SCRIPTS_ROOT/fml_template/dut.f"

if [[ ! -f "$DUT_F" ]]; then
  echo "ERROR: DUT filelist not found: $DUT_F" >&2
  exit 1
fi

cat > "$REQ_JSON" <<EOF
{
  "filelists": ["$DUT_F"],
  "top": "ibex_top",
  "defines": ["SYNTHESIS"],
  "include_dirs": [],
  "parameters": {
    "RV32E": 0,
    "RV32M": "{ibex_pkg::RV32MSingleCycle}",
    "RV32B": "{ibex_pkg::RV32BOTEarlGrey}",
    "RV32ZC": "{ibex_pkg::RV32ZcaZcbZcmp}",
    "RegFile": "{ibex_pkg::RegFileFF}",
    "BranchTargetALU": 1,
    "WritebackStage": 1,
    "ICache": 1,
    "ICacheECC": 1,
    "ICacheScramble": 1,
    "ICacheTweakInfection": 0,
    "BranchPredictor": 0,
    "DbgTriggerEn": 1,
    "DbgHwBreakNum": 1,
    "SecureIbex": 1,
    "LockstepOffset": 1,
    "PMPEnable": 1,
    "PMPGranularity": 0,
    "PMPNumRegions": 16,
    "MHPMCounterNum": 10,
    "MHPMCounterWidth": 32,
    "DmBaseAddr": "32'h1A110000",
    "DmAddrMask": "32'h00000FFF",
    "DmHaltAddr": "32'h80000000",
    "DmExceptionAddr": "32'h80000008"
  }
}
EOF

"$EXTRACTOR_BIN" --request "$REQ_JSON" > "$OUT_JSON"

python3 - "$OUT_JSON" <<'PY'
import json
import sys
from collections import Counter

path = sys.argv[1]
data = json.load(open(path, encoding="utf-8"))
signals = data.get("signals", [])
if not signals:
    raise SystemExit("ERROR: extractor produced no signals")
kinds = Counter(item.get("type") for item in signals)
if kinds["OneBit"] <= 0:
    raise SystemExit("ERROR: extractor produced no OneBit signals")
if kinds["FsmState"] <= 0:
    raise SystemExit("ERROR: extractor produced no FsmState signals")
ctrl = [item for item in signals if item.get("name") == "ctrl_fsm_cs"]
if not any(item.get("width") == 4 for item in ctrl):
    raise SystemExit("ERROR: ctrl_fsm_cs was not extracted as 4-bit FSM state")
print(f"C++ smoke: signals={len(signals)} OneBit={kinds['OneBit']} FsmState={kinds['FsmState']}")
PY

PYTHONPATH="$EXTRACT_DIR${PYTHONPATH:+:$PYTHONPATH}" python3 - <<'PY'
from _sig_note import FsmState, OneBit, SigDisappear, SigSet

missing = SigDisappear("sig", "1'b1", "ONE")
one = OneBit(name="sig", instance="top", module="m", width=1,
             legal_values=[missing], disappear_vals=[missing])
fsm = FsmState(name="state_q", instance="top", module="m", width=2,
               legal_values=[missing], disappear_vals=[missing])
if one.hier_name != "top.sig" or fsm.hier_name != "top.state_q":
    raise SystemExit("ERROR: Python API smoke failed")
print("Python API smoke: ok")
PY

if [[ "$NO_FSDB" == 0 && -z "$FSDB" ]]; then
  FSDB="$(find "$INSTR_GEN_DIR/runs" -path '*/iterations/*/simulation/fsdb/eval.fsdb' -type f -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2- || true)"
fi

if [[ "$NO_FSDB" == 1 ]]; then
  echo "FSDB smoke: skipped (--no-fsdb)"
elif [[ -z "$FSDB" ]]; then
  echo "FSDB smoke: skipped (no eval.fsdb found under $INSTR_GEN_DIR/runs)"
elif [[ ! -f "$FSDB" ]]; then
  echo "ERROR: FSDB not found: $FSDB" >&2
  exit 1
else
  PYTHONPATH="$EXTRACT_DIR${PYTHONPATH:+:$PYTHONPATH}" python3 - "$FSDB" "$DUT_F" "$EXTRACTOR_BIN" "$VERDI_HOME" "$REQ_DIR/sig_note_smoke.sv" <<'PY'
from pathlib import Path
from collections import Counter
import sys

from _sig_note import SigSet

fsdb = Path(sys.argv[1])
dut_f = Path(sys.argv[2])
extractor = Path(sys.argv[3])
verdi = Path(sys.argv[4])
sva = Path(sys.argv[5])
params = {
    "RV32E": 0,
    "RV32M": "{ibex_pkg::RV32MSingleCycle}",
    "RV32B": "{ibex_pkg::RV32BOTEarlGrey}",
    "RV32ZC": "{ibex_pkg::RV32ZcaZcbZcmp}",
    "RegFile": "{ibex_pkg::RegFileFF}",
    "BranchTargetALU": 1,
    "WritebackStage": 1,
    "ICache": 1,
    "ICacheECC": 1,
    "ICacheScramble": 1,
    "ICacheTweakInfection": 0,
    "BranchPredictor": 0,
    "DbgTriggerEn": 1,
    "DbgHwBreakNum": 1,
    "SecureIbex": 1,
    "LockstepOffset": 1,
    "PMPEnable": 1,
    "PMPGranularity": 0,
    "PMPNumRegions": 16,
    "MHPMCounterNum": 10,
    "MHPMCounterWidth": 32,
    "DmBaseAddr": "32'h1A110000",
    "DmAddrMask": "32'h00000FFF",
    "DmHaltAddr": "32'h80000000",
    "DmExceptionAddr": "32'h80000008",
}
sigset = SigSet(
    fsdb=fsdb,
    dut_f=dut_f,
    dut_top="ibex_top",
    sim_dut_top="core_ibex_tb_top.dut.u_ibex_top",
    parameters=params,
    defines=["SYNTHESIS"],
    extractor_bin=extractor,
    verdi=verdi,
)
if not sigset.signals:
    raise SystemExit("ERROR: SigSet extracted no FSDB-matched signals")
missing = sum(len(signal.disappear_vals) for signal in sigset.signals)
if missing > 0:
    sigset.random_select_disappears(1, seed=1).dump_sva(sva)
    if not sva.is_file() or sva.stat().st_size == 0:
        raise SystemExit("ERROR: dump_sva did not create output")
kinds = Counter(signal.type for signal in sigset.signals)
print(f"FSDB smoke: fsdb={fsdb}")
print(f"FSDB smoke: signals={len(sigset.signals)} OneBit={kinds['OneBit']} FsmState={kinds['FsmState']} diagnostics={len(sigset.diagnostics)} missing_values={missing}")
PY
fi

echo "All target extraction tests passed."
