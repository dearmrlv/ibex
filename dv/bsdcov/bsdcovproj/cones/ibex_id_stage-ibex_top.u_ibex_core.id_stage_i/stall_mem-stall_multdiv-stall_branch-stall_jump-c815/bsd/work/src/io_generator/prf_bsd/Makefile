# 这个文件暂时用来对启蒙3好的模块.h进行按变量分解
# --template参数后面跟io_generator的.h
# --cpp参数后面跟模拟器模块的C代码的.h
# --outdir参数后面跟输出文件路径

run_python:
	python3 split_h.py --template ./prf_bsd.h --cpp ../simulator_include/PRF_cpp.h --outdir .

clean:
	rm -rf *_bsd_*_*.h