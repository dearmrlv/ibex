filename="c432"
python insert_io_notes.py input_verilog/${filename}.v -o work/netlist/${filename}.v
python execute.py ${filename}
yosys work/yosys_bits/yosys.ys
python  aag_to_cpp_bits.py
sh work/vec_bits/write_vec.sh
python execute.py ${filename}
