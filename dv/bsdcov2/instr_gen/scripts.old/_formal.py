#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import shutil
from pathlib import Path
from typing import Any

from _common import run
from _image import IMAGE_BASE, read_words


ELABORATE = r"""elaborate -top ibex_top \
  -parameter RV32E 0 \
  -parameter RV32M {ibex_pkg::RV32MSingleCycle} \
  -parameter RV32B {ibex_pkg::RV32BOTEarlGrey} \
  -parameter RV32ZC {ibex_pkg::RV32ZcaZcbZcmp} \
  -parameter RegFile {ibex_pkg::RegFileFF} \
  -parameter BranchTargetALU 1 \
  -parameter WritebackStage 1 \
  -parameter ICache 1 \
  -parameter ICacheECC 1 \
  -parameter ICacheScramble 1 \
  -parameter ICacheTweakInfection 0 \
  -parameter BranchPredictor 0 \
  -parameter DbgTriggerEn 1 \
  -parameter DbgHwBreakNum 1 \
  -parameter SecureIbex 1 \
  -parameter LockstepOffset 1 \
  -parameter PMPEnable 1 \
  -parameter PMPGranularity 0 \
  -parameter PMPNumRegions 16 \
  -parameter MHPMCounterNum 10 \
  -parameter MHPMCounterWidth 32 \
  -parameter DmBaseAddr {32'h1A110000} \
  -parameter DmAddrMask {32'h00000FFF} \
  -parameter DmHaltAddr {32'h80000000} \
  -parameter DmExceptionAddr {32'h80000008}"""


def _hx(value: int) -> str:
    return f"32'h{value:08x}"


