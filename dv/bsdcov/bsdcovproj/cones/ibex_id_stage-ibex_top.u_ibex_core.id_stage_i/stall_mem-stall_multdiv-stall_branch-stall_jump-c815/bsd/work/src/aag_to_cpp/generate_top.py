import json
import subprocess
import os
import sys
import re

# ==============================================================================
# 1. 自动依赖分析器 (Dependency Resolver)
# ==============================================================================
def resolve_dependencies(input_folder, top_module_name):
    print(f"Step 0: 解析依赖关系 (Top: {top_module_name}, Path: {input_folder})...")
    
    module_map = {} 
    module_pattern = re.compile(r"^\s*module\s+([a-zA-Z0-9_]+)", re.MULTILINE)
    
    if not os.path.exists(input_folder):
        raise FileNotFoundError(f"Folder {input_folder} not found.")

    all_files = [f for f in os.listdir(input_folder) if f.endswith('.v')]
    
    for fname in all_files:
        fpath = os.path.join(input_folder, fname)
        try:
            with open(fpath, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                matches = module_pattern.findall(content)
                for mod_name in matches:
                    module_map[mod_name] = fpath
        except Exception: pass

    if top_module_name not in module_map:
        raise ValueError(f"Top module '{top_module_name}' not found.")

    used_files = set()
    used_modules = set()
    queue = [top_module_name]
    
    while queue:
        curr_mod = queue.pop(0)
        if curr_mod in used_modules: continue
        used_modules.add(curr_mod)
        
        curr_file = module_map[curr_mod]
        used_files.add(curr_file)
        
        try:
            with open(curr_file, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                for candidate_mod, candidate_file in module_map.items():
                    if candidate_mod == curr_mod: continue
                    if candidate_mod in used_modules: continue
                    if re.search(r'\b' + re.escape(candidate_mod) + r'\b', content):
                        if candidate_mod not in queue:
                            queue.append(candidate_mod)
        except Exception: pass

    return list(used_files)

# ==============================================================================
# 2. 端口分析与 Wrapper 生成
# ==============================================================================
def get_ports_info_from_json(dependency_files, top_module_name):
    json_file = f"work/yosys_bits/{top_module_name}_ports.json"
    os.makedirs("work/yosys_bits", exist_ok=True)

    script = ""
    for fpath in dependency_files:
        script += f"read_verilog -sv {fpath}; "
    script += f"hierarchy -top {top_module_name}; write_json {json_file};"
    cmd = ["yosys", "-p", script, "-q"]
    subprocess.run(cmd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    with open(json_file, 'r') as f:
        data = json.load(f)
    
    modules = data.get("modules", {})
    module_data = modules.get(top_module_name) or modules.get(f"\\{top_module_name}")
    
    if not module_data: raise ValueError(f"Module {top_module_name} not found.")

    ports = module_data.get("ports", {})
    sorted_port_names = sorted(ports.keys())

    inputs, outputs = [], []
    total_in, total_out = 0, 0

    for name in sorted_port_names:
        p = ports[name]
        width = len(p["bits"])
        direction = p["direction"]
        info = {"name": name, "width": width}
        
        if direction == "input":
            inputs.append(info)
            total_in += width
        elif direction == "output":
            outputs.append(info)
            total_out += width
        elif direction == "inout":
            inputs.append(info) 
            total_in += width

    return inputs, outputs, total_in, total_out

def create_flatten_wrapper(dependency_files, original_top, wrapper_name):
    inputs, outputs, total_in, total_out = get_ports_info_from_json(dependency_files, original_top)
    
    wrapper_path = f"work/netlist/{wrapper_name}.v"
    os.makedirs("work/netlist", exist_ok=True)

    with open(wrapper_path, 'w') as f:
        f.write(f"module {wrapper_name} (\n")
        if total_in > 0: f.write(f"    input [{total_in-1}:0] PI,\n")
        f.write(f"    output [{total_out-1}:0] PO\n);\n\n")

        f.write(f"    {original_top} u_original (\n")
        
        curr = 0
        for idx, port in enumerate(inputs):
            msb = curr + port["width"] - 1
            f.write(f"        .{port['name']} ( PI[{msb}:{curr}] )")
            f.write(",\n" if (idx < len(inputs)-1 or outputs) else "\n")
            curr += port["width"]

        curr = 0
        for idx, port in enumerate(outputs):
            msb = curr + port["width"] - 1
            f.write(f"        .{port['name']} ( PO[{msb}:{curr}] )")
            f.write(",\n" if idx < len(outputs)-1 else "\n")
            curr += port["width"]
            
        f.write("    );\nendmodule\n")

    return inputs, outputs, total_in, total_out

def analyze_driver_from_json(json_file, top_module_name):
    try:
        with open(json_file, 'r') as f:
            data = json.load(f)
        modules = data.get("modules", {})
        module_data = modules.get(top_module_name) or modules.get(f"\\{top_module_name}")
        if not module_data: return None

        driven_nets = set()
        ports = module_data.get("ports", {})
        for pname, pdata in ports.items():
            if pdata["direction"] in ["input", "inout"]:
                for bit in pdata["bits"]:
                    if isinstance(bit, int): driven_nets.add(bit)
        
        cells = module_data.get("cells", {})
        for cname, cdata in cells.items():
            connections = cdata.get("connections", {})
            port_dirs = cdata.get("port_directions", {})
            for port, conn_bits in connections.items():
                direction = port_dirs.get(port)
                if direction in ["output", "out", "inout"] or port in ["Y", "Q", "O", "OUT"]:
                     for bit in conn_bits:
                        if isinstance(bit, int): driven_nets.add(bit)

        driver_map = []
        sorted_ports = sorted(ports.items()) 
        for pname, pdata in sorted_ports:
            if pdata["direction"] == "output":
                for bit in pdata["bits"]:
                    if bit in ["0", 0, "x", "z"]: driver_map.append(0)
                    elif bit in ["1", 1]: driver_map.append(1)
                    elif isinstance(bit, int):
                        if bit in driven_nets: driver_map.append('driven')
                        else: driver_map.append(0) 
                    else: driver_map.append(0)
        return driver_map
    except Exception: return None

# ==============================================================================
# 3. 主流程
# ==============================================================================
def verilog_top(top_module_name, input_folder="input_verilog"):
    try:
        dependency_files = resolve_dependencies(input_folder, top_module_name)
    except Exception as e:
        print(f"Error: {e}")
        return []

    wrapper_name = top_module_name + "_flat"
    print(f"\nStep 1: Generated Wrapper '{wrapper_name}'")
    try:
        inputs_info, outputs_info, input_bit_width, output_bit_width = create_flatten_wrapper(
            dependency_files, top_module_name, wrapper_name
        )
    except Exception as e:
        print(f"Wrapper Gen Error: {e}")
        return []

    print(f"  Inputs: {len(inputs_info)}, Width: {input_bit_width}")
    print(f"  Outputs: {len(outputs_info)}, Width: {output_bit_width}")

    # Analyze Drivers
    print("\nStep 2: Analyzing Drivers...")
    wrapper_path = f"work/netlist/{wrapper_name}.v"
    json_file = f"work/yosys_bits/{wrapper_name}_analysis.json"
    
    script = ""
    for f in dependency_files: script += f"read_verilog -sv {f}; "
    script += f"read_verilog -sv {wrapper_path}; hierarchy -top {wrapper_name}; proc; opt; flatten; write_json {json_file};"
    
    subprocess.run(["yosys", "-p", script, "-q"], check=False)
    
    driver_status = analyze_driver_from_json(json_file, wrapper_name)
    if not driver_status: driver_status = ['driven'] * output_bit_width
    print(f"  Driven: {driver_status.count('driven')}")

    # Generate Slices
    os.makedirs("work/verilog_bits", exist_ok=True)
    base_name = wrapper_name 

    for bit_index in range(output_bit_width):
        if driver_status[bit_index] != 'driven': continue
        with open(f"work/verilog_bits/{base_name}_o{bit_index}.v", 'w') as file:
            file.write(f"module {base_name}_o{bit_index}(in,out);\n\n")
            if input_bit_width > 0: file.write(f"input [{input_bit_width-1}:0] in;\n")
            file.write("output out;\n\n")
            file.write(f"wire [{output_bit_width-1}:0] PO;\n")
            file.write(f"assign out = PO[{bit_index}];\n\n")
            file.write(f"{wrapper_name} m0(\n")
            if input_bit_width > 0: file.write("    .PI(in),\n")
            file.write("    .PO(PO)\n);\nendmodule\n")

    # Yosys Script
    os.makedirs("work/aag_bits", exist_ok=True)
    with open("work/yosys_bits/yosys.ys", 'w') as file:
        for bit_index in range(output_bit_width):
            if driver_status[bit_index] == 'driven':
                for f in dependency_files: file.write(f"read_verilog -sv {f};\n")
                file.write(f"read_verilog -sv work/netlist/{wrapper_name}.v;\n")
                file.write(f"read_verilog work/verilog_bits/{base_name}_o{bit_index}.v;\n")
                file.write(f"hierarchy -top {base_name}_o{bit_index};\n")
                file.write("flatten; synth; aigmap;\n")
                file.write(f"write_aiger -symbols -ascii work/aag_bits/{base_name}_o{bit_index}.aag\n\n")

    # AAG -> CPP
    with open("aag_to_cpp_bits.py", 'w') as file:
        file.write("from aag_to_cpp import *\n")
        for bit_index in range(output_bit_width):
            if driver_status[bit_index] == 'driven':
                file.write("aag_to_cpp(\n")
                file.write(f"    \"work/aag_bits/{base_name}_o{bit_index}.aag\",\n")
                file.write(f"    \"work/cpp_bits/{base_name}_o{bit_index}.h\",\n")
                file.write(f"    \"work/cpp_bits/{base_name}_o{bit_index}.cpp\",\n")
                file.write(f"    \"io_generator_outer_o{bit_index}\",\n")
                file.write("    ignore=True, quiet=True)\n")

    # Vectorized Script
    try:
        with open("work/vec_bits/write_vec.sh", 'w') as file:
            file.write(f"module_name=\"{base_name}\"\n")
            for bit_index in range(output_bit_width):
                if driver_status[bit_index] == 'driven':
                    file.write("cp work/cpp_bits/${module_name}_o%d.cpp  work/cpp_bits/${module_name}_o%d_vec.cpp\n"%(bit_index,bit_index))
                    file.write("vim 	-c \"open work/cpp_bits/${module_name}_o%d_vec.cpp\" \\n"%bit_index)
                    file.write("	-c \"1,$ s/io_generator_outer/io_generator_outer_vec\" \\\n")
                    file.write("	-c \":wq!\" \n")
                    file.write("vim 	-c \"open work/cpp_bits/${module_name}_o%d_vec.cpp\" \\\n"%bit_index)
                    file.write("	-c \"1,$ s/vec_vec/vec\" \\\n")
                    file.write("	-c \"1,$ s/bool/uint64_t/g\" \\\n")
                    file.write("	-c \"1,$ s/!/\\~/g\" \\\n")
                    file.write("	-c \"1,$ s/&&/and/g\" \\\n")
                    file.write("	-c \"1,$ s/and/\\&/g\" \\\n")
                    file.write("	-c \"1,$ s/false/uint64_t(0)/g\" \\\n")
                    file.write("	-c \"1,$ s/true/64'hffffffffffffffff/g\" \\\n")
                    file.write("	-c \":wq!\" \n")
    except Exception: pass

    # ==========================================
    # Step 7: Merge (恢复 Single 函数)
    # ==========================================
    os.makedirs("output_cpp", exist_ok=True)
    output_h = f"output_cpp/{top_module_name}.h"
    
    with open(output_h, 'w') as out:
        out.write("#ifndef IO_GENERATOR_OUTER_H\n#define IO_GENERATOR_OUTER_H\n")
        out.write("#include <cstdint>\n")
        out.write(f"extern const int PI_WIDTH = {input_bit_width};\n")
        out.write(f"extern const int PO_WIDTH = {output_bit_width};\n#endif\n\n")

        # 1. Include Includes
        for i in range(output_bit_width):
            if driver_status[i] == 'driven':
                try:
                    with open(f"work/cpp_bits/{base_name}_o{i}.cpp") as f:
                        out.write(f.read() + "\n")
                except: pass
        
        # 2. Outer Function (Optimized)
        out.write("void io_generator_outer(bool* pi, bool* po) {\n")
        for i in range(output_bit_width):
            if driver_status[i] == 'driven':
                out.write(f"    io_generator_outer_o{i}(pi, &po[{i}]);\n")
            else:
                val = "true" if driver_status[i] == 1 else "false"
                out.write(f"    po[{i}] = {val};\n")
        out.write("}\n\n")

        # 3. Single Function (Restored)
        out.write("bool io_generator_outer_single(bool* pi, uint64_t bit_index) {\n")
        out.write("    bool* po_tmp = new bool[1];\n") # Size 1 is sufficient
        
        for i in range(output_bit_width):
            prefix = "if" if i == 0 else "else if"
            out.write(f"    {prefix} (bit_index == {i}) {{\n")
            
            if driver_status[i] == 'driven':
                 # Driven: Call the function
                 out.write(f"        io_generator_outer_o{i}(pi, po_tmp);\n")
            else:
                 # Constant: Manually assign
                 val = "true" if driver_status[i] == 1 else "false"
                 out.write(f"        po_tmp[0] = {val};\n")
            
            out.write("    }\n")
            
        out.write("    bool po = po_tmp[0];\n")
        out.write("    delete [] po_tmp;\n")
        out.write("    return po;\n")
        out.write("}\n")
        
    # ==================== Vectorized Merge ====================
    output_vec_h = f"output_cpp/{top_module_name}_vec.h"
    with open(output_vec_h, 'w') as out:
        for i in range(output_bit_width):
            if driver_status[i] == 'driven':
                try:
                    with open(f"work/cpp_bits/{base_name}_o{i}_vec.cpp") as f:
                        out.write(f.read() + "\n")
                except: pass

        # 1. Outer Vectorized (Optimized)
        out.write("void io_generator_outer_vec(uint64_t* pi, uint64_t* po) {\n")
        for i in range(output_bit_width):
            if driver_status[i] == 'driven':
                out.write(f"    io_generator_outer_vec_o{i}(pi, &po[{i}]);\n")
            else:
                val = "0xFFFFFFFFFFFFFFFF" if driver_status[i] == 1 else "0"
                out.write(f"    po[{i}] = {val};\n")
        out.write("}\n\n")

        # 2. Single Vectorized (Restored)
        out.write("uint64_t io_generator_outer_vec_single(uint64_t* pi, int bit_index) {\n")
        out.write("    uint64_t* po_tmp = new uint64_t[1];\n")
        
        for i in range(output_bit_width):
            prefix = "if" if i == 0 else "else if"
            out.write(f"    {prefix} (bit_index == {i}) {{\n")
            
            if driver_status[i] == 'driven':
                 out.write(f"        io_generator_outer_vec_o{i}(pi, po_tmp);\n")
            else:
                 val = "0xFFFFFFFFFFFFFFFF" if driver_status[i] == 1 else "0"
                 out.write(f"        po_tmp[0] = {val};\n")
            
            out.write("    }\n")
            
        out.write("    uint64_t po = po_tmp[0];\n")
        out.write("    delete [] po_tmp;\n")
        out.write("    return po;\n")
        out.write("}\n")

    print(f"\nAll done! Output: {output_h}")
    return [input_bit_width, output_bit_width]

if __name__ == "__main__":
    if len(sys.argv) > 1:
        verilog_top(sys.argv[1], "input_verilog")
    else:
        print("Please provide top module name.")