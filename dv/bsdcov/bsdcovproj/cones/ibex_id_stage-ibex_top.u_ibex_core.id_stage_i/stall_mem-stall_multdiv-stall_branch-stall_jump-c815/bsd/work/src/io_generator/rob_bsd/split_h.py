import re
import os
import argparse
import sys

def get_object_name(header_content):
    """
    智能识别对象名。
    策略：直接在文件中查找谁调用了 simulator_to_po(po)。
    目标匹配: "prf.simulator_to_po(po);" 中的 "prf"
    """
    # 正则：匹配 变量名.simulator_to_po(po)
    # \w+ 匹配变量名
    # \.  匹配点
    # simulator_to_po 匹配函数名
    usage_pattern = re.compile(r"(\w+)\.simulator_to_po\s*\(")
    
    match = usage_pattern.search(header_content)
    if match:
        obj_name = match.group(1)
        print(f"[Info] Detected object name from function usage: '{obj_name}'")
        return obj_name
    
    # 如果没找到调用，尝试回退到查找定义 PRF xxx = {};
    print("[Warning] Could not detect usage 'xxx.simulator_to_po(...)'. Falling back to class definition search.")
    def_pattern = re.compile(r"PRF\s+([a-z]\w*)\s*=\s*{};")
    match_def = def_pattern.search(header_content)
    if match_def:
        obj_name = match_def.group(1)
        print(f"[Info] Detected object name from definition: '{obj_name}'")
        return obj_name

    # 最后的默认值
    print("[Warning] Could not detect object name. Defaulting to 'prf'.")
    return "prf"

def parse_and_unroll_logic(cpp_content, obj_name):
    """
    解析 simulator_to_po 函数，并将循环完全展开。
    """
    # 1. 定位 simulator_to_po 函数体
    start_pattern = r"void\s+\w+::simulator_to_po\s*\(\s*bool\s*\*\s*po\s*\)\s*\{"
    match = re.search(start_pattern, cpp_content)
    if not match:
        print("[Error] Could not find 'void X::simulator_to_po(bool* po)' function.")
        return []

    body_start = match.end()
    
    # 提取函数体
    open_braces = 1
    body_end = body_start
    for i, char in enumerate(cpp_content[body_start:], start=body_start):
        if char == '{':
            open_braces += 1
        elif char == '}':
            open_braces -= 1
            if open_braces == 0:
                body_end = i
                break
    
    func_body = cpp_content[body_start:body_end]
    lines = func_body.split('\n')
    
    actions = []
    
    # 正则：匹配 for 循环
    re_for = re.compile(r"for\s*\(\s*int\s+i\s*=\s*0\s*;\s*i\s*<\s*(\d+)\s*;\s*i\+\+\s*\)")
    # 正则：匹配 unpack_bits
    re_unpack = re.compile(r"unpack_bits\s*\(\s*cursor\s*,\s*(.+?)\s*,\s*(\d+)\s*\)\s*;")

    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if not line:
            i += 1
            continue
            
        # 情况 A: 遇到 For 循环 -> 展开它
        for_match = re_for.search(line)
        if for_match and '{' in line:
            loop_count = int(for_match.group(1))
            
            # 寻找循环体内的 unpack_bits
            j = i + 1
            target_expr = ""
            width = 0
            found_unpack = False
            
            while j < len(lines):
                sub_line = lines[j].strip()
                unpack_match = re_unpack.search(sub_line)
                if unpack_match:
                    target_expr = unpack_match.group(1) # 例如 out.prf2exe->iss_entry[i].valid
                    width = int(unpack_match.group(2))
                    found_unpack = True
                
                if '}' in sub_line:
                    i = j + 1 # 跳出外部循环
                    break
                j += 1
            
            if found_unpack:
                # 展开循环
                for k in range(loop_count):
                    # 替换下标 [i] -> [k]
                    current_expr = target_expr.replace('[i]', f'[{k}]')
                    
                    # 加上对象前缀
                    # 无论原始表达式是否已经有前缀，我们统一加上 obj_name.
                    # 如果原代码是 out.prf... -> prf.out.prf...
                    final_expr = f"{obj_name}.{current_expr}"
                    
                    code_line = f"unpack_bits(cursor, {final_expr}, {width});"
                    actions.append({'code': code_line, 'width': width})
            else:
                pass # 空循环或未识别到内容
            
            continue

        # 情况 B: 独立的 unpack_bits
        unpack_match = re_unpack.search(line)
        if unpack_match and 'for' not in line:
            raw_expr = unpack_match.group(1)
            width = int(unpack_match.group(2))
            
            final_expr = f"{obj_name}.{raw_expr}"
            
            code_line = f"unpack_bits(cursor, {final_expr}, {width});"
            actions.append({'code': code_line, 'width': width})
            i += 1
            continue
            
        i += 1
        
    return actions

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--template', type=str, default='prf_bsd.h')
    parser.add_argument('--cpp', type=str, default='PRF_cpp.h')
    parser.add_argument('--outdir', type=str, default='.')
    args = parser.parse_args()

    if not os.path.exists(args.template) or not os.path.exists(args.cpp):
        print("[Error] Input files not found.")
        sys.exit(1)

    with open(args.template, 'r', encoding='utf-8') as f:
        template_content = f.read()
    with open(args.cpp, 'r', encoding='utf-8') as f:
        cpp_content = f.read()

    # 1. 获取对象名 (修复点：通过 usage 获取)
    obj_name = get_object_name(template_content)

    # 2. 解析逻辑
    actions = parse_and_unroll_logic(cpp_content, obj_name)
    print(f"[Info] Generating {len(actions)} files...")

    if not os.path.exists(args.outdir):
        os.makedirs(args.outdir)

    current_bit = 0
    
    # 3. 构造替换 simulator_to_po 调用的正则
    # 匹配 prf.simulator_to_po(po); 或 prf.simulator_to_po(po)
    call_pattern = re.compile(re.escape(obj_name) + r"\.simulator_to_po\s*\(\s*po\s*\)\s*;?")

    for action in actions:
        width = action['width']
        start_bit = current_bit
        end_bit = current_bit + width - 1
        
        base_name = os.path.splitext(os.path.basename(args.template))[0]
        filename = f"{base_name}_{start_bit}_{end_bit}.h"
        filepath = os.path.join(args.outdir, filename)
        
        new_content = template_content
        
        # 替换 PO_WIDTH
        new_content = re.sub(
            r"extern const int PO_WIDTH = \d+;", 
            f"extern const int PO_WIDTH = {width};", 
            new_content
        )
        
        # 替换函数调用
        replacement_code =  "    // Generated Code Slice\n"
        replacement_code += "    bool* cursor = po;\n"
        replacement_code += "    " + action['code']
        
        if call_pattern.search(new_content):
            new_content = call_pattern.sub(replacement_code, new_content)
        else:
            # 如果正则没匹配到，尝试硬替换 prf.simulator_to_po(po);
            # 这种情况通常发生在 obj_name 识别为了 prf 但代码里写的不太一样，作为保底
            new_content = new_content.replace(f"{obj_name}.simulator_to_po(po);", replacement_code)

        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
            
        current_bit += width

    print(f"[Success] All files generated in '{args.outdir}'.")

if __name__ == "__main__":
    main()