def emit_formal_imem(image: Path, output: Path, window: int) -> None:
    words = read_words(image)
    start = IMAGE_BASE + image.stat().st_size
    lookup = "\n".join(f"      {_hx(address)}: fixed_lookup = {_hx(word)};"
                       for address, word in sorted(words.items()))
    hits = "\n".join(f"      {_hx(address)}: fixed_hit = 1'b1;"
                     for address in sorted(words))
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(f"""// AUTO-GENERATED for one BSD-Cov instruction-generation epoch.
module imem(
  input logic clk_i, input logic rst_ni, input logic req_i,
  input logic [31:0] addr_i, output logic gnt_o, output logic rvalid_o,
  output logic err_o, output logic [31:0] data_o
);
  localparam logic [31:0] SYMBOLIC_START = {_hx(start)};
  localparam int SYMBOLIC_WORDS = {window};
  (* anyseq *) logic [31:0] symbolic_word [0:SYMBOLIC_WORDS-1];
  logic [31:0] addr_in_proc;
  logic accepted;
  logic address_allowed;
  integer symbolic_index;

  always_comb begin
    symbolic_index = (addr_i - SYMBOLIC_START) >> 2;
    address_allowed = fixed_hit(addr_i) ||
      ((addr_i >= SYMBOLIC_START) && (symbolic_index >= 0) &&
       (symbolic_index < SYMBOLIC_WORDS) && (addr_i[1:0] == 2'b00));
  end
  assign accepted = req_i && !gnt_o && !rvalid_o && address_allowed;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) gnt_o <= 1'b0; else gnt_o <= accepted;
    if (!rst_ni) rvalid_o <= 1'b0; else rvalid_o <= gnt_o;
    if (!rst_ni) addr_in_proc <= '0; else if (accepted) addr_in_proc <= addr_i;
    if (!rst_ni) err_o <= 1'b0; else err_o <= 1'b0;
  end
  always_comb begin
    data_o = '0;
    if (rvalid_o) begin
      if (fixed_hit(addr_in_proc)) data_o = fixed_lookup(addr_in_proc);
      else data_o = symbolic_word[(addr_in_proc - SYMBOLIC_START) >> 2];
    end
  end

  genvar gi;
  generate for (gi = 0; gi < SYMBOLIC_WORDS; gi++) begin : g_legal
    logic legal;
    instr_vld u_instr_vld(.instr_i(symbolic_word[gi]), .instr_vld(legal));
    ASM_BSDCOV_legal: assume property (@(posedge clk_i) legal &&
                                       symbolic_word[gi][1:0] == 2'b11);
  end endgenerate

  function automatic logic [31:0] fixed_lookup(input logic [31:0] addr);
    unique case ({{addr[31:2], 2'b00}})
{lookup}
      default: fixed_lookup = '0;
    endcase
  endfunction
  function automatic logic fixed_hit(input logic [31:0] addr);
    unique case ({{addr[31:2], 2'b00}})
{hits}
      default: fixed_hit = 1'b0;
    endcase
  endfunction
endmodule

module imem_if(
  input logic clk_i, input logic rst_ni, input logic instr_req_o,
  input logic instr_gnt_i, input logic instr_rvalid_i,
  input logic [31:0] instr_addr_o, input logic [31:0] instr_rdata_i,
  input logic instr_err_i, input logic [6:0] instr_rdata_intg_i
);
  logic gnt, rvalid, err;
  logic [31:0] data;
  imem u_fml_imem(.clk_i(clk_i), .rst_ni(rst_ni), .req_i(instr_req_o),
    .addr_i(instr_addr_o), .gnt_o(gnt), .rvalid_o(rvalid), .err_o(err), .data_o(data));
  function automatic logic [38:0] ecc(input logic [31:0] d);
    logic [38:0] c;
    begin
      c = 39'(d);
      c[32]=^(c&39'h002606BD25); c[33]=^(c&39'h00DEBA8050);
      c[34]=^(c&39'h00413D89AA); c[35]=^(c&39'h0031234ED1);
      c[36]=^(c&39'h00C2C1323B); c[37]=^(c&39'h002DCC624C);
      c[38]=^(c&39'h0098505586); ecc=c^39'h2A00000000;
    end
  endfunction
  logic [38:0] instr_ecc;
  assign instr_ecc = ecc(instr_rdata_i);
  always_comb if (rst_ni) begin
    assume(instr_gnt_i == gnt); assume(instr_rvalid_i == rvalid);
    if (instr_rvalid_i) begin assume(instr_rdata_i == data); assume(instr_err_i == err); end
    else assume(instr_err_i == 1'b0);
    assume(instr_rdata_intg_i == instr_ecc[38:32]);
  end
endmodule
bind ibex_top : ibex_top imem_if imem_if_inst(
  .clk_i(clk_i), .rst_ni(rst_ni), .instr_req_o(instr_req_o),
  .instr_gnt_i(instr_gnt_i), .instr_rvalid_i(instr_rvalid_i),
  .instr_addr_o(instr_addr_o), .instr_rdata_i(instr_rdata_i),
  .instr_err_i(instr_err_i), .instr_rdata_intg_i(instr_rdata_intg_i));
""", encoding="utf-8")


def _tcl_quote(value: str | Path) -> str:
    return "{" + str(value).replace("}", "\\}") + "}"


def emit_env_filelist(output: Path, fml_dir: Path, imem: Path) -> None:
    files = [fml_dir / "env/instr_vld.sv", imem,
             fml_dir / "env/top_asm.sv", fml_dir / "env/dmem.sv"]
    output.write_text("\n".join(str(path.resolve()) for path in files) + "\n",
                      encoding="utf-8")


