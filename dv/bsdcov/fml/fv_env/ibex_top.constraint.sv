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
    .RV32ZC(RV32ZC),
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
    .ASSUME_RESET_BOOT(1'b1),
    .RESET_BOOT_CYCLES(2),

    .ASSUME_BOOT_ADDR_ZERO(1'b1),
    .ASSUME_FETCH_ENABLE_ON(1'b1),
    .ASSUME_TEST_EN_ON(1'b1),

    .ASSUME_IMEM_ADDR_RANGE(1'b1),
    .ASSUME_IMEM_WORD_ALIGNED(1'b1),
    .ASSUME_LEGAL_ID_STAGE_INSTR(1'b1),

    .ASSUME_DMEM_ADDR_RANGE(1'b1),
    .ASSUME_DMEM_WORD_ALIGNED(1'b1),

    .ASSUME_SINGLE_OUTSTANDING_INSTR(1'b0),
    .ASSUME_SINGLE_OUTSTANDING_DATA(1'b0)
)
bsd_cov_ibex_top_input_assumptions_inst
(
    .clk_i(clk_i),
    .rst_ni(rst_ni),

    .test_en_i(test_en_i),
    .scan_rst_ni(scan_rst_ni),
    .ram_cfg_icache_tag_i(ram_cfg_icache_tag_i),
    .ram_cfg_icache_data_i(ram_cfg_icache_data_i),
    .hart_id_i(hart_id_i),
    .boot_addr_i(boot_addr_i),
    .fetch_enable_i(fetch_enable_i),

    .irq_software_i(irq_software_i),
    .irq_timer_i(irq_timer_i),
    .irq_external_i(irq_external_i),
    .irq_fast_i(irq_fast_i),
    .irq_nm_i(irq_nm_i),

    .debug_req_i(debug_req_i),
    .scramble_key_valid_i(scramble_key_valid_i),
    .scramble_key_i(scramble_key_i),
    .scramble_nonce_i(scramble_nonce_i),

    .instr_req_o(instr_req_o),
    .instr_gnt_i(instr_gnt_i),
    .instr_rvalid_i(instr_rvalid_i),
    .instr_addr_o(instr_addr_o),
    .instr_rdata_i(instr_rdata_i),
    .instr_rdata_intg_i(instr_rdata_intg_i),
    .instr_err_i(instr_err_i),

    .data_req_o(data_req_o),
    .data_gnt_i(data_gnt_i),
    .data_rvalid_i(data_rvalid_i),
    .data_we_o(data_we_o),
    .data_be_o(data_be_o),
    .data_addr_o(data_addr_o),
    .data_wdata_o(data_wdata_o),
    .data_rdata_i(data_rdata_i),
    .data_rdata_intg_i(data_rdata_intg_i),
    .data_err_i(data_err_i),

    .instr_valid_id_i(u_ibex_core.instr_valid_id),
    .instr_fetch_err_id_i(u_ibex_core.instr_fetch_err),
    .illegal_c_insn_id_i(u_ibex_core.illegal_c_insn_id),
    .illegal_insn_id_i(u_ibex_core.illegal_insn_id),
    .instr_is_compressed_id_i(u_ibex_core.instr_is_compressed_id),
    .pc_id_i(u_ibex_core.pc_id)
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
    parameter ibex_pkg::rv32zc_e RV32ZC = ibex_pkg::RV32ZcaZcbZcmp,
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
    parameter bit ASSUME_RESET_BOOT = 1'b1,
    parameter int unsigned RESET_BOOT_CYCLES = 2,

    parameter bit ASSUME_BOOT_ADDR_ZERO = 1'b1,
    parameter bit ASSUME_FETCH_ENABLE_ON = 1'b1,
    parameter bit ASSUME_TEST_EN_ON = 1'b1,

    parameter bit ASSUME_IMEM_ADDR_RANGE = 1'b1,
    parameter bit ASSUME_IMEM_WORD_ALIGNED = 1'b1,
    parameter bit ASSUME_LEGAL_ID_STAGE_INSTR = 1'b1,

    parameter bit ASSUME_DMEM_ADDR_RANGE = 1'b1,
    parameter bit ASSUME_DMEM_WORD_ALIGNED = 1'b1,

    parameter bit ASSUME_SINGLE_OUTSTANDING_INSTR = 1'b1,
    parameter bit ASSUME_SINGLE_OUTSTANDING_DATA = 1'b1
)
(
    input  logic clk_i,
    input  logic rst_ni,

    input  logic test_en_i,
    input  logic scan_rst_ni,
    input  prim_ram_1p_pkg::ram_1p_cfg_t ram_cfg_icache_tag_i,
    input  prim_ram_1p_pkg::ram_1p_cfg_t ram_cfg_icache_data_i,
    input  logic [31:0] hart_id_i,
    input  logic [31:0] boot_addr_i,
    input  ibex_pkg::ibex_mubi_t fetch_enable_i,

    input  logic irq_software_i,
    input  logic irq_timer_i,
    input  logic irq_external_i,
    input  logic [14:0] irq_fast_i,
    input  logic irq_nm_i,

    input  logic debug_req_i,
    input  logic scramble_key_valid_i,
    input  logic [ibex_pkg::SCRAMBLE_KEY_W-1:0] scramble_key_i,
    input  logic [ibex_pkg::SCRAMBLE_NONCE_W-1:0] scramble_nonce_i,

    input  logic instr_req_o,
    input  logic instr_gnt_i,
    input  logic instr_rvalid_i,
    input  logic [31:0] instr_addr_o,
    input  logic [31:0] instr_rdata_i,
    input  logic [6:0] instr_rdata_intg_i,
    input  logic instr_err_i,

    input  logic data_req_o,
    input  logic data_gnt_i,
    input  logic data_rvalid_i,
    input  logic data_we_o,
    input  logic [3:0] data_be_o,
    input  logic [31:0] data_addr_o,
    input  logic [31:0] data_wdata_o,
    input  logic [31:0] data_rdata_i,
    input  logic [6:0] data_rdata_intg_i,
    input  logic data_err_i,

    input  logic instr_valid_id_i,
    input  logic instr_fetch_err_id_i,
    input  logic illegal_c_insn_id_i,
    input  logic illegal_insn_id_i,
    input  logic instr_is_compressed_id_i,
    input  logic [31:0] pc_id_i
);

    localparam int unsigned IMEM_AW = (IMEM_WORDS <= 1) ? 1 : $clog2(IMEM_WORDS);
    localparam int unsigned DMEM_AW = (DMEM_WORDS <= 1) ? 1 : $clog2(DMEM_WORDS);
    localparam int unsigned IMEM_HALFWORDS = IMEM_WORDS * 2;
    localparam int unsigned IMEM_HAW = (IMEM_HALFWORDS <= 1) ? 1 : $clog2(IMEM_HALFWORDS);
    localparam int unsigned RESET_BOOT_CW = (RESET_BOOT_CYCLES <= 1) ? 1 :
                                            $clog2(RESET_BOOT_CYCLES + 1);
    localparam logic [RESET_BOOT_CW-1:0] RESET_BOOT_DONE_COUNT = RESET_BOOT_CYCLES;

    // -------------------------------------------------------------------------
    // Symbolic replayable instruction memory, stored as halfwords so the
    // generated witness can contain compressed instructions and 32-bit
    // instructions starting at halfword PCs.
    // -------------------------------------------------------------------------

    logic [15:0] imem_hword [0:IMEM_HALFWORDS-1];

    genvar gi;
    generate
        for (gi = 0; gi < IMEM_HALFWORDS; gi = gi + 1) begin : g_imem_hold
            always_ff @(posedge clk_i) begin
                imem_hword[gi] <= imem_hword[gi];
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

    function automatic logic imem_pc_in_range(
        input logic [31:0] addr,
        input logic        is_compressed
    );
        imem_pc_in_range = (addr[0] == 1'b0) &&
                           imem_addr_in_range(addr) &&
                           (is_compressed || imem_addr_in_range(addr + 32'd2));
    endfunction

    function automatic logic dmem_addr_in_range(input logic [31:0] addr);
        dmem_addr_in_range = (addr[31:DMEM_AW+2] == '0);
    endfunction

    function automatic logic [IMEM_HAW-1:0] imem_hword_index(input logic [31:0] addr);
        imem_hword_index = addr[IMEM_HAW:1];
    endfunction

    function automatic logic [DMEM_AW-1:0] dmem_index(input logic [31:0] addr);
        dmem_index = addr[DMEM_AW+1:2];
    endfunction

    function automatic logic [31:0] imem_word_at_addr(input logic [31:0] addr);
        logic [IMEM_HAW-1:0] idx;
        logic [IMEM_HAW-1:0] idx_plus_one;
        begin
            idx = imem_hword_index(addr);
            idx_plus_one = idx + 1'b1;
            imem_word_at_addr = {imem_hword[idx_plus_one], imem_hword[idx]};
        end
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
    // Reset-start model.
    //
    // This prevents Jasper from seeding arbitrary post-reset pipeline state in
    // cycle 0. The core and the local reference monitors must first observe a
    // real reset, then any WB/outstanding/load-store state is produced only by
    // subsequent instruction and data bus activity.
    // -------------------------------------------------------------------------

    logic [RESET_BOOT_CW-1:0] reset_boot_count_q = '0;

    always_ff @(posedge clk_i) begin
        if (reset_boot_count_q < RESET_BOOT_DONE_COUNT) begin
            reset_boot_count_q <= reset_boot_count_q + {{(RESET_BOOT_CW-1){1'b0}}, 1'b1};
        end
    end

    generate
        if (ASSUME_RESET_BOOT) begin : g_reset_boot_assumption
            property p_reset_boot_asserted;
                @(posedge clk_i)
                    (reset_boot_count_q < RESET_BOOT_DONE_COUNT) |-> !rst_ni;
            endproperty
            asm_reset_boot_asserted: assume property (p_reset_boot_asserted);

            property p_reset_boot_released;
                @(posedge clk_i)
                    (reset_boot_count_q >= RESET_BOOT_DONE_COUNT) |-> rst_ni;
            endproperty
            asm_reset_boot_released: assume property (p_reset_boot_released);
        end
    endgenerate

    logic [2:0] valid_id_count_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            valid_id_count_q <= '0;
        end else if (instr_valid_id_i && valid_id_count_q != '1) begin
            valid_id_count_q <= valid_id_count_q + 1'b1;
        end
    end

    COV_BSDCOV_ENV_RESET_RELEASE:
        cover property (@(posedge clk_i) rst_ni && $past(!rst_ni));

    COV_BSDCOV_ENV_ONE_VALID_ID:
        cover property (@(posedge clk_i) disable iff (!rst_ni) instr_valid_id_i);

    COV_BSDCOV_ENV_TWO_VALID_ID:
        cover property (@(posedge clk_i) disable iff (!rst_ni) valid_id_count_q >= 3'd2);

    // -------------------------------------------------------------------------
    // Instruction bus reference state.
    // -------------------------------------------------------------------------

    logic [1:0]  instr_pending_count_q;
    logic [31:0] instr_pending_addr0_q;
    logic [31:0] instr_pending_addr1_q;

    wire instr_accept = instr_req_o && instr_gnt_i;
    wire instr_done   = instr_rvalid_i;
    wire instr_pending_full = (instr_pending_count_q == 2'd2);
    wire instr_pending_has_space = !instr_pending_full || instr_done;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            instr_pending_count_q <= 2'd0;
            instr_pending_addr0_q <= '0;
            instr_pending_addr1_q <= '0;
        end else begin
            unique case ({instr_done, instr_accept})
                2'b01: begin
                    if (instr_pending_count_q == 2'd0) begin
                        instr_pending_addr0_q <= instr_addr_o;
                        instr_pending_count_q <= 2'd1;
                    end else if (instr_pending_count_q == 2'd1) begin
                        instr_pending_addr1_q <= instr_addr_o;
                        instr_pending_count_q <= 2'd2;
                    end
                end

                2'b10: begin
                    if (instr_pending_count_q == 2'd1) begin
                        instr_pending_count_q <= 2'd0;
                    end else if (instr_pending_count_q == 2'd2) begin
                        instr_pending_addr0_q <= instr_pending_addr1_q;
                        instr_pending_count_q <= 2'd1;
                    end
                end

                2'b11: begin
                    if (instr_pending_count_q == 2'd1) begin
                        instr_pending_addr0_q <= instr_addr_o;
                        instr_pending_count_q <= 2'd1;
                    end else if (instr_pending_count_q == 2'd2) begin
                        instr_pending_addr0_q <= instr_pending_addr1_q;
                        instr_pending_addr1_q <= instr_addr_o;
                        instr_pending_count_q <= 2'd2;
                    end
                end

                default: begin
                    instr_pending_count_q <= instr_pending_count_q;
                end
            endcase
        end
    end

    // -------------------------------------------------------------------------
    // Data bus reference state.
    // -------------------------------------------------------------------------

    logic [1:0]  data_pending_count_q;
    logic [31:0] data_pending_addr0_q;
    logic [31:0] data_pending_addr1_q;
    logic        data_pending_we0_q;
    logic        data_pending_we1_q;
    logic [3:0]  data_pending_be0_q;
    logic [3:0]  data_pending_be1_q;
    logic [31:0] data_pending_wdata0_q;
    logic [31:0] data_pending_wdata1_q;

    wire data_accept = data_req_o && data_gnt_i;
    wire data_done   = data_rvalid_i;
    wire data_pending_full = (data_pending_count_q == 2'd2);
    wire data_pending_has_space = !data_pending_full || data_done;

    COV_BSDCOV_ENV_DATA_RESPONSE:
        cover property (
            @(posedge clk_i) disable iff (!rst_ni)
                data_accept ##[1:DATA_RVALID_MAX_LATENCY] data_rvalid_i
        );

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            data_pending_count_q  <= 2'd0;
            data_pending_addr0_q  <= '0;
            data_pending_addr1_q  <= '0;
            data_pending_we0_q    <= 1'b0;
            data_pending_we1_q    <= 1'b0;
            data_pending_be0_q    <= '0;
            data_pending_be1_q    <= '0;
            data_pending_wdata0_q <= '0;
            data_pending_wdata1_q <= '0;
        end else begin
            unique case ({data_done, data_accept})
                2'b01: begin
                    if (data_pending_count_q == 2'd0) begin
                        data_pending_addr0_q  <= data_addr_o;
                        data_pending_we0_q    <= data_we_o;
                        data_pending_be0_q    <= data_be_o;
                        data_pending_wdata0_q <= data_wdata_o;
                        data_pending_count_q  <= 2'd1;
                    end else if (data_pending_count_q == 2'd1) begin
                        data_pending_addr1_q  <= data_addr_o;
                        data_pending_we1_q    <= data_we_o;
                        data_pending_be1_q    <= data_be_o;
                        data_pending_wdata1_q <= data_wdata_o;
                        data_pending_count_q  <= 2'd2;
                    end
                end

                2'b10: begin
                    if (data_pending_count_q == 2'd1) begin
                        data_pending_count_q <= 2'd0;
                    end else if (data_pending_count_q == 2'd2) begin
                        data_pending_addr0_q  <= data_pending_addr1_q;
                        data_pending_we0_q    <= data_pending_we1_q;
                        data_pending_be0_q    <= data_pending_be1_q;
                        data_pending_wdata0_q <= data_pending_wdata1_q;
                        data_pending_count_q  <= 2'd1;
                    end
                end

                2'b11: begin
                    if (data_pending_count_q == 2'd1) begin
                        data_pending_addr0_q  <= data_addr_o;
                        data_pending_we0_q    <= data_we_o;
                        data_pending_be0_q    <= data_be_o;
                        data_pending_wdata0_q <= data_wdata_o;
                        data_pending_count_q  <= 2'd1;
                    end else if (data_pending_count_q == 2'd2) begin
                        data_pending_addr0_q  <= data_pending_addr1_q;
                        data_pending_we0_q    <= data_pending_we1_q;
                        data_pending_be0_q    <= data_pending_be1_q;
                        data_pending_wdata0_q <= data_pending_wdata1_q;
                        data_pending_addr1_q  <= data_addr_o;
                        data_pending_we1_q    <= data_we_o;
                        data_pending_be1_q    <= data_be_o;
                        data_pending_wdata1_q <= data_wdata_o;
                        data_pending_count_q  <= 2'd2;
                    end
                end

                default: begin
                    data_pending_count_q <= data_pending_count_q;
                end
            endcase
        end
    end

    always_ff @(posedge clk_i) begin
        if (rst_ni && data_done && data_pending_we0_q) begin
            dmem[dmem_index(data_pending_addr0_q)] <= apply_store_mask(
                dmem[dmem_index(data_pending_addr0_q)],
                data_pending_wdata0_q,
                data_pending_be0_q
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

            property p_scan_reset_released;
                @(posedge clk_i) disable iff (!rst_ni)
                    scan_rst_ni == 1'b1;
            endproperty
            asm_scan_reset_released: assume property (p_scan_reset_released);

            property p_no_scramble_key;
                @(posedge clk_i) disable iff (!rst_ni)
                    scramble_key_valid_i == 1'b0 &&
                    scramble_key_i == '0 &&
                    scramble_nonce_i == '0;
            endproperty
            asm_no_scramble_key: assume property (p_no_scramble_key);

            property p_no_mem_integrity_bits;
                @(posedge clk_i) disable iff (!rst_ni)
                    instr_rdata_intg_i == '0 &&
                    data_rdata_intg_i == '0;
            endproperty
            asm_no_mem_integrity_bits: assume property (p_no_mem_integrity_bits);

            property p_default_ram_cfg;
                @(posedge clk_i) disable iff (!rst_ni)
                    ram_cfg_icache_tag_i == prim_ram_1p_pkg::RAM_1P_CFG_DEFAULT &&
                    ram_cfg_icache_data_i == prim_ram_1p_pkg::RAM_1P_CFG_DEFAULT;
            endproperty
            asm_default_ram_cfg: assume property (p_default_ram_cfg);

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
        if (ASSUME_LEGAL_ID_STAGE_INSTR) begin : g_legal_id_stage_instr_assumption
            property p_legal_id_stage_instr;
                @(posedge clk_i) disable iff (!rst_ni)
                    instr_valid_id_i |->
                    !instr_fetch_err_id_i &&
                    !illegal_c_insn_id_i &&
                    !illegal_insn_id_i &&
                    imem_pc_in_range(pc_id_i, instr_is_compressed_id_i);
            endproperty
            asm_legal_id_stage_instr: assume property (p_legal_id_stage_instr);
        end
    endgenerate

    // -------------------------------------------------------------------------
    // Instruction protocol assumptions.
    // -------------------------------------------------------------------------

    property p_instr_gnt_only_on_req_with_space;
        @(posedge clk_i) disable iff (!rst_ni)
            instr_gnt_i |-> instr_req_o && instr_pending_has_space;
    endproperty
    asm_instr_gnt_only_on_req_with_space: assume property (p_instr_gnt_only_on_req_with_space);

    property p_instr_rvalid_only_when_outstanding;
        @(posedge clk_i) disable iff (!rst_ni)
            instr_rvalid_i |-> (instr_pending_count_q != 2'd0);
    endproperty
    asm_instr_rvalid_only_when_outstanding: assume property (p_instr_rvalid_only_when_outstanding);

    generate
        if (ASSUME_SINGLE_OUTSTANDING_INSTR) begin : g_single_outstanding_instr_assumption
            property p_no_second_instr_accept;
                @(posedge clk_i) disable iff (!rst_ni)
                    (instr_pending_count_q != 2'd0 && !instr_done) |-> !instr_accept;
            endproperty
            asm_no_second_instr_accept: assume property (p_no_second_instr_accept);
        end
    endgenerate

    property p_instr_req_gets_gnt;
        @(posedge clk_i) disable iff (!rst_ni)
            (instr_req_o && instr_pending_has_space)
            |-> ##[0:INSTR_GNT_MAX_LATENCY] instr_gnt_i;
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
            instr_rvalid_i |-> (instr_rdata_i == imem_word_at_addr(instr_pending_addr0_q));
    endproperty
    asm_instr_rdata_matches_imem: assume property (p_instr_rdata_matches_imem);

    // -------------------------------------------------------------------------
    // Data protocol assumptions.
    // -------------------------------------------------------------------------

    property p_data_gnt_only_on_req_with_space;
        @(posedge clk_i) disable iff (!rst_ni)
            data_gnt_i |-> data_req_o && data_pending_has_space;
    endproperty
    asm_data_gnt_only_on_req_with_space: assume property (p_data_gnt_only_on_req_with_space);

    property p_data_rvalid_only_when_outstanding;
        @(posedge clk_i) disable iff (!rst_ni)
            data_rvalid_i |-> (data_pending_count_q != 2'd0);
    endproperty
    asm_data_rvalid_only_when_outstanding: assume property (p_data_rvalid_only_when_outstanding);

    generate
        if (ASSUME_SINGLE_OUTSTANDING_DATA) begin : g_single_outstanding_data_assumption
            property p_no_second_data_accept;
                @(posedge clk_i) disable iff (!rst_ni)
                    (data_pending_count_q != 2'd0 && !data_done) |-> !data_accept;
            endproperty
            asm_no_second_data_accept: assume property (p_no_second_data_accept);
        end
    endgenerate

    property p_data_req_gets_gnt;
        @(posedge clk_i) disable iff (!rst_ni)
            (data_req_o && data_pending_has_space)
            |-> ##[0:DATA_GNT_MAX_LATENCY] data_gnt_i;
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
            (data_rvalid_i && !data_pending_we0_q)
            |->
            (data_rdata_i == dmem[dmem_index(data_pending_addr0_q)]);
    endproperty
    asm_data_rdata_matches_dmem_on_load: assume property (p_data_rdata_matches_dmem_on_load);

endmodule
