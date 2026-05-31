bind ibex_top : ibex_top
bsd_cov_ibex_top_instr_mem_assumptions
#(
    .NUM_TRACK(32),

    .RV32E          (RV32E),
    .RV32M          (RV32M),
    .RV32B          (RV32B),
    .BranchTargetALU(BranchTargetALU)
)
bsd_cov_ibex_top_instr_mem_assumptions_inst
(
    .clk_i          (clk_i),
    .rst_ni         (rst_ni),
        
    .illegal_instr(u_ibex_core.id_stage_i.decoder_i.illegal_insn_o),

    .instr_req_o    (instr_req_o),
    .instr_gnt_i    (instr_gnt_i),
    .instr_rvalid_i (instr_rvalid_i),
    .instr_addr_o   (instr_addr_o),
    .instr_rdata_i  (instr_rdata_i),
    .instr_err_i    (instr_err_i)
);


module bsd_cov_ibex_top_instr_mem_assumptions
#(
    parameter int unsigned NUM_TRACK = 32,

    parameter bit RV32E               = 0,
    parameter ibex_pkg::rv32m_e RV32M = ibex_pkg::RV32MFast,
    parameter ibex_pkg::rv32b_e RV32B = ibex_pkg::RV32BNone,
    parameter bit BranchTargetALU     = 0
)
(
    input logic        clk_i,
    input logic        rst_ni,

    input logic        illegal_instr,

    input logic        instr_req_o,
    input logic [31:0] instr_addr_o,
    input logic        instr_gnt_i,
    input logic        instr_rvalid_i,
    input logic [31:0] instr_rdata_i,
    input logic        instr_err_i
);

    logic instr_mem_gnt;
    logic instr_mem_rvalid;
    logic instr_mem_rdata;
    logic instr_mem_err;

    instr_mem #(
        .NUM_TRACK(NUM_TRACK), 

        .RV32E          (RV32E),
        .RV32M          (RV32M),
        .RV32B          (RV32B),
        .BranchTargetALU(BranchTargetALU)
    ) instr_mem_inst (
        .clk_i     (clk_i),
        .rst_ni    (rst_ni),

        .req_i     (instr_req_o),
        .addr_i    (instr_addr_o),

        .gnt_o     (instr_mem_gnt),
        .rvalid_o  (instr_mem_rvalid),
        .rdata_o   (instr_mem_rdata),
        .err_o     (instr_mem_err)
    );

    property p_instr_mem_gnt;
        @(posedge clk_i) disable iff (!rst_ni)
        instr_mem_gnt == instr_gnt_i;
    endproperty
    ASM_instr_mem_gnt: assume property (p_instr_mem_gnt);

    property p_instr_mem_rvalid;
        @(posedge clk_i) disable iff (!rst_ni)
        instr_mem_rvalid == instr_rvalid_i;
    endproperty
    ASM_instr_mem_rvalid: assume property (p_instr_mem_rvalid);

    // property p_legal_instr;
    //     @(posedge clk_i) disable iff (!rst_ni)
    //     illegal_instr == 0;
    // endproperty
    // ASM_legal_instr: assume property (p_legal_instr);

    // property p_instr_mem_rdata;
    //     @(posedge clk_i) disable iff (!rst_ni)
    //     instr_mem_rdata == instr_rdata_i;
    // endproperty
    // ASM_instr_mem_rdata: assume property (p_instr_mem_rdata);

    property p_instr_mem_err;
        @(posedge clk_i) disable iff (!rst_ni)
        instr_mem_err == instr_err_i;
    endproperty
    ASM_instr_mem_err: assume property (p_instr_mem_err);

    /*
    /////////////// Outstanding Requests: max 1 allowed, must complete current one before dealing with the next one
    logic instr_accept;
    logic instr_done;
    assign instr_accept = instr_gnt_i & instr_req_o;
    assign instr_done = instr_rvalid_i;    

    logic block_req_d;
    logic block_req_q;
    assign block_req_d = instr_accept ? 1'b1 :
                         instr_done   ? 1'b0 :
                                        block_req_q;
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            block_req_q <= 1'b0;
        end else begin
            block_req_q <= block_req_d;
        end
    end

    // 有 pending response 时，memory 不能 grant 新 request
    property p_instr_no_gnt_when_block_req;
        @(posedge clk_i) disable iff (!rst_ni)
            block_req_q |-> !instr_gnt_i;
    endproperty
    ASM_instr_no_gnt_when_block_req:
        assume property (p_instr_no_gnt_when_block_req);

    // rvalid 只能在有 pending request 时出现
    property p_instr_rvalid_only_when_block_req;
        @(posedge clk_i) disable iff (!rst_ni)
            instr_rvalid_i |-> block_req_q;
    endproperty
    ASM_instr_rvalid_only_when_block_req:
        assume property (p_instr_rvalid_only_when_block_req);
    
    // 没有 block 的时候，req 会在下一拍得到 grant
    property p_instr_req_gets_gnt_when_not_blocked;
        @(posedge clk_i) disable iff (!rst_ni)
            (instr_req_o && !block_req_q && !instr_gnt_i)
            |-> ##1 instr_gnt_i;
    endproperty
    ASM_instr_req_gets_gnt_when_not_blocked:
        assume property (p_instr_req_gets_gnt_when_not_blocked);
    
    // accept 后，rvalid 在下一拍回来
    property p_instr_accept_gets_rvalid;
        @(posedge clk_i) disable iff (!rst_ni)
            instr_accept
            |-> ##1 instr_rvalid_i;
    endproperty
    ASM_instr_accept_gets_rvalid:
        assume property (p_instr_accept_gets_rvalid);
    */


    /*
    /////////////// WIP: Same Addr returns Same Data (Data consistancy)
    logic [NUM_TRACK-1:0] slot_vld_q;
    logic [NUM_TRACK-1:0][31:0] slot_addr_q;
    logic [NUM_TRACK-1:0][31:0] slot_data_q;

    localparam int SLOT_CNT_W = (NUM_TRACK == 0) ? 1 : $clog2(NUM_TRACK + 1);
    logic [SLOT_CNT_W-1:0] slot_cnt_d;
    logic [SLOT_CNT_W-1:0] slot_cnt_q;

    // check if the instr_addr hit the previous one, or there is an empty slot
    logic [NUM_TRACK-1:0] hit_vec;
    logic [NUM_TRACK-1:0] free_vec;
    logic has_hit;
    logic has_free;

    genvar gi;
    generate
        for (gi = 0; gi < NUM_TRACK; gi = gi + 1) begin: instr_addr_hit
            assign hit_vec[gi] = slot_vld_q[gi] & (slot_addr_q[gi] == instr_addr_o);
            assign free_vec[gi] = ~slot_vld_q[gi];
        end
    endgenerate
    assign has_hit = |hit_vec;
    assign has_free = |free_vec;

    assign slot_cnt_d = (~has_hit & instr_done) ? 
                        slot_cnt_q + 1 :
                        slot_cnt_q;
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni)
            slot_cnt_q <= 0;
        else
            slot_cnt_q <= slot_cnt_d;
    end

    // a new addr never seen before

    // a seen addr
    */


endmodule