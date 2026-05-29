# Target-Cone Coverage Comparison

Baseline: `baseline_2k_targettrace`

Candidate: `bsdcov_guided_hazard_stall_2k`

| Metric | Baseline | Candidate | Delta |
|---|---:|---:|---:|
| output_bit_coverage_pct | 83.33 | 75.00 | -8.33 |
| input_bool_coverage_pct | 92.11 | 84.21 | -7.89 |
| predicate_coverage_pct | 100.00 | 83.33 | -16.67 |
| cross_coverage_pct | 60.00 | 50.00 | -10.00 |
| accepted_region_coverage_pct | 60.00 | 60.00 | 0.00 |
| supported_region_coverage_pct | 100.00 | 100.00 | 0.00 |
| overall_target_coverage_pct | 79.09 | 70.51 | -8.58 |
| unique_output_vectors | 7 | 6 | -1.00 |
| unique_input_vectors | 2211 | 536 | -1675.00 |
| trace_rows | 17711 | 14440 | -3271.00 |

## Output vector union

Baseline union coverage: 87.50

Candidate union coverage: 75.00

Delta: -12.50

## Candidate-only bins

| Category | Bin | Baseline count | Candidate count |
|---|---|---:|---:|
| cross | `stall_ld_hz & raw_hazard_rs2 & load_wait` | 0 | 3492 |

## Baseline-only bins

| Category | Bin | Baseline count | Candidate count |
|---|---|---:|---:|
| cross | `stall_multdiv & div_active` | 2549 | 0 |
| cross | `stall_multdiv & mult_active` | 70 | 0 |
| input_bool | `div_en_dec==1` | 2648 | 0 |
| input_bool | `ex_valid_i==0` | 2619 | 0 |
| input_bool | `mult_en_dec==1` | 152 | 0 |
| output_bit | `stall_multdiv==1` | 2619 | 0 |
| predicate | `div_active` | 2648 | 0 |
| predicate | `mult_active` | 152 | 0 |

## Missed by both

| Category | Bin | Baseline count | Candidate count |
|---|---|---:|---:|
| cross | `stall_branch & branch_active` | 0 | 0 |
| cross | `stall_branch & branch_taken` | 0 | 0 |
| cross | `stall_jump & jump_active` | 0 | 0 |
| input_bool | `data_ind_timing_i==1` | 0 | 0 |
| input_bool | `instr_fetch_err_i==1` | 0 | 0 |
| input_bool | `instr_valid_i==0` | 0 | 0 |
| output_bit | `stall_branch==1` | 0 | 0 |
| output_bit | `stall_jump==1` | 0 | 0 |
| region | `region:R_rf_rd_wb_hz_000` | 0 | 0 |
| region | `region:R_stall_mem_001` | 0 | 0 |
