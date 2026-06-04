
int64_t BDD_class::print_circuit(int64_t node_depth, char* start_node_index_string){
	#ifdef SEARCH_PARTITION
	if (start_node_index_string == nullptr) {
	    std::cout << "Error: Null pointer input.0" << std::endl;
	    exit(1);
    }
    // 方法：直接遍历寻找 '1'
    // 由于是独热码， theoretically 只有一个 '1'
    uint64_t start_node_index = 0;
    // 这种写法不需要先用 strlen 计算长度，效率更高，直接扫到 '\0' 结束
    for (int i = 0; start_node_index_string[i] != '\0'; ++i) {
        if (start_node_index_string[i] == '1') {
            if (start_node_index != 0) {
                std::cout << "Error: start_node_index_string is not one-hot string.1" << std::endl;
                exit(1);
            }
            start_node_index = i;
        }
    }
	#endif
 int64_t i,j;
 int64_t zi;
 
 char*  output_file_name = new char [100+parameter_output_bit_width];
//sprintf(output_file_name,"rtl/module_output_bit_%d.v",which_bit_output);
// sprintf(output_file_name,"rtl/function_%d_id_%d.v",circuit_index,BDD_id);
#ifdef DYNAMIC_SUFFIX
    sprintf(output_file_name,"rtl_set/function_layer_%d_nodes_%s.v",node_depth, output_suffix.c_str());
#else
    #ifdef SEARCH_PARTITION
        sprintf(output_file_name,"rtl/function_layer_%d_nodes_%d.v",node_depth, start_node_index);
    #else
        sprintf(output_file_name,"rtl/function_layer_%d_nodes_%s.v",node_depth, start_node_index_string);
    #endif
#endif
// string  output_file_name << output_file_name_begin << which_bit_output << output_file_name_end;

 
     cout<<output_file_name<<endl;

      ofstream output_module_file(output_file_name);
 
	//copy this
 	char  plot_file_name[100];
	sprintf(plot_file_name,"BDD.plot");
      	ofstream plot_file(plot_file_name);
	for (int64_t i=0;i<total_BDD_depth;i++){
		plot_file <<"[";
	  for (int64_t j=0;j<BDD_width_each_layer[i];j++){
			plot_file << "("<<BDD[i][j].left_node_index << "," << BDD[i][j].right_node_index<<")";
			if(j < (BDD_width_each_layer[i]-1)){
				plot_file <<",";
			}
			else{
				//plot_file <<endl;
			}
		}
		plot_file <<"]"<<endl;
	}
	
		plot_file <<"[";
		for (int64_t i=0;i<total_BDD_depth;i++){
			plot_file<<BDD[i][0].this_layer_bit_expansion;
			if(i<total_BDD_depth-1)
				plot_file<<",";
		}
		plot_file <<"]"<<endl;
	//finish copy

/////////////////////////////////// output_module_file << "//circuit accuracy = "<<circuit_accuracy<<endl; 
/////////////////////////////////// output_module_file << "//test amounts  = "<<parameter_test_ios<<endl; 
/////////////////////////////////// output_module_file << "//total BDD nodes = "<<total_nodes_amount<<endl; 
/////////////////////////////////// output_module_file << "//total split modes = "<<total_split_nodes<<endl; 
/////////////////////////////////// output_module_file << "//train time = "<<train_time<<endl; 
/////////////////////////////////// output_module_file << "module module_output_bit_"<<which_bit_output<<"(i,o);"<<endl<<endl; 
/////////////////////////////////// output_module_file << "input ["<<parameter_input_bit_width-1<<":0] i;"<<endl; 
/////////////////////////////////// output_module_file << "output  o;"<<endl<<endl;
///////////////////////////////////
/////////////////////////////////// output_module_file << "wire ["<<total_non_equal_nodes-1<<":0] nodes;"<<endl;
///////////////////////////////////
/////////////////////////////////// output_module_file <<endl<< "assign o = nodes[0];"<<endl<<endl;
/////////////////////////////////// for (i=0;i<total_BDD_depth+1;i++){
///////////////////////////////////  for (j=0;j<BDD_width_each_layer[i];j++){
///////////////////////////////////   if((BDD[i][j].left_node_index >= 0) && (BDD[i][j].right_node_index >= 0)){
///////////////////////////////////	if(BDD[i][j].left_node_index == BDD[i][j].right_node_index){
///////////////////////////////////		if((BDD[i][j].left_node_neg == 0) && (BDD[i][j].right_node_neg == 0)){
///////////////////////////////////			if(BDD[i][j].non_equal_number == BDD[i+1][BDD[i][j].left_node_index].non_equal_number){
///////////////////////////////////				;
///////////////////////////////////			}else{
///////////////////////////////////    				output_module_file << "assign nodes["<<BDD[i][j].non_equal_number<<"]    = (nodes["<<BDD[i+1][BDD[i][j].left_node_index].non_equal_number<<"]);"<<endl;
///////////////////////////////////			}
///////////////////////////////////		}else if((BDD[i][j].left_node_neg == 1) && (BDD[i][j].right_node_neg == 1)){
///////////////////////////////////    			output_module_file << "assign nodes["<<BDD[i][j].non_equal_number<<"]    = (!nodes["<<BDD[i+1][BDD[i][j].left_node_index].non_equal_number<<"]);"<<endl;
///////////////////////////////////		}else if((BDD[i][j].left_node_neg == 0) && (BDD[i][j].right_node_neg == 1)){
///////////////////////////////////    			output_module_file << "assign nodes["<<BDD[i][j].non_equal_number<<"]    = ( nodes["<<BDD[i+1][BDD[i][j].left_node_index].non_equal_number<<"] ^   i["<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;	
///////////////////////////////////		}else if((BDD[i][j].left_node_neg == 1) && (BDD[i][j].right_node_neg == 0)){
///////////////////////////////////    			output_module_file << "assign nodes["<<BDD[i][j].non_equal_number<<"]    = ( nodes["<<BDD[i+1][BDD[i][j].left_node_index].non_equal_number<<"] ^  !i["<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;	
///////////////////////////////////		}
///////////////////////////////////	}else{
///////////////////////////////////		if((BDD[i][j].left_node_neg == 0) && (BDD[i][j].right_node_neg == 0)){
///////////////////////////////////    			output_module_file << "assign nodes["<<BDD[i][j].non_equal_number<<"]    = ( nodes["<<BDD[i+1][BDD[i][j].left_node_index].non_equal_number<<"] & !i["<<BDD[i][j].this_layer_bit_expansion<<"]) | ( nodes["<<BDD[i+1][BDD[i][j].right_node_index].non_equal_number<<"] &  i["<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;	
///////////////////////////////////		}else if((BDD[i][j].left_node_neg == 1) && (BDD[i][j].right_node_neg == 1)){
///////////////////////////////////    			output_module_file << "assign nodes["<<BDD[i][j].non_equal_number<<"]    = (!nodes["<<BDD[i+1][BDD[i][j].left_node_index].non_equal_number<<"] & !i["<<BDD[i][j].this_layer_bit_expansion<<"]) | (!nodes["<<BDD[i+1][BDD[i][j].right_node_index].non_equal_number<<"] &  i["<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;	
///////////////////////////////////		}else if((BDD[i][j].left_node_neg == 0) && (BDD[i][j].right_node_neg == 1)){
///////////////////////////////////    			output_module_file << "assign nodes["<<BDD[i][j].non_equal_number<<"]    = ( nodes["<<BDD[i+1][BDD[i][j].left_node_index].non_equal_number<<"] & !i["<<BDD[i][j].this_layer_bit_expansion<<"]) | (!nodes["<<BDD[i+1][BDD[i][j].right_node_index].non_equal_number<<"] &  i["<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;	
///////////////////////////////////		}else if((BDD[i][j].left_node_neg == 1) && (BDD[i][j].right_node_neg == 0)){
///////////////////////////////////    			output_module_file << "assign nodes["<<BDD[i][j].non_equal_number<<"]    = (!nodes["<<BDD[i+1][BDD[i][j].left_node_index].non_equal_number<<"] & !i["<<BDD[i][j].this_layer_bit_expansion<<"]) | ( nodes["<<BDD[i+1][BDD[i][j].right_node_index].non_equal_number<<"] &  i["<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;	
///////////////////////////////////		}
///////////////////////////////////	}
///////////////////////////////////   }else if((BDD[i][j].left_node_index == -1) & (BDD[i][j].right_node_index >= 0)){
///////////////////////////////////	if(BDD[i][j].right_node_neg == 0){
///////////////////////////////////    		output_module_file << "assign nodes["<<BDD[i][j].non_equal_number<<"]    = (!i["<<BDD[i][j].this_layer_bit_expansion<<"]) | ( nodes["<<BDD[i+1][BDD[i][j].right_node_index].non_equal_number<<"] &  i["<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
///////////////////////////////////	}else{
///////////////////////////////////    		output_module_file << "assign nodes["<<BDD[i][j].non_equal_number<<"]    = (!i["<<BDD[i][j].this_layer_bit_expansion<<"]) | (!nodes["<<BDD[i+1][BDD[i][j].right_node_index].non_equal_number<<"] &  i["<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
///////////////////////////////////	}
///////////////////////////////////   }else if((BDD[i][j].left_node_index == -2) & (BDD[i][j].right_node_index >= 0)){
///////////////////////////////////	if(BDD[i][j].right_node_neg == 0){
///////////////////////////////////    		output_module_file << "assign nodes["<<BDD[i][j].non_equal_number<<"]    = ( nodes["<<BDD[i+1][BDD[i][j].right_node_index].non_equal_number<<"] &  i["<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
///////////////////////////////////	}else{
///////////////////////////////////    		output_module_file << "assign nodes["<<BDD[i][j].non_equal_number<<"]    = (!nodes["<<BDD[i+1][BDD[i][j].right_node_index].non_equal_number<<"] &  i["<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
///////////////////////////////////	}
///////////////////////////////////   }else if((BDD[i][j].left_node_index >= 0) & (BDD[i][j].right_node_index == -1 )){
///////////////////////////////////	if(BDD[i][j].left_node_neg == 0){
///////////////////////////////////    		output_module_file << "assign nodes["<<BDD[i][j].non_equal_number<<"]    = ( nodes["<<BDD[i+1][BDD[i][j].left_node_index].non_equal_number<<"] & !i["<<BDD[i][j].this_layer_bit_expansion<<"]) | (      i["<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
///////////////////////////////////	}else{
///////////////////////////////////    		output_module_file << "assign nodes["<<BDD[i][j].non_equal_number<<"]    = (!nodes["<<BDD[i+1][BDD[i][j].left_node_index].non_equal_number<<"] & !i["<<BDD[i][j].this_layer_bit_expansion<<"]) | (      i["<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
///////////////////////////////////	}
///////////////////////////////////   }else if((BDD[i][j].left_node_index >= 0) & (BDD[i][j].right_node_index == -2)){
///////////////////////////////////	if(BDD[i][j].right_node_neg == 0){
///////////////////////////////////    		output_module_file << "assign nodes["<<BDD[i][j].non_equal_number<<"]    = ( nodes["<<BDD[i+1][BDD[i][j].left_node_index].non_equal_number<<"] & !i["<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
///////////////////////////////////	}else{
///////////////////////////////////    		output_module_file << "assign nodes["<<BDD[i][j].non_equal_number<<"]    = (!nodes["<<BDD[i+1][BDD[i][j].left_node_index].non_equal_number<<"] & !i["<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
///////////////////////////////////	}
///////////////////////////////////   }else if((BDD[i][j].left_node_index == -1) & (BDD[i][j].right_node_index == -1)){
///////////////////////////////////    	output_module_file << "assign nodes["<<BDD[i][j].non_equal_number<<"]    = 1;"<<endl;
///////////////////////////////////   }else if((BDD[i][j].left_node_index == -2) & (BDD[i][j].right_node_index == -2)){
///////////////////////////////////    	output_module_file << "assign nodes["<<BDD[i][j].non_equal_number<<"]    = 0;"<<endl;
///////////////////////////////////   }else if((BDD[i][j].left_node_index == -1) & (BDD[i][j].right_node_index == -2)){
///////////////////////////////////    	output_module_file << "assign nodes["<<BDD[i][j].non_equal_number<<"]    = !i["<<BDD[i][j].this_layer_bit_expansion<<"];"<<endl;
///////////////////////////////////   }else if((BDD[i][j].left_node_index == -2) & (BDD[i][j].right_node_index == -1)){
///////////////////////////////////    	output_module_file << "assign nodes["<<BDD[i][j].non_equal_number<<"]    =  i["<<BDD[i][j].this_layer_bit_expansion<<"];"<<endl;
///////////////////////////////////   }
///////////////////////////////////  }
/////////////////////////////////// }
/////////////////////////////////// 
/////////////////////////////////// output_module_file << endl <<"endmodule"<<endl;









 output_module_file << "//circuit accuracy	= "<<circuit_accuracy<<endl; 
 output_module_file << "//test amounts 	= "<<parameter_test_ios<<endl; 
 output_module_file <<"//total BDD depth	="<<total_BDD_depth<<endl;
 output_module_file << "//total BDD nodes	= "<<total_nodes_amount<<endl; 
 output_module_file << "//total split modes	= "<<total_split_nodes<<endl; 
 output_module_file << "//total BDD nodes recursive	= "<<total_nodes_amount_recursive<<endl; 
 output_module_file << "//total split modes recursive	= "<<total_split_nodes_recursive<<endl; 
 output_module_file << "//train time	= "<<train_time<<endl; 
// output_module_file << "module function_"<<circuit_index<<"_BDD_id_"<<BDD_id<<" (i,o);"<<endl<<endl; 
 output_module_file << "module function_layer_"<<node_depth<<"_nodes_";
#ifdef SEARCH_PARTITION
 output_module_file << start_node_index;
#else
 for(int64_t i=0;i<parameter_output_bit_width;i++){
 	output_module_file << start_node_index_string[i];
 }
#endif
 output_module_file <<"	(i,o_index);"<<endl<<endl;
 output_module_file << "input 	["<<PI_WIDTH-1<<":0] i;"<<endl; 
 output_module_file << "output	["<<parameter_output_bit_width-1<<":0]  o_index;"<<endl<<endl;

 
 output_module_file << "wire	["<<how_many_start_nodes-1<<":0]  o;"<<endl<<endl;
 
int64_t ij=0;
for(int64_t i=0;i<parameter_output_bit_width;i++){
	if(start_node_index_string[i]=='1'){
 		output_module_file << "assign	o_index["<<i<<"] = o["<<ij<<"];"<<endl;
		ij++;
	}
}
output_module_file <<endl;

if(partition_depth ==  total_BDD_depth){
	 for (i=0;i<total_BDD_depth+1;i++){
		if(BDD_width_each_layer[i]>0)
	  		output_module_file << "wire ["<<setw(6)<<BDD_width_each_layer[i]-1<<":0] l_"<<i<<";"<<endl;
	 }

	cout<<endl;
	for (i=0;i<partition_into_how_many_parts;i++){
	  output_module_file << "wire ["<<setw(6)<<partition_start_node_numbers[i]-1<<":0] part_"<<i<<";"<<endl;
	}
	for (i=0;i<partition_into_how_many_parts;i++){
	  output_module_file << "function_"<<circuit_index<<"_BDD_"<<BDD_partition[BDD[total_BDD_depth][partition_index[i][0]].switch_to_which_BDD].BDD_id<<"	p_"<<i<<"	(i,part_"<<i<<");"<<endl;
	}
	
	 output_module_file <<endl<< "assign o ["<<how_many_start_nodes-1<<":0] = l_0["<<how_many_start_nodes-1<<":0];"<<endl<<endl;
	 for (i=start_depth;i<total_BDD_depth;i++){
	  for (j=0;j<BDD_width_each_layer[i];j++){
	   if((BDD[i][j].left_node_index >= 0) & (BDD[i][j].right_node_index >= 0)){
		if(BDD[i][j].left_node_index == BDD[i][j].right_node_index){
			if((BDD[i][j].left_node_neg == 0) && (BDD[i][j].right_node_neg == 0)){
	    			output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = ( l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].left_node_index<<"]);"<<endl;
			}else if((BDD[i][j].left_node_neg == 1) && (BDD[i][j].right_node_neg == 1)){
	    			output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = (!l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].left_node_index<<"]);"<<endl;
			}else if((BDD[i][j].left_node_neg == 0) && (BDD[i][j].right_node_neg == 1)){
	    			output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = ( l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].left_node_index<<"] ^  i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;	
			}else if((BDD[i][j].left_node_neg == 1) && (BDD[i][j].right_node_neg == 0)){
	    			output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = ( l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].left_node_index<<"] ^ !i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;	
			}
		}else{
			if((BDD[i][j].left_node_neg == 0) && (BDD[i][j].right_node_neg == 0)){
	    			output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = ( l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].left_node_index<<"] & !i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]) | ( l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].right_node_index<<"] &  i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;	
			}else if((BDD[i][j].left_node_neg == 1) && (BDD[i][j].right_node_neg == 1)){
	    			output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = (!l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].left_node_index<<"] & !i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]) | (!l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].right_node_index<<"] &  i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;	
			}else if((BDD[i][j].left_node_neg == 0) && (BDD[i][j].right_node_neg == 1)){
	    			output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = ( l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].left_node_index<<"] & !i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]) | (!l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].right_node_index<<"] &  i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;	
			}else if((BDD[i][j].left_node_neg == 1) && (BDD[i][j].right_node_neg == 0)){
	    			output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = (!l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].left_node_index<<"] & !i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]) | ( l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].right_node_index<<"] &  i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;	
			}
		}
	   }else if((BDD[i][j].left_node_index == -1) & (BDD[i][j].right_node_index >= 0)){
		if(BDD[i][j].right_node_neg == 0){
	    		output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = (!i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]) | ( l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].right_node_index<<"] &  i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
		}else{
	    		output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = (!i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]) | (!l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].right_node_index<<"] &  i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
		}
	   }else if((BDD[i][j].left_node_index == -2) & (BDD[i][j].right_node_index >= 0)){
		if(BDD[i][j].right_node_neg == 0){
	    		output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = ( l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].right_node_index<<"] &  i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
		}else{
	    		output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = (!l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].right_node_index<<"] &  i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
		}
	   }else if((BDD[i][j].left_node_index >= 0) & (BDD[i][j].right_node_index == -1 )){
		if(BDD[i][j].left_node_neg == 0){
	    		output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = ( l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].left_node_index<<"] & !i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]) | (      i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
		}else{
	    		output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = (!l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].left_node_index<<"] & !i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]) | (      i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
		}
	   }else if((BDD[i][j].left_node_index >= 0) & (BDD[i][j].right_node_index == -2)){
		if(BDD[i][j].left_node_neg == 0){
	    		output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = ( l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].left_node_index<<"] & !i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
		}else{
	    		output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = (!l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].left_node_index<<"] & !i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
		}
	   }else if((BDD[i][j].left_node_index == -1) & (BDD[i][j].right_node_index == -1)){
	    	output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = 1;"<<endl;
	   }else if((BDD[i][j].left_node_index == -2) & (BDD[i][j].right_node_index == -2)){
	    	output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = 0;"<<endl;
	   }else if((BDD[i][j].left_node_index == -1) & (BDD[i][j].right_node_index == -2)){
	    	output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = !i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"];"<<endl;
	   }else if((BDD[i][j].left_node_index == -2) & (BDD[i][j].right_node_index == -1)){
	    	output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    =  i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"];"<<endl;
	   }
	  }
	 }
	for (i=0;i<BDD_width_each_layer[total_BDD_depth];i++){
	 output_module_file << "assign l_"<<total_BDD_depth<<"["<<setw(6)<<i<<"]	= part_"<<BDD[total_BDD_depth][i].switch_to_which_BDD<<"["<<setw(6)<<BDD[total_BDD_depth][i].switch_to_which_node<<"];"<<endl;
	} 
}


