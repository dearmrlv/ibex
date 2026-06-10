module imem (
  input  logic        clk_i,
  input  logic        rst_ni,
  input  logic        req_i,
  input  logic [31:0] addr_i,
  output logic        gnt_o,
  output logic        rvalid_o,
  output logic        err_o,
  output logic [31:0] data_o
);

  /*
  Can only deal with one req a time, no out-standing req is allowed
  */
  logic in_proc;
  logic accept_req;

  assign in_proc = gnt_o | rvalid_o;
  assign accept_req = req_i & ~in_proc;

  // make gnt a pulse
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) 
      gnt_o <= '0;
    else
      gnt_o <= accept_req;
  end

  // after gnt, next cycle launch rvalid
  always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni)
        rvalid_o <= '0;
      else
        rvalid_o <= gnt_o;
  end

  logic [31:0] addr_in_proc;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni)
      addr_in_proc <= '0;
    else if (accept_req)
      addr_in_proc <= addr_i;
  end
  
  logic err_d;
  // err_o is aligned with rvalid_o
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni)
      err_o <= 1'b0;
    else
      err_o <= gnt_o & (addr_in_proc[1:0] != 2'b00);
  end

  /*
    TODO: 
    If addr met, make data_o the recorded data
    Else, make data_o undriven (can be any valid data)
  */
  logic addr_met;
  assign addr_met = rom_hit(addr_in_proc);
  
`ifdef BSDFML
  (* anyseq *) logic [31:0] any_data;
`endif

  always_comb begin
    data_o = '0;

    if (rvalid_o) begin
      if (addr_met && !err_o)
        data_o = rom_lookup(addr_in_proc);
      else
`ifdef BSDFML
        data_o = any_data;
`else
        data_o = '0;
`endif
    end
  end

`ifdef BSDFML
  logic instr_vld;

  instr_vld u_any_data_vld (
    .instr_i   (data_o),
    .instr_vld (instr_vld)
  );

  property p_legal_instr;
  @(posedge clk_i) disable iff (!rst_ni)
  rvalid_o |-> instr_vld;
  endproperty
  ASM_BSDCOV_legal_instr: assume property (p_legal_instr);
`endif

  function automatic logic [31:0] rom_lookup(input logic [31:0] addr);
    logic [31:0] aligned_addr;
    begin
      aligned_addr = {addr[31:2], 2'b00};
      unique case (aligned_addr)
        32'h8000_0080: rom_lookup = 32'h0000_0297;
        32'h8000_0084: rom_lookup = 32'h0b82_8293;
        32'h8000_0088: rom_lookup = 32'h3052_9073;
        32'h8000_008c: rom_lookup = 32'h3040_5073;
        32'h8000_0090: rom_lookup = 32'h3400_5073;
        32'h8000_0094: rom_lookup = 32'h3410_5073;
        32'h8000_0098: rom_lookup = 32'h0000_22b7;
        32'h8000_009c: rom_lookup = 32'h8002_8293;
        32'h8000_00a0: rom_lookup = 32'h3002_9073;
        32'h8000_00a4: rom_lookup = 32'h0000_0093;
        32'h8000_00a8: rom_lookup = 32'h8fff_f137;
        32'h8000_00ac: rom_lookup = 32'h0000_0193;
        32'h8000_00b0: rom_lookup = 32'h0000_0213;
        32'h8000_00b4: rom_lookup = 32'h0000_0293;
        32'h8000_00b8: rom_lookup = 32'h0000_0313;
        32'h8000_00bc: rom_lookup = 32'h0000_0393;
        32'h8000_00c0: rom_lookup = 32'h0000_0413;
        32'h8000_00c4: rom_lookup = 32'h0000_0493;
        32'h8000_00c8: rom_lookup = 32'h0000_0513;
        32'h8000_00cc: rom_lookup = 32'h0000_0593;
        32'h8000_00d0: rom_lookup = 32'h0000_0613;
        32'h8000_00d4: rom_lookup = 32'h0000_0693;
        32'h8000_00d8: rom_lookup = 32'h0000_0713;
        32'h8000_00dc: rom_lookup = 32'h0000_0793;
        32'h8000_00e0: rom_lookup = 32'h0000_0813;
        32'h8000_00e4: rom_lookup = 32'h0000_0893;
        32'h8000_00e8: rom_lookup = 32'h0000_0913;
        32'h8000_00ec: rom_lookup = 32'h0000_0993;
        32'h8000_00f0: rom_lookup = 32'h0000_0a13;
        32'h8000_00f4: rom_lookup = 32'h0000_0a93;
        32'h8000_00f8: rom_lookup = 32'h0000_0b13;
        32'h8000_00fc: rom_lookup = 32'h0000_0b93;
        32'h8000_0100: rom_lookup = 32'h0000_0c13;
        32'h8000_0104: rom_lookup = 32'h0000_0c93;
        32'h8000_0108: rom_lookup = 32'h0000_0d13;
        32'h8000_010c: rom_lookup = 32'h0000_0d93;
        32'h8000_0110: rom_lookup = 32'h0000_0e13;
        32'h8000_0114: rom_lookup = 32'h0000_0e93;
        32'h8000_0118: rom_lookup = 32'h0000_0f13;
        32'h8000_011c: rom_lookup = 32'h0000_0f93;
        32'h8000_0120: rom_lookup = 32'h9000_02b7;
        32'h8000_0124: rom_lookup = 32'hff82_8293;
        32'h8000_0128: rom_lookup = 32'h0010_0313;
        32'h8000_012c: rom_lookup = 32'h0062_a023;
        32'h8000_0130: rom_lookup = 32'h1050_0073;
        32'h8000_0134: rom_lookup = 32'hffdf_f06f;
        32'h8000_0138: rom_lookup = 32'h9000_02b7;
        32'h8000_013c: rom_lookup = 32'hff82_8293;
        32'h8000_0140: rom_lookup = 32'h1010_0313;
        32'h8000_0144: rom_lookup = 32'h0062_a023;
        32'h8000_0148: rom_lookup = 32'h1050_0073;
        32'h8000_014c: rom_lookup = 32'hffdf_f06f;
        default:      rom_lookup = 32'h0000_0000;
      endcase
    end
  endfunction

  function automatic logic rom_hit(input logic [31:0] addr);
    logic [31:0] aligned_addr;
    begin
      aligned_addr = {addr[31:2], 2'b00};
      unique case (aligned_addr)
        32'h8000_0080: rom_hit = 1'b1;
        32'h8000_0084: rom_hit = 1'b1;
        32'h8000_0088: rom_hit = 1'b1;
        32'h8000_008c: rom_hit = 1'b1;
        32'h8000_0090: rom_hit = 1'b1;
        32'h8000_0094: rom_hit = 1'b1;
        32'h8000_0098: rom_hit = 1'b1;
        32'h8000_009c: rom_hit = 1'b1;
        32'h8000_00a0: rom_hit = 1'b1;
        32'h8000_00a4: rom_hit = 1'b1;
        32'h8000_00a8: rom_hit = 1'b1;
        32'h8000_00ac: rom_hit = 1'b1;
        32'h8000_00b0: rom_hit = 1'b1;
        32'h8000_00b4: rom_hit = 1'b1;
        32'h8000_00b8: rom_hit = 1'b1;
        32'h8000_00bc: rom_hit = 1'b1;
        32'h8000_00c0: rom_hit = 1'b1;
        32'h8000_00c4: rom_hit = 1'b1;
        32'h8000_00c8: rom_hit = 1'b1;
        32'h8000_00cc: rom_hit = 1'b1;
        32'h8000_00d0: rom_hit = 1'b1;
        32'h8000_00d4: rom_hit = 1'b1;
        32'h8000_00d8: rom_hit = 1'b1;
        32'h8000_00dc: rom_hit = 1'b1;
        32'h8000_00e0: rom_hit = 1'b1;
        32'h8000_00e4: rom_hit = 1'b1;
        32'h8000_00e8: rom_hit = 1'b1;
        32'h8000_00ec: rom_hit = 1'b1;
        32'h8000_00f0: rom_hit = 1'b1;
        32'h8000_00f4: rom_hit = 1'b1;
        32'h8000_00f8: rom_hit = 1'b1;
        32'h8000_00fc: rom_hit = 1'b1;
        32'h8000_0100: rom_hit = 1'b1;
        32'h8000_0104: rom_hit = 1'b1;
        32'h8000_0108: rom_hit = 1'b1;
        32'h8000_010c: rom_hit = 1'b1;
        32'h8000_0110: rom_hit = 1'b1;
        32'h8000_0114: rom_hit = 1'b1;
        32'h8000_0118: rom_hit = 1'b1;
        32'h8000_011c: rom_hit = 1'b1;
        32'h8000_0120: rom_hit = 1'b1;
        32'h8000_0124: rom_hit = 1'b1;
        32'h8000_0128: rom_hit = 1'b1;
        32'h8000_012c: rom_hit = 1'b1;
        32'h8000_0130: rom_hit = 1'b1;
        32'h8000_0134: rom_hit = 1'b1;
        32'h8000_0138: rom_hit = 1'b1;
        32'h8000_013c: rom_hit = 1'b1;
        32'h8000_0140: rom_hit = 1'b1;
        32'h8000_0144: rom_hit = 1'b1;
        32'h8000_0148: rom_hit = 1'b1;
        32'h8000_014c: rom_hit = 1'b1;
        default:      rom_hit = 1'b0;
      endcase
    end
  endfunction

endmodule

module imem_if (
  input  logic        clk_i,
  input  logic        rst_ni,
  input  logic        instr_req_o,
  input  logic        instr_gnt_i,
  input  logic        instr_rvalid_i,
  input  logic [31:0] instr_addr_o,
  input  logic [31:0] instr_rdata_i,
  input  logic        instr_err_i
);

  logic imem_gnt_o;
  logic imem_rvalid_o;
  logic [31:0] imem_rdata_o;
  logic imem_err_o;

  imem u_fml_imem (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .req_i(instr_req_o),
    .addr_i(instr_addr_o),
    .gnt_o(imem_gnt_o),
    .rvalid_o(imem_rvalid_o),
    .data_o(imem_rdata_o),
    .err_o(imem_err_o)
  );

  ASM_BSDCOV_imem_gnt: assume property (@(posedge clk_i) disable iff (!rst_ni) imem_gnt_o == instr_gnt_i);
  ASM_BSDCOV_imem_rvalid: assume property (@(posedge clk_i) disable iff (!rst_ni) imem_rvalid_o == instr_rvalid_i);
  ASM_BSDCOV_imem_rdata: assume property (@(posedge clk_i) disable iff (!rst_ni) imem_rdata_o == instr_rdata_i);
  ASM_BSDCOV_imem_err: assume property (@(posedge clk_i) disable iff (!rst_ni) imem_err_o == instr_err_i);

endmodule

bind ibex_top : ibex_top
imem_if
#(
)
imem_if_inst
(
    .clk_i          (clk_i),
    .rst_ni         (rst_ni),

    .instr_req_o    (instr_req_o),
    .instr_gnt_i    (instr_gnt_i),
    .instr_rvalid_i (instr_rvalid_i),
    .instr_addr_o   (instr_addr_o),
    .instr_rdata_i  (instr_rdata_i),
    .instr_err_i    (instr_err_i)
);