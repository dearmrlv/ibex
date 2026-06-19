// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

interface ibex_mem_intf#(
  parameter int ADDR_WIDTH = 32,
  parameter int DATA_WIDTH = 32,
  parameter int INTG_WIDTH = 7
) (
  input clk,
  input limit_common_init_imem
);
  logic [31:0] bsdcov_imem_last_addr;
  initial begin
    bsdcov_imem_last_addr = 32'h8000_011c;
    void'($value$plusargs("bsdcov_imem_last_addr=%h", bsdcov_imem_last_addr));
  end

  task automatic bsdcov_set_last_addr(input logic [31:0] addr);
    bsdcov_imem_last_addr = addr;
    $display("BSDCOV_EVAL_IMEM_LAST_ADDR 0x%08x", addr);
  endtask

  wire                     reset;
  wire                     request;
  wire                     grant;
  wire                     grant_bounded;
  wire  [ADDR_WIDTH-1:0]   addr;
  wire                     we;
  wire  [DATA_WIDTH/8-1:0] be;
  wire                     rvalid;
  wire  [DATA_WIDTH-1:0]   wdata;
  wire  [INTG_WIDTH-1:0]   wintg;
  wire  [DATA_WIDTH-1:0]   rdata;
  wire  [INTG_WIDTH-1:0]   rintg;
  wire                     error;
  wire                     misaligned_first;
  wire                     misaligned_second;
  wire                     misaligned_first_saw_error;
  wire                     m_mode_access;
  wire                     spurious_response;

  assign grant_bounded = grant &&
      (!limit_common_init_imem ||
       (addr >= 32'h8000_0080 && addr <= bsdcov_imem_last_addr));

  clocking request_driver_cb @(posedge clk);
    input   reset;
    output  request;
    input   grant = grant_bounded;
    output  addr;
    output  we;
    output  be;
    input   rvalid;
    output  wdata;
    output  wintg;
    input   rdata;
    input   rintg;
    input   error;
    input   spurious_response;
  endclocking

  clocking response_driver_cb @(posedge clk);
    input   reset;
    input   request;
    output  grant;
    input   addr;
    input   we;
    input   be;
    output  rvalid;
    input   wdata;
    input   wintg;
    output  rdata;
    output  rintg;
    output  error;
    output  spurious_response;
  endclocking

  clocking monitor_cb @(posedge clk);
    input reset;
    input request;
    input grant = grant_bounded;
    input addr;
    input we;
    input be;
    input rvalid;
    input wdata;
    input wintg;
    input rdata;
    input rintg;
    input error;
    input misaligned_first;
    input misaligned_second;
    input misaligned_first_saw_error;
    input m_mode_access;
    input spurious_response;
  endclocking

  task automatic wait_clks(input int num);
    repeat (num) @(posedge clk);
  endtask

  task automatic wait_neg_clks(input int num);
    repeat (num) @(negedge clk);
  endtask

endinterface : ibex_mem_intf
