// Runtime-configurable retirement stop monitor for BSD-Cov instruction generation.
module bsdcov_instr_gen_eval_stop (
  input logic clk_i,
  input logic rvfi_valid_i,
  input logic [31:0] rvfi_pc_i,
  input logic [31:0] rvfi_insn_i,
  input logic instr_req_i,
  input logic instr_gnt_i,
  input logic [31:0] instr_addr_i
);
  logic [31:0] stop_pc;
  logic [31:0] stop_instruction;
  logic blocked_req_seen = 1'b0;

  initial begin
    stop_pc = 32'h8000_011c;
    stop_instruction = 32'h0000_0f93;
    void'($value$plusargs("bsdcov_stop_pc=%h", stop_pc));
    void'($value$plusargs("bsdcov_stop_instruction=%h", stop_instruction));
  end

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
    if (rvfi_valid_i && rvfi_pc_i == stop_pc) begin
      logic [31:0] retired_pc;
      logic [31:0] retired_insn;
      retired_pc = rvfi_pc_i;
      retired_insn = rvfi_insn_i;
      if (rvfi_insn_i != stop_instruction) begin
        $fatal(1, "BSDCOV_EVAL unexpected instruction pc=0x%08x insn=0x%08x expected=0x%08x",
               rvfi_pc_i, rvfi_insn_i, stop_instruction);
      end
      #1ps;
      $display("BSDCOV_EVAL_RETIRED pc=0x%08x insn=0x%08x blocked_req_seen=%0d",
               retired_pc, retired_insn,
               blocked_req_seen || (instr_req_i && !instr_gnt_i && instr_addr_i > stop_pc));
      $finish;
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
  .instr_addr_i(instr_mem_vif.addr)
);
