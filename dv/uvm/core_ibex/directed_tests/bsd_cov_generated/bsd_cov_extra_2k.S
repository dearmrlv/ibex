#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV64M
RVTEST_CODE_BEGIN

main:
  la   x10, bsd_cov_data
  li   x11, 0x11111111
  li   x12, 0x22222222

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0000 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x5, 0(x10)
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0001 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x6, 4(x10)
  sub  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0002 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x7, 8(x10)
  xor  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0003 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x8, 12(x10)
  or   x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0004 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x9, 16(x10)
  and  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0005 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x13, 20(x10)
  slt  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0006 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x14, 24(x10)
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0007 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x15, 28(x10)
  sub  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0008 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x16, 32(x10)
  xor  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0009 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x17, 36(x10)
  or   x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0010 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x18, 40(x10)
  and  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0011 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x19, 44(x10)
  slt  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0012 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x20, 48(x10)
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0013 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x21, 52(x10)
  sub  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0014 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x22, 56(x10)
  xor  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0015 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x23, 60(x10)
  or   x30, x23, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0016 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x24, 64(x10)
  and  x31, x24, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0017 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x25, 68(x10)
  slt  x5, x25, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0018 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x26, 72(x10)
  add  x6, x26, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0019 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x27, 76(x10)
  sub  x7, x27, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0020 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x28, 80(x10)
  xor  x8, x28, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0021 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x29, 84(x10)
  or   x9, x29, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0022 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x30, 88(x10)
  and  x13, x30, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0023 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x31, 92(x10)
  slt  x14, x31, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0024 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x5, 96(x10)
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0025 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x6, 100(x10)
  sub  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0026 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x7, 104(x10)
  xor  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0027 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x8, 108(x10)
  or   x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0028 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x9, 112(x10)
  and  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0029 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x13, 116(x10)
  slt  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0030 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x14, 120(x10)
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0031 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x15, 124(x10)
  sub  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0032 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x16, 128(x10)
  xor  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0033 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x17, 132(x10)
  or   x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0034 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x18, 136(x10)
  and  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0035 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x19, 140(x10)
  slt  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0036 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x20, 144(x10)
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0037 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x21, 148(x10)
  sub  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0038 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x22, 152(x10)
  xor  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0039 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x23, 156(x10)
  or   x30, x23, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0040 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x24, 160(x10)
  and  x31, x24, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0041 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x25, 164(x10)
  slt  x5, x25, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0042 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x26, 168(x10)
  add  x6, x26, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0043 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x27, 172(x10)
  sub  x7, x27, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0044 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x28, 176(x10)
  xor  x8, x28, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0045 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x29, 180(x10)
  or   x9, x29, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0046 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x30, 184(x10)
  and  x13, x30, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0047 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x31, 188(x10)
  slt  x14, x31, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0048 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x5, 192(x10)
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0049 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x6, 196(x10)
  sub  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0050 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x7, 200(x10)
  xor  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0051 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x8, 204(x10)
  or   x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0052 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x9, 208(x10)
  and  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0053 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x13, 212(x10)
  slt  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0054 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x14, 216(x10)
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0055 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x15, 220(x10)
  sub  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0056 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x16, 224(x10)
  xor  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0057 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x17, 228(x10)
  or   x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0058 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x18, 232(x10)
  and  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0059 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x19, 236(x10)
  slt  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0060 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x20, 240(x10)
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0061 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x21, 244(x10)
  sub  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0062 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x22, 248(x10)
  xor  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0063 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x23, 252(x10)
  or   x30, x23, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0064 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x24, 0(x10)
  and  x31, x24, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0065 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x25, 4(x10)
  slt  x5, x25, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0066 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x26, 8(x10)
  add  x6, x26, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0067 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x27, 12(x10)
  sub  x7, x27, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0068 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x28, 16(x10)
  xor  x8, x28, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0069 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x29, 20(x10)
  or   x9, x29, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0070 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x30, 24(x10)
  and  x13, x30, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0071 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x31, 28(x10)
  slt  x14, x31, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0072 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x5, 32(x10)
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0073 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x6, 36(x10)
  sub  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0074 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x7, 40(x10)
  xor  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0075 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x8, 44(x10)
  or   x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0076 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x9, 48(x10)
  and  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0077 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x13, 52(x10)
  slt  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0078 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x14, 56(x10)
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0079 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x15, 60(x10)
  sub  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0080 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x16, 64(x10)
  xor  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0081 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x17, 68(x10)
  or   x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0082 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x18, 72(x10)
  and  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0083 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x19, 76(x10)
  slt  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0084 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x20, 80(x10)
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0085 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x21, 84(x10)
  sub  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0086 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x22, 88(x10)
  xor  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0087 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x23, 92(x10)
  or   x30, x23, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0088 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x24, 96(x10)
  and  x31, x24, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0089 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x25, 100(x10)
  slt  x5, x25, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0090 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x26, 104(x10)
  add  x6, x26, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0091 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x27, 108(x10)
  sub  x7, x27, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0092 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x28, 112(x10)
  xor  x8, x28, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0093 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x29, 116(x10)
  or   x9, x29, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0094 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x30, 120(x10)
  and  x13, x30, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0095 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x31, 124(x10)
  slt  x14, x31, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0096 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x5, 128(x10)
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0097 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x6, 132(x10)
  sub  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0098 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x7, 136(x10)
  xor  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0099 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x8, 140(x10)
  or   x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0100 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x9, 144(x10)
  and  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0101 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x13, 148(x10)
  slt  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0102 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x14, 152(x10)
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0103 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x15, 156(x10)
  sub  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0104 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x16, 160(x10)
  xor  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0105 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x17, 164(x10)
  or   x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0106 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x18, 168(x10)
  and  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0107 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x19, 172(x10)
  slt  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0108 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x20, 176(x10)
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0109 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x21, 180(x10)
  sub  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0110 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x22, 184(x10)
  xor  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0111 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x23, 188(x10)
  or   x30, x23, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0112 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x24, 192(x10)
  and  x31, x24, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0113 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x25, 196(x10)
  slt  x5, x25, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0114 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x26, 200(x10)
  add  x6, x26, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0115 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x27, 204(x10)
  sub  x7, x27, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0116 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x28, 208(x10)
  xor  x8, x28, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0117 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x29, 212(x10)
  or   x9, x29, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0118 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x30, 216(x10)
  and  x13, x30, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0119 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x31, 220(x10)
  slt  x14, x31, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0120 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x5, 224(x10)
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0121 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x6, 228(x10)
  sub  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0122 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x7, 232(x10)
  xor  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0123 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x8, 236(x10)
  or   x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0124 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x9, 240(x10)
  and  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0125 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x13, 244(x10)
  slt  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0126 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x14, 248(x10)
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0127 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x15, 252(x10)
  sub  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0128 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x16, 0(x10)
  xor  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0129 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x17, 4(x10)
  or   x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0130 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x18, 8(x10)
  and  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0131 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x19, 12(x10)
  slt  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0132 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x20, 16(x10)
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0133 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x21, 20(x10)
  sub  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0134 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x22, 24(x10)
  xor  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0135 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x23, 28(x10)
  or   x30, x23, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0136 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x24, 32(x10)
  and  x31, x24, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0137 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x25, 36(x10)
  slt  x5, x25, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0138 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x26, 40(x10)
  add  x6, x26, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0139 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x27, 44(x10)
  sub  x7, x27, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0140 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x28, 48(x10)
  xor  x8, x28, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0141 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x29, 52(x10)
  or   x9, x29, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0142 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x30, 56(x10)
  and  x13, x30, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0143 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x31, 60(x10)
  slt  x14, x31, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0144 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x5, 64(x10)
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0145 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x6, 68(x10)
  sub  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0146 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x7, 72(x10)
  xor  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0147 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x8, 76(x10)
  or   x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0148 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x9, 80(x10)
  and  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0149 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x13, 84(x10)
  slt  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0150 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x14, 88(x10)
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0151 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x15, 92(x10)
  sub  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0152 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x16, 96(x10)
  xor  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0153 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x17, 100(x10)
  or   x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0154 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x18, 104(x10)
  and  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0155 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x19, 108(x10)
  slt  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0156 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x20, 112(x10)
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0157 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x21, 116(x10)
  sub  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0158 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x22, 120(x10)
  xor  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0159 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x23, 124(x10)
  or   x30, x23, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0160 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x24, 128(x10)
  and  x31, x24, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0161 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x25, 132(x10)
  slt  x5, x25, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0162 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x26, 136(x10)
  add  x6, x26, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0163 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x27, 140(x10)
  sub  x7, x27, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0164 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x28, 144(x10)
  xor  x8, x28, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0165 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x29, 148(x10)
  or   x9, x29, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0166 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x30, 152(x10)
  and  x13, x30, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0167 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x31, 156(x10)
  slt  x14, x31, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0168 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x5, 160(x10)
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0169 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x6, 164(x10)
  sub  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0170 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x7, 168(x10)
  xor  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0171 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x8, 172(x10)
  or   x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0172 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x9, 176(x10)
  and  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0173 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x13, 180(x10)
  slt  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0174 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x14, 184(x10)
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0175 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x15, 188(x10)
  sub  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0176 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x16, 192(x10)
  xor  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0177 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x17, 196(x10)
  or   x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0178 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x18, 200(x10)
  and  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0179 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x19, 204(x10)
  slt  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0180 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x20, 208(x10)
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0181 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x21, 212(x10)
  sub  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0182 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x22, 216(x10)
  xor  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0183 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x23, 220(x10)
  or   x30, x23, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0184 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x24, 224(x10)
  and  x31, x24, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0185 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x25, 228(x10)
  slt  x5, x25, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0186 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x26, 232(x10)
  add  x6, x26, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0187 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x27, 236(x10)
  sub  x7, x27, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0188 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x28, 240(x10)
  xor  x8, x28, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0189 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x29, 244(x10)
  or   x9, x29, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0190 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x30, 248(x10)
  and  x13, x30, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0191 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x31, 252(x10)
  slt  x14, x31, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0192 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x5, 0(x10)
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0193 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x6, 4(x10)
  sub  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0194 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x7, 8(x10)
  xor  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0195 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x8, 12(x10)
  or   x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0196 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x9, 16(x10)
  and  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0197 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x13, 20(x10)
  slt  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0198 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x14, 24(x10)
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0199 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x15, 28(x10)
  sub  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0200 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x16, 32(x10)
  xor  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0201 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x17, 36(x10)
  or   x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0202 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x18, 40(x10)
  and  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0203 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x19, 44(x10)
  slt  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0204 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x20, 48(x10)
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0205 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x21, 52(x10)
  sub  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0206 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x22, 56(x10)
  xor  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0207 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x23, 60(x10)
  or   x30, x23, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0208 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x24, 64(x10)
  and  x31, x24, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0209 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x25, 68(x10)
  slt  x5, x25, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0210 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x26, 72(x10)
  add  x6, x26, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0211 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x27, 76(x10)
  sub  x7, x27, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0212 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x28, 80(x10)
  xor  x8, x28, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0213 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x29, 84(x10)
  or   x9, x29, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0214 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x30, 88(x10)
  and  x13, x30, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0215 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x31, 92(x10)
  slt  x14, x31, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0216 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x5, 96(x10)
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0217 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x6, 100(x10)
  sub  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0218 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x7, 104(x10)
  xor  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0219 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x8, 108(x10)
  or   x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0220 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x9, 112(x10)
  and  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0221 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x13, 116(x10)
  slt  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0222 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x14, 120(x10)
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0223 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x15, 124(x10)
  sub  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0224 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x16, 128(x10)
  xor  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0225 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x17, 132(x10)
  or   x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0226 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x18, 136(x10)
  and  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0227 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x19, 140(x10)
  slt  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0228 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x20, 144(x10)
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0229 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x21, 148(x10)
  sub  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0230 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x22, 152(x10)
  xor  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0231 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x23, 156(x10)
  or   x30, x23, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0232 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x24, 160(x10)
  and  x31, x24, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0233 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x25, 164(x10)
  slt  x5, x25, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0234 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x26, 168(x10)
  add  x6, x26, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0235 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x27, 172(x10)
  sub  x7, x27, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0236 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x28, 176(x10)
  xor  x8, x28, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0237 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x29, 180(x10)
  or   x9, x29, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0238 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x30, 184(x10)
  and  x13, x30, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0239 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x31, 188(x10)
  slt  x14, x31, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0240 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x5, 192(x10)
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0241 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x6, 196(x10)
  sub  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0242 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x7, 200(x10)
  xor  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0243 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x8, 204(x10)
  or   x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0244 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x9, 208(x10)
  and  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0245 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x13, 212(x10)
  slt  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0246 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x14, 216(x10)
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0247 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x15, 220(x10)
  sub  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0248 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x16, 224(x10)
  xor  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0249 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x17, 228(x10)
  or   x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0250 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x18, 232(x10)
  and  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0251 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x19, 236(x10)
  slt  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0252 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x20, 240(x10)
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0253 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x21, 244(x10)
  sub  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0254 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x22, 248(x10)
  xor  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0255 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x23, 252(x10)
  or   x30, x23, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0256 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x24, 0(x10)
  and  x31, x24, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0257 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x25, 4(x10)
  slt  x5, x25, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0258 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x26, 8(x10)
  add  x6, x26, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0259 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x27, 12(x10)
  sub  x7, x27, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0260 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x28, 16(x10)
  xor  x8, x28, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0261 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x29, 20(x10)
  or   x9, x29, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0262 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x30, 24(x10)
  and  x13, x30, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0263 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x31, 28(x10)
  slt  x14, x31, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0264 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x5, 32(x10)
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0265 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x6, 36(x10)
  sub  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0266 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x7, 40(x10)
  xor  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0267 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x8, 44(x10)
  or   x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0268 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x9, 48(x10)
  and  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0269 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x13, 52(x10)
  slt  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0270 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x14, 56(x10)
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0271 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x15, 60(x10)
  sub  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0272 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x16, 64(x10)
  xor  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0273 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x17, 68(x10)
  or   x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0274 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x18, 72(x10)
  and  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0275 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x19, 76(x10)
  slt  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0276 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x20, 80(x10)
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0277 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x21, 84(x10)
  sub  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0278 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x22, 88(x10)
  xor  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0279 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x23, 92(x10)
  or   x30, x23, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0280 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x24, 96(x10)
  and  x31, x24, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0281 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x25, 100(x10)
  slt  x5, x25, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0282 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x26, 104(x10)
  add  x6, x26, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0283 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x27, 108(x10)
  sub  x7, x27, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0284 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x28, 112(x10)
  xor  x8, x28, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0285 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x29, 116(x10)
  or   x9, x29, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0286 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x30, 120(x10)
  and  x13, x30, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0287 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x31, 124(x10)
  slt  x14, x31, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0288 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x5, 128(x10)
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0289 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x6, 132(x10)
  sub  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0290 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x7, 136(x10)
  xor  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0291 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x8, 140(x10)
  or   x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0292 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x9, 144(x10)
  and  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0293 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x13, 148(x10)
  slt  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0294 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x14, 152(x10)
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0295 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x15, 156(x10)
  sub  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0296 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x16, 160(x10)
  xor  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0297 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x17, 164(x10)
  or   x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0298 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x18, 168(x10)
  and  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0299 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x19, 172(x10)
  slt  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0300 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x20, 176(x10)
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0301 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x21, 180(x10)
  sub  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0302 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x22, 184(x10)
  xor  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0303 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x23, 188(x10)
  or   x30, x23, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0304 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x24, 192(x10)
  and  x31, x24, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0305 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x25, 196(x10)
  slt  x5, x25, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0306 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x26, 200(x10)
  add  x6, x26, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0307 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x27, 204(x10)
  sub  x7, x27, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0308 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x28, 208(x10)
  xor  x8, x28, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0309 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x29, 212(x10)
  or   x9, x29, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0310 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x30, 216(x10)
  and  x13, x30, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0311 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x31, 220(x10)
  slt  x14, x31, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0312 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x5, 224(x10)
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0313 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x6, 228(x10)
  sub  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0314 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x7, 232(x10)
  xor  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0315 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x8, 236(x10)
  or   x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0316 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x9, 240(x10)
  and  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0317 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x13, 244(x10)
  slt  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0318 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x14, 248(x10)
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0319 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x15, 252(x10)
  sub  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0320 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x16, 0(x10)
  xor  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0321 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x17, 4(x10)
  or   x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0322 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x18, 8(x10)
  and  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0323 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x19, 12(x10)
  slt  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0324 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x20, 16(x10)
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0325 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x21, 20(x10)
  sub  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0326 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x22, 24(x10)
  xor  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0327 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x23, 28(x10)
  or   x30, x23, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0328 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x24, 32(x10)
  and  x31, x24, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0329 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x25, 36(x10)
  slt  x5, x25, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0330 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x26, 40(x10)
  add  x6, x26, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0331 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x27, 44(x10)
  sub  x7, x27, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0332 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x28, 48(x10)
  xor  x8, x28, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0333 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x29, 52(x10)
  or   x9, x29, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0334 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x30, 56(x10)
  and  x13, x30, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0335 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x31, 60(x10)
  slt  x14, x31, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0336 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x5, 64(x10)
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0337 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x6, 68(x10)
  sub  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0338 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x7, 72(x10)
  xor  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0339 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x8, 76(x10)
  or   x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0340 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x9, 80(x10)
  and  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0341 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x13, 84(x10)
  slt  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0342 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x14, 88(x10)
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0343 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x15, 92(x10)
  sub  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0344 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x16, 96(x10)
  xor  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0345 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x17, 100(x10)
  or   x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0346 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x18, 104(x10)
  and  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0347 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x19, 108(x10)
  slt  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0348 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x20, 112(x10)
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0349 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x21, 116(x10)
  sub  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0350 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x22, 120(x10)
  xor  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0351 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x23, 124(x10)
  or   x30, x23, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0352 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x24, 128(x10)
  and  x31, x24, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0353 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x25, 132(x10)
  slt  x5, x25, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0354 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x26, 136(x10)
  add  x6, x26, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0355 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x27, 140(x10)
  sub  x7, x27, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0356 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x28, 144(x10)
  xor  x8, x28, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0357 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x29, 148(x10)
  or   x9, x29, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0358 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x30, 152(x10)
  and  x13, x30, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0359 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x31, 156(x10)
  slt  x14, x31, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0360 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x5, 160(x10)
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0361 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x6, 164(x10)
  sub  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0362 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x7, 168(x10)
  xor  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0363 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x8, 172(x10)
  or   x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0364 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x9, 176(x10)
  and  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0365 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x13, 180(x10)
  slt  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0366 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x14, 184(x10)
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0367 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x15, 188(x10)
  sub  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0368 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x16, 192(x10)
  xor  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0369 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x17, 196(x10)
  or   x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0370 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x18, 200(x10)
  and  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0371 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x19, 204(x10)
  slt  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0372 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x20, 208(x10)
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0373 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x21, 212(x10)
  sub  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0374 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x22, 216(x10)
  xor  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0375 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x23, 220(x10)
  or   x30, x23, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0376 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x24, 224(x10)
  and  x31, x24, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0377 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x25, 228(x10)
  slt  x5, x25, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0378 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x26, 232(x10)
  add  x6, x26, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0379 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x27, 236(x10)
  sub  x7, x27, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0380 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x28, 240(x10)
  xor  x8, x28, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0381 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x29, 244(x10)
  or   x9, x29, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0382 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x30, 248(x10)
  and  x13, x30, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0383 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x31, 252(x10)
  slt  x14, x31, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0384 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x5, 0(x10)
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0385 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x6, 4(x10)
  sub  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0386 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x7, 8(x10)
  xor  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0387 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x8, 12(x10)
  or   x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0388 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x9, 16(x10)
  and  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0389 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x13, 20(x10)
  slt  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0390 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x14, 24(x10)
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0391 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x15, 28(x10)
  sub  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0392 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x16, 32(x10)
  xor  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0393 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x17, 36(x10)
  or   x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0394 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x18, 40(x10)
  and  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0395 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x19, 44(x10)
  slt  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0396 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x20, 48(x10)
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0397 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x21, 52(x10)
  sub  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0398 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x22, 56(x10)
  xor  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0399 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x23, 60(x10)
  or   x30, x23, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0400 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x24, 64(x10)
  and  x31, x24, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0401 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x25, 68(x10)
  slt  x5, x25, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0402 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x26, 72(x10)
  add  x6, x26, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0403 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x27, 76(x10)
  sub  x7, x27, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0404 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x28, 80(x10)
  xor  x8, x28, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0405 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x29, 84(x10)
  or   x9, x29, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0406 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x30, 88(x10)
  and  x13, x30, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0407 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x31, 92(x10)
  slt  x14, x31, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0408 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x5, 96(x10)
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0409 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x6, 100(x10)
  sub  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0410 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x7, 104(x10)
  xor  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0411 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x8, 108(x10)
  or   x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0412 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x9, 112(x10)
  and  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0413 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x13, 116(x10)
  slt  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0414 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x14, 120(x10)
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0415 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x15, 124(x10)
  sub  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0416 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x16, 128(x10)
  xor  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0417 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x17, 132(x10)
  or   x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0418 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x18, 136(x10)
  and  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0419 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x19, 140(x10)
  slt  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0420 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x20, 144(x10)
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0421 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x21, 148(x10)
  sub  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0422 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x22, 152(x10)
  xor  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0423 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x23, 156(x10)
  or   x30, x23, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0424 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x24, 160(x10)
  and  x31, x24, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0425 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x25, 164(x10)
  slt  x5, x25, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0426 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x26, 168(x10)
  add  x6, x26, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0427 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x27, 172(x10)
  sub  x7, x27, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0428 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x28, 176(x10)
  xor  x8, x28, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0429 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x29, 180(x10)
  or   x9, x29, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0430 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x30, 184(x10)
  and  x13, x30, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0431 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x31, 188(x10)
  slt  x14, x31, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0432 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x5, 192(x10)
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0433 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x6, 196(x10)
  sub  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0434 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x7, 200(x10)
  xor  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0435 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x8, 204(x10)
  or   x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0436 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x9, 208(x10)
  and  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0437 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x13, 212(x10)
  slt  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0438 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x14, 216(x10)
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0439 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x15, 220(x10)
  sub  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0440 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x16, 224(x10)
  xor  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0441 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x17, 228(x10)
  or   x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0442 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x18, 232(x10)
  and  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0443 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x19, 236(x10)
  slt  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0444 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x20, 240(x10)
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0445 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x21, 244(x10)
  sub  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0446 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x22, 248(x10)
  xor  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0447 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x23, 252(x10)
  or   x30, x23, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0448 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x24, 0(x10)
  and  x31, x24, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0449 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x25, 4(x10)
  slt  x5, x25, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0450 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x26, 8(x10)
  add  x6, x26, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0451 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x27, 12(x10)
  sub  x7, x27, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0452 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x28, 16(x10)
  xor  x8, x28, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0453 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x29, 20(x10)
  or   x9, x29, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0454 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x30, 24(x10)
  and  x13, x30, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0455 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x31, 28(x10)
  slt  x14, x31, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0456 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x5, 32(x10)
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0457 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x6, 36(x10)
  sub  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0458 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x7, 40(x10)
  xor  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0459 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x8, 44(x10)
  or   x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0460 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x9, 48(x10)
  and  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0461 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x13, 52(x10)
  slt  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0462 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x14, 56(x10)
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0463 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x15, 60(x10)
  sub  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0464 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x16, 64(x10)
  xor  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0465 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x17, 68(x10)
  or   x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0466 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x18, 72(x10)
  and  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0467 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x19, 76(x10)
  slt  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0468 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x20, 80(x10)
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0469 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x21, 84(x10)
  sub  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0470 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x22, 88(x10)
  xor  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0471 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x23, 92(x10)
  or   x30, x23, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0472 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x24, 96(x10)
  and  x31, x24, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0473 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x25, 100(x10)
  slt  x5, x25, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0474 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x26, 104(x10)
  add  x6, x26, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0475 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x27, 108(x10)
  sub  x7, x27, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0476 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x28, 112(x10)
  xor  x8, x28, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0477 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x29, 116(x10)
  or   x9, x29, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0478 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x30, 120(x10)
  and  x13, x30, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0479 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x31, 124(x10)
  slt  x14, x31, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0480 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x5, 128(x10)
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0481 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x6, 132(x10)
  sub  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0482 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x7, 136(x10)
  xor  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0483 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x8, 140(x10)
  or   x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0484 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x9, 144(x10)
  and  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0485 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x13, 148(x10)
  slt  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0486 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x14, 152(x10)
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0487 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x15, 156(x10)
  sub  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0488 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x16, 160(x10)
  xor  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0489 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x17, 164(x10)
  or   x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0490 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x18, 168(x10)
  and  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0491 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x19, 172(x10)
  slt  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0492 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x20, 176(x10)
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0493 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x21, 180(x10)
  sub  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0494 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x22, 184(x10)
  xor  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0495 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x23, 188(x10)
  or   x30, x23, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0496 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x24, 192(x10)
  and  x31, x24, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0497 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x25, 196(x10)
  slt  x5, x25, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0498 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x26, 200(x10)
  add  x6, x26, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0000 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x5, 0(x10)
  add  x15, x11, x5

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0001 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x6, 4(x10)
  sub  x16, x11, x6

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0002 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x7, 8(x10)
  xor  x17, x11, x7

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0003 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x8, 12(x10)
  or   x18, x11, x8

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0004 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x9, 16(x10)
  and  x19, x11, x9

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0005 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x13, 20(x10)
  slt  x20, x11, x13

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0006 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x14, 24(x10)
  add  x21, x11, x14

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0007 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x15, 28(x10)
  sub  x22, x11, x15

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0008 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x16, 32(x10)
  xor  x23, x11, x16

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0009 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x17, 36(x10)
  or   x24, x11, x17

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0010 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x18, 40(x10)
  and  x25, x11, x18

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0011 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x19, 44(x10)
  slt  x26, x11, x19

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0012 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x20, 48(x10)
  add  x27, x11, x20

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0013 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x21, 52(x10)
  sub  x28, x11, x21

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0014 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x22, 56(x10)
  xor  x29, x11, x22

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0015 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x23, 60(x10)
  or   x30, x11, x23

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0016 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x24, 64(x10)
  and  x31, x11, x24

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0017 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x25, 68(x10)
  slt  x5, x11, x25

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0018 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x26, 72(x10)
  add  x6, x11, x26

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0019 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x27, 76(x10)
  sub  x7, x11, x27

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0020 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x28, 80(x10)
  xor  x8, x11, x28

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0021 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x29, 84(x10)
  or   x9, x11, x29

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0022 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x30, 88(x10)
  and  x13, x11, x30

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0023 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x31, 92(x10)
  slt  x14, x11, x31

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0024 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x5, 96(x10)
  add  x15, x11, x5

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0025 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x6, 100(x10)
  sub  x16, x11, x6

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0026 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x7, 104(x10)
  xor  x17, x11, x7

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0027 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x8, 108(x10)
  or   x18, x11, x8

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0028 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x9, 112(x10)
  and  x19, x11, x9

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0029 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x13, 116(x10)
  slt  x20, x11, x13

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0030 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x14, 120(x10)
  add  x21, x11, x14

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0031 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x15, 124(x10)
  sub  x22, x11, x15

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0032 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x16, 128(x10)
  xor  x23, x11, x16

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0033 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x17, 132(x10)
  or   x24, x11, x17

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0034 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x18, 136(x10)
  and  x25, x11, x18

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0035 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x19, 140(x10)
  slt  x26, x11, x19

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0036 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x20, 144(x10)
  add  x27, x11, x20

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0037 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x21, 148(x10)
  sub  x28, x11, x21

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0038 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x22, 152(x10)
  xor  x29, x11, x22

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0039 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x23, 156(x10)
  or   x30, x11, x23

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0040 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x24, 160(x10)
  and  x31, x11, x24

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0041 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x25, 164(x10)
  slt  x5, x11, x25

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0042 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x26, 168(x10)
  add  x6, x11, x26

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0043 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x27, 172(x10)
  sub  x7, x11, x27

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0044 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x28, 176(x10)
  xor  x8, x11, x28

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0045 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x29, 180(x10)
  or   x9, x11, x29

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0046 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x30, 184(x10)
  and  x13, x11, x30

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0047 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x31, 188(x10)
  slt  x14, x11, x31

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0048 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x5, 192(x10)
  add  x15, x11, x5

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0049 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x6, 196(x10)
  sub  x16, x11, x6

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0050 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x7, 200(x10)
  xor  x17, x11, x7

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0051 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x8, 204(x10)
  or   x18, x11, x8

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0052 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x9, 208(x10)
  and  x19, x11, x9

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0053 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x13, 212(x10)
  slt  x20, x11, x13

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0054 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x14, 216(x10)
  add  x21, x11, x14

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0055 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x15, 220(x10)
  sub  x22, x11, x15

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0056 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x16, 224(x10)
  xor  x23, x11, x16

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0057 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x17, 228(x10)
  or   x24, x11, x17

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0058 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x18, 232(x10)
  and  x25, x11, x18

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0059 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x19, 236(x10)
  slt  x26, x11, x19

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0060 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x20, 240(x10)
  add  x27, x11, x20

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0061 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x21, 244(x10)
  sub  x28, x11, x21

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0062 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x22, 248(x10)
  xor  x29, x11, x22

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0063 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x23, 252(x10)
  or   x30, x11, x23

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0064 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x24, 0(x10)
  and  x31, x11, x24

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0065 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x25, 4(x10)
  slt  x5, x11, x25

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0066 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x26, 8(x10)
  add  x6, x11, x26

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0067 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x27, 12(x10)
  sub  x7, x11, x27

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0068 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x28, 16(x10)
  xor  x8, x11, x28

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0069 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x29, 20(x10)
  or   x9, x11, x29

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0070 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x30, 24(x10)
  and  x13, x11, x30

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0071 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x31, 28(x10)
  slt  x14, x11, x31

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0072 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x5, 32(x10)
  add  x15, x11, x5

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0073 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x6, 36(x10)
  sub  x16, x11, x6

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0074 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x7, 40(x10)
  xor  x17, x11, x7

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0075 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x8, 44(x10)
  or   x18, x11, x8

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0076 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x9, 48(x10)
  and  x19, x11, x9

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0077 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x13, 52(x10)
  slt  x20, x11, x13

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0078 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x14, 56(x10)
  add  x21, x11, x14

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0079 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x15, 60(x10)
  sub  x22, x11, x15

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0080 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x16, 64(x10)
  xor  x23, x11, x16

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0081 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x17, 68(x10)
  or   x24, x11, x17

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0082 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x18, 72(x10)
  and  x25, x11, x18

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0083 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x19, 76(x10)
  slt  x26, x11, x19

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0084 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x20, 80(x10)
  add  x27, x11, x20

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0085 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x21, 84(x10)
  sub  x28, x11, x21

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0086 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x22, 88(x10)
  xor  x29, x11, x22

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0087 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x23, 92(x10)
  or   x30, x11, x23

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0088 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x24, 96(x10)
  and  x31, x11, x24

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0089 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x25, 100(x10)
  slt  x5, x11, x25

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0090 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x26, 104(x10)
  add  x6, x11, x26

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0091 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x27, 108(x10)
  sub  x7, x11, x27

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0092 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x28, 112(x10)
  xor  x8, x11, x28

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0093 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x29, 116(x10)
  or   x9, x11, x29

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0094 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x30, 120(x10)
  and  x13, x11, x30

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0095 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x31, 124(x10)
  slt  x14, x11, x31

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0096 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x5, 128(x10)
  add  x15, x11, x5

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0097 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x6, 132(x10)
  sub  x16, x11, x6

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0098 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x7, 136(x10)
  xor  x17, x11, x7

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0099 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x8, 140(x10)
  or   x18, x11, x8

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0100 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x9, 144(x10)
  and  x19, x11, x9

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0101 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x13, 148(x10)
  slt  x20, x11, x13

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0102 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x14, 152(x10)
  add  x21, x11, x14

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0103 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x15, 156(x10)
  sub  x22, x11, x15

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0104 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x16, 160(x10)
  xor  x23, x11, x16

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0105 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x17, 164(x10)
  or   x24, x11, x17

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0106 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x18, 168(x10)
  and  x25, x11, x18

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0107 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x19, 172(x10)
  slt  x26, x11, x19

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0108 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x20, 176(x10)
  add  x27, x11, x20

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0109 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x21, 180(x10)
  sub  x28, x11, x21

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0110 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x22, 184(x10)
  xor  x29, x11, x22

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0111 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x23, 188(x10)
  or   x30, x11, x23

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0112 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x24, 192(x10)
  and  x31, x11, x24

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0113 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x25, 196(x10)
  slt  x5, x11, x25

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0114 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x26, 200(x10)
  add  x6, x11, x26

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0115 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x27, 204(x10)
  sub  x7, x11, x27

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0116 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x28, 208(x10)
  xor  x8, x11, x28

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0117 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x29, 212(x10)
  or   x9, x11, x29

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0118 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x30, 216(x10)
  and  x13, x11, x30

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0119 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x31, 220(x10)
  slt  x14, x11, x31

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0120 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x5, 224(x10)
  add  x15, x11, x5

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0121 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x6, 228(x10)
  sub  x16, x11, x6

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0122 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x7, 232(x10)
  xor  x17, x11, x7

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0123 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x8, 236(x10)
  or   x18, x11, x8

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0124 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x9, 240(x10)
  and  x19, x11, x9

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0125 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x13, 244(x10)
  slt  x20, x11, x13

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0126 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x14, 248(x10)
  add  x21, x11, x14

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0127 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x15, 252(x10)
  sub  x22, x11, x15

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0128 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x16, 0(x10)
  xor  x23, x11, x16

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0129 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x17, 4(x10)
  or   x24, x11, x17

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0130 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x18, 8(x10)
  and  x25, x11, x18

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0131 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x19, 12(x10)
  slt  x26, x11, x19

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0132 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x20, 16(x10)
  add  x27, x11, x20

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0133 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x21, 20(x10)
  sub  x28, x11, x21

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0134 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x22, 24(x10)
  xor  x29, x11, x22

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0135 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x23, 28(x10)
  or   x30, x11, x23

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0136 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x24, 32(x10)
  and  x31, x11, x24

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0137 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x25, 36(x10)
  slt  x5, x11, x25

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0138 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x26, 40(x10)
  add  x6, x11, x26

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0139 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x27, 44(x10)
  sub  x7, x11, x27

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0140 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x28, 48(x10)
  xor  x8, x11, x28

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0141 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x29, 52(x10)
  or   x9, x11, x29

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0142 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x30, 56(x10)
  and  x13, x11, x30

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0143 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x31, 60(x10)
  slt  x14, x11, x31

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0144 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x5, 64(x10)
  add  x15, x11, x5

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0145 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x6, 68(x10)
  sub  x16, x11, x6

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0146 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x7, 72(x10)
  xor  x17, x11, x7

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0147 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x8, 76(x10)
  or   x18, x11, x8

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0148 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x9, 80(x10)
  and  x19, x11, x9

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0149 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x13, 84(x10)
  slt  x20, x11, x13

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0150 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x14, 88(x10)
  add  x21, x11, x14

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0151 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x15, 92(x10)
  sub  x22, x11, x15

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0152 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x16, 96(x10)
  xor  x23, x11, x16

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0153 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x17, 100(x10)
  or   x24, x11, x17

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0154 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x18, 104(x10)
  and  x25, x11, x18

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0155 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x19, 108(x10)
  slt  x26, x11, x19

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0156 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x20, 112(x10)
  add  x27, x11, x20

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0157 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x21, 116(x10)
  sub  x28, x11, x21

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0158 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x22, 120(x10)
  xor  x29, x11, x22

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0159 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x23, 124(x10)
  or   x30, x11, x23

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0160 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x24, 128(x10)
  and  x31, x11, x24

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0161 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x25, 132(x10)
  slt  x5, x11, x25

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0162 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x26, 136(x10)
  add  x6, x11, x26

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0163 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x27, 140(x10)
  sub  x7, x11, x27

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0164 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x28, 144(x10)
  xor  x8, x11, x28

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0165 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x29, 148(x10)
  or   x9, x11, x29

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0166 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x30, 152(x10)
  and  x13, x11, x30

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0167 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x31, 156(x10)
  slt  x14, x11, x31

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0168 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x5, 160(x10)
  add  x15, x11, x5

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0169 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x6, 164(x10)
  sub  x16, x11, x6

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0170 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x7, 168(x10)
  xor  x17, x11, x7

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0171 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x8, 172(x10)
  or   x18, x11, x8

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0172 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x9, 176(x10)
  and  x19, x11, x9

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0173 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x13, 180(x10)
  slt  x20, x11, x13

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0174 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x14, 184(x10)
  add  x21, x11, x14

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0175 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x15, 188(x10)
  sub  x22, x11, x15

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0176 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x16, 192(x10)
  xor  x23, x11, x16

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0177 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x17, 196(x10)
  or   x24, x11, x17

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0178 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x18, 200(x10)
  and  x25, x11, x18

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0179 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x19, 204(x10)
  slt  x26, x11, x19

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0180 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x20, 208(x10)
  add  x27, x11, x20

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0181 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x21, 212(x10)
  sub  x28, x11, x21

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0182 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x22, 216(x10)
  xor  x29, x11, x22

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0183 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x23, 220(x10)
  or   x30, x11, x23

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0184 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x24, 224(x10)
  and  x31, x11, x24

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0185 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x25, 228(x10)
  slt  x5, x11, x25

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0186 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x26, 232(x10)
  add  x6, x11, x26

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0187 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x27, 236(x10)
  sub  x7, x11, x27

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0188 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x28, 240(x10)
  xor  x8, x11, x28

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0189 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x29, 244(x10)
  or   x9, x11, x29

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0190 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x30, 248(x10)
  and  x13, x11, x30

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0191 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x31, 252(x10)
  slt  x14, x11, x31

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0192 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x5, 0(x10)
  add  x15, x11, x5

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0193 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x6, 4(x10)
  sub  x16, x11, x6

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0194 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x7, 8(x10)
  xor  x17, x11, x7

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0195 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x8, 12(x10)
  or   x18, x11, x8

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0196 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x9, 16(x10)
  and  x19, x11, x9

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0197 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x13, 20(x10)
  slt  x20, x11, x13

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0198 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x14, 24(x10)
  add  x21, x11, x14

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0199 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x15, 28(x10)
  sub  x22, x11, x15

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0200 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x16, 32(x10)
  xor  x23, x11, x16

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0201 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x17, 36(x10)
  or   x24, x11, x17

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0202 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x18, 40(x10)
  and  x25, x11, x18

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0203 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x19, 44(x10)
  slt  x26, x11, x19

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0204 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x20, 48(x10)
  add  x27, x11, x20

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0205 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x21, 52(x10)
  sub  x28, x11, x21

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0206 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x22, 56(x10)
  xor  x29, x11, x22

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0207 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x23, 60(x10)
  or   x30, x11, x23

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0208 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x24, 64(x10)
  and  x31, x11, x24

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0209 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x25, 68(x10)
  slt  x5, x11, x25

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0210 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x26, 72(x10)
  add  x6, x11, x26

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0211 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x27, 76(x10)
  sub  x7, x11, x27

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0212 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x28, 80(x10)
  xor  x8, x11, x28

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0213 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x29, 84(x10)
  or   x9, x11, x29

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0214 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x30, 88(x10)
  and  x13, x11, x30

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0215 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x31, 92(x10)
  slt  x14, x11, x31

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0216 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x5, 96(x10)
  add  x15, x11, x5

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0217 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x6, 100(x10)
  sub  x16, x11, x6

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0218 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x7, 104(x10)
  xor  x17, x11, x7

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0219 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x8, 108(x10)
  or   x18, x11, x8

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0220 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x9, 112(x10)
  and  x19, x11, x9

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0221 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x13, 116(x10)
  slt  x20, x11, x13

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0222 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x14, 120(x10)
  add  x21, x11, x14

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0223 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x15, 124(x10)
  sub  x22, x11, x15

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0224 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x16, 128(x10)
  xor  x23, x11, x16

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0225 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x17, 132(x10)
  or   x24, x11, x17

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0226 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x18, 136(x10)
  and  x25, x11, x18

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0227 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x19, 140(x10)
  slt  x26, x11, x19

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0228 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x20, 144(x10)
  add  x27, x11, x20

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0229 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x21, 148(x10)
  sub  x28, x11, x21

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0230 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x22, 152(x10)
  xor  x29, x11, x22

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0231 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x23, 156(x10)
  or   x30, x11, x23

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0232 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x24, 160(x10)
  and  x31, x11, x24

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0233 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x25, 164(x10)
  slt  x5, x11, x25

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0234 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x26, 168(x10)
  add  x6, x11, x26

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0235 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x27, 172(x10)
  sub  x7, x11, x27

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0236 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x28, 176(x10)
  xor  x8, x11, x28

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0237 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x29, 180(x10)
  or   x9, x11, x29

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0238 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x30, 184(x10)
  and  x13, x11, x30

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0239 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x31, 188(x10)
  slt  x14, x11, x31

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0240 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x5, 192(x10)
  add  x15, x11, x5

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0241 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x6, 196(x10)
  sub  x16, x11, x6

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0242 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x7, 200(x10)
  xor  x17, x11, x7

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0243 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x8, 204(x10)
  or   x18, x11, x8

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0244 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x9, 208(x10)
  and  x19, x11, x9

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0245 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x13, 212(x10)
  slt  x20, x11, x13

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0246 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x14, 216(x10)
  add  x21, x11, x14

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0247 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x15, 220(x10)
  sub  x22, x11, x15

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0248 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x16, 224(x10)
  xor  x23, x11, x16

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0249 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x17, 228(x10)
  or   x24, x11, x17

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0250 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x18, 232(x10)
  and  x25, x11, x18

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0251 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x19, 236(x10)
  slt  x26, x11, x19

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0252 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x20, 240(x10)
  add  x27, x11, x20

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0253 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x21, 244(x10)
  sub  x28, x11, x21

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0254 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x22, 248(x10)
  xor  x29, x11, x22

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0255 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x23, 252(x10)
  or   x30, x11, x23

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0256 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x24, 0(x10)
  and  x31, x11, x24

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0257 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x25, 4(x10)
  slt  x5, x11, x25

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0258 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x26, 8(x10)
  add  x6, x11, x26

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0259 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x27, 12(x10)
  sub  x7, x11, x27

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0260 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x28, 16(x10)
  xor  x8, x11, x28

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0261 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x29, 20(x10)
  or   x9, x11, x29

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0262 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x30, 24(x10)
  and  x13, x11, x30

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0263 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x31, 28(x10)
  slt  x14, x11, x31

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0264 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x5, 32(x10)
  add  x15, x11, x5

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0265 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x6, 36(x10)
  sub  x16, x11, x6

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0266 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x7, 40(x10)
  xor  x17, x11, x7

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0267 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x8, 44(x10)
  or   x18, x11, x8

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0268 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x9, 48(x10)
  and  x19, x11, x9

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0269 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x13, 52(x10)
  slt  x20, x11, x13

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0270 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x14, 56(x10)
  add  x21, x11, x14

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0271 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x15, 60(x10)
  sub  x22, x11, x15

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0272 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x16, 64(x10)
  xor  x23, x11, x16

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0273 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x17, 68(x10)
  or   x24, x11, x17

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0274 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x18, 72(x10)
  and  x25, x11, x18

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0275 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x19, 76(x10)
  slt  x26, x11, x19

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0276 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x20, 80(x10)
  add  x27, x11, x20

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0277 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x21, 84(x10)
  sub  x28, x11, x21

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0278 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x22, 88(x10)
  xor  x29, x11, x22

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0279 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x23, 92(x10)
  or   x30, x11, x23

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0280 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x24, 96(x10)
  and  x31, x11, x24

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0281 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x25, 100(x10)
  slt  x5, x11, x25

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0282 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x26, 104(x10)
  add  x6, x11, x26

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0283 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x27, 108(x10)
  sub  x7, x11, x27

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0284 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x28, 112(x10)
  xor  x8, x11, x28

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0285 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x29, 116(x10)
  or   x9, x11, x29

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0286 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x30, 120(x10)
  and  x13, x11, x30

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0287 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x31, 124(x10)
  slt  x14, x11, x31

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0288 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x5, 128(x10)
  add  x15, x11, x5

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0289 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x6, 132(x10)
  sub  x16, x11, x6

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0290 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x7, 136(x10)
  xor  x17, x11, x7

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0291 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x8, 140(x10)
  or   x18, x11, x8

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0292 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x9, 144(x10)
  and  x19, x11, x9

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0293 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x13, 148(x10)
  slt  x20, x11, x13

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0294 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x14, 152(x10)
  add  x21, x11, x14

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0295 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x15, 156(x10)
  sub  x22, x11, x15

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0296 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x16, 160(x10)
  xor  x23, x11, x16

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0297 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x17, 164(x10)
  or   x24, x11, x17

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0298 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x18, 168(x10)
  and  x25, x11, x18

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0299 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x19, 172(x10)
  slt  x26, x11, x19

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0300 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x20, 176(x10)
  add  x27, x11, x20

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0301 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x21, 180(x10)
  sub  x28, x11, x21

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0302 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x22, 184(x10)
  xor  x29, x11, x22

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0303 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x23, 188(x10)
  or   x30, x11, x23

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0304 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x24, 192(x10)
  and  x31, x11, x24

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0305 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x25, 196(x10)
  slt  x5, x11, x25

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0306 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x26, 200(x10)
  add  x6, x11, x26

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0307 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x27, 204(x10)
  sub  x7, x11, x27

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0308 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x28, 208(x10)
  xor  x8, x11, x28

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0309 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x29, 212(x10)
  or   x9, x11, x29

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0310 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x30, 216(x10)
  and  x13, x11, x30

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0311 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x31, 220(x10)
  slt  x14, x11, x31

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0312 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x5, 224(x10)
  add  x15, x11, x5

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0313 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x6, 228(x10)
  sub  x16, x11, x6

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0314 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x7, 232(x10)
  xor  x17, x11, x7

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0315 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x8, 236(x10)
  or   x18, x11, x8

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0316 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x9, 240(x10)
  and  x19, x11, x9

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0317 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x13, 244(x10)
  slt  x20, x11, x13

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0318 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x14, 248(x10)
  add  x21, x11, x14

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0319 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x15, 252(x10)
  sub  x22, x11, x15

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0320 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x16, 0(x10)
  xor  x23, x11, x16

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0321 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x17, 4(x10)
  or   x24, x11, x17

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0322 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x18, 8(x10)
  and  x25, x11, x18

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0323 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x19, 12(x10)
  slt  x26, x11, x19

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0324 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x20, 16(x10)
  add  x27, x11, x20

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0325 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x21, 20(x10)
  sub  x28, x11, x21

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0326 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x22, 24(x10)
  xor  x29, x11, x22

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0327 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x23, 28(x10)
  or   x30, x11, x23

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0328 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x24, 32(x10)
  and  x31, x11, x24

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0329 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x25, 36(x10)
  slt  x5, x11, x25

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0330 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x26, 40(x10)
  add  x6, x11, x26

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0331 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x27, 44(x10)
  sub  x7, x11, x27

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0332 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x28, 48(x10)
  xor  x8, x11, x28

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0333 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x29, 52(x10)
  or   x9, x11, x29

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0334 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x30, 56(x10)
  and  x13, x11, x30

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0335 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x31, 60(x10)
  slt  x14, x11, x31

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0336 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x5, 64(x10)
  add  x15, x11, x5

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0337 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x6, 68(x10)
  sub  x16, x11, x6

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0338 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x7, 72(x10)
  xor  x17, x11, x7

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0339 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x8, 76(x10)
  or   x18, x11, x8

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0340 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x9, 80(x10)
  and  x19, x11, x9

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0341 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x13, 84(x10)
  slt  x20, x11, x13

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0342 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x14, 88(x10)
  add  x21, x11, x14

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0343 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x15, 92(x10)
  sub  x22, x11, x15

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0344 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x16, 96(x10)
  xor  x23, x11, x16

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0345 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x17, 100(x10)
  or   x24, x11, x17

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0346 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x18, 104(x10)
  and  x25, x11, x18

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0347 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x19, 108(x10)
  slt  x26, x11, x19

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0348 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x20, 112(x10)
  add  x27, x11, x20

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0349 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x21, 116(x10)
  sub  x28, x11, x21

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0350 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x22, 120(x10)
  xor  x29, x11, x22

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0351 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x23, 124(x10)
  or   x30, x11, x23

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0352 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x24, 128(x10)
  and  x31, x11, x24

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0353 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x25, 132(x10)
  slt  x5, x11, x25

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0354 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x26, 136(x10)
  add  x6, x11, x26

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0355 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x27, 140(x10)
  sub  x7, x11, x27

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0356 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x28, 144(x10)
  xor  x8, x11, x28

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0357 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x29, 148(x10)
  or   x9, x11, x29

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0358 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x30, 152(x10)
  and  x13, x11, x30

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0359 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x31, 156(x10)
  slt  x14, x11, x31

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0360 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x5, 160(x10)
  add  x15, x11, x5

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0361 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x6, 164(x10)
  sub  x16, x11, x6

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0362 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x7, 168(x10)
  xor  x17, x11, x7

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0363 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x8, 172(x10)
  or   x18, x11, x8

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0364 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x9, 176(x10)
  and  x19, x11, x9

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0365 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x13, 180(x10)
  slt  x20, x11, x13

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0366 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x14, 184(x10)
  add  x21, x11, x14

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0367 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x15, 188(x10)
  sub  x22, x11, x15

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0368 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x16, 192(x10)
  xor  x23, x11, x16

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0369 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x17, 196(x10)
  or   x24, x11, x17

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0370 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x18, 200(x10)
  and  x25, x11, x18

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0371 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x19, 204(x10)
  slt  x26, x11, x19

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0372 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x20, 208(x10)
  add  x27, x11, x20

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0373 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x21, 212(x10)
  sub  x28, x11, x21

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0374 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x22, 216(x10)
  xor  x29, x11, x22

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0375 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x23, 220(x10)
  or   x30, x11, x23

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0376 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x24, 224(x10)
  and  x31, x11, x24

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0377 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x25, 228(x10)
  slt  x5, x11, x25

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0378 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x26, 232(x10)
  add  x6, x11, x26

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0379 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x27, 236(x10)
  sub  x7, x11, x27

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0380 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x28, 240(x10)
  xor  x8, x11, x28

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0381 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x29, 244(x10)
  or   x9, x11, x29

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0382 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x30, 248(x10)
  and  x13, x11, x30

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0383 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x31, 252(x10)
  slt  x14, x11, x31

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0384 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x5, 0(x10)
  add  x15, x11, x5

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0385 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x6, 4(x10)
  sub  x16, x11, x6

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0386 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x7, 8(x10)
  xor  x17, x11, x7

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0387 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x8, 12(x10)
  or   x18, x11, x8

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0388 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x9, 16(x10)
  and  x19, x11, x9

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0389 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x13, 20(x10)
  slt  x20, x11, x13

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0390 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x14, 24(x10)
  add  x21, x11, x14

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0391 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x15, 28(x10)
  sub  x22, x11, x15

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0392 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x16, 32(x10)
  xor  x23, x11, x16

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0393 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x17, 36(x10)
  or   x24, x11, x17

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0394 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x18, 40(x10)
  and  x25, x11, x18

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0395 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x19, 44(x10)
  slt  x26, x11, x19

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0396 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x20, 48(x10)
  add  x27, x11, x20

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0397 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x21, 52(x10)
  sub  x28, x11, x21

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0398 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x22, 56(x10)
  xor  x29, x11, x22

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0399 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x23, 60(x10)
  or   x30, x11, x23

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0400 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x24, 64(x10)
  and  x31, x11, x24

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0401 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x25, 68(x10)
  slt  x5, x11, x25

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0402 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x26, 72(x10)
  add  x6, x11, x26

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0403 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x27, 76(x10)
  sub  x7, x11, x27

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0404 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x28, 80(x10)
  xor  x8, x11, x28

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0405 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x29, 84(x10)
  or   x9, x11, x29

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0406 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x30, 88(x10)
  and  x13, x11, x30

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0407 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x31, 92(x10)
  slt  x14, x11, x31

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0408 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x5, 96(x10)
  add  x15, x11, x5

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0409 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x6, 100(x10)
  sub  x16, x11, x6

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0410 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x7, 104(x10)
  xor  x17, x11, x7

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0411 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x8, 108(x10)
  or   x18, x11, x8

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0412 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x9, 112(x10)
  and  x19, x11, x9

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0413 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x13, 116(x10)
  slt  x20, x11, x13

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0414 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x14, 120(x10)
  add  x21, x11, x14

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0415 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x15, 124(x10)
  sub  x22, x11, x15

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0416 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x16, 128(x10)
  xor  x23, x11, x16

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0417 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x17, 132(x10)
  or   x24, x11, x17

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0418 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x18, 136(x10)
  and  x25, x11, x18

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0419 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x19, 140(x10)
  slt  x26, x11, x19

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0420 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x20, 144(x10)
  add  x27, x11, x20

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0421 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x21, 148(x10)
  sub  x28, x11, x21

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0422 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x22, 152(x10)
  xor  x29, x11, x22

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0423 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x23, 156(x10)
  or   x30, x11, x23

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0424 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x24, 160(x10)
  and  x31, x11, x24

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0425 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x25, 164(x10)
  slt  x5, x11, x25

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0426 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x26, 168(x10)
  add  x6, x11, x26

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0427 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x27, 172(x10)
  sub  x7, x11, x27

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0428 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x28, 176(x10)
  xor  x8, x11, x28

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0429 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x29, 180(x10)
  or   x9, x11, x29

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0430 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x30, 184(x10)
  and  x13, x11, x30

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0431 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x31, 188(x10)
  slt  x14, x11, x31

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0432 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x5, 192(x10)
  add  x15, x11, x5

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0433 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x6, 196(x10)
  sub  x16, x11, x6

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0434 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x7, 200(x10)
  xor  x17, x11, x7

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0435 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x8, 204(x10)
  or   x18, x11, x8

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0436 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x9, 208(x10)
  and  x19, x11, x9

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0437 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x13, 212(x10)
  slt  x20, x11, x13

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0438 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x14, 216(x10)
  add  x21, x11, x14

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0439 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x15, 220(x10)
  sub  x22, x11, x15

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0440 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x16, 224(x10)
  xor  x23, x11, x16

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0441 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x17, 228(x10)
  or   x24, x11, x17

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0442 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x18, 232(x10)
  and  x25, x11, x18

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0443 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x19, 236(x10)
  slt  x26, x11, x19

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0444 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x20, 240(x10)
  add  x27, x11, x20

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0445 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x21, 244(x10)
  sub  x28, x11, x21

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0446 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x22, 248(x10)
  xor  x29, x11, x22

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0447 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x23, 252(x10)
  or   x30, x11, x23

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0448 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x24, 0(x10)
  and  x31, x11, x24

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0449 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x25, 4(x10)
  slt  x5, x11, x25

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0450 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x26, 8(x10)
  add  x6, x11, x26

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0451 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x27, 12(x10)
  sub  x7, x11, x27

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0452 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x28, 16(x10)
  xor  x8, x11, x28

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0453 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x29, 20(x10)
  or   x9, x11, x29

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0454 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x30, 24(x10)
  and  x13, x11, x30

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0455 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x31, 28(x10)
  slt  x14, x11, x31

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0456 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x5, 32(x10)
  add  x15, x11, x5

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0457 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x6, 36(x10)
  sub  x16, x11, x6

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0458 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x7, 40(x10)
  xor  x17, x11, x7

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0459 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x8, 44(x10)
  or   x18, x11, x8

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0460 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x9, 48(x10)
  and  x19, x11, x9

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0461 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x13, 52(x10)
  slt  x20, x11, x13

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0462 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x14, 56(x10)
  add  x21, x11, x14

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0463 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x15, 60(x10)
  sub  x22, x11, x15

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0464 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x16, 64(x10)
  xor  x23, x11, x16

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0465 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x17, 68(x10)
  or   x24, x11, x17

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0466 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x18, 72(x10)
  and  x25, x11, x18

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0467 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x19, 76(x10)
  slt  x26, x11, x19

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0468 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x20, 80(x10)
  add  x27, x11, x20

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0469 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x21, 84(x10)
  sub  x28, x11, x21

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0470 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x22, 88(x10)
  xor  x29, x11, x22

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0471 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x23, 92(x10)
  or   x30, x11, x23

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0472 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x24, 96(x10)
  and  x31, x11, x24

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0473 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x25, 100(x10)
  slt  x5, x11, x25

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0474 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x26, 104(x10)
  add  x6, x11, x26

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0475 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x27, 108(x10)
  sub  x7, x11, x27

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0476 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x28, 112(x10)
  xor  x8, x11, x28

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0477 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x29, 116(x10)
  or   x9, x11, x29

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0478 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x30, 120(x10)
  and  x13, x11, x30

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0479 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x31, 124(x10)
  slt  x14, x11, x31

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0480 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x5, 128(x10)
  add  x15, x11, x5

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0481 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x6, 132(x10)
  sub  x16, x11, x6

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0482 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x7, 136(x10)
  xor  x17, x11, x7

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0483 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x8, 140(x10)
  or   x18, x11, x8

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0484 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x9, 144(x10)
  and  x19, x11, x9

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0485 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x13, 148(x10)
  slt  x20, x11, x13

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0486 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x14, 152(x10)
  add  x21, x11, x14

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0487 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x15, 156(x10)
  sub  x22, x11, x15

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0488 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x16, 160(x10)
  xor  x23, x11, x16

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0489 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x17, 164(x10)
  or   x24, x11, x17

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0490 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x18, 168(x10)
  and  x25, x11, x18

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0491 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x19, 172(x10)
  slt  x26, x11, x19

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0492 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x20, 176(x10)
  add  x27, x11, x20

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0493 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x21, 180(x10)
  sub  x28, x11, x21

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0494 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x22, 184(x10)
  xor  x29, x11, x22

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0495 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x23, 188(x10)
  or   x30, x11, x23

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0496 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x24, 192(x10)
  and  x31, x11, x24

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0497 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x25, 196(x10)
  slt  x5, x11, x25

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0498 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x26, 200(x10)
  add  x6, x11, x26

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
