

class	BDD_node{
public:
	int64_t	left_node_index		=	0;
	int64_t	right_node_index	=	0;
	int64_t	depth			=	0;
	double	weight			=	pow(2.0,20);
	bool*	mask;
	int64_t	sort_in_layer		=	0;
	bool	left_node_neg		=	0;
	bool	right_node_neg		=	0;
	int64_t	non_equal_number	=	0;
	bool	has_equal_father	=	0;
	bool*	which_root_node_all;
	int64_t	which_root_node		=	0;
	int64_t	which_bit_output	=	0;

	int64_t	this_layer_bit_expansion= 0;
	bool	switch_to_another_BDD	= 0;
	int64_t	switch_to_which_BDD	= 0;
	int64_t	switch_to_which_node	= 0;

	BDD_node(){
		which_root_node_all = new bool [parameter_output_bit_width];
		mask = new bool [parameter_input_bit_width]; 
	};
	~BDD_node(){
		arr_delete ( which_root_node_all );
		arr_delete ( mask 	); 
	};

};
class	BDD_node_mask{
public:	
	bool*	mask;
	BDD_node_mask(){
		mask = new bool [parameter_input_bit_width];
	}
	~BDD_node_mask(){
		arr_delete (mask);
	}
};
class BDD_class{
public:
	//BSD内部使用的变量（可变）
#ifdef BSD_COV_DATASET_REPLAY
	int64_t			BSD_samples 		= min(int64_t(BSD_COV_REPLAY_SAMPLES),parameter_max_samples);
	int64_t			BSD_samples_train 	= min(int64_t(BSD_COV_REPLAY_SAMPLES),parameter_max_samples);
	int64_t			BSD_samples_sort 	= min(int64_t(BSD_COV_REPLAY_SAMPLES),parameter_max_samples);
#else
	int64_t			BSD_samples 		= min(int64_t(4),parameter_max_samples);
	int64_t			BSD_samples_train 	= min(int64_t(4),parameter_max_samples);
	int64_t			BSD_samples_sort 	= min(int64_t(4),parameter_max_samples);
#endif
	const int64_t	how_often_simplify 	= 1;
	//BSD内部使用的变量（固定）
	const double	total_weight_max		= pow(2.0,20);	//指导权重分布修改
	const int64_t	total_sample_max 	= 1000000000;	//指导采样个数修改
	const int64_t	BSD_samples_influence_max 	= min(parameter_max_samples,int64_t(1));		//BSD确定展开序的置信度
	int64_t	which_demo_function ;

	int64_t	BDD_id=0;
	bool	this_is_BDD_temp = 0;	
	struct timeval	initial_start_time;
	int64_t	which_BDD = 0;
	int64_t	total_compare_times=0;
	const	int64_t	cal_data_width = min(parameter_input_bit_width/2,int64_t(32));

	int64_t i,j,zi,zj,ii,jj;

	int64_t	*	most_influence		;
	int64_t	*	BDD_width_each_layer 	;
	bool	**	mask_input_data  	;
	bool	**	mask_input_data_order  	;
	bool	*	mask_output_data 	;
	
	double		total_finish_weight = 0;
	long		total_non_equal_nodes = 0;

	BDD_node ** 	BDD 		;
	BDD_node_mask*	BDD_mask_this	;
	BDD_node_mask*	BDD_mask_next	;
	long		io_read_times;


	bool*	has_been_unfold 	;	
	//bool***	amount_turn_input_data	;
	bool**	amount_turn_output_data	;
	double*	amount_turn 		;
	
	bool	**	simplify_list ;
	int64_t	*	hash_simplify_list;

	bool	cal_infer_result(bool* input_data,int64_t which_root_node,bool neg);
	bool*	io_generator(bool* input_data,bool* output_data);
	uint64_t*	io_generator_vec(uint64_t* input_data,int64_t* output_data);
	bool	io_generator_single(bool* input_data,int64_t which_bit_output);
	uint64_t	io_generator_single_vec(uint64_t* input_data,int64_t which_bit_output);
	int64_t	set_random_input_data(bool** mask_input_data);
	int64_t	mask_random_input_data(int64_t depth,bool* mask,int64_t amount,bool** mask_input_data);
	int64_t	next_bit_layer(int64_t depth);
	int64_t	next_bit_layer_0(int64_t depth);
	int64_t	next_bit_layer_1(int64_t depth);
	int64_t	next_bit_layer_old(int64_t depth);
	int64_t	next_bit_layer_single(int64_t depth,int64_t which_node_this_layer);

	int64_t 	hash_simplify_list_function(bool* list,bool neg);
	int64_t 	compare_simplify_list(int64_t list_line_amount,bool* this_line,bool** simplify_list,int64_t* hash_simplify_list,int64_t hash_number);
	int64_t 	compare_simplify_list_neg(int64_t list_line_amount,bool* this_line,bool** simplify_list, int64_t* hash_simplify_list,int64_t hash_neg_number);
	
	long	total_nodes_amount = 0;
	long	total_split_nodes  = 0;
	long	total_nodes_amount_recursive = 0;
	long	total_split_nodes_recursive  = 0;
	int64_t	total_BDD_depth	   = 0;
	double	train_time	   = 0;	
	struct timeval	start_time,finish_time;

	int64_t	start_depth = 0;	
	int64_t	how_many_start_nodes = 32;
	BDD_node*	start_nodes;
	int64_t 	train_BDD(int64_t start_depth,int64_t how_many_start_nodes,BDD_node* start_nodes);

	double	circuit_accuracy;
	double*	circuit_accuracy_all_bits;
	int64_t	error_amount = 0;
	int64_t	error_amount_all = 0;
	int64_t	train_error  = 0;
	int64_t	incre_wrong_dataset_size = 0;
		
	bool*	test_input_data;
	bool	test_output_data;
	bool	infer_output_data;
	

	int64_t	BDD_infer();
	int64_t 	print_circuit(int64_t node_depth, char* start_node_index_string);
	int64_t	BDD_FULL_PROCESS();
	
	bool*	left_son_mask		;
	bool*	right_son_mask		;
	bool* 	left_mask_output_data	;
	bool* 	right_mask_output_data	;
	
	bool* 	left_mask_output_data_all	;
	bool* 	right_mask_output_data_all	;

		bool* all_one_left_list   ;
		bool* all_zero_left_list  ;
		bool* all_one_right_list  ;
		bool* all_zero_right_list ;
	int64_t		partition_depth = 100000;
	int64_t		partition_parts = 2;
	int64_t		partition_into_how_many_parts  =2;
	int64_t*		partition_start_node_numbers;
	int64_t**		partition_index;
	BDD_class*	BDD_partition;


	//new functions
	int64_t	BSD_samples_train_each_layer();
	int64_t	BSD_samples_sort_each_layer();

	int64_t*	BSD_variable_order;
	int64_t	BSD_variable_order_depth;
	int64_t	feature_area;

	int64_t*	split_nodes_each_layer;
	int64_t*	accuracy_each_layer;
	bool*	output_partition_set;

	node_index* start_node_index;
	char* 	    start_node_index_string ;
	//huanglue 
	void 	BSD_switch_layer(int64_t i);
	int64_t * 	BDD_split_nodes_each_layer = nullptr;
	int64_t	order_num;

	BDD_class(){
		most_influence			= new int64_t [parameter_input_bit_width+1];
		BDD_width_each_layer 		= new int64_t [parameter_input_bit_width+1];
		mask_output_data 		= new bool [parameter_max_samples*2];
		hash_simplify_list		= new int64_t  [parameter_max_BDD_width];
		BDD_mask_this			= new BDD_node_mask[parameter_max_BDD_width];
		BDD_mask_next			= new BDD_node_mask[parameter_max_BDD_width];
		has_been_unfold 		= new bool[parameter_input_bit_width+1];
		amount_turn 			= new double [parameter_input_bit_width+1];
		test_input_data 		= new bool[parameter_input_bit_width];
		left_son_mask			= new bool [parameter_input_bit_width];
		right_son_mask			= new bool [parameter_input_bit_width];
		left_mask_output_data		= new bool [parameter_max_samples];
		right_mask_output_data		= new bool [parameter_max_samples];
		left_mask_output_data_all	= new bool [long(parameter_max_BDD_width)*long(parameter_max_samples)];
		right_mask_output_data_all	= new bool [long(parameter_max_BDD_width)*long(parameter_max_samples)];
		all_one_left_list   = new bool [parameter_max_BDD_width];
		all_zero_left_list  = new bool [parameter_max_BDD_width];
		all_one_right_list  = new bool [parameter_max_BDD_width];
		all_zero_right_list = new bool [parameter_max_BDD_width];

		split_nodes_each_layer = new int64_t [parameter_input_bit_width+1];
		accuracy_each_layer    = new int64_t [parameter_input_bit_width+1];
		BSD_variable_order     = new int64_t [parameter_input_bit_width+1];
		BDD_split_nodes_each_layer = new int64_t [parameter_input_bit_width+1];
		output_partition_set  =  new bool [parameter_output_bit_width];
		start_node_index	= new node_index [parameter_output_bit_width];
		start_node_index_string = new char [parameter_output_bit_width+1];
		
		arr2d_new(mask_input_data, parameter_max_samples*2);
		arr2d_new(mask_input_data_order, parameter_max_samples*2);
		arr2d_new(simplify_list,   parameter_max_BDD_width);
		arr2d_new(BDD, 1+parameter_input_bit_width);
		arr2d_new(amount_turn_output_data, 1+parameter_input_bit_width);
	};
	
