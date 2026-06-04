#include"top.h"
#include"cvt.h"
#include <iostream>
#include <vector>
#include <omp.h>
#include <cstdint>
#include <ctime>
#include <random> // 用于 random_device
#include <chrono> // 用于高精度时间

//电路的parameter	Circuit_parameter
int64_t			circuit_index	 		= 9999;		//电路编号
extern const int64_t			parameter_max_orders		= 1;



//算法的parameter 	Algorithm_parameter
extern const int64_t	parameter_multi_output_index	= 0; 		//BSD从第几层开始化简，前面若干层展开序确定
extern const int64_t	parameter_max_BDD_width		= 320000;	//BSD每一层最多多少个节点
int64_t	parameter_early_stop_depth	= parameter_input_bit_width;		//BSD到第几层终止，输出此时的不准确BSD
int64_t	parameter_early_stop_split_nodes= 10000000;	//BSD每一层最多多少个节点

//全局变量
int64_t	GLOBAL_which_demo_function;
int64_t	GLOBAL_BDD_id_number; 
int64_t	GLOBAL_BDD_nodes; 
int64_t	GLOBAL_BDD_split_nodes; 
int64_t	GLOBAL_train_time; 
int64_t	GLOBAL_program_time; 

bool**	file_inputs;
//待优化变量
int64_t**	multi_variable_order ;
int64_t	variable_order_number;

//bool	truth_table [1024*1024];


int64_t output_bit_index [PO_WIDTH] = {120};
bool* io_generator_function(bool* input_data, bool* output_data) {

	
	int64_t i,j;
	bool* output_data_temp = new bool [PO_WIDTH];
	
		
	io_generator_outer(input_data,output_data_temp);
	for(i=0;i<parameter_output_bit_width;i++){
		if(parameter_output_bit_width == PO_WIDTH)
			output_data[i] = output_data_temp[i];
		else
			output_data[i] = output_data_temp[output_bit_index[i]];
	}
	arr_delete (output_data_temp);
			
	return	output_data;
}

#ifdef INPUT_AIG
uint64_t* io_generator_function_vec(uint64_t* input_data, uint64_t* output_data) {

	
	int64_t i,j;
	uint64_t* output_data_temp = new uint64_t [PO_WIDTH];
	
	io_generator_outer_vec(input_data,output_data_temp);
	for(i=0;i<parameter_output_bit_width;i++){
		if(parameter_output_bit_width == PO_WIDTH)
			output_data[i] = output_data_temp[i];
		else
			output_data[i] = output_data_temp[output_bit_index[i]];
	}
	arr_delete (output_data_temp);
		
	return	output_data;
}
#endif
class	node_index {
public:	
	int64_t	node_depth=0;
	int64_t	root_node_index=0;
	int64_t*	expand_input_bit_index;
	bool*	expand_input_bit_data;
	
	node_index(){
		expand_input_bit_index = new int64_t  [parameter_input_bit_width];
		expand_input_bit_data  = new bool [parameter_input_bit_width];
	}
	~node_index(){
		//arr_delete (expand_input_bit_index);
		//arr_delete (expand_input_bit_data);
	}
};

int64_t default_start_node_number = parameter_output_bit_width;
node_index*	default_start_node_index;


int64_t BSD_execute(int64_t start_node_number, node_index* start_node_index,int64_t variable_order_number, int64_t* variable_order);

#ifdef USE_FAST_RANDOM
// ==========================================
// 1. 高性能随机数生成器 (Xoshiro256++)
// ==========================================
struct Xoshiro256pp {
    uint64_t s[4];

    static inline uint64_t rotl(const uint64_t x, int k) {
        return (x << k) | (x >> (64 - k));
    }

    Xoshiro256pp(uint64_t seed) {
        // SplitMix64 初始化
        for(int i = 0; i < 4; ++i) {
            uint64_t z = (seed += 0x9e3779b97f4a7c15);
            z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9;
            z = (z ^ (z >> 27)) * 0x94d049bb133111eb;
            s[i] = z ^ (z >> 31);
        }
    }

    inline uint64_t next() {
        const uint64_t result = rotl(s[0] + s[3], 23) + s[0];
        const uint64_t t = s[1] << 17;
        s[2] ^= s[0]; s[3] ^= s[1]; s[1] ^= s[2]; s[0] ^= s[3];
        s[2] ^= t; s[3] = rotl(s[3], 45);
        return result;
    }

    void jump() {
        static const uint64_t JUMP[] = { 0x180ec6d33cfd0aba, 0xd5a61266f0c9392c, 0xa9582618e03fc9aa, 0x39abdc4529b1661c };
        uint64_t s0 = 0; uint64_t s1 = 0; uint64_t s2 = 0; uint64_t s3 = 0;
        for(int i = 0; i < sizeof JUMP / sizeof *JUMP; i++)
            for(int b = 0; b < 64; b++) {
                if (JUMP[i] & (1ULL << b)) {
                    s0 ^= s[0]; s1 ^= s[1]; s2 ^= s[2]; s3 ^= s[3];
                }
                next();
            }
        s[0] = s0; s[1] = s1; s[2] = s2; s[3] = s3;
    }
};

// ==========================================
// 传入 uint64_t 数组，而非 bool 数组
// ==========================================
void generate_random_bits(uint64_t* packed_buffer, size_t num_uint64s) {
    std::random_device rd;
    auto now = std::chrono::high_resolution_clock::now().time_since_epoch().count();
    uint64_t seed = (uint64_t(rd()) << 32) | rd(); 
    seed ^= now;
    
    Xoshiro256pp master_rng(seed);

    #pragma omp parallel
    {
        Xoshiro256pp local_rng = master_rng;
        int tid = omp_get_thread_num();
        for(int k = 0; k < tid; ++k) local_rng.jump();

        // 这里的循环极其简单：生成一个随机数，直接存入内存
        // 不需要任何位拆分操作，速度达到内存带宽极限
        #pragma omp for schedule(static)
        for (size_t i = 0; i < num_uint64s; ++i) {
            packed_buffer[i] = local_rng.next();
        }
    }
}
#endif

