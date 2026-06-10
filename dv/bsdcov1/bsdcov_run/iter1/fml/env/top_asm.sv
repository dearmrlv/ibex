module ibex_top_env_assume import ibex_pkg::*; (
  input logic        clk_i,
  input logic        rst_ni,

  input logic [31:0] boot_addr_i,
  input ibex_mubi_t  fetch_enable_i,

  input logic        debug_req_i,
  input logic        irq_software_i,
  input logic        irq_timer_i,
  input logic        irq_external_i,
  input logic [14:0] irq_fast_i,
  input logic        irq_nm_i,

  input logic        scramble_key_valid_i
);

  ASM_BSDCOV_boot_addr: assume property (
    @(posedge clk_i) disable iff (!rst_ni)
      boot_addr_i == 32'h8000_0000
  );

  ASM_BSDCOV_fetch_enable: assume property (
    @(posedge clk_i) disable iff (!rst_ni)
      fetch_enable_i == IbexMuBiOn
  );

  ASM_BSDCOV_no_debug_req: assume property (
    @(posedge clk_i) disable iff (!rst_ni)
      debug_req_i == 1'b0
  );

  ASM_BSDCOV_no_irq: assume property (
    @(posedge clk_i) disable iff (!rst_ni)
      irq_software_i == 1'b0 &&
      irq_timer_i    == 1'b0 &&
      irq_external_i == 1'b0 &&
      irq_fast_i     == 15'b0 &&
      irq_nm_i       == 1'b0
  );

  ASM_BSDCOV_scramble_key_valid: assume property (
    @(posedge clk_i) disable iff (!rst_ni)
      scramble_key_valid_i == 1'b1
  );

endmodule

bind ibex_top : ibex_top
ibex_top_env_assume u_ibex_top_env_assume (
  .clk_i                (clk_i),
  .rst_ni               (rst_ni),

  .boot_addr_i          (boot_addr_i),
  .fetch_enable_i       (fetch_enable_i),

  .debug_req_i          (debug_req_i),
  .irq_software_i       (irq_software_i),
  .irq_timer_i          (irq_timer_i),
  .irq_external_i       (irq_external_i),
  .irq_fast_i           (irq_fast_i),
  .irq_nm_i             (irq_nm_i),

  .scramble_key_valid_i (scramble_key_valid_i)
);