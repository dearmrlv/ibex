#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASELINE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BSDCOV2_DIR="$(cd "$BASELINE_DIR/.." && pwd)"
IBEX_ROOT="$(cd "$BASELINE_DIR/../../.." && pwd)"
BSDCOV_DIR="$IBEX_ROOT/dv/bsdcov"
CADENCE_WRAPPER_DIR="/home/lvzhengyang/workspace/cadence"

if [[ -d "$CADENCE_WRAPPER_DIR" ]]; then
  export PATH="$CADENCE_WRAPPER_DIR:$PATH"
fi

DEFAULT_REFERENCE_BIN="$BSDCOV2_DIR/instr_gen3/runs/run.20260612T110926Z.seed1/images/accepted_0033.bin"
DEFAULT_COMMON_PREFIX_BIN="$BSDCOV2_DIR/common_init/build/common_init.bin"

seed=1
reference_bin="$DEFAULT_REFERENCE_BIN"
common_prefix_bin="$DEFAULT_COMMON_PREFIX_BIN"
target_words=""
run_tag=""
jobs=1
timeout_s=1800
generator_simulator=pyflow
force_compile=0
fsdb=0
coverage=1
bsdcov_io_dump=1
dry_run=0
keep_going_assert=1
reuse_tb_dir="${BSDCOV_REUSE_TB_DIR:-}"
allow_prefix_mismatch=0

usage() {
  cat <<'EOF'
Usage:
  ./scripts/run_baseline.sh [options]

Options:
  --seed N                 riscv-dv/xrun seed. Default: 1
  --reference-bin PATH     binary used to derive target 32-bit word count
  --common-prefix-bin PATH binary whose full contents must prefix generated .bin
  --target-words N         override target 32-bit word count
  --run-tag TAG            output run tag. Default: timestamped tag
  --jobs N                 parallel xrun jobs for launch_sim.sh. Default: 1
  --timeout-s N            riscv-dv generation timeout. Default: 1800
  --generator-simulator S  riscv-dv generator simulator. Default: pyflow
  --fsdb                   dump FSDB during xrun
  --no-coverage            run xrun without coverage options
  --no-bsdcov-io-dump      run xrun without BSD-Cov IO dump plusargs
  --force-compile          force Ibex TB compile
  --reuse-tb-dir PATH      reuse an existing original Ibex compiled TB
  --no-reuse-tb            ignore BSDCOV_REUSE_TB_DIR and compile a fresh TB
  --allow-prefix-mismatch  do not fail when the riscv-dv binary lacks common_init prefix
  --stop-on-assert         do not pass --continue-on-assert to launch_sim.sh
  --dry-run                create files without running riscv-dv/xrun
  -h, --help               show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --seed)
      seed="$2"; shift 2 ;;
    --reference-bin)
      reference_bin="$2"; shift 2 ;;
    --common-prefix-bin)
      common_prefix_bin="$2"; shift 2 ;;
    --target-words)
      target_words="$2"; shift 2 ;;
    --run-tag)
      run_tag="$2"; shift 2 ;;
    --jobs)
      jobs="$2"; shift 2 ;;
    --timeout-s)
      timeout_s="$2"; shift 2 ;;
    --generator-simulator)
      generator_simulator="$2"; shift 2 ;;
    --fsdb)
      fsdb=1; shift ;;
    --no-coverage)
      coverage=0; shift ;;
    --no-bsdcov-io-dump)
      bsdcov_io_dump=0; shift ;;
    --force-compile)
      force_compile=1; shift ;;
    --reuse-tb-dir)
      reuse_tb_dir="$2"; shift 2 ;;
    --no-reuse-tb)
      reuse_tb_dir=""; unset BSDCOV_REUSE_TB_DIR; shift ;;
    --allow-prefix-mismatch)
      allow_prefix_mismatch=1; shift ;;
    --stop-on-assert)
      keep_going_assert=0; shift ;;
    --dry-run)
      dry_run=1; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "ERROR: unknown option: $1" >&2
      usage >&2
      exit 2 ;;
  esac
