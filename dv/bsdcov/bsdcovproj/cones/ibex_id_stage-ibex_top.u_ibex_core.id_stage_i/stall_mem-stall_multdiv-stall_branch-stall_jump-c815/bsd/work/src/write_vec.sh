module_name="usb1_crc16"
#@vim 	-c "open io_generator/${module_name}.h" \
#@	-c "1d"\
#@	-c "1d"\
#@	-c ":$"\
#@	-c "d"
cp io_generator/${module_name}.h  ${module_name}_vec.h
vim 	-c "open ${module_name}_vec.h" \
	-c "1d" \
	-c "1d" \
	-c "1d" \
	-c "1d" \
	-c "1,$ s/io_generator_outer/io_generator_outer_vec" 
vim 	-c "open ${module_name}_vec.h" \
	-c "1,$ s/vec_vec/vec" \
	-c "1,$ s/bool/uint32_t/g" \
	-c "1,$ s/!/\~/g" \
	-c "1,$ s/&&/and/g" \
	-c "1,$ s/and/\&/g" \
	-c "1,$ s/false/0/g" \
	-c "1,$ s/true/32'hffffffff/g" \
	-c ":$"\
	-c "d"
