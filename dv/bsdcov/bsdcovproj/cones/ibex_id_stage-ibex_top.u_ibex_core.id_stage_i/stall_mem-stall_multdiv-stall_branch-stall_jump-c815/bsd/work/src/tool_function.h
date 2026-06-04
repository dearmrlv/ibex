#include 	"sample.h"
int64_t	BDD_class::mask_random_input_data(int64_t depth,bool* mask,int64_t amount,bool** mask_input_data){
	int64_t i,j;
	//#pragma omp parallel for
	for (i=0;i<amount;i++){
		for (j=0;j<depth+1;j++){
			mask_input_data[i][most_influence[j]] = mask[most_influence[j]];
		}
	}

	return 0;
};

int64_t BDD_class::hash_simplify_list_function(bool* list, bool neg){

	int64_t a = int64_t(BSD_samples/1);
	int64_t b = int64_t(BSD_samples/2);
	int64_t c = int64_t(BSD_samples/3);
	int64_t d = int64_t(BSD_samples/4);
	int64_t line_sum_a=0;
	int64_t line_sum_b=0;
	int64_t line_sum_c=0;
	int64_t line_sum_d=0;
	for(int64_t i=0;i<BSD_samples;i++){
		if(i<d){
			if(list[i]==!neg)
				line_sum_d += 1;
		}else if (i<c){
			if(list[i]==!neg)
				line_sum_c += 1;
		}else if (i<b){
			if(list[i]==!neg)
				line_sum_b += 1;
		}
		else if (i<a){
			if(list[i]==!neg)
				line_sum_a += 1;
		}

	}
	int64_t line_sum = line_sum_d * 3 + line_sum_c * 5 + line_sum_b * 7 + line_sum_a;
	return line_sum;
}
int64_t BDD_class::compare_simplify_list(int64_t list_line_amount,bool* this_line,bool** simplify_list, int64_t* hash_simplify_list, int64_t hash_number){
	int64_t which_list_number = -1;
	//return which_list_number;
	bool it_can_simplify  = 0;
	int64_t i,j;
	bool it_can_simplify_here;
	which_list_number = -1;
	double early_stop_accuracy_node = 1 - (1-parameter_early_stop_accuracy)/double(4);
	if(early_stop_accuracy_node < 1 - double(1)/BSD_samples){
		if(parameter_early_stop_oneway){
			for (int64_t i=list_line_amount-1;i>=0;i--){
				it_can_simplify_here = 0;
				int64_t same_bit = 0;
				bool oneway_merge =1;
				if((hash_number < double(hash_simplify_list[i]) * early_stop_accuracy_node) || (hash_number > double(hash_simplify_list[i]) / early_stop_accuracy_node)){
					it_can_simplify_here = 0;
				}else{
					for(int64_t j=0;j<BSD_samples;j++){
						if(simplify_list[i][j] == this_line[j]){
							same_bit += 1;
						}else if(!simplify_list[i][j] && this_line[j]){
							oneway_merge = 0;
							break;
						}
					}
					if(double(same_bit)/double(BSD_samples) > early_stop_accuracy_node)
						it_can_simplify_here = oneway_merge;
				}
				if(it_can_simplify_here){
					it_can_simplify   = 1;
					which_list_number = i;
					break;
				}
			}
		}else{
			for (int64_t i=list_line_amount-1;i>=0;i--){
				it_can_simplify_here = 0;
				int64_t same_bit = 0;
				if((hash_number < double(hash_simplify_list[i]) * early_stop_accuracy_node) || (hash_number > double(hash_simplify_list[i]) / early_stop_accuracy_node)){
					it_can_simplify_here = 0;
				}else{
					for(int64_t j=0;j<BSD_samples;j++){
						if(simplify_list[i][j] == this_line[j]){
							same_bit += 1;
						}
					}
					if(double(same_bit)/double(BSD_samples) > early_stop_accuracy_node)
						it_can_simplify_here = 1;
				}
				if(it_can_simplify_here){
					it_can_simplify   = 1;
					which_list_number = i;
					break;
				}
			}
		}

	}
	else {	
		for (int64_t i=list_line_amount-1;i>=0;i--){
			it_can_simplify_here = 1;
			if(hash_number!=hash_simplify_list[i]){
				it_can_simplify_here = 0;
			}else{
				for(int64_t j=0;j<BSD_samples;j++){
					if(simplify_list[i][j] != this_line[j]){
						it_can_simplify_here = 0;
						break;
					}
				}
			}
			if(it_can_simplify_here){
				it_can_simplify   = 1;
				which_list_number = i;
				break;
			}
		}
	}
	return which_list_number;
};
int64_t BDD_class::compare_simplify_list_neg(int64_t list_line_amount,bool* this_line,bool** simplify_list,int64_t * hash_simplify_list,int64_t hash_neg_number){
	int64_t which_list_number = -1;
	return which_list_number;
	bool it_can_simplify  = 0;
	int64_t i,j;
	bool it_can_simplify_here;
	which_list_number = -1;
	if(1){	
		for (i=list_line_amount-1;i>=0;i--){
			it_can_simplify_here = 1;
			if(hash_neg_number!=hash_simplify_list[i]){
				it_can_simplify_here = 0;
			}else{
				for(int64_t j=0;j<BSD_samples;j++){
					if(simplify_list[i][j] == this_line[j]){
						it_can_simplify_here = 0;
						break;
					}
				}
			}
			if(it_can_simplify_here){
				it_can_simplify   = 1;
				which_list_number = i;
				break;
			}
		}
	}
	return which_list_number;
};