inline bool get_bit(const uint64_t* buffer, size_t index) {
    // index / 64 找到所在的 uint64 块
    // index % 64 找到块内的偏移
    return (buffer[index / 64] >> (index % 64)) & 1ULL;
}

#ifdef USE_FAST_RANDOM
size_t  test_total_bits = (size_t)parameter_test_ios * parameter_input_bit_width;
size_t train_total_bits = (size_t)parameter_max_samples * parameter_input_bit_width;
size_t  test_uint64_total_bits =  (test_total_bits + 63) / 64;
size_t train_uint64_total_bits = (train_total_bits + 63) / 64;
uint64_t*  test_input_bits = new uint64_t[ test_uint64_total_bits];
uint64_t* train_input_bits = new uint64_t[train_uint64_total_bits];
#else
bool * test_input_bits  = new bool [long(parameter_test_ios)*long(parameter_input_bit_width)];
bool * train_input_bits = new bool [long(parameter_max_samples)*long(parameter_input_bit_width)];
#endif

void set_random_train(){
#ifdef BSD_COV_DATASET_REPLAY
	return;
#else
	#ifdef USE_FAST_RANDOM
		generate_random_bits(train_input_bits, train_uint64_total_bits);
	#else
		random_device rd;	
		mt19937 gen(rd());
		#pragma omp parallel for 
		for (long j=0;j<long(parameter_max_samples)*long(parameter_input_bit_width)/30;j++){
			long randint64_t = gen();
			for (int64_t zi=0;zi<30;zi++)
				train_input_bits[j*30+zi] = bool((int(randint64_t >> (zi)))%2);
		}
	#endif
#endif
};

class BSD_features{
public:
	int64_t	BSD_depth =0;
	double	BSD_area  =0;
	double	accuracy  =0;
	
	int64_t*	BSD_area_layers;
	int64_t*	accuracy_layers;
	int64_t*	BDD_width_each_layer;
	int64_t*	variable_order;

	int64_t	feature_area;
	BSD_features(){
		BSD_area_layers		=	new int64_t [parameter_input_bit_width];
		accuracy_layers		=	new int64_t [parameter_input_bit_width];
		BDD_width_each_layer	=	new int64_t [parameter_input_bit_width];
		variable_order		= 	new int64_t [parameter_input_bit_width];
	}
	//int64_t	nodes_for_each_start_nodparameter_max_BDD_width];
};
BSD_features BSD_features_0;

#include"BSD.h"
#include"next_layer_bit.h"
#include"tool_function.h"
#include"print_circuit.h"

bool*	default_partition_set;
int64_t*	default_start_order;


void	set_default(){
	omp_set_num_threads(parameter_num_threads);
	GLOBAL_BDD_id_number 	= 0;
	GLOBAL_BDD_nodes 	= 0;
	GLOBAL_BDD_split_nodes 	= 0;
	default_start_order 	= new int64_t  [parameter_input_bit_width];	
	default_partition_set 	= new bool [parameter_output_bit_width];
	default_start_node_index= new node_index [parameter_output_bit_width];
	for(int64_t i=0;i<parameter_output_bit_width;i++){
		default_partition_set[i] = 1;
	}
	default_start_node_number = parameter_output_bit_width;
	for(int64_t i=0;i<default_start_node_number;i++){
		default_start_node_index[i].node_depth = 0;
		default_start_node_index[i].root_node_index = i;
		for (int64_t j=0;j<parameter_input_bit_width;j++){
			default_start_node_index[i].expand_input_bit_index[j] = 0;
			default_start_node_index[i].expand_input_bit_data[j]  = 0;
		}
	}
	//for(int64_t i=0;i<parameter_output_bit_width;i++)
		default_partition_set[0] = 1;
	
	ifstream sampling_input_file("sample_input.set");
	file_inputs = new bool* [parameter_io_file_lines];
	for (int64_t i=0;i<parameter_io_file_lines;i++){
		file_inputs[i] = new bool [parameter_input_bit_width];
		for(int64_t j=0;j<parameter_input_bit_width;j++){
			file_inputs[i][j] = 0;
		}
	}
	std::string line;
	int64_t lineCount = 0;
	while ((lineCount < parameter_io_file_lines) && std::getline(sampling_input_file, line)){
		if (line.length() >= parameter_input_bit_width){
			for (int64_t i = 0; i < parameter_input_bit_width; i++) {
				if(line[i] == '1'){
					file_inputs[lineCount][i] = 1;
				}
				else if (line[i] == '0'){
					file_inputs[lineCount][i] = 0;
				}else{
					std::cerr << "第 " << lineCount + 1 << " 行第 " << i + 1 << " 个字符无效，应为'0'或'1'" << std::endl;
					file_inputs[lineCount][i] = 0;  // 默认值
				}
			}
			lineCount ++;
		}
	}	
#ifndef BSD_COV_DATASET_REPLAY
	#ifdef USE_FAST_RANDOM
		generate_random_bits(test_input_bits, test_uint64_total_bits);
	#else
	random_device rd;	
	mt19937 gen(rd());
	#pragma omp parallel for 
	for (long j=0;j<long(parameter_test_ios)*long(parameter_input_bit_width)/30;j++){
		long randint64_t = gen();
		for (int64_t zi=0;zi<30;zi++)
			test_input_bits[j*30+zi] = bool((randint64_t >> (zi))%2);
	}
	#endif
#endif
	cout<<"Finish default setup";
	//io generator来自真值表，不来自写好的文件
 	//char*  truth_table_name = new char [100];
	//int64_t    truth_table_input_width;
	//	if(argc >= 2){
	//		truth_table_input_width= atoi(argv[1]);
	//	}
	//	if(argc>=3){
	//		truth_table_name = argv[2];
	//	}
	//
	

	//	string line_data;
	//	for(int64_t i=0;i<pow(2,20);i++){
	//			truth_table[i] = 0;
	//	}
	//	for(int64_t i=0;i<pow(2,20);i++){
	//		getline(truth_table_file,line_data);
	//		//cout<<line_data[truth_table_input_width+1]<<endl;
	//		if(line_data[truth_table_input_width+1]=='0')
	//			truth_table[i] = 0;
	//		else
	//			truth_table[i] = 1;
	//	}
	//search_order();
	//int64_t* start_order_a = new int64_t [parameter_input_bit_width];	
	//int64_t area_a =	search_order(10,output_partition_set_a,0,start_order_a);
	
	


}
//double	variable_features[parameter_input_bit_width];
double search_order(int64_t start_node_number , int64_t start_node_depth, node_index* start_node_index,int64_t search_iterations, int64_t* start_order);
double	search_reward(BSD_features BSD_features_0);
int64_t search_partition(int64_t start_node_number,int64_t start_node_depth , node_index* start_node_index , int64_t* start_order);