	~BDD_class(){
		arr_delete (split_nodes_each_layer );
		arr_delete (accuracy_each_layer    );
		arr_delete (BSD_variable_order     );
		arr_delete (BDD_split_nodes_each_layer );
		arr_delete (output_partition_set  );
		//arr_delete (start_node_index	);
		arr_delete (start_node_index_string	);
		arr_delete (start_node_index_string );
	
		arr_delete (most_influence		)	; 
		arr_delete ( BDD_width_each_layer 	)	; 
		arr_delete ( mask_output_data 		)	; 
		arr_delete ( hash_simplify_list		)	; 
		arr_delete ( BDD_mask_this		)	; 
		arr_delete ( BDD_mask_next		)	; 
		arr_delete ( has_been_unfold 		)	; 
		arr_delete ( amount_turn 		)	; 
		arr_delete ( test_input_data 		)	; 
		arr_delete ( left_son_mask		)	; 
		arr_delete ( right_son_mask		)	; 
		arr_delete ( left_mask_output_data	)	; 
		arr_delete ( right_mask_output_data	)	; 
		arr_delete ( left_mask_output_data_all	)	; 
		arr_delete ( right_mask_output_data_all	)	; 
		arr_delete ( all_one_left_list   	)	; 
		arr_delete ( all_zero_left_list  	)	; 
		arr_delete ( all_one_right_list  	)	; 
		arr_delete ( all_zero_right_list 	)	; 
		arr2d_delete(mask_input_data, parameter_max_samples*2);
		arr2d_delete(mask_input_data_order, parameter_max_samples*2);
		arr2d_delete(simplify_list,   parameter_max_BDD_width);
		arr2d_delete(BDD, 1+parameter_input_bit_width);
		arr2d_delete(amount_turn_output_data, 1+parameter_input_bit_width);

		};


};
int64_t	BDD_class::BSD_samples_train_each_layer(){
		int64_t	BSD_samples_train;
		if(total_finish_weight/((pow(2.0,20)*how_many_start_nodes)) > 0.9999999999){
			BSD_samples_train = 64;
			if(total_finish_weight/((pow(2.0,20)*how_many_start_nodes)) > 1){
				BSD_samples_train = 64;
			}
		}else{
			BSD_samples_train = max(int64_t(64),min(int64_t(total_sample_max * (1-total_finish_weight/(pow(2.0,20)*how_many_start_nodes))),parameter_max_samples-1));
		}
		cout<<"BSD train samples:	"<<BSD_samples_train<<endl;
		return BSD_samples_train;
}
int64_t	BDD_class::BSD_samples_sort_each_layer(){
		return BSD_samples_sort;
}


bool	BDD_class::io_generator_single(bool* input_data,int64_t which_bit_output){

	//int64_t	origin_which_bit_output = this->start_node_index[which_bit_output].root_node_index;
	//for (int64_t i=0;i<this->start_node_index[which_bit_output].node_depth;i++){
	//	input_data[this->start_node_index[which_bit_output].expand_input_bit_index[i]] = this->start_node_index[which_bit_output].expand_input_bit_data[i];
	//}
	#ifdef SINGLE_BITS	
		//if (output_partition_set[which_bit_output]==1){
			bool output_bit_s =  io_generator_outer_single( input_data,  which_bit_output) ;
			return output_bit_s;
		//}else{
		//	return 0;
		//}
	#else
		bool	output_bit;
		bool*	output_bits = new bool [parameter_output_bit_width];
		//if (output_partition_set[which_bit_output]==1){
					output_bits 	= io_generator_function(input_data,output_bits);
					output_bit = output_bits[which_bit_output] ;
		//}
		//else
		//			output_bit = 0;
		arr_delete(output_bits);
		return	output_bit;
	#endif
};
#ifdef INPUT_AIG

uint64_t	BDD_class::io_generator_single_vec(uint64_t* input_data,int64_t which_bit_output){
	
	///int64_t	origin_which_bit_output = this->start_node_index[which_bit_output].root_node_index;
	///for (int64_t i=0;i<this->start_node_index[which_bit_output].node_depth;i++){
	///	if(this->start_node_index[which_bit_output].expand_input_bit_data[i] == 0)
	///		input_data[this->start_node_index[which_bit_output].expand_input_bit_index[i]] = uint64_t(0);
	///	else
	///		input_data[this->start_node_index[which_bit_output].expand_input_bit_index[i]] = ~uint64_t(0);
	///}
	#ifdef SINGLE_BITS	
		//if (output_partition_set[which_bit_output]==1){
			uint64_t  output_bit_s =  io_generator_outer_vec_single( input_data, which_bit_output) ;
			return output_bit_s;
		//}else
		//	return 0;
	#else
		uint64_t	output_bit;
		uint64_t*	output_bits = new uint64_t [parameter_output_bit_width];
		//if (output_partition_set[which_bit_output]==1){
					output_bits 	= io_generator_function_vec(input_data,output_bits);
					output_bit = output_bits[which_bit_output] ;
		//}
		//else
		//			output_bit = 0;
		arr_delete(output_bits);
		return	output_bit;
	#endif
};
#endif



