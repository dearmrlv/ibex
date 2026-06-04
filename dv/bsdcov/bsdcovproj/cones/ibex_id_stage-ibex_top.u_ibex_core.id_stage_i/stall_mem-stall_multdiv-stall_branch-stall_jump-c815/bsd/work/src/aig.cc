// @start ==================================================
// @file aig.cc
// @author Chongxiao Li (chongxiao_li@outlook.com)
// @brief
// @version 0.1
// @date 2022-10-27
//
// @copyright Copyright (c) 2022
//
// @end   ==================================================

#include "./aig.h"

#include <limits.h>

AigNode::AigNode() {}
AigNode::AigNode(const AigNode& node) {
  node_id_ = node.node_id_;
  left_id_ = node.left_id_;
  right_id_ = node.right_id_;
  left_node_ptr_ = nullptr;
  right_node_ptr_ = nullptr;
  is_left_neg_ = node.is_left_neg_;
  is_right_neg_ = node.is_right_neg_;
  is_output_ = node.is_output_;
  output_bits_id_ = node.output_bits_id_;
  is_left_leaf_ = node.is_left_leaf_;
  is_right_leaf_ = node.is_right_leaf_;
  left_leaf_value_ = node.left_leaf_value_;
  right_leaf_value_ = node.right_leaf_value_;
  left_leaf_ptr_ = &left_leaf_value_;
  right_leaf_ptr_ = &right_leaf_value_;
  key_path_length_ = node.key_path_length_;
  highest_level_ = node.highest_level_;
  stage_id_ = node.stage_id_;
  ancestor_ids_.assign((node.ancestor_ids_).begin(),
                       (node.ancestor_ids_).end());
}
AigNode& AigNode::operator=(const AigNode& node) {
  if (this != &node) {
    node_id_ = node.node_id_;
    left_id_ = node.left_id_;
    right_id_ = node.right_id_;
    left_node_ptr_ = nullptr;
    right_node_ptr_ = nullptr;
    is_left_neg_ = node.is_left_neg_;
    is_right_neg_ = node.is_right_neg_;
    is_output_ = node.is_output_;
    output_bits_id_ = node.output_bits_id_;
    is_left_leaf_ = node.is_left_leaf_;
    is_right_leaf_ = node.is_right_leaf_;
    left_leaf_value_ = node.left_leaf_value_;
    right_leaf_value_ = node.right_leaf_value_;
    left_leaf_ptr_ = nullptr;
    right_leaf_ptr_ = nullptr;
    key_path_length_ = node.key_path_length_;
    highest_level_ = node.highest_level_;
    stage_id_ = node.stage_id_;
    ancestor_ids_.assign((node.ancestor_ids_).begin(),
                         (node.ancestor_ids_).end());
  }
  return *this;
}

int Aig::CalKeyPathLength(AigNode& node) {
  if (node.key_path_length_ == -1) {
    if (node.is_left_leaf_ && node.is_right_leaf_) {
      node.key_path_length_ = 1;
    } else if (node.is_left_leaf_ && !node.is_right_leaf_) {
      node.key_path_length_ = CalKeyPathLength(*node.right_node_ptr_) + 1;
    } else if (!node.is_left_leaf_ && node.is_right_leaf_) {
      node.key_path_length_ = CalKeyPathLength(*node.left_node_ptr_) + 1;
    } else {
      node.key_path_length_ =
          std::max(CalKeyPathLength(*node.left_node_ptr_),
                   CalKeyPathLength(*node.right_node_ptr_)) +
          1;
    }
    if (node.key_path_length_ > longest_key_path_length_) {
      longest_key_path_length_ = node.key_path_length_;
    }
  }
  assert(node.key_path_length_ > 0);
  return node.key_path_length_;
}
int Aig::RecordAncestor() {
  for (int i = 0; i < node_num_; i++) {
    if (!node_vector_[i].is_left_leaf_) {
      node_vector_[node_vector_[i].left_id_].ancestor_ids_.emplace_back(i);
    }
    if (!node_vector_[i].is_right_leaf_) {
      node_vector_[node_vector_[i].right_id_].ancestor_ids_.emplace_back(i);
    }
  }
  return 0;
}

