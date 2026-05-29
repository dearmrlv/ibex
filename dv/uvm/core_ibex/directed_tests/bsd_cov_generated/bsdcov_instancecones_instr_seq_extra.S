#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV64M
RVTEST_CODE_BEGIN

main:
  # BSDCOV_INSTR_SEQ_SOURCE exp/ibex_riscvdv/baseline10k_plus_instancecones_instr_seq/instr_seq_instancecones/3.STCONE_IBEX_INSTANCECONE_CORE_IBEX_TB_TOP_DUT_U_IBEX_TOP_U_IBEX_CORE_ID_STAGE_I_CONTROLLER_I_EXC_REQ_D.Ht.4.S
  .word 0x00100073  # 0: pc=0x00000080 time=(0 30) ebreak

  # BSDCOV_INSTR_SEQ_SOURCE exp/ibex_riscvdv/baseline10k_plus_instancecones_instr_seq/instr_seq_instancecones/4.NE_IBEX_INSTANCECONE_CORE_IBEX_TB_TOP_DUT_U_IBEX_TOP_U_IBEX_CORE_LOAD_STORE_UNIT_I_HANDLE_MISALIGNED_D.Ht.4.S
  .word 0x00309e03  # 0: pc=0x00000080 time=(0 30) lh x28, 3(x1)

  # BSDCOV_INSTR_SEQ_SOURCE exp/ibex_riscvdv/baseline10k_plus_instancecones_instr_seq/instr_seq_instancecones/5.X_INSTANCECONE_CORE_IBEX_TB_TOP_DUT_U_IBEX_TOP_U_IBEX_CORE_CS_REGISTERS_I_MINSTRET_COUNTER_I_COUNTER_D.Ht.4.S
  .word 0xb02162f3  # 0: pc=0x00000080 time=(0 30) csrrsi x5, 0xb02, 2

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
