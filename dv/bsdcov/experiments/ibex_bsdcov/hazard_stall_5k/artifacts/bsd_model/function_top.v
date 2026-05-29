`include "function_layer_0_nodes_1111.v"

module function_top (i,o);

input  [39:0] i;
output [3:0] o;

wire [3:0] o_index;

function_layer_0_nodes_1111 u_bsd_cov_model (.i(i), .o_index(o_index));

assign o = o_index;
endmodule
