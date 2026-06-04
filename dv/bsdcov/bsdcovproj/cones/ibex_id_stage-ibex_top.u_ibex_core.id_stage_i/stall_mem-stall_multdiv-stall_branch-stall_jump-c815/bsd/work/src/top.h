#include 	"head.h"

// 启蒙3号动态编译，编译开关带有“DYNAMIC”，用于对模块_bsd_数字_数字.h进行分进程动态编译
#ifndef DYNAMIC_HEADER
    #include	"io_generator/rob_bsd/rob_bsd.h"					//io_generator中需要包含对PI_WIDTH,PO_WIDTH的全局定义,如: extern const int64_t PI_WIDTH = 36;
#else
    #include DYNAMIC_HEADER
#endif

// #include   "io_generator_vec/c432_vec.h"				//如果有对应Verilog, 可以在aag_to_rtl里面直接生成2个文件	
// #define INPUT_AIG							//io_generator是否可以用uint64_t按位操作进行加速,也即是否包含_vec后缀的另一个io_generator
// #define SINGLE_BITS							//io_generator是否包含每一个bit单独的io_generator_o{x}

// #define SEARCH_PARTITION						//BSD算法搜索partition策略
// #define ACCURACY_FIRST						//精度优先算法: 慢且面积冗余大，在精度是瓶颈时使用，不作为默认选项。

#ifdef BSD_COV_EXACT_PI_WIDTH
extern const int64_t parameter_input_bit_width = PI_WIDTH;
#else
extern const int64_t parameter_input_bit_width = PI_WIDTH + 5;
#endif	
int64_t parameter_output_bit_width			= PO_WIDTH;			


extern const int64_t	parameter_search_iterations	= 1; 		//最大设计次数
#ifdef BSD_COV_TEST_IOS
extern const int64_t parameter_test_ios = BSD_COV_TEST_IOS;
#else
extern const int64_t parameter_test_ios = 100000000;
#endif	//测试要求多少样本
#ifdef BSD_COV_MAX_SAMPLES
extern const int64_t parameter_max_samples = BSD_COV_MAX_SAMPLES;
#else
extern const int64_t parameter_max_samples = 100000;
#endif		//BSD每一个节点最多进行多少次采样,至少为64
#ifdef BSD_COV_EARLY_STOP_ACCURACY
extern const double parameter_early_stop_accuracy = 1;
#else
extern const double parameter_early_stop_accuracy = 1;
#endif		//允许的错误率,如果完全不允许，设为1; 	
									//没有特殊需要不要设到<1，会慢一些。
									//0.5以下无意义，建议至少设到0.8吧.
extern const bool 	parameter_early_stop_oneway	= 1;		//如果设为1，只允许0->1 的错误，不允许1->0的错误
extern const int64_t	parameter_io_file_lines		= 2;		//在sample_input.set文件中，保存了最少parameter_use_io_file行input;保证每次采样，都能采到这些样本。

#ifndef DYNAMIC_THREADS
    #define DYNAMIC_THREADS 256
    // extern const int64_t 	parameter_num_threads		= 256;		//线程数
#endif
extern const int64_t parameter_num_threads = DYNAMIC_THREADS;

// 用于文件名尾部的字符串
#ifdef DYNAMIC_SUFFIX
    const std::string output_suffix = DYNAMIC_SUFFIX;
    // #define DYNAMIC_SUFFIX "default"
#endif


#ifndef BSD_COV_DISABLE_FAST_RANDOM
#define USE_FAST_RANDOM
#endif					//使用高性能随机数生成器 (Xoshiro256++)生成test_input_bits和train_input_bits，尤其当parameter_test_ios达到一亿的时候，建议启用