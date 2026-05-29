`include "function_layer_0_nodes_111111.v"

module function_top (i,o);

input  [33:0] i;
output [5:0] o;

wire [5:0] o_index;

function_layer_0_nodes_111111 u_bsd_cov_model (.i(i), .o_index(o_index));

assign o = o_index;
endmodule
