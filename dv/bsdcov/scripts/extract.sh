#!/usr/bin/env bash
set -euo pipefail

BSDCOV_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ROOT="$(cd "$BSDCOV_DIR/../../../.." && pwd)"

python3 - <<'PY'
from pathlib import Path

from src.stages.conegen import run_conegen_stage

root = Path("/home/lvzhengyang/workspace/BSD-Cov")
bsdcov_dir = root / "designs" / "ibex" / "dv" / "bsdcov"

run_conegen_stage(
    design="ibex",
    seed_path=root / "designs" / "ibex" / "dv" / "bsdcov.old" / "targets" / "hazard_stall.seed.yaml",
    out_target=bsdcov_dir / "bsdcovproj" / "targets" / "hazard_stall.yaml",
    run_dir=bsdcov_dir / "bsdcovproj" / "hazard_stall_extract",
    verific_tool=root / "src" / "tools" / "verific_conegen" / "build" / "verific_conegen",
    install_trace_bind=False,
    allow_static_fallback=False,
    force=True,
)
PY