int64_t BDD_class::train_BDD(int64_t start_depth, int64_t how_many_start_nodes, BDD_node* start_nodes){

	int64_t i,j;
	int64_t zi;
	bool	left_son_neg;
	bool	right_son_neg;

		
	int64_t	which_list_number; 	
	int64_t	which_list_number_neg;

	bool	all_zero_left  ;
	bool	all_one_left   ;
	bool	all_one_right  ;
	bool	all_zero_right ;

	int64_t	first_one_left 		;
	int64_t	first_zero_left 	;
	int64_t	first_one_right 	;
	int64_t	first_zero_right 	;
	int64_t	which_cluster;
	bool	it_cannot_simplify 	;
	bool	it_can_simplify 	;
	bool	it_can_simplify_neg 	;
	double  all_train_time;
	int64_t*	root_nodes_leafs = new int64_t [how_many_start_nodes];
	int64_t*	leaf_nodes_roots = new int64_t [how_many_start_nodes];

	feature_area=0;

		//cout<<"Train BDD	"<<endl;
	for(i=0;i<start_depth+1;i++)	
		BDD[i] 		= new BDD_node[how_many_start_nodes];
	//out<<"New nodes	"<<endl;
	for (i=0;i<how_many_start_nodes;i++){
		BDD[start_depth][i].which_bit_output = start_nodes[i].which_bit_output;
		BDD[start_depth][i].which_root_node  = start_nodes[i].which_root_node;
		for(zi=0;zi<how_many_start_nodes;zi++){
			BDD[start_depth][i].which_root_node_all[zi] = 0;
		}		
		BDD[start_depth][i].which_root_node_all[i] = 1;
		for (zi=0;zi<parameter_input_bit_width;zi++){
			BDD[start_depth][i].mask[zi] 	= start_nodes[i].mask[zi];
			BDD_mask_this[i].mask[zi] 	= start_nodes[i].mask[zi];
		}
	}
	//cout<<"Initial nodes	"<<endl;
	total_finish_weight = 0;

	BDD_width_each_layer[start_depth] = how_many_start_nodes;
	total_BDD_depth	   = 0;
	train_time	   = 0;
	
	for(int64_t i=0;i<parameter_input_bit_width+1;i++)
		amount_turn[i] = 0;
	
	for(i=start_depth;i</*parameter_early_stop_depth*/parameter_input_bit_width+1;i++){
#ifndef BSD_COV_DATASET_REPLAY
		set_random_train();
#endif
		cout<<"BSD input bit sequence :	";
		for(int64_t zi=0;zi<i;zi++){
			cout<<most_influence[zi]<<" ";
		}
		cout<<endl;
	
		if(i>start_depth){	
			for(j=0;j<BDD_width_each_layer[i];j++){
				for (zi=0;zi<parameter_input_bit_width;zi++){
					BDD[i][j].mask[zi] 		= BDD_mask_next[j].mask[zi];
					BDD_mask_this[j].mask[zi] 	= BDD_mask_next[j].mask[zi];
				}	
			}
		}
		total_nodes_amount_recursive 	= total_nodes_amount;
		total_split_nodes_recursive 	= total_split_nodes;
		feature_area += total_nodes_amount; 
		bool this_layer_need_partition = (i==partition_depth);
		//cout<<"Start partition check	";
		if(this_layer_need_partition){
			cout<<"go for partition"<<endl;
			partition_into_how_many_parts	= min(int64_t(2),int64_t(partition_parts));
			BDD_partition 			= new BDD_class [partition_into_how_many_parts];
			partition_start_node_numbers 	= new int64_t  [partition_into_how_many_parts];
			partition_index 		= new int64_t* [partition_into_how_many_parts];
			
			for(zi=0;zi<partition_into_how_many_parts;zi++){
				partition_start_node_numbers[zi] = 0;
				for(int64_t zj = 0; zj < BDD_width_each_layer[i];zj++){
					//if(BDD[i][zj].mask[most_influence[i-1]] == zi){
					if(zj%partition_into_how_many_parts==zi){
						partition_start_node_numbers[zi] += 1;;
					}
				}
			}
			cout<<"finish partition node numbers	"<<partition_start_node_numbers[0]<<"	"<<partition_start_node_numbers[1]<<endl;	
				for(int64_t zi=0;zi<partition_into_how_many_parts;zi++){	
					partition_index[zi] = new int64_t [partition_start_node_numbers[zi]];
					int64_t counter = 0;
					for(int64_t zj=0;zj<BDD_width_each_layer[i];zj++){
						//if(BDD[i][zk].mask[most_influence[i-1]] == zj){
						if(zj%partition_into_how_many_parts==zi){
							partition_index[zi][counter] = zj;
							counter += 1;
						}
					}
				}
			cout<<"finish partition index"<<endl;	
			for(zi=0;zi<partition_into_how_many_parts;zi++){
				BDD_partition[zi].start_depth = i;	
				BDD_partition[zi].how_many_start_nodes = partition_start_node_numbers[zi];
				BDD_partition[zi].which_demo_function 	= 3;
				BDD_partition[zi].start_nodes = new BDD_node [BDD_partition[zi].how_many_start_nodes];
				for(int64_t zj=0;zj<parameter_input_bit_width+1;zj++){
					BDD_partition[zi].has_been_unfold[zj] 	= has_been_unfold[zj];
					BDD_partition[zi].most_influence[zj] 	= most_influence[zj];
					BDD_partition[zi].BSD_variable_order[zj] 	= BSD_variable_order[zj];
				}
				for(int64_t zj=0;zj<BDD_partition[zi].how_many_start_nodes;zj++){
					if(partition_index[zi][zj] < BDD_width_each_layer[i]){
						BDD_partition[zi].start_nodes[zj].which_bit_output 	= BDD[i][partition_index[zi][zj]].which_bit_output;
						BDD_partition[zi].start_nodes[zj].which_root_node  	= BDD[i][partition_index[zi][zj]].which_root_node;
						for (int64_t zk=0;zk<parameter_input_bit_width;zk++){
							BDD_partition[zi].start_nodes[zj].mask[zk]	= BDD_mask_this[partition_index[zi][zj]].mask[zk];
							BDD_partition[zi].BDD_mask_this[zj].mask[zk] 	= BDD_mask_this[partition_index[zi][zj]].mask[zk];
						}
					}
				}
				for(int64_t zj=0;zj<parameter_input_bit_width+1;zj++){
					BDD_partition[zi].BDD_width_each_layer[zj] = BDD_width_each_layer[zj];
				}
				//if(!this_is_BDD_temp){	
					BDD_partition[zi].partition_depth = 100000;
					
			}
				//	for (zj=0;zj<parameter_max_samples;zj++){
				//		delete [] mask_input_data[j];
				//	}
							
			
			for(j=0;j<BDD_width_each_layer[i];j++){
				BDD[i][j].switch_to_another_BDD = 1;
				for(zi=0;zi<partition_into_how_many_parts;zi++){
					for(int64_t zj=0;zj<BDD_partition[zi].how_many_start_nodes;zj++){
						if(partition_index[zi][zj] == j){
							BDD[i][j].switch_to_which_BDD 	= zi;
							BDD[i][j].switch_to_which_node 	= zj;
						}
					}
				}
			}		
			total_BDD_depth = i;
			cout<<"BDD partition on layer "<<i<<endl;
			
					///for (int64_t zj=0;zj<parameter_input_bit_width+1;zj++){
					///	delete [] amount_turn_output_data[zj] ;
					///}
					///for (int64_t zj=0;zj<parameter_max_BDD_width;zj++){
					///	delete [] simplify_list[zj];
					///}
					///for (int64_t zj=0;zj<parameter_max_samples;zj++){
					///	delete [] mask_input_data[zj] ;
					///}
					///for(int64_t zj=0;zj<partition_into_how_many_parts;zj++){
					///	delete [] partition_index[zj];
					///	
					///}
					///delete [] amount_turn_output_data	;
					///delete [] amount_turn 			;
					///delete [] left_mask_output_data		;
					///delete [] right_mask_output_data	;
					///delete [] left_mask_output_data_all	;
					///delete [] right_mask_output_data_all	;
					///delete []left_son_mask			;
					///delete []right_son_mask			;
					///delete [] BDD_mask_this			;
					///delete [] BDD_mask_next			;
					///delete [] simplify_list			;
					///delete [] hash_simplify_list;
					///delete [] mask_input_data;

					///delete [] split_nodes_each_layer;
					///delete [] accuracy_each_layer   ;
					///delete []BSD_variable_order     ;

			for(zi=0;zi<partition_into_how_many_parts;zi++){
					BDD_partition[zi].BDD_FULL_PROCESS();
					total_nodes_amount_recursive 	+= BDD_partition[zi].total_nodes_amount_recursive;	
					total_split_nodes_recursive 	+= BDD_partition[zi].total_split_nodes_recursive;	
				//}
			}
			cout<<"BSD total split nodes recursive = " << total_split_nodes_recursive <<endl;
			break;
		}	
		

		//cout<<"Finish partition check	"<<endl;
		BSD_samples_train = BSD_samples_train_each_layer();
		BSD_samples_sort  = BSD_samples_sort_each_layer();
		
	
		if((BDD_width_each_layer[i]==0)){
			total_BDD_depth = i;
			cout<<"total BDD depth:	"<<total_BDD_depth<<endl;
			break;
		}
		
		total_nodes_amount += BDD_width_each_layer[i];

		//cout<<"New BSD nodes start	"<<BDD_width_each_layer[i]<<endl;
		BDD[i+1] 	= new BDD_node[BDD_width_each_layer[i]*2];
		
		cout<<"New BSD nodes finish	"<<endl;
		for(zi=0;zi<BDD_width_each_layer[i]*2;zi++){
			BDD[i+1][zi].has_equal_father = 0;
			BDD[i+1][zi].non_equal_number = 0;
		}
		BSD_samples = BSD_samples_sort;
		cout<<"next bit layer start	"<<endl;
		most_influence[i] = next_bit_layer(i);
		cout<<"next bit layer finish	"<<endl;
 
			BSD_samples = int64_t(BSD_samples_train/63)*63; //一定要是vec_length的整数倍
		cout<<BSD_samples<<endl;
		cout<<"The BSD is on layer: "<<i<<"		";
		cout<<"The input bit is: x"<<most_influence[i]<<endl;
		cout<<"BSD width at this layer: "<<BDD_width_each_layer[i]<<endl;
		cout<<"set random input data finish	"<<endl;
#ifdef BSD_COV_DATASET_REPLAY
		#pragma omp parallel for
		for(long j=0;j<BDD_width_each_layer[i];j++){
			bsd_cov_fill_branch_outputs(
				BDD_mask_this[j].mask,
				most_influence,
				i,
				most_influence[i],
				BDD[i][j].which_bit_output,
				BSD_samples,
				&left_mask_output_data_all[BSD_samples*j],
				&right_mask_output_data_all[BSD_samples*j]
			);
		}
#else
		set_random_input_data(mask_input_data);
	 #ifdef INPUT_AIG
			int64_t vec_length=63;
		#pragma omp parallel for 
		for(long zk=0;zk<int64_t(BDD_width_each_layer[i]*int64_t(BSD_samples/vec_length));zk++){
			bool** vec_input_left  = new bool* [parameter_input_bit_width];
			bool** vec_input_right = new bool* [parameter_input_bit_width];
			for(int64_t kk=0;kk<parameter_input_bit_width;kk++){
				vec_input_left[kk]	= new bool [64];
				vec_input_right[kk]	= new bool [64];
			}
			uint64_t* vec_input_left_int64_t  = new uint64_t [parameter_input_bit_width];
			uint64_t* vec_input_right_int64_t = new uint64_t [parameter_input_bit_width];
			int64_t start_zj = vec_length*zk;
			int64_t j  	= int64_t(start_zj/BSD_samples);
			for(int64_t kk=0;kk<64;kk++){
				if(kk<vec_length){
					long zj= start_zj+kk;
					int64_t zi = int64_t(zj%BSD_samples);
					for (int64_t jj=0;jj<parameter_input_bit_width;jj++){
						vec_input_left [jj][kk] = mask_input_data[zi][jj];
						vec_input_right[jj][kk] = mask_input_data[zi][jj];
					}
					for (int64_t jj=0;jj<i;jj++){
						vec_input_left [most_influence[jj]][kk] = BDD_mask_this[j].mask[most_influence[jj]];
						vec_input_right[most_influence[jj]][kk] = BDD_mask_this[j].mask[most_influence[jj]];
					}
						vec_input_left [most_influence[i]][kk] = 0;
						vec_input_right[most_influence[i]][kk] = 1;
				}else{
					for (int64_t jj=0;jj<parameter_input_bit_width;jj++){
						vec_input_left [jj][kk] = 0;
						vec_input_right[jj][kk] = 0;
					}
				}
			}
			for(int64_t kk=0;kk<parameter_input_bit_width;kk++){
				 vec_input_left_int64_t[kk]  = cvt_bit_to_number_unsigned(vec_input_left[kk],64);
				 vec_input_right_int64_t[kk] = cvt_bit_to_number_unsigned(vec_input_right[kk],64);
			}
			uint64_t vec_output_left_int64_t  ;
			uint64_t vec_output_right_int64_t ;
			vec_output_left_int64_t  = io_generator_single_vec(vec_input_left_int64_t ,BDD[i][j].which_bit_output);
			vec_output_right_int64_t = io_generator_single_vec(vec_input_right_int64_t,BDD[i][j].which_bit_output);
			bool* vec_output_left  = new bool [64];
			bool* vec_output_right = new bool [64];
			cvt_number_to_bit_unsigned(vec_output_left,vec_output_left_int64_t,64);
			cvt_number_to_bit_unsigned(vec_output_right,vec_output_right_int64_t,64);

			
			for(int64_t zj=0;zj<vec_length;zj++){
					right_mask_output_data_all[zj+start_zj] = vec_output_right[(zj)];
					left_mask_output_data_all [zj+start_zj] = vec_output_left [(zj)];
			}
			arr2d_delete (vec_input_left,parameter_input_bit_width) ;
			arr2d_delete (vec_input_right,parameter_input_bit_width) ;
			arr_delete(vec_output_left );
			arr_delete(vec_output_right);
			arr_delete(vec_input_left_int64_t)  ;
			arr_delete(vec_input_right_int64_t) ;
				
	 	}
	#else
		#pragma omp parallel for 
		for(long zj=0;zj<BDD_width_each_layer[i]*BSD_samples;zj++){
			int64_t j  = int64_t(zj/BSD_samples);
			int64_t zi = int64_t(zj%BSD_samples);
				bool mask_input_data_left [parameter_input_bit_width]; 
				bool mask_input_data_right[parameter_input_bit_width]; 
				for (int64_t jj=0;jj<parameter_input_bit_width;jj++){
					mask_input_data_left [jj] = mask_input_data[zi][jj];
					mask_input_data_right[jj] = mask_input_data[zi][jj];
				}
				for (int64_t jj=0;jj<i;jj++){
					mask_input_data_left [most_influence[jj]] = BDD_mask_this[j].mask[most_influence[jj]];
					mask_input_data_right[most_influence[jj]] = BDD_mask_this[j].mask[most_influence[jj]];
				}
					mask_input_data_left [most_influence[i]] = 0;
					mask_input_data_right[most_influence[i]] = 1;
				bool left_mask_output_data_b  = io_generator_single(mask_input_data_left ,BDD[i][j].which_bit_output);
				/////if(zj<100){
				/////	for (int64_t jj=0;jj<parameter_input_bit_width;jj++){
				/////		cout<<mask_input_data_left[jj];
				/////	}
				/////	cout<<"		"<<left_mask_output_data_b<<endl;
				/////}
				bool right_mask_output_data_b = io_generator_single(mask_input_data_right,BDD[i][j].which_bit_output);
				/////if(zj<100){
				/////	for (int64_t jj=0;jj<parameter_input_bit_width;jj++){
				/////		cout<<mask_input_data_right[jj];
				/////	}
				/////	cout<<"		"<<right_mask_output_data_b<<endl;
				/////}
				right_mask_output_data_all[zj] = right_mask_output_data_b;
				left_mask_output_data_all [zj] =  left_mask_output_data_b;
				
	 	}

	#endif

#endif
		cout<<"Finish sampling IOs"<<endl;
		gettimeofday(&finish_time,NULL);
		train_time = double(finish_time.tv_usec-start_time.tv_usec+1000000*(finish_time.tv_sec-start_time.tv_sec))/1000000;
		cout<<"BSD  "<<BDD_id<<" train time = "<<train_time<<"s"<<endl;
		
		
		//#pragma omp parallel for 
		for(int64_t j=0;j<BDD_width_each_layer[i];j++){
			int64_t left_zeros = 0;
			int64_t left_ones = 0;
			int64_t right_zeros = 0;
			int64_t right_ones = 0;
			bool* left_mask_output_data_tmp = new bool [BSD_samples];
			bool* right_mask_output_data_tmp = new bool [BSD_samples];
			if((i == (parameter_early_stop_depth-1))&&(which_BDD==0) || ((i == (parameter_early_stop_depth-1))&&(which_BDD==1)) || ((total_split_nodes_recursive) > parameter_early_stop_split_nodes-BDD_width_each_layer[i])){
				cout<<"Early Stop: Condition A	"<<endl;
				for(int64_t zi=0;zi<min(BSD_samples,int64_t(100));zi++){
					left_mask_output_data_tmp[zi]  =  left_mask_output_data_all[zi+BSD_samples*j];
					if(left_mask_output_data_tmp[zi]){
						left_ones += 1;
					}else{
						left_zeros += 1;
					}
				}
				for(int64_t zi=0;zi<min(BSD_samples,int64_t(100));zi++){
					right_mask_output_data[zi] = right_mask_output_data_all[zi+BSD_samples*j];
					if(right_mask_output_data_tmp[zi]){
						right_ones += 1;
					}else{
						right_zeros += 1;
					}
				}

				if(left_ones > left_zeros){
					all_one_left_list[j] 	= 1;
					all_zero_left_list[j]	= 0;
				}else{
					all_one_left_list[j] 	= 0;
					all_zero_left_list[j]	= 1;
				}
				if(right_ones > right_zeros){
					all_one_right_list[j] 	= 1;
					all_zero_right_list[j]	= 0;
				}else{
					all_one_right_list[j] 	= 0;
					all_zero_right_list[j]	= 1;
				}
			}else if((BDD_width_each_layer[i] > parameter_max_BDD_width/2) ){
				//cout<<"Early Stop: Condition B	"<<endl;
				cout<<"which node this layer:	"<<j<<endl;
				cout<<"		Finish trained weight =  "<<setprecision(12)<<(total_finish_weight)/pow(2.0,20)<<endl;
				for(int64_t zi=0;zi<min(BSD_samples,int64_t(10));zi++){
					if(left_mask_output_data_tmp[zi]){
						left_ones += 1;
					}else{
						left_zeros += 1;
					}
				}
				for(int64_t zi=0;zi<min(BSD_samples,int64_t(100));zi++){
					if(right_mask_output_data_tmp[zi]){
						right_ones += 1;
					}else{
						right_zeros += 1;
					}
				}

				if(left_ones > left_zeros){
					all_one_left_list[j] 	= 1;
					all_zero_left_list[j]	= 0;
				}else{
					all_one_left_list[j] 	= 0;
					all_zero_left_list[j]	= 1;
				}
				if(right_ones > right_zeros){
					all_one_right_list[j] 	= 1;
					all_zero_right_list[j]	= 0;
				}else{
					all_one_right_list[j] 	= 0;
					all_zero_right_list[j]	= 1;
				}
			}else if(parameter_early_stop_accuracy < double(1-double(1/BSD_samples))){
				int64_t how_many_zeros_left = 0;
				int64_t how_many_ones_left  = 0;
				int64_t how_many_zeros_right= 0;
				int64_t how_many_ones_right = 0;
				for(int64_t zi=0;zi<BSD_samples;zi++){
					left_mask_output_data_tmp[zi]   =   left_mask_output_data_all[zi+BSD_samples*j];
					right_mask_output_data_tmp[zi]  =  right_mask_output_data_all[zi+BSD_samples*j];
					if(left_mask_output_data_tmp[zi]){
						how_many_ones_left += 1;
					}
					if(right_mask_output_data_tmp[zi]){
						how_many_ones_right += 1;
					}
				}
				how_many_zeros_left  = BSD_samples - how_many_ones_left;
				how_many_zeros_right = BSD_samples - how_many_ones_right;
				all_zero_left_list[j] 	= 0;
				all_one_left_list[j] 	= 0;
				all_zero_right_list[j] 	= 0;
				all_one_right_list[j] 	= 0;
				double early_stop_accuracy_node = 1 - (1-parameter_early_stop_accuracy)/double(1);
				if(parameter_early_stop_oneway){
					if(how_many_zeros_left == BSD_samples)
						all_zero_left_list[j] 	= 1;
					else if(double(how_many_ones_left)/double(BSD_samples) > parameter_early_stop_accuracy)
						all_one_left_list[j] 	= 1;
					if(how_many_zeros_right == BSD_samples)
						all_zero_right_list[j] 	= 1;
					else if(double(how_many_ones_right)/double(BSD_samples) > parameter_early_stop_accuracy)
						all_one_right_list[j] 	= 1;

				}
				else{
					if(double(how_many_zeros_left)/double(BSD_samples) > parameter_early_stop_accuracy)
						all_zero_left_list[j] 	= 1;
					else if(double(how_many_ones_left)/double(BSD_samples) > parameter_early_stop_accuracy)
						all_one_left_list[j] 	= 1;
					if(double(how_many_zeros_right)/double(BSD_samples) > parameter_early_stop_accuracy)
						all_zero_right_list[j] 	= 1;
					else if(double(how_many_ones_right)/double(BSD_samples) > parameter_early_stop_accuracy)
						all_one_right_list[j] 	= 1;
				}

				
			}
			else {
						all_zero_left_list[j] 	= 1;
						all_one_left_list[j] 	= 1;
						all_zero_right_list[j] 	= 1;
						all_one_right_list[j] 	= 1;
				for(int64_t zi=0;zi<BSD_samples;zi++){
					left_mask_output_data_tmp[zi]  =  left_mask_output_data_all[zi+BSD_samples*j];
					//if(zi<100)
					//cout<<left_mask_output_data_tmp[zi];
					if(left_mask_output_data_tmp[zi]){
						all_zero_left_list[j] 	= 0;
					}else{
						all_one_left_list[j] 	= 0;
					}
					if((!all_zero_left_list[j])&&(!all_one_left_list[j])){
						break;
					}
				}
				//cout<<endl;
				//cout<<endl;
				for(int64_t zi=0;zi<BSD_samples;zi++){
					right_mask_output_data_tmp[zi] = right_mask_output_data_all[zi+BSD_samples*j];
					//if(zi<100)
					//cout<<right_mask_output_data_tmp[zi];
					if(right_mask_output_data_tmp[zi]){
						all_zero_right_list[j] 		= 0;
					}else{
						all_one_right_list[j] 		= 0;
					}
					if((!all_zero_right_list[j])&&(!all_one_right_list[j])){
						break;
					}
				}
				//cout<<endl;
						//cout<<"all zero  left"<<all_zero_left_list[j] 	<<endl;
						//cout<<"all one   left"<<all_one_left_list[j] 	<<endl;
						//cout<<"all zero right"<<all_zero_right_list[j] 	<<endl;
						//cout<<"all one  right"<<all_one_right_list[j] 	<<endl;
			}
			arr_delete( left_mask_output_data_tmp );
			arr_delete( right_mask_output_data_tmp);
		}

		cout<<"Finish all one all zero compare "<<endl;
		gettimeofday(&finish_time,NULL);
		train_time = double(finish_time.tv_usec-start_time.tv_usec+1000000*(finish_time.tv_sec-start_time.tv_sec))/1000000;
		cout<<"BSD  "<<BDD_id<<" train time = "<<train_time<<"s"<<endl;
		for(int64_t j=0;j<BDD_width_each_layer[i];j++){
		
			BDD[i][j].this_layer_bit_expansion = most_influence[i];	
			
			if(BDD[i][j].has_equal_father){
				;
			}else{
				BDD[i][j].non_equal_number = total_non_equal_nodes;
				total_non_equal_nodes += 1;
			}
			//cout<<j<<"	Debug 1"<<"	";
			for(zi=0;zi<i;zi++){
				left_son_mask[most_influence[zi]] 	= BDD_mask_this[j].mask[most_influence[zi]]; 
				right_son_mask[most_influence[zi]] 	= BDD_mask_this[j].mask[most_influence[zi]]; 
			}
			left_son_mask[most_influence[i]] 	= 0;
			right_son_mask[most_influence[i]] 	= 1;
			
			bool all_zero_left  =  all_zero_left_list[j]  ;
			bool all_one_left   =  all_one_left_list[j]   ;
			bool all_one_right  =  all_one_right_list[j]  ;
			bool all_zero_right =  all_zero_right_list[j] ;
	
			for(int64_t zi=0;zi<BSD_samples;zi++){
				left_mask_output_data[zi]  =  left_mask_output_data_all[zi+BSD_samples*j];
				right_mask_output_data[zi] = right_mask_output_data_all[zi+BSD_samples*j];
			}
			//cout<<"Debug 2"<<"	"<<endl;
			///int64_t left_zeros = 0;
			///int64_t left_ones = 0;
			///int64_t right_zeros = 0;
			///int64_t right_ones = 0;
			///for(int64_t zi=0;zi<min(BSD_samples,10);zi++){
			///	if(left_mask_output_data[zi]){
			///		left_ones += 1;
			///	}else{
			///		left_zeros += 1;
			///	}
			///}
			///for(int64_t zi=0;zi<min(BSD_samples,10);zi++){
			///	if(right_mask_output_data[zi]){
			///		right_ones += 1;
			///	}else{
			///		right_zeros += 1;
			///	}
			///}
			//cout<<"Debug 3"<<"	";
			
			//cout<<"Debug 4"<<"	";
			int64_t hash_left_number 		= hash_simplify_list_function(left_mask_output_data,0);
			int64_t hash_left_neg_number 	= hash_simplify_list_function(left_mask_output_data,1);
			int64_t hash_right_number 		= hash_simplify_list_function(right_mask_output_data,0);
			int64_t hash_right_neg_number 	= hash_simplify_list_function(right_mask_output_data,1);
			if(i>parameter_multi_output_index-1){
				if(all_zero_left){
						//cout<<"all zero  left"<<all_zero_left 	<<endl;
					BDD[i][j].left_node_index = -2;
					total_finish_weight += BDD[i][j].weight/2;
				}else if(all_one_left){
						//cout<<"all one   left"<<all_one_left 	<<endl;
					BDD[i][j].left_node_index = -1; 
					total_finish_weight += BDD[i][j].weight/2;
				}else{
					if(((i%how_often_simplify) == 0)){
						which_list_number 	= compare_simplify_list    (BDD_width_each_layer[i+1],left_mask_output_data,simplify_list,hash_simplify_list,hash_left_number);
						which_list_number_neg 	= compare_simplify_list_neg(BDD_width_each_layer[i+1],left_mask_output_data,simplify_list,hash_simplify_list,hash_left_neg_number);
						it_cannot_simplify 	= (which_list_number < 0)&&(which_list_number_neg<0);
						it_can_simplify 	= (which_list_number 		>=0);
						it_can_simplify_neg 	= (which_list_number_neg	>=0);
						if((it_can_simplify_neg == 0) && (it_can_simplify == 0)){
							it_cannot_simplify = 1;
						}
						if(it_cannot_simplify){
							BDD_width_each_layer[i+1] += 1;
							BDD[i+1][BDD_width_each_layer[i+1]-1].depth  = i+1; 
							BDD[i+1][BDD_width_each_layer[i+1]-1].weight = BDD[i][j].weight/2;
							for(zi=0;zi<how_many_start_nodes;zi++){
								BDD[i+1][BDD_width_each_layer[i+1]-1].which_root_node_all[zi] = BDD[i][j].which_root_node_all[zi]; 
							} 
							BDD[i+1][BDD_width_each_layer[i+1]-1].which_root_node = BDD[i][j].which_root_node; 
							BDD[i+1][BDD_width_each_layer[i+1]-1].which_root_node = BDD[i][j].which_root_node; 
							BDD[i+1][BDD_width_each_layer[i+1]-1].which_bit_output = BDD[i][j].which_bit_output; 
							for (zi=0;zi<i+1;zi++){
								BDD_mask_next[BDD_width_each_layer[i+1]-1].mask[most_influence[zi]]  = left_son_mask[most_influence[zi]]; 
							}
							BDD[i][j].left_node_index = 	BDD_width_each_layer[i+1]-1;
							BDD[i][j].left_node_neg   = 	0;
							for (zi=0;zi<BSD_samples;zi++){
								simplify_list[BDD_width_each_layer[i+1]-1][zi] = left_mask_output_data[zi];
							}
							hash_simplify_list[BDD_width_each_layer[i+1]-1] = hash_left_number;
						}else if(it_can_simplify){
							BDD[i][j].left_node_index = 	which_list_number;
							BDD[i][j].left_node_neg   = 	0;
							BDD[i+1][which_list_number].weight += BDD[i][j].weight/2;
							for(zi=0;zi<how_many_start_nodes;zi++){
								BDD[i+1][which_list_number].which_root_node_all[zi] |= BDD[i][j].which_root_node_all[zi]; 
							} 
						}else if(it_can_simplify_neg){
							BDD[i][j].left_node_index = 	which_list_number_neg;
							BDD[i][j].left_node_neg   = 	1;
							BDD[i+1][which_list_number_neg].weight += BDD[i][j].weight/2;
							for(zi=0;zi<how_many_start_nodes;zi++){
								BDD[i+1][which_list_number_neg].which_root_node_all[zi] |= BDD[i][j].which_root_node_all[zi]; 
							}
						}
					}else{
						BDD_width_each_layer[i+1] += 1;
						BDD[i+1][BDD_width_each_layer[i+1]-1].depth = i+1; 
						BDD[i+1][BDD_width_each_layer[i+1]-1].weight = BDD[i][j].weight/2; 
						BDD[i+1][BDD_width_each_layer[i+1]-1].which_root_node = BDD[i][j].which_root_node; 
						BDD[i+1][BDD_width_each_layer[i+1]-1].which_bit_output = BDD[i][j].which_bit_output; 
						for(zi=0;zi<how_many_start_nodes;zi++){
							BDD[i+1][BDD_width_each_layer[i+1]-1].which_root_node_all[zi] = BDD[i][j].which_root_node_all[zi]; 
						} 
						for (zi=0;zi<i+1;zi++){
							BDD_mask_next[BDD_width_each_layer[i+1]-1].mask[most_influence[zi]]  = left_son_mask[most_influence[zi]]; 
						}
						BDD[i][j].left_node_index = 	BDD_width_each_layer[i+1]-1;
						BDD[i][j].left_node_neg   = 	0;
						
					}
				}
			}else{			
						BDD_width_each_layer[i+1] += 1;
						BDD[i+1][BDD_width_each_layer[i+1]-1].depth = i+1; 
						BDD[i+1][BDD_width_each_layer[i+1]-1].weight = BDD[i][j].weight/2; 
						BDD[i+1][BDD_width_each_layer[i+1]-1].which_root_node = BDD[i][j].which_root_node; 
						BDD[i+1][BDD_width_each_layer[i+1]-1].which_bit_output = BDD[i][j].which_bit_output; 	
						for(zi=0;zi<how_many_start_nodes;zi++){
							BDD[i+1][BDD_width_each_layer[i+1]-1].which_root_node_all[zi] = BDD[i][j].which_root_node_all[zi]; 
						} 
						for (zi=0;zi<i+1;zi++){                                                              	
							BDD_mask_next[BDD_width_each_layer[i+1]-1].mask[most_influence[zi]]  = left_son_mask[most_influence[zi]]; 
						}
						BDD[i][j].left_node_index = 	BDD_width_each_layer[i+1]-1;
						BDD[i][j].left_node_neg   = 	0;
						for (zi=0;zi<BSD_samples;zi++){
							simplify_list[BDD_width_each_layer[i+1]-1][zi] = left_mask_output_data[zi];
						}
							hash_simplify_list[BDD_width_each_layer[i+1]-1] = hash_left_number;

			}
			if(i>parameter_multi_output_index-1){
				if(all_zero_right){
					BDD[i][j].right_node_index = -2; 
					total_finish_weight += BDD[i][j].weight/2;
						//cout<<"all zero right"<<all_zero_right 	<<endl;
				}else if(all_one_right){
					BDD[i][j].right_node_index = -1; 
					total_finish_weight += BDD[i][j].weight/2;
						//cout<<"all one  right"<<all_one_right 	<<endl;
				}else{
					if(((i%how_often_simplify == 0))){
						which_list_number 	= compare_simplify_list(BDD_width_each_layer[i+1],right_mask_output_data,simplify_list,hash_simplify_list,hash_right_number);
						which_list_number_neg 	= compare_simplify_list_neg(BDD_width_each_layer[i+1],right_mask_output_data,simplify_list,hash_simplify_list,hash_right_neg_number);
						it_cannot_simplify 	= (which_list_number < 0)&&(which_list_number_neg<0);
						it_can_simplify 	= (which_list_number 		>=0);
						it_can_simplify_neg 	= (which_list_number_neg	>=0);
						if((it_can_simplify_neg == 0) && (it_can_simplify == 0)){
							it_cannot_simplify = 1;
						}
						if(it_cannot_simplify){
							BDD_width_each_layer[i+1] += 1;
							BDD[i+1][BDD_width_each_layer[i+1]-1].depth = i+1; 
							BDD[i+1][BDD_width_each_layer[i+1]-1].weight = BDD[i][j].weight/2; 
							BDD[i+1][BDD_width_each_layer[i+1]-1].which_root_node = BDD[i][j].which_root_node; 
							BDD[i+1][BDD_width_each_layer[i+1]-1].which_bit_output = BDD[i][j].which_bit_output; 
							for(zi=0;zi<how_many_start_nodes;zi++){
								BDD[i+1][BDD_width_each_layer[i+1]-1].which_root_node_all[zi] = BDD[i][j].which_root_node_all[zi]; 
							} 
							for (zi=0;zi<i+1;zi++){
								BDD_mask_next[BDD_width_each_layer[i+1]-1].mask[most_influence[zi]]  = right_son_mask[most_influence[zi]]; 
							}
							BDD[i][j].right_node_index = 	BDD_width_each_layer[i+1]-1;
							BDD[i][j].right_node_neg    = 	0;
							for (zi=0;zi<BSD_samples;zi++){
								simplify_list[BDD_width_each_layer[i+1]-1][zi] = right_mask_output_data[zi];
							}
							hash_simplify_list[BDD_width_each_layer[i+1]-1] = hash_right_number;
						}else if(it_can_simplify){
							BDD[i][j].right_node_index = 	which_list_number;
							BDD[i][j].right_node_neg   = 0;
							BDD[i+1][which_list_number].weight += BDD[i][j].weight/2;
							for(zi=0;zi<how_many_start_nodes;zi++){
								BDD[i+1][which_list_number].which_root_node_all[zi] |= BDD[i][j].which_root_node_all[zi]; 
							} 
						}else if(it_can_simplify_neg){
							BDD[i][j].right_node_index = 	which_list_number_neg;
							BDD[i][j].right_node_neg   = 1;
							BDD[i+1][which_list_number_neg].weight += BDD[i][j].weight/2;
							for(zi=0;zi<how_many_start_nodes;zi++){
								BDD[i+1][which_list_number_neg].which_root_node_all[zi] |= BDD[i][j].which_root_node_all[zi]; 
							} 
						}
					}else{
						BDD_width_each_layer[i+1] += 1;
						BDD[i+1][BDD_width_each_layer[i+1]-1].depth = i+1; 
						BDD[i+1][BDD_width_each_layer[i+1]-1].weight = BDD[i][j].weight/2; 
						BDD[i+1][BDD_width_each_layer[i+1]-1].which_root_node = BDD[i][j].which_root_node; 
						BDD[i+1][BDD_width_each_layer[i+1]-1].which_bit_output = BDD[i][j].which_bit_output; 
						for(zi=0;zi<how_many_start_nodes;zi++){
							BDD[i+1][BDD_width_each_layer[i+1]-1].which_root_node_all[zi] = BDD[i][j].which_root_node_all[zi]; 
						} 
						for (zi=0;zi<i+1;zi++){
							BDD_mask_next[BDD_width_each_layer[i+1]-1].mask[most_influence[zi]]  = right_son_mask[most_influence[zi]]; 
						}
						BDD[i][j].right_node_index = 	BDD_width_each_layer[i+1]-1;
						BDD[i][j].right_node_neg    = 	0;
							for (zi=0;zi<BSD_samples;zi++){
								simplify_list[BDD_width_each_layer[i+1]-1][zi] = right_mask_output_data[zi];
							}
							hash_simplify_list[BDD_width_each_layer[i+1]-1] = hash_right_number;
					}
				}
			}else{		
						BDD_width_each_layer[i+1] += 1;
						BDD[i+1][BDD_width_each_layer[i+1]-1].depth = i+1; 
						BDD[i+1][BDD_width_each_layer[i+1]-1].weight = BDD[i][j].weight/2; 
						BDD[i+1][BDD_width_each_layer[i+1]-1].which_root_node = BDD[i][j].which_root_node; 
						BDD[i+1][BDD_width_each_layer[i+1]-1].which_bit_output = BDD[i][j].which_bit_output; 
						for(zi=0;zi<how_many_start_nodes;zi++){
							BDD[i+1][BDD_width_each_layer[i+1]-1].which_root_node_all[zi] = BDD[i][j].which_root_node_all[zi]; 
						} 
						for (zi=0;zi<i+1;zi++){
							BDD_mask_next[BDD_width_each_layer[i+1]-1].mask[most_influence[zi]]  = right_son_mask[most_influence[zi]]; 
						}
						BDD[i][j].right_node_index = 	BDD_width_each_layer[i+1]-1;
						BDD[i][j].right_node_neg    = 	0;
							for (zi=0;zi<BSD_samples;zi++){
								simplify_list[BDD_width_each_layer[i+1]-1][zi] = right_mask_output_data[zi];
							}
							hash_simplify_list[BDD_width_each_layer[i+1]-1] = hash_right_number;

			}
			//cout<<"Debug 5"<<"	";
			if(BDD[i][j].left_node_index != BDD[i][j].right_node_index){
				total_split_nodes += 1;	
				BDD_split_nodes_each_layer[i] += 1;
			}else{
				if((BDD[i][j].left_node_neg == 0) && (BDD[i][j].right_node_neg == 0) && (BDD[i][j].left_node_index >= 0)){
					if(BDD[i+1][BDD[i][j].left_node_index].has_equal_father == 0){
						BDD[i+1][BDD[i][j].left_node_index].has_equal_father = 1;
						BDD[i+1][BDD[i][j].left_node_index].non_equal_number = BDD[i][j].non_equal_number;
					}
				}
			}
		}
			//cout<<"Debug 6"<<"	";
		for(zi=0;zi<how_many_start_nodes;zi++){
			root_nodes_leafs[zi] = 0;
			for(int64_t zj=0;zj<BDD_width_each_layer[i+1];zj++){
				root_nodes_leafs[zi] += int64_t(BDD[i+1][zj].which_root_node_all[zi]);
			}
			cout<<root_nodes_leafs[zi]<<" ";
		}
		cout<<endl;

		split_nodes_each_layer[i]	= total_split_nodes;	
		accuracy_each_layer[i]		= ((total_finish_weight)/pow(2.0,20))/double(parameter_output_bit_width);
		total_nodes_amount_recursive 	= total_nodes_amount;
		total_split_nodes_recursive 	= total_split_nodes;
	
		cout<<"BSD "<<BDD_id<<" nodes = "<<total_nodes_amount<<endl;
		cout<<"BSD "<<BDD_id<<" split nodes = "<<total_split_nodes<<endl;
		cout<<"BSD "<<BDD_id<<" feature area = "<<feature_area;
		cout<<"		Finish trained weight =  "<<setprecision(12)<<(total_finish_weight)/pow(2.0,20)<<endl;
		gettimeofday(&finish_time,NULL);
		train_time = double(finish_time.tv_usec-start_time.tv_usec+1000000*(finish_time.tv_sec-start_time.tv_sec))/1000000;
		cout<<"BSD  "<<BDD_id<<" train time = "<<train_time<<"s"<<endl;
		all_train_time = double(finish_time.tv_usec-initial_start_time.tv_usec+1000000*(finish_time.tv_sec-initial_start_time.tv_sec))/1000000;
		cout<<"BSD  "<<BDD_id<<" program time = "<<all_train_time<<"s"<<endl;
		cout<<"######################################################################"<<endl;
	}

	arr_delete( 	root_nodes_leafs);
	arr_delete( 	leaf_nodes_roots);

	return 0;
};

