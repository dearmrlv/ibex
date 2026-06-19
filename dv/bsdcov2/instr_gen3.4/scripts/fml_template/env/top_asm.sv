// top_asm.sv
//
// Top-level environment assumptions for ibex_top under BSD-Cov formal.
// Intended to be used with ibex_top as the Jasper top.
//
// This file constrains primary inputs that are normally driven by the
// testbench/top-level integration, not by Ibex itself.

module ibex_top_env_assume
  import ibex_pkg::*;
#(
  parameter int unsigned SCRAMBLE_KEY_W_P   = SCRAMBLE_KEY_W,
  parameter int unsigned SCRAMBLE_NONCE_W_P = SCRAMBLE_NONCE_W
) (
  input logic                         clk_i,
  input logic                         rst_ni,

  input logic                         test_en_i,
  input logic                         scan_rst_ni,

  input logic [31:0]                  boot_addr_i,
  input ibex_mubi_t                   fetch_enable_i,

  input logic                         debug_req_i,

  input logic                         irq_software_i,
  input logic                         irq_timer_i,
  input logic                         irq_external_i,
  input logic [14:0]                  irq_fast_i,
  input logic                         irq_nm_i,

  input logic                         scramble_key_valid_i,
  input logic [SCRAMBLE_KEY_W_P-1:0]  scramble_key_i,
  input logic [SCRAMBLE_NONCE_W_P-1:0] scramble_nonce_i
);

  // Used to avoid $stable checks comparing against reset-cycle values.
  logic fml_past_valid_q;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      fml_past_valid_q <= 1'b0;
    end else begin
      fml_past_valid_q <= 1'b1;
    end
  end

  // Ibex boot PC is {boot_addr_i[31:8], 8'h80}.
  // Therefore boot_addr_i = 0x8000_0000 gives reset fetch PC 0x8000_0080.
  ASM_BSDCOV_boot_addr: assume property (
    @(posedge clk_i) disable iff (!rst_ni)
      boot_addr_i == 32'h8000_0000
  );

  // Keep instruction fetch enabled.
  ASM_BSDCOV_fetch_enable: assume property (
    @(posedge clk_i) disable iff (!rst_ni)
      fetch_enable_i == IbexMuBiOn
  );

  // Formal environment should not use test mode.
  ASM_BSDCOV_test_en_off: assume property (
    @(posedge clk_i) disable iff (!rst_ni)
      test_en_i == 1'b0
  );

  // Tie scan reset to normal reset. This prevents scan reset from becoming
  // an unconstrained independent reset source.
  ASM_BSDCOV_scan_rst_match: assume property (
    @(posedge clk_i)
      scan_rst_ni == rst_ni
  );

  // Do not let the formal environment asynchronously enter debug mode.
  ASM_BSDCOV_no_debug_req: assume property (
    @(posedge clk_i) disable iff (!rst_ni)
      debug_req_i == 1'b0
  );

  // Disable all external interrupt sources. This prevents the environment from
  // forcing PC redirects to interrupt/NMI vectors.
  ASM_BSDCOV_no_irq: assume property (
    @(posedge clk_i) disable iff (!rst_ni)
      irq_software_i == 1'b0 &&
      irq_timer_i    == 1'b0 &&
      irq_external_i == 1'b0 &&
      irq_fast_i     == 15'b0 &&
      irq_nm_i       == 1'b0
  );

  // For ICacheScramble/SecureIbex configurations, keep the scramble key valid.
  ASM_BSDCOV_scramble_key_valid: assume property (
    @(posedge clk_i) disable iff (!rst_ni)
      scramble_key_valid_i == 1'b1
  );

  // The scramble key and nonce model top-level integration state.
  // They should not change arbitrarily during formal proof.
  ASM_BSDCOV_scramble_key_stable: assume property (
    @(posedge clk_i) disable iff (!rst_ni)
      fml_past_valid_q |-> $stable(scramble_key_i)
  );

  ASM_BSDCOV_scramble_nonce_stable: assume property (
    @(posedge clk_i) disable iff (!rst_ni)
      fml_past_valid_q |-> $stable(scramble_nonce_i)
  );

`ifdef BSDCOV_FIX_SCRAMBLE_DEFAULT
  // Optional stronger version:
  // Use this if you want to match the common OpenTitan/Ibex default constants
  // rather than leaving the stable key/nonce symbolic.
  ASM_BSDCOV_scramble_key_default: assume property (
    @(posedge clk_i) disable iff (!rst_ni)
      scramble_key_i == RndCnstIbexKeyDefault
  );

  ASM_BSDCOV_scramble_nonce_default: assume property (
    @(posedge clk_i) disable iff (!rst_ni)
      scramble_nonce_i == RndCnstIbexNonceDefault
  );
`endif

endmodule


bind ibex_top : ibex_top
ibex_top_env_assume u_ibex_top_env_assume (
  .clk_i                (clk_i),
  .rst_ni               (rst_ni),

  .test_en_i            (test_en_i),
  .scan_rst_ni          (scan_rst_ni),

  .boot_addr_i          (boot_addr_i),
  .fetch_enable_i       (fetch_enable_i),

  .debug_req_i          (debug_req_i),

  .irq_software_i       (irq_software_i),
  .irq_timer_i          (irq_timer_i),
  .irq_external_i       (irq_external_i),
  .irq_fast_i           (irq_fast_i),
  .irq_nm_i             (irq_nm_i),

  .scramble_key_valid_i (scramble_key_valid_i),
  .scramble_key_i       (scramble_key_i),
  .scramble_nonce_i     (scramble_nonce_i)
);