done

require_uint() {
  local name="$1"
  local value="$2"
  if [[ ! "$value" =~ ^[0-9]+$ ]] || [[ "$value" == "0" ]]; then
    echo "ERROR: $name must be a positive integer: $value" >&2
    exit 2
  fi
}

require_uint "--seed" "$seed"
require_uint "--jobs" "$jobs"
require_uint "--timeout-s" "$timeout_s"

reference_bin="$(realpath -m "$reference_bin")"
common_prefix_bin="$(realpath -m "$common_prefix_bin")"
if [[ -n "$reuse_tb_dir" ]]; then
  reuse_tb_dir="$(realpath -m "$reuse_tb_dir")"
  if [[ ! -d "$reuse_tb_dir" ]]; then
    echo "ERROR: --reuse-tb-dir does not exist: $reuse_tb_dir" >&2
    exit 1
  fi
  export BSDCOV_REUSE_TB_DIR="$reuse_tb_dir"
fi
if [[ -z "$target_words" ]]; then
  if [[ ! -f "$reference_bin" ]]; then
    echo "ERROR: reference binary does not exist: $reference_bin" >&2
    exit 1
  fi
  target_words="$(python3 - "$reference_bin" <<'PY'
import sys
from pathlib import Path
p = Path(sys.argv[1])
size = p.stat().st_size
if size % 4:
    raise SystemExit(f"reference binary size is not 32-bit aligned: {size}")
print(size // 4)
PY
)"
fi
require_uint "--target-words" "$target_words"
if [[ ! -f "$common_prefix_bin" ]]; then
  echo "ERROR: common prefix binary does not exist: $common_prefix_bin" >&2
  exit 1
fi

if [[ -z "$run_tag" ]]; then
  run_tag="run.$(date -u +%Y%m%dT%H%M%SZ).seed${seed}"
fi

run_dir="$BASELINE_DIR/runs/$run_tag"
riscvdv_dir="$run_dir/riscvdv"
sim_root="$run_dir/sim"
reports_dir="$run_dir/reports"
logs_dir="$run_dir/logs"
mkdir -p "$riscvdv_dir" "$sim_root" "$reports_dir" "$logs_dir"

config_json="$run_dir/config.json"
summary_json="$run_dir/summary.json"
requested_num="$target_words"

python3 - "$config_json" <<PY
import json
from pathlib import Path
config = {
    "seed": int("$seed"),
    "reference_bin": "$reference_bin",
    "common_prefix_bin": "$common_prefix_bin",
    "target_words": int("$target_words"),
    "requested_riscvdv_num": int("$requested_num"),
    "run_tag": "$run_tag",
    "jobs": int("$jobs"),
    "timeout_s": int("$timeout_s"),
    "generator_simulator": "$generator_simulator",
    "fsdb": bool(int("$fsdb")),
    "coverage": bool(int("$coverage")),
    "bsdcov_io_dump": bool(int("$bsdcov_io_dump")),
    "force_compile": bool(int("$force_compile")),
    "continue_on_assert": bool(int("$keep_going_assert")),
    "reuse_tb_dir": "$reuse_tb_dir",
    "allow_prefix_mismatch": bool(int("$allow_prefix_mismatch")),
    "generator": "riscv-dv",
    "generator_test": "riscv_rand_instr_test",
    "rtl_test": "core_ibex_base_test",
}
Path("$config_json").write_text(json.dumps(config, indent=2, sort_keys=True) + "\\n")
PY

echo "BSD-Cov2 baseline run: $run_dir"
echo "Reference bin : $reference_bin"
echo "Common prefix : $common_prefix_bin"
echo "Target words  : $target_words"
echo "Seed          : $seed"

