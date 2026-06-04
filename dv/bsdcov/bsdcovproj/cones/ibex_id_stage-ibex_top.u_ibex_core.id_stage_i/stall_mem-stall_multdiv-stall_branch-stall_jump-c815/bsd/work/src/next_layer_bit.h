int64_t	BDD_class::next_bit_layer(int64_t depth){
	if((depth < BSD_variable_order_depth) ){
			if(!has_been_unfold[BSD_variable_order[depth]]){
				most_influence[depth] = BSD_variable_order[depth];
				has_been_unfold[most_influence[depth]]=1;
				cout<<most_influence[depth]<<endl;
				return  BSD_variable_order[depth];
			}
			else{
				;
			}
		return next_bit_layer_0(depth);
	}
	else{
		return next_bit_layer_0(depth);
	}
}


int64_t	BDD_class::next_bit_layer_0(int64_t depth){
		
		set_random_input_data(mask_input_data_order);
	int64_t	most_influence_next=0;
	int64_t 	i,j,k;
	int64_t	zz;
	int64_t	zi;
	random_device rd;	
	mt19937 gen(rd());

	long	parameter_sample_mul = 10;
			for (j=0;j<20;j++){
				parameter_sample_mul *= 10;
				if((parameter_sample_mul * (1-total_finish_weight/pow(2.0,20))) > 10000){
					break;
				}
			}
	int64_t	BSD_samples_influence = BSD_samples_influence_max;
	bool	finish_influence_sample = 0;
	for (zz=0;zz<20*(BSD_samples_influence);zz++){
		if(zz==0){
			for (i=0;i<parameter_input_bit_width;i++){
				if((amount_turn[i] > 0) ){
					finish_influence_sample = 1;
					break;
				}
			}
		}else{
			if(depth < parameter_multi_output_index){
				break;
			}
			
			int64_t	which_node_this_layer = 0;
			int64_t	which_node_this_layer_sample = 0;
			int64_t	which_node_this_layer_array[BSD_samples_influence];
				//#pragma omp parallel for
			for (int64_t i=0;i<BSD_samples_influence;i++){
				int64_t which_node_this_layer = gen()%BDD_width_each_layer[depth];
				//for (j=0;j<parameter_input_bit_width;j++){
				//	int64_t zi = 0;
				//	long randint64_t;
				//	zi = j%30;
				//	if(zi == 0){
				//		randint64_t = gen();
				//	}
				//	if(depth == 0){
				//		mask_input_data[i][j] = bool((randint64_t >> (zi))%2);
				//	}
				//	else{
				//		if(has_been_unfold[j]){
				//			mask_input_data[i][j] = BDD_mask_this[which_node_this_layer].mask[j];
				//		}else{	
				//			mask_input_data[i][j] = bool((randint64_t >> (zi))%2);		
				//		}
				//		
				//	}
				//}	
				for (j=0;j<parameter_input_bit_width;j++){
					if(depth == 0){
						#ifdef USE_FAST_RANDOM
							mask_input_data_order[i][j] = get_bit(train_input_bits, (i+zz*BSD_samples_influence)*parameter_input_bit_width+j);
						#else
							mask_input_data_order[i][j] = train_input_bits[(i+zz*BSD_samples_influence)*parameter_input_bit_width+j];
						#endif
					}
					else{
						if(has_been_unfold[j]){
							mask_input_data_order[i][j] = BDD_mask_this[which_node_this_layer].mask[j];
						}else{	
							#ifdef USE_FAST_RANDOM
								mask_input_data_order[i][j] = get_bit(train_input_bits, (i+zz*BSD_samples_influence)*parameter_input_bit_width+j);
							#else
								mask_input_data_order[i][j] = train_input_bits[(i+zz*BSD_samples_influence)*parameter_input_bit_width+j];
							#endif
						}
						
					}
				}
				which_node_this_layer_array[i] = which_node_this_layer;
			}
			
			#pragma omp parallel for
			for (i=0;i<parameter_input_bit_width+1;i++){
				if(has_been_unfold[i] ){
					
				}else{
					for(int64_t j=0;j<BSD_samples_influence;j++){
						bool* amount_turn_input_data_ij = new bool [parameter_input_bit_width];
						for(int64_t k=0;k<parameter_input_bit_width;k++){
								amount_turn_input_data_ij[k] = mask_input_data_order[j][k];
						}
						if(i<parameter_input_bit_width)
							amount_turn_input_data_ij[i] = !amount_turn_input_data_ij[i];
						bool amount_turn_output_data_ij = io_generator_single(amount_turn_input_data_ij,BDD[depth][which_node_this_layer_array[j]].which_bit_output);
						//bool amount_turn_output_data_ij = io_generator_single(amount_turn_input_data_ij,0);
						amount_turn_output_data[i][j] = amount_turn_output_data_ij;
						arr_delete(amount_turn_input_data_ij);
					}
				}
			}
			for (i=0;i<parameter_input_bit_width;i++){
				if(has_been_unfold[i] ){
					amount_turn[i] = -1;	
				}else{
					for(j=0;j<BSD_samples_influence;j++){
						if(amount_turn_output_data[i][j] && !amount_turn_output_data[parameter_input_bit_width][j]){
							amount_turn[i] += 1;
						}
						else if(!amount_turn_output_data[i][j] && amount_turn_output_data[parameter_input_bit_width][j]){
							amount_turn[i] += 1;
						}
					}
					//USE_THIS:RANDOM
					//if(i<64)
						//amount_turn[i] = gen()%5;
					//else 
					//	amount_turn[i] = 0;
						
					//if((amount_turn[i] > 1) && ((zz*BSD_samples_influence-amount_turn[i])>1)){
					if((amount_turn[i] > 0) ){
						finish_influence_sample = 1;
					}
					
				}
				//cout<<"bit "<<i<<"	amount turn:	"<<amount_turn[i]<<"	has been unfold	"<<has_been_unfold[i]<<"should not be unfold	"<<should_not_be_unfold[i]<<endl;
			}
		}	
		if(finish_influence_sample){
			cout<<"这一层排序的采样个数为："<<zz*BSD_samples_influence<<endl;
			break;
		}
	}
			//cout<<"这一层排序的采样个数为："<<zz*BSD_samples_influence<<endl;
	double amount_turn_all = 0;
	double amount_turn_valid_bits = 0;
	int64_t	amount_turn_static[parameter_input_bit_width];
	for (i=0;i<parameter_input_bit_width;i++){
		//if(amount_turn[i]>((zz*BSD_samples_influence)/2.0)){
		//	amount_turn_static[i] = amount_turn[i];
		//}else{
			amount_turn_static[i] = amount_turn[i];
		//}
		if(amount_turn_static[i]>=1){
			cout<<"bit "<<i<<":	"<<amount_turn[i]<<endl;
			amount_turn_all = amount_turn_all + max(int64_t(1),amount_turn_static[i]);
			amount_turn_valid_bits = amount_turn_valid_bits + 1;
		}
	}
	double amount_turn_average = (amount_turn_all+1)/amount_turn_valid_bits;
	most_influence_next = max_element(amount_turn_static,amount_turn_static+parameter_input_bit_width) - amount_turn_static;	
	for (i=0;i<parameter_input_bit_width;i++){
		if(has_been_unfold[most_influence_next]){
			amount_turn_static[most_influence_next] = -10;
		}else{
			break;	//has_been_unfold[most_influence_next] = 1;
		}
		most_influence_next = max_element(amount_turn_static,amount_turn_static+parameter_input_bit_width) - amount_turn_static;
	}
	has_been_unfold[most_influence_next] = 1;
	amount_turn[most_influence_next] = -1;	
	double amount_turn_max_divide_average = amount_turn_static[most_influence_next]/amount_turn_average;
	double amount_turn_max_ratio = amount_turn[most_influence_next]/(zz+1);
	//arr_delete(	should_not_be_unfold);
	
	return	most_influence_next;
};
