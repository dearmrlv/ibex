#pragma once

int	parameter_data_width = 8;
bool*	io_generator_single_function_0(bool* input_data,bool* output_data);//==
bool*	io_generator_single_function_1(bool* input_data,bool* output_data);//add_unsigned
bool*	io_generator_single_function_2(bool* input_data,bool* output_data);//add
bool*	io_generator_single_function_3(bool* input_data,bool* output_data);//minus_unsigned
bool*	io_generator_single_function_4(bool* input_data,bool* output_data);//minus
bool*	io_generator_single_function_5(bool* input_data,bool* output_data);//left_shift
bool*	io_generator_single_function_6(bool* input_data,bool* output_data);//right_shift
bool*	io_generator_single_function_7(bool* input_data,bool* output_data);//< unsigned
bool*	io_generator_single_function_8(bool* input_data,bool* output_data);//< 
bool*	io_generator_single_function_9(bool* input_data,bool* output_data);//and
bool*	io_generator_single_function_10(bool* input_data,bool* output_data);//or
bool*	io_generator_single_function_11(bool* input_data,bool* output_data);//xor
bool*	io_generator_single_function_12(bool* input_data,bool* output_data);//ax+b
bool*	io_generator_single_function_13(bool* input_data,bool* output_data);//add invert
bool*	io_generator_single_function_14(bool* input_data,bool* output_data);//add 4
bool*	io_generator_single_function_15(bool* input_data,bool* output_data);//ax+by+c
bool*	io_generator_single_function_mul(bool* input_data,bool* output_data);// mul unsigned
bool* io_generator_single_function_fp32_add(bool* input_data,bool* output_data); // fp32_add

bool*	io_generator_alu_function_1(bool* input_data,bool* output_data);
bool*	io_generator_alu_function_2(bool* input_data,bool* output_data);
bool*	io_generator_alu_function_3(bool* input_data,bool* output_data);
bool*	io_generator_alu_function_4(bool* input_data,bool* output_data);
bool*	io_generator_alu_function_5(bool* input_data,bool* output_data);

bool*	io_generator_cpu_function_1(bool* input_data,bool* output_data);//add_shift

//#include"io_generator/cpp_comb/parallel_serial_16.h"
//#include"patch.h"



bool*	io_generator_single_function_0(bool* input_data,bool* output_data){//==
	int i,j;
	for (i=0;i<parameter_data_width;i++){
		output_data[i] = input_data[i];
	}
	return output_data;
}

bool*	io_generator_single_function_1(bool* input_data,bool* output_data){//add_unsigned

	int i,j;
	bool	input_data_a[parameter_data_width],input_data_b[parameter_data_width];
	for (i=0;i<parameter_data_width;i++){
		input_data_a[i] = input_data[i];
		input_data_b[i] = input_data[i+parameter_data_width];
	}
	long	data_a = cvt_bit_to_number_unsigned(input_data_a,parameter_data_width);
	long	data_b = cvt_bit_to_number_unsigned(input_data_b,parameter_data_width);

	long 	data_result = data_a + data_b;
	bool*	output_data_result= new bool[parameter_data_width]; 
		cvt_number_to_bit_unsigned(output_data_result,data_result,parameter_data_width);
	
	for (i=0;i<PO_WIDTH;i++){
		if(i<parameter_data_width)
			output_data[i] = output_data_result[i];
		else 
			output_data[i] = 0;
	}
	delete[]	output_data_result;
	return output_data;
}

bool*	io_generator_single_function_2(bool* input_data,bool* output_data){//add
	int i,j;
	bool	input_data_a[parameter_data_width],input_data_b[parameter_data_width];
	for (i=0;i<parameter_data_width;i++){
		input_data_a[i] = input_data[i];
		input_data_b[i] = input_data[i+parameter_data_width];
	}
	long	data_a = cvt_bit_to_number(input_data_a,parameter_data_width);
	long	data_b = cvt_bit_to_number(input_data_b,parameter_data_width);

	long 	data_result = data_a + data_b;
	bool*	output_data_result= new bool[parameter_data_width]; 
		cvt_number_to_bit(output_data_result,data_result,parameter_data_width);
	
	for (i=0;i<parameter_data_width;i++){
		output_data[i] = output_data_result[i];
	}
	delete[]	output_data_result;
	return output_data;
}

