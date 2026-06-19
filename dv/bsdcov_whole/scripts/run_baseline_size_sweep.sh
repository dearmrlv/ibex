#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BSDCOV_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

SWEEP_POINTS="${SWEEP_POINTS:-10000 20000 30000 40000 50000 60000 70000 80000 90000 100000}"
MAX_PARALLEL_FLOWS="${MAX_PARALLEL_FLOWS:-8}"
JOBS="${JOBS:-4}"
FML_JOBS="${FML_JOBS:-4}"
CONTINUE_ON_ASSERT="${CONTINUE_ON_ASSERT:-1}"
BASE_SEED="${BASE_SEED:-1688}"
RAND_INSTR_TIMEOUT_S="${RAND_INSTR_TIMEOUT_S:-3600}"
FORCE="${FORCE:-0}"

SWEEP_DIR="$BSDCOV_DIR/runs/baseline_size_sweep"
LOG_DIR="$SWEEP_DIR/logs"
STATUS_TSV="$SWEEP_DIR/status.tsv"
FAILURES_TSV="$SWEEP_DIR/failures.tsv"
SUMMARY_CSV="$SWEEP_DIR/summary.csv"
SUMMARY_MD="$SWEEP_DIR/summary.md"
COVERAGE_REPORT_DIR="$BSDCOV_DIR/reports"
COVERAGE_REPORT_CSV="$COVERAGE_REPORT_DIR/baseline_bsdcov_extra_coverage.csv"

mkdir -p "$LOG_DIR"

now_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

elapsed_s() {
  local start_epoch="$1"
  echo "$(( $(date +%s) - start_epoch ))"
}

init_tables() {
  printf "baseline_instr\trun_tag\tstatus\tpid\tstart_time\tend_time\telapsed_s\tlog\trun_dir\treport\tfailure_summary\n" > "$STATUS_TSV"
  printf "baseline_instr\trun_tag\tfailed_step_guess\terror_line\tlog\tlikely_debug_file\n" > "$FAILURES_TSV"
}

append_status() {
  local instr="$1"
  local tag="$2"
  local status="$3"
  local pid="$4"
  local start_time="$5"
  local end_time="$6"
  local elapsed="$7"
  local log="$8"
  local run_dir="$9"
  local report="${10}"
  local failure_summary="${11}"
  printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
    "$instr" "$tag" "$status" "$pid" "$start_time" "$end_time" "$elapsed" \
    "$log" "$run_dir" "$report" "$failure_summary" >> "$STATUS_TSV"
}

guess_failed_step() {
  local log="$1"
  if grep -q "Generate baseline riscv-dv assembly" "$log" && ! grep -q "Run baseline simulation" "$log"; then
    echo "rand_instr"
  elif grep -q "Run baseline simulation" "$log" && ! grep -q "Cook BSD-Cov project" "$log"; then
    echo "baseline_sim"
  elif grep -q "Cook BSD-Cov project" "$log" && ! grep -q "Run JasperGold multi-CEX" "$log"; then
    echo "cook"
  elif grep -q "Run JasperGold multi-CEX" "$log" && ! grep -q "Extract instruction words" "$log"; then
    echo "formal"
  elif grep -q "Extract instruction words" "$log" && ! grep -q "Patch baseline assembly" "$log"; then
    echo "fsdb_to_instr"
  elif grep -q "Run patched Baseline+BSD-Cov simulation" "$log" && ! grep -q "Generate and run same-prefix baseline-extra comparison" "$log"; then
    echo "bsdcov_sim"
  elif grep -q "Generate and run same-prefix baseline-extra comparison" "$log" && ! grep -q "Merge baseline coverage into the final BSD-Cov / baseline-extra results" "$log"; then
    echo "baseline_extra"
  elif grep -q "Merge baseline coverage into the final BSD-Cov / baseline-extra results" "$log" && ! grep -q "Write coverage comparison report" "$log"; then
    echo "final_merge"
  elif grep -q "Write coverage comparison report" "$log"; then
    echo "coverage_report"
  else
    echo "unknown"
  fi
}

extract_error_line() {
  local log="$1"
  grep -E "ERROR:|RuntimeError:|UVM_FATAL|command failed|JasperGold .*failed|no BSD-Cov instruction words|same-prefix baseline-extra run did not pass|Traceback" "$log" \
    | tail -1 \
    | tr '\t' ' ' \
    || true
}

