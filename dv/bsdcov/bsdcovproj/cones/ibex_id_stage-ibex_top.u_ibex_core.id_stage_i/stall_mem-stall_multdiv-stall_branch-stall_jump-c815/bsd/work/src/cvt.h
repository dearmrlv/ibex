#pragma once
#include<iostream>
#include<cstring>
using namespace std;
struct key{
	int lc;	int rc;	bool lc_neg; bool rc_neg;
	bool operator==(const key& other) const {
		return lc == other.lc && rc == other.rc &&
			   lc_neg == other.lc_neg && rc_neg == other.rc_neg;
	}
};

namespace std{
	template <>
	struct hash<key> {
		size_t operator()(const key& k) const {
			size_t h1 = std::hash<int>()(k.lc);
			size_t h2 = std::hash<int>()(k.rc);
			size_t h3 = std::hash<bool>()(k.lc_neg);
			size_t h4 = std::hash<bool>()(k.rc_neg);
			// 简单组合哈希值
			return h1 ^ (h2 << 1) ^ (h3 << 2) ^ (h4 << 3);
		}
	};
}
template <typename T>
inline void arr_copy(T target[], const T source[], const int size) {
    for (int i = 0; i < size; i++){
        target[i] = source[i];
    }
}

template <typename T>
inline void arr_init(T arr[], const T val, const int size){
    for (int i = 0; i < size; i++){
        arr[i] = val;
    }
}

template <typename T>
inline void arr_delete(T *&arr){//需要使用引用，因为涉及对arr指向地址的操作
    delete [] arr;
    arr = nullptr;
}

template <typename T>
inline void arr2d_new(T **&arr, const int size){//需要初始化为nullptr，否则不好释放
    arr = new T*[size];
    for (int i = 0; i < size; i++){
        arr[i] = nullptr;   //并没有提前全部分配内存，以节省空间
    }
}

//释放堆上的二维数组
template <typename T>
inline void arr2d_delete(T **&arr, const int size){
    for (int i = 0; i < size; i++){
        delete[] arr[i];    //nullptr会被忽略
    	arr[i] = nullptr;  
    }
    delete [] arr;
    arr = nullptr;  
}

// 数组线性搜索
template <typename T>
inline int arr_find(const T val, T *arr, const int size){
    for (int i = 0; i < size; i++){
        if (arr[i] == val)  return i;
    }
    return -1;
}

///int	cvt_bit_to_number(bool input_data[], int k){
///
///	int	output_number = 0;
///	int	i;
///	for (i=0;i<k-1;i++){
///		output_number += uint32_t(input_data[k-1-i]) << i; 
///		//cout<<input_data[i];
///	}
///	if(input_data[0]){
///		output_number -= uint32_t(1)<<(k-1);
///	}
///	//cout<<' '<<dec<< output_number<<endl;
///	return	output_number;
///};


//bool*	cvt_number_to_bit(int input_data, int k){
//	int	i;
//	//bool*	output_bits;
//	bool* output_bits = new bool [k];
//	for (i=0;i<k;i++){
//		output_bits[i] = (input_data >> (k-1-i)) & int(1); 
//	}
//	return	output_bits;
//};

uint64_t	cvt_bit_to_number_unsigned(bool input_data[], int k){

	uint64_t	output_number = 0;
	int	i;
	for (i=0;i<k;i++){
		if(input_data[i])
			output_number += uint64_t(1) << (k-1-i);
		//cout<<input_data[i];
	}
	//cout<<' '<<dec<<output_number<<endl;
	return	output_number;
};

//bool*	cvt_number_to_bit_unsigned(uint32_t input_data, int k){
//
//	bool*	output_bits = new bool [k];
//	int	i;
//	for (i=0;i<k;i++){
//		output_bits[i] = (input_data >> (k-1-i)) & uint32_t(1); 
//		//cout<<output_number[i];
//	}
//	//cout<<' '<<hex<<input_data<<endl;
//	return	output_bits;
//};

void sign_extend(bool* bit_output, int output_length, bool* bit_input, int input_length) {
	for(int i = 0; i < output_length-input_length; i++)
		bit_output[i] = bit_input[0];
	for(int i = 0; i < input_length; i++)
		bit_output[output_length - input_length + i] = bit_input[i];
}

void zero_extend(bool* bit_output, int output_length, bool* bit_input, int input_length) {
	for(int i = 0; i < output_length-input_length; i++)
		bit_output[i] = 0;
	for(int i = 0; i < input_length; i++)
		bit_output[output_length - input_length + i] = bit_input[i];
}

void add_bit_list(bool* bit_output, bool* bit_input_a, bool* bit_input_b, int length) {
	bool c = 0;
	for(int i = length-1; i >= 0; i--) {
		int temp = int(bit_input_a[i]) + int(bit_input_b[i]) + int(c);
		bit_output[i] = temp%2==1 ? 1:0 ;
		c = temp > 1? 1:0;
	}
}

void copy_indice(bool* dst, uint32_t dst_idx, bool* src, uint32_t src_idx, uint32_t num) {
	memcpy(dst + dst_idx, src + src_idx, num*sizeof(bool));
}

template <typename T>
void cout_indice(T arr, uint32_t idx, uint32_t num) {
	for (int i = 0; i < num; i++)
		cout << arr[i + idx];
	cout << endl;
}

void init_indice(bool* arr, uint32_t idx, uint32_t num) {
	memset(arr+idx, 0, num*sizeof(bool));
}


void init_indice(uint32_t* arr, uint32_t idx, uint32_t num) {
	memset(arr+idx, 0, num*sizeof(uint32_t));
}

void  cvt_number_to_bit_unsigned(bool* output_number, uint64_t input_data, int k) {
	int i;
	for (i = 0; i < k; i++) {
		//output_number[i] = uint64_t(input_data >> (k - 1 - i)) & uint64_t(1);
		output_number[i] = uint64_t(input_data >> (k - 1 - i)) & uint64_t(1);
		//	cout<<output_number[i];
	}
	// cout<<' '<< dec<<input_data<<endl;
};

//void cvt_number_to_bit(bool* output_number, int input_data, int k) {
//	int i;
//	for (i = 0; i < k; i++) {
//		output_number[i] = (input_data >> (k - 1 - i)) & uint32_t(1);
//		//	cout<<output_number[i];
//	}
//	// cout<<' '<< input_data<<endl;
//};