rand_cmd=(
  "$BSDCOV_DIR/scripts/rand_instr.sh"
  --seed "$seed"
  --num "$requested_num"
  --out-dir "$riscvdv_dir"
  --timeout-s "$timeout_s"
  --generator-simulator "$generator_simulator"
  --force
  --target rv32imc
  --isa rv32imc
  --mabi ilp32
  --gen-test riscv_instr_base_test
  --rtl-test core_ibex_base_test
  --boot-mode m
  --num-of-sub-program 0
  --gen-opt +no_csr_instr=0
  --gen-opt +randomize_csr=0
  --gen-opt +set_mstatus_mprv=0
  --gen-opt +boot_mode=m
)
if [[ "$generator_simulator" != "pyflow" ]]; then
  rand_cmd+=(
    --gen-opt +enable_write_pmp_csr=1
    --gen-opt +pmp_max_offset=00024000
  )
else
  echo "WARNING: pyflow generator does not support PMP-specific riscv-dv options; generating CSR-biased baseline only." >&2
fi
if [[ "$dry_run" == "1" ]]; then
  rand_cmd+=(--dry-run)
fi

printf '%q ' "${rand_cmd[@]}" > "$logs_dir/rand_instr.cmd"
printf '\n' >> "$logs_dir/rand_instr.cmd"
"${rand_cmd[@]}" 2>&1 | tee "$logs_dir/rand_instr.stdout.log"

chunk_file="$riscvdv_dir/assembly/seq.${seed}.${requested_num}.chunks.f"
asm_file="$riscvdv_dir/assembly/seq.${seed}.${requested_num}.S"
if [[ ! -f "$chunk_file" ]]; then
  echo "ERROR: riscv-dv chunk file was not produced: $chunk_file" >&2
  exit 1
fi

launch_cmd=(
  "$BSDCOV_DIR/scripts/launch_sim.sh"
  --instr-seq "$chunk_file"
  --cov-update "$target_words"
  --jobs "$jobs"
  --run-tag "$run_tag"
  --seed "$seed"
  --simulator xlm
  --iss spike
  --isa rv32imc
  --mabi ilp32
  --rtl-test core_ibex_base_test
)
if [[ "$force_compile" == "1" ]]; then
  launch_cmd+=(--force-compile)
fi
if [[ "$fsdb" == "1" ]]; then
  launch_cmd+=(--fsdb)
fi
if [[ "$coverage" == "0" ]]; then
  launch_cmd+=(--no-coverage)
fi
if [[ "$bsdcov_io_dump" == "0" ]]; then
  launch_cmd+=(--no-bsdcov-io-dump)
fi
if [[ "$keep_going_assert" == "1" ]]; then
  launch_cmd+=(--continue-on-assert)
fi
if [[ "$dry_run" == "1" ]]; then
  launch_cmd+=(--dry-run)
fi

printf '%q ' "${launch_cmd[@]}" > "$logs_dir/launch_sim.cmd"
printf '\n' >> "$logs_dir/launch_sim.cmd"
(
  cd "$sim_root"
  "${launch_cmd[@]}"
) 2>&1 | tee "$logs_dir/launch_sim.stdout.log"

sim_run_dir="$BSDCOV_DIR/sim/runs/$run_tag"
if [[ -d "$sim_run_dir" ]]; then
  ln -sfn "$sim_run_dir" "$run_dir/sim_run"
fi

python3 - "$summary_json" "$run_dir" "$sim_run_dir" "$target_words" "$requested_num" "$asm_file" "$common_prefix_bin" "$allow_prefix_mismatch" <<'PY'
import csv
import json
import sys
from pathlib import Path

summary_path = Path(sys.argv[1])
run_dir = Path(sys.argv[2])
sim_run_dir = Path(sys.argv[3])
target_words = int(sys.argv[4])
requested_num = int(sys.argv[5])
asm_file = Path(sys.argv[6])
common_prefix_bin = Path(sys.argv[7])
allow_prefix_mismatch = bool(int(sys.argv[8]))