bool*	io_generator_single_function_3(bool* input_data,bool* output_data){//minus_unsigned
	int i,j;
	bool	input_data_a[parameter_data_width],input_data_b[parameter_data_width];
	for (i=0;i<parameter_data_width;i++){
		input_data_a[i] = input_data[i];
		input_data_b[i] = input_data[i+parameter_data_width];
	}
	long	data_a = cvt_bit_to_number_unsigned(input_data_a,parameter_data_width);
	long	data_b = cvt_bit_to_number_unsigned(input_data_b,parameter_data_width);

	long 	data_result = data_a - data_b;
	bool*	output_data_result= new bool[parameter_data_width]; 
		cvt_number_to_bit_unsigned(output_data_result,data_result,parameter_data_width);
	
	for (i=0;i<parameter_data_width;i++){
		output_data[i] = output_data_result[i];
	}
	delete[]	output_data_result;
	return output_data;
}

bool*	io_generator_single_function_4(bool* input_data,bool* output_data){//minus
	int i,j;
	bool	input_data_a[parameter_data_width],input_data_b[parameter_data_width];
	for (i=0;i<parameter_data_width;i++){
		input_data_a[i] = input_data[i];
		input_data_b[i] = input_data[i+parameter_data_width];
	}
	long	data_a = cvt_bit_to_number(input_data_a,parameter_data_width);
	long	data_b = cvt_bit_to_number(input_data_b,parameter_data_width);

	long 	data_result = data_a - data_b;
	bool*	output_data_result= new bool[parameter_data_width]; 
		cvt_number_to_bit(output_data_result,data_result,parameter_data_width);
	
	for (i=0;i<parameter_data_width;i++){
		output_data[i] = output_data_result[i];
	}
	delete[]	output_data_result;
	return output_data;
}

/*
For shift, in C++, input_data[0], ..., input_data[31] as verilog input[0], ..., input[31],
C++ input_data[32], ..., input_data[36] as verilog num[0], ..., num[4].
*/
bool*	io_generator_single_function_5(bool* input_data,bool* output_data){//left_shift
	int i,j;
	bool	input_data_a[parameter_data_width],input_data_b[parameter_data_width];
	for (i=0;i<5;i++){
		input_data_b[i] = input_data[i+parameter_data_width];
	}
	long	data_b = cvt_bit_to_number_unsigned(input_data_b,5);

	for (i = 0; i < parameter_data_width - data_b; i++) {
		output_data[i+data_b] = input_data[i];
	}
	
	// for (i=0;i<parameter_data_width;i++){
	// 	output_data[i+data_b] = input_data[i];
	// }
	return output_data;
}

bool*	io_generator_single_function_6(bool* input_data,bool* output_data){//right_shift
	int i,j;
	bool	input_data_a[parameter_data_width],input_data_b[parameter_data_width];
	for (i=0;i<5;i++){
		input_data_b[i] = input_data[i+parameter_data_width];
	}
	long	data_b = cvt_bit_to_number_unsigned(input_data_b,5);

	for (i = 0; i < parameter_data_width - data_b; i++) {
		output_data[i] = input_data[i+data_b];
	}
	
	// for (i=0;i<parameter_data_width;i++){
	// 	output_data[i+data_b] = input_data[i];
	// }

	return output_data;
}

