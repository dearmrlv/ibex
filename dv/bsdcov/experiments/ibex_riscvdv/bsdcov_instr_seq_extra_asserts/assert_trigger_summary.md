# BSD-Cov Region Assertion Simulation Result

Status: bsd_cov_assertion_triggered

## Inputs
- Formal bind source: `designs/ibex/dv/bsd-cov/bsd/asserts/bsd_cov_ibex_hazard_stall_region_asserts_bind.sv`
- Simulation bind copy: `designs/ibex/dv/bsdcov/experiments/ibex_riscvdv/bsdcov_instr_seq_extra_asserts/bsd_cov_ibex_hazard_stall_region_asserts_bind_xrun.sv`
- Compile log: `designs/ibex/dv/bsdcov/experiments/ibex_riscvdv/bsdcov_instr_seq_extra_asserts/build/tb/compile_tb_with_region_asserts.log`
- Simulation log: `designs/ibex/dv/bsdcov/experiments/ibex_riscvdv/bsdcov_instr_seq_extra_asserts/run/rtl_sim_with_region_asserts.log`
- IMC report: `designs/ibex/dv/bsdcov/experiments/ibex_riscvdv/bsdcov_instr_seq_extra_asserts/report_abs/report/cov_report.txt`

## Bind Note
The formal bind file was not modified. Xcelium simulation used a local copy rewritten to module-level bind ibex_id_stage because the original bind instance path syntax did not elaborate in this simulation context.

## Triggered Assertions
| Time ns | Region | Assertion | Instance |
|---:|---|---|---|
| 8313 | `R_stall_jump_003` | `AST_BSDCOV_R_stall_jump_003` | `core_ibex_tb_top.dut.u_ibex_top.u_ibex_core.id_stage_i.bsd_cov_ibex_hazard_stall_region_asserts_bind_inst` |
| 8333 | `R_stall_jump_003` | `AST_BSDCOV_R_stall_jump_003` | `core_ibex_tb_top.dut.u_ibex_top.gen_lockstep.u_ibex_lockstep.u_shadow_core.id_stage_i.bsd_cov_ibex_hazard_stall_region_asserts_bind_inst` |

## Simulation Outcome
- Final RTL test status: `failed`
- `NoAlertsTriggered` also appeared in the log: `True`

## IMC Assertion Items
- BSD-Cov assertion/cover items found in dynamic IMC report JSON: `204`
- `R_stall_jump_003` entries were present in the IMC dynamic report for the bind module/main core/shadow core.
