#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV64M
RVTEST_CODE_BEGIN

main:
  # BSDCOV_INSTR_SEQ_SOURCE designs/ibex/dv/bsd-cov/bsd/instr_seq/AST_BSDCOV_R_rf_rd_wb_hz_003.S
  .word 0x08062003  # 0: pc=0x00000080 time=(0 30) lw x0, 128(x12)
  .word 0xc8002d23  # 1: pc=0x00000084 time=(0 40) sw x0, -870(x0)

  # BSDCOV_INSTR_SEQ_SOURCE designs/ibex/dv/bsd-cov/bsd/instr_seq/AST_BSDCOV_R_rf_rd_wb_hz_004.S
  .word 0x00004403  # 0: pc=0x00000080 time=(0 30) lbu x8, 0(x0)

  # BSDCOV_INSTR_SEQ_SOURCE designs/ibex/dv/bsd-cov/bsd/instr_seq/AST_BSDCOV_R_rf_rd_wb_hz_006.S
  .word 0x32001073  # 0: pc=0x00000080 time=(0 30) csrrw x0, 0x320, x0

  # BSDCOV_INSTR_SEQ_SOURCE designs/ibex/dv/bsd-cov/bsd/instr_seq/AST_BSDCOV_R_rf_rd_wb_hz_008.S
  .word 0x00081023  # 0: pc=0x00000080 time=(0 30) sh x0, 0(x16)

  # BSDCOV_INSTR_SEQ_SOURCE designs/ibex/dv/bsd-cov/bsd/instr_seq/AST_BSDCOV_R_stall_jump_000.S
  .word 0xfb9ff0ef  # 0: pc=0x00000080 time=(0 30) jal x1, -72

  # BSDCOV_INSTR_SEQ_SOURCE designs/ibex/dv/bsd-cov/bsd/instr_seq/AST_BSDCOV_R_stall_ld_hz_000.S
  .word 0x0a428003  # 0: pc=0x00000080 time=(0 30) lb x0, 164(x5)
  .word 0x00040067  # 1: pc=0x00000084 time=(0 40) jalr x0, 0(x8)

  # BSDCOV_INSTR_SEQ_SOURCE designs/ibex/dv/bsd-cov/bsd/instr_seq/AST_BSDCOV_R_stall_ld_hz_001.S
  .word 0x0a428003  # 0: pc=0x00000080 time=(0 30) lb x0, 164(x5)
  .word 0x00800433  # 1: pc=0x00000084 time=(0 40) add x8, x0, x8

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