bool*	io_generator_single_function_7(bool* input_data,bool* output_data){//< unsigned
	int i,j;
	bool	input_data_a[parameter_data_width],input_data_b[parameter_data_width];
	for (i=0;i<parameter_data_width;i++){
		input_data_a[i] = input_data[i];
		input_data_b[i] = input_data[i+parameter_data_width];
	}
	long	data_a = cvt_bit_to_number_unsigned(input_data_a,parameter_data_width);
	long	data_b = cvt_bit_to_number_unsigned(input_data_b,parameter_data_width);

	int	data_result = data_a < data_b;
	bool*	output_data_result= new bool[parameter_data_width]; 
		cvt_number_to_bit_unsigned(output_data_result,data_result,parameter_data_width);
	
	for (i=0;i<parameter_data_width;i++){
		output_data[i] = output_data_result[i];
	}
	delete[]	output_data_result;
	return output_data;
}

bool*	io_generator_single_function_8(bool* input_data,bool* output_data){//< 
	int i,j;
	bool	input_data_a[parameter_data_width],input_data_b[parameter_data_width];
	for (i=0;i<parameter_data_width;i++){
		input_data_a[i] = input_data[i];
		input_data_b[i] = input_data[i+parameter_data_width];
	}
	long	data_a = cvt_bit_to_number(input_data_a,parameter_data_width);
	long	data_b = cvt_bit_to_number(input_data_b,parameter_data_width);

	int	data_result = data_a < data_b;
	bool*	output_data_result= new bool[parameter_data_width]; 
		cvt_number_to_bit_unsigned(output_data_result,data_result,parameter_data_width);
	
	for (i=0;i<parameter_data_width;i++){
		output_data[i] = output_data_result[i];
	}
	delete[]	output_data_result;
	return output_data;
}

bool*	io_generator_single_function_9(bool* input_data,bool* output_data){//and 
	int i,j;
	bool	input_data_a[parameter_data_width],input_data_b[parameter_data_width];
	for (i=0;i<parameter_data_width;i++){
		input_data_a[i] = input_data[i];
		input_data_b[i] = input_data[i+parameter_data_width];
	}
	
	for (i=0;i<parameter_data_width;i++){
		output_data[i] = input_data_a[i] && input_data_b[i];
	}
	return output_data;
}

bool*	io_generator_single_function_10(bool* input_data,bool* output_data){//or
	int i,j;
	bool	input_data_a[parameter_data_width],input_data_b[parameter_data_width];
	for (i=0;i<parameter_data_width;i++){
		input_data_a[i] = input_data[i];
		input_data_b[i] = input_data[i+parameter_data_width];
	}
	
	for (i=0;i<parameter_data_width;i++){
		output_data[i] = input_data_a[i] || input_data_b[i];
	}
	return output_data;
}

bool*	io_generator_single_function_11(bool* input_data,bool* output_data){//xor
	int i,j;
	bool	input_data_a[parameter_data_width],input_data_b[parameter_data_width];
	for (i=0;i<parameter_data_width;i++){
		input_data_a[i] = input_data[i];
		input_data_b[i] = input_data[i+parameter_data_width];
	}
	
	for (i=0;i<parameter_data_width;i++){
		output_data[i] = input_data_a[i] ^ input_data_b[i];
	}
	return output_data;
}

bool*	io_generator_single_function_12(bool* input_data,bool* output_data){//ax+b
	int i,j;
	bool	input_data_a[parameter_data_width],input_data_b[parameter_data_width];
	for (i=0;i<parameter_data_width;i++){
		input_data_a[i] = input_data[i];
		input_data_b[i] = input_data[i+parameter_data_width];
	}
	long	data_a = cvt_bit_to_number(input_data_a,parameter_data_width);
	long	data_b = cvt_bit_to_number(input_data_b,parameter_data_width);

	long 	data_result = 5*data_a + data_b;
	bool*	output_data_result= new bool[parameter_data_width]; 
		cvt_number_to_bit(output_data_result,data_result,parameter_data_width);
	
	for (i=0;i<parameter_data_width;i++){
		output_data[i] = output_data_result[i];
	}
	delete[]	output_data_result;
	return output_data;
}

