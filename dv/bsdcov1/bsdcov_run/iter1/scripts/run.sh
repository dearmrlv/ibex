#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ITER_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BSDCOV1_DIR="$(cd "$ITER_DIR/../.." && pwd)"
IBEX_ROOT="$(cd "$BSDCOV1_DIR/../.." && pwd)"
REPO_ROOT="$(cd "$IBEX_ROOT/../.." && pwd)"
CORE_IBEX_DIR="$IBEX_ROOT/dv/uvm/core_ibex"
COMMON_PROJ="$ITER_DIR/../common/bsdproj"
PROJ_DIR="$ITER_DIR/bsdproj"
SIM_DIR="$ITER_DIR/sim"
TB_OUT="$SIM_DIR/ibex_dv_out"
TB_DIR="$TB_OUT/build/tb"
IO_DIR="$SIM_DIR/io"
FSDB_DIR="$SIM_DIR/fsdb"
LOG_DIR="$SIM_DIR/logs"

BSDCOV_BIN="${BSDCOV_BIN:-$BSDCOV1_DIR/cpu_init/build/init_only.bin}"
BSDCOV_PYTHON="${BSDCOV_PYTHON:-python3}"
BSDCOV_XRUN="${BSDCOV_XRUN:-/home/lvzhengyang/workspace/cadence/xrun}"
BSDCOV_JG="${BSDCOV_JG:-/home/lvzhengyang/workspace/cadence/jg}"
BSDCOV_SEED="${BSDCOV_SEED:-1}"
BSDCOV_XRUN_TIMEOUT_S="${BSDCOV_XRUN_TIMEOUT_S:-300}"

log_step() {
  echo
  echo "================================================================"
  echo "$*"
  echo "================================================================"
}

write_status() {
  local status="$1"
  local stage="$2"
  local detail="$3"
  cat > "$ITER_DIR/run_status.toml" <<EOF
status = "$status"
stage = "$stage"
detail = "$detail"
binary = "$BSDCOV_BIN"
project = "$PROJ_DIR"
simulation = "$SIM_DIR"
fsdb = "$FSDB_DIR/iter1.fsdb"
EOF
}

fail() {
  write_status "failed" "$1" "$2"
  echo "ERROR: $2" >&2
  exit 1
}

if [[ ! -d "$COMMON_PROJ" ]]; then
  fail "copy" "common project does not exist: $COMMON_PROJ"
fi
if [[ ! -s "$BSDCOV_BIN" ]]; then
  fail "input" "BSDCOV_BIN does not exist or is empty: $BSDCOV_BIN"
fi
if [[ ! -x "$BSDCOV_XRUN" ]]; then
  fail "input" "xrun is not executable: $BSDCOV_XRUN"
fi

log_step "1. Copy common BSD-Cov project"
rm -rf "$PROJ_DIR" "$SIM_DIR"
mkdir -p "$ITER_DIR" "$SIM_DIR" "$IO_DIR" "$FSDB_DIR" "$LOG_DIR"
cp -a "$COMMON_PROJ" "$PROJ_DIR"

# Extract artifacts contain absolute project paths. Relocate all text files so
# aggregate and per-cone filelists refer to this iteration's private copy.
"$BSDCOV_PYTHON" - "$PROJ_DIR" "$COMMON_PROJ" <<'PY'
import sys
from pathlib import Path

root = Path(sys.argv[1])
old = sys.argv[2].encode()
new = str(root).encode()
for path in root.rglob("*"):
    if not path.is_file():
        continue
    data = path.read_bytes()
    if b"\x00" in data or old not in data:
        continue
    path.write_bytes(data.replace(old, new))
PY

log_step "2. Compile Ibex testbench with IO-dump binds and FSDB PLI"
pushd "$CORE_IBEX_DIR" >/dev/null
# shellcheck disable=SC1091
source ./setup_env.sh
popd >/dev/null

export IBEX_ROOT PRJ_DIR="$IBEX_ROOT" LOWRISC_IP_DIR="$IBEX_ROOT/vendor/lowrisc_ip"
export DUT_TOP=ibex_top dv_root="$IBEX_ROOT/vendor/lowrisc_ip/dv"
export EXTRA_COSIM_CFLAGS="${EXTRA_COSIM_CFLAGS:-}"
export CADENCE_XRUN="$BSDCOV_XRUN"
export VERDI_HOME="${VERDI_HOME:-/home/lvzhengyang/workspace/synopsys/verdi/T-2022.06}"
export BSD_COV_EXTRA_XRUN_FILELISTS="$PROJ_DIR/db/io_dump.f"
export BSD_COV_EXTRA_XRUN_COMPILE_OPTS="-access +rwc -loadpli1 debpli:novas_pli_boot"
unset BSDCOV_REUSE_TB_DIR BSDCOV_PROJECT_DIR BSDCOV_SIM_DIR

