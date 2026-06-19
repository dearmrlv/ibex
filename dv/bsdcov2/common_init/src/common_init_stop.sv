module bsdcov_common_init_stop (
  input logic        clk_i,
  input logic        rvfi_valid_i,
  input logic [31:0] rvfi_pc_i,
  input logic        instr_req_i,
  input logic        instr_gnt_i,
  input logic        instr_rvalid_i,
  input logic [31:0] instr_addr_i
);
  integer outstanding_q = 0;
  logic retired_q = 1'b0;
  logic blocked_req_seen_q = 1'b0;

  always @(posedge clk_i) begin
    integer outstanding_n;
    logic retire_now;

    outstanding_n = outstanding_q;
    if (instr_req_i && instr_gnt_i) outstanding_n = outstanding_n + 1;
    if (instr_rvalid_i) outstanding_n = outstanding_n - 1;
    retire_now = rvfi_valid_i && rvfi_pc_i == 32'h8000_011c;

    if (outstanding_n < 0) begin
      $fatal(1, "BSDCOV_COMMON_INIT negative instruction outstanding count");
    end
    if (instr_gnt_i &&
        (instr_addr_i < 32'h8000_0080 || instr_addr_i > 32'h8000_011c)) begin
      $fatal(1, "BSDCOV_COMMON_INIT illegal grant addr=0x%08x", instr_addr_i);
    end
    if (instr_req_i && !instr_gnt_i && instr_addr_i > 32'h8000_011c) begin
      blocked_req_seen_q <= 1'b1;
    end

    outstanding_q <= outstanding_n;
    if (retire_now) retired_q <= 1'b1;

    if ((retired_q || retire_now) && outstanding_n == 0) begin
      // RVFI marks architectural retirement and all accepted instruction-bus
      // requests have completed. Capture the settled state before finishing.
      #1ps;
      $display("BSDCOV_COMMON_INIT_RETIRED pc=0x8000011c outstanding=0 blocked_req_seen=%0d",
               blocked_req_seen_q ||
               (instr_req_i && !instr_gnt_i && instr_addr_i > 32'h8000_011c));
      $finish;
    end
  end
endmodule

bind core_ibex_tb_top bsdcov_common_init_stop u_bsdcov_common_init_stop (
  .clk_i        (clk),
  .rvfi_valid_i (rvfi_if.valid),
  .rvfi_pc_i    (rvfi_if.pc_rdata),
  .instr_req_i  (instr_mem_vif.request),
  .instr_gnt_i  (instr_mem_vif.grant_bounded),
  .instr_rvalid_i(instr_mem_vif.rvalid),
  .instr_addr_i (instr_mem_vif.addr)
);