bool*	io_generator_single_function_13(bool* input_data,bool* output_data){//add_invert
	int i,j;
	bool	input_data_a[parameter_data_width],input_data_b[parameter_data_width];
	for (i=0;i<parameter_data_width;i++){
		input_data_a[i] = input_data[parameter_data_width-1-i];
		input_data_b[i] = input_data[i+parameter_data_width];
	}
	long	data_a = cvt_bit_to_number(input_data_a,parameter_data_width);
	long	data_b = cvt_bit_to_number(input_data_b,parameter_data_width);

	long 	data_result = data_a + data_b;
	bool*	output_data_result= new bool[parameter_data_width]; 
		cvt_number_to_bit(output_data_result,data_result,parameter_data_width);
	
	for (i=0;i<parameter_data_width;i++){
		output_data[i] = output_data_result[i];
	}
	delete[]	output_data_result;
	return output_data;
}

bool*	io_generator_single_function_14(bool* input_data,bool* output_data){//add_4
	int i,j;
	bool	input_data_a[parameter_data_width];
	for (i=0;i<parameter_data_width;i++){
		input_data_a[i] = input_data[parameter_data_width-1-i];
	}
	long	data_a = cvt_bit_to_number(input_data_a,parameter_data_width);

	long 	data_result = data_a + 4;
	bool*	output_data_result= new bool[parameter_data_width]; 
		cvt_number_to_bit(output_data_result,data_result,parameter_data_width);
	
	for (i=0;i<parameter_data_width;i++){
		output_data[i] = output_data_result[i];
	}
	delete[]	output_data_result;
	return output_data;
}

bool*	io_generator_single_function_15(bool* input_data,bool* output_data){//ax+by+c
	int i,j;
	bool	input_data_a[parameter_data_width],input_data_b[parameter_data_width];
	for (i=0;i<parameter_data_width;i++){
		input_data_a[i] = input_data[i];
		input_data_b[i] = input_data[i+parameter_data_width];
	}
	long	data_a = cvt_bit_to_number(input_data_a,parameter_data_width);
	long	data_b = cvt_bit_to_number(input_data_b,parameter_data_width);

	long 	data_result = 11*data_a + 5*data_b + 4;
	bool*	output_data_result= new bool[parameter_data_width]; 
		cvt_number_to_bit(output_data_result,data_result,parameter_data_width);
	
	for (i=0;i<parameter_data_width;i++){
		output_data[i] = output_data_result[i];
	}
	delete[]	output_data_result;
	return output_data;
}

bool*	io_generator_single_function_mul(bool* input_data,bool* output_data){ // mul
	int i,j;
	bool	input_data_a[parameter_data_width],input_data_b[parameter_data_width];
	for (i=0;i<parameter_data_width;i++){
		input_data_a[i] = input_data[i];
		input_data_b[i] = input_data[i+parameter_data_width];
	}
	long	data_a = cvt_bit_to_number(input_data_a,parameter_data_width);
	long	data_b = cvt_bit_to_number(input_data_b,parameter_data_width);

	long 	data_result = data_a * data_b;
	bool*	output_data_result= new bool[32]; 
		cvt_number_to_bit(output_data_result, data_result, 32);
	
	for (i=0;i<parameter_data_width;i++){
		output_data[i] = output_data_result[i];
	}
	delete[]	output_data_result;
	return output_data;
}

