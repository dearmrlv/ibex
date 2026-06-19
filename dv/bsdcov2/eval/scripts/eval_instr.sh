#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EVAL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
COMMON_INIT_DIR="$(cd "$EVAL_DIR/../common_init" && pwd)"
SEED="${SEED:-1}"
INSTR_SEQ_FILE=""
RUN_TAG=""
HANG_ON_IMEM=""

usage() {
  echo "Usage: $0 --instr-seq-file FILE --hang-on-imem on|off [--seed N] [--run-tag NAME]"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --instr-seq-file) INSTR_SEQ_FILE="$2"; shift 2 ;;
    --hang-on-imem) HANG_ON_IMEM="$2"; shift 2 ;;
    --seed) SEED="$2"; shift 2 ;;
    --run-tag) RUN_TAG="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERROR: unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[[ -n "$INSTR_SEQ_FILE" ]] || { echo "ERROR: --instr-seq-file is required" >&2; exit 2; }
[[ "$HANG_ON_IMEM" == "on" || "$HANG_ON_IMEM" == "off" ]] || {
  echo "ERROR: --hang-on-imem must be 'on' or 'off'" >&2; exit 2;
}
[[ -f "$INSTR_SEQ_FILE" ]] || { echo "ERROR: input file does not exist: $INSTR_SEQ_FILE" >&2; exit 2; }
[[ -s "$COMMON_INIT_DIR/build/common_init.bin" ]] || {
  echo "ERROR: missing common-init image: $COMMON_INIT_DIR/build/common_init.bin" >&2
  echo "Run 'make' under $COMMON_INIT_DIR first." >&2
  exit 2
}

[[ -n "$RUN_TAG" ]] || RUN_TAG="run.$(date -u +%Y%m%dT%H%M%SZ).seed${SEED}"
RUN_DIR="$EVAL_DIR/runs/$RUN_TAG"
[[ ! -e "$RUN_DIR" ]] || { echo "ERROR: run already exists: $RUN_DIR" >&2; exit 2; }
mkdir -p "$RUN_DIR/input" "$RUN_DIR/bin" "$RUN_DIR/sv" "$RUN_DIR/sim" \
  "$RUN_DIR/fsdb" "$RUN_DIR/coverage" "$RUN_DIR/logs"
cp "$INSTR_SEQ_FILE" "$RUN_DIR/input/instr_seq.txt"

python3 "$SCRIPT_DIR/_build_image.py" \
  --base-bin "$COMMON_INIT_DIR/build/common_init.bin" \
  --instr-seq-file "$RUN_DIR/input/instr_seq.txt" \
  --output-bin "$RUN_DIR/bin/eval.bin" \
  --normalized-csv "$RUN_DIR/input/instr_seq.normalized.csv" \
  --layout-json "$RUN_DIR/bin/image_layout.json" \
  --hang-on-imem "$HANG_ON_IMEM"

python3 "$SCRIPT_DIR/_emit_imem_sv.py" \
  --bin "$RUN_DIR/bin/eval.bin" --output "$RUN_DIR/sv/imem.sv"

python3 "$SCRIPT_DIR/_emit_stop_sv.py" \
  --layout-json "$RUN_DIR/bin/image_layout.json" \
  --output "$RUN_DIR/sv/eval_stop.sv"

set +e
bash "$SCRIPT_DIR/_run_sim.sh" "$RUN_DIR" "$SEED" "$HANG_ON_IMEM"
sim_rc=$?
set -e

set +e
python3 "$SCRIPT_DIR/_check_result.py" "$RUN_DIR"
check_rc=$?
set -e

ln -sfn "$RUN_TAG" "$EVAL_DIR/runs/latest"
python3 "$SCRIPT_DIR/_print_summary.py" "$RUN_DIR"

if [[ "$sim_rc" -ne 0 || "$check_rc" -ne 0 ]]; then
  exit 1
fi
