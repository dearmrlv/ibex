#!/bin/bash

# ./scripts/gen_instr.sh \
#   --init-bin ../common_init/build/common_init.bin \
#   --target-sample-num -1 \
#   --seed 1 \
#   --retry-limit 3 \
#   --prove-timeout 120 \
#   --max-epochs 100 \
#   --max-generated-words 4096

./scripts/gen_instr.sh \
  --init-bin ../common_init/build/common_init.bin \
  --target-sample-num -1 \
  --max-epochs 100 \
  --retry-limit 5 \
  --seed 1