set +e
(
  cd "$CORE_IBEX_DIR"
  make -B --keep-going GOAL=rtl_tb_compile OUT="$TB_OUT" \
    IBEX_CONFIG=opentitan SIMULATOR=xlm ISS=spike TEST=empty ITERATIONS=1 \
    SEED="$BSDCOV_SEED" WAVES=0 COV=0 VERBOSE=0
) >"$LOG_DIR/rtl_tb_compile.log" 2>&1
compile_rc=$?
set -e
if [[ "$compile_rc" -ne 0 ]]; then
  fail "compile" "Ibex testbench compilation failed; see $LOG_DIR/rtl_tb_compile.log"
fi

log_step "3. Run raw binary and collect IO samples plus FSDB"
UCLI="$SIM_DIR/xrun.ucli.cmd"
cat > "$UCLI" <<EOF
call fsdbDumpfile {"$FSDB_DIR/iter1.fsdb"}
call fsdbDumpvars {0} {core_ibex_tb_top} {"+mda"} {"+struct"} {"+parameter"}
call fsdbDumpSVA
run
exit
EOF

TRACE_BASE="$IO_DIR/bsdcov_trace"
set +e
(
  cd "$CORE_IBEX_DIR"
  timeout --signal=TERM --kill-after=15s "${BSDCOV_XRUN_TIMEOUT_S}s" \
    "$BSDCOV_XRUN" -64bit -R -xmlibdirpath "$TB_DIR" -licqueue \
    -svseed "$BSDCOV_SEED" -svrnc rand_struct -nokey \
    -l "$SIM_DIR/rtl_sim.log" \
    +UVM_TESTNAME=core_ibex_base_test +UVM_VERBOSITY=UVM_LOW \
    +bin="$BSDCOV_BIN" +signature_addr=8ffffffc +test_timeout_s=60 \
    +disable_cosim=1 +bsdcov_io_dump +bsdcov_trace_base="$TRACE_BASE" \
    +ibex_tracer_file_base="$SIM_DIR/trace_core" -input "$UCLI"
) >"$LOG_DIR/launch_rtl.log" 2>&1
xrun_rc=$?
set -e
echo "$xrun_rc" > "$SIM_DIR/xrun.exit_code"

combined_log="$SIM_DIR/rtl_sim.log"
if [[ "$xrun_rc" -ne 0 ]]; then
  fail "simulation" "xrun failed with exit code $xrun_rc; see $LOG_DIR/launch_rtl.log"
fi
grep -Fq "Test done due to RISCV-DV handshake (payload=TEST_PASS)" "$combined_log" \
  || fail "simulation" "TEST_PASS handshake was not observed"
grep -Eq '^UVM_ERROR[[:space:]]*:[[:space:]]*0[[:space:]]*$' "$combined_log" \
  || fail "simulation" "UVM_ERROR summary is missing or non-zero"
grep -Eq '^UVM_FATAL[[:space:]]*:[[:space:]]*0[[:space:]]*$' "$combined_log" \
  || fail "simulation" "UVM_FATAL summary is missing or non-zero"
[[ -s "$FSDB_DIR/iter1.fsdb" ]] || fail "simulation" "FSDB was not generated"

log_step "4. Import IO samples into the copied project"
"$BSDCOV_PYTHON" - "$PROJ_DIR" "$IO_DIR" <<'PY'
import csv
import shutil
import sys
from pathlib import Path

project = Path(sys.argv[1])
io_dir = Path(sys.argv[2])
rows = []
for cone_dir in sorted(project.glob("cones/*/*")):
    cone = cone_dir.name
    src = io_dir / f"bsdcov_trace_{cone}.io_samples.csv"
    dst = cone_dir / "io_dump" / f"{cone}.io_samples.csv"
    count = 0
    if src.exists():
        with src.open(encoding="utf-8", errors="ignore") as fd:
            count = max(sum(1 for line in fd if line.strip()) - 1, 0)
        shutil.copy2(src, dst)
    rows.append((cone, src, dst, count))

