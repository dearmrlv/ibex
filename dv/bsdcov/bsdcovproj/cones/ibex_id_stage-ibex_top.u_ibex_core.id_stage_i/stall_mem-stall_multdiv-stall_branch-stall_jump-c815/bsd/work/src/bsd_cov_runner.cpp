#include "BSD_top.h"
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <string>

static void bsd_cov_write_function_top() {
    std::string node_string;
    for (int64_t i = 0; i < parameter_output_bit_width; ++i) node_string.push_back('1');
    std::ofstream f("rtl/function_top.v");
    f << "`include \"function_layer_0_nodes_" << node_string << ".v\"\n\n";
    f << "module function_top (i,o);\n\n";
    f << "input  [" << parameter_input_bit_width - 1 << ":0] i;\n";
    f << "output [" << parameter_output_bit_width - 1 << ":0] o;\n\n";
    f << "wire [" << parameter_output_bit_width - 1 << ":0] o_index;\n\n";
    f << "function_layer_0_nodes_" << node_string << " u_bsd_cov_model (.i(i), .o_index(o_index));\n\n";
    f << "assign o = o_index;\n";
    f << "endmodule\n";
}

int main() {
    set_default();
    int64_t* order = new int64_t[parameter_input_bit_width];
    for (int64_t i = 0; i < parameter_input_bit_width; ++i) order[i] = i;
    BSD_execute(default_start_node_number, default_start_node_index, parameter_input_bit_width, order);
    bsd_cov_write_function_top();
    bsd_cov_write_replay_stats("rtl/bsd_cov_replay_stats.json");
    delete [] order;
    fflush(NULL);
    std::_Exit(0);
}
