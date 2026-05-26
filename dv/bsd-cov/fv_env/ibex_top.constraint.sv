bind ibex_top
:
ibex_top
bsd_cov_ibex_top_input_assumptions
#(
    // -------------------------------------------------------------------------
    // ibex_top configuration parameters.
    // These names are resolved in the bound ibex_top parameter scope.
    // -------------------------------------------------------------------------
    .PMPEnable(PMPEnable),
    .PMPGranularity(PMPGranularity),
    .PMPNumRegions(PMPNumRegions),

    .MHPMCounterNum(MHPMCounterNum),
    .MHPMCounterWidth(MHPMCounterWidth),

    .RV32E(RV32E),
    .RV32M(RV32M),
    .RV32B(RV32B),
    .RegFile(RegFile),

    .BranchTargetALU(BranchTargetALU),
    .WritebackStage(WritebackStage),
    .BranchPredictor(BranchPredictor),

    .DbgTriggerEn(DbgTriggerEn),
    .DbgHwBreakNum(DbgHwBreakNum),

    .SecureIbex(SecureIbex),
    .ICache(ICache),
    .ICacheECC(ICacheECC),
    .ICacheScramble(ICacheScramble),
    .MemECC(MemECC),

    // -------------------------------------------------------------------------
    // BSD-Cov local formal parameters.
    // These are not ibex_top parameters.
    // -------------------------------------------------------------------------
    .IMEM_WORDS(64),
    .DMEM_WORDS(64),

    .INSTR_GNT_MAX_LATENCY(1),
    .INSTR_RVALID_MAX_LATENCY(3),
    .DATA_GNT_MAX_LATENCY(2),
    .DATA_RVALID_MAX_LATENCY(5),

    .ASSUME_NORMAL_ENVIRONMENT(1'b1),
    .ASSUME_BOOT_ADDR_ZERO(1'b1),
    .ASSUME_FETCH_ENABLE_ON(1'b1),
    .ASSUME_TEST_EN_ON(1'b1),

    .ASSUME_IMEM_ADDR_RANGE(1'b1),
    .ASSUME_IMEM_WORD_ALIGNED(1'b1),
    .ASSUME_LEGAL_INSTR_SUBSET(1'b1),

    .ASSUME_DMEM_ADDR_RANGE(1'b1),
    .ASSUME_DMEM_WORD_ALIGNED(1'b1),

    .ASSUME_SINGLE_OUTSTANDING_INSTR(1'b1),
    .ASSUME_SINGLE_OUTSTANDING_DATA(1'b1)
)
bsd_cov_ibex_top_input_assumptions_inst
(
    .clk_i(clk_i),
    .rst_ni(rst_ni),

    .test_en_i(test_en_i),
    .hart_id_i(hart_id_i),
    .boot_addr_i(boot_addr_i),
    .fetch_enable_i(fetch_enable_i),

    .irq_software_i(irq_software_i),
    .irq_timer_i(irq_timer_i),
    .irq_external_i(irq_external_i),
    .irq_fast_i(irq_fast_i),
    .irq_nm_i(irq_nm_i),

    .debug_req_i(debug_req_i),

    .instr_req_o(instr_req_o),
    .instr_gnt_i(instr_gnt_i),
    .instr_rvalid_i(instr_rvalid_i),
    .instr_addr_o(instr_addr_o),
    .instr_rdata_i(instr_rdata_i),
    .instr_err_i(instr_err_i),

    .data_req_o(data_req_o),
    .data_gnt_i(data_gnt_i),
    .data_rvalid_i(data_rvalid_i),
    .data_we_o(data_we_o),
    .data_be_o(data_be_o),
    .data_addr_o(data_addr_o),
    .data_wdata_o(data_wdata_o),
    .data_rdata_i(data_rdata_i),
    .data_err_i(data_err_i)
);


module bsd_cov_ibex_top_input_assumptions
#(
    // -------------------------------------------------------------------------
    // ibex_top configuration parameters.
    // Keep these compatible with ibex_top.
    // They are mostly recorded/passed through for consistency and future
    // config-aware assumptions.
    // -------------------------------------------------------------------------
    parameter bit PMPEnable = 1'b0,
    parameter int unsigned PMPGranularity = 0,
    parameter int unsigned PMPNumRegions = 4,

    parameter int unsigned MHPMCounterNum = 0,
    parameter int unsigned MHPMCounterWidth = 40,

    parameter bit RV32E = 1'b0,
    parameter ibex_pkg::rv32m_e RV32M = ibex_pkg::RV32MFast,
    parameter ibex_pkg::rv32b_e RV32B = ibex_pkg::RV32BNone,
    parameter ibex_pkg::regfile_e RegFile = ibex_pkg::RegFileFF,

    parameter bit BranchTargetALU = 1'b0,
    parameter bit WritebackStage = 1'b1,
    parameter bit BranchPredictor = 1'b0,

    parameter bit DbgTriggerEn = 1'b0,
    parameter int unsigned DbgHwBreakNum = 1,

    parameter bit SecureIbex = 1'b0,
    parameter bit ICache = 1'b0,
    parameter bit ICacheECC = 1'b0,
    parameter bit ICacheScramble = 1'b0,
    parameter bit MemECC = 1'b0,

    // -------------------------------------------------------------------------
    // BSD-Cov local formal parameters.
    // -------------------------------------------------------------------------
    parameter int unsigned IMEM_WORDS = 64,
    parameter int unsigned DMEM_WORDS = 64,

    parameter int unsigned INSTR_GNT_MAX_LATENCY = 1,
    parameter int unsigned INSTR_RVALID_MAX_LATENCY = 3,
    parameter int unsigned DATA_GNT_MAX_LATENCY = 2,
    parameter int unsigned DATA_RVALID_MAX_LATENCY = 5,

    parameter bit ASSUME_NORMAL_ENVIRONMENT = 1'b1,
    parameter bit ASSUME_BOOT_ADDR_ZERO = 1'b1,
    parameter bit ASSUME_FETCH_ENABLE_ON = 1'b1,
    parameter bit ASSUME_TEST_EN_ON = 1'b1,

    parameter bit ASSUME_IMEM_ADDR_RANGE = 1'b1,
    parameter bit ASSUME_IMEM_WORD_ALIGNED = 1'b1,
    parameter bit ASSUME_LEGAL_INSTR_SUBSET = 1'b1,

    parameter bit ASSUME_DMEM_ADDR_RANGE = 1'b1,
    parameter bit ASSUME_DMEM_WORD_ALIGNED = 1'b1,

    parameter bit ASSUME_SINGLE_OUTSTANDING_INSTR = 1'b1,
    parameter bit ASSUME_SINGLE_OUTSTANDING_DATA = 1'b1
)
(
    input  logic clk_i,
    input  logic rst_ni,

    input  logic test_en_i,
    input  logic [31:0] hart_id_i,
    input  logic [31:0] boot_addr_i,
    input  ibex_pkg::mubi4_t fetch_enable_i,

    input  logic irq_software_i,
    input  logic irq_timer_i,
    input  logic irq_external_i,
    input  logic [14:0] irq_fast_i,
    input  logic irq_nm_i,

    input  logic debug_req_i,

    input  logic instr_req_o,
    input  logic instr_gnt_i,
    input  logic instr_rvalid_i,
    input  logic [31:0] instr_addr_o,
    input  logic [31:0] instr_rdata_i,
    input  logic instr_err_i,

    input  logic data_req_o,
    input  logic data_gnt_i,
    input  logic data_rvalid_i,
    input  logic data_we_o,
    input  logic [3:0] data_be_o,
    input  logic [31:0] data_addr_o,
    input  logic [31:0] data_wdata_o,
    input  logic [31:0] data_rdata_i,
    input  logic data_err_i
);

    localparam int unsigned IMEM_AW = (IMEM_WORDS <= 1) ? 1 : $clog2(IMEM_WORDS);
    localparam int unsigned DMEM_AW = (DMEM_WORDS <= 1) ? 1 : $clog2(DMEM_WORDS);

    // -------------------------------------------------------------------------
    // Symbolic replayable instruction memory.
    //
    // Initial values are formal-symbolic. The self-hold makes the instruction
    // memory stable after initialization:
    //
    //   same PC -> same instruction
    // -------------------------------------------------------------------------

    logic [31:0] imem [0:IMEM_WORDS-1];

    genvar gi;
    generate
        for (gi = 0; gi < IMEM_WORDS; gi = gi + 1) begin : g_imem_hold
            always_ff @(posedge clk_i) begin
                imem[gi] <= imem[gi];
            end
        end
    endgenerate

    // -------------------------------------------------------------------------
    // Symbolic deterministic data memory.
    //
    // Initial values are formal-symbolic. Stores update memory. Loads read
    // memory. This makes data-dependent witnesses replayable if the dmem image
    // is also extracted.
    // -------------------------------------------------------------------------

    logic [31:0] dmem [0:DMEM_WORDS-1];

    // -------------------------------------------------------------------------
    // Address helper functions.
    // -------------------------------------------------------------------------

    function automatic logic imem_addr_in_range(input logic [31:0] addr);
        imem_addr_in_range = (addr[31:IMEM_AW+2] == '0);
    endfunction

    function automatic logic dmem_addr_in_range(input logic [31:0] addr);
        dmem_addr_in_range = (addr[31:DMEM_AW+2] == '0);
    endfunction

    function automatic logic [IMEM_AW-1:0] imem_index(input logic [31:0] addr);
        imem_index = addr[IMEM_AW+1:2];
    endfunction

    function automatic logic [DMEM_AW-1:0] dmem_index(input logic [31:0] addr);
        dmem_index = addr[DMEM_AW+1:2];
    endfunction

    function automatic logic [31:0] apply_store_mask(
        input logic [31:0] old_word,
        input logic [31:0] new_word,
        input logic [3:0]  be
    );
        logic [31:0] result;
        begin
            result = old_word;

            if (be[0]) result[7:0]   = new_word[7:0];
            if (be[1]) result[15:8]  = new_word[15:8];
            if (be[2]) result[23:16] = new_word[23:16];
            if (be[3]) result[31:24] = new_word[31:24];

            apply_store_mask = result;
        end
    endfunction

    // -------------------------------------------------------------------------
    // Legal RV32I/M instruction subset.
    //
    // Allowed:
    //   LUI, AUIPC,
    //   JAL, JALR,
    //   BEQ/BNE/BLT/BGE/BLTU/BGEU,
    //   LW, SW,
    //   ADDI/XORI/ORI/ANDI,
    //   ADD/SUB/XOR/OR/AND,
    //   MUL/MULH/MULHSU/MULHU/DIV/DIVU/REM/REMU.
    // -------------------------------------------------------------------------

    function automatic logic legal_rv32im_subset(input logic [31:0] insn);
        logic [6:0] opcode;
        logic [2:0] funct3;
        logic [6:0] funct7;
        begin
            opcode = insn[6:0];
            funct3 = insn[14:12];
            funct7 = insn[31:25];

            legal_rv32im_subset = 1'b0;

            unique case (opcode)
                7'b0110111: begin
                    legal_rv32im_subset = 1'b1; // LUI
                end

                7'b0010111: begin
                    legal_rv32im_subset = 1'b1; // AUIPC
                end

                7'b1101111: begin
                    legal_rv32im_subset = 1'b1; // JAL
                end

                7'b1100111: begin
                    legal_rv32im_subset = (funct3 == 3'b000); // JALR
                end

                7'b1100011: begin
                    unique case (funct3)
                        3'b000,
                        3'b001,
                        3'b100,
                        3'b101,
                        3'b110,
                        3'b111: legal_rv32im_subset = 1'b1;
                        default: legal_rv32im_subset = 1'b0;
                    endcase
                end

                7'b0000011: begin
                    legal_rv32im_subset = (funct3 == 3'b010); // LW only
                end

                7'b0100011: begin
                    legal_rv32im_subset = (funct3 == 3'b010); // SW only
                end

                7'b0010011: begin
                    unique case (funct3)
                        3'b000,
                        3'b100,
                        3'b110,
                        3'b111: legal_rv32im_subset = 1'b1;
                        default: legal_rv32im_subset = 1'b0;
                    endcase
                end

                7'b0110011: begin
                    unique case (funct7)
                        7'b0000000: begin
                            unique case (funct3)
                                3'b000,
                                3'b100,
                                3'b110,
                                3'b111: legal_rv32im_subset = 1'b1;
                                default: legal_rv32im_subset = 1'b0;
                            endcase
                        end

                        7'b0100000: begin
                            legal_rv32im_subset = (funct3 == 3'b000); // SUB
                        end

                        7'b0000001: begin
                            legal_rv32im_subset = 1'b1; // RV32M
                        end

                        default: begin
                            legal_rv32im_subset = 1'b0;
                        end
                    endcase
                end

                default: begin
                    legal_rv32im_subset = 1'b0;
                end
            endcase

            legal_rv32im_subset = legal_rv32im_subset && (insn[1:0] == 2'b11);
        end
    endfunction

    // -------------------------------------------------------------------------
    // Instruction bus reference state.
    // -------------------------------------------------------------------------

    logic instr_outstanding_q;
    logic [31:0] instr_pending_addr_q;

    wire instr_accept = instr_req_o && instr_gnt_i;
    wire instr_done   = instr_rvalid_i;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            instr_outstanding_q  <= 1'b0;
            instr_pending_addr_q <= '0;
        end else begin
            if (instr_accept) begin
                instr_outstanding_q  <= 1'b1;
                instr_pending_addr_q <= instr_addr_o;
            end

            if (instr_done) begin
                instr_outstanding_q <= 1'b0;
            end
        end
    end

    // -------------------------------------------------------------------------
    // Data bus reference state.
    // -------------------------------------------------------------------------

    logic data_outstanding_q;
    logic [31:0] data_pending_addr_q;
    logic        data_pending_we_q;
    logic [3:0]  data_pending_be_q;
    logic [31:0] data_pending_wdata_q;

    wire data_accept = data_req_o && data_gnt_i;
    wire data_done   = data_rvalid_i;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            data_outstanding_q   <= 1'b0;
            data_pending_addr_q  <= '0;
            data_pending_we_q    <= 1'b0;
            data_pending_be_q    <= '0;
            data_pending_wdata_q <= '0;
        end else begin
            if (data_accept) begin
                data_outstanding_q   <= 1'b1;
                data_pending_addr_q  <= data_addr_o;
                data_pending_we_q    <= data_we_o;
                data_pending_be_q    <= data_be_o;
                data_pending_wdata_q <= data_wdata_o;
            end

            if (data_done) begin
                data_outstanding_q <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (data_accept && data_we_o) begin
            dmem[dmem_index(data_addr_o)] <= apply_store_mask(
                dmem[dmem_index(data_addr_o)],
                data_wdata_o,
                data_be_o
            );
        end
    end

    // -------------------------------------------------------------------------
    // Normal execution assumptions.
    // -------------------------------------------------------------------------

    generate
        if (ASSUME_NORMAL_ENVIRONMENT) begin : g_normal_environment_assumptions

            property p_no_debug_req;
                @(posedge clk_i) disable iff (!rst_ni)
                    debug_req_i == 1'b0;
            endproperty
            asm_no_debug_req: assume property (p_no_debug_req);

            property p_no_irq_software;
                @(posedge clk_i) disable iff (!rst_ni)
                    irq_software_i == 1'b0;
            endproperty
            asm_no_irq_software: assume property (p_no_irq_software);

            property p_no_irq_timer;
                @(posedge clk_i) disable iff (!rst_ni)
                    irq_timer_i == 1'b0;
            endproperty
            asm_no_irq_timer: assume property (p_no_irq_timer);

            property p_no_irq_external;
                @(posedge clk_i) disable iff (!rst_ni)
                    irq_external_i == 1'b0;
            endproperty
            asm_no_irq_external: assume property (p_no_irq_external);

            property p_no_irq_fast;
                @(posedge clk_i) disable iff (!rst_ni)
                    irq_fast_i == '0;
            endproperty
            asm_no_irq_fast: assume property (p_no_irq_fast);

            property p_no_irq_nm;
                @(posedge clk_i) disable iff (!rst_ni)
                    irq_nm_i == 1'b0;
            endproperty
            asm_no_irq_nm: assume property (p_no_irq_nm);

            property p_no_instr_err;
                @(posedge clk_i) disable iff (!rst_ni)
                    instr_err_i == 1'b0;
            endproperty
            asm_no_instr_err: assume property (p_no_instr_err);

            property p_no_data_err;
                @(posedge clk_i) disable iff (!rst_ni)
                    data_err_i == 1'b0;
            endproperty
            asm_no_data_err: assume property (p_no_data_err);

        end
    endgenerate

    generate
        if (ASSUME_BOOT_ADDR_ZERO) begin : g_boot_addr_zero_assumption
            property p_boot_addr_zero;
                @(posedge clk_i) disable iff (!rst_ni)
                    boot_addr_i == 32'h0000_0000;
            endproperty
            asm_boot_addr_zero: assume property (p_boot_addr_zero);
        end
    endgenerate

    generate
        if (ASSUME_FETCH_ENABLE_ON) begin : g_fetch_enable_on_assumption
            property p_fetch_enable_on;
                @(posedge clk_i) disable iff (!rst_ni)
                    fetch_enable_i == ibex_pkg::IbexMuBiOn;
            endproperty
            asm_fetch_enable_on: assume property (p_fetch_enable_on);
        end
    endgenerate

    generate
        if (ASSUME_TEST_EN_ON) begin : g_test_en_on_assumption
            property p_test_en_on;
                @(posedge clk_i) disable iff (!rst_ni)
                    test_en_i == 1'b1;
            endproperty
            asm_test_en_on: assume property (p_test_en_on);
        end
    endgenerate

    property p_hart_id_stable;
        @(posedge clk_i) disable iff (!rst_ni)
            $stable(hart_id_i);
    endproperty
    asm_hart_id_stable: assume property (p_hart_id_stable);

    // -------------------------------------------------------------------------
    // Legal program assumptions.
    // -------------------------------------------------------------------------

    generate
        if (ASSUME_LEGAL_INSTR_SUBSET) begin : g_legal_instr_subset_assumptions
            for (gi = 0; gi < IMEM_WORDS; gi = gi + 1) begin : g_legal_imem_word
                property p_legal_imem_word;
                    @(posedge clk_i) disable iff (!rst_ni)
                        legal_rv32im_subset(imem[gi]);
                endproperty
                asm_legal_imem_word: assume property (p_legal_imem_word);
            end
        end
    endgenerate

    // -------------------------------------------------------------------------
    // Instruction protocol assumptions.
    // -------------------------------------------------------------------------

    property p_instr_gnt_only_on_req;
        @(posedge clk_i) disable iff (!rst_ni)
            instr_gnt_i |-> instr_req_o;
    endproperty
    asm_instr_gnt_only_on_req: assume property (p_instr_gnt_only_on_req);

    property p_instr_rvalid_only_when_outstanding;
        @(posedge clk_i) disable iff (!rst_ni)
            instr_rvalid_i |-> instr_outstanding_q;
    endproperty
    asm_instr_rvalid_only_when_outstanding: assume property (p_instr_rvalid_only_when_outstanding);

    generate
        if (ASSUME_SINGLE_OUTSTANDING_INSTR) begin : g_single_outstanding_instr_assumption
            property p_no_new_instr_accept_while_outstanding;
                @(posedge clk_i) disable iff (!rst_ni)
                    instr_outstanding_q |-> !instr_accept;
            endproperty
            asm_no_new_instr_accept_while_outstanding: assume property (p_no_new_instr_accept_while_outstanding);
        end
    endgenerate

    property p_instr_req_gets_gnt;
        @(posedge clk_i) disable iff (!rst_ni)
            instr_req_o |-> ##[0:INSTR_GNT_MAX_LATENCY] instr_gnt_i;
    endproperty
    asm_instr_req_gets_gnt: assume property (p_instr_req_gets_gnt);

    property p_instr_accept_gets_rvalid;
        @(posedge clk_i) disable iff (!rst_ni)
            instr_accept |-> ##[1:INSTR_RVALID_MAX_LATENCY] instr_rvalid_i;
    endproperty
    asm_instr_accept_gets_rvalid: assume property (p_instr_accept_gets_rvalid);

    generate
        if (ASSUME_IMEM_ADDR_RANGE) begin : g_imem_addr_range_assumption
            property p_instr_addr_in_range;
                @(posedge clk_i) disable iff (!rst_ni)
                    instr_req_o |-> imem_addr_in_range(instr_addr_o);
            endproperty
            asm_instr_addr_in_range: assume property (p_instr_addr_in_range);
        end
    endgenerate

    generate
        if (ASSUME_IMEM_WORD_ALIGNED) begin : g_imem_word_aligned_assumption
            property p_instr_addr_word_aligned;
                @(posedge clk_i) disable iff (!rst_ni)
                    instr_req_o |-> (instr_addr_o[1:0] == 2'b00);
            endproperty
            asm_instr_addr_word_aligned: assume property (p_instr_addr_word_aligned);
        end
    endgenerate

    property p_instr_rdata_matches_imem;
        @(posedge clk_i) disable iff (!rst_ni)
            instr_rvalid_i |-> (instr_rdata_i == imem[imem_index(instr_pending_addr_q)]);
    endproperty
    asm_instr_rdata_matches_imem: assume property (p_instr_rdata_matches_imem);

    // -------------------------------------------------------------------------
    // Data protocol assumptions.
    // -------------------------------------------------------------------------

    property p_data_gnt_only_on_req;
        @(posedge clk_i) disable iff (!rst_ni)
            data_gnt_i |-> data_req_o;
    endproperty
    asm_data_gnt_only_on_req: assume property (p_data_gnt_only_on_req);

    property p_data_rvalid_only_when_outstanding;
        @(posedge clk_i) disable iff (!rst_ni)
            data_rvalid_i |-> data_outstanding_q;
    endproperty
    asm_data_rvalid_only_when_outstanding: assume property (p_data_rvalid_only_when_outstanding);

    generate
        if (ASSUME_SINGLE_OUTSTANDING_DATA) begin : g_single_outstanding_data_assumption
            property p_no_new_data_accept_while_outstanding;
                @(posedge clk_i) disable iff (!rst_ni)
                    data_outstanding_q |-> !data_accept;
            endproperty
            asm_no_new_data_accept_while_outstanding: assume property (p_no_new_data_accept_while_outstanding);
        end
    endgenerate

    property p_data_req_gets_gnt;
        @(posedge clk_i) disable iff (!rst_ni)
            data_req_o |-> ##[0:DATA_GNT_MAX_LATENCY] data_gnt_i;
    endproperty
    asm_data_req_gets_gnt: assume property (p_data_req_gets_gnt);

    property p_data_accept_gets_rvalid;
        @(posedge clk_i) disable iff (!rst_ni)
            data_accept |-> ##[1:DATA_RVALID_MAX_LATENCY] data_rvalid_i;
    endproperty
    asm_data_accept_gets_rvalid: assume property (p_data_accept_gets_rvalid);

    generate
        if (ASSUME_DMEM_ADDR_RANGE) begin : g_dmem_addr_range_assumption
            property p_data_addr_in_range;
                @(posedge clk_i) disable iff (!rst_ni)
                    data_req_o |-> dmem_addr_in_range(data_addr_o);
            endproperty
            asm_data_addr_in_range: assume property (p_data_addr_in_range);
        end
    endgenerate

    generate
        if (ASSUME_DMEM_WORD_ALIGNED) begin : g_dmem_word_aligned_assumption
            property p_data_addr_word_aligned;
                @(posedge clk_i) disable iff (!rst_ni)
                    data_req_o |-> (data_addr_o[1:0] == 2'b00);
            endproperty
            asm_data_addr_word_aligned: assume property (p_data_addr_word_aligned);
        end
    endgenerate

    property p_data_rdata_matches_dmem_on_load;
        @(posedge clk_i) disable iff (!rst_ni)
            (data_rvalid_i && !data_pending_we_q)
            |->
            (data_rdata_i == dmem[dmem_index(data_pending_addr_q)]);
    endproperty
    asm_data_rdata_matches_dmem_on_load: assume property (p_data_rdata_matches_dmem_on_load);

endmodule
