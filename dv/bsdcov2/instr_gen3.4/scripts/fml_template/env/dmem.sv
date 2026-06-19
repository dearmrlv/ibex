module dmem_if (
  input  logic        clk_i,
  input  logic        rst_ni,

  input  logic        data_req_o,
  input  logic        data_gnt_i,
  input  logic        data_rvalid_i,
  input  logic        data_we_o,
  input  logic [3:0]  data_be_o,
  input  logic [31:0] data_addr_o,
  input  logic [31:0] data_wdata_o,
  input  logic [6:0]  data_wdata_intg_o,

  input  logic [31:0] data_rdata_i,
  input  logic [6:0]  data_rdata_intg_i,
  input  logic        data_err_i
);

  logic in_proc;
  logic accept_req;

  logic dmem_gnt_o;
  logic dmem_rvalid_o;

  assign in_proc    = dmem_gnt_o | dmem_rvalid_o;
  assign accept_req = data_req_o & ~in_proc;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni)
      dmem_gnt_o <= 1'b0;
    else
      dmem_gnt_o <= accept_req;
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni)
      dmem_rvalid_o <= 1'b0;
    else
      dmem_rvalid_o <= dmem_gnt_o;
  end

`ifdef BSDFML
  (* anyseq *) logic [31:0] any_rdata;
`else
  logic [31:0] any_rdata;
  assign any_rdata = 32'h0000_0000;
`endif

  function automatic logic [38:0] secded_inv_39_32_enc(input logic [31:0] data);
    logic [38:0] code;
    begin
      code = {7'b0, data};

      code[32] = ^(code & 39'h002606BD25);
      code[33] = ^(code & 39'h00DEBA8050);
      code[34] = ^(code & 39'h00413D89AA);
      code[35] = ^(code & 39'h0031234ED1);
      code[36] = ^(code & 39'h00C2C1323B);
      code[37] = ^(code & 39'h002DCC624C);
      code[38] = ^(code & 39'h0098505586);

      code = code ^ 39'h2A00000000;

      secded_inv_39_32_enc = code;
    end
  endfunction

  logic [38:0] dmem_rdata_enc;
  assign dmem_rdata_enc = secded_inv_39_32_enc(data_rdata_i);

  always_comb begin
    if (rst_ni) begin
      assume(data_gnt_i    == dmem_gnt_o);
      assume(data_rvalid_i == dmem_rvalid_o);
  
      if (data_rvalid_i) begin
        assume(data_rdata_i == any_rdata);
        assume(data_err_i   == 1'b0);
      end else begin
        assume(data_err_i   == 1'b0);
      end
  
      assume(data_rdata_intg_i == dmem_rdata_enc[38:32]);
    end
  end

  // ASM_BSDCOV_dmem_gnt: assume property (
  //   @(posedge clk_i) disable iff (!rst_ni)
  //     data_gnt_i == dmem_gnt_o
  // );

  // ASM_BSDCOV_dmem_rvalid: assume property (
  //   @(posedge clk_i) disable iff (!rst_ni)
  //     data_rvalid_i == dmem_rvalid_o
  // );

  // ASM_BSDCOV_dmem_rdata: assume property (
  //   @(posedge clk_i) disable iff (!rst_ni)
  //     data_rvalid_i |-> data_rdata_i == any_rdata
  // );

  // ASM_BSDCOV_dmem_rdata_intg: assume property (
  //   @(posedge clk_i) disable iff (!rst_ni)
  //     data_rdata_intg_i == dmem_rdata_enc[38:32]
  // );

  // ASM_BSDCOV_dmem_err: assume property (
  //   @(posedge clk_i) disable iff (!rst_ni)
  //     data_rvalid_i |-> data_err_i == 1'b0
  // );

  // Avoid unused warnings.
  logic unused_dmem;
  assign unused_dmem = ^{
    data_we_o,
    data_be_o,
    data_addr_o,
    data_wdata_o,
    data_wdata_intg_o
  };

endmodule


bind ibex_top : ibex_top
dmem_if dmem_if_inst (
  .clk_i             (clk_i),
  .rst_ni            (rst_ni),

  .data_req_o        (data_req_o),
  .data_gnt_i        (data_gnt_i),
  .data_rvalid_i     (data_rvalid_i),
  .data_we_o         (data_we_o),
  .data_be_o         (data_be_o),
  .data_addr_o       (data_addr_o),
  .data_wdata_o      (data_wdata_o),
  .data_wdata_intg_o (data_wdata_intg_o),

  .data_rdata_i      (data_rdata_i),
  .data_rdata_intg_i (data_rdata_intg_i),
  .data_err_i        (data_err_i)
);