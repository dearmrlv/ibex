#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV64M
RVTEST_CODE_BEGIN

main:
  la   x10, bsd_cov_data
  li   x11, 0x11111111
  li   x12, 0x22222222

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_001_0000 region=R_rf_rd_wb_hz_001 template=rf_wb_hazard_rs2
  lw   x5, 0(x10)
  add  x15, x11, x5

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_001_0001 region=R_rf_rd_wb_hz_001 template=rf_wb_hazard_rs2
  lw   x6, 4(x10)
  add  x16, x11, x6

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_001_0002 region=R_rf_rd_wb_hz_001 template=rf_wb_hazard_rs2
  lw   x7, 8(x10)
  add  x17, x11, x7

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_001_0003 region=R_rf_rd_wb_hz_001 template=rf_wb_hazard_rs2
  lw   x8, 12(x10)
  add  x18, x11, x8

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_001_0004 region=R_rf_rd_wb_hz_001 template=rf_wb_hazard_rs2
  lw   x9, 16(x10)
  add  x19, x11, x9

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_001_0005 region=R_rf_rd_wb_hz_001 template=rf_wb_hazard_rs2
  lw   x13, 20(x10)
  add  x20, x11, x13

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_001_0006 region=R_rf_rd_wb_hz_001 template=rf_wb_hazard_rs2
  lw   x14, 24(x10)
  add  x21, x11, x14

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_001_0007 region=R_rf_rd_wb_hz_001 template=rf_wb_hazard_rs2
  lw   x15, 28(x10)
  add  x22, x11, x15

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_001_0008 region=R_rf_rd_wb_hz_001 template=rf_wb_hazard_rs2
  lw   x16, 32(x10)
  add  x23, x11, x16

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_001_0009 region=R_rf_rd_wb_hz_001 template=rf_wb_hazard_rs2
  lw   x17, 36(x10)
  add  x24, x11, x17

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_001_0010 region=R_rf_rd_wb_hz_001 template=rf_wb_hazard_rs2
  lw   x18, 40(x10)
  add  x25, x11, x18

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_001_0011 region=R_rf_rd_wb_hz_001 template=rf_wb_hazard_rs2
  lw   x19, 44(x10)
  add  x26, x11, x19

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_001_0012 region=R_rf_rd_wb_hz_001 template=rf_wb_hazard_rs2
  lw   x20, 48(x10)
  add  x27, x11, x20

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_001_0013 region=R_rf_rd_wb_hz_001 template=rf_wb_hazard_rs2
  lw   x21, 52(x10)
  add  x28, x11, x21

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_001_0014 region=R_rf_rd_wb_hz_001 template=rf_wb_hazard_rs2
  lw   x22, 56(x10)
  add  x29, x11, x22

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_001_0015 region=R_rf_rd_wb_hz_001 template=rf_wb_hazard_rs2
  lw   x23, 60(x10)
  add  x30, x11, x23

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_001_0016 region=R_rf_rd_wb_hz_001 template=rf_wb_hazard_rs2
  lw   x24, 64(x10)
  add  x31, x11, x24

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_001_0017 region=R_rf_rd_wb_hz_001 template=rf_wb_hazard_rs2
  lw   x25, 68(x10)
  add  x5, x11, x25

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_001_0018 region=R_rf_rd_wb_hz_001 template=rf_wb_hazard_rs2
  lw   x26, 72(x10)
  add  x6, x11, x26

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_001_0019 region=R_rf_rd_wb_hz_001 template=rf_wb_hazard_rs2
  lw   x27, 76(x10)
  add  x7, x11, x27

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_001_0020 region=R_rf_rd_wb_hz_001 template=rf_wb_hazard_rs2
  lw   x28, 80(x10)
  add  x8, x11, x28

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_000_0000 region=R_rf_rd_wb_hz_000 template=rf_wb_hazard_rs1
  lw   x5, 0(x10)
  addi x15, x5, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_000_0001 region=R_rf_rd_wb_hz_000 template=rf_wb_hazard_rs1
  lw   x6, 4(x10)
  addi x16, x6, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_000_0002 region=R_rf_rd_wb_hz_000 template=rf_wb_hazard_rs1
  lw   x7, 8(x10)
  addi x17, x7, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_000_0003 region=R_rf_rd_wb_hz_000 template=rf_wb_hazard_rs1
  lw   x8, 12(x10)
  addi x18, x8, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_000_0004 region=R_rf_rd_wb_hz_000 template=rf_wb_hazard_rs1
  lw   x9, 16(x10)
  addi x19, x9, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_000_0005 region=R_rf_rd_wb_hz_000 template=rf_wb_hazard_rs1
  lw   x13, 20(x10)
  addi x20, x13, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_000_0006 region=R_rf_rd_wb_hz_000 template=rf_wb_hazard_rs1
  lw   x14, 24(x10)
  addi x21, x14, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_000_0007 region=R_rf_rd_wb_hz_000 template=rf_wb_hazard_rs1
  lw   x15, 28(x10)
  addi x22, x15, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_000_0008 region=R_rf_rd_wb_hz_000 template=rf_wb_hazard_rs1
  lw   x16, 32(x10)
  addi x23, x16, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_000_0009 region=R_rf_rd_wb_hz_000 template=rf_wb_hazard_rs1
  lw   x17, 36(x10)
  addi x24, x17, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_000_0010 region=R_rf_rd_wb_hz_000 template=rf_wb_hazard_rs1
  lw   x18, 40(x10)
  addi x25, x18, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_000_0011 region=R_rf_rd_wb_hz_000 template=rf_wb_hazard_rs1
  lw   x19, 44(x10)
  addi x26, x19, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_000_0012 region=R_rf_rd_wb_hz_000 template=rf_wb_hazard_rs1
  lw   x20, 48(x10)
  addi x27, x20, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_000_0013 region=R_rf_rd_wb_hz_000 template=rf_wb_hazard_rs1
  lw   x21, 52(x10)
  addi x28, x21, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_000_0014 region=R_rf_rd_wb_hz_000 template=rf_wb_hazard_rs1
  lw   x22, 56(x10)
  addi x29, x22, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_000_0015 region=R_rf_rd_wb_hz_000 template=rf_wb_hazard_rs1
  lw   x23, 60(x10)
  addi x30, x23, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_000_0016 region=R_rf_rd_wb_hz_000 template=rf_wb_hazard_rs1
  lw   x24, 64(x10)
  addi x31, x24, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_000_0017 region=R_rf_rd_wb_hz_000 template=rf_wb_hazard_rs1
  lw   x25, 68(x10)
  addi x5, x25, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_000_0018 region=R_rf_rd_wb_hz_000 template=rf_wb_hazard_rs1
  lw   x26, 72(x10)
  addi x6, x26, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_000_0019 region=R_rf_rd_wb_hz_000 template=rf_wb_hazard_rs1
  lw   x27, 76(x10)
  addi x7, x27, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_000_0020 region=R_rf_rd_wb_hz_000 template=rf_wb_hazard_rs1
  lw   x28, 80(x10)
  addi x8, x28, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_002_0000 region=R_rf_rd_wb_hz_002 template=rf_wb_hazard_rs1
  lw   x5, 0(x10)
  addi x15, x5, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_002_0001 region=R_rf_rd_wb_hz_002 template=rf_wb_hazard_rs1
  lw   x6, 4(x10)
  addi x16, x6, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_002_0002 region=R_rf_rd_wb_hz_002 template=rf_wb_hazard_rs1
  lw   x7, 8(x10)
  addi x17, x7, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_002_0003 region=R_rf_rd_wb_hz_002 template=rf_wb_hazard_rs1
  lw   x8, 12(x10)
  addi x18, x8, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_002_0004 region=R_rf_rd_wb_hz_002 template=rf_wb_hazard_rs1
  lw   x9, 16(x10)
  addi x19, x9, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_002_0005 region=R_rf_rd_wb_hz_002 template=rf_wb_hazard_rs1
  lw   x13, 20(x10)
  addi x20, x13, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_002_0006 region=R_rf_rd_wb_hz_002 template=rf_wb_hazard_rs1
  lw   x14, 24(x10)
  addi x21, x14, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_002_0007 region=R_rf_rd_wb_hz_002 template=rf_wb_hazard_rs1
  lw   x15, 28(x10)
  addi x22, x15, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_002_0008 region=R_rf_rd_wb_hz_002 template=rf_wb_hazard_rs1
  lw   x16, 32(x10)
  addi x23, x16, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_002_0009 region=R_rf_rd_wb_hz_002 template=rf_wb_hazard_rs1
  lw   x17, 36(x10)
  addi x24, x17, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_002_0010 region=R_rf_rd_wb_hz_002 template=rf_wb_hazard_rs1
  lw   x18, 40(x10)
  addi x25, x18, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_002_0011 region=R_rf_rd_wb_hz_002 template=rf_wb_hazard_rs1
  lw   x19, 44(x10)
  addi x26, x19, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_002_0012 region=R_rf_rd_wb_hz_002 template=rf_wb_hazard_rs1
  lw   x20, 48(x10)
  addi x27, x20, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_002_0013 region=R_rf_rd_wb_hz_002 template=rf_wb_hazard_rs1
  lw   x21, 52(x10)
  addi x28, x21, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_002_0014 region=R_rf_rd_wb_hz_002 template=rf_wb_hazard_rs1
  lw   x22, 56(x10)
  addi x29, x22, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_002_0015 region=R_rf_rd_wb_hz_002 template=rf_wb_hazard_rs1
  lw   x23, 60(x10)
  addi x30, x23, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_002_0016 region=R_rf_rd_wb_hz_002 template=rf_wb_hazard_rs1
  lw   x24, 64(x10)
  addi x31, x24, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_002_0017 region=R_rf_rd_wb_hz_002 template=rf_wb_hazard_rs1
  lw   x25, 68(x10)
  addi x5, x25, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_002_0018 region=R_rf_rd_wb_hz_002 template=rf_wb_hazard_rs1
  lw   x26, 72(x10)
  addi x6, x26, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_002_0019 region=R_rf_rd_wb_hz_002 template=rf_wb_hazard_rs1
  lw   x27, 76(x10)
  addi x7, x27, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_002_0020 region=R_rf_rd_wb_hz_002 template=rf_wb_hazard_rs1
  lw   x28, 80(x10)
  addi x8, x28, 1

  # BSDCOV_SEQ seq_R_stall_jump_001_0000 region=R_stall_jump_001 template=jump_after_load
  lw   x5, 0(x10)
  andi x5, x5, 0
  la   x21, seq_R_stall_jump_001_0000_target
  add  x5, x5, x21
  jalr x1, 0(x5)
  addi x15, x11, 1
  seq_R_stall_jump_001_0000_target:
  addi x15, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_001_0001 region=R_stall_jump_001 template=jump_after_load
  lw   x6, 4(x10)
  andi x6, x6, 0
  la   x22, seq_R_stall_jump_001_0001_target
  add  x6, x6, x22
  jalr x1, 0(x6)
  addi x16, x11, 1
  seq_R_stall_jump_001_0001_target:
  addi x16, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_001_0002 region=R_stall_jump_001 template=jump_after_load
  lw   x7, 8(x10)
  andi x7, x7, 0
  la   x23, seq_R_stall_jump_001_0002_target
  add  x7, x7, x23
  jalr x1, 0(x7)
  addi x17, x11, 1
  seq_R_stall_jump_001_0002_target:
  addi x17, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_001_0003 region=R_stall_jump_001 template=jump_after_load
  lw   x8, 12(x10)
  andi x8, x8, 0
  la   x24, seq_R_stall_jump_001_0003_target
  add  x8, x8, x24
  jalr x1, 0(x8)
  addi x18, x11, 1
  seq_R_stall_jump_001_0003_target:
  addi x18, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_001_0004 region=R_stall_jump_001 template=jump_after_load
  lw   x9, 16(x10)
  andi x9, x9, 0
  la   x25, seq_R_stall_jump_001_0004_target
  add  x9, x9, x25
  jalr x1, 0(x9)
  addi x19, x11, 1
  seq_R_stall_jump_001_0004_target:
  addi x19, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_001_0005 region=R_stall_jump_001 template=jump_after_load
  lw   x13, 20(x10)
  andi x13, x13, 0
  la   x26, seq_R_stall_jump_001_0005_target
  add  x13, x13, x26
  jalr x1, 0(x13)
  addi x20, x11, 1
  seq_R_stall_jump_001_0005_target:
  addi x20, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_001_0006 region=R_stall_jump_001 template=jump_after_load
  lw   x14, 24(x10)
  andi x14, x14, 0
  la   x27, seq_R_stall_jump_001_0006_target
  add  x14, x14, x27
  jalr x1, 0(x14)
  addi x21, x11, 1
  seq_R_stall_jump_001_0006_target:
  addi x21, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_001_0007 region=R_stall_jump_001 template=jump_after_load
  lw   x15, 28(x10)
  andi x15, x15, 0
  la   x28, seq_R_stall_jump_001_0007_target
  add  x15, x15, x28
  jalr x1, 0(x15)
  addi x22, x11, 1
  seq_R_stall_jump_001_0007_target:
  addi x22, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_001_0008 region=R_stall_jump_001 template=jump_after_load
  lw   x16, 32(x10)
  andi x16, x16, 0
  la   x29, seq_R_stall_jump_001_0008_target
  add  x16, x16, x29
  jalr x1, 0(x16)
  addi x23, x11, 1
  seq_R_stall_jump_001_0008_target:
  addi x23, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_001_0009 region=R_stall_jump_001 template=jump_after_load
  lw   x17, 36(x10)
  andi x17, x17, 0
  la   x30, seq_R_stall_jump_001_0009_target
  add  x17, x17, x30
  jalr x1, 0(x17)
  addi x24, x11, 1
  seq_R_stall_jump_001_0009_target:
  addi x24, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_001_0010 region=R_stall_jump_001 template=jump_after_load
  lw   x18, 40(x10)
  andi x18, x18, 0
  la   x31, seq_R_stall_jump_001_0010_target
  add  x18, x18, x31
  jalr x1, 0(x18)
  addi x25, x11, 1
  seq_R_stall_jump_001_0010_target:
  addi x25, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_001_0011 region=R_stall_jump_001 template=jump_after_load
  lw   x19, 44(x10)
  andi x19, x19, 0
  la   x5, seq_R_stall_jump_001_0011_target
  add  x19, x19, x5
  jalr x1, 0(x19)
  addi x26, x11, 1
  seq_R_stall_jump_001_0011_target:
  addi x26, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_001_0012 region=R_stall_jump_001 template=jump_after_load
  lw   x20, 48(x10)
  andi x20, x20, 0
  la   x6, seq_R_stall_jump_001_0012_target
  add  x20, x20, x6
  jalr x1, 0(x20)
  addi x27, x11, 1
  seq_R_stall_jump_001_0012_target:
  addi x27, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_001_0013 region=R_stall_jump_001 template=jump_after_load
  lw   x21, 52(x10)
  andi x21, x21, 0
  la   x7, seq_R_stall_jump_001_0013_target
  add  x21, x21, x7
  jalr x1, 0(x21)
  addi x28, x11, 1
  seq_R_stall_jump_001_0013_target:
  addi x28, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_001_0014 region=R_stall_jump_001 template=jump_after_load
  lw   x22, 56(x10)
  andi x22, x22, 0
  la   x8, seq_R_stall_jump_001_0014_target
  add  x22, x22, x8
  jalr x1, 0(x22)
  addi x29, x11, 1
  seq_R_stall_jump_001_0014_target:
  addi x29, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_001_0015 region=R_stall_jump_001 template=jump_after_load
  lw   x23, 60(x10)
  andi x23, x23, 0
  la   x9, seq_R_stall_jump_001_0015_target
  add  x23, x23, x9
  jalr x1, 0(x23)
  addi x30, x11, 1
  seq_R_stall_jump_001_0015_target:
  addi x30, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_001_0016 region=R_stall_jump_001 template=jump_after_load
  lw   x24, 64(x10)
  andi x24, x24, 0
  la   x13, seq_R_stall_jump_001_0016_target
  add  x24, x24, x13
  jalr x1, 0(x24)
  addi x31, x11, 1
  seq_R_stall_jump_001_0016_target:
  addi x31, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_001_0017 region=R_stall_jump_001 template=jump_after_load
  lw   x25, 68(x10)
  andi x25, x25, 0
  la   x14, seq_R_stall_jump_001_0017_target
  add  x25, x25, x14
  jalr x1, 0(x25)
  addi x5, x11, 1
  seq_R_stall_jump_001_0017_target:
  addi x5, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_001_0018 region=R_stall_jump_001 template=jump_after_load
  lw   x26, 72(x10)
  andi x26, x26, 0
  la   x15, seq_R_stall_jump_001_0018_target
  add  x26, x26, x15
  jalr x1, 0(x26)
  addi x6, x11, 1
  seq_R_stall_jump_001_0018_target:
  addi x6, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_001_0019 region=R_stall_jump_001 template=jump_after_load
  lw   x27, 76(x10)
  andi x27, x27, 0
  la   x16, seq_R_stall_jump_001_0019_target
  add  x27, x27, x16
  jalr x1, 0(x27)
  addi x7, x11, 1
  seq_R_stall_jump_001_0019_target:
  addi x7, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_001_0020 region=R_stall_jump_001 template=jump_after_load
  lw   x28, 80(x10)
  andi x28, x28, 0
  la   x17, seq_R_stall_jump_001_0020_target
  add  x28, x28, x17
  jalr x1, 0(x28)
  addi x8, x11, 1
  seq_R_stall_jump_001_0020_target:
  addi x8, x11, 2

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_007_0000 region=R_rf_rd_wb_hz_007 template=rf_wb_hazard_rs1
  lw   x5, 0(x10)
  addi x15, x5, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_007_0001 region=R_rf_rd_wb_hz_007 template=rf_wb_hazard_rs1
  lw   x6, 4(x10)
  addi x16, x6, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_007_0002 region=R_rf_rd_wb_hz_007 template=rf_wb_hazard_rs1
  lw   x7, 8(x10)
  addi x17, x7, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_007_0003 region=R_rf_rd_wb_hz_007 template=rf_wb_hazard_rs1
  lw   x8, 12(x10)
  addi x18, x8, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_007_0004 region=R_rf_rd_wb_hz_007 template=rf_wb_hazard_rs1
  lw   x9, 16(x10)
  addi x19, x9, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_007_0005 region=R_rf_rd_wb_hz_007 template=rf_wb_hazard_rs1
  lw   x13, 20(x10)
  addi x20, x13, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_007_0006 region=R_rf_rd_wb_hz_007 template=rf_wb_hazard_rs1
  lw   x14, 24(x10)
  addi x21, x14, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_007_0007 region=R_rf_rd_wb_hz_007 template=rf_wb_hazard_rs1
  lw   x15, 28(x10)
  addi x22, x15, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_007_0008 region=R_rf_rd_wb_hz_007 template=rf_wb_hazard_rs1
  lw   x16, 32(x10)
  addi x23, x16, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_007_0009 region=R_rf_rd_wb_hz_007 template=rf_wb_hazard_rs1
  lw   x17, 36(x10)
  addi x24, x17, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_007_0010 region=R_rf_rd_wb_hz_007 template=rf_wb_hazard_rs1
  lw   x18, 40(x10)
  addi x25, x18, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_007_0011 region=R_rf_rd_wb_hz_007 template=rf_wb_hazard_rs1
  lw   x19, 44(x10)
  addi x26, x19, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_007_0012 region=R_rf_rd_wb_hz_007 template=rf_wb_hazard_rs1
  lw   x20, 48(x10)
  addi x27, x20, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_007_0013 region=R_rf_rd_wb_hz_007 template=rf_wb_hazard_rs1
  lw   x21, 52(x10)
  addi x28, x21, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_007_0014 region=R_rf_rd_wb_hz_007 template=rf_wb_hazard_rs1
  lw   x22, 56(x10)
  addi x29, x22, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_007_0015 region=R_rf_rd_wb_hz_007 template=rf_wb_hazard_rs1
  lw   x23, 60(x10)
  addi x30, x23, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_007_0016 region=R_rf_rd_wb_hz_007 template=rf_wb_hazard_rs1
  lw   x24, 64(x10)
  addi x31, x24, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_007_0017 region=R_rf_rd_wb_hz_007 template=rf_wb_hazard_rs1
  lw   x25, 68(x10)
  addi x5, x25, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_007_0018 region=R_rf_rd_wb_hz_007 template=rf_wb_hazard_rs1
  lw   x26, 72(x10)
  addi x6, x26, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_007_0019 region=R_rf_rd_wb_hz_007 template=rf_wb_hazard_rs1
  lw   x27, 76(x10)
  addi x7, x27, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_007_0020 region=R_rf_rd_wb_hz_007 template=rf_wb_hazard_rs1
  lw   x28, 80(x10)
  addi x8, x28, 1

  # BSDCOV_SEQ seq_R_stall_multdiv_001_0000 region=R_stall_multdiv_001 template=mul_active
  mul  x5, x11, x12
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_001_0001 region=R_stall_multdiv_001 template=mul_active
  mul  x6, x11, x12
  add  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_001_0002 region=R_stall_multdiv_001 template=mul_active
  mul  x7, x11, x12
  add  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_001_0003 region=R_stall_multdiv_001 template=mul_active
  mul  x8, x11, x12
  add  x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_001_0004 region=R_stall_multdiv_001 template=mul_active
  mul  x9, x11, x12
  add  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_001_0005 region=R_stall_multdiv_001 template=mul_active
  mul  x13, x11, x12
  add  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_001_0006 region=R_stall_multdiv_001 template=mul_active
  mul  x14, x11, x12
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_001_0007 region=R_stall_multdiv_001 template=mul_active
  mul  x15, x11, x12
  add  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_001_0008 region=R_stall_multdiv_001 template=mul_active
  mul  x16, x11, x12
  add  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_001_0009 region=R_stall_multdiv_001 template=mul_active
  mul  x17, x11, x12
  add  x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_001_0010 region=R_stall_multdiv_001 template=mul_active
  mul  x18, x11, x12
  add  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_001_0011 region=R_stall_multdiv_001 template=mul_active
  mul  x19, x11, x12
  add  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_001_0012 region=R_stall_multdiv_001 template=mul_active
  mul  x20, x11, x12
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_001_0013 region=R_stall_multdiv_001 template=mul_active
  mul  x21, x11, x12
  add  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_001_0014 region=R_stall_multdiv_001 template=mul_active
  mul  x22, x11, x12
  add  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_001_0015 region=R_stall_multdiv_001 template=mul_active
  mul  x23, x11, x12
  add  x30, x23, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_001_0016 region=R_stall_multdiv_001 template=mul_active
  mul  x24, x11, x12
  add  x31, x24, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_001_0017 region=R_stall_multdiv_001 template=mul_active
  mul  x25, x11, x12
  add  x5, x25, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_001_0018 region=R_stall_multdiv_001 template=mul_active
  mul  x26, x11, x12
  add  x6, x26, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_001_0019 region=R_stall_multdiv_001 template=mul_active
  mul  x27, x11, x12
  add  x7, x27, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_001_0020 region=R_stall_multdiv_001 template=mul_active
  mul  x28, x11, x12
  add  x8, x28, x11

  # BSDCOV_SEQ seq_R_stall_jump_000_0000 region=R_stall_jump_000 template=jump_after_load
  lw   x5, 0(x10)
  andi x5, x5, 0
  la   x21, seq_R_stall_jump_000_0000_target
  add  x5, x5, x21
  jalr x1, 0(x5)
  addi x15, x11, 1
  seq_R_stall_jump_000_0000_target:
  addi x15, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_000_0001 region=R_stall_jump_000 template=jump_after_load
  lw   x6, 4(x10)
  andi x6, x6, 0
  la   x22, seq_R_stall_jump_000_0001_target
  add  x6, x6, x22
  jalr x1, 0(x6)
  addi x16, x11, 1
  seq_R_stall_jump_000_0001_target:
  addi x16, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_000_0002 region=R_stall_jump_000 template=jump_after_load
  lw   x7, 8(x10)
  andi x7, x7, 0
  la   x23, seq_R_stall_jump_000_0002_target
  add  x7, x7, x23
  jalr x1, 0(x7)
  addi x17, x11, 1
  seq_R_stall_jump_000_0002_target:
  addi x17, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_000_0003 region=R_stall_jump_000 template=jump_after_load
  lw   x8, 12(x10)
  andi x8, x8, 0
  la   x24, seq_R_stall_jump_000_0003_target
  add  x8, x8, x24
  jalr x1, 0(x8)
  addi x18, x11, 1
  seq_R_stall_jump_000_0003_target:
  addi x18, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_000_0004 region=R_stall_jump_000 template=jump_after_load
  lw   x9, 16(x10)
  andi x9, x9, 0
  la   x25, seq_R_stall_jump_000_0004_target
  add  x9, x9, x25
  jalr x1, 0(x9)
  addi x19, x11, 1
  seq_R_stall_jump_000_0004_target:
  addi x19, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_000_0005 region=R_stall_jump_000 template=jump_after_load
  lw   x13, 20(x10)
  andi x13, x13, 0
  la   x26, seq_R_stall_jump_000_0005_target
  add  x13, x13, x26
  jalr x1, 0(x13)
  addi x20, x11, 1
  seq_R_stall_jump_000_0005_target:
  addi x20, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_000_0006 region=R_stall_jump_000 template=jump_after_load
  lw   x14, 24(x10)
  andi x14, x14, 0
  la   x27, seq_R_stall_jump_000_0006_target
  add  x14, x14, x27
  jalr x1, 0(x14)
  addi x21, x11, 1
  seq_R_stall_jump_000_0006_target:
  addi x21, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_000_0007 region=R_stall_jump_000 template=jump_after_load
  lw   x15, 28(x10)
  andi x15, x15, 0
  la   x28, seq_R_stall_jump_000_0007_target
  add  x15, x15, x28
  jalr x1, 0(x15)
  addi x22, x11, 1
  seq_R_stall_jump_000_0007_target:
  addi x22, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_000_0008 region=R_stall_jump_000 template=jump_after_load
  lw   x16, 32(x10)
  andi x16, x16, 0
  la   x29, seq_R_stall_jump_000_0008_target
  add  x16, x16, x29
  jalr x1, 0(x16)
  addi x23, x11, 1
  seq_R_stall_jump_000_0008_target:
  addi x23, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_000_0009 region=R_stall_jump_000 template=jump_after_load
  lw   x17, 36(x10)
  andi x17, x17, 0
  la   x30, seq_R_stall_jump_000_0009_target
  add  x17, x17, x30
  jalr x1, 0(x17)
  addi x24, x11, 1
  seq_R_stall_jump_000_0009_target:
  addi x24, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_000_0010 region=R_stall_jump_000 template=jump_after_load
  lw   x18, 40(x10)
  andi x18, x18, 0
  la   x31, seq_R_stall_jump_000_0010_target
  add  x18, x18, x31
  jalr x1, 0(x18)
  addi x25, x11, 1
  seq_R_stall_jump_000_0010_target:
  addi x25, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_000_0011 region=R_stall_jump_000 template=jump_after_load
  lw   x19, 44(x10)
  andi x19, x19, 0
  la   x5, seq_R_stall_jump_000_0011_target
  add  x19, x19, x5
  jalr x1, 0(x19)
  addi x26, x11, 1
  seq_R_stall_jump_000_0011_target:
  addi x26, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_000_0012 region=R_stall_jump_000 template=jump_after_load
  lw   x20, 48(x10)
  andi x20, x20, 0
  la   x6, seq_R_stall_jump_000_0012_target
  add  x20, x20, x6
  jalr x1, 0(x20)
  addi x27, x11, 1
  seq_R_stall_jump_000_0012_target:
  addi x27, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_000_0013 region=R_stall_jump_000 template=jump_after_load
  lw   x21, 52(x10)
  andi x21, x21, 0
  la   x7, seq_R_stall_jump_000_0013_target
  add  x21, x21, x7
  jalr x1, 0(x21)
  addi x28, x11, 1
  seq_R_stall_jump_000_0013_target:
  addi x28, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_000_0014 region=R_stall_jump_000 template=jump_after_load
  lw   x22, 56(x10)
  andi x22, x22, 0
  la   x8, seq_R_stall_jump_000_0014_target
  add  x22, x22, x8
  jalr x1, 0(x22)
  addi x29, x11, 1
  seq_R_stall_jump_000_0014_target:
  addi x29, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_000_0015 region=R_stall_jump_000 template=jump_after_load
  lw   x23, 60(x10)
  andi x23, x23, 0
  la   x9, seq_R_stall_jump_000_0015_target
  add  x23, x23, x9
  jalr x1, 0(x23)
  addi x30, x11, 1
  seq_R_stall_jump_000_0015_target:
  addi x30, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_000_0016 region=R_stall_jump_000 template=jump_after_load
  lw   x24, 64(x10)
  andi x24, x24, 0
  la   x13, seq_R_stall_jump_000_0016_target
  add  x24, x24, x13
  jalr x1, 0(x24)
  addi x31, x11, 1
  seq_R_stall_jump_000_0016_target:
  addi x31, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_000_0017 region=R_stall_jump_000 template=jump_after_load
  lw   x25, 68(x10)
  andi x25, x25, 0
  la   x14, seq_R_stall_jump_000_0017_target
  add  x25, x25, x14
  jalr x1, 0(x25)
  addi x5, x11, 1
  seq_R_stall_jump_000_0017_target:
  addi x5, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_000_0018 region=R_stall_jump_000 template=jump_after_load
  lw   x26, 72(x10)
  andi x26, x26, 0
  la   x15, seq_R_stall_jump_000_0018_target
  add  x26, x26, x15
  jalr x1, 0(x26)
  addi x6, x11, 1
  seq_R_stall_jump_000_0018_target:
  addi x6, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_000_0019 region=R_stall_jump_000 template=jump_after_load
  lw   x27, 76(x10)
  andi x27, x27, 0
  la   x16, seq_R_stall_jump_000_0019_target
  add  x27, x27, x16
  jalr x1, 0(x27)
  addi x7, x11, 1
  seq_R_stall_jump_000_0019_target:
  addi x7, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_000_0020 region=R_stall_jump_000 template=jump_after_load
  lw   x28, 80(x10)
  andi x28, x28, 0
  la   x17, seq_R_stall_jump_000_0020_target
  add  x28, x28, x17
  jalr x1, 0(x28)
  addi x8, x11, 1
  seq_R_stall_jump_000_0020_target:
  addi x8, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_005_0000 region=R_stall_multdiv_005 template=mul_active
  mul  x5, x11, x12
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_005_0001 region=R_stall_multdiv_005 template=mul_active
  mul  x6, x11, x12
  add  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_005_0002 region=R_stall_multdiv_005 template=mul_active
  mul  x7, x11, x12
  add  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_005_0003 region=R_stall_multdiv_005 template=mul_active
  mul  x8, x11, x12
  add  x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_005_0004 region=R_stall_multdiv_005 template=mul_active
  mul  x9, x11, x12
  add  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_005_0005 region=R_stall_multdiv_005 template=mul_active
  mul  x13, x11, x12
  add  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_005_0006 region=R_stall_multdiv_005 template=mul_active
  mul  x14, x11, x12
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_005_0007 region=R_stall_multdiv_005 template=mul_active
  mul  x15, x11, x12
  add  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_005_0008 region=R_stall_multdiv_005 template=mul_active
  mul  x16, x11, x12
  add  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_005_0009 region=R_stall_multdiv_005 template=mul_active
  mul  x17, x11, x12
  add  x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_005_0010 region=R_stall_multdiv_005 template=mul_active
  mul  x18, x11, x12
  add  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_005_0011 region=R_stall_multdiv_005 template=mul_active
  mul  x19, x11, x12
  add  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_005_0012 region=R_stall_multdiv_005 template=mul_active
  mul  x20, x11, x12
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_005_0013 region=R_stall_multdiv_005 template=mul_active
  mul  x21, x11, x12
  add  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_005_0014 region=R_stall_multdiv_005 template=mul_active
  mul  x22, x11, x12
  add  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_005_0015 region=R_stall_multdiv_005 template=mul_active
  mul  x23, x11, x12
  add  x30, x23, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_005_0016 region=R_stall_multdiv_005 template=mul_active
  mul  x24, x11, x12
  add  x31, x24, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_005_0017 region=R_stall_multdiv_005 template=mul_active
  mul  x25, x11, x12
  add  x5, x25, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_005_0018 region=R_stall_multdiv_005 template=mul_active
  mul  x26, x11, x12
  add  x6, x26, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_005_0019 region=R_stall_multdiv_005 template=mul_active
  mul  x27, x11, x12
  add  x7, x27, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_005_0020 region=R_stall_multdiv_005 template=mul_active
  mul  x28, x11, x12
  add  x8, x28, x11

  # BSDCOV_SEQ seq_R_stall_jump_002_0000 region=R_stall_jump_002 template=jump_after_load
  lw   x5, 0(x10)
  andi x5, x5, 0
  la   x21, seq_R_stall_jump_002_0000_target
  add  x5, x5, x21
  jalr x1, 0(x5)
  addi x15, x11, 1
  seq_R_stall_jump_002_0000_target:
  addi x15, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_002_0001 region=R_stall_jump_002 template=jump_after_load
  lw   x6, 4(x10)
  andi x6, x6, 0
  la   x22, seq_R_stall_jump_002_0001_target
  add  x6, x6, x22
  jalr x1, 0(x6)
  addi x16, x11, 1
  seq_R_stall_jump_002_0001_target:
  addi x16, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_002_0002 region=R_stall_jump_002 template=jump_after_load
  lw   x7, 8(x10)
  andi x7, x7, 0
  la   x23, seq_R_stall_jump_002_0002_target
  add  x7, x7, x23
  jalr x1, 0(x7)
  addi x17, x11, 1
  seq_R_stall_jump_002_0002_target:
  addi x17, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_002_0003 region=R_stall_jump_002 template=jump_after_load
  lw   x8, 12(x10)
  andi x8, x8, 0
  la   x24, seq_R_stall_jump_002_0003_target
  add  x8, x8, x24
  jalr x1, 0(x8)
  addi x18, x11, 1
  seq_R_stall_jump_002_0003_target:
  addi x18, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_002_0004 region=R_stall_jump_002 template=jump_after_load
  lw   x9, 16(x10)
  andi x9, x9, 0
  la   x25, seq_R_stall_jump_002_0004_target
  add  x9, x9, x25
  jalr x1, 0(x9)
  addi x19, x11, 1
  seq_R_stall_jump_002_0004_target:
  addi x19, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_002_0005 region=R_stall_jump_002 template=jump_after_load
  lw   x13, 20(x10)
  andi x13, x13, 0
  la   x26, seq_R_stall_jump_002_0005_target
  add  x13, x13, x26
  jalr x1, 0(x13)
  addi x20, x11, 1
  seq_R_stall_jump_002_0005_target:
  addi x20, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_002_0006 region=R_stall_jump_002 template=jump_after_load
  lw   x14, 24(x10)
  andi x14, x14, 0
  la   x27, seq_R_stall_jump_002_0006_target
  add  x14, x14, x27
  jalr x1, 0(x14)
  addi x21, x11, 1
  seq_R_stall_jump_002_0006_target:
  addi x21, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_002_0007 region=R_stall_jump_002 template=jump_after_load
  lw   x15, 28(x10)
  andi x15, x15, 0
  la   x28, seq_R_stall_jump_002_0007_target
  add  x15, x15, x28
  jalr x1, 0(x15)
  addi x22, x11, 1
  seq_R_stall_jump_002_0007_target:
  addi x22, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_002_0008 region=R_stall_jump_002 template=jump_after_load
  lw   x16, 32(x10)
  andi x16, x16, 0
  la   x29, seq_R_stall_jump_002_0008_target
  add  x16, x16, x29
  jalr x1, 0(x16)
  addi x23, x11, 1
  seq_R_stall_jump_002_0008_target:
  addi x23, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_002_0009 region=R_stall_jump_002 template=jump_after_load
  lw   x17, 36(x10)
  andi x17, x17, 0
  la   x30, seq_R_stall_jump_002_0009_target
  add  x17, x17, x30
  jalr x1, 0(x17)
  addi x24, x11, 1
  seq_R_stall_jump_002_0009_target:
  addi x24, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_002_0010 region=R_stall_jump_002 template=jump_after_load
  lw   x18, 40(x10)
  andi x18, x18, 0
  la   x31, seq_R_stall_jump_002_0010_target
  add  x18, x18, x31
  jalr x1, 0(x18)
  addi x25, x11, 1
  seq_R_stall_jump_002_0010_target:
  addi x25, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_002_0011 region=R_stall_jump_002 template=jump_after_load
  lw   x19, 44(x10)
  andi x19, x19, 0
  la   x5, seq_R_stall_jump_002_0011_target
  add  x19, x19, x5
  jalr x1, 0(x19)
  addi x26, x11, 1
  seq_R_stall_jump_002_0011_target:
  addi x26, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_002_0012 region=R_stall_jump_002 template=jump_after_load
  lw   x20, 48(x10)
  andi x20, x20, 0
  la   x6, seq_R_stall_jump_002_0012_target
  add  x20, x20, x6
  jalr x1, 0(x20)
  addi x27, x11, 1
  seq_R_stall_jump_002_0012_target:
  addi x27, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_002_0013 region=R_stall_jump_002 template=jump_after_load
  lw   x21, 52(x10)
  andi x21, x21, 0
  la   x7, seq_R_stall_jump_002_0013_target
  add  x21, x21, x7
  jalr x1, 0(x21)
  addi x28, x11, 1
  seq_R_stall_jump_002_0013_target:
  addi x28, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_002_0014 region=R_stall_jump_002 template=jump_after_load
  lw   x22, 56(x10)
  andi x22, x22, 0
  la   x8, seq_R_stall_jump_002_0014_target
  add  x22, x22, x8
  jalr x1, 0(x22)
  addi x29, x11, 1
  seq_R_stall_jump_002_0014_target:
  addi x29, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_002_0015 region=R_stall_jump_002 template=jump_after_load
  lw   x23, 60(x10)
  andi x23, x23, 0
  la   x9, seq_R_stall_jump_002_0015_target
  add  x23, x23, x9
  jalr x1, 0(x23)
  addi x30, x11, 1
  seq_R_stall_jump_002_0015_target:
  addi x30, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_002_0016 region=R_stall_jump_002 template=jump_after_load
  lw   x24, 64(x10)
  andi x24, x24, 0
  la   x13, seq_R_stall_jump_002_0016_target
  add  x24, x24, x13
  jalr x1, 0(x24)
  addi x31, x11, 1
  seq_R_stall_jump_002_0016_target:
  addi x31, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_002_0017 region=R_stall_jump_002 template=jump_after_load
  lw   x25, 68(x10)
  andi x25, x25, 0
  la   x14, seq_R_stall_jump_002_0017_target
  add  x25, x25, x14
  jalr x1, 0(x25)
  addi x5, x11, 1
  seq_R_stall_jump_002_0017_target:
  addi x5, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_002_0018 region=R_stall_jump_002 template=jump_after_load
  lw   x26, 72(x10)
  andi x26, x26, 0
  la   x15, seq_R_stall_jump_002_0018_target
  add  x26, x26, x15
  jalr x1, 0(x26)
  addi x6, x11, 1
  seq_R_stall_jump_002_0018_target:
  addi x6, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_002_0019 region=R_stall_jump_002 template=jump_after_load
  lw   x27, 76(x10)
  andi x27, x27, 0
  la   x16, seq_R_stall_jump_002_0019_target
  add  x27, x27, x16
  jalr x1, 0(x27)
  addi x7, x11, 1
  seq_R_stall_jump_002_0019_target:
  addi x7, x11, 2

  # BSDCOV_SEQ seq_R_stall_jump_002_0020 region=R_stall_jump_002 template=jump_after_load
  lw   x28, 80(x10)
  andi x28, x28, 0
  la   x17, seq_R_stall_jump_002_0020_target
  add  x28, x28, x17
  jalr x1, 0(x28)
  addi x8, x11, 1
  seq_R_stall_jump_002_0020_target:
  addi x8, x11, 2

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_004_0000 region=R_rf_rd_wb_hz_004 template=rf_wb_hazard_rs1
  lw   x5, 0(x10)
  addi x15, x5, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_004_0001 region=R_rf_rd_wb_hz_004 template=rf_wb_hazard_rs1
  lw   x6, 4(x10)
  addi x16, x6, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_004_0002 region=R_rf_rd_wb_hz_004 template=rf_wb_hazard_rs1
  lw   x7, 8(x10)
  addi x17, x7, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_004_0003 region=R_rf_rd_wb_hz_004 template=rf_wb_hazard_rs1
  lw   x8, 12(x10)
  addi x18, x8, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_004_0004 region=R_rf_rd_wb_hz_004 template=rf_wb_hazard_rs1
  lw   x9, 16(x10)
  addi x19, x9, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_004_0005 region=R_rf_rd_wb_hz_004 template=rf_wb_hazard_rs1
  lw   x13, 20(x10)
  addi x20, x13, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_004_0006 region=R_rf_rd_wb_hz_004 template=rf_wb_hazard_rs1
  lw   x14, 24(x10)
  addi x21, x14, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_004_0007 region=R_rf_rd_wb_hz_004 template=rf_wb_hazard_rs1
  lw   x15, 28(x10)
  addi x22, x15, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_004_0008 region=R_rf_rd_wb_hz_004 template=rf_wb_hazard_rs1
  lw   x16, 32(x10)
  addi x23, x16, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_004_0009 region=R_rf_rd_wb_hz_004 template=rf_wb_hazard_rs1
  lw   x17, 36(x10)
  addi x24, x17, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_004_0010 region=R_rf_rd_wb_hz_004 template=rf_wb_hazard_rs1
  lw   x18, 40(x10)
  addi x25, x18, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_004_0011 region=R_rf_rd_wb_hz_004 template=rf_wb_hazard_rs1
  lw   x19, 44(x10)
  addi x26, x19, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_004_0012 region=R_rf_rd_wb_hz_004 template=rf_wb_hazard_rs1
  lw   x20, 48(x10)
  addi x27, x20, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_004_0013 region=R_rf_rd_wb_hz_004 template=rf_wb_hazard_rs1
  lw   x21, 52(x10)
  addi x28, x21, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_004_0014 region=R_rf_rd_wb_hz_004 template=rf_wb_hazard_rs1
  lw   x22, 56(x10)
  addi x29, x22, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_004_0015 region=R_rf_rd_wb_hz_004 template=rf_wb_hazard_rs1
  lw   x23, 60(x10)
  addi x30, x23, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_004_0016 region=R_rf_rd_wb_hz_004 template=rf_wb_hazard_rs1
  lw   x24, 64(x10)
  addi x31, x24, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_004_0017 region=R_rf_rd_wb_hz_004 template=rf_wb_hazard_rs1
  lw   x25, 68(x10)
  addi x5, x25, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_004_0018 region=R_rf_rd_wb_hz_004 template=rf_wb_hazard_rs1
  lw   x26, 72(x10)
  addi x6, x26, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_004_0019 region=R_rf_rd_wb_hz_004 template=rf_wb_hazard_rs1
  lw   x27, 76(x10)
  addi x7, x27, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_004_0020 region=R_rf_rd_wb_hz_004 template=rf_wb_hazard_rs1
  lw   x28, 80(x10)
  addi x8, x28, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_003_0000 region=R_rf_rd_wb_hz_003 template=rf_wb_hazard_rs1
  lw   x5, 0(x10)
  addi x15, x5, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_003_0001 region=R_rf_rd_wb_hz_003 template=rf_wb_hazard_rs1
  lw   x6, 4(x10)
  addi x16, x6, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_003_0002 region=R_rf_rd_wb_hz_003 template=rf_wb_hazard_rs1
  lw   x7, 8(x10)
  addi x17, x7, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_003_0003 region=R_rf_rd_wb_hz_003 template=rf_wb_hazard_rs1
  lw   x8, 12(x10)
  addi x18, x8, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_003_0004 region=R_rf_rd_wb_hz_003 template=rf_wb_hazard_rs1
  lw   x9, 16(x10)
  addi x19, x9, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_003_0005 region=R_rf_rd_wb_hz_003 template=rf_wb_hazard_rs1
  lw   x13, 20(x10)
  addi x20, x13, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_003_0006 region=R_rf_rd_wb_hz_003 template=rf_wb_hazard_rs1
  lw   x14, 24(x10)
  addi x21, x14, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_003_0007 region=R_rf_rd_wb_hz_003 template=rf_wb_hazard_rs1
  lw   x15, 28(x10)
  addi x22, x15, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_003_0008 region=R_rf_rd_wb_hz_003 template=rf_wb_hazard_rs1
  lw   x16, 32(x10)
  addi x23, x16, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_003_0009 region=R_rf_rd_wb_hz_003 template=rf_wb_hazard_rs1
  lw   x17, 36(x10)
  addi x24, x17, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_003_0010 region=R_rf_rd_wb_hz_003 template=rf_wb_hazard_rs1
  lw   x18, 40(x10)
  addi x25, x18, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_003_0011 region=R_rf_rd_wb_hz_003 template=rf_wb_hazard_rs1
  lw   x19, 44(x10)
  addi x26, x19, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_003_0012 region=R_rf_rd_wb_hz_003 template=rf_wb_hazard_rs1
  lw   x20, 48(x10)
  addi x27, x20, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_003_0013 region=R_rf_rd_wb_hz_003 template=rf_wb_hazard_rs1
  lw   x21, 52(x10)
  addi x28, x21, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_003_0014 region=R_rf_rd_wb_hz_003 template=rf_wb_hazard_rs1
  lw   x22, 56(x10)
  addi x29, x22, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_003_0015 region=R_rf_rd_wb_hz_003 template=rf_wb_hazard_rs1
  lw   x23, 60(x10)
  addi x30, x23, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_003_0016 region=R_rf_rd_wb_hz_003 template=rf_wb_hazard_rs1
  lw   x24, 64(x10)
  addi x31, x24, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_003_0017 region=R_rf_rd_wb_hz_003 template=rf_wb_hazard_rs1
  lw   x25, 68(x10)
  addi x5, x25, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_003_0018 region=R_rf_rd_wb_hz_003 template=rf_wb_hazard_rs1
  lw   x26, 72(x10)
  addi x6, x26, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_003_0019 region=R_rf_rd_wb_hz_003 template=rf_wb_hazard_rs1
  lw   x27, 76(x10)
  addi x7, x27, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_003_0020 region=R_rf_rd_wb_hz_003 template=rf_wb_hazard_rs1
  lw   x28, 80(x10)
  addi x8, x28, 1

  # BSDCOV_SEQ seq_R_stall_branch_001_0000 region=R_stall_branch_001 template=branch_taken
  addi x5, x0, 1
  addi x15, x0, 1
  beq  x5, x15, seq_R_stall_branch_001_0000_taken
  addi x15, x15, 3
  seq_R_stall_branch_001_0000_taken:
  addi x15, x15, 1

  # BSDCOV_SEQ seq_R_stall_branch_001_0001 region=R_stall_branch_001 template=branch_taken
  addi x6, x0, 1
  addi x16, x0, 1
  beq  x6, x16, seq_R_stall_branch_001_0001_taken
  addi x16, x16, 3
  seq_R_stall_branch_001_0001_taken:
  addi x16, x16, 1

  # BSDCOV_SEQ seq_R_stall_branch_001_0002 region=R_stall_branch_001 template=branch_taken
  addi x7, x0, 1
  addi x17, x0, 1
  beq  x7, x17, seq_R_stall_branch_001_0002_taken
  addi x17, x17, 3
  seq_R_stall_branch_001_0002_taken:
  addi x17, x17, 1

  # BSDCOV_SEQ seq_R_stall_branch_001_0003 region=R_stall_branch_001 template=branch_taken
  addi x8, x0, 1
  addi x18, x0, 1
  beq  x8, x18, seq_R_stall_branch_001_0003_taken
  addi x18, x18, 3
  seq_R_stall_branch_001_0003_taken:
  addi x18, x18, 1

  # BSDCOV_SEQ seq_R_stall_branch_001_0004 region=R_stall_branch_001 template=branch_taken
  addi x9, x0, 1
  addi x19, x0, 1
  beq  x9, x19, seq_R_stall_branch_001_0004_taken
  addi x19, x19, 3
  seq_R_stall_branch_001_0004_taken:
  addi x19, x19, 1

  # BSDCOV_SEQ seq_R_stall_branch_001_0005 region=R_stall_branch_001 template=branch_taken
  addi x13, x0, 1
  addi x20, x0, 1
  beq  x13, x20, seq_R_stall_branch_001_0005_taken
  addi x20, x20, 3
  seq_R_stall_branch_001_0005_taken:
  addi x20, x20, 1

  # BSDCOV_SEQ seq_R_stall_branch_001_0006 region=R_stall_branch_001 template=branch_taken
  addi x14, x0, 1
  addi x21, x0, 1
  beq  x14, x21, seq_R_stall_branch_001_0006_taken
  addi x21, x21, 3
  seq_R_stall_branch_001_0006_taken:
  addi x21, x21, 1

  # BSDCOV_SEQ seq_R_stall_branch_001_0007 region=R_stall_branch_001 template=branch_taken
  addi x15, x0, 1
  addi x22, x0, 1
  beq  x15, x22, seq_R_stall_branch_001_0007_taken
  addi x22, x22, 3
  seq_R_stall_branch_001_0007_taken:
  addi x22, x22, 1

  # BSDCOV_SEQ seq_R_stall_branch_001_0008 region=R_stall_branch_001 template=branch_taken
  addi x16, x0, 1
  addi x23, x0, 1
  beq  x16, x23, seq_R_stall_branch_001_0008_taken
  addi x23, x23, 3
  seq_R_stall_branch_001_0008_taken:
  addi x23, x23, 1

  # BSDCOV_SEQ seq_R_stall_branch_001_0009 region=R_stall_branch_001 template=branch_taken
  addi x17, x0, 1
  addi x24, x0, 1
  beq  x17, x24, seq_R_stall_branch_001_0009_taken
  addi x24, x24, 3
  seq_R_stall_branch_001_0009_taken:
  addi x24, x24, 1

  # BSDCOV_SEQ seq_R_stall_branch_001_0010 region=R_stall_branch_001 template=branch_taken
  addi x18, x0, 1
  addi x25, x0, 1
  beq  x18, x25, seq_R_stall_branch_001_0010_taken
  addi x25, x25, 3
  seq_R_stall_branch_001_0010_taken:
  addi x25, x25, 1

  # BSDCOV_SEQ seq_R_stall_branch_001_0011 region=R_stall_branch_001 template=branch_taken
  addi x19, x0, 1
  addi x26, x0, 1
  beq  x19, x26, seq_R_stall_branch_001_0011_taken
  addi x26, x26, 3
  seq_R_stall_branch_001_0011_taken:
  addi x26, x26, 1

  # BSDCOV_SEQ seq_R_stall_branch_001_0012 region=R_stall_branch_001 template=branch_taken
  addi x20, x0, 1
  addi x27, x0, 1
  beq  x20, x27, seq_R_stall_branch_001_0012_taken
  addi x27, x27, 3
  seq_R_stall_branch_001_0012_taken:
  addi x27, x27, 1

  # BSDCOV_SEQ seq_R_stall_branch_001_0013 region=R_stall_branch_001 template=branch_taken
  addi x21, x0, 1
  addi x28, x0, 1
  beq  x21, x28, seq_R_stall_branch_001_0013_taken
  addi x28, x28, 3
  seq_R_stall_branch_001_0013_taken:
  addi x28, x28, 1

  # BSDCOV_SEQ seq_R_stall_branch_001_0014 region=R_stall_branch_001 template=branch_taken
  addi x22, x0, 1
  addi x29, x0, 1
  beq  x22, x29, seq_R_stall_branch_001_0014_taken
  addi x29, x29, 3
  seq_R_stall_branch_001_0014_taken:
  addi x29, x29, 1

  # BSDCOV_SEQ seq_R_stall_branch_001_0015 region=R_stall_branch_001 template=branch_taken
  addi x23, x0, 1
  addi x30, x0, 1
  beq  x23, x30, seq_R_stall_branch_001_0015_taken
  addi x30, x30, 3
  seq_R_stall_branch_001_0015_taken:
  addi x30, x30, 1

  # BSDCOV_SEQ seq_R_stall_branch_001_0016 region=R_stall_branch_001 template=branch_taken
  addi x24, x0, 1
  addi x31, x0, 1
  beq  x24, x31, seq_R_stall_branch_001_0016_taken
  addi x31, x31, 3
  seq_R_stall_branch_001_0016_taken:
  addi x31, x31, 1

  # BSDCOV_SEQ seq_R_stall_branch_001_0017 region=R_stall_branch_001 template=branch_taken
  addi x25, x0, 1
  addi x5, x0, 1
  beq  x25, x5, seq_R_stall_branch_001_0017_taken
  addi x5, x5, 3
  seq_R_stall_branch_001_0017_taken:
  addi x5, x5, 1

  # BSDCOV_SEQ seq_R_stall_branch_001_0018 region=R_stall_branch_001 template=branch_taken
  addi x26, x0, 1
  addi x6, x0, 1
  beq  x26, x6, seq_R_stall_branch_001_0018_taken
  addi x6, x6, 3
  seq_R_stall_branch_001_0018_taken:
  addi x6, x6, 1

  # BSDCOV_SEQ seq_R_stall_branch_001_0019 region=R_stall_branch_001 template=branch_taken
  addi x27, x0, 1
  addi x7, x0, 1
  beq  x27, x7, seq_R_stall_branch_001_0019_taken
  addi x7, x7, 3
  seq_R_stall_branch_001_0019_taken:
  addi x7, x7, 1

  # BSDCOV_SEQ seq_R_stall_branch_001_0020 region=R_stall_branch_001 template=branch_taken
  addi x28, x0, 1
  addi x8, x0, 1
  beq  x28, x8, seq_R_stall_branch_001_0020_taken
  addi x8, x8, 3
  seq_R_stall_branch_001_0020_taken:
  addi x8, x8, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_006_0000 region=R_rf_rd_wb_hz_006 template=rf_wb_hazard_rs1
  lw   x5, 0(x10)
  addi x15, x5, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_006_0001 region=R_rf_rd_wb_hz_006 template=rf_wb_hazard_rs1
  lw   x6, 4(x10)
  addi x16, x6, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_006_0002 region=R_rf_rd_wb_hz_006 template=rf_wb_hazard_rs1
  lw   x7, 8(x10)
  addi x17, x7, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_006_0003 region=R_rf_rd_wb_hz_006 template=rf_wb_hazard_rs1
  lw   x8, 12(x10)
  addi x18, x8, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_006_0004 region=R_rf_rd_wb_hz_006 template=rf_wb_hazard_rs1
  lw   x9, 16(x10)
  addi x19, x9, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_006_0005 region=R_rf_rd_wb_hz_006 template=rf_wb_hazard_rs1
  lw   x13, 20(x10)
  addi x20, x13, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_006_0006 region=R_rf_rd_wb_hz_006 template=rf_wb_hazard_rs1
  lw   x14, 24(x10)
  addi x21, x14, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_006_0007 region=R_rf_rd_wb_hz_006 template=rf_wb_hazard_rs1
  lw   x15, 28(x10)
  addi x22, x15, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_006_0008 region=R_rf_rd_wb_hz_006 template=rf_wb_hazard_rs1
  lw   x16, 32(x10)
  addi x23, x16, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_006_0009 region=R_rf_rd_wb_hz_006 template=rf_wb_hazard_rs1
  lw   x17, 36(x10)
  addi x24, x17, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_006_0010 region=R_rf_rd_wb_hz_006 template=rf_wb_hazard_rs1
  lw   x18, 40(x10)
  addi x25, x18, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_006_0011 region=R_rf_rd_wb_hz_006 template=rf_wb_hazard_rs1
  lw   x19, 44(x10)
  addi x26, x19, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_006_0012 region=R_rf_rd_wb_hz_006 template=rf_wb_hazard_rs1
  lw   x20, 48(x10)
  addi x27, x20, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_006_0013 region=R_rf_rd_wb_hz_006 template=rf_wb_hazard_rs1
  lw   x21, 52(x10)
  addi x28, x21, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_006_0014 region=R_rf_rd_wb_hz_006 template=rf_wb_hazard_rs1
  lw   x22, 56(x10)
  addi x29, x22, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_006_0015 region=R_rf_rd_wb_hz_006 template=rf_wb_hazard_rs1
  lw   x23, 60(x10)
  addi x30, x23, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_006_0016 region=R_rf_rd_wb_hz_006 template=rf_wb_hazard_rs1
  lw   x24, 64(x10)
  addi x31, x24, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_006_0017 region=R_rf_rd_wb_hz_006 template=rf_wb_hazard_rs1
  lw   x25, 68(x10)
  addi x5, x25, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_006_0018 region=R_rf_rd_wb_hz_006 template=rf_wb_hazard_rs1
  lw   x26, 72(x10)
  addi x6, x26, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_006_0019 region=R_rf_rd_wb_hz_006 template=rf_wb_hazard_rs1
  lw   x27, 76(x10)
  addi x7, x27, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_006_0020 region=R_rf_rd_wb_hz_006 template=rf_wb_hazard_rs1
  lw   x28, 80(x10)
  addi x8, x28, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_011_0000 region=R_rf_rd_wb_hz_011 template=rf_wb_hazard_rs1
  lw   x5, 0(x10)
  addi x15, x5, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_011_0001 region=R_rf_rd_wb_hz_011 template=rf_wb_hazard_rs1
  lw   x6, 4(x10)
  addi x16, x6, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_011_0002 region=R_rf_rd_wb_hz_011 template=rf_wb_hazard_rs1
  lw   x7, 8(x10)
  addi x17, x7, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_011_0003 region=R_rf_rd_wb_hz_011 template=rf_wb_hazard_rs1
  lw   x8, 12(x10)
  addi x18, x8, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_011_0004 region=R_rf_rd_wb_hz_011 template=rf_wb_hazard_rs1
  lw   x9, 16(x10)
  addi x19, x9, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_011_0005 region=R_rf_rd_wb_hz_011 template=rf_wb_hazard_rs1
  lw   x13, 20(x10)
  addi x20, x13, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_011_0006 region=R_rf_rd_wb_hz_011 template=rf_wb_hazard_rs1
  lw   x14, 24(x10)
  addi x21, x14, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_011_0007 region=R_rf_rd_wb_hz_011 template=rf_wb_hazard_rs1
  lw   x15, 28(x10)
  addi x22, x15, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_011_0008 region=R_rf_rd_wb_hz_011 template=rf_wb_hazard_rs1
  lw   x16, 32(x10)
  addi x23, x16, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_011_0009 region=R_rf_rd_wb_hz_011 template=rf_wb_hazard_rs1
  lw   x17, 36(x10)
  addi x24, x17, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_011_0010 region=R_rf_rd_wb_hz_011 template=rf_wb_hazard_rs1
  lw   x18, 40(x10)
  addi x25, x18, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_011_0011 region=R_rf_rd_wb_hz_011 template=rf_wb_hazard_rs1
  lw   x19, 44(x10)
  addi x26, x19, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_011_0012 region=R_rf_rd_wb_hz_011 template=rf_wb_hazard_rs1
  lw   x20, 48(x10)
  addi x27, x20, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_011_0013 region=R_rf_rd_wb_hz_011 template=rf_wb_hazard_rs1
  lw   x21, 52(x10)
  addi x28, x21, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_011_0014 region=R_rf_rd_wb_hz_011 template=rf_wb_hazard_rs1
  lw   x22, 56(x10)
  addi x29, x22, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_011_0015 region=R_rf_rd_wb_hz_011 template=rf_wb_hazard_rs1
  lw   x23, 60(x10)
  addi x30, x23, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_011_0016 region=R_rf_rd_wb_hz_011 template=rf_wb_hazard_rs1
  lw   x24, 64(x10)
  addi x31, x24, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_011_0017 region=R_rf_rd_wb_hz_011 template=rf_wb_hazard_rs1
  lw   x25, 68(x10)
  addi x5, x25, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_011_0018 region=R_rf_rd_wb_hz_011 template=rf_wb_hazard_rs1
  lw   x26, 72(x10)
  addi x6, x26, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_011_0019 region=R_rf_rd_wb_hz_011 template=rf_wb_hazard_rs1
  lw   x27, 76(x10)
  addi x7, x27, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_011_0020 region=R_rf_rd_wb_hz_011 template=rf_wb_hazard_rs1
  lw   x28, 80(x10)
  addi x8, x28, 1

  # BSDCOV_SEQ seq_R_stall_multdiv_002_0000 region=R_stall_multdiv_002 template=div_active
  addi x12, x0, 7
  div  x5, x11, x12
  rem  x15, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_002_0001 region=R_stall_multdiv_002 template=div_active
  addi x12, x0, 7
  div  x6, x11, x12
  rem  x16, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_002_0002 region=R_stall_multdiv_002 template=div_active
  addi x12, x0, 7
  div  x7, x11, x12
  rem  x17, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_002_0003 region=R_stall_multdiv_002 template=div_active
  addi x12, x0, 7
  div  x8, x11, x12
  rem  x18, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_002_0004 region=R_stall_multdiv_002 template=div_active
  addi x12, x0, 7
  div  x9, x11, x12
  rem  x19, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_002_0005 region=R_stall_multdiv_002 template=div_active
  addi x12, x0, 7
  div  x13, x11, x12
  rem  x20, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_002_0006 region=R_stall_multdiv_002 template=div_active
  addi x12, x0, 7
  div  x14, x11, x12
  rem  x21, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_002_0007 region=R_stall_multdiv_002 template=div_active
  addi x12, x0, 7
  div  x15, x11, x12
  rem  x22, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_002_0008 region=R_stall_multdiv_002 template=div_active
  addi x12, x0, 7
  div  x16, x11, x12
  rem  x23, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_002_0009 region=R_stall_multdiv_002 template=div_active
  addi x12, x0, 7
  div  x17, x11, x12
  rem  x24, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_002_0010 region=R_stall_multdiv_002 template=div_active
  addi x12, x0, 7
  div  x18, x11, x12
  rem  x25, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_002_0011 region=R_stall_multdiv_002 template=div_active
  addi x12, x0, 7
  div  x19, x11, x12
  rem  x26, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_002_0012 region=R_stall_multdiv_002 template=div_active
  addi x12, x0, 7
  div  x20, x11, x12
  rem  x27, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_002_0013 region=R_stall_multdiv_002 template=div_active
  addi x12, x0, 7
  div  x21, x11, x12
  rem  x28, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_002_0014 region=R_stall_multdiv_002 template=div_active
  addi x12, x0, 7
  div  x22, x11, x12
  rem  x29, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_002_0015 region=R_stall_multdiv_002 template=div_active
  addi x12, x0, 7
  div  x23, x11, x12
  rem  x30, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_002_0016 region=R_stall_multdiv_002 template=div_active
  addi x12, x0, 7
  div  x24, x11, x12
  rem  x31, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_002_0017 region=R_stall_multdiv_002 template=div_active
  addi x12, x0, 7
  div  x25, x11, x12
  rem  x5, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_002_0018 region=R_stall_multdiv_002 template=div_active
  addi x12, x0, 7
  div  x26, x11, x12
  rem  x6, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_002_0019 region=R_stall_multdiv_002 template=div_active
  addi x12, x0, 7
  div  x27, x11, x12
  rem  x7, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_002_0020 region=R_stall_multdiv_002 template=div_active
  addi x12, x0, 7
  div  x28, x11, x12
  rem  x8, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_003_0000 region=R_stall_multdiv_003 template=mul_active
  mul  x5, x11, x12
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_003_0001 region=R_stall_multdiv_003 template=mul_active
  mul  x6, x11, x12
  add  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_003_0002 region=R_stall_multdiv_003 template=mul_active
  mul  x7, x11, x12
  add  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_003_0003 region=R_stall_multdiv_003 template=mul_active
  mul  x8, x11, x12
  add  x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_003_0004 region=R_stall_multdiv_003 template=mul_active
  mul  x9, x11, x12
  add  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_003_0005 region=R_stall_multdiv_003 template=mul_active
  mul  x13, x11, x12
  add  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_003_0006 region=R_stall_multdiv_003 template=mul_active
  mul  x14, x11, x12
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_003_0007 region=R_stall_multdiv_003 template=mul_active
  mul  x15, x11, x12
  add  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_003_0008 region=R_stall_multdiv_003 template=mul_active
  mul  x16, x11, x12
  add  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_003_0009 region=R_stall_multdiv_003 template=mul_active
  mul  x17, x11, x12
  add  x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_003_0010 region=R_stall_multdiv_003 template=mul_active
  mul  x18, x11, x12
  add  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_003_0011 region=R_stall_multdiv_003 template=mul_active
  mul  x19, x11, x12
  add  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_003_0012 region=R_stall_multdiv_003 template=mul_active
  mul  x20, x11, x12
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_003_0013 region=R_stall_multdiv_003 template=mul_active
  mul  x21, x11, x12
  add  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_003_0014 region=R_stall_multdiv_003 template=mul_active
  mul  x22, x11, x12
  add  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_003_0015 region=R_stall_multdiv_003 template=mul_active
  mul  x23, x11, x12
  add  x30, x23, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_003_0016 region=R_stall_multdiv_003 template=mul_active
  mul  x24, x11, x12
  add  x31, x24, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_003_0017 region=R_stall_multdiv_003 template=mul_active
  mul  x25, x11, x12
  add  x5, x25, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_003_0018 region=R_stall_multdiv_003 template=mul_active
  mul  x26, x11, x12
  add  x6, x26, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_003_0019 region=R_stall_multdiv_003 template=mul_active
  mul  x27, x11, x12
  add  x7, x27, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_003_0020 region=R_stall_multdiv_003 template=mul_active
  mul  x28, x11, x12
  add  x8, x28, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_000_0000 region=R_stall_multdiv_000 template=jump_after_load
  lw   x5, 0(x10)
  andi x5, x5, 0
  la   x21, seq_R_stall_multdiv_000_0000_target
  add  x5, x5, x21
  jalr x1, 0(x5)
  addi x15, x11, 1
  seq_R_stall_multdiv_000_0000_target:
  addi x15, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_000_0001 region=R_stall_multdiv_000 template=jump_after_load
  lw   x6, 4(x10)
  andi x6, x6, 0
  la   x22, seq_R_stall_multdiv_000_0001_target
  add  x6, x6, x22
  jalr x1, 0(x6)
  addi x16, x11, 1
  seq_R_stall_multdiv_000_0001_target:
  addi x16, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_000_0002 region=R_stall_multdiv_000 template=jump_after_load
  lw   x7, 8(x10)
  andi x7, x7, 0
  la   x23, seq_R_stall_multdiv_000_0002_target
  add  x7, x7, x23
  jalr x1, 0(x7)
  addi x17, x11, 1
  seq_R_stall_multdiv_000_0002_target:
  addi x17, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_000_0003 region=R_stall_multdiv_000 template=jump_after_load
  lw   x8, 12(x10)
  andi x8, x8, 0
  la   x24, seq_R_stall_multdiv_000_0003_target
  add  x8, x8, x24
  jalr x1, 0(x8)
  addi x18, x11, 1
  seq_R_stall_multdiv_000_0003_target:
  addi x18, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_000_0004 region=R_stall_multdiv_000 template=jump_after_load
  lw   x9, 16(x10)
  andi x9, x9, 0
  la   x25, seq_R_stall_multdiv_000_0004_target
  add  x9, x9, x25
  jalr x1, 0(x9)
  addi x19, x11, 1
  seq_R_stall_multdiv_000_0004_target:
  addi x19, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_000_0005 region=R_stall_multdiv_000 template=jump_after_load
  lw   x13, 20(x10)
  andi x13, x13, 0
  la   x26, seq_R_stall_multdiv_000_0005_target
  add  x13, x13, x26
  jalr x1, 0(x13)
  addi x20, x11, 1
  seq_R_stall_multdiv_000_0005_target:
  addi x20, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_000_0006 region=R_stall_multdiv_000 template=jump_after_load
  lw   x14, 24(x10)
  andi x14, x14, 0
  la   x27, seq_R_stall_multdiv_000_0006_target
  add  x14, x14, x27
  jalr x1, 0(x14)
  addi x21, x11, 1
  seq_R_stall_multdiv_000_0006_target:
  addi x21, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_000_0007 region=R_stall_multdiv_000 template=jump_after_load
  lw   x15, 28(x10)
  andi x15, x15, 0
  la   x28, seq_R_stall_multdiv_000_0007_target
  add  x15, x15, x28
  jalr x1, 0(x15)
  addi x22, x11, 1
  seq_R_stall_multdiv_000_0007_target:
  addi x22, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_000_0008 region=R_stall_multdiv_000 template=jump_after_load
  lw   x16, 32(x10)
  andi x16, x16, 0
  la   x29, seq_R_stall_multdiv_000_0008_target
  add  x16, x16, x29
  jalr x1, 0(x16)
  addi x23, x11, 1
  seq_R_stall_multdiv_000_0008_target:
  addi x23, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_000_0009 region=R_stall_multdiv_000 template=jump_after_load
  lw   x17, 36(x10)
  andi x17, x17, 0
  la   x30, seq_R_stall_multdiv_000_0009_target
  add  x17, x17, x30
  jalr x1, 0(x17)
  addi x24, x11, 1
  seq_R_stall_multdiv_000_0009_target:
  addi x24, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_000_0010 region=R_stall_multdiv_000 template=jump_after_load
  lw   x18, 40(x10)
  andi x18, x18, 0
  la   x31, seq_R_stall_multdiv_000_0010_target
  add  x18, x18, x31
  jalr x1, 0(x18)
  addi x25, x11, 1
  seq_R_stall_multdiv_000_0010_target:
  addi x25, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_000_0011 region=R_stall_multdiv_000 template=jump_after_load
  lw   x19, 44(x10)
  andi x19, x19, 0
  la   x5, seq_R_stall_multdiv_000_0011_target
  add  x19, x19, x5
  jalr x1, 0(x19)
  addi x26, x11, 1
  seq_R_stall_multdiv_000_0011_target:
  addi x26, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_000_0012 region=R_stall_multdiv_000 template=jump_after_load
  lw   x20, 48(x10)
  andi x20, x20, 0
  la   x6, seq_R_stall_multdiv_000_0012_target
  add  x20, x20, x6
  jalr x1, 0(x20)
  addi x27, x11, 1
  seq_R_stall_multdiv_000_0012_target:
  addi x27, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_000_0013 region=R_stall_multdiv_000 template=jump_after_load
  lw   x21, 52(x10)
  andi x21, x21, 0
  la   x7, seq_R_stall_multdiv_000_0013_target
  add  x21, x21, x7
  jalr x1, 0(x21)
  addi x28, x11, 1
  seq_R_stall_multdiv_000_0013_target:
  addi x28, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_000_0014 region=R_stall_multdiv_000 template=jump_after_load
  lw   x22, 56(x10)
  andi x22, x22, 0
  la   x8, seq_R_stall_multdiv_000_0014_target
  add  x22, x22, x8
  jalr x1, 0(x22)
  addi x29, x11, 1
  seq_R_stall_multdiv_000_0014_target:
  addi x29, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_000_0015 region=R_stall_multdiv_000 template=jump_after_load
  lw   x23, 60(x10)
  andi x23, x23, 0
  la   x9, seq_R_stall_multdiv_000_0015_target
  add  x23, x23, x9
  jalr x1, 0(x23)
  addi x30, x11, 1
  seq_R_stall_multdiv_000_0015_target:
  addi x30, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_000_0016 region=R_stall_multdiv_000 template=jump_after_load
  lw   x24, 64(x10)
  andi x24, x24, 0
  la   x13, seq_R_stall_multdiv_000_0016_target
  add  x24, x24, x13
  jalr x1, 0(x24)
  addi x31, x11, 1
  seq_R_stall_multdiv_000_0016_target:
  addi x31, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_000_0017 region=R_stall_multdiv_000 template=jump_after_load
  lw   x25, 68(x10)
  andi x25, x25, 0
  la   x14, seq_R_stall_multdiv_000_0017_target
  add  x25, x25, x14
  jalr x1, 0(x25)
  addi x5, x11, 1
  seq_R_stall_multdiv_000_0017_target:
  addi x5, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_000_0018 region=R_stall_multdiv_000 template=jump_after_load
  lw   x26, 72(x10)
  andi x26, x26, 0
  la   x15, seq_R_stall_multdiv_000_0018_target
  add  x26, x26, x15
  jalr x1, 0(x26)
  addi x6, x11, 1
  seq_R_stall_multdiv_000_0018_target:
  addi x6, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_000_0019 region=R_stall_multdiv_000 template=jump_after_load
  lw   x27, 76(x10)
  andi x27, x27, 0
  la   x16, seq_R_stall_multdiv_000_0019_target
  add  x27, x27, x16
  jalr x1, 0(x27)
  addi x7, x11, 1
  seq_R_stall_multdiv_000_0019_target:
  addi x7, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_000_0020 region=R_stall_multdiv_000 template=jump_after_load
  lw   x28, 80(x10)
  andi x28, x28, 0
  la   x17, seq_R_stall_multdiv_000_0020_target
  add  x28, x28, x17
  jalr x1, 0(x28)
  addi x8, x11, 1
  seq_R_stall_multdiv_000_0020_target:
  addi x8, x11, 2

  # BSDCOV_SEQ seq_R_stall_branch_000_0000 region=R_stall_branch_000 template=branch_taken
  addi x5, x0, 1
  addi x15, x0, 1
  beq  x5, x15, seq_R_stall_branch_000_0000_taken
  addi x15, x15, 3
  seq_R_stall_branch_000_0000_taken:
  addi x15, x15, 1

  # BSDCOV_SEQ seq_R_stall_branch_000_0001 region=R_stall_branch_000 template=branch_taken
  addi x6, x0, 1
  addi x16, x0, 1
  beq  x6, x16, seq_R_stall_branch_000_0001_taken
  addi x16, x16, 3
  seq_R_stall_branch_000_0001_taken:
  addi x16, x16, 1

  # BSDCOV_SEQ seq_R_stall_branch_000_0002 region=R_stall_branch_000 template=branch_taken
  addi x7, x0, 1
  addi x17, x0, 1
  beq  x7, x17, seq_R_stall_branch_000_0002_taken
  addi x17, x17, 3
  seq_R_stall_branch_000_0002_taken:
  addi x17, x17, 1

  # BSDCOV_SEQ seq_R_stall_branch_000_0003 region=R_stall_branch_000 template=branch_taken
  addi x8, x0, 1
  addi x18, x0, 1
  beq  x8, x18, seq_R_stall_branch_000_0003_taken
  addi x18, x18, 3
  seq_R_stall_branch_000_0003_taken:
  addi x18, x18, 1

  # BSDCOV_SEQ seq_R_stall_branch_000_0004 region=R_stall_branch_000 template=branch_taken
  addi x9, x0, 1
  addi x19, x0, 1
  beq  x9, x19, seq_R_stall_branch_000_0004_taken
  addi x19, x19, 3
  seq_R_stall_branch_000_0004_taken:
  addi x19, x19, 1

  # BSDCOV_SEQ seq_R_stall_branch_000_0005 region=R_stall_branch_000 template=branch_taken
  addi x13, x0, 1
  addi x20, x0, 1
  beq  x13, x20, seq_R_stall_branch_000_0005_taken
  addi x20, x20, 3
  seq_R_stall_branch_000_0005_taken:
  addi x20, x20, 1

  # BSDCOV_SEQ seq_R_stall_branch_000_0006 region=R_stall_branch_000 template=branch_taken
  addi x14, x0, 1
  addi x21, x0, 1
  beq  x14, x21, seq_R_stall_branch_000_0006_taken
  addi x21, x21, 3
  seq_R_stall_branch_000_0006_taken:
  addi x21, x21, 1

  # BSDCOV_SEQ seq_R_stall_branch_000_0007 region=R_stall_branch_000 template=branch_taken
  addi x15, x0, 1
  addi x22, x0, 1
  beq  x15, x22, seq_R_stall_branch_000_0007_taken
  addi x22, x22, 3
  seq_R_stall_branch_000_0007_taken:
  addi x22, x22, 1

  # BSDCOV_SEQ seq_R_stall_branch_000_0008 region=R_stall_branch_000 template=branch_taken
  addi x16, x0, 1
  addi x23, x0, 1
  beq  x16, x23, seq_R_stall_branch_000_0008_taken
  addi x23, x23, 3
  seq_R_stall_branch_000_0008_taken:
  addi x23, x23, 1

  # BSDCOV_SEQ seq_R_stall_branch_000_0009 region=R_stall_branch_000 template=branch_taken
  addi x17, x0, 1
  addi x24, x0, 1
  beq  x17, x24, seq_R_stall_branch_000_0009_taken
  addi x24, x24, 3
  seq_R_stall_branch_000_0009_taken:
  addi x24, x24, 1

  # BSDCOV_SEQ seq_R_stall_branch_000_0010 region=R_stall_branch_000 template=branch_taken
  addi x18, x0, 1
  addi x25, x0, 1
  beq  x18, x25, seq_R_stall_branch_000_0010_taken
  addi x25, x25, 3
  seq_R_stall_branch_000_0010_taken:
  addi x25, x25, 1

  # BSDCOV_SEQ seq_R_stall_branch_000_0011 region=R_stall_branch_000 template=branch_taken
  addi x19, x0, 1
  addi x26, x0, 1
  beq  x19, x26, seq_R_stall_branch_000_0011_taken
  addi x26, x26, 3
  seq_R_stall_branch_000_0011_taken:
  addi x26, x26, 1

  # BSDCOV_SEQ seq_R_stall_branch_000_0012 region=R_stall_branch_000 template=branch_taken
  addi x20, x0, 1
  addi x27, x0, 1
  beq  x20, x27, seq_R_stall_branch_000_0012_taken
  addi x27, x27, 3
  seq_R_stall_branch_000_0012_taken:
  addi x27, x27, 1

  # BSDCOV_SEQ seq_R_stall_branch_000_0013 region=R_stall_branch_000 template=branch_taken
  addi x21, x0, 1
  addi x28, x0, 1
  beq  x21, x28, seq_R_stall_branch_000_0013_taken
  addi x28, x28, 3
  seq_R_stall_branch_000_0013_taken:
  addi x28, x28, 1

  # BSDCOV_SEQ seq_R_stall_branch_000_0014 region=R_stall_branch_000 template=branch_taken
  addi x22, x0, 1
  addi x29, x0, 1
  beq  x22, x29, seq_R_stall_branch_000_0014_taken
  addi x29, x29, 3
  seq_R_stall_branch_000_0014_taken:
  addi x29, x29, 1

  # BSDCOV_SEQ seq_R_stall_branch_000_0015 region=R_stall_branch_000 template=branch_taken
  addi x23, x0, 1
  addi x30, x0, 1
  beq  x23, x30, seq_R_stall_branch_000_0015_taken
  addi x30, x30, 3
  seq_R_stall_branch_000_0015_taken:
  addi x30, x30, 1

  # BSDCOV_SEQ seq_R_stall_branch_000_0016 region=R_stall_branch_000 template=branch_taken
  addi x24, x0, 1
  addi x31, x0, 1
  beq  x24, x31, seq_R_stall_branch_000_0016_taken
  addi x31, x31, 3
  seq_R_stall_branch_000_0016_taken:
  addi x31, x31, 1

  # BSDCOV_SEQ seq_R_stall_branch_000_0017 region=R_stall_branch_000 template=branch_taken
  addi x25, x0, 1
  addi x5, x0, 1
  beq  x25, x5, seq_R_stall_branch_000_0017_taken
  addi x5, x5, 3
  seq_R_stall_branch_000_0017_taken:
  addi x5, x5, 1

  # BSDCOV_SEQ seq_R_stall_branch_000_0018 region=R_stall_branch_000 template=branch_taken
  addi x26, x0, 1
  addi x6, x0, 1
  beq  x26, x6, seq_R_stall_branch_000_0018_taken
  addi x6, x6, 3
  seq_R_stall_branch_000_0018_taken:
  addi x6, x6, 1

  # BSDCOV_SEQ seq_R_stall_branch_000_0019 region=R_stall_branch_000 template=branch_taken
  addi x27, x0, 1
  addi x7, x0, 1
  beq  x27, x7, seq_R_stall_branch_000_0019_taken
  addi x7, x7, 3
  seq_R_stall_branch_000_0019_taken:
  addi x7, x7, 1

  # BSDCOV_SEQ seq_R_stall_branch_000_0020 region=R_stall_branch_000 template=branch_taken
  addi x28, x0, 1
  addi x8, x0, 1
  beq  x28, x8, seq_R_stall_branch_000_0020_taken
  addi x8, x8, 3
  seq_R_stall_branch_000_0020_taken:
  addi x8, x8, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_009_0000 region=R_rf_rd_wb_hz_009 template=rf_wb_hazard_rs1
  lw   x5, 0(x10)
  addi x15, x5, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_009_0001 region=R_rf_rd_wb_hz_009 template=rf_wb_hazard_rs1
  lw   x6, 4(x10)
  addi x16, x6, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_009_0002 region=R_rf_rd_wb_hz_009 template=rf_wb_hazard_rs1
  lw   x7, 8(x10)
  addi x17, x7, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_009_0003 region=R_rf_rd_wb_hz_009 template=rf_wb_hazard_rs1
  lw   x8, 12(x10)
  addi x18, x8, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_009_0004 region=R_rf_rd_wb_hz_009 template=rf_wb_hazard_rs1
  lw   x9, 16(x10)
  addi x19, x9, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_009_0005 region=R_rf_rd_wb_hz_009 template=rf_wb_hazard_rs1
  lw   x13, 20(x10)
  addi x20, x13, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_009_0006 region=R_rf_rd_wb_hz_009 template=rf_wb_hazard_rs1
  lw   x14, 24(x10)
  addi x21, x14, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_009_0007 region=R_rf_rd_wb_hz_009 template=rf_wb_hazard_rs1
  lw   x15, 28(x10)
  addi x22, x15, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_009_0008 region=R_rf_rd_wb_hz_009 template=rf_wb_hazard_rs1
  lw   x16, 32(x10)
  addi x23, x16, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_009_0009 region=R_rf_rd_wb_hz_009 template=rf_wb_hazard_rs1
  lw   x17, 36(x10)
  addi x24, x17, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_009_0010 region=R_rf_rd_wb_hz_009 template=rf_wb_hazard_rs1
  lw   x18, 40(x10)
  addi x25, x18, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_009_0011 region=R_rf_rd_wb_hz_009 template=rf_wb_hazard_rs1
  lw   x19, 44(x10)
  addi x26, x19, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_009_0012 region=R_rf_rd_wb_hz_009 template=rf_wb_hazard_rs1
  lw   x20, 48(x10)
  addi x27, x20, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_009_0013 region=R_rf_rd_wb_hz_009 template=rf_wb_hazard_rs1
  lw   x21, 52(x10)
  addi x28, x21, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_009_0014 region=R_rf_rd_wb_hz_009 template=rf_wb_hazard_rs1
  lw   x22, 56(x10)
  addi x29, x22, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_009_0015 region=R_rf_rd_wb_hz_009 template=rf_wb_hazard_rs1
  lw   x23, 60(x10)
  addi x30, x23, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_009_0016 region=R_rf_rd_wb_hz_009 template=rf_wb_hazard_rs1
  lw   x24, 64(x10)
  addi x31, x24, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_009_0017 region=R_rf_rd_wb_hz_009 template=rf_wb_hazard_rs1
  lw   x25, 68(x10)
  addi x5, x25, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_009_0018 region=R_rf_rd_wb_hz_009 template=rf_wb_hazard_rs1
  lw   x26, 72(x10)
  addi x6, x26, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_009_0019 region=R_rf_rd_wb_hz_009 template=rf_wb_hazard_rs1
  lw   x27, 76(x10)
  addi x7, x27, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_009_0020 region=R_rf_rd_wb_hz_009 template=rf_wb_hazard_rs1
  lw   x28, 80(x10)
  addi x8, x28, 1

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_010_0000 region=R_rf_rd_wb_hz_010 template=rf_wb_hazard_rs2
  lw   x5, 0(x10)
  add  x15, x11, x5

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_010_0001 region=R_rf_rd_wb_hz_010 template=rf_wb_hazard_rs2
  lw   x6, 4(x10)
  add  x16, x11, x6

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_010_0002 region=R_rf_rd_wb_hz_010 template=rf_wb_hazard_rs2
  lw   x7, 8(x10)
  add  x17, x11, x7

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_010_0003 region=R_rf_rd_wb_hz_010 template=rf_wb_hazard_rs2
  lw   x8, 12(x10)
  add  x18, x11, x8

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_010_0004 region=R_rf_rd_wb_hz_010 template=rf_wb_hazard_rs2
  lw   x9, 16(x10)
  add  x19, x11, x9

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_010_0005 region=R_rf_rd_wb_hz_010 template=rf_wb_hazard_rs2
  lw   x13, 20(x10)
  add  x20, x11, x13

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_010_0006 region=R_rf_rd_wb_hz_010 template=rf_wb_hazard_rs2
  lw   x14, 24(x10)
  add  x21, x11, x14

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_010_0007 region=R_rf_rd_wb_hz_010 template=rf_wb_hazard_rs2
  lw   x15, 28(x10)
  add  x22, x11, x15

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_010_0008 region=R_rf_rd_wb_hz_010 template=rf_wb_hazard_rs2
  lw   x16, 32(x10)
  add  x23, x11, x16

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_010_0009 region=R_rf_rd_wb_hz_010 template=rf_wb_hazard_rs2
  lw   x17, 36(x10)
  add  x24, x11, x17

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_010_0010 region=R_rf_rd_wb_hz_010 template=rf_wb_hazard_rs2
  lw   x18, 40(x10)
  add  x25, x11, x18

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_010_0011 region=R_rf_rd_wb_hz_010 template=rf_wb_hazard_rs2
  lw   x19, 44(x10)
  add  x26, x11, x19

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_010_0012 region=R_rf_rd_wb_hz_010 template=rf_wb_hazard_rs2
  lw   x20, 48(x10)
  add  x27, x11, x20

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_010_0013 region=R_rf_rd_wb_hz_010 template=rf_wb_hazard_rs2
  lw   x21, 52(x10)
  add  x28, x11, x21

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_010_0014 region=R_rf_rd_wb_hz_010 template=rf_wb_hazard_rs2
  lw   x22, 56(x10)
  add  x29, x11, x22

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_010_0015 region=R_rf_rd_wb_hz_010 template=rf_wb_hazard_rs2
  lw   x23, 60(x10)
  add  x30, x11, x23

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_010_0016 region=R_rf_rd_wb_hz_010 template=rf_wb_hazard_rs2
  lw   x24, 64(x10)
  add  x31, x11, x24

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_010_0017 region=R_rf_rd_wb_hz_010 template=rf_wb_hazard_rs2
  lw   x25, 68(x10)
  add  x5, x11, x25

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_010_0018 region=R_rf_rd_wb_hz_010 template=rf_wb_hazard_rs2
  lw   x26, 72(x10)
  add  x6, x11, x26

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_010_0019 region=R_rf_rd_wb_hz_010 template=rf_wb_hazard_rs2
  lw   x27, 76(x10)
  add  x7, x11, x27

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_010_0020 region=R_rf_rd_wb_hz_010 template=rf_wb_hazard_rs2
  lw   x28, 80(x10)
  add  x8, x11, x28

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_008_0000 region=R_rf_rd_wb_hz_008 template=rf_wb_hazard_rs2
  lw   x5, 0(x10)
  add  x15, x11, x5

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_008_0001 region=R_rf_rd_wb_hz_008 template=rf_wb_hazard_rs2
  lw   x6, 4(x10)
  add  x16, x11, x6

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_008_0002 region=R_rf_rd_wb_hz_008 template=rf_wb_hazard_rs2
  lw   x7, 8(x10)
  add  x17, x11, x7

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_008_0003 region=R_rf_rd_wb_hz_008 template=rf_wb_hazard_rs2
  lw   x8, 12(x10)
  add  x18, x11, x8

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_008_0004 region=R_rf_rd_wb_hz_008 template=rf_wb_hazard_rs2
  lw   x9, 16(x10)
  add  x19, x11, x9

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_008_0005 region=R_rf_rd_wb_hz_008 template=rf_wb_hazard_rs2
  lw   x13, 20(x10)
  add  x20, x11, x13

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_008_0006 region=R_rf_rd_wb_hz_008 template=rf_wb_hazard_rs2
  lw   x14, 24(x10)
  add  x21, x11, x14

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_008_0007 region=R_rf_rd_wb_hz_008 template=rf_wb_hazard_rs2
  lw   x15, 28(x10)
  add  x22, x11, x15

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_008_0008 region=R_rf_rd_wb_hz_008 template=rf_wb_hazard_rs2
  lw   x16, 32(x10)
  add  x23, x11, x16

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_008_0009 region=R_rf_rd_wb_hz_008 template=rf_wb_hazard_rs2
  lw   x17, 36(x10)
  add  x24, x11, x17

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_008_0010 region=R_rf_rd_wb_hz_008 template=rf_wb_hazard_rs2
  lw   x18, 40(x10)
  add  x25, x11, x18

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_008_0011 region=R_rf_rd_wb_hz_008 template=rf_wb_hazard_rs2
  lw   x19, 44(x10)
  add  x26, x11, x19

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_008_0012 region=R_rf_rd_wb_hz_008 template=rf_wb_hazard_rs2
  lw   x20, 48(x10)
  add  x27, x11, x20

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_008_0013 region=R_rf_rd_wb_hz_008 template=rf_wb_hazard_rs2
  lw   x21, 52(x10)
  add  x28, x11, x21

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_008_0014 region=R_rf_rd_wb_hz_008 template=rf_wb_hazard_rs2
  lw   x22, 56(x10)
  add  x29, x11, x22

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_008_0015 region=R_rf_rd_wb_hz_008 template=rf_wb_hazard_rs2
  lw   x23, 60(x10)
  add  x30, x11, x23

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_008_0016 region=R_rf_rd_wb_hz_008 template=rf_wb_hazard_rs2
  lw   x24, 64(x10)
  add  x31, x11, x24

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_008_0017 region=R_rf_rd_wb_hz_008 template=rf_wb_hazard_rs2
  lw   x25, 68(x10)
  add  x5, x11, x25

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_008_0018 region=R_rf_rd_wb_hz_008 template=rf_wb_hazard_rs2
  lw   x26, 72(x10)
  add  x6, x11, x26

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_008_0019 region=R_rf_rd_wb_hz_008 template=rf_wb_hazard_rs2
  lw   x27, 76(x10)
  add  x7, x11, x27

  # BSDCOV_SEQ seq_R_rf_rd_wb_hz_008_0020 region=R_rf_rd_wb_hz_008 template=rf_wb_hazard_rs2
  lw   x28, 80(x10)
  add  x8, x11, x28

  # BSDCOV_SEQ seq_R_stall_multdiv_006_0000 region=R_stall_multdiv_006 template=div_active
  addi x12, x0, 7
  div  x5, x11, x12
  rem  x15, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_006_0001 region=R_stall_multdiv_006 template=div_active
  addi x12, x0, 7
  div  x6, x11, x12
  rem  x16, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_006_0002 region=R_stall_multdiv_006 template=div_active
  addi x12, x0, 7
  div  x7, x11, x12
  rem  x17, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_006_0003 region=R_stall_multdiv_006 template=div_active
  addi x12, x0, 7
  div  x8, x11, x12
  rem  x18, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_006_0004 region=R_stall_multdiv_006 template=div_active
  addi x12, x0, 7
  div  x9, x11, x12
  rem  x19, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_006_0005 region=R_stall_multdiv_006 template=div_active
  addi x12, x0, 7
  div  x13, x11, x12
  rem  x20, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_006_0006 region=R_stall_multdiv_006 template=div_active
  addi x12, x0, 7
  div  x14, x11, x12
  rem  x21, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_006_0007 region=R_stall_multdiv_006 template=div_active
  addi x12, x0, 7
  div  x15, x11, x12
  rem  x22, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_006_0008 region=R_stall_multdiv_006 template=div_active
  addi x12, x0, 7
  div  x16, x11, x12
  rem  x23, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_006_0009 region=R_stall_multdiv_006 template=div_active
  addi x12, x0, 7
  div  x17, x11, x12
  rem  x24, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_006_0010 region=R_stall_multdiv_006 template=div_active
  addi x12, x0, 7
  div  x18, x11, x12
  rem  x25, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_006_0011 region=R_stall_multdiv_006 template=div_active
  addi x12, x0, 7
  div  x19, x11, x12
  rem  x26, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_006_0012 region=R_stall_multdiv_006 template=div_active
  addi x12, x0, 7
  div  x20, x11, x12
  rem  x27, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_006_0013 region=R_stall_multdiv_006 template=div_active
  addi x12, x0, 7
  div  x21, x11, x12
  rem  x28, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_006_0014 region=R_stall_multdiv_006 template=div_active
  addi x12, x0, 7
  div  x22, x11, x12
  rem  x29, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_006_0015 region=R_stall_multdiv_006 template=div_active
  addi x12, x0, 7
  div  x23, x11, x12
  rem  x30, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_006_0016 region=R_stall_multdiv_006 template=div_active
  addi x12, x0, 7
  div  x24, x11, x12
  rem  x31, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_006_0017 region=R_stall_multdiv_006 template=div_active
  addi x12, x0, 7
  div  x25, x11, x12
  rem  x5, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_006_0018 region=R_stall_multdiv_006 template=div_active
  addi x12, x0, 7
  div  x26, x11, x12
  rem  x6, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_006_0019 region=R_stall_multdiv_006 template=div_active
  addi x12, x0, 7
  div  x27, x11, x12
  rem  x7, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_006_0020 region=R_stall_multdiv_006 template=div_active
  addi x12, x0, 7
  div  x28, x11, x12
  rem  x8, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_004_0000 region=R_stall_multdiv_004 template=mul_active
  mul  x5, x11, x12
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_004_0001 region=R_stall_multdiv_004 template=mul_active
  mul  x6, x11, x12
  add  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_004_0002 region=R_stall_multdiv_004 template=mul_active
  mul  x7, x11, x12
  add  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_004_0003 region=R_stall_multdiv_004 template=mul_active
  mul  x8, x11, x12
  add  x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_004_0004 region=R_stall_multdiv_004 template=mul_active
  mul  x9, x11, x12
  add  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_004_0005 region=R_stall_multdiv_004 template=mul_active
  mul  x13, x11, x12
  add  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_004_0006 region=R_stall_multdiv_004 template=mul_active
  mul  x14, x11, x12
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_004_0007 region=R_stall_multdiv_004 template=mul_active
  mul  x15, x11, x12
  add  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_004_0008 region=R_stall_multdiv_004 template=mul_active
  mul  x16, x11, x12
  add  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_004_0009 region=R_stall_multdiv_004 template=mul_active
  mul  x17, x11, x12
  add  x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_004_0010 region=R_stall_multdiv_004 template=mul_active
  mul  x18, x11, x12
  add  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_004_0011 region=R_stall_multdiv_004 template=mul_active
  mul  x19, x11, x12
  add  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_004_0012 region=R_stall_multdiv_004 template=mul_active
  mul  x20, x11, x12
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_004_0013 region=R_stall_multdiv_004 template=mul_active
  mul  x21, x11, x12
  add  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_004_0014 region=R_stall_multdiv_004 template=mul_active
  mul  x22, x11, x12
  add  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_004_0015 region=R_stall_multdiv_004 template=mul_active
  mul  x23, x11, x12
  add  x30, x23, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_004_0016 region=R_stall_multdiv_004 template=mul_active
  mul  x24, x11, x12
  add  x31, x24, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_004_0017 region=R_stall_multdiv_004 template=mul_active
  mul  x25, x11, x12
  add  x5, x25, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_004_0018 region=R_stall_multdiv_004 template=mul_active
  mul  x26, x11, x12
  add  x6, x26, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_004_0019 region=R_stall_multdiv_004 template=mul_active
  mul  x27, x11, x12
  add  x7, x27, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_004_0020 region=R_stall_multdiv_004 template=mul_active
  mul  x28, x11, x12
  add  x8, x28, x11

  # BSDCOV_SEQ seq_R_stall_multdiv_007_0000 region=R_stall_multdiv_007 template=jump_after_load
  lw   x5, 0(x10)
  andi x5, x5, 0
  la   x21, seq_R_stall_multdiv_007_0000_target
  add  x5, x5, x21
  jalr x1, 0(x5)
  addi x15, x11, 1
  seq_R_stall_multdiv_007_0000_target:
  addi x15, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_007_0001 region=R_stall_multdiv_007 template=jump_after_load
  lw   x6, 4(x10)
  andi x6, x6, 0
  la   x22, seq_R_stall_multdiv_007_0001_target
  add  x6, x6, x22
  jalr x1, 0(x6)
  addi x16, x11, 1
  seq_R_stall_multdiv_007_0001_target:
  addi x16, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_007_0002 region=R_stall_multdiv_007 template=jump_after_load
  lw   x7, 8(x10)
  andi x7, x7, 0
  la   x23, seq_R_stall_multdiv_007_0002_target
  add  x7, x7, x23
  jalr x1, 0(x7)
  addi x17, x11, 1
  seq_R_stall_multdiv_007_0002_target:
  addi x17, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_007_0003 region=R_stall_multdiv_007 template=jump_after_load
  lw   x8, 12(x10)
  andi x8, x8, 0
  la   x24, seq_R_stall_multdiv_007_0003_target
  add  x8, x8, x24
  jalr x1, 0(x8)
  addi x18, x11, 1
  seq_R_stall_multdiv_007_0003_target:
  addi x18, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_007_0004 region=R_stall_multdiv_007 template=jump_after_load
  lw   x9, 16(x10)
  andi x9, x9, 0
  la   x25, seq_R_stall_multdiv_007_0004_target
  add  x9, x9, x25
  jalr x1, 0(x9)
  addi x19, x11, 1
  seq_R_stall_multdiv_007_0004_target:
  addi x19, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_007_0005 region=R_stall_multdiv_007 template=jump_after_load
  lw   x13, 20(x10)
  andi x13, x13, 0
  la   x26, seq_R_stall_multdiv_007_0005_target
  add  x13, x13, x26
  jalr x1, 0(x13)
  addi x20, x11, 1
  seq_R_stall_multdiv_007_0005_target:
  addi x20, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_007_0006 region=R_stall_multdiv_007 template=jump_after_load
  lw   x14, 24(x10)
  andi x14, x14, 0
  la   x27, seq_R_stall_multdiv_007_0006_target
  add  x14, x14, x27
  jalr x1, 0(x14)
  addi x21, x11, 1
  seq_R_stall_multdiv_007_0006_target:
  addi x21, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_007_0007 region=R_stall_multdiv_007 template=jump_after_load
  lw   x15, 28(x10)
  andi x15, x15, 0
  la   x28, seq_R_stall_multdiv_007_0007_target
  add  x15, x15, x28
  jalr x1, 0(x15)
  addi x22, x11, 1
  seq_R_stall_multdiv_007_0007_target:
  addi x22, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_007_0008 region=R_stall_multdiv_007 template=jump_after_load
  lw   x16, 32(x10)
  andi x16, x16, 0
  la   x29, seq_R_stall_multdiv_007_0008_target
  add  x16, x16, x29
  jalr x1, 0(x16)
  addi x23, x11, 1
  seq_R_stall_multdiv_007_0008_target:
  addi x23, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_007_0009 region=R_stall_multdiv_007 template=jump_after_load
  lw   x17, 36(x10)
  andi x17, x17, 0
  la   x30, seq_R_stall_multdiv_007_0009_target
  add  x17, x17, x30
  jalr x1, 0(x17)
  addi x24, x11, 1
  seq_R_stall_multdiv_007_0009_target:
  addi x24, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_007_0010 region=R_stall_multdiv_007 template=jump_after_load
  lw   x18, 40(x10)
  andi x18, x18, 0
  la   x31, seq_R_stall_multdiv_007_0010_target
  add  x18, x18, x31
  jalr x1, 0(x18)
  addi x25, x11, 1
  seq_R_stall_multdiv_007_0010_target:
  addi x25, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_007_0011 region=R_stall_multdiv_007 template=jump_after_load
  lw   x19, 44(x10)
  andi x19, x19, 0
  la   x5, seq_R_stall_multdiv_007_0011_target
  add  x19, x19, x5
  jalr x1, 0(x19)
  addi x26, x11, 1
  seq_R_stall_multdiv_007_0011_target:
  addi x26, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_007_0012 region=R_stall_multdiv_007 template=jump_after_load
  lw   x20, 48(x10)
  andi x20, x20, 0
  la   x6, seq_R_stall_multdiv_007_0012_target
  add  x20, x20, x6
  jalr x1, 0(x20)
  addi x27, x11, 1
  seq_R_stall_multdiv_007_0012_target:
  addi x27, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_007_0013 region=R_stall_multdiv_007 template=jump_after_load
  lw   x21, 52(x10)
  andi x21, x21, 0
  la   x7, seq_R_stall_multdiv_007_0013_target
  add  x21, x21, x7
  jalr x1, 0(x21)
  addi x28, x11, 1
  seq_R_stall_multdiv_007_0013_target:
  addi x28, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_007_0014 region=R_stall_multdiv_007 template=jump_after_load
  lw   x22, 56(x10)
  andi x22, x22, 0
  la   x8, seq_R_stall_multdiv_007_0014_target
  add  x22, x22, x8
  jalr x1, 0(x22)
  addi x29, x11, 1
  seq_R_stall_multdiv_007_0014_target:
  addi x29, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_007_0015 region=R_stall_multdiv_007 template=jump_after_load
  lw   x23, 60(x10)
  andi x23, x23, 0
  la   x9, seq_R_stall_multdiv_007_0015_target
  add  x23, x23, x9
  jalr x1, 0(x23)
  addi x30, x11, 1
  seq_R_stall_multdiv_007_0015_target:
  addi x30, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_007_0016 region=R_stall_multdiv_007 template=jump_after_load
  lw   x24, 64(x10)
  andi x24, x24, 0
  la   x13, seq_R_stall_multdiv_007_0016_target
  add  x24, x24, x13
  jalr x1, 0(x24)
  addi x31, x11, 1
  seq_R_stall_multdiv_007_0016_target:
  addi x31, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_007_0017 region=R_stall_multdiv_007 template=jump_after_load
  lw   x25, 68(x10)
  andi x25, x25, 0
  la   x14, seq_R_stall_multdiv_007_0017_target
  add  x25, x25, x14
  jalr x1, 0(x25)
  addi x5, x11, 1
  seq_R_stall_multdiv_007_0017_target:
  addi x5, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_007_0018 region=R_stall_multdiv_007 template=jump_after_load
  lw   x26, 72(x10)
  andi x26, x26, 0
  la   x15, seq_R_stall_multdiv_007_0018_target
  add  x26, x26, x15
  jalr x1, 0(x26)
  addi x6, x11, 1
  seq_R_stall_multdiv_007_0018_target:
  addi x6, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_007_0019 region=R_stall_multdiv_007 template=jump_after_load
  lw   x27, 76(x10)
  andi x27, x27, 0
  la   x16, seq_R_stall_multdiv_007_0019_target
  add  x27, x27, x16
  jalr x1, 0(x27)
  addi x7, x11, 1
  seq_R_stall_multdiv_007_0019_target:
  addi x7, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_007_0020 region=R_stall_multdiv_007 template=jump_after_load
  lw   x28, 80(x10)
  andi x28, x28, 0
  la   x17, seq_R_stall_multdiv_007_0020_target
  add  x28, x28, x17
  jalr x1, 0(x28)
  addi x8, x11, 1
  seq_R_stall_multdiv_007_0020_target:
  addi x8, x11, 2

  # BSDCOV_SEQ seq_R_stall_branch_002_0000 region=R_stall_branch_002 template=jump_after_load
  lw   x5, 0(x10)
  andi x5, x5, 0
  la   x21, seq_R_stall_branch_002_0000_target
  add  x5, x5, x21
  jalr x1, 0(x5)
  addi x15, x11, 1
  seq_R_stall_branch_002_0000_target:
  addi x15, x11, 2

  # BSDCOV_SEQ seq_R_stall_branch_002_0001 region=R_stall_branch_002 template=jump_after_load
  lw   x6, 4(x10)
  andi x6, x6, 0
  la   x22, seq_R_stall_branch_002_0001_target
  add  x6, x6, x22
  jalr x1, 0(x6)
  addi x16, x11, 1
  seq_R_stall_branch_002_0001_target:
  addi x16, x11, 2

  # BSDCOV_SEQ seq_R_stall_branch_002_0002 region=R_stall_branch_002 template=jump_after_load
  lw   x7, 8(x10)
  andi x7, x7, 0
  la   x23, seq_R_stall_branch_002_0002_target
  add  x7, x7, x23
  jalr x1, 0(x7)
  addi x17, x11, 1
  seq_R_stall_branch_002_0002_target:
  addi x17, x11, 2

  # BSDCOV_SEQ seq_R_stall_branch_002_0003 region=R_stall_branch_002 template=jump_after_load
  lw   x8, 12(x10)
  andi x8, x8, 0
  la   x24, seq_R_stall_branch_002_0003_target
  add  x8, x8, x24
  jalr x1, 0(x8)
  addi x18, x11, 1
  seq_R_stall_branch_002_0003_target:
  addi x18, x11, 2

  # BSDCOV_SEQ seq_R_stall_branch_002_0004 region=R_stall_branch_002 template=jump_after_load
  lw   x9, 16(x10)
  andi x9, x9, 0
  la   x25, seq_R_stall_branch_002_0004_target
  add  x9, x9, x25
  jalr x1, 0(x9)
  addi x19, x11, 1
  seq_R_stall_branch_002_0004_target:
  addi x19, x11, 2

  # BSDCOV_SEQ seq_R_stall_branch_002_0005 region=R_stall_branch_002 template=jump_after_load
  lw   x13, 20(x10)
  andi x13, x13, 0
  la   x26, seq_R_stall_branch_002_0005_target
  add  x13, x13, x26
  jalr x1, 0(x13)
  addi x20, x11, 1
  seq_R_stall_branch_002_0005_target:
  addi x20, x11, 2

  # BSDCOV_SEQ seq_R_stall_branch_002_0006 region=R_stall_branch_002 template=jump_after_load
  lw   x14, 24(x10)
  andi x14, x14, 0
  la   x27, seq_R_stall_branch_002_0006_target
  add  x14, x14, x27
  jalr x1, 0(x14)
  addi x21, x11, 1
  seq_R_stall_branch_002_0006_target:
  addi x21, x11, 2

  # BSDCOV_SEQ seq_R_stall_branch_002_0007 region=R_stall_branch_002 template=jump_after_load
  lw   x15, 28(x10)
  andi x15, x15, 0
  la   x28, seq_R_stall_branch_002_0007_target
  add  x15, x15, x28
  jalr x1, 0(x15)
  addi x22, x11, 1
  seq_R_stall_branch_002_0007_target:
  addi x22, x11, 2

  # BSDCOV_SEQ seq_R_stall_branch_002_0008 region=R_stall_branch_002 template=jump_after_load
  lw   x16, 32(x10)
  andi x16, x16, 0
  la   x29, seq_R_stall_branch_002_0008_target
  add  x16, x16, x29
  jalr x1, 0(x16)
  addi x23, x11, 1
  seq_R_stall_branch_002_0008_target:
  addi x23, x11, 2

  # BSDCOV_SEQ seq_R_stall_branch_002_0009 region=R_stall_branch_002 template=jump_after_load
  lw   x17, 36(x10)
  andi x17, x17, 0
  la   x30, seq_R_stall_branch_002_0009_target
  add  x17, x17, x30
  jalr x1, 0(x17)
  addi x24, x11, 1
  seq_R_stall_branch_002_0009_target:
  addi x24, x11, 2

  # BSDCOV_SEQ seq_R_stall_branch_002_0010 region=R_stall_branch_002 template=jump_after_load
  lw   x18, 40(x10)
  andi x18, x18, 0
  la   x31, seq_R_stall_branch_002_0010_target
  add  x18, x18, x31
  jalr x1, 0(x18)
  addi x25, x11, 1
  seq_R_stall_branch_002_0010_target:
  addi x25, x11, 2

  # BSDCOV_SEQ seq_R_stall_branch_002_0011 region=R_stall_branch_002 template=jump_after_load
  lw   x19, 44(x10)
  andi x19, x19, 0
  la   x5, seq_R_stall_branch_002_0011_target
  add  x19, x19, x5
  jalr x1, 0(x19)
  addi x26, x11, 1
  seq_R_stall_branch_002_0011_target:
  addi x26, x11, 2

  # BSDCOV_SEQ seq_R_stall_branch_002_0012 region=R_stall_branch_002 template=jump_after_load
  lw   x20, 48(x10)
  andi x20, x20, 0
  la   x6, seq_R_stall_branch_002_0012_target
  add  x20, x20, x6
  jalr x1, 0(x20)
  addi x27, x11, 1
  seq_R_stall_branch_002_0012_target:
  addi x27, x11, 2

  # BSDCOV_SEQ seq_R_stall_branch_002_0013 region=R_stall_branch_002 template=jump_after_load
  lw   x21, 52(x10)
  andi x21, x21, 0
  la   x7, seq_R_stall_branch_002_0013_target
  add  x21, x21, x7
  jalr x1, 0(x21)
  addi x28, x11, 1
  seq_R_stall_branch_002_0013_target:
  addi x28, x11, 2

  # BSDCOV_SEQ seq_R_stall_branch_002_0014 region=R_stall_branch_002 template=jump_after_load
  lw   x22, 56(x10)
  andi x22, x22, 0
  la   x8, seq_R_stall_branch_002_0014_target
  add  x22, x22, x8
  jalr x1, 0(x22)
  addi x29, x11, 1
  seq_R_stall_branch_002_0014_target:
  addi x29, x11, 2

  # BSDCOV_SEQ seq_R_stall_branch_002_0015 region=R_stall_branch_002 template=jump_after_load
  lw   x23, 60(x10)
  andi x23, x23, 0
  la   x9, seq_R_stall_branch_002_0015_target
  add  x23, x23, x9
  jalr x1, 0(x23)
  addi x30, x11, 1
  seq_R_stall_branch_002_0015_target:
  addi x30, x11, 2

  # BSDCOV_SEQ seq_R_stall_branch_002_0016 region=R_stall_branch_002 template=jump_after_load
  lw   x24, 64(x10)
  andi x24, x24, 0
  la   x13, seq_R_stall_branch_002_0016_target
  add  x24, x24, x13
  jalr x1, 0(x24)
  addi x31, x11, 1
  seq_R_stall_branch_002_0016_target:
  addi x31, x11, 2

  # BSDCOV_SEQ seq_R_stall_branch_002_0017 region=R_stall_branch_002 template=jump_after_load
  lw   x25, 68(x10)
  andi x25, x25, 0
  la   x14, seq_R_stall_branch_002_0017_target
  add  x25, x25, x14
  jalr x1, 0(x25)
  addi x5, x11, 1
  seq_R_stall_branch_002_0017_target:
  addi x5, x11, 2

  # BSDCOV_SEQ seq_R_stall_branch_002_0018 region=R_stall_branch_002 template=jump_after_load
  lw   x26, 72(x10)
  andi x26, x26, 0
  la   x15, seq_R_stall_branch_002_0018_target
  add  x26, x26, x15
  jalr x1, 0(x26)
  addi x6, x11, 1
  seq_R_stall_branch_002_0018_target:
  addi x6, x11, 2

  # BSDCOV_SEQ seq_R_stall_branch_002_0019 region=R_stall_branch_002 template=jump_after_load
  lw   x27, 76(x10)
  andi x27, x27, 0
  la   x16, seq_R_stall_branch_002_0019_target
  add  x27, x27, x16
  jalr x1, 0(x27)
  addi x7, x11, 1
  seq_R_stall_branch_002_0019_target:
  addi x7, x11, 2

  # BSDCOV_SEQ seq_R_stall_branch_002_0020 region=R_stall_branch_002 template=jump_after_load
  lw   x28, 80(x10)
  andi x28, x28, 0
  la   x17, seq_R_stall_branch_002_0020_target
  add  x28, x28, x17
  jalr x1, 0(x28)
  addi x8, x11, 1
  seq_R_stall_branch_002_0020_target:
  addi x8, x11, 2

  # BSDCOV_SEQ seq_R_stall_multdiv_009_0000 region=R_stall_multdiv_009 template=div_active
  addi x12, x0, 7
  div  x5, x11, x12
  rem  x15, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_009_0001 region=R_stall_multdiv_009 template=div_active
  addi x12, x0, 7
  div  x6, x11, x12
  rem  x16, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_009_0002 region=R_stall_multdiv_009 template=div_active
  addi x12, x0, 7
  div  x7, x11, x12
  rem  x17, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_009_0003 region=R_stall_multdiv_009 template=div_active
  addi x12, x0, 7
  div  x8, x11, x12
  rem  x18, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_009_0004 region=R_stall_multdiv_009 template=div_active
  addi x12, x0, 7
  div  x9, x11, x12
  rem  x19, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_009_0005 region=R_stall_multdiv_009 template=div_active
  addi x12, x0, 7
  div  x13, x11, x12
  rem  x20, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_009_0006 region=R_stall_multdiv_009 template=div_active
  addi x12, x0, 7
  div  x14, x11, x12
  rem  x21, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_009_0007 region=R_stall_multdiv_009 template=div_active
  addi x12, x0, 7
  div  x15, x11, x12
  rem  x22, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_009_0008 region=R_stall_multdiv_009 template=div_active
  addi x12, x0, 7
  div  x16, x11, x12
  rem  x23, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_009_0009 region=R_stall_multdiv_009 template=div_active
  addi x12, x0, 7
  div  x17, x11, x12
  rem  x24, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_009_0010 region=R_stall_multdiv_009 template=div_active
  addi x12, x0, 7
  div  x18, x11, x12
  rem  x25, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_009_0011 region=R_stall_multdiv_009 template=div_active
  addi x12, x0, 7
  div  x19, x11, x12
  rem  x26, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_009_0012 region=R_stall_multdiv_009 template=div_active
  addi x12, x0, 7
  div  x20, x11, x12
  rem  x27, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_009_0013 region=R_stall_multdiv_009 template=div_active
  addi x12, x0, 7
  div  x21, x11, x12
  rem  x28, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_009_0014 region=R_stall_multdiv_009 template=div_active
  addi x12, x0, 7
  div  x22, x11, x12
  rem  x29, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_009_0015 region=R_stall_multdiv_009 template=div_active
  addi x12, x0, 7
  div  x23, x11, x12
  rem  x30, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_009_0016 region=R_stall_multdiv_009 template=div_active
  addi x12, x0, 7
  div  x24, x11, x12
  rem  x31, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_009_0017 region=R_stall_multdiv_009 template=div_active
  addi x12, x0, 7
  div  x25, x11, x12
  rem  x5, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_009_0018 region=R_stall_multdiv_009 template=div_active
  addi x12, x0, 7
  div  x26, x11, x12
  rem  x6, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_009_0019 region=R_stall_multdiv_009 template=div_active
  addi x12, x0, 7
  div  x27, x11, x12
  rem  x7, x11, x12

  # BSDCOV_SEQ seq_R_stall_multdiv_009_0020 region=R_stall_multdiv_009 template=div_active
  addi x12, x0, 7
  div  x28, x11, x12
  rem  x8, x11, x12

  j pass

