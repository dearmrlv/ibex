bind ibex_top : ibex_top
bsd_cov_ibex_top_instr_mem_assumptions
#(
    .NUM_TRACK(32),

    .NUM_INSTR_OUTSTANDING(2),
    .INSTR_GNT_MAX_LATENCY(1),
    .INSTR_RVALID_MAX_LATENCY(3)
)
bsd_cov_ibex_top_instr_mem_assumptions_inst
(
    .clk_i          (clk_i),
    .rst_ni         (rst_ni),

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

    parameter int unsigned NUM_INSTR_OUTSTANDING = 2,
    parameter int unsigned INSTR_GNT_MAX_LATENCY    = 1,
    parameter int unsigned INSTR_RVALID_MAX_LATENCY = 3
)
(
    input logic        clk_i,
    input logic        rst_ni,

    input logic        instr_req_o,
    input logic [31:0] instr_addr_o,
    input logic        instr_gnt_i,
    input logic        instr_rvalid_i,
    input logic [31:0] instr_rdata_i,
    input logic        instr_err_i
);

    // -------------------------------------------------------------------------
    // Instruction memory protocol assumptions.
    // -------------------------------------------------------------------------

    /////////////// Memory cannot grant without a request.
    property p_instr_gnt_only_on_req;
        @(posedge clk_i) disable iff (!rst_ni)
            instr_gnt_i |-> instr_req_o;
    endproperty
    ASM_instr_gnt_only_on_req: assume property (p_instr_gnt_only_on_req);

    /////////////// while req is not granted, keep stable
    property p_instr_req_addr_stable_until_gnt;
        @(posedge clk_i) disable iff (!rst_ni)
            (instr_req_o && !instr_gnt_i)
            |=>
            (instr_req_o && $stable(instr_addr_o));
    endproperty
    ASM_instr_req_addr_stable_until_gnt:
        assume property (p_instr_req_addr_stable_until_gnt);

    /////////////// No Instruction Error
    property p_no_instruction_error;
        @(posedge clk_i) disable iff (!rst_ni)
            instr_err_i == 1'b0;
    endproperty
    ASM_no_instruction_error: assume property (p_no_instruction_error);

    /////////////// Word Aligned
    property p_instr_addr_word_aligned;
        @(posedge clk_i) disable iff (!rst_ni)
            instr_req_o |-> (instr_addr_o[1:0] == 2'b00);
    endproperty
    ASM_instr_addr_word_aligned: assume property (p_instr_addr_word_aligned);

    /////////////// WIP: Outstanding Requests: max 2 allowed
    logic instr_accept;
    logic instr_done;
    assign instr_accept = instr_gnt_i & instr_req_o;
    assign instr_done = instr_rvalid_i;    

    localparam int unsigned INSTR_FIFO_DEPTH_W =
    (NUM_INSTR_OUTSTANDING <= 1) ? 1 : $clog2(NUM_INSTR_OUTSTANDING + 1);

    logic instr_fifo_wready;
    logic instr_fifo_rvalid;
    logic instr_fifo_full;
    logic instr_fifo_empty;
    logic instr_fifo_allow_push;
    logic [INSTR_FIFO_DEPTH_W-1:0] instr_fifo_depth;
    logic [31:0] instr_resp_addr;

    bsdcov_fifo_sync #(
        .Width(32),
        .Depth(NUM_INSTR_OUTSTANDING)
    ) u_instr_addr_fifo (
        .clk_i        (clk_i),
        .rst_ni       (rst_ni),
    
        .wvalid_i     (instr_accept),
        .wready_o     (instr_fifo_wready),
        .wdata_i      (instr_addr_o),
    
        .rvalid_o     (instr_fifo_rvalid),
        .rready_i     (instr_done),
        .rdata_o      (instr_resp_addr),
    
        .full_o       (instr_fifo_full),
        .empty_o      (instr_fifo_empty),
        .allow_push_o (instr_fifo_allow_push),
        .depth_o      (instr_fifo_depth)
    );

    // If the FIFO is full and no response returns in this cycle, memory must not
    // grant a new request.
    property p_instr_no_accept_when_full;
        @(posedge clk_i) disable iff (!rst_ni)
            (instr_fifo_full && !instr_done) |-> !instr_gnt_i;
    endproperty
    ASM_instr_no_accept_when_full:
        assume property (p_instr_no_accept_when_full);

    // A response can only occur when there is an outstanding request.
    property p_instr_rvalid_only_when_outstanding;
        @(posedge clk_i) disable iff (!rst_ni)
            instr_rvalid_i |-> instr_fifo_rvalid;
    endproperty
    ASM_instr_rvalid_only_when_outstanding:
        assume property (p_instr_rvalid_only_when_outstanding);

    // If Ibex requests while the instruction FIFO can accept a new request,
    // memory grants within a bounded latency.
    property p_instr_req_gets_gnt_when_fifo_allows_push;
        @(posedge clk_i) disable iff (!rst_ni)
            (instr_req_o && instr_fifo_allow_push)
            |-> ##[0:INSTR_GNT_MAX_LATENCY] instr_gnt_i;
    endproperty
    ASM_instr_req_gets_gnt_when_fifo_allows_push:
        assume property (p_instr_req_gets_gnt_when_fifo_allows_push);

    // Once a request is accepted, memory returns a response within a bounded
    // latency.
    property p_instr_accept_gets_rvalid;
        @(posedge clk_i) disable iff (!rst_ni)
            instr_accept
            |-> ##[1:INSTR_RVALID_MAX_LATENCY] instr_rvalid_i;
    endproperty
    ASM_instr_accept_gets_rvalid:
        assume property (p_instr_accept_gets_rvalid);

    // make gnt a pulse
    property p_gnt_pulse;
        @(posedge clk_i) disable iff (!rst_ni)
        instr_gnt_i |=> ~instr_gnt_i;
    endproperty
    ASM_gnt_pulse:
        assume property (p_gnt_pulse);

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