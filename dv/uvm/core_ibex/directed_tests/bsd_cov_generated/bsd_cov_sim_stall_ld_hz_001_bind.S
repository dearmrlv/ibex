#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV64M
RVTEST_CODE_BEGIN

main:
  # BSD-Cov source: /home/lvzhengyang/workspace/BSD-Cov/designs/ibex/dv/bsd-cov/sim/instr_seq/AST_BSDCOV_R_stall_ld_hz_001.instr.S
  .word 0xf1420003    # lb   x0, -236(x4)     ; lb zero, -236(tp)
  .word 0xf8007fe3    # bgeu x0, x0, -98      ; bgeu zero, zero, -98

  j pass

RVTEST_CODE_END

pass:
  RVTEST_PASS

fail:
  RVTEST_FAIL

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
