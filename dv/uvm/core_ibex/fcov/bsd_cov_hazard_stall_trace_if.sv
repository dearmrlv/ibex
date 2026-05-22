// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module bsd_cov_hazard_stall_trace_if (
  input logic        clk_i,
  input logic        rst_ni,

  input logic [31:0] pc_id_i,
  input logic        instr_valid_id_i,
  input logic [31:0] instr_rdata_id_i,
  input logic        instr_first_cycle_id_i,

  input logic        id_in_ready_i,
  input logic        ex_valid_i,
  input logic        lsu_resp_valid_i,

  input logic [4:0]  rf_raddr_a_i,
  input logic [4:0]  rf_raddr_b_i,
  input logic [4:0]  rf_waddr_wb_i,
  input logic        rf_we_wb_i,
  input logic        rf_write_wb_i,

  input logic        outstanding_load_wb_i,
  input logic        outstanding_store_wb_i,
  input logic        ready_wb_i,
  input logic        wb_valid_i,

  input logic        instr_req_i,
  input logic        instr_gnt_i,
  input logic        instr_rvalid_i,

  input logic        data_req_i,
  input logic        data_gnt_i,
  input logic        data_rvalid_i,
  input logic        data_we_i,
  input logic [31:0] data_addr_i,

  input logic        if_instr_valid_i,
  input logic        if_req_i,

  input logic        stall_mem_i,
  input logic        stall_ld_hz_i,
  input logic        stall_multdiv_i,
  input logic        stall_branch_i,
  input logic        stall_jump_i,
  input logic        rf_rd_wb_hz_i
);

  int fd;
  bit trace_en;
  longint unsigned cycle;
  string trace_base;
  string trace_file;
  string header;

  initial begin
    fd = 0;
    trace_en = $test$plusargs("bsd_cov_hazard_stall_trace");

    if (trace_en) begin
      if (!$value$plusargs("ibex_tracer_file_base=%s", trace_base)) begin
        trace_base = "trace_core";
      end

      trace_file = {trace_base, "_bsd_cov_hazard_stall.csv"};
      fd = $fopen(trace_file, "w");

      if (fd == 0) begin
        $display("BSD-COV ERROR: failed to open %s", trace_file);
      end else begin
        $display("BSD-COV: writing hazard/stall trace to %s", trace_file);
        header = {
          "cycle,pc_id,instr_valid_id,instr_rdata_id,instr_first_cycle_id,",
          "id_in_ready,ex_valid,lsu_resp_valid,",
          "rf_raddr_a,rf_raddr_b,rf_waddr_wb,rf_we_wb,rf_write_wb,",
          "outstanding_load_wb,outstanding_store_wb,ready_wb,wb_valid,",
          "instr_req,instr_gnt,instr_rvalid,",
          "data_req,data_gnt,data_rvalid,data_we,data_addr,",
          "if_instr_valid,if_req,",
          "stall_mem,stall_ld_hz,stall_multdiv,stall_branch,stall_jump,rf_rd_wb_hz\n"
        };
        $fwrite(fd, "%s", header);
      end
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      cycle <= 0;
    end else begin
      cycle <= cycle + 1;

      if (trace_en && fd != 0 && instr_valid_id_i) begin
        $fwrite(fd,
          "%0d,%08h,%0d,%08h,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%08h,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d\n",
          cycle,
          pc_id_i,
          instr_valid_id_i,
          instr_rdata_id_i,
          instr_first_cycle_id_i,

          id_in_ready_i,
          ex_valid_i,
          lsu_resp_valid_i,

          rf_raddr_a_i,
          rf_raddr_b_i,
          rf_waddr_wb_i,
          rf_we_wb_i,
          rf_write_wb_i,

          outstanding_load_wb_i,
          outstanding_store_wb_i,
          ready_wb_i,
          wb_valid_i,

          instr_req_i,
          instr_gnt_i,
          instr_rvalid_i,

          data_req_i,
          data_gnt_i,
          data_rvalid_i,
          data_we_i,
          data_addr_i,

          if_instr_valid_i,
          if_req_i,

          stall_mem_i,
          stall_ld_hz_i,
          stall_multdiv_i,
          stall_branch_i,
          stall_jump_i,
          rf_rd_wb_hz_i
        );
      end
    end
  end

  final begin
    if (trace_en && fd != 0) begin
      $fclose(fd);
    end
  end

endmodule
