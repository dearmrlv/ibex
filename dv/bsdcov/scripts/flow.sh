#!/usr/bin/env bash
set -euo pipefail

BSDCOV_DIR="$(cd "$(dirname "$0")/.." && pwd)"

cd "$BSDCOV_DIR"

./scripts/prep.sh
./scripts/extract.sh
./scripts/rand_instr.sh --seed 1 --num 300 --chunk-size 100 --force
./scripts/launch_sim.sh \
  --instr-seq riscvdv/assembly/seq.1.300.chunks.f \
  --bind-flist bsdcovproj/sim_bind.f \
  --cov-update 100 \
  --jobs 3

RUN=""
if [[ -L sim/latest || -e sim/latest ]]; then
  RUN="$(readlink -f sim/latest 2>/dev/null || true)"
fi
if [[ -z "$RUN" && -f sim/latest.txt ]]; then
  RUN="$(cat sim/latest.txt)"
fi
if [[ -z "$RUN" || ! -d "$RUN" ]]; then
  echo "BSD-COV ERROR: launch_sim did not create a valid sim/latest run directory" >&2
  exit 1
fi

if [[ -f "$RUN/runs.csv" ]]; then
  echo "BSD-COV: simulation run summary: $RUN/runs.csv"
  cat "$RUN/runs.csv"
fi

if [[ ! -f "$RUN/io_samples/manifest.csv" ]]; then
  echo "BSD-COV ERROR: launch_sim produced no IO sample manifest; refusing to run cook." >&2
  echo "Inspect failing chunk logs under: $RUN/chunks/chunk_*/" >&2
  find "$RUN/chunks" -maxdepth 2 -type f \( -name 'error.txt' -o -name 'rtl_sim.log' -o -name 'launch_rtl.log' \) -print >&2 || true
  exit 1
fi

python3 - <<'PY' "$RUN/io_samples/manifest.csv"
import csv
import sys
from pathlib import Path

manifest = Path(sys.argv[1])
rows = list(csv.DictReader(manifest.open()))
num_rows = sum(int(row.get("num_rows") or 0) for row in rows)
if num_rows <= 0:
    raise SystemExit(f"BSD-COV ERROR: IO sample manifest has zero rows: {manifest}")
print(f"BSD-COV: collected {num_rows} IO sample rows across {len(rows)} cone(s)")
PY

./scripts/cook.sh