int64_t	BDD_class::BDD_infer(){
#ifdef BSD_COV_DATASET_REPLAY
	cout<<"BSD-Cov eval dataset size = "<<BSD_COV_NUM_EVAL_SAMPLES<<endl;
	error_amount_all = 0;
	circuit_accuracy_all_bits = new double [how_many_start_nodes];
	for (int64_t test_bit = 0; test_bit < how_many_start_nodes; ++test_bit) {
		error_amount = 0;
		for (int64_t s = 0; s < BSD_COV_NUM_EVAL_SAMPLES; ++s) {
			bool* test_input_data = new bool [parameter_input_bit_width];
			for (int64_t b = 0; b < parameter_input_bit_width; ++b) test_input_data[b] = bsd_cov_eval_input_bit(s, b);
			for (int64_t d = 0; d < start_depth; ++d) test_input_data[most_influence[d]] = BDD[start_depth][test_bit].mask[most_influence[d]];
			bool truth = bsd_cov_eval_output_bit(s, BDD[start_depth][test_bit].which_bit_output);
			bool infer = cal_infer_result(test_input_data, test_bit, 0);
			if (truth != infer) { error_amount++; error_amount_all++; }
			arr_delete(test_input_data);
		}
		circuit_accuracy_all_bits[test_bit] = 1.0 - (double(error_amount) / double(BSD_COV_NUM_EVAL_SAMPLES));
		cout<<"Testing output bit No. "<<setw(4)<<test_bit<<"\tError amount = "<<error_amount<<"\tAccuracy = "<<circuit_accuracy_all_bits[test_bit]<<endl;
	}
	circuit_accuracy = 0;
	for (int64_t test_bit = 0; test_bit < how_many_start_nodes; ++test_bit) circuit_accuracy += circuit_accuracy_all_bits[test_bit];
	circuit_accuracy /= how_many_start_nodes;
	arr_delete(circuit_accuracy_all_bits);
	cout<<"How many start nodes = "<<how_many_start_nodes<<endl;
	cout<<"Average Accuracy among all output bits = "<<circuit_accuracy<<endl;
	return 0;
#else
	return 0;
#endif
};