int64_t search_partition(int64_t start_node_number=default_start_node_number,int64_t start_node_depth = 0, node_index* start_node_index = default_start_node_index, int64_t* start_order = default_start_order){
	
	int64_t search_order_times = 2;
	int64_t min_partition_parts ;
	#ifdef ACCURACY_FIRST							
		min_partition_parts = start_node_number;
	#else
		min_partition_parts = 0;
	#endif

	random_device rd;	
	mt19937 gen(rd());
	int64_t   max_partition_parts = start_node_number;
	int64_t   best_partition_parts = max_partition_parts;
	double   best_area = 999999;
	
	bool** partition_sets = new bool* [max_partition_parts];
	bool** best_partition_sets = new bool* [max_partition_parts];
	for (int64_t i=0;i<max_partition_parts;i++){
		partition_sets[i] = new bool [max_partition_parts];
		best_partition_sets[i] = new bool [max_partition_parts];
		for(int64_t j=0;j<max_partition_parts;j++){
			partition_sets[i][j] = 0;
			best_partition_sets[i][j] = 0;
		}
		partition_sets[i][i] = 1;
		best_partition_sets[i][i] = 1;
	}
	double* area_parts 	= new double [max_partition_parts];
	double* best_area_parts 	= new double [max_partition_parts];
	
	double area=0;
	for (int64_t i=0;i<max_partition_parts;i++){
		cout<<"Partition_set	["<<i<<"]	";
		int64_t start_node_partition = 0;
		for(int64_t j=0;j<max_partition_parts;j++){
			cout<<partition_sets[i][j];
			if(partition_sets[i][j]){
				start_node_partition ++;
			}
		}
		cout<<endl;
		int64_t zi =0;
		node_index* start_node_index_partition = new node_index [max_partition_parts];
		for(int64_t j=0;j<max_partition_parts;j++){
			if(partition_sets[i][j]){
				start_node_index_partition[zi].node_depth = start_node_index[j].node_depth;
				start_node_index_partition[zi].root_node_index = start_node_index[j].root_node_index;
				for(int64_t zj=0;zj<parameter_input_bit_width;zj++){
					start_node_index_partition[zi].expand_input_bit_index[zj] = start_node_index[j].expand_input_bit_index[zj];
					start_node_index_partition[zi].expand_input_bit_data[zj] = start_node_index[j].expand_input_bit_data[zj];
				}
				zi++;
			}
		}
		area_parts[i] =  search_order(start_node_partition , start_node_depth, start_node_index_partition, search_order_times, start_order);
		area += area_parts[i];
		arr_delete  (start_node_index_partition);
	}
	if(area<best_area){
		best_area = area;
		best_partition_parts = max_partition_parts;
		for (int64_t i=0;i<max_partition_parts;i++){
			for(int64_t j=0;j<max_partition_parts;j++){
				best_partition_sets[i][j] = partition_sets[i][j];
			}
			best_area_parts[i] = area_parts[i];
		}
	}
	cout<<"###########################################################################"<<endl;
	cout<<"Design Area:		"<<area<<endl;
	for (int64_t i=0;i<max_partition_parts;i++){
		cout<<"partition "<<i<<"	"<<area_parts[i]<<endl;
	}	
	char* 	    start_node_index_string = new char [parameter_output_bit_width+1];
	
	ofstream function_top_file("rtl/function_top.v");
	for (int64_t i = 0 ;i < best_partition_parts;i++){
		for (int64_t j=0;j<parameter_output_bit_width;j++){
			if(best_partition_sets[i][j]){
				start_node_index_string[j] = '1';
			}
			else{
				start_node_index_string[j] = '0';
			}
			
		}
		start_node_index_string[parameter_output_bit_width] = '\0';
		#ifdef SEARCH_PARTITION
        if (start_node_index_string == nullptr) {
            std::cout << "Error: Null pointer input.2" << std::endl;
            exit(1);
        }
        // 方法：直接遍历寻找 '1'
        // 由于是独热码， theoretically 只有一个 '1'
        uint64_t start_node_index = 0;
        // 这种写法不需要先用 strlen 计算长度，效率更高，直接扫到 '\0' 结束
        for (int i = 0; start_node_index_string[i] != '\0'; ++i) {
            if (start_node_index_string[i] == '1') {
                if (start_node_index != 0) {
                    std::cout << "Error: start_node_index_string is not one-hot string.3" << std::endl;
                    exit(1);
                }
                start_node_index = i;
            }
        }
        function_top_file << "`include \"function_layer_"<<start_node_depth<<"_nodes_"<<start_node_index<<".v\" "<<endl;
		#else
 		function_top_file << "`include \"function_layer_"<<start_node_depth<<"_nodes_"<<start_node_index_string<<".v\" "<<endl;
		#endif
	}
	function_top_file << endl;
	function_top_file << "module function_top (i,o);"<<endl<<endl;
 	function_top_file << "input 	["<<PI_WIDTH-1<<":0] i;"<<endl; 
 	function_top_file << "output	["<<parameter_output_bit_width-1<<":0]  o;"<<endl<<endl;
	for (int64_t i = 0 ;i < best_partition_parts;i++){
 		function_top_file << "wire	["<<parameter_output_bit_width-1<<":0]  o_"<<i<<";"<<endl;
 	}
	function_top_file << endl;
	for (int64_t i = 0 ;i < best_partition_parts;i++){
		for (int64_t j=0;j<parameter_output_bit_width;j++){
			if(best_partition_sets[i][j]){
				start_node_index_string[j] = '1';
			}
			else{
				start_node_index_string[j] = '0';
			}
			
		}
		start_node_index_string[parameter_output_bit_width] = '\0';
		#ifdef SEARCH_PARTITION
        if (start_node_index_string == nullptr) {
            std::cout << "Error: Null pointer input.4" << std::endl;
            exit(1);
        }
        // 方法：直接遍历寻找 '1'
        // 由于是独热码， theoretically 只有一个 '1'
        uint64_t start_node_index = 0;
        // 这种写法不需要先用 strlen 计算长度，效率更高，直接扫到 '\0' 结束
        for (int i = 0; start_node_index_string[i] != '\0'; ++i) {
            if (start_node_index_string[i] == '1') {
                if (start_node_index != 0) {
                    std::cout << "Error: start_node_index_string is not one-hot string.5" << std::endl;
                    exit(1);
                }
                start_node_index = i;
            }
        }
 		function_top_file << "function_layer_"<<start_node_depth<<"_nodes_"<<start_node_index<<"	part"<<i<<"	(.i(i),.o_index(o_"<<i<<"));"<<endl;
		#else
 		function_top_file << "function_layer_"<<start_node_depth<<"_nodes_"<<start_node_index_string<<"	part"<<i<<"	(.i(i),.o_index(o_"<<i<<"));"<<endl;
		#endif
	}
	function_top_file <<endl;
	for (int64_t i = 0 ;i < parameter_output_bit_width;i++){
		int64_t position_a = 0;
		for (int64_t j=0;j<best_partition_parts;j++){
				if(best_partition_sets[j][i] == 1){
					position_a = j;
					break;
				}
		}
 		function_top_file << "assign	o["<<i<<"]	=	o_"<<position_a<<"["<<i<<"];"<<endl;
 	}
	function_top_file << "endmodule"<<endl;
	function_top_file.close();

	cout<<"Best Design Area:	"<<best_area<<endl;
	cout<<"###########################################################################"<<endl;

	for (int64_t partition_parts=max_partition_parts-1;partition_parts>min_partition_parts;partition_parts--){
		int64_t use_part;
		for (use_part=0;use_part<partition_parts;use_part++){
			bool merge_success = 0;
			for(int64_t merge_part=use_part+1;merge_part<partition_parts;merge_part++){
				
				//改变Partition Set

				for (int64_t i=0;i<partition_parts;i++){
					if(i<merge_part){
						for(int64_t j=0;j<max_partition_parts;j++){
							partition_sets[i][j] = best_partition_sets[i][j];
						}
					}else if(i<partition_parts){
						for(int64_t j=0;j<max_partition_parts;j++){
							partition_sets[i][j] = best_partition_sets[i+1][j];
						}
					}else{
						for(int64_t j=0;j<max_partition_parts;j++){
							partition_sets[i][j] = 0;
						}
					}
				}		
				for(int64_t j=0;j<max_partition_parts;j++){
					if(!partition_sets[use_part][j])
						partition_sets[use_part][j] = best_partition_sets[merge_part][j];
				}


				//执行对比
				double area=0;
				for (int64_t i=0;i<partition_parts;i++){
					if(i>=merge_part){

						area_parts[i] =  best_area_parts[i+1];
						area += area_parts[i];
					}
					else{
			
						cout<<"Partition_set	["<<i<<"]	";
						int64_t start_node_partition = 0;
						for(int64_t j=0;j<max_partition_parts;j++){
							cout<<partition_sets[i][j];
							if(partition_sets[i][j]){
								start_node_partition ++;
							}
						}
						cout<<endl;
						node_index* start_node_index_partition = new node_index [max_partition_parts];
						int64_t zi =0;
						for(int64_t j=0;j<partition_parts;j++){
							if(partition_sets[i][j]){
								//start_node_index_partition[zi] = start_node_index[j];
								start_node_index_partition[zi].node_depth 		= start_node_index[j].node_depth;
								start_node_index_partition[zi].root_node_index 		= start_node_index[j].root_node_index;
								for(int64_t zj=0;zj<parameter_input_bit_width;zj++){
									start_node_index_partition[zi].expand_input_bit_index[zj] = start_node_index[j].expand_input_bit_index[zj];
									start_node_index_partition[zi].expand_input_bit_data[zj]  = start_node_index[j].expand_input_bit_data[zj];
								}

								zi ++;
							}
						}
						area_parts[i] =  search_order(start_node_partition , start_node_depth, start_node_index_partition, search_order_times, start_order);
						area += area_parts[i];
						arr_delete ( start_node_index_partition);
					}
					
				}
				if(area<best_area){
					best_area = area;
					best_partition_parts = partition_parts;
					for (int64_t i=0;i<max_partition_parts;i++){
						for(int64_t j=0;j<max_partition_parts;j++){
							best_partition_sets[i][j] = partition_sets[i][j];
						}
						best_area_parts[i] = area_parts[i];
					}
					merge_success = 1;
				}
				cout<<"###########################################################################"<<endl;
				cout<<"Design Area:		"<<area<<endl;
				for (int64_t i=0;i<partition_parts;i++){
					cout<<"partition "<<i<<"	";
					for (int64_t j = 0;j<max_partition_parts;j++){
						cout<<partition_sets[i][j];
					}
					cout<<"	"<<area_parts[i]<<endl;
				}
				cout<<"Best Design Area:	"<<best_area<<endl;
			
				char* 	    start_node_index_string = new char [parameter_output_bit_width+1];
				ofstream function_top_file("rtl/function_top.v");
				for (int64_t i = 0 ;i < best_partition_parts;i++){
					for (int64_t j=0;j<parameter_output_bit_width;j++){
						if(best_partition_sets[i][j]){
							start_node_index_string[j] = '1';
						}
						else{
							start_node_index_string[j] = '0';
						}
						
					}
					start_node_index_string[parameter_output_bit_width] = '\0';
 					function_top_file << "`include \"function_layer_"<<start_node_depth<<"_nodes_"<<start_node_index_string<<".v\" "<<endl;
 				}
				function_top_file << endl;
				function_top_file << "module function_top (i,o);"<<endl<<endl;
 				function_top_file << "input 	["<<PI_WIDTH-1<<":0] i;"<<endl; 
 				function_top_file << "output	["<<parameter_output_bit_width-1<<":0]  o;"<<endl<<endl;
				for (int64_t i = 0 ;i < best_partition_parts;i++){
 					function_top_file << "wire	["<<parameter_output_bit_width-1<<":0]  o_"<<i<<";"<<endl;
 				}
				function_top_file << endl;
				for (int64_t i = 0 ;i < best_partition_parts;i++){
					for (int64_t j=0;j<parameter_output_bit_width;j++){
						if(best_partition_sets[i][j]){
							start_node_index_string[j] = '1';
						}
						else{
							start_node_index_string[j] = '0';
						}
						
					}
					start_node_index_string[parameter_output_bit_width] = '\0';
 					function_top_file << "function_layer_"<<start_node_depth<<"_nodes_"<<start_node_index_string<<"	part"<<i<<"	(.i(i),.o_index(o_"<<i<<"));"<<endl;
 				}
				function_top_file <<endl;
				for (int64_t i = 0 ;i < parameter_output_bit_width;i++){
					int64_t position_a = 0;
					for (int64_t j=0;j<best_partition_parts;j++){
							if(best_partition_sets[j][i] == 1){
								position_a = j;
								break;
							}
					}
 					function_top_file << "assign	o["<<i<<"]	=	o_"<<position_a<<"["<<i<<"];"<<endl;
 				}
				function_top_file << "endmodule"<<endl;
				function_top_file.close();

				cout<<"###########################################################################"<<endl;
				if(merge_success)
					break;
			}
			if(merge_success)
				break;
		}
		if(use_part==(partition_parts-1))
			break;
	}
				
	cout<<"###########################################################################"<<endl;
	cout<<"Best Design Area:		"<<best_area<<endl;
				for (int64_t i=0;i<best_partition_parts;i++){
					cout<<best_area_parts[i]<<endl;
				}

	cout<<"###########################################################################"<<endl;
	arr2d_delete(partition_sets,max_partition_parts);
	arr2d_delete(best_partition_sets,max_partition_parts);

	arr_delete( area_parts 	);
	arr_delete( best_area_parts 	);

	return 0;
};
int64_t BSD_execute(int64_t start_node_number, node_index* start_node_index,int64_t variable_order_depth, int64_t* variable_order){

	cout<<"BSD execute start"<<endl;	
	static BDD_class BDD_class_main;
	cout<<"This variable order: "<<variable_order_depth<<endl;
	//BDD_class_main.output_partition_set 	= output_partition_set;
	BDD_class_main.which_demo_function 	= GLOBAL_which_demo_function;
	BDD_class_main.BSD_variable_order_depth = variable_order_depth;
	//for (int64_t vi=0;vi<partition_parts;vi++){
	//	BDD_class_main.BSD_variable_order_number = variable_order_number;
	//	for(int64_t i=0;i<variable_order_number;i++){
	//		BDD_class_main.BSD_variable_order[vi][i] = variable_order[vi][i];
	//		cout<<BDD_class_main.BSD_variable_order[vi][i]<<" ";
	//	}
	//	cout<<endl;
	//}
	//cout<<endl;
		for(int64_t i=0;i<variable_order_depth;i++){
			BDD_class_main.BSD_variable_order[i] = variable_order[i];
			cout<<BDD_class_main.BSD_variable_order[i]<<" ";
		}
		cout<<endl;
	cout<<endl;


	BDD_class_main.start_depth 	= 0;	
	BDD_class_main.BDD_id 	= 0;
	BDD_class_main.how_many_start_nodes = start_node_number;
	BDD_class_main.start_nodes = new BDD_node [BDD_class_main.how_many_start_nodes];
	for(int64_t zi=0;zi<BDD_class_main.how_many_start_nodes;zi++){
		BDD_class_main.start_node_index[zi].node_depth 		= start_node_index[zi].node_depth;
		BDD_class_main.start_node_index[zi].root_node_index 	= start_node_index[zi].root_node_index;
		for(int64_t zj=0;zj<parameter_input_bit_width;zj++){
			BDD_class_main.start_node_index[zi].expand_input_bit_index[zj] = start_node_index[zi].expand_input_bit_index[zj];
			BDD_class_main.start_node_index[zi].expand_input_bit_data[zj]  = start_node_index[zi].expand_input_bit_data[zj];
		}
		BDD_class_main.start_nodes[zi].which_bit_output 	= start_node_index[zi].root_node_index;
		BDD_class_main.start_nodes[zi].which_root_node  	= start_node_index[zi].root_node_index;
		BDD_class_main.start_nodes[zi].which_root_node_all[BDD_class_main.start_nodes[zi].which_root_node] = 1;
	}
	for(int64_t zi=0;zi<parameter_input_bit_width+1;zi++){
		BDD_class_main.has_been_unfold[zi] = 0;
		BDD_class_main.most_influence[zi] = 0;
		BDD_class_main.BDD_width_each_layer[zi] = 0;
	}

	BDD_class_main.partition_depth = 1000000;
	BDD_class_main.partition_parts = 1;

	BDD_class_main.BDD_FULL_PROCESS();

	for(int64_t zi=0;zi<parameter_input_bit_width;zi++){
		variable_order[zi] = BSD_features_0.variable_order [zi] ;
	}
	double reward = search_reward(BSD_features_0);

#ifndef BSD_COV_DATASET_REPLAY
	arr_delete(BDD_class_main.start_nodes) ;
#endif
	return reward;	

};

