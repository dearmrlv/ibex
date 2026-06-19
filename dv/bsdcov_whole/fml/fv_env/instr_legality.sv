// -----------------------------------------------------------------------------
// BSD-Cov Ibex Instruction Validity Assumptions
//
// This module is intentionally separated from the instruction memory model.
//
// It constrains only the decoded instruction entering ID stage:
//   - if an instruction is valid in ID,
//   - then it must not be illegal according to Ibex decoder.
//
// This should NOT be placed on instr_rdata_i directly, because instr_rdata_i is
// a 32-bit fetch word and may contain two compressed 16-bit instructions.
// -----------------------------------------------------------------------------

bind ibex_top : ibex_top
bsd_cov_ibex_top_instr_valid_assumptions
bsd_cov_ibex_top_instr_valid_assumptions_inst
(
    .clk_i                (clk_i),
    .rst_ni               (rst_ni),

    .instr_valid_id_i     (u_ibex_core.instr_valid_id),
    .instr_fetch_err_id_i (u_ibex_core.instr_fetch_err),
    .illegal_c_insn_id_i  (u_ibex_core.illegal_c_insn_id),
    .illegal_insn_id_i    (u_ibex_core.illegal_insn_id)
);


module bsd_cov_ibex_top_instr_valid_assumptions
(
    input logic clk_i,
    input logic rst_ni,

    input logic instr_valid_id_i,
    input logic instr_fetch_err_id_i,
    input logic illegal_c_insn_id_i,
    input logic illegal_insn_id_i
);

    // -------------------------------------------------------------------------
    // Legal instruction assumptions.
    // -------------------------------------------------------------------------

    // Any instruction that reaches ID stage must be a valid, legal instruction.
    property p_id_instr_valid_and_legal;
        @(posedge clk_i) disable iff (!rst_ni)
            instr_valid_id_i |->
                (!instr_fetch_err_id_i && !illegal_c_insn_id_i  && !illegal_insn_id_i);
    endproperty
    ASM_id_instr_valid_and_legal:
        assume property (p_id_instr_valid_and_legal);

endmodule