def emit_tcl(*, output: Path, dut_f: Path, env_f: Path, assertion_fs: list[Path],
             fsdb: Path, sim_hier: str, work_dir: Path, timeout: int,
             seed: int, property_name: str | None, retry_index: int = 0) -> None:
    analyze = " \\\n  ".join([f"-f {_tcl_quote(dut_f)}", f"-f {_tcl_quote(env_f)}"] +
                         [f"-f {_tcl_quote(path)}" for path in assertion_fs])
    mode = "prove" if property_name else "discover"
    property_block = ""
    if property_name:
        if retry_index == 0:
            search = f"""prove -property $target_prop -asserts -force -engine_mode auto \\
  -per_property_time_limit {timeout}s -dump_trace -dump_trace_type fsdb \\
  -dump_trace_dir [file join $work_dir traces]"""
        else:
            search = f"""assert -set_store_trace unlimited $target_prop
hunt -clear
hunt -config -strategy bsdcov_retry_{retry_index} -mode state_swarm \\
  -target_type assert -max_jobs 1 -max_trace_length 300 -seed {seed + retry_index}
hunt -run -strategy bsdcov_retry_{retry_index} -property $target_prop \\
  -time_limit {timeout}s -force -dump_trace -dump_trace_type fsdb \\
  -dump_trace_dir [file join $work_dir traces]"""
        property_block = f"""
set target_prop {_tcl_quote(property_name)}
set init_state [file join $work_dir init_state.rst]
reset -clear
reset -fsdb {_tcl_quote(fsdb)} -hier_path {_tcl_quote(sim_hier)} -non_resettable_regs 0
get_reset_info -save_values $init_state -all -comments
reset -clear
reset -init_state $init_state
set_prove_dump_trace_type assert
{search}
set status [get_status $target_prop]
set fd [open [file join $work_dir status.txt] w]
puts $fd $status
close $fd
report -property $target_prop -results -detailed \\
  -file [file join $work_dir property_report.txt] -force
"""
    else:
        property_block = """
set fd [open [file join $work_dir properties.txt] w]
foreach p [lsort [get_property_list -include {type assert}]] {
  if {[string match "*AST_BSDCOV_*" $p] &&
      [string match "*u_ibex_core*" $p] &&
      ![string match "*u_shadow_core*" $p]} { puts $fd $p }
}
close $fd
"""
    output.write_text(f"""clear -all
set work_dir {_tcl_quote(work_dir)}
file mkdir $work_dir
file mkdir [file join $work_dir traces]
analyze -sv12 \\
  {analyze}
{ELABORATE}
clock clk_i
set_trace_show_reset false
{property_block}
exit
""", encoding="utf-8")


def run_jasper(jg: Path, tcl: Path, work_dir: Path, timeout: int) -> None:
    shutil.rmtree(work_dir / "jgproject", ignore_errors=True)
    run([str(jg), "-fpv", "-batch", "-tcl", str(tcl)], cwd=work_dir,
        log=work_dir / "jasper.log", timeout=timeout, check=True)


def discover_properties(*, jg: Path, dut_f: Path, env_f: Path,
                        assertion_fs: list[Path], fsdb: Path, sim_hier: str,
                        work_dir: Path, timeout: int, seed: int) -> list[str]:
    work_dir.mkdir(parents=True, exist_ok=True)
    tcl = work_dir / "discover.tcl"
    emit_tcl(output=tcl, dut_f=dut_f, env_f=env_f, assertion_fs=assertion_fs,
             fsdb=fsdb, sim_hier=sim_hier, work_dir=work_dir,
             timeout=timeout, seed=seed, property_name=None)
    run_jasper(jg, tcl, work_dir, timeout + 600)
    path = work_dir / "properties.txt"
    if not path.exists():
        raise RuntimeError("Jasper did not produce properties.txt")
    return [line.strip() for line in path.read_text(encoding="utf-8").splitlines()
            if line.strip()]


def prove_property(*, jg: Path, dut_f: Path, env_f: Path,
                   assertion_fs: list[Path], fsdb: Path, sim_hier: str,
                   work_dir: Path, timeout: int, seed: int,
                   property_name: str, retry_index: int = 0) -> dict[str, Any]:
    work_dir.mkdir(parents=True, exist_ok=True)
    tcl = work_dir / "prove.tcl"
    emit_tcl(output=tcl, dut_f=dut_f, env_f=env_f, assertion_fs=assertion_fs,
             fsdb=fsdb, sim_hier=sim_hier, work_dir=work_dir,
             timeout=timeout, seed=seed, property_name=property_name,
             retry_index=retry_index)
    run_jasper(jg, tcl, work_dir, timeout + 600)
    status_file = work_dir / "status.txt"
    status = status_file.read_text(encoding="utf-8").strip() if status_file.exists() else "error"
    traces = sorted((work_dir / "traces").glob("**/*.fsdb"),
                    key=lambda path: path.stat().st_mtime)
    return {"status": status, "cex_fsdb": str(traces[-1]) if traces else None}
