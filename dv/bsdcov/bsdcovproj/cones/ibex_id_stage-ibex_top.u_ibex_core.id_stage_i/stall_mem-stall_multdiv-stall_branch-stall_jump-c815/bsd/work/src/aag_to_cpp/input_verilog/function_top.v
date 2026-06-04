module function_top (i,o);

input 	[9411:0] i;
output	[0:0]  o;

wire	[0:0]  o_0;

function_layer_0_nodes_0	part0	(.i(i),.o_index(o_0));

assign	o[0]	=	o_0[0];
endmodule