bool	BDD_class::cal_infer_result(bool* input_data,int64_t which_root_node,bool neg){
	bool	infer_result = 0;
	int64_t i;
	int64_t position = which_root_node;
	for (i=this->start_depth;i<parameter_input_bit_width+10000;i++){
		if(this->BDD[i][position].switch_to_another_BDD == 0){
			if(!input_data[this->most_influence[i]]){
				if(this->BDD[i][position].left_node_index == -1){
					if(neg){
						infer_result = 0;
					}else{
						infer_result = 1;
					}
					break;
				}else if(this->BDD[i][position].left_node_index == -2){
					if(neg){
						infer_result = 1;
					}else{
						infer_result = 0;
					}
					break;
				}else{
					if(this->BDD[i][position].left_node_neg){
						neg = !neg;
					}
					position = this->BDD[i][position].left_node_index;
				}
			}else{
				if(this->BDD[i][position].right_node_index == -1){
					if(neg){
						infer_result = 0;
					}else{
						infer_result = 1;
					}
					break;
				}else if(this->BDD[i][position].right_node_index == -2){
					if(neg){
						infer_result = 1;
					}else{
						infer_result = 0;
					}
					break;
				}else{
					if(this->BDD[i][position].right_node_neg){
						neg = !neg;
					}
					position = this->BDD[i][position].right_node_index;
				}
			}
		}
		else{
			infer_result 	= BDD_partition[(this->BDD[i][position].switch_to_which_BDD)].cal_infer_result(input_data,this->BDD[i][position].switch_to_which_node,neg);
			break;
		}
	}
	return	infer_result;
};