double search_reward(BSD_features BSD_features_0){
	double	reward = 0;//(1000000*double(1-BSD_features_0.accuracy));
	reward += BSD_features_0.BSD_area;
	if(BSD_features_0.accuracy <parameter_early_stop_accuracy)
		reward = int64_t(1.2*reward) +int64_t(1000000*double(1-BSD_features_0.accuracy)) + BSD_features_0.accuracy;
	cout<<"BSD accuracy:	"<< BSD_features_0.accuracy <<endl;
	cout<<"BSD area:	"<< BSD_features_0.BSD_area <<endl;
	//reward += int64_t(BSD_features_0.feature_area/100) ;

	return reward;	

};

double search_order(int64_t start_node_number = default_start_node_number, int64_t start_node_depth = 0, node_index* start_node_index = default_start_node_index,int64_t search_iterations = parameter_search_iterations, int64_t* start_order = default_start_order){
        
	arr2d_new(multi_variable_order,parameter_max_orders);
	//multi_variable_order = new int64_t* [parameter_max_orders];
	for (int64_t vi=0;vi<parameter_max_orders;vi++){
		multi_variable_order[vi] = new int64_t [parameter_input_bit_width+1];
		for (int64_t vj=0;vj<parameter_input_bit_width;vj++)
			multi_variable_order[vi][vj]=0;
	}

	double	best_area=9999999; 
	int64_t	best_reward=9999999; 
	int64_t	best_area_depth = 0;
	int64_t**	best_variable_order;

	int64_t*	best_BDD_split_nodes = new int64_t [parameter_input_bit_width];
	double*	best_areas	= new double [parameter_max_orders];
	int64_t*	best_rewards	= new int64_t [parameter_max_orders];
	double*	best_area_depths= new double [parameter_max_orders];
	for (int64_t vi=0;vi<parameter_max_orders;vi++){
		best_areas[vi] = 0;
		best_rewards[vi] = 0;
		best_area_depths[vi] = 0;
	}
	int64_t best_reward_max = 0;
	int64_t best_order_num=0;

	//best_variable_order = new int64_t* [parameter_max_orders];
	arr2d_new(best_variable_order,parameter_max_orders);
	for (int64_t vi=0;vi<parameter_max_orders;vi++){
		best_variable_order[vi] = new int64_t [parameter_input_bit_width+1];
		for (int64_t vj=0;vj<parameter_input_bit_width;vj++)
			best_variable_order[vi][vj]=0;
	}

	double area =0;
	int64_t reward =0;
	int64_t	mutation_depth =0;
	random_device rd;	
	mt19937 gen(rd());

	double*	feature_variable = new double [parameter_input_bit_width];
		for (int64_t vj=0;vj<parameter_input_bit_width;vj++)
			feature_variable[vj]=0;

	double best_area_0;
	double best_area_10;
	double best_area_100;
	double best_area_1000;

	int64_t	best_iteration = 0;
	int64_t	partition_depth = 1000000;
	int64_t	partition_parts = 2;	
	int64_t	best_partition_depth = 1000000;
	int64_t	best_partition_parts = 2;	
	int64_t learning_rate;
	cout<<"Start search order"<<endl;
	for (int64_t i=0;i<search_iterations;i++){

				GLOBAL_BDD_id_number += 1;

	
		int64_t parameter_learning_rate = 2;
		if(best_area > 10000){
			parameter_learning_rate =6;
		}
		else if(best_area > 6000)
			parameter_learning_rate =5;
		else if(i-best_iteration > 2000)	
			parameter_learning_rate =4;
		else if(i-best_iteration > 800)	
			parameter_learning_rate =3;
		learning_rate = 1+gen()%parameter_learning_rate;
		//learning_rate = 1;
		mutation_depth =  int64_t(best_area_depth/2);
		if(mutation_depth > best_area_depth)
			mutation_depth = best_area_depth;

		int64_t	min_feature = 9999999;
		cout<<"Current best variable order: "<<endl;
		for(int64_t vj=0;vj<parameter_max_orders;vj++){
			if(i==0){
				for(int64_t vi=0;vi<best_area_depth;vi++){
					multi_variable_order[vj][vi] = start_order[vi];
					//cout<<multi_variable_order[vj][vi]<<" ";
				}
			}
			else{
				for(int64_t vi=0;vi<max(best_area_depth,parameter_input_bit_width);vi++){
					multi_variable_order[vj][vi] = best_variable_order[vj][vi];
					//cout<<multi_variable_order[vj][vi]<<" ";
				}
			}
			//cout<<endl;
		}
		cout<<endl;
			
			int64_t order_num = gen()%parameter_max_orders;
			if(i<parameter_max_orders)
				order_num = 0;
			//else if (i==search_iterations){
			//	int64_t best_reward_tmp = 999999;
			//	int64_t min_best_order = 0;
			//	for(int64_t zi=0;zi<parameter_max_orders;zi++){
			//		if(best_rewards[zi] < best_reward_tmp){
			//			best_reward_tmp = best_rewards[zi];
			//			min_best_order = zi;
			//		}
			//	}
			//	order_num = min_best_order;
			//	cout<<"Best order num	"<<order_num<<endl;
			//}
			

			//if(gen()%4==0){
			//	order_num = max_best_order;
			//}
		//if(i<100)
		// 	learning_rate= int64_t((100-i)/10);
		//else
		// 	learning_rate= 2;
		learning_rate=1;
		for (int64_t zi=0;zi<learning_rate;zi++){	
			//for(int64_t vv = 0;vv<parameter_max_orders;vv++){	
				int64_t vv = order_num;
			if(i<parameter_max_orders){
					vv=0;
			}else if (i==search_iterations){
			}
			else{
				best_area_depth = best_area_depths[vv];
			      //for(int64_t vi=1;vi<best_area_depth;vi++){
			      //	if( (gen()%int64_t(1+best_area_depth)==0)){
			      //		int64_t vii = vi-1;
			      //		int64_t x = variable_order[vv][vi];
			      //		variable_order[vv][vi] = variable_order[vv][vii];
			      //		variable_order[vv][vii] = x;
			      //		//double y = variable_features[vi];
			      //		//variable_features[vi] = variable_features[vii];
			      //		//variable_features[vii] = y;
			      //		break;
			      //	}
			      //}
			      int64_t num_a = gen()%int64_t(best_area_depth-1);
			      //int64_t num_b = gen()%int64_t(1+best_area_depth/4);
			      int64_t num_c = gen()%int64_t(1+best_area_depth/2);
			      int64_t num_b =  gen()%int64_t(1+best_area_depth/2);
			      cout<<"order number	"<<order_num<<endl;
			      cout<<"num_a:	"<<num_a<<"	num_b:	"<<num_b<<"	num_c:	"<<num_c<<endl;
			      for(int64_t vc=0;vc<num_c;vc++){
			      	int64_t x = multi_variable_order[vv][num_a];
			        	for (int64_t vj=0;vj<num_b+num_c;vj++){
			        		if( (vj==(num_b+num_c-1))){
			            			multi_variable_order[vv][(num_a + vj)%int64_t(best_area_depth)] =x;
			        		}
			        		else
			        			multi_variable_order[vv][(num_a + vj)%int64_t(best_area_depth)] = multi_variable_order[vv][(num_a + vj+1)%int64_t(best_area_depth)];
			        	}
			      }
	
			      //for(int64_t vi=0;vi<best_area_depth;vi++){
			      //	for(int64_t vj=0;vj<vi;vj++){
			      //		if(variable_order[vv][vi] == variable_order[vv][vj]){
			      //			for(int64_t vk=0;vk<best_area_depth-vi-1;vk++)
			      //				variable_order[vv][vi+vk] = variable_order[vv][vi+vk+1];
			      //		}
			      //	}
			      //}
			      
				//int64_t num_d = gen()%int64_t(1+best_area_depth);
				//int64_t num_e = gen()%int64_t(1+best_area_depth);
			      	//int64_t x = variable_order[vv][num_d];
			      	//variable_order[vv][num_d] = variable_order[vv][num_e];
			      	//variable_order[vv][num_e] = x;
			}
			//}
			  	
		}     			
		

					//for (int64_t vj=0;vj<parameter_max_orders;vj++){
					//	for(int64_t vi=0;vi<parameter_input_bit_width;vi++){
					//		cout<<variable_order[vj][vi]<<" ";
					//		//variable_features[vi] = double(BSD_features_0.BDD_width_each_layer[vi+1]) / double(BSD_features_0.BDD_width_each_layer[vi]);
					//		//cout<<variable_features[vi]<<"	";
					//	}
					//	cout<<endl;
					//}

		//for(int64_t j=mutation_depth;j<parameter_input_bit_width;j++){
		//	for (int64_t vi=0;vi<parameter_input_bit_width;vi++){
		//		if(feature_variable[vi]<min_feature){
		//			min_feature = feature_variable[vi];
		//			variable_order[j] = vi;
		//		}
		//	}
		//	min_feature = 9999999;
		//	feature_variable[variable_order[j]] = 9999999;

		//}
		node_index* start_node_index_copy = new node_index [start_node_number];
		for(int64_t zi=0;zi<start_node_number;zi++){
				start_node_index_copy[zi].node_depth 		= start_node_index[zi].node_depth;
				start_node_index_copy[zi].root_node_index 	= start_node_index[zi].root_node_index;
				for(int64_t zj=0;zj<parameter_input_bit_width;zj++){
					start_node_index_copy[zi].expand_input_bit_index[zj] = start_node_index[zi].expand_input_bit_index[zj];
					start_node_index_copy[zi].expand_input_bit_data[zj]  = start_node_index[zi].expand_input_bit_data[zj];
				}

		}
		if (i<parameter_max_orders){
			//parameter_max_samples 		= int64_t(parameter_max_samples/10);		//BSD每一个节点最多进行多少次采样
			reward = 	BSD_execute(start_node_number,start_node_index_copy,start_node_depth,multi_variable_order[order_num]);
			//parameter_max_samples 		*= 10;		//BSD每一个节点最多进行多少次采样
		}
		//else if (i<parameter_max_orders){
		//	reward = 	BSD_execute(0,variable_order,partition_depth,partition_parts,0,output_partition_set);
		//}
		else if (i==search_iterations-1){
			parameter_early_stop_split_nodes = 9999999;
			reward = 	BSD_execute(start_node_number,start_node_index_copy,best_area_depth,best_variable_order[order_num]);
			break;
		}
		else{
			reward = 	BSD_execute(start_node_number,start_node_index_copy,best_area_depth,multi_variable_order[order_num]);
		}
		arr_delete(start_node_index_copy);
		#ifdef SEARCH_PARTITION
		#else
			char* start_node_index_string = new char [parameter_output_bit_width+1];
			ofstream function_top_file("rtl/function_top.v");
			for (int64_t j=0;j<parameter_output_bit_width;j++){
					start_node_index_string[j] = '1';
			}
			start_node_index_string[parameter_output_bit_width] = '\0';
	 		function_top_file << "`include \"function_layer_"<<start_node_depth<<"_nodes_"<<start_node_index_string<<".v\" "<<endl;
			function_top_file << endl;
			function_top_file << "module function_top (i,o);"<<endl<<endl;
	 		function_top_file << "input 	["<<PI_WIDTH-1<<":0] i;"<<endl; 
	 		function_top_file << "output	["<<parameter_output_bit_width-1<<":0]  o;"<<endl<<endl;
			for (int64_t i = 0 ;i < 1;i++){
	 			function_top_file << "wire	["<<parameter_output_bit_width-1<<":0]  o_"<<i<<";"<<endl;
	 		}
			function_top_file << endl;
				
	 		function_top_file << "function_layer_"<<start_node_depth<<"_nodes_"<<start_node_index_string<<"	part1	(.i(i),.o_index(o_0));"<<endl;
			function_top_file <<endl;
			for (int64_t i = 0 ;i < parameter_output_bit_width;i++){
	 			function_top_file << "assign	o["<<i<<"]	=	o_0["<<i<<"];"<<endl;
	 		}
			function_top_file << "endmodule"<<endl;
			function_top_file.close();
			arr_delete(start_node_index_string);
		#endif

		bool accept=0;
			//accept = (reward <= best_reward);
			double accept_ratio = double(reward) / double(best_reward_max);
			if(i<parameter_max_orders)
				accept = 1;
			else if(accept_ratio < 1)
				accept = 1;
			else if (accept_ratio == 1){
				if(gen()%2 == 0)
					accept = 1;
				else 
					accept = 0;
			}
			else if (accept_ratio > 1.1)
				accept = 0;
			else {
				int64_t k = (1.1-accept_ratio)*100;
				if(gen()%40<k)
					accept = 1;
				else
					accept = 0;	
			}
			if(accept){
				int64_t replace_order;
					replace_order = order_num;
					int64_t best_reward_tmp = 0;
					if(i>=parameter_max_orders){
						for(int64_t zi=0;zi<parameter_max_orders;zi++){
							if(best_rewards[zi] > best_reward_tmp){
								best_reward_tmp = best_rewards[zi];
								replace_order = zi;
							}
						}
					}
					else{
						replace_order = i;
					}
					
				if(i==0){
					for (int64_t zi=0;zi<1;zi++){
						replace_order = zi;
						best_iteration = i;
						if(reward<best_reward){
							best_reward = reward;
							best_area = BSD_features_0.BSD_area;
							best_area_depth = BSD_features_0.BSD_depth;
						}
						best_rewards[replace_order] = reward;
						best_areas[replace_order] = BSD_features_0.BSD_area;
						best_area_depths[replace_order] = BSD_features_0.BSD_depth;
						best_partition_depth = partition_depth;
						best_partition_parts = partition_parts;
								for(int64_t vi=0;vi<parameter_input_bit_width;vi++){
									best_variable_order[replace_order][vi] = multi_variable_order[order_num][vi];
									//cout<<best_variable_order[replace_order][vi]<<" ";
									best_BDD_split_nodes[vi] = BSD_features_0.BSD_area_layers[vi];
								}
								//cout<<endl;
						}
						best_reward_max = 0;	
						best_order_num = 0;	
						for(int64_t zi=0;zi<parameter_max_orders;zi++){
							if(best_rewards[zi] > best_reward_max)
								best_reward_max = best_rewards[zi];
							if(best_rewards[zi] == best_reward)
								best_order_num = zi;	
						}
						if(best_reward_max<1000)
							parameter_early_stop_split_nodes = 4000;
						else
							parameter_early_stop_split_nodes = int64_t(best_reward_max*4);

				}else{
					best_iteration = i;
					if(reward<best_reward){
						best_reward = reward;
						best_area = BSD_features_0.BSD_area;
						best_area_depth = BSD_features_0.BSD_depth;
					}
					best_rewards[replace_order] = reward;
					best_areas[replace_order] = BSD_features_0.BSD_area;
					best_area_depths[replace_order] = BSD_features_0.BSD_depth;
					best_partition_depth = partition_depth;
					best_partition_parts = partition_parts;
							for(int64_t vi=0;vi<parameter_input_bit_width;vi++){
								best_variable_order[replace_order][vi] = multi_variable_order[order_num][vi];
								//cout<<best_variable_order[replace_order][vi]<<" ";
								best_BDD_split_nodes[vi] = BSD_features_0.BSD_area_layers[vi];
							}
							//cout<<endl;
					best_reward_max = 0;	
					best_order_num = 0;	
					for(int64_t zi=0;zi<parameter_max_orders;zi++){
						if(best_rewards[zi] > best_reward_max)
							best_reward_max = best_rewards[zi];
						if(best_rewards[zi] == best_reward)
							best_order_num = zi;	
					}
					if(i>=parameter_max_orders)
						if(best_reward_max<1000)
							parameter_early_stop_split_nodes = 4000;
						else
								parameter_early_stop_split_nodes = int64_t(best_reward_max*4);


					if((i>=10) && (best_reward_max < 1.005*best_reward))
						break;

				}

				cout<<"#############################"<<endl;
				cout<<"#    This order accept      #"<<endl;
				cout<<"#############################"<<endl;
			}
			if(parameter_early_stop_split_nodes<4*best_reward_max)
				parameter_early_stop_split_nodes += 100;
							cout<<endl;
			cout<<"Best Iteration:	"<<best_iteration<<endl;
			cout<<"This Iteration:	"<<i<<endl;
			cout<<"Reward:		"<<reward<<endl;
			cout<<"Best Reward:	"<<best_reward<<endl;
			cout<<"Area:		"<<BSD_features_0.BSD_area<<endl;
			cout<<"Best Area:	"<<best_area<<endl;


			cout<<endl;
			cout<<"Best Reward Max:	"<<best_reward_max<<endl;
			for(int64_t zi=0;zi<parameter_max_orders;zi++){
				cout<<"Reward["<<zi<<"]	"<<best_rewards[zi]<<endl;
			}
			cout<<"Best Order:	";
			for (int64_t vj=0;vj<parameter_input_bit_width;vj++){
				//cout<<best_variable_order[best_order_num][vj];
				//cout<<start_order[vj]<<" ";
			}
			//cout<<endl;
			//cout<<"Best Design Area:	"<<BSD_features_0.BSD_area<<endl;
			cout<<endl;
		}
				
	//area = 	BSD_execute(parameter_input_bit_width,best_variable_order,10000,best_partition_parts,best_order_num,output_partition_set);

	arr_delete( best_BDD_split_nodes );
	arr_delete( best_areas	);
	arr_delete( best_rewards)	;
	arr_delete( best_area_depths);
	arr2d_delete (multi_variable_order,parameter_max_orders);
	arr2d_delete(best_variable_order,parameter_max_orders);
	//arr2d_delete (best_variable_order,1);
	//delete [] best_variable_order[0];
	//for(int64_t i=0;i<parameter_input_bit_width;i++)
	//	cout<<best_variable_order[0][i];
	//delete [] best_variable_order[0];
	//delete [] best_variable_order;
	
	return reward;
};