bool*	io_generator_single_function_fp32_add(bool* input_data, bool* output_data){ // fp32_add
	int i,j;
	bool	input_data_a[parameter_data_width],input_data_b[parameter_data_width];
	for (i=0;i < parameter_data_width; i++){
		input_data_a[i] = input_data[i];
		input_data_b[i] = input_data[i+parameter_data_width];
	}
	uint32_t data_a = cvt_bit_to_number_unsigned(input_data_a, parameter_data_width);
	uint32_t data_b = cvt_bit_to_number_unsigned(input_data_b, parameter_data_width);
	float data_result = *(float *) &data_a + *(float *) &data_b;
	//cout<<*(float *) &data_a<<"	"<<*(float *) &data_b<<"	"<<data_result<<endl;
	bool* output_data_result= new bool[32]; 
		cvt_number_to_bit_unsigned(output_data_result, *(uint32_t *) &data_result, 32);
	
	for (i=0;i<parameter_data_width;i++){
		output_data[i] = output_data_result[22];
	}
	delete[]	output_data_result;
	return output_data;
}

bool*	io_generator_alu_function_1(bool* input_data,bool* output_data){//add_minus 2_4
	int i,j;

	bool*	output_data_function_a = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_b = new bool [parameter_input_bit_width*2];
	
	for(i=0;i<2*parameter_input_bit_width;i++){
		output_data_function_a[i] = 0;
		output_data_function_b[i] = 0;
	}
	output_data_function_a = io_generator_single_function_2(input_data,output_data_function_a);
	output_data_function_b = io_generator_single_function_4(input_data,output_data_function_b);

	for (i=0;i<2*parameter_input_bit_width;i++){
		output_data[i] = 0;
		if(input_data[64])
			output_data[i] = output_data_function_a[i];
		else
			output_data[i] = output_data_function_b[i];
	}
		if(input_data[64])
			output_data[0] = output_data_function_a[0];
		else
			output_data[0] = output_data_function_b[0];

	delete[]	output_data_function_a;
	delete[]	output_data_function_b;
	return output_data;
};
bool*	io_generator_alu_function_2(bool* input_data,bool* output_data){//add_minus 2_3_4_5
	int i,j;

	bool*	output_data_function_a = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_b = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_c = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_d = new bool [parameter_input_bit_width*2];
	
	for(i=0;i<2*parameter_input_bit_width;i++){
		output_data_function_a[i] = 0;
		output_data_function_b[i] = 0;
		output_data_function_c[i] = 0;
		output_data_function_d[i] = 0;
	}
	output_data_function_a = io_generator_single_function_2(input_data,output_data_function_a);
	output_data_function_b = io_generator_single_function_3(input_data,output_data_function_b);
	output_data_function_c = io_generator_single_function_4(input_data,output_data_function_c);
	output_data_function_d = io_generator_single_function_1(input_data,output_data_function_d);

	for (i=0;i<2*parameter_input_bit_width;i++){
		output_data[i] = 0;
		if(input_data[64] && input_data[65])
			output_data[i] = output_data_function_a[i];
		else if(input_data[64] && !input_data[65])
			output_data[i] = output_data_function_b[i];
		else if(!input_data[64] && input_data[65])
			output_data[i] = output_data_function_c[i];
		else
			output_data[i] = output_data_function_d[i];
	}
	delete[]	output_data_function_a;
	delete[]	output_data_function_b;
	delete[]	output_data_function_c;
	delete[]	output_data_function_d;
	return output_data;
};
bool*	io_generator_alu_function_3(bool* input_data,bool* output_data){
	int i,j;

	bool*	output_data_function_a = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_b = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_c = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_d = new bool [parameter_input_bit_width*2];

	for(i=0;i<2*parameter_input_bit_width;i++){
		output_data_function_a[i] = 0;
		output_data_function_b[i] = 0;
		output_data_function_c[i] = 0;
		output_data_function_d[i] = 0;
	}
	
	output_data_function_a = io_generator_single_function_2(input_data,output_data_function_a);
	output_data_function_b = io_generator_single_function_5(input_data,output_data_function_b);
	output_data_function_c = io_generator_single_function_8(input_data,output_data_function_c);
	output_data_function_d = io_generator_single_function_9(input_data,output_data_function_d);

	for (i=0;i<2*parameter_input_bit_width;i++){
		if(input_data[64] && input_data[65])
			output_data[i] = output_data_function_a[i];
		else if(input_data[64] && !input_data[65])
			output_data[i] = output_data_function_b[i];
		else if(!input_data[64] && input_data[65])
			output_data[i] = output_data_function_c[i];
		else
			output_data[i] = output_data_function_d[i];
	}
	delete[]	output_data_function_a;
	delete[]	output_data_function_b;
	delete[]	output_data_function_c;
	delete[]	output_data_function_d;
	return output_data;
};