int64_t	BDD_class::BDD_FULL_PROCESS(){

	gettimeofday(&initial_start_time,NULL);
		gettimeofday(&start_time,NULL);
				BDD_id	= GLOBAL_BDD_id_number;
				cout<<"switch_BDD:	"<<BDD_id<<endl;
				cout<<"######################################################################"<<endl;

	for (i=0;i<parameter_input_bit_width+1;i++){
		amount_turn_output_data[i] = new bool  [BSD_samples_influence_max];
	}

	gettimeofday(&finish_time,NULL);
	double train_time = double(finish_time.tv_usec-start_time.tv_usec+1000000*(finish_time.tv_sec-start_time.tv_sec))/1000000;

	srand((unsigned)time(0));
	cout<<"ready to train"<<endl;
	
	for (j=0;j<parameter_max_samples;j++){
		mask_input_data[j] 	= new bool[parameter_input_bit_width+2];
		mask_input_data_order[j] 	= new bool[parameter_input_bit_width+2];
	}
	int64_t start_node_ij=0;
	for (int64_t i=0;i<parameter_output_bit_width;i++){
		if(i==start_node_index[start_node_ij].root_node_index){
			start_node_index_string[i] = '1';
			start_node_ij ++;
		}
		else{
			start_node_index_string[i] = '0';
		}
		
	}
	start_node_index_string[parameter_output_bit_width] = '\0';
//	for (j=0;j<parameter_max_orders;j++){
//		BSD_variable_order[j]     = new int64_t [parameter_input_bit_width];
//	}
	for (int64_t zi=0;zi<parameter_max_BDD_width;zi++){
			simplify_list[zi] = new bool[parameter_max_samples];
	}
	for(int64_t i=0;i<parameter_input_bit_width;i++)
		BDD_split_nodes_each_layer[i] = 0;
	train_BDD(start_depth,how_many_start_nodes,start_nodes);
	int64_t	best_total_split_nodes_recursive = total_split_nodes_recursive;
	cout<<"Finish Train"<<endl;
	struct timeval	switch_start_time,switch_finish_time;
	gettimeofday(&switch_start_time,NULL);
	int64_t max_move_length = 40;	
	int64_t max_group = 5;
	
	BDD_infer();
	if(circuit_accuracy<0.96){}
	else{
		int64_t optimize_time =0;
		for(int64_t k=1;k<2;k++){
			///for(int64_t zj=0;zj<2;zj++){
			///	max_group = 2  ;
			///	max_move_length = max(min(50,int64_t(parameter_input_bit_width/2)-1),int64_t((parameter_input_bit_width/(1+zj))-1)) ;
			///	
			///	cout<<"######################################################################"<<endl;
			///	cout<<"Switch Times	"<<zj<<endl;
			///	optimize_time = 0;
			///	int64_t best_move_times_zk=0;
			///	int64_t best_move_times_zi=0;
			///	random_device rd;	
			///	mt19937 gen(rd());
			///	//int64_t start_i = gen()%total_BDD_depth;
			///	int64_t start_i = 0;
			///	for(int64_t si=0;si<parameter_input_bit_width;si++){
			///		int64_t i = (start_i + si)%total_BDD_depth;
			///		cout<<"Switch bit:	"<<i<<"	"<<endl;
			///		bool optimize=0;
			///		int64_t move_length = min(i,max_move_length);
			///		for(int64_t zk=0;zk<=max_group;zk++){
			///			for(int64_t zi=0;zi<=move_length;zi++){
			///				BSD_switch_layer(i-zi);
			///				if(total_split_nodes_recursive < best_total_split_nodes_recursive){
			///					best_total_split_nodes_recursive = total_split_nodes_recursive;
			///					cout<<"	move length "<<zi<<"	move group "<<zk;
			///					cout<<"	Best area update:	"<<best_total_split_nodes_recursive<<endl;
			///					optimize_time +=1;
			///				}
			///			}
			///			
			///		}
			///		for(int64_t zk=max_group;zk>=0;zk--){
			///			for(int64_t zi=move_length;zi>=0;zi--){
			///				if(total_split_nodes_recursive == best_total_split_nodes_recursive)
			///					break;
			///				else
			///					BSD_switch_layer(i-zi);
			///			}
			///		}
			///	}
			///	//if(( parameter_input_bit_width<50)){
			///	//	if((optimize_time < 1) )
			///	//		break;
			///	//}else{
			///	//	if(optimize_time < int64_t(parameter_input_bit_width/10))
			///	//		break;
			///	//}
			///}
			for(int64_t zj=0;zj<1;zj++){
				if(zj==0)
					max_group = zj ;
				else
					max_group = zj - 1;
				max_move_length = min(int64_t(20),int64_t((parameter_input_bit_width/(1+zj))-3)) ;
				
				cout<<"######################################################################"<<endl;
				cout<<"Switch Times	"<<zj<<endl;
				optimize_time = 0;
				int64_t best_move_times_zk=0;
				int64_t best_move_times_zi=0;
				random_device rd;	
				mt19937 gen(rd());
				//int64_t start_i = gen()%total_BDD_depth;
				int64_t start_i = 0;
				for(int64_t si=0;si<total_BDD_depth-1;si++){
					int64_t i = (start_i + si)%total_BDD_depth;
					cout<<"Switch bit:	"<<i<<"	"<<endl;
					bool optimize=0;
					int64_t move_length = min(total_BDD_depth-i-max_group-3,max_move_length);
					for(int64_t zi=0;zi<=move_length;zi++){
						for(int64_t zk=0;zk<=min(max_group,move_length-1);zk++){
							BSD_switch_layer((i+zi+min(max_group,move_length-1)-zk)%total_BDD_depth);
							if(total_split_nodes_recursive < best_total_split_nodes_recursive){
								best_total_split_nodes_recursive = total_split_nodes_recursive;
								cout<<"	move length "<<zi<<"	move group "<<zk;
								cout<<"	Best area update:	"<<best_total_split_nodes_recursive<<endl;
								optimize_time +=1;
							}
						}
						
					}
					for(int64_t zi=move_length;zi>=0;zi--){
						for(int64_t zk=min(max_group,move_length-1);zk>=0;zk--){
							if(total_split_nodes_recursive == best_total_split_nodes_recursive)
								break;
							else
								BSD_switch_layer((i+zi+min(max_group,move_length-1)-zk%total_BDD_depth));
						}
					}
				}
				if((optimize_time < 2) && (zj>4))
					break;
				if((optimize_time > 10) )
					zj-=1;
			}
		}
		gettimeofday(&switch_finish_time,NULL);
		double switch_time = double(switch_finish_time.tv_usec-switch_start_time.tv_usec+1000000*(switch_finish_time.tv_sec-switch_start_time.tv_sec))/1000000;
		
		cout<<" Switch time = "<<switch_time<<"s"<<endl;
	}
	
#ifdef BSD_COV_ALWAYS_PRINT
	print_circuit(start_depth,start_node_index_string);
#else
	if(circuit_accuracy>0.9999)
		print_circuit(start_depth,start_node_index_string);
#endif
	for (int64_t vi=0;vi<parameter_input_bit_width;vi++){
		BSD_variable_order[vi] = most_influence[vi];
	}
	
	for(int64_t zi=0;zi<parameter_input_bit_width;zi++){
		BSD_features_0.BSD_area_layers [zi] =  split_nodes_each_layer[zi];
		BSD_features_0.accuracy_layers [zi] =  accuracy_each_layer[zi];
		BSD_features_0.BDD_width_each_layer[zi] = BDD_width_each_layer[zi];
	}
	if(partition_depth > parameter_input_bit_width){
			for(int64_t zi=0;zi<parameter_input_bit_width;zi++){
				BSD_features_0.variable_order [zi] = most_influence[zi];
			}
	}
	else{
			for(int64_t zi=0;zi<parameter_input_bit_width;zi++){
				BSD_features_0.variable_order [zi] = BSD_variable_order[zi];
			}
	}

	BSD_features_0.BSD_depth = total_BDD_depth+1;
	BSD_features_0.BSD_area  = total_split_nodes_recursive;
	BSD_features_0.accuracy  = circuit_accuracy;
	BSD_features_0.feature_area  = feature_area;
	
		//GLOBAL_BDD_nodes += total_nodes_amount; 
		//GLOBAL_BDD_split_nodes += total_split_nodes; 
		//cout<<"Total nodes = "<<total_nodes_amount<<endl;
		//cout<<"Total split nodes = "<<total_split_nodes<<endl;
	//arr_delete	(most_influence)			; 
	//delete []	BDD_width_each_layer 		; 
	//delete []	mask_output_data 		; 
	//delete []	hash_simplify_list		; 
	//delete []	BDD_mask_this			; 
	//delete []	BDD_mask_next			; 
	//delete []	has_been_unfold 		; 
	//delete []	amount_turn 			; 
	//delete []	test_input_data 		; 
	//delete []	left_son_mask			; 
	//delete []	right_son_mask			; 
	//delete []	left_mask_output_data		; 
	//delete []	right_mask_output_data		; 
	//delete []	left_mask_output_data_all	; 
	//delete []	right_mask_output_data_all	; 
	//delete []	all_one_left_list   		; 
	//delete []	all_zero_left_list  		; 
	//delete []	all_one_right_list  		; 
	//delete []	all_zero_right_list 		; 

	//delete []	split_nodes_each_layer 		; 
	//delete []	accuracy_each_layer    		; 
	//delete []	BSD_variable_order     		; 
	//delete []	BDD_split_nodes_each_layer 	; 
	//delete []	output_partition_set  		; 
	//delete []	start_node_index		; 
	//delete []	start_node_index_string 	; 

	//for (i=0;i<parameter_input_bit_width+1;i++){
	//	delete []amount_turn_output_data[i] ;
	//}
	//for (i=0;i<parameter_max_BDD_width;i++){
	//	delete [] simplify_list[i] ;
	//}
	//for (i=0;i<parameter_max_samples*2;i++){
	//	delete [] mask_input_data[i] ;
	//}
	//delete []amount_turn_output_data	= new bool* [parameter_input_bit_width+1];
	//delete []simplify_list     		= new bool*[parameter_max_BDD_width];
	//delete []mask_input_data  		= new bool*[parameter_max_samples*2];
	//delete []	BDD 				; 
	return 0;
}