int Aig::CalHighestLevel(AigNode& node) {
  if (node.highest_level_ == -1) {
    if (node.is_output_) {
      node.highest_level_ = node.key_path_length_;
    } else {
      int lowest_ancestor = INT_MAX;
      for (auto ancestor_id_iter = node.ancestor_ids_.begin();
           ancestor_id_iter != node.ancestor_ids_.end(); ancestor_id_iter++) {
        int level_temp = CalHighestLevel(node_vector_[*ancestor_id_iter]);
        if (lowest_ancestor > level_temp) {
          lowest_ancestor = level_temp;
        }
      }
      node.highest_level_ = std::max(lowest_ancestor - 1, 1);
    }
  }
  return node.highest_level_;
}

Aig::Aig() {}
bool Aig::NodeInfer(AigNode& node, bool* input_reg) {
  node.accessed_ = true;
  if (node.infer_value_ == -1) {
    bool left_value, right_value;
    if (node.is_left_leaf_) {
      if (node.left_id_ >= -input_width_ && node.left_id_ < 0) {
        left_value =
            node.is_left_neg_ && !(input_reg[node.left_id_ + input_width_]) ||
            !node.is_left_neg_ && (input_reg[node.left_id_ + input_width_]);
      } else {
        left_value = node.is_left_neg_ && !*(node.left_leaf_ptr_) ||
                     !node.is_left_neg_ && *(node.left_leaf_ptr_);
      }
    } else {
      left_value =
          node.is_left_neg_ && !NodeInfer(*(node.left_node_ptr_), input_reg) ||
          !node.is_left_neg_ && NodeInfer(*(node.left_node_ptr_), input_reg);
    }
    if (node.is_right_leaf_) {
      if (node.right_id_ >= -input_width_ && node.right_id_ < 0) {
        right_value =
            node.is_right_neg_ && !(input_reg[node.right_id_ + input_width_]) ||
            !node.is_right_neg_ && (input_reg[node.right_id_ + input_width_]);
      } else {
        right_value = node.is_right_neg_ && !*(node.right_leaf_ptr_) ||
                      !node.is_right_neg_ && *(node.right_leaf_ptr_);
      }
    } else {
      right_value =
          node.is_right_neg_ &&
              !NodeInfer(*(node.right_node_ptr_), input_reg) ||
          !node.is_right_neg_ && NodeInfer(*(node.right_node_ptr_), input_reg);
    }
    node.infer_value_ = static_cast<int>(left_value && right_value);
  }
  return static_cast<bool>(node.infer_value_);
}
int Aig::AigInfer(bool* output_array, bool* input_reg) {
  for (int i = 0; i < node_num_; i++) {
    node_vector_[i].infer_value_ = -1;
    node_vector_[i].accessed_ = false;
  }
  for (int i = 0; i < output_width_; i++) {
    output_array[output_ptr_list_[i]->output_bits_id_] =
        NodeInfer(*output_ptr_list_[i], input_reg);
  }
  return 0;
}
Aig::~Aig() {
  delete[] node_vector_;
  delete[] output_id_list_;
  delete[] output_ptr_list_;
}

