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
  --prove-timeout 30 \
  --max-epochs 100 \
  --retry-limit 1 \
  --seed 1 \
  --prop-batch-size 2
# --exclude "ibex_top.u_ibex_core.cs_registers_i"
# --exclude "ibex_top.u_ibex_core.cs_registers_i.g_pmp_registers"