bool*	io_generator_alu_function_4(bool* input_data,bool* output_data){
	int i,j;

	bool*	output_data_function_a = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_b = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_c = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_d = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_e = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_f = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_g = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_h = new bool [parameter_input_bit_width*2];

	for(i=0;i<2*parameter_input_bit_width;i++){
		output_data_function_a[i] = 0;
		output_data_function_b[i] = 0;
		output_data_function_c[i] = 0;
		output_data_function_d[i] = 0;
		output_data_function_e[i] = 0;
		output_data_function_f[i] = 0;
		output_data_function_g[i] = 0;
		output_data_function_h[i] = 0;
	}
	
	output_data_function_a = io_generator_single_function_1(input_data,output_data_function_a);
	output_data_function_b = io_generator_single_function_2(input_data,output_data_function_b);
	output_data_function_c = io_generator_single_function_3(input_data,output_data_function_c);
	output_data_function_d = io_generator_single_function_4(input_data,output_data_function_d);
	output_data_function_e = io_generator_single_function_5(input_data,output_data_function_e);
	output_data_function_f = io_generator_single_function_6(input_data,output_data_function_f);
	output_data_function_g = io_generator_single_function_7(input_data,output_data_function_g);
	output_data_function_h = io_generator_single_function_8(input_data,output_data_function_h);

	bool*	op_code = new bool [3];
	for(i=0;i<3;i++){
		op_code[i] = input_data[64+i];
	}
	int	op_code_number = cvt_bit_to_number_unsigned(op_code,3);
	for (i=0;i<2*parameter_input_bit_width;i++){
		if(op_code_number == 0)
			output_data[i] = output_data_function_a[i];
		else if(op_code_number == 1)
			output_data[i] = output_data_function_b[i];
		else if(op_code_number == 2)
			output_data[i] = output_data_function_c[i];
		else if(op_code_number == 3)
			output_data[i] = output_data_function_d[i];
		else if(op_code_number == 4)
			output_data[i] = output_data_function_e[i];
		else if(op_code_number == 5)
			output_data[i] = output_data_function_f[i];
		else if(op_code_number == 6)
			output_data[i] = output_data_function_g[i];
		else
			output_data[i] = output_data_function_h[i];
	}
	delete[]	output_data_function_a;
	delete[]	output_data_function_b;
	delete[]	output_data_function_c;
	delete[]	output_data_function_d;
	delete[]	output_data_function_e;
	delete[]	output_data_function_f;
	delete[]	output_data_function_g;
	delete[]	output_data_function_h;
	delete[]	op_code;
	return output_data;
};
bool*	io_generator_alu_function_5(bool* input_data,bool* output_data){//add_minus 2_3_4_5
	int i,j;

	bool*	output_data_function_a = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_b = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_c = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_d = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_e = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_f = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_g = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_h = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_i = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_j = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_k = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_l = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_m = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_n = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_o = new bool [parameter_input_bit_width*2];
	bool*	output_data_function_p = new bool [parameter_input_bit_width*2];


	for(i=0;i<2*parameter_input_bit_width;i++){
		output_data_function_a[i] = 0;
		output_data_function_b[i] = 0;
		output_data_function_c[i] = 0;
		output_data_function_d[i] = 0;
		output_data_function_e[i] = 0;
		output_data_function_f[i] = 0;
		output_data_function_g[i] = 0;
		output_data_function_h[i] = 0;
		output_data_function_i[i] = 0;
		output_data_function_j[i] = 0;
		output_data_function_k[i] = 0;
		output_data_function_l[i] = 0;
		output_data_function_m[i] = 0;
		output_data_function_n[i] = 0;
		output_data_function_o[i] = 0;
		output_data_function_p[i] = 0;
	}
	
	output_data_function_a = io_generator_single_function_1 (input_data,output_data_function_a);
	output_data_function_b = io_generator_single_function_2 (input_data,output_data_function_b);
	output_data_function_c = io_generator_single_function_3 (input_data,output_data_function_c);
	output_data_function_d = io_generator_single_function_4 (input_data,output_data_function_d);
	output_data_function_e = io_generator_single_function_5 (input_data,output_data_function_e);
	output_data_function_f = io_generator_single_function_6 (input_data,output_data_function_f);
	output_data_function_g = io_generator_single_function_7 (input_data,output_data_function_g);
	output_data_function_h = io_generator_single_function_8 (input_data,output_data_function_h);
	output_data_function_i = io_generator_single_function_9 (input_data,output_data_function_i);
	output_data_function_j = io_generator_single_function_10(input_data,output_data_function_j);
	output_data_function_k = io_generator_single_function_11(input_data,output_data_function_k);
	output_data_function_l = io_generator_single_function_12(input_data,output_data_function_l);
	output_data_function_m = io_generator_single_function_13(input_data,output_data_function_m);
	output_data_function_n = io_generator_single_function_14(input_data,output_data_function_n);
	output_data_function_o = io_generator_single_function_15(input_data,output_data_function_o);
	output_data_function_p = io_generator_single_function_0(input_data,output_data_function_p);

	bool*	op_code = new bool [4];
	for(i=0;i<4;i++){
		op_code[i] = input_data[64+i];
	}
	int	op_code_number = cvt_bit_to_number_unsigned(op_code,4);
	for (i=0;i<2*parameter_input_bit_width;i++){
		if(op_code_number == 0)
			output_data[i] = output_data_function_a[i];
		else if(op_code_number == 1)
			output_data[i] = output_data_function_b[i];
		else if(op_code_number == 2)
			output_data[i] = output_data_function_c[i];
		else if(op_code_number == 3)
			output_data[i] = output_data_function_d[i];
		else if(op_code_number == 4)
			output_data[i] = output_data_function_e[i];
		else if(op_code_number == 5)
			output_data[i] = output_data_function_f[i];
		else if(op_code_number == 6)
			output_data[i] = output_data_function_g[i];
		else if(op_code_number == 7)
			output_data[i] = output_data_function_h[i];
		else if(op_code_number == 8)
			output_data[i] = output_data_function_i[i];
		else if(op_code_number == 9)
			output_data[i] = output_data_function_j[i];
		else if(op_code_number ==10)
			output_data[i] = output_data_function_k[i];
		else if(op_code_number ==11)
			output_data[i] = output_data_function_l[i];
		else if(op_code_number ==12)
			output_data[i] = output_data_function_m[i];
		else if(op_code_number ==13)
			output_data[i] = output_data_function_n[i];
		else if(op_code_number ==14)
			output_data[i] = output_data_function_o[i];
		else
			output_data[i] = output_data_function_p[i];
	}
	delete[]	output_data_function_a;
	delete[]	output_data_function_b;
	delete[]	output_data_function_c;
	delete[]	output_data_function_d;
	delete[]	output_data_function_e;
	delete[]	output_data_function_f;
	delete[]	output_data_function_g;
	delete[]	output_data_function_h;
	delete[]	output_data_function_i;
	delete[]	output_data_function_j;
	delete[]	output_data_function_k;
	delete[]	output_data_function_l;
	delete[]	output_data_function_m;
	delete[]	output_data_function_n;
	delete[]	output_data_function_o;
	delete[]	output_data_function_p;
	delete[]	op_code;
	return output_data;
};
