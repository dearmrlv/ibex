module instr_mem
#(
    parameter int unsigned NUM_TRACK = 32,

    parameter bit RV32E               = 0,
    parameter ibex_pkg::rv32m_e RV32M = ibex_pkg::RV32MFast,
    parameter ibex_pkg::rv32b_e RV32B = ibex_pkg::RV32BNone,
    parameter bit BranchTargetALU     = 0
)
(
    input  logic        clk_i,
    input  logic        rst_ni,

    input  logic        req_i,
    input  logic [31:0] addr_i,
    output logic        gnt_o,
    output logic        rvalid_o,
    output logic [31:0] rdata_o,
    output logic        err_o
);

    /////////////// Memory cannot grant without a request.
    property p_gnt_only_on_req;
        @(posedge clk_i) disable iff (!rst_ni)
            gnt_o |-> req_i;
    endproperty
    ASM_gnt_only_on_req: assume property (p_gnt_only_on_req);

    /////////////// while req is not granted, keep stable
    property p_req_addr_stable_until_gnt;
        @(posedge clk_i) disable iff (!rst_ni)
            (req_i && !gnt_o)
            |=>
            (req_i && $stable(addr_i));
    endproperty
    ASM_req_addr_stable_until_gnt:
        assume property (p_req_addr_stable_until_gnt);

    /////////////// No Instruction Error
    property p_no_instruction_error;
        @(posedge clk_i) disable iff (!rst_ni)
            err_o == 1'b0;
    endproperty
    ASM_no_instruction_error: assume property (p_no_instruction_error);

    /////////////// Word Aligned
    property p_addr_word_aligned;
        @(posedge clk_i) disable iff (!rst_ni)
            req_i |-> (addr_i[1:0] == 2'b00);
    endproperty
    ASM_addr_word_aligned: assume property (p_addr_word_aligned);

    /////////////// make gnt a pulse
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            gnt_o <= '0;
        end
        else begin
            if (gnt_o) begin
                gnt_o <= '0;
            end
            else begin
                if (req_i & ~gnt_o) begin
                    gnt_o <= '1;
                end
            end
        end
    end

    // after gnt, next cycle launch rvalid
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            rvalid_o <= '0;
        end
        else begin
            if (rvalid_o) begin
                rvalid_o <= '0;
            end
            else if (gnt_o) begin
                rvalid_o <= '1;
            end
        end
    end
    
    logic [31:0] addr_in_process;
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            addr_in_process <= '0;
        end
        else if (req_i) begin
            addr_in_process <= addr_i;
        end
    end

    // logic dec_illegal_insn;
    // ibex_decoder #(
    //     .RV32E          (RV32E),
    //     .RV32M          (RV32M),
    //     .RV32B          (RV32B),
    //     .BranchTargetALU(BranchTargetALU)
    // ) u_ibex_legal_instr_decoder (
    //     .clk_i              (clk_i),
    //     .rst_ni             (rst_ni),

    //     // Decoder status outputs
    //     .illegal_insn_o     (dec_illegal_insn),
    //     .ebrk_insn_o        (),
    //     .mret_insn_o        (),
    //     .dret_insn_o        (),
    //     .ecall_insn_o       (),
    //     .wfi_insn_o         (),
    //     .jump_set_o         (),

    //     // Inputs needed by decoder
    //     .branch_taken_i     (1'b0),
    //     .icache_inval_o     (),
    //     .instr_first_cycle_i(1'b1),
    //     .instr_rdata_i      (rdata_o),
    //     .instr_rdata_alu_i  (rdata_o),
    //     .illegal_c_insn_i   (1'b0),

    //     // Immediate outputs
    //     .imm_a_mux_sel_o    (),
    //     .imm_b_mux_sel_o    (),
    //     .bt_a_mux_sel_o     (),
    //     .bt_b_mux_sel_o     (),
    //     .imm_i_type_o       (),
    //     .imm_s_type_o       (),
    //     .imm_b_type_o       (),
    //     .imm_u_type_o       (),
    //     .imm_j_type_o       (),
    //     .zimm_rs1_type_o    (),

    //     // Register file outputs
    //     .rf_wdata_sel_o     (),
    //     .rf_we_o            (),
    //     .rf_raddr_a_o       (),
    //     .rf_raddr_b_o       (),
    //     .rf_waddr_o         (),
    //     .rf_ren_a_o         (),
    //     .rf_ren_b_o         (),

    //     // ALU outputs
    //     .alu_operator_o     (),
    //     .alu_op_a_mux_sel_o (),
    //     .alu_op_b_mux_sel_o (),
    //     .alu_multicycle_o   (),

    //     // Mult/div outputs
    //     .mult_en_o          (),
    //     .div_en_o           (),
    //     .mult_sel_o         (),
    //     .div_sel_o          (),
    //     .multdiv_operator_o (),
    //     .multdiv_signed_mode_o(),

    //     // CSR outputs
    //     .csr_access_o       (),
    //     .csr_op_o           (),
    //     .csr_addr_o         (),

    //     // LSU outputs
    //     .data_req_o         (),
    //     .data_we_o          (),
    //     .data_type_o        (),
    //     .data_sign_extension_o(),

    //     // Control-flow outputs
    //     .jump_in_dec_o      (),
    //     .branch_in_dec_o    ()
    // );

    // // Whenever instruction memory returns data, the returned instruction must be:
    // //   1. uncompressed 32-bit instruction, rdata_o[1:0] == 2'b11
    // //   2. legal according to Ibex's own decoder
    // property p_rdata_is_legal_ibex_instr;
    //     @(posedge clk_i) disable iff (!rst_ni)
    //         rvalid_o |-> (
    //             (rdata_o[1:0] == 2'b11) &&
    //             !dec_illegal_insn
    //         );
    // endproperty
    // ASM_rdata_is_legal_ibex_instr:
    //     assume property (p_rdata_is_legal_ibex_instr);

endmodule
