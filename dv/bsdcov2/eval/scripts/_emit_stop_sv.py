#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path


def sv_hex(value: str) -> str:
    digits = value.removeprefix("0x").lower().zfill(8)
    return f"32'h{digits[:4]}_{digits[4:]}"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--layout-json", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    layout = json.loads(args.layout_json.read_text(encoding="utf-8"))
    stop_pc = sv_hex(layout["stop_pc"])
    stop_instruction = sv_hex(layout["stop_instruction"])
    args.output.write_text(f"""// AUTO-GENERATED evaluation retirement monitor.
module bsdcov_eval_stop (
  input logic clk_i,
  input logic rvfi_valid_i,
  input logic [31:0] rvfi_pc_i,
  input logic [31:0] rvfi_insn_i,
  input logic instr_req_i,
  input logic instr_gnt_i,
  input logic [31:0] instr_addr_i
);
  logic blocked_req_seen = 1'b0;
  always @(posedge clk_i) begin
    if (instr_req_i && !instr_gnt_i && instr_addr_i > {stop_pc}) begin
      blocked_req_seen <= 1'b1;
    end
    if (rvfi_valid_i && rvfi_pc_i == {stop_pc}) begin
      logic [31:0] retired_pc;
      logic [31:0] retired_insn;
      retired_pc = rvfi_pc_i;
      retired_insn = rvfi_insn_i;
      if (rvfi_insn_i != {stop_instruction}) begin
        $fatal(1, "BSDCOV_EVAL unexpected instruction pc=0x%08x insn=0x%08x", rvfi_pc_i, rvfi_insn_i);
      end
      #1ps;
      $display("BSDCOV_EVAL_RETIRED pc=0x%08x insn=0x%08x blocked_req_seen=%0d",
               retired_pc, retired_insn,
               blocked_req_seen || (instr_req_i && !instr_gnt_i && instr_addr_i > {stop_pc}));
      $finish;
    end
  end
endmodule

bind core_ibex_tb_top bsdcov_eval_stop u_bsdcov_eval_stop (
  .clk_i(clk),
  .rvfi_valid_i(rvfi_if.valid),
  .rvfi_pc_i(rvfi_if.pc_rdata),
  .rvfi_insn_i(rvfi_if.insn),
  .instr_req_i(instr_mem_vif.request),
  .instr_gnt_i(instr_mem_vif.grant),
  .instr_addr_i(instr_mem_vif.addr)
);
""", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
