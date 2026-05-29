# Target-Cone Coverage Report

Target: `ibex_hazard_stall`

Method: `bsdcov_guided_hazard_stall_2k`

Trace rows: 14440

| Metric | Value |
|---|---:|
| Output bit coverage | 75.00 |
| Input boolean coverage | 84.21 |
| Predicate coverage | 83.33 |
| Cross coverage | 50.00 |
| Accepted region coverage | 60.00 |
| Supported region coverage | 100.00 |
| Overall target coverage | 70.51 |
| Unique output vectors | 6 |
| Unique input vectors | 536 |

## Top bins

| Category | Bin | Hit count |
|---|---|---:|
| input_bool | `data_ind_timing_i==0` | 14440 |
| input_bool | `div_en_dec==0` | 14440 |
| input_bool | `ex_valid_i==1` | 14440 |
| input_bool | `instr_fetch_err_i==0` | 14440 |
| input_bool | `instr_valid_i==1` | 14440 |
| input_bool | `mult_en_dec==0` | 14440 |
| output_bit | `stall_branch==0` | 14440 |
| output_bit | `stall_jump==0` | 14440 |
| output_bit | `stall_multdiv==0` | 14440 |
| input_bool | `branch_in_dec==0` | 14437 |
| input_bool | `controller_run==1` | 14433 |
| input_bool | `jump_in_dec==0` | 14368 |
| input_bool | `rf_ren_a==1` | 14354 |
| input_bool | `branch_decision_i==0` | 14162 |
| predicate | `wb_nonzero` | 13928 |
| input_bool | `lsu_resp_valid_i==0` | 13060 |
| input_bool | `lsu_req_done_i==0` | 12938 |
| output_bit | `stall_mem==1` | 11877 |
| input_bool | `lsu_req_dec==1` | 11423 |
| input_bool | `outstanding_store_wb_i==0` | 11402 |

## Missed cross bins

- `stall_branch & branch_active`
- `stall_branch & branch_taken`
- `stall_jump & jump_active`
- `stall_multdiv & div_active`
- `stall_multdiv & mult_active`

## Missed regions

- `R_rf_rd_wb_hz_000`
- `R_stall_mem_001`