with (io_dir / "manifest.csv").open("w", newline="", encoding="utf-8") as fd:
    writer = csv.writer(fd)
    writer.writerow(["cone_name", "source", "project_sample", "num_rows"])
    writer.writerows(rows)

missing = [cone for cone, _, _, count in rows if count == 0]
print(f"Imported non-empty IO samples for {len(rows) - len(missing)}/{len(rows)} cone(s)")
if missing:
    print("No usable rows: " + ", ".join(missing))
PY

log_step "5. Train BSD, find CEX/Region, and generate Instr Gen binds"
export BSDCOV_XRUN="$BSDCOV_XRUN"
export BSDCOV_JG="$BSDCOV_JG"
export BSDCOV_BSD_THREADS="${BSDCOV_BSD_THREADS:-8}"
set +e
"$BSDCOV_PYTHON" "$REPO_ROOT/main.py" bsdcov cook --force "$PROJ_DIR" \
  > >(tee "$LOG_DIR/cook.log") 2>&1
cook_rc=$?
set -e
echo "$cook_rc" > "$SIM_DIR/cook.exit_code"

# cook_full_layout only publishes results after a fully successful Cook. Build
# the same public result set from whichever cones completed when Cook is partial.
set +e
"$BSDCOV_PYTHON" - "$PROJ_DIR" "$cook_rc" <<'PY'
import csv
import shutil
import sys
from pathlib import Path

project = Path(sys.argv[1])
cook_rc = int(sys.argv[2])
results = project / "results"
results.mkdir(parents=True, exist_ok=True)
for old in results.glob("*.regions.bind.sv"):
    old.unlink()

binds = []
for cone_dir in sorted(project.glob("cones/*/*")):
    candidates = list(cone_dir.glob("region/sv/*.regions.bind.sv"))
    candidates += list(cone_dir.glob("cmp/region/sv/*.regions.bind.sv"))
    if not candidates:
        continue
    src = candidates[0]
    dst = results / f"{cone_dir.parent.name}__{cone_dir.name}.regions.bind.sv"
    shutil.copy2(src, dst)
    binds.append(dst)

bsdcov_f = results / "bsdcov.f"
bsdcov_f.write_text(
    "# Generated by iter1 from successful BSD-Cov Cook cones.\n"
    + "".join(f"{path}\n" for path in binds),
    encoding="utf-8",
)

seen = len(list(project.glob("cones/*/*")))
failed = seen - len(binds)
status = "generated" if cook_rc == 0 else "partial"
(results / "results_status.toml").write_text(
    f'status = "{status}"\n'
    f'cook_exit_code = {cook_rc}\n'
    f'cones_seen = {seen}\n'
    f'cones_succeeded = {len(binds)}\n'
    f'cones_failed = {failed}\n'
    f'bsdcov_f = "{bsdcov_f}"\n',
    encoding="utf-8",
)
print(f"Cook result: {status}; successful cones={len(binds)}/{seen}")
if not binds:
    raise SystemExit(2)
PY
collect_rc=$?
set -e

if [[ "$collect_rc" -ne 0 ]]; then
  fail "cook" "Cook produced no usable Region bind files"
fi

sample_files=$(find "$IO_DIR" -maxdepth 1 -type f -name '*.io_samples.csv' | wc -l)
region_files=$(find "$PROJ_DIR/results" -maxdepth 1 -type f -name '*.regions.bind.sv' | wc -l)
cat > "$ITER_DIR/run_status.toml" <<EOF
status = "completed"
stage = "results"
binary = "$BSDCOV_BIN"
project = "$PROJ_DIR"
simulation = "$SIM_DIR"
fsdb = "$FSDB_DIR/iter1.fsdb"
xrun_exit_code = $xrun_rc
cook_exit_code = $cook_rc
io_sample_files = $sample_files
region_bind_files = $region_files
bsdcov_f = "$PROJ_DIR/results/bsdcov.f"
EOF

log_step "ITER1 COMPLETE"
echo "Binary       : $BSDCOV_BIN"
echo "Project      : $PROJ_DIR"
echo "FSDB         : $FSDB_DIR/iter1.fsdb"
echo "IO manifest  : $IO_DIR/manifest.csv"
echo "Cook log     : $LOG_DIR/cook.log"
echo "Instr Gen f  : $PROJ_DIR/results/bsdcov.f"
echo "Cook exit    : $cook_rc (partial success is allowed)"
