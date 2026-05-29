#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV64M
RVTEST_CODE_BEGIN

main:
  # BSDCOV_INSTR_SEQ_SOURCE exp/ibex_riscvdv/baseline10k_plus_multicone_instr_seq/instr_seq_multicone/AST_BSDCOV_R_rf_rd_wb_hz_000.S
  .word 0x00c45003  # 0: pc=0x00000080 time=(0 30) lhu x0, 12(x8)
  .word 0x01800c33  # 1: pc=0x00000084 time=(0 40) add x24, x0, x24

  # BSDCOV_INSTR_SEQ_SOURCE exp/ibex_riscvdv/baseline10k_plus_multicone_instr_seq/instr_seq_multicone/AST_BSDCOV_R_rf_rd_wb_hz_002.S
  .word 0x00100067  # 0: pc=0x00000080 time=(0 30) jalr x0, 1(x0)

  # BSDCOV_INSTR_SEQ_SOURCE exp/ibex_riscvdv/baseline10k_plus_multicone_instr_seq/instr_seq_multicone/AST_BSDCOV_R_stall_branch_000.S
  .word 0x0b002023  # 0: pc=0x00000080 time=(0 30) sw x16, 160(x0)
  .word 0x04049263  # 1: pc=0x00000084 time=(0 40) bne x9, x0, 68

  # BSDCOV_INSTR_SEQ_SOURCE exp/ibex_riscvdv/baseline10k_plus_multicone_instr_seq/instr_seq_multicone/AST_BSDCOV_R_stall_branch_002.S
  .word 0x0b002023  # 0: pc=0x00000080 time=(0 30) sw x16, 160(x0)
  .word 0x04049263  # 1: pc=0x00000084 time=(0 40) bne x9, x0, 68

  # BSDCOV_INSTR_SEQ_SOURCE exp/ibex_riscvdv/baseline10k_plus_multicone_instr_seq/instr_seq_multicone/AST_BSDCOV_R_stall_branch_008.S
  .word 0x02400023  # 0: pc=0x00000080 time=(0 30) sb x4, 32(x0)
  .word 0x78024163  # 1: pc=0x00000084 time=(0 40) blt x4, x0, 1922

  # BSDCOV_INSTR_SEQ_SOURCE exp/ibex_riscvdv/baseline10k_plus_multicone_instr_seq/instr_seq_multicone/AST_BSDCOV_R_stall_branch_009.S
  .word 0x0b002203  # 0: pc=0x00000080 time=(0 30) lw x4, 176(x0)
  .word 0x04049263  # 1: pc=0x00000084 time=(0 40) bne x9, x0, 68

  # BSDCOV_INSTR_SEQ_SOURCE exp/ibex_riscvdv/baseline10k_plus_multicone_instr_seq/instr_seq_multicone/AST_BSDCOV_R_stall_branch_011.S
  .word 0xf84050e3  # 0: pc=0x00000080 time=(0 30) bge x0, x4, -128

  # BSDCOV_INSTR_SEQ_SOURCE exp/ibex_riscvdv/baseline10k_plus_multicone_instr_seq/instr_seq_multicone/AST_BSDCOV_R_stall_jump_000.S
  .word 0x00100067  # 0: pc=0x00000080 time=(0 30) jalr x0, 1(x0)

  # BSDCOV_INSTR_SEQ_SOURCE exp/ibex_riscvdv/baseline10k_plus_multicone_instr_seq/instr_seq_multicone/AST_BSDCOV_R_stall_jump_001.S
  .word 0x0040006f  # 0: pc=0x00000080 time=(0 30) jal x0, 4

  # BSDCOV_INSTR_SEQ_SOURCE exp/ibex_riscvdv/baseline10k_plus_multicone_instr_seq/instr_seq_multicone/AST_BSDCOV_R_stall_jump_002.S
  .word 0x0040006f  # 0: pc=0x00000080 time=(0 30) jal x0, 4

  # BSDCOV_INSTR_SEQ_SOURCE exp/ibex_riscvdv/baseline10k_plus_multicone_instr_seq/instr_seq_multicone/AST_BSDCOV_R_stall_jump_003.S
  .word 0x00180067  # 0: pc=0x00000080 time=(0 30) jalr x0, 1(x16)

  # BSDCOV_INSTR_SEQ_SOURCE exp/ibex_riscvdv/baseline10k_plus_multicone_instr_seq/instr_seq_multicone/AST_BSDCOV_R_stall_jump_004.S
  .word 0x00200803  # 0: pc=0x00000080 time=(0 30) lb x16, 2(x0)
  .word 0x00004137  # 1: pc=0x00000084 time=(0 40) lui x2, 0x00004000

  # BSDCOV_INSTR_SEQ_SOURCE exp/ibex_riscvdv/baseline10k_plus_multicone_instr_seq/instr_seq_multicone/AST_BSDCOV_R_stall_jump_007.S
  .word 0x0040006f  # 0: pc=0x00000080 time=(0 30) jal x0, 4

  # BSDCOV_INSTR_SEQ_SOURCE exp/ibex_riscvdv/baseline10k_plus_multicone_instr_seq/instr_seq_multicone/AST_BSDCOV_R_stall_ld_hz_000.S
  .word 0x0b002083  # 0: pc=0x00000080 time=(0 30) lw x1, 176(x0)
  .word 0xa010d197  # 1: pc=0x00000084 time=(0 40) auipc x3, 0xa010d000

  # BSDCOV_INSTR_SEQ_SOURCE exp/ibex_riscvdv/baseline10k_plus_multicone_instr_seq/instr_seq_multicone/AST_BSDCOV_R_stall_ld_hz_001.S
  .word 0x00415003  # 0: pc=0x00000080 time=(0 30) lhu x0, 4(x2)
  .word 0x02000fa3  # 1: pc=0x00000084 time=(0 40) sb x0, 63(x0)

  # BSDCOV_INSTR_SEQ_SOURCE exp/ibex_riscvdv/baseline10k_plus_multicone_instr_seq/instr_seq_multicone/AST_BSDCOV_R_stall_ld_hz_002.S
  .word 0x0b002083  # 0: pc=0x00000080 time=(0 30) lw x1, 176(x0)
  .word 0xa010d197  # 1: pc=0x00000084 time=(0 40) auipc x3, 0xa010d000

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