likely_debug_file() {
  local run_dir="$1"
  local step="$2"
  case "$step" in
    rand_instr)
      find "$run_dir/riscvdv/logs" -type f -name '*.log' 2>/dev/null | sort | tail -1 || true
      ;;
    baseline_sim|bsdcov_sim|baseline_extra)
      find "$run_dir/sim/runs" -type f \( -name 'rtl_sim.log' -o -name 'launch_rtl.log' -o -name 'error.txt' \) 2>/dev/null | sort | tail -1 || true
      ;;
    cook)
      find "$run_dir/big_proj/cones" -type f \( -name 'train.log' -o -name 'jg.log' -o -name 'status.toml' \) 2>/dev/null | sort | tail -1 || true
      ;;
    formal)
      find "$run_dir/fml" "$BSDCOV_DIR/fml" -type f \( -name '*.log' -o -name '*.txt' \) 2>/dev/null | sort | tail -1 || true
      ;;
    fsdb_to_instr)
      find "$run_dir/cex_instr" -type f 2>/dev/null | sort | tail -1 || true
      ;;
    final_merge|coverage_report)
      find "$run_dir/coverage" "$run_dir/reports" -type f \( -name '*.txt' -o -name '*.csv' -o -name '*.json' -o -name '*.md' \) 2>/dev/null | sort | tail -1 || true
      ;;
    *)
      find "$run_dir" -type f \( -name 'error.txt' -o -name '*.log' \) 2>/dev/null | sort | tail -1 || true
      ;;
  esac
}

run_one_point() {
  local instr="$1"
  local tag="sweep_baseline_${instr}"
  local seed="$BASE_SEED"
  local run_dir="$BSDCOV_DIR/runs/$tag"
  local log="$LOG_DIR/${tag}.log"
  local tail_log="$LOG_DIR/${tag}.tail"
  local report="$run_dir/reports/coverage_compare.md"
  local manifest="$run_dir/manifest.txt"
  local start_time
  local start_epoch
  local end_time
  local elapsed

  if [[ "$FORCE" != "1" && -f "$manifest" && -f "$report" ]]; then
    append_status "$instr" "$tag" "skipped" "" "" "$(now_utc)" "0" "$log" "$run_dir" "$report" "existing complete run"
    return 0
  fi

  start_time="$(now_utc)"
  start_epoch="$(date +%s)"
  append_status "$instr" "$tag" "running" "$BASHPID" "$start_time" "" "" "$log" "$run_dir" "$report" ""

  set +e
  {
    echo "BSD-Cov baseline-size sweep point"
    echo "baseline_instr=$instr"
    echo "run_tag=$tag"
    echo "seed=$seed"
    echo "jobs=$JOBS"
    echo "fml_jobs=$FML_JOBS"
    echo "continue_on_assert=$CONTINUE_ON_ASSERT"
    echo "rand_instr_timeout_s=$RAND_INSTR_TIMEOUT_S"
    echo "started_at=$start_time"
    echo
    cd "$BSDCOV_DIR"
    BASELINE_INSTR="$instr" \
      SEED="$seed" \
      RUN_TAG="$tag" \
      JOBS="$JOBS" \
      FML_JOBS="$FML_JOBS" \
      CONTINUE_ON_ASSERT="$CONTINUE_ON_ASSERT" \
      RAND_INSTR_TIMEOUT_S="$RAND_INSTR_TIMEOUT_S" \
      ./scripts/whole_flow.sh
  } > "$log" 2>&1
  local rc=$?
  set -e

  tail -200 "$log" > "$tail_log" 2>/dev/null || true
  end_time="$(now_utc)"
  elapsed="$(elapsed_s "$start_epoch")"
  if [[ "$rc" == "0" && -f "$report" ]]; then
    append_status "$instr" "$tag" "pass" "" "$start_time" "$end_time" "$elapsed" "$log" "$run_dir" "$report" ""
    return 0
  fi

  local step
  local error_line
  local debug_file
  step="$(guess_failed_step "$log")"
  error_line="$(extract_error_line "$log")"
  debug_file="$(likely_debug_file "$run_dir" "$step")"
  append_status "$instr" "$tag" "failed" "" "$start_time" "$end_time" "$elapsed" "$log" "$run_dir" "$report" "$error_line"
  printf "%s\t%s\t%s\t%s\t%s\t%s\n" "$instr" "$tag" "$step" "$error_line" "$log" "$debug_file" >> "$FAILURES_TSV"
  return 0
}

wait_for_slot() {
  while (( $(jobs -rp | wc -l) >= MAX_PARALLEL_FLOWS )); do
    sleep 30
  done
}

