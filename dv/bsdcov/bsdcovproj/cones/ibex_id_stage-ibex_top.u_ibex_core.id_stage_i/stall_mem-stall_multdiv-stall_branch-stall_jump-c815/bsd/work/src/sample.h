// 修改BSD的采样函数：给mask_input_data[BSD_samples-1:0][parameter_input_bit_width-1:0]赋值。
// 目前的赋值是均匀随机函数。
int64_t	BDD_class::set_random_input_data(bool** mask_input_data){
	int64_t i,j;

	random_device rd;	
	mt19937 gen(rd());
	for (int64_t i=0;i<BSD_samples;i++){
		//对于特定的case，可以直接加到文件里面:sample_input.set
		if(i<parameter_io_file_lines){
			for(int64_t j=0;j<parameter_input_bit_width;j++){
				mask_input_data[i][j] = file_inputs[i][j];
			}
		}else{
			long randint64_t;
			for(int64_t j=0;j<parameter_input_bit_width;j++){
				//int64_t zj = i*parameter_input_bit_width + j;
				//int64_t zi = 0;
				////下面是采样分布函数，目前是均匀随机	
				//zi = j%30;
				//if(zi == 0){
				//	randint64_t = gen();
				//}
				//mask_input_data[i][j] = bool((randint64_t >> (zi))%2);
				#ifdef USE_FAST_RANDOM
					mask_input_data[i][j] = get_bit(train_input_bits, long(i)*long(parameter_input_bit_width)+j);
				#else
					mask_input_data[i][j] = train_input_bits[long(i)*long(parameter_input_bit_width)+j];
				#endif
			}
			
		}
	}
	return 0;
};


