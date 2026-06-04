#include"BSD_top.h"


int	main(int argc,char* argv[]){
    #ifdef DYNAMIC_SUFFIX
        struct stat info;
        if (stat("rtl_set", &info) != 0) { // 检查是否存在
            mkdir("rtl_set", 0777);      // 创建文件夹
        }
    #endif
	set_default();
	#ifdef SEARCH_PARTITION
		search_partition();
	#else
		search_order();
	#endif
};

