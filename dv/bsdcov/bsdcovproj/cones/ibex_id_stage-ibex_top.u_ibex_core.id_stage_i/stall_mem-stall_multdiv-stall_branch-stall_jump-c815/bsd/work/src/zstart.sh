#export PATH=/lustre/S/chengshuyao/haoshiming/anaconda3/envs/BSD/bin:/bin:/lustre/S/chengshuyao/haoshiming/anaconda3/envs/BSD/bin:/lustre/S/chengshuyao/haoshiming/anaconda3/envs/BSD/bin/gcc
#export LIBRARY_PATH=/lustre/S/chengshuyao/haoshiming/anaconda3/envs/BSD/bin:/lustre/S/chengshuyao/haoshiming/anaconda3/envs/BSD/lib 
#export LD_LIBRARY_PATH=/lustre/S/chengshuyao/haoshiming/anaconda3/envs/BSD/bin:/lustre/S/chengshuyao/haoshiming/anaconda3/envs/BSD/lib
#export ASAN_OPTIONS=halt_on_error=0:detect_leaks=1:malloc_context_size=15:log_path=./asan.log
rm rtl/*
#bash write_vec.sh
#g++  -fno-omit-frame-pointer -fsanitize=address  -g BSD.cpp -O3 -std=c++11 -fopenmp
g++  BSD.cpp -O3 -std=c++11 -fopenmp -I./io_generator/simulator_include
./a.out 
