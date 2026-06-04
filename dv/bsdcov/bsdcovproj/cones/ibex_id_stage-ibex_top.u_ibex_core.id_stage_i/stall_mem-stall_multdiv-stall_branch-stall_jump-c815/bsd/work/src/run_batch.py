import os
import glob
import re
import subprocess
import time
import threading
import traceback
from concurrent.futures import ThreadPoolExecutor

# ================= 配置区域 =================

# 1. 头文件所在的目录 (根据你之前的反馈修正)
HEADER_DIR = "./io_generator/rob_bsd/" 
HEADER_PATTERN = "*_bsd_*.h" # 匹配模式

# 2. 输出文件夹配置 (会自动创建)
EXE_OUTPUT_DIR = "./build_bin"  # 存放编译好的可执行文件
LOG_OUTPUT_DIR = "./run_logs"   # 存放运行时的日志文件

# 3. 并发配置
MAX_PARALLEL_PROCESSES = 4
THREADS_PER_PROCESS = 64

# 4. 编译命令
# 注意：{exe_name} 现在会包含文件夹路径
BASE_COMPILE_CMD = "g++ BSD.cpp -o {exe_name} -O3 -std=c++11 -fopenmp -I./io_generator/simulator_include -I./io_generator"

# ===========================================

compile_lock = threading.Lock()

def ensure_directories_exist():
    """确保输出目录存在，不存在则创建"""
    if not os.path.exists(EXE_OUTPUT_DIR):
        os.makedirs(EXE_OUTPUT_DIR)
        print(f"[系统] 创建目录: {EXE_OUTPUT_DIR}")
    
    if not os.path.exists(LOG_OUTPUT_DIR):
        os.makedirs(LOG_OUTPUT_DIR)
        print(f"[系统] 创建目录: {LOG_OUTPUT_DIR}")

def compile_and_run(header_file):
    try:
        # --- 解析文件名 ---
        basename = os.path.basename(header_file)
        match = re.search(r'_(\d+_\d+)\.h$', basename)
        
        if not match:
            print(f"[跳过] 无法解析文件名: {header_file}")
            return

        suffix_id = match.group(1)
        
        # --- 路径构造 ---
        # 1. 可执行文件的完整路径 (例如: ./build_bin/program_0_0)
        unique_exe_name = f"program_{suffix_id}"
        exe_path = os.path.join(EXE_OUTPUT_DIR, unique_exe_name)
        
        # 2. 日志文件的完整路径 (例如: ./run_logs/log_0_0.txt)
        log_file_path = os.path.join(LOG_OUTPUT_DIR, f"log_{suffix_id}.txt")

        # 3. 头文件的相对路径 (传给C++宏)
        full_include_path = os.path.relpath(header_file, start=".")
        
        print(f"[{suffix_id}] 准备处理 -> Log将写入: {log_file_path}")

        # --- 编译阶段 ---
        with compile_lock:
            # print(f"[{suffix_id}] 正在编译...")
            
            compile_flags = (
                f'-DDYNAMIC_HEADER=\\"{full_include_path}\\" '
                f'-DDYNAMIC_THREADS={THREADS_PER_PROCESS} '
                f'-DDYNAMIC_SUFFIX=\\"{suffix_id}\\"'
            )
            
            # 将 exe_path 填入命令
            cmd = BASE_COMPILE_CMD.format(exe_name=exe_path) + " " + compile_flags
            
            ret = subprocess.run(cmd, shell=True, stderr=subprocess.PIPE)
            if ret.returncode != 0:
                # 编译错误依然打印到主屏幕，方便你立刻发现代码问题
                print(f"[{suffix_id}] 编译失败！G++报错:\n{ret.stderr.decode(errors='ignore')}")
                return

        # --- 运行阶段 ---
        # print(f"[{suffix_id}] 编译完成，开始运行...")
        start_time = time.time()
        
        # 打开日志文件准备写入
        with open(log_file_path, "w", encoding='utf-8') as f_log:
            try:
                # stdout=f_log: 标准输出写入文件
                # stderr=subprocess.STDOUT: 错误输出也合并写入同一个文件
                subprocess.run(exe_path, shell=True, check=True, stdout=f_log, stderr=subprocess.STDOUT)
                
                duration = time.time() - start_time
                print(f"[{suffix_id}] 完成 (耗时 {duration:.2f}s) -> 查看日志: {log_file_path}")
                
            except subprocess.CalledProcessError:
                f_log.write(f"\n\n[脚本记录] 程序异常退出 (非0返回码)\n")
                print(f"[{suffix_id}] 运行出错，详情请查看日志文件。")

        # --- 清理阶段 ---
        # 运行完删除可执行文件，节省空间 (日志保留)
        if os.path.exists(exe_path):
            os.remove(exe_path)

    except Exception as e:
        print(f"[{header_file}] 发生脚本错误: {e}")
        traceback.print_exc()

def main():
    # 0. 初始化目录
    ensure_directories_exist()

    # 1. 查找文件
    headers = glob.glob(os.path.join(HEADER_DIR, HEADER_PATTERN))
    
    # 按数字排序
    def sort_key(fname):
        match = re.search(r'_(\d+)_', fname)
        return int(match.group(1)) if match else 0
    headers.sort(key=sort_key)
    
    print(f"找到 {len(headers)} 个任务文件，日志将存入 {LOG_OUTPUT_DIR}")
    print("-" * 50)

    # 2. 开始并发
    with ThreadPoolExecutor(max_workers=MAX_PARALLEL_PROCESSES) as executor:
        executor.map(compile_and_run, headers)
        
    print("-" * 50)
    print("所有任务已完成。")

if __name__ == "__main__":
    main()