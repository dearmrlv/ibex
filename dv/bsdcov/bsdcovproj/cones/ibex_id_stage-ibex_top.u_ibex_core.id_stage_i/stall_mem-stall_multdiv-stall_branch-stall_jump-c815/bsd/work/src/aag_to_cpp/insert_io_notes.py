import argparse
import os
import re
import signal
import subprocess
import json
import subprocess

def run_with_timeout(cmd, timeout):
    try:
        proc = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            errors='replace',
            start_new_session=True
        )
        stdout, stderr = proc.communicate(timeout=timeout)
        return proc.returncode, stdout, stderr
    except subprocess.TimeoutExpired:
        os.killpg(proc.pid, signal.SIGTERM)
        try:
            stdout, stderr = proc.communicate(timeout=5)
        except subprocess.TimeoutExpired:
            os.killpg(proc.pid, signal.SIGKILL)
            stdout, stderr = proc.communicate()
        return -9, stdout, stderr
    
def get_io_widths(vpath, top_module):
    # if top_module is not None:
    #     script = f"read_verilog -sv {vpath}; synth -top {top_module};" # modified by liuguilan
    # else:
    #     script = f"read_verilog -sv {vpath}; synth -auto-top;" # modified by liuguilan
    # cmd = ["yosys", "-p", script]
    # #breakpoint()
    # retcode, stdout, stderr = run_with_timeout(cmd, timeout=60)
    # if retcode != 0:
    #     raise RuntimeError(f"Yosys failed with return code {retcode}:\nSTDOUT:\n{stdout}\nSTDERR:\n{stderr}")
    # input_pattern = r"ABC RESULTS:\s+input signals:\s+(\d+)"
    # output_pattern = r"ABC RESULTS:\s+output signals:\s+(\d+)"
    # yosys_log = stdout.split("Re-integrating ABC results.")[-1]
    # n_inputs = int(re.findall(input_pattern, yosys_log)[0])
    # n_outputs = int(re.findall(output_pattern, yosys_log)[0])
    # return n_inputs, n_outputs

    # 下面这个不会对unload和undrive的端口进行优化，如果要使用优化的就使用上面那段被注释掉的
    # 1. 构建 Yosys 脚本
    # 使用 hierarchy 建立层级，但不运行 proc 或 opt，这样保留原始端口
    if top_module:
        # -check 选项用于检查完整性，但在提取端口时不强制要求
        script = f"read_verilog -sv {vpath}; hierarchy -top {top_module}; write_json -;"
    else:
        script = f"read_verilog -sv {vpath}; hierarchy -auto-top; write_json -;"

    cmd = ["yosys", "-p", script, "-q"] # -q 减少 log 噪音
    # 2. 运行 Yosys
    try:
        # 增加 encoding='utf-8' 防止解码错误
        result = subprocess.run(
            cmd, 
            stdout=subprocess.PIPE, 
            stderr=subprocess.PIPE, 
            timeout=60, 
            check=True,
            encoding='utf-8' 
        )
        stdout = result.stdout
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"Yosys failed:\nSTDOUT:\n{e.stdout}\nSTDERR:\n{e.stderr}")

    # 3. 解析 JSON 输出
    try:
        yosys_data = json.loads(stdout)
        modules = yosys_data.get("modules", {})
        
        # 确定目标模块的名称
        target_mod_name = None
        if top_module:
            # Yosys 内部模块名通常会加反斜杠前缀，如 "\top"
            # 但 write_json 有时会保留原始名称，这里做兼容处理
            if top_module in modules:
                target_mod_name = top_module
            elif f"\\{top_module}" in modules:
                target_mod_name = f"\\{top_module}"
        else:
            # 如果是 auto-top，寻找被标记为 top 的模块
            # 或者如果只有一个模块，直接取该模块
            if len(modules) == 1:
                target_mod_name = list(modules.keys())[0]
            else:
                # 遍历寻找 attributes 中包含 top 标记的模块
                for name, mod in modules.items():
                    attrs = mod.get("attributes", {})
                    # Yosys 中 top 属性通常标记为 1
                    if "top" in attrs or "\\top" in attrs:
                        target_mod_name = name
                        break
        
        if not target_mod_name:
            raise ValueError("Could not determine top module from Yosys JSON output.")

        # 4. 统计端口位宽
        ports = modules[target_mod_name]["ports"]
        n_inputs = 0
        n_outputs = 0

        for port_name, port_data in ports.items():
            direction = port_data["direction"]
            width = len(port_data["bits"]) # bits 列表的长度即为位宽

            if direction == "input":
                n_inputs += width
            elif direction == "output":
                n_outputs += width
            elif direction == "inout":
                # 根据需求，inout 可以既算输入也算输出，或者单独统计
                # 这里简单处理，两边都加，或者你可以只加到 inputs
                n_inputs += width
                n_outputs += width

        return n_inputs, n_outputs

    except json.JSONDecodeError:
        raise RuntimeError("Failed to parse Yosys JSON output.")
    except Exception as e:
        raise RuntimeError(f"Error analyzing ports: {str(e)}")

def insert_io_notes(input_path, output_path, top_module):
    n_inputs, n_outputs = get_io_widths(input_path, top_module=top_module)
    note = f"// Ninputs {n_inputs}\n// Noutputs {n_outputs}\n\n"

    with open(input_path, "r") as f:
        verilog_code = f.read()
    
    modified_code = note + verilog_code

    with open(output_path, "w") as f:
        f.write(modified_code)

def main():
    parser = argparse.ArgumentParser(description="在verilog代码前插入IO位数注释.")
    parser.add_argument("input_path", help="Path to the input Verilog file.")
    parser.add_argument("-o", "--output_path", help="Path to the output Verilog file. Default using same path as input file.", default=None)
    parser.add_argument("-t", "--top_name", help="Top module name. Default using yosys auto-top command.", default=None)
    args = parser.parse_args()

    if args.output_path is None:
        args.output_path = args.input_path

    insert_io_notes(args.input_path, args.output_path, top_module=args.top_name)

if __name__ == "__main__":
    main()