else{
	 for (i=0;i<total_BDD_depth+1;i++){
		if(BDD_width_each_layer[i]>0)
	  		output_module_file << "wire ["<<setw(6)<<BDD_width_each_layer[i]-1<<":0] l_"<<i<<";"<<endl;
	 } 
	 output_module_file <<endl<< "assign o ["<<setw(6)<<how_many_start_nodes-1<<":0] = l_0["<<setw(6)<<how_many_start_nodes-1<<":0];"<<endl<<endl;
	 for (i=0;i<total_BDD_depth+1;i++){
	  for (j=0;j<BDD_width_each_layer[i];j++){
	   if((BDD[i][j].left_node_index >= 0) & (BDD[i][j].right_node_index >= 0)){
		if(BDD[i][j].left_node_index == BDD[i][j].right_node_index){
			if((BDD[i][j].left_node_neg == 0) && (BDD[i][j].right_node_neg == 0)){
	    			output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = ( l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].left_node_index<<"]);"<<endl;
			}else if((BDD[i][j].left_node_neg == 1) && (BDD[i][j].right_node_neg == 1)){
	    			output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = (!l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].left_node_index<<"]);"<<endl;
			}else if((BDD[i][j].left_node_neg == 0) && (BDD[i][j].right_node_neg == 1)){
	    			output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = ( l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].left_node_index<<"] ^  i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;	
			}else if((BDD[i][j].left_node_neg == 1) && (BDD[i][j].right_node_neg == 0)){
	    			output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = ( l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].left_node_index<<"] ^ !i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;	
			}
		}else{
			if((BDD[i][j].left_node_neg == 0) && (BDD[i][j].right_node_neg == 0)){
	    			output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = ( l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].left_node_index<<"] & !i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]) | ( l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].right_node_index<<"] &  i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;	
			}else if((BDD[i][j].left_node_neg == 1) && (BDD[i][j].right_node_neg == 1)){
	    			output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = (!l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].left_node_index<<"] & !i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]) | (!l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].right_node_index<<"] &  i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;	
			}else if((BDD[i][j].left_node_neg == 0) && (BDD[i][j].right_node_neg == 1)){
	    			output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = ( l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].left_node_index<<"] & !i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]) | (!l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].right_node_index<<"] &  i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;	
			}else if((BDD[i][j].left_node_neg == 1) && (BDD[i][j].right_node_neg == 0)){
	    			output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = (!l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].left_node_index<<"] & !i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]) | ( l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].right_node_index<<"] &  i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;	
			}
		}
	   }else if((BDD[i][j].left_node_index == -1) & (BDD[i][j].right_node_index >= 0)){
		if(BDD[i][j].right_node_neg == 0){
	    		output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = (!i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]) | ( l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].right_node_index<<"] &  i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
		}else{
	    		output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = (!i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]) | (!l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].right_node_index<<"] &  i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
		}
	   }else if((BDD[i][j].left_node_index == -2) & (BDD[i][j].right_node_index >= 0)){
		if(BDD[i][j].right_node_neg == 0){
	    		output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = ( l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].right_node_index<<"] &  i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
		}else{
	    		output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = (!l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].right_node_index<<"] &  i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
		}
	   }else if((BDD[i][j].left_node_index >= 0) & (BDD[i][j].right_node_index == -1 )){
		if(BDD[i][j].left_node_neg == 0){
	    		output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = ( l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].left_node_index<<"] & !i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]) | (      i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
		}else{
	    		output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = (!l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].left_node_index<<"] & !i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]) | (      i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
		}
	   }else if((BDD[i][j].left_node_index >= 0) & (BDD[i][j].right_node_index == -2)){
		if(BDD[i][j].left_node_neg == 0){
	    		output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = ( l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].left_node_index<<"] & !i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
		}else{
	    		output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = (!l_"<<i+1<<" ["<<setw(6)<<BDD[i][j].left_node_index<<"] & !i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
		}
	   }else if((BDD[i][j].left_node_index == -1) & (BDD[i][j].right_node_index == -1)){
	    	output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = 1;"<<endl;
	   }else if((BDD[i][j].left_node_index == -2) & (BDD[i][j].right_node_index == -2)){
	    	output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = 0;"<<endl;
	   }else if((BDD[i][j].left_node_index == -1) & (BDD[i][j].right_node_index == -2)){
	    	output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    = !i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"];"<<endl;
	   }else if((BDD[i][j].left_node_index == -2) & (BDD[i][j].right_node_index == -1)){
	    	output_module_file << "assign l_"<<i<<"["<<setw(6)<<j<<"]    =  i["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"];"<<endl;
	   }
	  }
	 }
	
 }
 output_module_file << endl <<"endmodule"<<endl;











