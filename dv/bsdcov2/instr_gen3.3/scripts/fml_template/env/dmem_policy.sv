module bsdcov_dmem_policy_assume #(
  parameter logic [31:0] DATA_START = 32'h8fff_0000,
  parameter logic [31:0] DATA_END   = 32'h9000_0000
) (
  input logic        clk_i,
  input logic        rst_ni,

  input logic        data_req_o,
  input logic        data_we_o,
  input logic [3:0]  data_be_o,
  input logic [31:0] data_addr_o,
  input logic        data_err_i
);

  function automatic logic data_addr_allowed(input logic [31:0] addr);
    data_addr_allowed = (addr >= DATA_START) && (addr < DATA_END);
  endfunction

  function automatic logic be_align_ok(
    input logic [31:0] addr,
    input logic [3:0]  be
  );
    begin
      unique case (be)
        // byte
        4'b0001,
        4'b0010,
        4'b0100,
        4'b1000: be_align_ok = 1'b1;

        // halfword
        4'b0011,
        4'b1100: be_align_ok = (addr[0] == 1'b0);

        // word
        4'b1111: be_align_ok = (addr[1:0] == 2'b00);

        default: be_align_ok = 1'b0;
      endcase
    end
  endfunction

  ASM_BSDCOV_dmem_addr_allowed: assume property (
    @(posedge clk_i) disable iff (!rst_ni)
      data_req_o |-> data_addr_allowed(data_addr_o)
  );

  ASM_BSDCOV_dmem_align_ok: assume property (
    @(posedge clk_i) disable iff (!rst_ni)
      data_req_o |-> be_align_ok(data_addr_o, data_be_o)
  );

  ASM_BSDCOV_no_dmem_bus_err: assume property (
    @(posedge clk_i) disable iff (!rst_ni)
      data_err_i == 1'b0
  );

  logic unused_dmem_policy;
  assign unused_dmem_policy = data_we_o;

endmodule


bind ibex_top : ibex_top
bsdcov_dmem_policy_assume #(
  .DATA_START (32'h8fff_0000),
  .DATA_END   (32'h9000_0000)
) u_bsd_cov_dmem_policy_assume (
  .clk_i       (clk_i),
  .rst_ni      (rst_ni),

  .data_req_o  (data_req_o),
  .data_we_o   (data_we_o),
  .data_be_o   (data_be_o),
  .data_addr_o (data_addr_o),
  .data_err_i  (data_err_i)
);