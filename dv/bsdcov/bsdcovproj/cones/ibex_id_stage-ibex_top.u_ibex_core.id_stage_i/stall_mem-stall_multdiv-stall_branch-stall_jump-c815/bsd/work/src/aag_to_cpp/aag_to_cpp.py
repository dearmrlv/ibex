from encodings.punycode import T
import os
import argparse


def aag_to_cpp(aag_path, header_path, src_path, cpp_func_name, ignore=False, quiet=False):
    """
    Convert *.aag files to C++ *.h files.
    Args:
        aag_path (str): Path to the *.aag file
        header_path (str): Path to the generated *.h file
        src_path (str): Path to the generated *.cpp file
        cpp_func_name (str): Name of the generated C++ function
        ignore (bool): Ignore existing C++ file and overwrite it
        quiet (bool): Execute the program quietly without printing messages
    Returns:
        dict: A dictionary containing the number of primary inputs, latches, and primary outputs
    """
    # 检查cpp文件是否存在
    if os.path.exists(src_path) and ignore is False:
        overwrite = input(
            f"Warning: {src_path} exists! \nOverwrite existing C++ file? (y/n)"
        )
        if overwrite.lower() != "y":
            raise Exception("Existing C++ file is NOT overwritten.")
        elif not quiet:
            print(f"{src_path} will be overwritten.")
    if os.path.exists(header_path) and ignore is False:
        overwrite = input(
            f"Warning: {header_path} exists! \nOverwrite existing C++ file? (y/n)"
        )
        if overwrite.lower() != "y":
            raise Exception("Existing C++ file is NOT overwritten.")
        elif not quiet:
            print(f"{header_path} will be overwritten.")
    # 检查aag文件是否存在
    if not os.path.exists(aag_path):
        raise Exception(f"Error: {aag_path} does not exist!")
    # 检查AIG文件是否为ASCII格式
    with open(aag_path, "r") as f:
        aag_lines = f.readlines()
    if not aag_lines[0].startswith("aag"):
        raise Exception(f"Error: {aag_path} is not an ascii AIG file!")
    # 读AIG的第一行，提取变量数 输入数 latch数 输出数 AND门数
    # 第一行为aag M I L O A, 其中要求M = I + L + A
    M, I, L, O, A = map(int, aag_lines[0].split()[1:])
    # 从以下开始, 读输入，输出，AND门的ID，转为C++函数
    header_lines = [f"#ifndef {cpp_func_name.upper()}_H", f"#define {cpp_func_name.upper()}_H"]
    src_lines = []
    #src_lines = [f'#include "{os.path.basename(header_path) }"']
    header_lines.append(f"extern const int PI_WIDTH = {I};")
    # cpp_lines.append(f"extern const int LATCH_WIDTH = {L};")
    header_lines.append(f"extern const int PO_WIDTH = {O};")
    if L > 0:
        header_lines.append(f"void {cpp_func_name}(bool* pi, bool* li, bool* po, bool* lo);")
        src_lines.append(f"void {cpp_func_name}(bool* pi, bool* li, bool* po, bool* lo) {{")
    elif L == 0:
        header_lines.append(f"void {cpp_func_name}(bool* pi, bool* po);")
        src_lines.append(f"void {cpp_func_name}(bool* pi, bool* po) {{")
    else:
        raise Exception("Error: Latch number L < 0!")
    
    output_nodes = []
    for i, line in enumerate(aag_lines):
        if i < 1:
            src_lines.append("    bool n0 = false;")
            continue
        # 输入
        if 1 <= i < I + 1:
            idx = int(line)
            src_lines.append(f"    bool n{idx//2} = pi[{idx//2 - 1}];")
            continue
        # 锁存器
        if I + 1 <= i < I + L + 1:
            li_id, lo_id = map(int, line.split())
            src_lines.append(f"    bool n{li_id//2} = li[{li_id//2 - I - 1}];")
            if lo_id % 2 == 1:
                output_nodes.append(f"    lo[{i-I-1}] = !n{lo_id//2};")
            else:
                output_nodes.append(f"    lo[{i-I-1}] = n{lo_id//2};")
            continue
        # 输出
        if I + L + 1 <= i < I + L + O + 1:
            idx = int(line)
            if idx % 2 == 1:
                output_nodes.append(f"    po[{i-I-L-1}] = !n{idx//2};")
            else:
                output_nodes.append(f"    po[{i-I-L-1}] = n{idx//2};")
            continue
        # AND门
        if I + L + O + 1 <= i < I + L + O + A + 1:
            node, left, right = map(int, line.split())
            and_gate = f"n{node//2}"
            left_gate = f"n{left//2}" if left % 2 == 0 else f"!n{left//2}"
            right_gate = f"n{right//2}" if right % 2 == 0 else f"!n{right//2}"
            src_lines.append(f"    bool {and_gate} = {left_gate} && {right_gate};")
            continue
        if line == "c\n":
            src_lines.extend(output_nodes)
            break
    src_lines.append("}")
    header_lines.append("#endif")
    with open(header_path, "w") as f:
        f.write("\n".join(header_lines))
    with open(src_path, "w") as f:
        f.write("\n".join(src_lines))
    if not quiet:
        print(f"Success: {header_path} and {src_path} has been generated!")
    io_info = {"pi_num": I, "latch_num": L, "po_num": O}

    return io_info