write_summary() {
  "$PYTHON_BIN" - "$BSDCOV_DIR" "$SWEEP_DIR" $SWEEP_POINTS <<'PY'
from __future__ import annotations

import csv
import re
import sys
from pathlib import Path

METRICS = ["block", "branch", "statement", "expression", "toggle", "statement_dup", "fsm", "assertion", "covergroup"]

bsdcov_dir = Path(sys.argv[1])
sweep_dir = Path(sys.argv[2])
points = [int(x) for x in sys.argv[3:]]


def read_manifest(path: Path) -> dict[str, str]:
    out: dict[str, str] = {}
    if not path.exists():
        return out
    for raw in path.read_text(encoding="utf-8", errors="ignore").splitlines():
        if "=" in raw:
            key, value = raw.split("=", 1)
            out[key.strip()] = value.strip()
    return out


def read_compare(path: Path) -> dict[str, dict[str, str]]:
    csv_path = path.parent / "coverage_compare.csv"
    if not csv_path.exists():
        return {}
    rows = list(csv.DictReader(csv_path.open(encoding="utf-8", errors="ignore")))
    return {row["case"]: row for row in rows}


def infer_instr(tag: str, default: int) -> str:
    match = re.search(r"sweep_baseline_(\d+)", tag)
    if match:
        return match.group(1)
    return str(default)


def status_for(instr: int) -> tuple[str, str]:
    status_path = sweep_dir / "status.tsv"
    if not status_path.exists():
        return "", ""
    matches = []
    for row in csv.DictReader(status_path.open(encoding="utf-8", errors="ignore"), delimiter="\t"):
        if row.get("baseline_instr") == str(instr):
            matches.append(row)
    if not matches:
        return "", ""
    row = matches[-1]
    return row.get("status", ""), row.get("failure_summary", "")


def to_float(value: str) -> float | None:
    try:
        return float(value)
    except (TypeError, ValueError):
        return None


rows: list[dict[str, str]] = []
for instr in points:
    tag = f"sweep_baseline_{instr}"
    run_dir = bsdcov_dir / "runs" / tag
    report = run_dir / "reports" / "coverage_compare.md"
    manifest = read_manifest(run_dir / "manifest.txt")
    compare = read_compare(report)
    status, failure = status_for(instr)
    row: dict[str, str] = {
        "baseline_instr": infer_instr(tag, instr),
        "run_tag": tag,
        "status": status,
        "failure_summary": failure,
        "bsdcov_word_count": manifest.get("bsdcov_word_count", ""),
        "total_instr": "",
        "baseline_extra_seed": manifest.get("baseline_extra_seed", ""),
        "run_dir": str(run_dir),
        "report": str(report) if report.exists() else "",
    }
    if row["bsdcov_word_count"].isdigit():
        row["total_instr"] = str(instr + int(row["bsdcov_word_count"]))
    for case in ["baseline", "baseline_plus_bsdcov", "baseline_extra_same_budget"]:
        case_row = compare.get(case, {})
        case_instr_field = "baseline_case_instr" if case == "baseline" else f"{case}_instr"
        row[case_instr_field] = case_row.get("instruction_count", "")
        for metric in METRICS:
            row[f"{case}_{metric}_pct"] = case_row.get(f"{metric}_pct", "")
    for metric in METRICS:
        b = to_float(row.get(f"baseline_{metric}_pct", ""))
        c = to_float(row.get(f"baseline_plus_bsdcov_{metric}_pct", ""))
        e = to_float(row.get(f"baseline_extra_same_budget_{metric}_pct", ""))
        row[f"bsdcov_delta_{metric}"] = "" if b is None or c is None else f"{c - b:+.2f}"
        row[f"extra_delta_{metric}"] = "" if b is None or e is None else f"{e - b:+.2f}"
        row[f"bsdcov_advantage_vs_extra_{metric}"] = "" if c is None or e is None else f"{c - e:+.2f}"
    rows.append(row)

fields = [
    "baseline_instr", "run_tag", "status", "failure_summary",
    "bsdcov_word_count", "total_instr", "baseline_extra_seed", "run_dir", "report",
]
for case in ["baseline", "baseline_plus_bsdcov", "baseline_extra_same_budget"]:
    case_instr_field = "baseline_case_instr" if case == "baseline" else f"{case}_instr"
    fields.append(case_instr_field)
    fields.extend(f"{case}_{metric}_pct" for metric in METRICS)
for metric in METRICS:
    fields.extend([f"bsdcov_delta_{metric}", f"extra_delta_{metric}", f"bsdcov_advantage_vs_extra_{metric}"])

csv_path = sweep_dir / "summary.csv"
with csv_path.open("w", encoding="utf-8", newline="") as fd:
    writer = csv.DictWriter(fd, fieldnames=fields, extrasaction="ignore")
    writer.writeheader()
    writer.writerows(rows)

md_lines = [
    "# BSD-Cov Baseline Size Sweep",
    "",
    "| Baseline Instr | Status | BSD-Cov Instr | Baseline block | BSD-Cov block | Extra block | BSD adv block | Report |",
    "|---:|---|---:|---:|---:|---:|---:|---|",
]
for row in rows:
    report_cell = f"`{row['report']}`" if row.get("report") else ""
    md_lines.append(
        "| "
        + " | ".join([
            row["baseline_instr"],
            row.get("status", ""),
            row.get("bsdcov_word_count", ""),
            row.get("baseline_block_pct", ""),
            row.get("baseline_plus_bsdcov_block_pct", ""),
            row.get("baseline_extra_same_budget_block_pct", ""),
            row.get("bsdcov_advantage_vs_extra_block", ""),
            report_cell,
        ])
        + " |"
    )
md_lines.extend(["", "## Failures", ""])
failed = [row for row in rows if row.get("status") == "failed"]
if not failed:
    md_lines.append("No failed points recorded.")
else:
    md_lines.extend(["| Baseline Instr | Failure Summary |", "|---:|---|"])
    for row in failed:
        md_lines.append(f"| {row['baseline_instr']} | {row.get('failure_summary', '')} |")

(sweep_dir / "summary.md").write_text("\n".join(md_lines) + "\n", encoding="utf-8")
report_dir = bsdcov_dir / "reports"
report_dir.mkdir(parents=True, exist_ok=True)
coverage_fields = [
    "BaselineInstructionNum",
    "BaselineBlock", "Baseline+BSDCOVBlock", "Baseline+ExtraBlock",
    "BaselineBranch", "Baseline+BSDCOVBranch", "Baseline+ExtraBranch",
    "BaselineStatement", "Baseline+BSDCOVStatement", "Baseline+ExtraStatement",
    "BaselineExpression", "Baseline+BSDCOVExpression", "Baseline+ExtraExpression",
    "BaselineToggle", "Baseline+BSDCOVToggle", "Baseline+ExtraToggle",
    "BaselineFSM", "Baseline+BSDCOVFSM", "Baseline+ExtraFSM",
    "BaselineAssertion", "Baseline+BSDCOVAssertion", "Baseline+ExtraAssertion",
    "BaselineCovergroup", "Baseline+BSDCOVCovergroup", "Baseline+ExtraCovergroup",
]
metric_map = [
    ("Block", "block"),
    ("Branch", "branch"),
    ("Statement", "statement"),
    ("Expression", "expression"),
    ("Toggle", "toggle"),
    ("FSM", "fsm"),
    ("Assertion", "assertion"),
    ("Covergroup", "covergroup"),
]
coverage_csv = report_dir / "baseline_bsdcov_extra_coverage.csv"
with coverage_csv.open("w", encoding="utf-8", newline="") as fd:
    writer = csv.DictWriter(fd, fieldnames=coverage_fields)
    writer.writeheader()
    for row in rows:
        out = {"BaselineInstructionNum": row["baseline_instr"]}
        for label, metric in metric_map:
            out[f"Baseline{label}"] = row.get(f"baseline_{metric}_pct", "")
            out[f"Baseline+BSDCOV{label}"] = row.get(f"baseline_plus_bsdcov_{metric}_pct", "")
            out[f"Baseline+Extra{label}"] = row.get(f"baseline_extra_same_budget_{metric}_pct", "")
        writer.writerow(out)
print(f"Wrote {csv_path}")
print(f"Wrote {sweep_dir / 'summary.md'}")
print(f"Wrote {coverage_csv}")
PY
}

