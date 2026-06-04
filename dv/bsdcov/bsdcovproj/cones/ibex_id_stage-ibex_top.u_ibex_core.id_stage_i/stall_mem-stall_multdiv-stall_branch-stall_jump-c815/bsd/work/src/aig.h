// @start ==================================================
// @file aig.h
// @author Chongxiao Li (chongxiao_li@outlook.com)
// @brief
// @version 0.1
// @date 2022-10-27
//
// @copyright Copyright (c) 2022
//
// @end   ==================================================
#ifndef AUTOPIPELINE_AIG_H
#define AUTOPIPELINE_AIG_H
#include <assert.h>

#include <algorithm>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <vector>
class AigNode {
 public:
  AigNode();
  int node_id_ = -1;
  int left_id_ = -1;
  int right_id_ = -1;
  AigNode* left_node_ptr_ = nullptr;
  AigNode* right_node_ptr_ = nullptr;
  bool is_left_neg_ = 0;
  bool is_right_neg_ = 0;
  bool is_output_ = 0;
  int output_bits_id_ = -1;
  bool is_left_leaf_ = 0;
  bool is_right_leaf_ = 0;
  bool* left_leaf_ptr_ = nullptr;
  bool* right_leaf_ptr_ = nullptr;
  bool left_leaf_value_ = 0;
  bool right_leaf_value_ = 0;
  int key_path_length_ = -1;
  int highest_level_ = -1;
  int stage_id_ = -1;
  int infer_value_ = -1;
  bool accessed_ = false;
  std::vector<int> ancestor_ids_;

  AigNode(const AigNode& node);
  AigNode& operator=(const AigNode& node);

 private:
};

class Aig {
 public:
  Aig();
  ~Aig();
  int input_width_ = 0;
  int output_width_ = 0;
  int node_num_ = 0;
  int longest_key_path_length_ = -1;
  int* output_id_list_;
  AigNode** output_ptr_list_;
  AigNode* node_vector_;
  int AigInfer(bool* output_array, bool* input_reg);
  bool NodeInfer(AigNode& node, bool* input_reg);
  int CalHighestLevel(AigNode& node);
  int CalKeyPathLength(AigNode& node);
  int RecordAncestor();

 private:
};

int LoadAig(Aig& aig, const char* aag_dir);
#endif  // AUTOPIPELINE_AIG_H