// Runtime-configurable retirement stop monitor for BSD-Cov instruction generation.
module bsdcov_instr_gen_eval_stop (
  input logic clk_i,
  input logic rvfi_valid_i,
  input logic [31:0] rvfi_pc_i,
  input logic [31:0] rvfi_insn_i,
  input logic instr_req_i,
  input logic instr_gnt_i,
  input logic [31:0] instr_addr_i,
  input logic alert_minor_i,
  input logic alert_major_internal_i,
  input logic alert_major_bus_i
);
  localparam int unsigned POST_ERROR_WAIT_CYCLES = 100;

  logic [31:0] stop_pc;
  logic [31:0] stop_instruction;
  logic epoch_done = 1'b0;
  logic [31:0] done_reason = 32'd0;
  logic finish_on_epoch_done = 1'b0;
  logic [31:0] retired_pc_q = '0;
  logic [31:0] retired_insn_q = '0;
  logic blocked_req_seen = 1'b0;
  logic error_seen_q = 1'b0;
  logic error_active_q = 1'b0;
  logic post_error_waiting_q = 1'b0;
  int unsigned post_error_cnt_q = 0;
  int unsigned error_count_q = 0;

  wire error_active =
      alert_minor_i || alert_major_internal_i || alert_major_bus_i;

  initial begin
    stop_pc = 32'h8000_011c;
    stop_instruction = 32'h0000_0f93;
    void'($value$plusargs("bsdcov_stop_pc=%h", stop_pc));
    void'($value$plusargs("bsdcov_stop_instruction=%h", stop_instruction));
    finish_on_epoch_done = $test$plusargs("bsdcov_finish_on_epoch_done");
  end

  task automatic bsdcov_arm_epoch(input logic [31:0] new_stop_pc,
                                  input logic [31:0] new_stop_instruction);
    stop_pc = new_stop_pc;
    stop_instruction = new_stop_instruction;
    epoch_done = 1'b0;
    done_reason = 32'd0;
    retired_pc_q = '0;
    retired_insn_q = '0;
    blocked_req_seen = 1'b0;
    error_seen_q = 1'b0;
    error_active_q = 1'b0;
    post_error_waiting_q = 1'b0;
    post_error_cnt_q = 0;
    error_count_q = 0;
    $display("BSDCOV_EVAL_ARMED stop_pc=0x%08x stop_instruction=0x%08x",
             stop_pc, stop_instruction);
  endtask

  initial begin
    uvm_pkg::uvm_report_server report_server_h;
    #1us;
    report_server_h = uvm_pkg::uvm_report_server::get_server();
    report_server_h.set_max_quit_count(0);
  end

  always @(posedge clk_i) begin
    if (instr_req_i && !instr_gnt_i && instr_addr_i > stop_pc) begin
      blocked_req_seen <= 1'b1;
    end

    error_active_q <= error_active;

    if (error_active) begin
      error_seen_q <= 1'b1;
      post_error_waiting_q <= 1'b0;
      post_error_cnt_q <= 0;
      if (!error_active_q) begin
        error_count_q <= error_count_q + 1;
      end
    end else if (error_seen_q) begin
      post_error_waiting_q <= 1'b1;
      if (!post_error_waiting_q) begin
        post_error_cnt_q <= 0;
      end else if (post_error_cnt_q < POST_ERROR_WAIT_CYCLES) begin
        post_error_cnt_q <= post_error_cnt_q + 1;
      end
    end

    if (post_error_waiting_q && !error_active &&
        post_error_cnt_q >= POST_ERROR_WAIT_CYCLES) begin
      if (finish_on_epoch_done) begin
        #1ps;
        $display("BSDCOV_EVAL_ERROR_HANDLED error_count=%0d wait_cycles=%0d last_rvfi_valid=%0d last_rvfi_pc=0x%08x blocked_req_seen=%0d",
                 error_count_q, POST_ERROR_WAIT_CYCLES,
                 rvfi_valid_i, rvfi_pc_i,
                 blocked_req_seen || (instr_req_i && !instr_gnt_i && instr_addr_i > stop_pc));
        $finish;
      end else begin
        $display("BSDCOV_EVAL_ERROR_HANDLED time_ps=%0t error_count=%0d wait_cycles=%0d last_rvfi_valid=%0d last_rvfi_pc=0x%08x blocked_req_seen=%0d",
                 $time,
                 error_count_q, POST_ERROR_WAIT_CYCLES,
                 rvfi_valid_i, rvfi_pc_i,
                 blocked_req_seen || (instr_req_i && !instr_gnt_i && instr_addr_i > stop_pc));
        epoch_done <= 1'b1;
        done_reason <= 32'd2;
      end
    end

    if (rvfi_valid_i && rvfi_pc_i == stop_pc) begin
      logic [31:0] retired_pc;
      logic [31:0] retired_insn;
      retired_pc = rvfi_pc_i;
      retired_insn = rvfi_insn_i;
      if (rvfi_insn_i != stop_instruction) begin
        $fatal(1, "BSDCOV_EVAL unexpected instruction pc=0x%08x insn=0x%08x expected=0x%08x",
               rvfi_pc_i, rvfi_insn_i, stop_instruction);
      end
      retired_pc_q <= retired_pc;
      retired_insn_q <= retired_insn;
      if (finish_on_epoch_done) begin
        #1ps;
        $display("BSDCOV_EVAL_RETIRED pc=0x%08x insn=0x%08x blocked_req_seen=%0d",
                 retired_pc, retired_insn,
                 blocked_req_seen || (instr_req_i && !instr_gnt_i && instr_addr_i > stop_pc));
        $finish;
      end else begin
        $display("BSDCOV_EVAL_RETIRED time_ps=%0t pc=0x%08x insn=0x%08x blocked_req_seen=%0d",
                 $time,
                 retired_pc, retired_insn,
                 blocked_req_seen || (instr_req_i && !instr_gnt_i && instr_addr_i > stop_pc));
        epoch_done <= 1'b1;
        done_reason <= 32'd1;
      end
    end
  end
endmodule

bind core_ibex_tb_top bsdcov_instr_gen_eval_stop u_bsdcov_instr_gen_eval_stop (
  .clk_i(clk),
  .rvfi_valid_i(rvfi_if.valid),
  .rvfi_pc_i(rvfi_if.pc_rdata),
  .rvfi_insn_i(rvfi_if.insn),
  .instr_req_i(instr_mem_vif.request),
  .instr_gnt_i(instr_mem_vif.grant),
  .instr_addr_i(instr_mem_vif.addr),
  .alert_minor_i(dut.u_ibex_top.alert_minor_o),
  .alert_major_internal_i(dut.u_ibex_top.alert_major_internal_o),
  .alert_major_bus_i(dut.u_ibex_top.alert_major_bus_o)
);
