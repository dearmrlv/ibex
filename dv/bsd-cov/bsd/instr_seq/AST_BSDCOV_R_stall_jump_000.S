#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV64M
RVTEST_CODE_BEGIN

main:
  # Source FSDB: /home/lvzhengyang/workspace/BSD-Cov/designs/ibex/dv/bsd-cov/jgproject/traces_fsdb.bsd_cov_region_asserts/4.ibex_top.u_ibex_core.id_stage_i.bsd_cov_ibex_hazard_stall_region_asserts_bind_inst.AST_BSDCOV_R_stall_jump_000.Ht.5.fsdb
  # Extracted valid instructions: 1
  # Sample mode: all-changes gated by new-id (ibex_top.u_ibex_core.instr_first_cycle_id)
  # Reset-started trace: no
  .word 0xfb9ff0ef  # 0: pc=0x00000080 time=(0 30) jal x1, -72

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
