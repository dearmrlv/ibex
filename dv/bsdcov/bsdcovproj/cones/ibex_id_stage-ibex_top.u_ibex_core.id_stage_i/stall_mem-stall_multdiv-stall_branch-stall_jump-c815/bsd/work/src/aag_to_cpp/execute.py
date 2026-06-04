from generate_top import *
import sys

if len(sys.argv) > 1:
    user_input = sys.argv[1]
    print("命令行参数是：", user_input)
else:
    print("没有提供命令行参数。")

verilog_top(user_input)