RVTEST_CODE_END

pass:
  RVTEST_PASS

fail:
  RVTEST_FAIL

  .data
RVTEST_DATA_BEGIN

  .balign 4
bsd_cov_data:
  .word 0x00000011
  .word 0x00000022
  .word 0x00000033
  .word 0x00000044
  .word 0x00000055
  .word 0x00000066
  .word 0x00000077
  .word 0x00000088
  .word 0x00000099
  .word 0x000000aa
  .word 0x000000bb
  .word 0x000000cc
  .word 0x000000dd
  .word 0x000000ee
  .word 0x000000ff
  .word 0x00000110
  .word 0x00000121
  .word 0x00000132
  .word 0x00000143
  .word 0x00000154
  .word 0x00000165
  .word 0x00000176
  .word 0x00000187
  .word 0x00000198
  .word 0x000001a9
  .word 0x000001ba
  .word 0x000001cb
  .word 0x000001dc
  .word 0x000001ed
  .word 0x000001fe
  .word 0x0000020f
  .word 0x00000220
  .word 0x00000231
  .word 0x00000242
  .word 0x00000253
  .word 0x00000264
  .word 0x00000275
  .word 0x00000286
  .word 0x00000297
  .word 0x000002a8
  .word 0x000002b9
  .word 0x000002ca
  .word 0x000002db
  .word 0x000002ec
  .word 0x000002fd
  .word 0x0000030e
  .word 0x0000031f
  .word 0x00000330
  .word 0x00000341
  .word 0x00000352
  .word 0x00000363
  .word 0x00000374
  .word 0x00000385
  .word 0x00000396
  .word 0x000003a7
  .word 0x000003b8
  .word 0x000003c9
  .word 0x000003da
  .word 0x000003eb
  .word 0x000003fc
  .word 0x0000040d
  .word 0x0000041e
  .word 0x0000042f
  .word 0x00000440
  .word 0x00000451
  .word 0x00000462
  .word 0x00000473
  .word 0x00000484
  .word 0x00000495
  .word 0x000004a6
  .word 0x000004b7
  .word 0x000004c8
  .word 0x000004d9
  .word 0x000004ea
  .word 0x000004fb
  .word 0x0000050c
  .word 0x0000051d
  .word 0x0000052e
  .word 0x0000053f
  .word 0x00000550
  .word 0x00000561
  .word 0x00000572
  .word 0x00000583
  .word 0x00000594
  .word 0x000005a5
  .word 0x000005b6
  .word 0x000005c7
  .word 0x000005d8
  .word 0x000005e9
  .word 0x000005fa
  .word 0x0000060b
  .word 0x0000061c
  .word 0x0000062d
  .word 0x0000063e
  .word 0x0000064f
  .word 0x00000660
  .word 0x00000671
  .word 0x00000682
  .word 0x00000693
  .word 0x000006a4
  .word 0x000006b5
  .word 0x000006c6
  .word 0x000006d7
  .word 0x000006e8
  .word 0x000006f9
  .word 0x0000070a
  .word 0x0000071b
  .word 0x0000072c
  .word 0x0000073d
  .word 0x0000074e
  .word 0x0000075f
  .word 0x00000770
  .word 0x00000781
  .word 0x00000792
  .word 0x000007a3
  .word 0x000007b4
  .word 0x000007c5
  .word 0x000007d6
  .word 0x000007e7
  .word 0x000007f8
  .word 0x00000809
  .word 0x0000081a
  .word 0x0000082b
  .word 0x0000083c
  .word 0x0000084d
  .word 0x0000085e
  .word 0x0000086f
  .word 0x00000880
  .word 0x00000891
  .word 0x000008a2
  .word 0x000008b3
  .word 0x000008c4
  .word 0x000008d5
  .word 0x000008e6
  .word 0x000008f7
  .word 0x00000908
  .word 0x00000919
  .word 0x0000092a
  .word 0x0000093b
  .word 0x0000094c
  .word 0x0000095d
  .word 0x0000096e
  .word 0x0000097f
  .word 0x00000990
  .word 0x000009a1
  .word 0x000009b2
  .word 0x000009c3
  .word 0x000009d4
  .word 0x000009e5
  .word 0x000009f6
  .word 0x00000a07
  .word 0x00000a18
  .word 0x00000a29
  .word 0x00000a3a
  .word 0x00000a4b
  .word 0x00000a5c
  .word 0x00000a6d
  .word 0x00000a7e
  .word 0x00000a8f
  .word 0x00000aa0
  .word 0x00000ab1
  .word 0x00000ac2
  .word 0x00000ad3
  .word 0x00000ae4
  .word 0x00000af5
  .word 0x00000b06
  .word 0x00000b17
  .word 0x00000b28
  .word 0x00000b39
  .word 0x00000b4a
  .word 0x00000b5b
  .word 0x00000b6c
  .word 0x00000b7d
  .word 0x00000b8e
  .word 0x00000b9f
  .word 0x00000bb0
  .word 0x00000bc1
  .word 0x00000bd2
  .word 0x00000be3
  .word 0x00000bf4
  .word 0x00000c05
  .word 0x00000c16
  .word 0x00000c27
  .word 0x00000c38
  .word 0x00000c49
  .word 0x00000c5a
  .word 0x00000c6b
  .word 0x00000c7c
  .word 0x00000c8d
  .word 0x00000c9e
  .word 0x00000caf
  .word 0x00000cc0
  .word 0x00000cd1
  .word 0x00000ce2
  .word 0x00000cf3
  .word 0x00000d04
  .word 0x00000d15
  .word 0x00000d26
  .word 0x00000d37
  .word 0x00000d48
  .word 0x00000d59
  .word 0x00000d6a
  .word 0x00000d7b
  .word 0x00000d8c
  .word 0x00000d9d
  .word 0x00000dae
  .word 0x00000dbf
  .word 0x00000dd0
  .word 0x00000de1
  .word 0x00000df2
  .word 0x00000e03
  .word 0x00000e14
  .word 0x00000e25
  .word 0x00000e36
  .word 0x00000e47
  .word 0x00000e58
  .word 0x00000e69
  .word 0x00000e7a
  .word 0x00000e8b
  .word 0x00000e9c
  .word 0x00000ead
  .word 0x00000ebe
  .word 0x00000ecf
  .word 0x00000ee0
  .word 0x00000ef1
  .word 0x00000f02
  .word 0x00000f13
  .word 0x00000f24
  .word 0x00000f35
  .word 0x00000f46
  .word 0x00000f57
  .word 0x00000f68
  .word 0x00000f79
  .word 0x00000f8a
  .word 0x00000f9b
  .word 0x00000fac
  .word 0x00000fbd
  .word 0x00000fce
  .word 0x00000fdf
  .word 0x00000ff0
  .word 0x00001001
  .word 0x00001012
  .word 0x00001023
  .word 0x00001034
  .word 0x00001045
  .word 0x00001056
  .word 0x00001067
  .word 0x00001078
  .word 0x00001089
  .word 0x0000109a
  .word 0x000010ab
  .word 0x000010bc
  .word 0x000010cd
  .word 0x000010de
  .word 0x000010ef
  .word 0x00001100

  TEST_DATA

RVTEST_DATA_END