void BDD_class::BSD_switch_layer(int64_t i){
	BDD_node* lr = new BDD_node[BDD_width_each_layer[i]*2];
	BDD_node* prt = BDD[i];
	int64_t lr_width = 0; 
	int64_t prt_split_nodes = 0;
	int64_t lr_split_nodes = 0;
	key k, k_neg;
	int f0, f1, f00, f01, f10, f11;
	bool f00_neg, f01_neg, f10_neg, f11_neg;
	unordered_map<key, int64_t> merge_map;
	//TODO non_equal_nodes, has_equal_father未作处理，因为未使用
	for (int64_t j = 0; j < BDD_width_each_layer[i]; j++){
		prt[j].this_layer_bit_expansion = most_influence[i+1];
		f0	= BDD[i][j].left_node_index;
		f1	= BDD[i][j].right_node_index;
		if (f0 < 0){
			f00 = f01 = f0;
			f00_neg = f01_neg = prt[j].left_node_neg;
		}
		else{
			f00 = BDD[i+1][f0].left_node_index;
			f01 = BDD[i+1][f0].right_node_index;
			f00_neg = prt[j].left_node_neg^BDD[i+1][f0].left_node_neg;
			f01_neg = prt[j].left_node_neg^BDD[i+1][f0].right_node_neg;
		}
		if (f1 < 0){
			f10 = f11 = f1;
			f10_neg = f11_neg = prt[j].right_node_neg;
		}
		else{
			f10 = BDD[i+1][f1].left_node_index;
			f11 = BDD[i+1][f1].right_node_index;
			f10_neg = prt[j].right_node_neg^BDD[i+1][f1].left_node_neg;
			f11_neg = prt[j].right_node_neg^BDD[i+1][f1].right_node_neg;
		}
		if		(f00==-2 && f00_neg)	{f00 = -1;	f00_neg = false;}
		else if (f00==-1 && f00_neg)	{f00 = -2;	f00_neg = false;}
		if		(f01==-2 && f01_neg)	{f01 = -1;	f01_neg = false;}
		else if	(f01==-1 && f01_neg)	{f01 = -2;	f01_neg = false;}
		if		(f10==-2 && f10_neg)	{f10 = -1;	f10_neg = false;}
		else if	(f10==-1 && f10_neg)	{f10 = -2;	f10_neg = false;}
		if		(f11==-2 && f11_neg)	{f11 = -1;	f11_neg = false;}
		else if	(f11==-1 && f11_neg)	{f11 = -2;	f11_neg = false;}
		
		// 合并f0'
		if (f00 == -2 && f10 == -2){
			prt[j].left_node_index = -2;
			prt[j].left_node_neg = false;
		}
		else if (f00 == -1 && f10 == -1){
			prt[j].left_node_index = -1;
			prt[j].left_node_neg = false;
		}
		else{
			k = {f00, f10, f00_neg, f10_neg};
			k_neg = k;
			if		(k_neg.lc==-1)	{k_neg.lc=-2;}
			else if	(k_neg.lc==-2)	{k_neg.lc=-1;}
			else	{k_neg.lc_neg = !k_neg.lc_neg;}
			if		(k_neg.rc==-1)	{k_neg.rc=-2;}
			else if	(k_neg.rc==-2)	{k_neg.rc=-1;}
			else	{k_neg.rc_neg = !k_neg.rc_neg;}
			auto result = merge_map.find(k);
			if (result != merge_map.end()){	//左子节点可以合并
				prt[j].left_node_index = result->second;
				prt[j].left_node_neg = false;
				lr[result->second].weight += prt[j].weight / 2;
				for(int64_t zi=0;zi<parameter_output_bit_width;zi++){
					lr[result->second].which_root_node_all[zi] |= prt[j].which_root_node_all[zi]; 
				}
			}
			else if ((result = merge_map.find(k_neg)) != merge_map.end()){	//左子节点可以取反合并
				prt[j].left_node_index = result->second;
				prt[j].left_node_neg = true;
				lr[result->second].weight += prt[j].weight / 2;
				for(int64_t zi=0;zi<parameter_output_bit_width;zi++){
					lr[result->second].which_root_node_all[zi] |= prt[j].which_root_node_all[zi]; 
				}
			}
			else{	//左子节点无法合并
				merge_map[k] = lr_width;
				lr[lr_width].this_layer_bit_expansion = most_influence[i];
				lr[lr_width].depth = i+1;
				lr[lr_width].weight = prt[j].weight / 2;
				lr[lr_width].which_root_node = prt[j].which_root_node;
				for(int64_t zi=0;zi<parameter_output_bit_width;zi++){
					lr[lr_width].which_root_node_all[zi] = prt[j].which_root_node_all[zi]; 
				}
				for(int64_t zi=0;zi<i;zi++){
					lr[lr_width].mask[most_influence[zi]] = prt[j].mask[most_influence[zi]]; 
				}
				lr[lr_width].mask[most_influence[i+1]] = 0;
				lr[lr_width].left_node_index = f00;
				lr[lr_width].right_node_index = f10;
				lr[lr_width].left_node_neg = f00_neg;
				lr[lr_width].right_node_neg = f10_neg;
				if(lr[lr_width].left_node_index != lr[lr_width].right_node_index){
					lr_split_nodes++;
				}
				prt[j].left_node_index = lr_width;
				prt[j].left_node_neg = false;
				lr_width++;
			}
		}
		
		//合并f1'
		if (f01 ==-2 && f11 == -2){
			prt[j].right_node_index = -2;
			prt[j].right_node_neg = false;
		}
		else if (f01 == -1 && f11 == -1){
			prt[j].right_node_index = -1;
			prt[j].right_node_neg = false;
		}
		else{
			k = {f01, f11, f01_neg, f11_neg};
			k_neg = k;
			if		(k_neg.lc==-1)	{k_neg.lc=-2;}
			else if	(k_neg.lc==-2)	{k_neg.lc=-1;}
			else	{k_neg.lc_neg = !k_neg.lc_neg;}
			if		(k_neg.rc==-1)	{k_neg.rc=-2;}
			else if	(k_neg.rc==-2)	{k_neg.rc=-1;}
			else	{k_neg.rc_neg = !k_neg.rc_neg;}
			auto result = merge_map.find(k);
			if (result != merge_map.end()){	//右子节点可以合并
				prt[j].right_node_index = result->second;
				prt[j].right_node_neg = false;
				lr[result->second].weight += prt[j].weight / 2;
				for(int64_t zi=0;zi<parameter_output_bit_width;zi++){
					lr[result->second].which_root_node_all[zi] |= prt[j].which_root_node_all[zi]; 
				}
			}
			else if ((result = merge_map.find(k_neg)) != merge_map.end()){	//右子节点可以取反合并
				prt[j].right_node_index = result->second;
				prt[j].right_node_neg = true;
				lr[result->second].weight += prt[j].weight / 2;
				for(int64_t zi=0;zi<parameter_output_bit_width;zi++){
					lr[result->second].which_root_node_all[zi] |= prt[j].which_root_node_all[zi]; 
				}
			}
			else{	//右子节点无法合并
				merge_map[k] = lr_width;
				lr[lr_width].this_layer_bit_expansion = most_influence[i];
				lr[lr_width].depth = i+1;
				lr[lr_width].weight = prt[j].weight / 2;
				lr[lr_width].which_root_node = prt[j].which_root_node;
				for(int64_t zi=0;zi<parameter_output_bit_width;zi++){
					lr[lr_width].which_root_node_all[zi] = prt[j].which_root_node_all[zi]; 
				}
				for(int64_t zi=0;zi<i;zi++){
					lr[lr_width].mask[most_influence[zi]] = prt[j].mask[most_influence[zi]]; 
				}
				lr[lr_width].mask[most_influence[i+1]] = 1;
				lr[lr_width].left_node_index = f01;
				lr[lr_width].right_node_index = f11;
				lr[lr_width].left_node_neg = f01_neg;
				lr[lr_width].right_node_neg = f11_neg;
				if(lr[lr_width].left_node_index != lr[lr_width].right_node_index){
					lr_split_nodes++;
				}
				prt[j].right_node_index = lr_width;
				prt[j].right_node_neg = false;
				lr_width++;
			}
		}
		
		if(prt[j].left_node_index != prt[j].right_node_index){
			prt_split_nodes++;
		}
	}
	//if((prt_split_nodes+lr_split_nodes)<(BDD_split_nodes_each_layer[i]+BDD_split_nodes_each_layer[i+1])){
	swap(most_influence[i], most_influence[i+1]);
	arr_delete(BDD[i+1]);
	BDD[i+1] = lr;
	total_nodes_amount = total_nodes_amount - BDD_width_each_layer[i+1] + lr_width;
	total_split_nodes_recursive = total_split_nodes_recursive - BDD_split_nodes_each_layer[i] + prt_split_nodes
						- BDD_split_nodes_each_layer[i+1] + lr_split_nodes;
	      // cout<<"prt_split_nodes	"<<prt_split_nodes<<"	ls_split_nodes	"<<lr_split_nodes<<" BDD_split_nodes_each_layer[i]	"<<BDD_split_nodes_each_layer[i]<<"	BDD_split_nodes_each_layer[i+1]	"<<BDD_split_nodes_each_layer[i+1]<<endl;	
	BDD_width_each_layer[i+1] = lr_width; 
	BDD_split_nodes_each_layer[i] = prt_split_nodes;
	BDD_split_nodes_each_layer[i+1] = lr_split_nodes;
	//}
}

