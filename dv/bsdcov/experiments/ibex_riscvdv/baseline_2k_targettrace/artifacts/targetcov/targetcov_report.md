# Target-Cone Coverage Report

Target: `ibex_hazard_stall`

Method: `baseline_riscvdv_2k_targettrace_seed888`

Trace rows: 17711

| Metric | Value |
|---|---:|
| Output bit coverage | 83.33 |
| Input boolean coverage | 92.11 |
| Predicate coverage | 100.00 |
| Cross coverage | 60.00 |
| Accepted region coverage | 60.00 |
| Supported region coverage | 100.00 |
| Overall target coverage | 79.09 |
| Unique output vectors | 7 |
| Unique input vectors | 2211 |

## Top bins

| Category | Bin | Hit count |
|---|---|---:|
| input_bool | `data_ind_timing_i==0` | 17711 |
| input_bool | `instr_fetch_err_i==0` | 17711 |
| input_bool | `instr_valid_i==1` | 17711 |
| output_bit | `stall_branch==0` | 17711 |
| output_bit | `stall_jump==0` | 17711 |
| input_bool | `jump_in_dec==0` | 17625 |
| output_bit | `stall_ld_hz==0` | 17588 |
| input_bool | `controller_run==1` | 17585 |
| input_bool | `mult_en_dec==0` | 17559 |
| input_bool | `branch_in_dec==0` | 17291 |
| input_bool | `rf_ren_a==1` | 16982 |
| input_bool | `branch_decision_i==0` | 16477 |
| input_bool | `lsu_resp_valid_i==0` | 16347 |
| input_bool | `lsu_req_done_i==0` | 16244 |
| predicate | `wb_nonzero` | 16005 |
| output_bit | `rf_rd_wb_hz==0` | 15571 |
| input_bool | `ex_valid_i==1` | 15092 |
| output_bit | `stall_multdiv==0` | 15092 |
| input_bool | `div_en_dec==0` | 15063 |
| input_bool | `outstanding_load_wb_i==0` | 14185 |

## Missed cross bins

- `stall_branch & branch_active`
- `stall_branch & branch_taken`
- `stall_jump & jump_active`
- `stall_ld_hz & raw_hazard_rs2 & load_wait`

## Missed regions

- `R_rf_rd_wb_hz_000`
- `R_stall_mem_001`