int LoadAig(Aig& aig, const char* aag_dir) {
  std::ifstream aag;
  aag.open(aag_dir, std::ios::in);
  char format[3];
  int variable_num, input_width, latch_num, output_width, and_gate_num;
  aag >> format >> variable_num >> input_width >> latch_num >> output_width >>
      and_gate_num;
  assert(latch_num == 0);
  aig.input_width_ = input_width;
  aig.output_width_ = output_width;
  aig.node_num_ = and_gate_num + output_width;
  aig.node_vector_ = new AigNode[aig.node_num_];
  aig.output_ptr_list_ = new AigNode*[aig.output_width_];
  aig.output_id_list_ = new int[aig.output_width_];
  int place_holder = 0;
  for (int i = 0; i < input_width; i++) {
    aag >> place_holder;
  }
  for (int i = 0; i < output_width; i++) {
    aag >> place_holder;
    int node_id = and_gate_num + i;
    AigNode& node = aig.node_vector_[node_id];
    node.node_id_ = node_id;
    node.is_output_ = 1;
    node.output_bits_id_ = i;
    aig.output_ptr_list_[i] = &node;
    aig.output_id_list_[i] = node.node_id_;
    if (place_holder / 2 == 0) {
      // constant
      node.left_id_ = place_holder / 2 - input_width - 1;
      node.right_id_ = node.left_id_;
      node.left_node_ptr_ = nullptr;
      node.right_node_ptr_ = nullptr;
      node.is_left_neg_ = place_holder % 2;
      node.is_right_neg_ = node.is_left_neg_;
      node.is_left_leaf_ = true;
      node.is_right_leaf_ = node.is_left_leaf_;
      node.left_leaf_value_ = 0;
      node.right_leaf_value_ = 0;
      node.left_leaf_ptr_ = &node.left_leaf_value_;
      node.right_leaf_ptr_ = &node.right_leaf_value_;
    } else if ((place_holder / 2) > 0 && (place_holder / 2) <= input_width) {
      // input
      node.left_id_ = place_holder / 2 - input_width - 1;
      node.right_id_ = node.left_id_;
      node.left_node_ptr_ = nullptr;
      node.right_node_ptr_ = nullptr;
      node.is_left_neg_ = place_holder % 2;
      node.is_right_neg_ = node.is_left_neg_;
      node.is_left_leaf_ = true;
      node.is_right_leaf_ = node.is_left_leaf_;
      node.left_leaf_ptr_ = nullptr;
      node.right_leaf_ptr_ = node.left_leaf_ptr_;
    } else {
      // and_gate
      node.left_id_ = place_holder / 2 - input_width - 1;
      node.right_id_ = node.left_id_;
      node.left_node_ptr_ = &(aig.node_vector_[node.left_id_]);
      node.right_node_ptr_ = node.left_node_ptr_;
      node.is_left_neg_ = place_holder % 2;
      node.is_right_neg_ = node.is_left_neg_;
      node.is_left_leaf_ = false;
      node.is_right_leaf_ = node.is_left_leaf_;
    }
  }
  for (int i = 0; i < and_gate_num; i++) {
    int and_variable, left_variable, right_variable;
    aag >> and_variable >> left_variable >> right_variable;
    int node_id = and_variable / 2 - input_width - 1;
    AigNode& node = aig.node_vector_[node_id];
    node.node_id_ = node_id;
    node.is_output_ = false;
    if (left_variable / 2 == 0) {
      // constant
      node.left_id_ = left_variable / 2 - input_width - 1;
      node.left_node_ptr_ = nullptr;
      node.is_left_neg_ = left_variable % 2;
      node.is_left_leaf_ = true;
      node.left_leaf_value_ = 0;
      node.left_leaf_ptr_ = &node.left_leaf_value_;
    } else if ((left_variable / 2) > 0 && (left_variable / 2) <= input_width) {
      // input
      node.left_id_ = left_variable / 2 - input_width - 1;
      node.left_node_ptr_ = nullptr;
      node.is_left_neg_ = left_variable % 2;
      node.is_left_leaf_ = true;
      node.left_leaf_ptr_ = nullptr;
    } else {
      // and_gate
      node.left_id_ = left_variable / 2 - input_width - 1;
      node.left_node_ptr_ = &(aig.node_vector_[node.left_id_]);
      node.is_left_neg_ = left_variable % 2;
      node.is_left_leaf_ = false;
    }
    if (right_variable / 2 == 0) {
      // constant
      node.right_id_ = right_variable / 2 - input_width - 1;
      node.right_node_ptr_ = nullptr;
      node.is_right_neg_ = right_variable % 2;
      node.is_right_leaf_ = true;
      node.right_leaf_value_ = 0;
      node.right_leaf_ptr_ = &node.right_leaf_value_;
    } else if ((right_variable / 2) > 0 &&
               (right_variable / 2) <= input_width) {
      // input
      node.right_id_ = right_variable / 2 - input_width - 1;
      node.right_node_ptr_ = nullptr;
      node.is_right_neg_ = right_variable % 2;
      node.is_right_leaf_ = true;
      node.right_leaf_ptr_ = nullptr;
    } else {
      // and_gate
      node.right_id_ = right_variable / 2 - input_width - 1;
      node.right_node_ptr_ = &(aig.node_vector_[node.right_id_]);
      node.is_right_neg_ = right_variable % 2;
      node.is_right_leaf_ = false;
    }
  }
  aig.RecordAncestor();
  for (int i = 0; i < aig.node_num_; i++) {
    aig.CalKeyPathLength(aig.node_vector_[i]);
  }
  aag.close();
  return 0;
}