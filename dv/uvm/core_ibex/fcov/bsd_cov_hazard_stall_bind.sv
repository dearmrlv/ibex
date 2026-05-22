// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module bsd_cov_hazard_stall_bind;

  bind ibex_core bsd_cov_hazard_stall_trace_if u_bsd_cov_hazard_stall_trace (
    .clk_i                  (clk_i),
    .rst_ni                 (rst_ni),

    .pc_id_i                (pc_id),
    .instr_valid_id_i       (instr_valid_id),
    .instr_rdata_id_i       (instr_rdata_id),
    .instr_first_cycle_id_i (instr_first_cycle_id),

    .id_in_ready_i          (id_in_ready),
    .ex_valid_i             (ex_valid),
    .lsu_resp_valid_i       (lsu_resp_valid),

    .rf_raddr_a_i           (rf_raddr_a),
    .rf_raddr_b_i           (rf_raddr_b),
    .rf_waddr_wb_i          (rf_waddr_wb),
    .rf_we_wb_i             (rf_we_wb),
    .rf_write_wb_i          (rf_write_wb),

    .outstanding_load_wb_i  (outstanding_load_wb),
    .outstanding_store_wb_i (outstanding_store_wb),
    .ready_wb_i             (ready_wb),
    .wb_valid_i             (wb_stage_i.fcov_wb_valid),

    .instr_req_i            (instr_req_o),
    .instr_gnt_i            (instr_gnt_i),
    .instr_rvalid_i         (instr_rvalid_i),

    .data_req_i             (data_req_o),
    .data_gnt_i             (data_gnt_i),
    .data_rvalid_i          (data_rvalid_i),
    .data_we_i              (data_we_o),
    .data_addr_i            (data_addr_o),

    .if_instr_valid_i       (if_stage_i.if_instr_valid),
    .if_req_i               (if_stage_i.req_i),

    .stall_mem_i            (id_stage_i.stall_mem),
    .stall_ld_hz_i          (id_stage_i.stall_ld_hz),
    .stall_multdiv_i        (id_stage_i.stall_multdiv),
    .stall_branch_i         (id_stage_i.stall_branch),
    .stall_jump_i           (id_stage_i.stall_jump),
    .rf_rd_wb_hz_i          (id_stage_i.fcov_rf_rd_wb_hz)
  );

endmodule
