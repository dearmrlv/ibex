#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path

BASE = 0x80000000


def hx(value: int) -> str:
    text = f"{value & 0xffffffff:08x}"
    return "32'h" + text[:4] + "_" + text[4:]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--bin", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    data = args.bin.read_bytes()
    if len(data) % 4:
        raise RuntimeError(f"binary size is not word aligned: {len(data)}")
    words = [int.from_bytes(data[i:i + 4], "little") for i in range(0, len(data), 4)]
    entries = [(BASE + i * 4, word) for i, word in enumerate(words)]

    lookup = "\n".join(f"        {hx(a)}: rom_lookup = {hx(w)};" for a, w in entries)
    hits = "\n".join(f"        {hx(a)}: rom_hit = 1'b1;" for a, _ in entries)
    sv = f"""// AUTO-GENERATED. Source of truth: eval.bin (little-endian, base 0x80000000).
module imem (
  input logic clk_i, input logic rst_ni, input logic req_i,
  input logic [31:0] addr_i, output logic gnt_o, output logic rvalid_o,
  output logic err_o, output logic [31:0] data_o
);
  logic in_proc, accept_req;
  logic [31:0] addr_in_proc;
  logic addr_met;
  assign in_proc = gnt_o | rvalid_o;
  assign accept_req = req_i & ~in_proc;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) gnt_o <= '0; else gnt_o <= accept_req;
  end
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) rvalid_o <= '0; else rvalid_o <= gnt_o;
  end
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) addr_in_proc <= '0; else if (accept_req) addr_in_proc <= addr_i;
  end
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) err_o <= 1'b0; else err_o <= gnt_o & (addr_in_proc[1:0] != 2'b00);
  end

  assign addr_met = rom_hit(addr_in_proc);
`ifdef BSDFML
  (* anyseq *) logic [31:0] any_data;
`endif
  always_comb begin
    data_o = '0;
    if (rvalid_o) begin
      if (addr_met && !err_o) data_o = rom_lookup(addr_in_proc);
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
  instr_vld u_any_data_vld (.instr_i(data_o), .instr_vld(instr_vld));
  ASM_BSDCOV_legal_instr: assume property (
    @(posedge clk_i) disable iff (!rst_ni) rvalid_o |-> instr_vld
  );
`endif

  function automatic logic [31:0] rom_lookup(input logic [31:0] addr);
    logic [31:0] aligned_addr;
    begin
      aligned_addr = {{addr[31:2], 2'b00}};
      unique case (aligned_addr)
{lookup}
        default: rom_lookup = 32'h0000_0000;
      endcase
    end
  endfunction

  function automatic logic rom_hit(input logic [31:0] addr);
    logic [31:0] aligned_addr;
    begin
      aligned_addr = {{addr[31:2], 2'b00}};
      unique case (aligned_addr)
{hits}
        default: rom_hit = 1'b0;
      endcase
    end
  endfunction
endmodule

module imem_if (
  input logic clk_i, input logic rst_ni, input logic instr_req_o,
  input logic instr_gnt_i, input logic instr_rvalid_i,
  input logic [31:0] instr_addr_o, input logic [31:0] instr_rdata_i,
  input logic instr_err_i, input logic [6:0] instr_rdata_intg_i
);
  logic imem_gnt_o, imem_rvalid_o, imem_err_o;
  logic [31:0] imem_rdata_o;
  imem u_fml_imem (
    .clk_i(clk_i), .rst_ni(rst_ni), .req_i(instr_req_o), .addr_i(instr_addr_o),
    .gnt_o(imem_gnt_o), .rvalid_o(imem_rvalid_o), .data_o(imem_rdata_o), .err_o(imem_err_o)
  );

  function automatic logic [38:0] secded_inv_39_32_enc(input logic [31:0] data);
    logic [38:0] code;
    begin
      code = 39'(data);
      code[32] = ^(code & 39'h002606BD25);
      code[33] = ^(code & 39'h00DEBA8050);
      code[34] = ^(code & 39'h00413D89AA);
      code[35] = ^(code & 39'h0031234ED1);
      code[36] = ^(code & 39'h00C2C1323B);
      code[37] = ^(code & 39'h002DCC624C);
      code[38] = ^(code & 39'h0098505586);
      secded_inv_39_32_enc = code ^ 39'h2A00000000;
    end
  endfunction
  logic [38:0] instr_rdata_enc;
  assign instr_rdata_enc = secded_inv_39_32_enc(instr_rdata_i);
  always_comb if (rst_ni) begin
    assume(instr_gnt_i == imem_gnt_o);
    assume(instr_rvalid_i == imem_rvalid_o);
    if (instr_rvalid_i) begin
      assume(instr_rdata_i == imem_rdata_o);
      assume(instr_err_i == imem_err_o);
    end else assume(instr_err_i == 1'b0);
    assume(instr_rdata_intg_i == instr_rdata_enc[38:32]);
  end
endmodule

bind ibex_top : ibex_top imem_if imem_if_inst (
  .clk_i(clk_i), .rst_ni(rst_ni), .instr_req_o(instr_req_o),
  .instr_gnt_i(instr_gnt_i), .instr_rvalid_i(instr_rvalid_i),
  .instr_addr_o(instr_addr_o), .instr_rdata_i(instr_rdata_i),
  .instr_err_i(instr_err_i), .instr_rdata_intg_i(instr_rdata_intg_i)
);
"""
    args.output.write_text(sv, encoding="utf-8")

    # Verify that every emitted lookup line exactly reflects the binary.
    emitted = [
        line.strip()
        for line in sv.splitlines()
        if line.strip().startswith("32'h") and ": rom_lookup =" in line
    ]
    expected = [f"{hx(a)}: rom_lookup = {hx(w)};" for a, w in entries]
    if emitted != expected:
        raise RuntimeError("generated imem.sv does not match eval.bin")
    print(f"Wrote {args.output}: {len(words)} words")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