//	output_module_file << "//circuit accuracy	= "<<circuit_accuracy<<endl;	
//	output_module_file << "//test amounts		= "<<parameter_test_ios<<endl;	
//	output_module_file << "//total BDD nodes	= "<<total_nodes_amount<<endl;	
//	output_module_file << "module module_output_bit_"<<which_bit_output<<"(input_data,output_bit);"<<endl<<endl;	
//	output_module_file << "input	["<<setw(6)<<parameter_input_bit_width-1<<":0]	input_data;"<<endl;	
//	output_module_file << "output		output_bit;"<<endl<<endl;
//
//
//	for (i=0;i<total_BDD_depth+1;i++){
//		output_module_file << "wire	["<<setw(6)<<BDD_width_each_layer[i]-1<<":0]	layer_"<<i<<";"<<endl;
//	}	
//	output_module_file <<endl<< "assign	output_bit = layer_0[0];"<<endl<<endl;
//	for (i=0;i<total_BDD_depth+1;i++){
//		for (j=0;j<BDD_width_each_layer[i];j++){
//			if((BDD[i][j].left_node_index >= 0) & (BDD[i][j].right_node_index >= 0)){
//				output_module_file << "assign	layer_"<<i<<"["<<setw(6)<<j<<"]   	= (layer_"<<i+1<<"	["<<setw(6)<<BDD[i][j].left_node_index<<"]	& !input_data["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"])	| (layer_"<<i+1<<"	["<<setw(6)<<BDD[i][j].right_node_index<<"]	&  input_data["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
//			}else if((BDD[i][j].left_node_index == -1) & (BDD[i][j].right_node_index >= 0)){
//				output_module_file << "assign	layer_"<<i<<"["<<setw(6)<<j<<"]   	= (			  !input_data["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"])	| (layer_"<<i+1<<"	["<<setw(6)<<BDD[i][j].right_node_index<<"]	&  input_data["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
//			}else if((BDD[i][j].left_node_index == -2) & (BDD[i][j].right_node_index >= 0)){
//				output_module_file << "assign	layer_"<<i<<"["<<setw(6)<<j<<"]   	= (layer_"<<i+1<<"	["<<setw(6)<<BDD[i][j].right_node_index<<"]	&  input_data["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
//			}else if((BDD[i][j].left_node_index >= 0) & (BDD[i][j].right_node_index == -1 )){
//				output_module_file << "assign	layer_"<<i<<"["<<setw(6)<<j<<"]   	= (layer_"<<i+1<<"	["<<setw(6)<<BDD[i][j].left_node_index<<"]	& !input_data["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"])	| (			   input_data["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
//			}else if((BDD[i][j].left_node_index >= 0) & (BDD[i][j].right_node_index == -2)){
//				output_module_file << "assign	layer_"<<i<<"["<<setw(6)<<j<<"]   	= (layer_"<<i+1<<"	["<<setw(6)<<BDD[i][j].left_node_index<<"]	& !input_data["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"]);"<<endl;
//			}else if((BDD[i][j].left_node_index == -1) & (BDD[i][j].right_node_index == -1)){
//				output_module_file << "assign	layer_"<<i<<"["<<setw(6)<<j<<"]   	= 1;"<<endl;
//			}else if((BDD[i][j].left_node_index == -2) & (BDD[i][j].right_node_index == -2)){
//				output_module_file << "assign	layer_"<<i<<"["<<setw(6)<<j<<"]   	= 0;"<<endl;
//			}else if((BDD[i][j].left_node_index == -1) & (BDD[i][j].right_node_index == -2)){
//				output_module_file << "assign	layer_"<<i<<"["<<setw(6)<<j<<"]   	= !input_data["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"];"<<endl;
//			}else if((BDD[i][j].left_node_index == -2) & (BDD[i][j].right_node_index == -1)){
//				output_module_file << "assign	layer_"<<i<<"["<<setw(6)<<j<<"]   	=  input_data["<<setw(6)<<BDD[i][j].this_layer_bit_expansion<<"];"<<endl;
//			}
//		}
//	}
//	
//	output_module_file << endl <<"endmodule"<<endl;

	return 0 ;
};