summary = {
    "run_dir": str(run_dir),
    "sim_run_dir": str(sim_run_dir),
    "target_words": target_words,
    "requested_riscvdv_num": requested_num,
    "asm": str(asm_file),
    "common_prefix_bin": str(common_prefix_bin),
}

runs_csv = sim_run_dir / "runs.csv"
if runs_csv.exists():
    rows = list(csv.DictReader(runs_csv.open(newline="", encoding="utf-8")))
    summary["runs_csv"] = str(runs_csv)
    summary["num_chunks"] = len(rows)
    if rows:
        row = rows[0]
        binary = Path(row.get("binary", ""))
        summary["binary"] = str(binary)
        summary["status"] = row.get("status", "")
        summary["static_instr_count"] = int(row["static_instr_count"]) if row.get("static_instr_count") else None
        summary["static_main_instr_count"] = int(row["static_main_instr_count"]) if row.get("static_main_instr_count") else None
        if binary.exists():
            summary["generated_binary_bytes"] = binary.stat().st_size
            summary["generated_binary_words"] = binary.stat().st_size // 4
            summary["word_delta_vs_target"] = summary["generated_binary_words"] - target_words
            prefix = common_prefix_bin.read_bytes()
            generated = binary.read_bytes()
            summary["common_prefix_bytes"] = len(prefix)
            summary["common_prefix_words"] = len(prefix) // 4
            summary["common_prefix_match"] = generated.startswith(prefix)
            if not summary["common_prefix_match"]:
                mismatch = None
                for idx, (lhs, rhs) in enumerate(zip(prefix, generated)):
                    if lhs != rhs:
                        mismatch = idx
                        break
                if mismatch is None and len(generated) < len(prefix):
                    mismatch = len(generated)
                summary["common_prefix_mismatch_byte"] = mismatch
                if mismatch is not None:
                    summary["common_prefix_mismatch_addr"] = f"0x{0x80000000 + (mismatch // 4) * 4:08x}"

samples_csv = sim_run_dir / "coverage" / "samples.csv"
if samples_csv.exists():
    rows = list(csv.DictReader(samples_csv.open(newline="", encoding="utf-8")))
    summary["samples_csv"] = str(samples_csv)
    if rows:
        last = rows[-1]
        summary["coverage_report"] = last.get("cov_report", "")
        summary["coverage"] = {
            metric: {
                "pct": last.get(f"{metric}_pct", ""),
                "covered": last.get(f"{metric}_covered", ""),
                "total": last.get(f"{metric}_total", ""),
                "uncovered": last.get(f"{metric}_uncovered", ""),
            }
            for metric in ["block", "branch", "statement", "expression", "toggle", "fsm", "assertion", "covergroup"]
        }

reports = run_dir / "reports"
reports.mkdir(parents=True, exist_ok=True)
if "coverage_report" in summary and summary["coverage_report"]:
    src = Path(summary["coverage_report"])
    if src.exists():
        (reports / "cov_report.txt").write_text(src.read_text(encoding="utf-8", errors="ignore"), encoding="utf-8")
if samples_csv.exists():
    (reports / "samples.csv").write_text(samples_csv.read_text(encoding="utf-8", errors="ignore"), encoding="utf-8")
if runs_csv.exists():
    (reports / "runs.csv").write_text(runs_csv.read_text(encoding="utf-8", errors="ignore"), encoding="utf-8")

summary_path.write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n", encoding="utf-8")
print(json.dumps(summary, indent=2, sort_keys=True))
if summary.get("common_prefix_match") is False and not allow_prefix_mismatch:
    raise SystemExit(
        "generated riscv-dv binary does not contain the common_init prefix; "
        "coverage would not be comparable to instr_gen3"
    )
PY

latest="$BASELINE_DIR/runs/latest"
ln -sfn "$run_dir" "$latest"

echo "Baseline summary: $summary_json"