PYTHON_BIN="${BSDCOV_PYTHON:-}"
if [[ -z "$PYTHON_BIN" ]]; then
  if [[ -x "$BSDCOV_DIR/../../.venv/bin/python" ]]; then
    PYTHON_BIN="$BSDCOV_DIR/../../.venv/bin/python"
  else
    PYTHON_BIN="$(command -v python3)"
  fi
fi

if [[ "$MAX_PARALLEL_FLOWS" -lt 1 ]]; then
  echo "ERROR: MAX_PARALLEL_FLOWS must be >= 1" >&2
  exit 1
fi

init_tables
echo "BSD-Cov baseline-size sweep"
echo "sweep_dir=$SWEEP_DIR"
echo "points=$SWEEP_POINTS"
echo "max_parallel_flows=$MAX_PARALLEL_FLOWS"
echo "jobs=$JOBS"
echo "fml_jobs=$FML_JOBS"
echo "continue_on_assert=$CONTINUE_ON_ASSERT"
echo "rand_instr_timeout_s=$RAND_INSTR_TIMEOUT_S"
echo

for instr in $SWEEP_POINTS; do
  wait_for_slot
  run_one_point "$instr" &
done

wait
write_summary

echo
echo "BSD-Cov baseline-size sweep complete."
echo "Status  : $STATUS_TSV"
echo "Failures: $FAILURES_TSV"
echo "Summary : $SUMMARY_MD"
