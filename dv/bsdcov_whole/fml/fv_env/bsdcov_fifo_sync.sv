module bsdcov_fifo_sync #(
    parameter int unsigned Width = 32,
    parameter int unsigned Depth = 2,

    localparam int unsigned DepthW = (Depth <= 1) ? 1 : $clog2(Depth + 1),
    localparam int unsigned PtrW   = (Depth <= 1) ? 1 : $clog2(Depth)
) (
    input  logic              clk_i,
    input  logic              rst_ni,

    // write side
    input  logic              wvalid_i,
    output logic              wready_o,
    input  logic [Width-1:0]  wdata_i,

    // read side
    output logic              rvalid_o,
    input  logic              rready_i,
    output logic [Width-1:0]  rdata_o,

    // status
    output logic              full_o,
    output logic              empty_o,
    output logic              allow_push_o,
    output logic [DepthW-1:0] depth_o
);

    logic [Depth-1:0][Width-1:0] storage_q;

    logic [PtrW-1:0] wptr_d;
    logic [PtrW-1:0] wptr_q;
    logic [PtrW-1:0] wptr_next;

    logic [PtrW-1:0] rptr_d;
    logic [PtrW-1:0] rptr_q;
    logic [PtrW-1:0] rptr_next;

    logic [DepthW-1:0] depth_d;
    logic [DepthW-1:0] depth_q;

    logic do_push;
    logic do_pop;

    assign empty_o = (depth_q == '0);
    assign full_o  = (depth_q == DepthW'(Depth));

    assign rvalid_o = !empty_o;

    assign do_pop  = rvalid_o && rready_i;

    // Allow push if FIFO is not full, or if this cycle also pops one entry.
    assign allow_push_o = !full_o || do_pop;
    assign wready_o     = allow_push_o;

    assign do_push = wvalid_i && wready_o;

    assign depth_o = depth_q;

    assign rdata_o = rvalid_o ? storage_q[rptr_q] : Width'(0);

    // -------------------------------------------------------------------------
    // Write pointer
    // -------------------------------------------------------------------------
    assign wptr_next = (wptr_q == PtrW'(Depth - 1)) ? '0 :
                                                       wptr_q + PtrW'(1);
    assign wptr_d = do_push ? wptr_next : wptr_q;
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            wptr_q <= '0;
        end else begin
            wptr_q <= wptr_d;
        end
    end

    // -------------------------------------------------------------------------
    // Read pointer
    // -------------------------------------------------------------------------
    assign rptr_next = (rptr_q == PtrW'(Depth - 1)) ? '0 :
                                                       rptr_q + PtrW'(1);
    assign rptr_d = do_pop ? rptr_next : rptr_q;
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            rptr_q <= '0;
        end else begin
            rptr_q <= rptr_d;
        end
    end

    // -------------------------------------------------------------------------
    // Depth counter
    // -------------------------------------------------------------------------
    assign depth_d = ( do_push && !do_pop) ? depth_q + DepthW'(1) :
                     (!do_push &&  do_pop) ? depth_q - DepthW'(1) :
                                             depth_q;
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            depth_q <= '0;
        end else begin
            depth_q <= depth_d;
        end
    end

    // -------------------------------------------------------------------------
    // Storage
    // -------------------------------------------------------------------------
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            storage_q <= '0;
        end else if (do_push) begin
            storage_q[wptr_q] <= wdata_i;
        end
    end

    // -------------------------------------------------------------------------
    // FIFO Assertions
    // -------------------------------------------------------------------------

    // 1. depth cannot exceed Depth.
    property p_depth_not_exceed_depth;
        @(posedge clk_i) disable iff (!rst_ni)
            depth_q <= DepthW'(Depth);
    endproperty
    AST_BSDCOV_depth_not_exceed_depth:
        assert property (p_depth_not_exceed_depth);


    // 2. If wr_ptr is larger than rd_ptr, then depth = wr_ptr - rd_ptr.
    property p_depth_eq_wptr_minus_rptr;
        @(posedge clk_i) disable iff (!rst_ni)
            (wptr_q > rptr_q)
            |->
            (depth_q == (DepthW'(wptr_q) - DepthW'(rptr_q)));
    endproperty
    AST_BSDCOV_depth_eq_wptr_minus_rptr:
        assert property (p_depth_eq_wptr_minus_rptr);


    // 3. If wr_ptr is smaller than rd_ptr, then depth = wr_ptr + Depth - rd_ptr.
    property p_depth_eq_wptr_plus_depth_minus_rptr;
        @(posedge clk_i) disable iff (!rst_ni)
            (wptr_q < rptr_q)
            |->
            (depth_q == (DepthW'(wptr_q) + DepthW'(Depth) - DepthW'(rptr_q)));
    endproperty
    AST_BSDCOV_depth_eq_wptr_plus_depth_minus_rptr:
        assert property (p_depth_eq_wptr_plus_depth_minus_rptr);


    // 4. If wr_ptr equals rd_ptr, FIFO is either empty or full.
    property p_equal_ptr_means_empty_or_full;
        @(posedge clk_i) disable iff (!rst_ni)
            (wptr_q == rptr_q) |-> (empty_o || full_o);
    endproperty
    AST_BSDCOV_equal_ptr_means_empty_or_full:
        assert property (p_equal_ptr_means_empty_or_full);

endmodule
