#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV64M
RVTEST_CODE_BEGIN

main:
  la   x10, bsd_cov_data
  li   x11, 0x11111111
  li   x12, 0x22222222

  # BSDCOV_PREFIX_BEGIN
  csrrw        s5, 0x325, s5
  nop  # BSDCOV_PREFIX_REPLACED_LABEL_REF
  c.nop
  sub          t1, s9, s9
  c.sub        s0, a3
  addi         s4, s4, -295
  csrrsi       s3, 0xb80, 17
  sltu         s7, a4, s11
  csrrsi       s3, 0x3b3, 0
  c.addi4spn   a3, sp, 528
  c.xor        a3, a1
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sra          tp, a0, tp
  nop  # BSDCOV_PREFIX_REPLACED_LABEL_REF
  addi         s2, s2, -917
  add          s1, s11, s6
  c.sub        a2, s1
  auipc        s3, 794300
  slt          s11, ra, t6
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.lui        a1, 27
  nop  # BSDCOV_PREFIX_REPLACED_LABEL_REF
  csrrwi       a3, 0x341, 18
  addi         a2, a2, -395
  div          tp, a7, a5
  c.nop
  csrrsi       a0, 0x3bf, 0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrwi       a6, 0x341, 3
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrw        tp, 0x323, a2
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_LABEL_REF
  c.addi       s3, -1
  addi         t3, t3, 112
  sltiu        s0, a4, 1701
  andi         sp, gp, 1263
  sub          sp, a6, s6
  and          tp, a3, s7
  c.xor        s1, a5
  mul          gp, s2, t4
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  ori          s4, gp, -992
  c.addi       t0, -1
  slti         s8, a0, 992
  nop  # BSDCOV_PREFIX_REPLACED_LABEL_REF
  c.xor        a1, a3
  addi         s11, s11, 38
  remu         a1, t6, t3
  add          s1, s4, t3
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  srai         gp, s3, 4
  c.slli       t4, 20
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  slli         t5, s7, 2
  srl          sp, s7, t2
  csrrs        s3, 0x3b8, zero
  mul          s10, s7, a3
  remu         zero, s11, a4
  csrrsi       s8, 0xf14, 20
  nop  # BSDCOV_PREFIX_REPLACED_LABEL_REF
  c.mv         t2, a3
  sub          s7, a6, s11
  addi         a7, a7, -797
  c.sub        s1, a5
  csrrsi       s11, 0x3a3, 0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  slli         s3, s6, 28
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  xori         a0, s7, 858
  c.addi4spn   a3, sp, 672
  sra          s7, s6, s2
  c.xor        a1, a5
  c.xor        a0, a4
  mulh         s7, s8, s0
  c.and        a2, a5
  mulhu        s1, s5, a2
  nop
  slli         s8, s9, 10
  xor          gp, s8, t2
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  addi         s10, t1, -457
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.mv         a2, s7
  or           s5, a5, t4
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  auipc        a0, 838869
  sll          s3, a5, zero
  nop  # BSDCOV_PREFIX_REPLACED_LABEL_REF
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mulhsu       s8, s3, s7
  xor          t4, s0, a5
  slli         a1, a4, 18
  addi         a5, a5, -44
  c.mv         a0, t6
  sw           s0, 4(a5)
  srli         s8, tp, 25
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  srli         t1, a2, 0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  srl          t1, s10, gp
  add          s5, s10, s2
  add          s6, s11, s5
  xor          s1, a6, s1
  mulhu        a0, sp, s5
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  xor          a0, s8, a4
  remu         s10, t5, ra
  c.add        a1, s10
  xor          t4, sp, t1
  srli         t4, a7, 31
  addi         s7, s4, 1336
  sub          s3, sp, sp
  c.mv         t5, a5
  srli         t3, t4, 1
  mulh         s11, s4, t6
  c.srli       a2, 1
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  ori          tp, s8, 1821
  add          a1, s4, gp
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  add          a0, s10, gp
  c.srai       a3, 8
  c.and        a1, s1
  slli         s6, a5, 2
  remu         t3, s0, sp
  csrrci       a1, 0xb83, 0
  slti         s6, a3, 1276
  srai         a2, a4, 2
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  slli         zero, t5, 2
  c.xor        a3, a1
  srl          ra, s4, s5
  srli         a0, zero, 14
  csrrs        zero, 0x304, zero
  c.addi       s7, -1
  sra          s5, s5, gp
  c.lui        s7, 11
  xor          gp, s3, t2
  c.or         s1, a0
  c.sub        a2, s0
  andi         s5, a3, -1932
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  slli         s11, s1, 12
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.mv         a3, a6
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sra          s6, a0, s9
  slli         a2, a2, 29
  srli         s7, s4, 5
  add          t4, a0, a3
  c.add        a6, t4
  addi         s11, s2, 1959
  c.slli       t6, 19
  c.nop
  srli         ra, zero, 30
  and          ra, a1, s10
  mulhu        zero, tp, s10
  xori         t6, s1, 1675
  srai         a2, a3, 6
  csrrsi       s3, 0xb8b, 0
  divu         s4, a5, t2
  c.addi4spn   a2, sp, 912
  sll          zero, t4, a4
  c.xor        a1, a0
  div          s4, a5, s10
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.addi16sp   sp, 224
  mul          gp, t3, s0
  c.xor        a3, s1
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  rem          a0, t6, s11
  c.add        s0, ra
  mulhsu       t2, tp, s9
  auipc        a1, 335067
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.nop
  divu         ra, a5, s8
  rem          s4, sp, s11
  c.xor        a1, a5
  lui          s8, 670035
  and          s10, t5, s1
  csrrs        t6, 0x32a, zero
  or           s3, t3, t2
  c.slli       t4, 2
  c.nop
  nop
  c.li         s6, -1
  csrrs        t6, 0x3a1, zero
  srl          s2, s11, a3
  sub          t5, a6, a2
  srai         a1, a1, 16
  or           t0, zero, s0
  c.srai       a2, 11
  c.slli       s1, 6
  csrrsi       t6, 0x3b5, 0
  mulhsu       a7, s11, s8
  csrrs        s5, 0x3ba, zero
  srl          zero, tp, a2
  csrrw        t2, 0x341, a3
  csrrs        s7, 0x3b7, zero
  srli         s1, t3, 1
  c.slli       s7, 3
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.addi4spn   s1, sp, 240
  sltu         s5, s8, a5
  c.srai       a3, 22
  csrrw        a7, 0x310, s11
  srai         s11, t4, 24
  remu         s10, zero, s0
  and          a3, s5, t5
  mulh         s5, s9, a7
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  srli         t0, s7, 7
  nop
  addi         t3, s6, -496
  srl          s3, gp, s8
  and          a1, t5, a7
  and          t4, s8, s4
  sub          s5, t0, s2
  c.srai       a1, 12
  c.andi       a0, -1
  divu         sp, s5, gp
  csrrwi       tp, 0x340, 3
  c.srli       s1, 23
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mulh         tp, s11, ra
  slt          t6, s3, zero
  or           a3, s4, a4
  divu         s4, s3, a3
  mulh         s4, tp, s5
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.mv         t6, t6
  remu         s1, a5, a4
  ori          t5, t0, 1399
  div          gp, t5, s6
  andi         t2, s2, 53
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sra          s8, t5, s10
  sltu         s7, gp, t3
  add          s8, a0, t6
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mulhu        zero, s10, s4
  csrrsi       sp, 0x342, 0
  sltu         s11, t0, t6
  c.li         a0, -1
  c.lui        a3, 14
  rem          s2, a7, s9
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  srl          s11, s3, a2
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mulhu        s10, a0, a2
  c.mv         t5, a3
  mulhu        a0, a3, gp
  rem          s7, a0, a0
  sltiu        t6, t6, 1606
  add          t6, a0, t0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.sub        a3, a2
  ori          t3, s4, 582
  c.mv         s7, s0
  lui          sp, 259886
  sll          t6, s4, s6
  remu         a0, t1, t4
  lui          t5, 91799
  slti         a2, t2, 1292
  slli         s4, t4, 30
  c.and        a2, s1
  div          s4, a6, s5
  divu         a6, s0, t6
  csrrsi       s4, 0xb87, 30
  add          t6, ra, t6
  and          t0, s1, t0
  ori          a7, s0, 1176
  c.li         tp, -1
  csrrw        t1, 0xb87, zero
  divu         tp, s11, t5
  sub          a7, t2, a2
  auipc        a2, 834996
  mulhsu       ra, s5, t1
  add          s11, gp, a2
  div          a6, a7, a3
  sltu         gp, t4, a6
  mulhu        a3, t6, a3
  auipc        s3, 370472
  c.slli       sp, 4
  sltiu        a6, sp, 1149
  c.add        a2, t0
  c.or         a2, a0
  add          a6, a7, t2
  xori         s10, a3, -234
  c.and        a1, a5
  slti         a7, s0, 157
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.and        a3, a2
  c.nop
  c.sub        a2, s0
  auipc        a1, 600188
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  slli         t0, t2, 4
  rem          s1, s6, a1
  csrrci       t0, 0x341, 0
  c.xor        a1, s1
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mulhu        t1, s9, a6
  c.sub        a3, a4
  c.srai       a1, 19
  mulhu        s4, s3, a1
  srai         s6, s3, 8
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  srl          sp, a5, a2
  slti         a2, t0, 714
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  slli         sp, t4, 2
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  srl          t2, s9, s11
  csrrci       s0, 0x3b3, 0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrw        a6, 0x342, s4
  mulhu        a3, zero, a3
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.srli       a3, 6
  addi         s4, a0, 1563
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.mv         s11, sp
  xor          t5, a2, a5
  remu         s1, s7, a4
  addi         t4, a2, 682
  and          t2, a6, a6
  c.add        sp, a7
  c.srai       a3, 14
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.lui        a1, 14
  srai         s3, a7, 21
  csrrwi       a7, 0x341, 19
  csrrci       t5, 0xb07, 17
  addi         ra, t6, -1324
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.sub        s1, a0
  div          a6, a6, s5
  divu         a1, sp, t6
  sll          t4, a5, s4
  c.xor        s1, a4
  c.add        t6, s0
  c.xor        s0, s1
  andi         s1, s0, 1198
  c.nop
  slli         t5, s2, 18
  csrrwi       t3, 0xb03, 6
  slti         a3, zero, 623
  and          s1, s4, s9
  addi         ra, a2, 605
  c.addi       gp, 21
  remu         ra, t0, t2
  and          a1, s6, t4
  ori          t5, t3, -662
  csrrc        t6, 0xb06, zero
  divu         t5, a1, s5
  csrrw        a2, 0xb03, s11
  c.addi       gp, -1
  c.andi       a1, 16
  c.and        s0, a1
  srl          a1, a1, s0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  srl          a3, t5, tp
  andi         t4, t6, 895
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.addi4spn   s1, sp, 48
  and          s8, a7, t4
  sll          ra, s10, t6
  c.and        s0, a0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrsi       s3, 0x342, 0
  sub          a3, a3, t4
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mulhsu       a2, a7, s5
  c.lui        s10, 2
  remu         zero, s3, t3
  auipc        a2, 808034
  c.nop
  c.addi16sp   sp, 112
  c.lui        a1, 9
  xori         a0, t3, 170
  sub          t0, t0, s2
  c.sub        s0, s0
  csrrw        s11, 0xf11, s4
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sltu         t0, ra, t3
  c.andi       s0, 4
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrsi       s6, 0x7a3, 0
  mulh         s7, s0, t6
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  div          a2, ra, t1
  add          t3, s4, zero
  c.lui        a1, 15
  sll          s2, t1, a0
  csrrsi       ra, 0xb8c, 0
  c.or         a3, a2
  c.addi       s8, 20
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  and          s3, t3, t2
  lui          s6, 68181
  xor          s6, a1, a5
  csrrc        t2, 0x7b0, zero
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.or         a1, a5
  or           t6, s6, s4
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.srai       s1, 1
  c.nop
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  slli         s4, s2, 14
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrc        t2, 0x7a0, zero
  c.and        a2, s0
  sltiu        t5, t0, -72
  c.slli       ra, 30
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.lui        a6, 10
  mul          s4, t6, s8
  mulh         zero, s6, a7
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  add          zero, t2, s10
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  auipc        s2, 804953
  csrrsi       s8, 0x343, 0
  sltu         t0, s6, s10
  srli         t0, s0, 31
  mulhsu       t3, s4, s8
  c.and        s1, a3
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  rem          t2, a5, t1
  mulhu        s6, s8, s10
  csrrwi       s11, 0x329, 21
  lui          s2, 483203
  c.and        a1, a2
  srli         t2, t6, 23
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mul          s3, t3, a6
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.add        tp, t4
  sll          a0, t6, tp
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.srli       a1, 13
  addi         s4, t6, -302
  rem          sp, t0, t1
  and          s1, s2, s8
  c.mv         tp, t3
  nop
  c.and        s1, a0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.and        a1, a5
  c.and        a3, a1
  srli         a7, t5, 14
  c.addi4spn   a3, sp, 496
  c.or         s0, a0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  auipc        s11, 405058
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.addi16sp   sp, -16
  c.xor        a2, a3
  sll          a6, a2, s1
  c.addi4spn   a2, sp, 592
  c.srai       a2, 8
  c.addi       s4, -1
  csrrs        s5, 0xb0a, zero
  c.srli       a1, 4
  remu         a1, zero, s2
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  srai         t3, t4, 23
  slti         a6, s4, 1158
  xori         tp, t5, 397
  c.and        a0, a3
  slli         s8, t4, 2
  divu         s5, a2, s9
  sub          t3, s4, s2
  sltiu        t2, a7, 810
  csrrc        t2, 0x342, t1
  c.li         s4, 29
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  slli         t2, s4, 14
  sll          tp, a1, s7
  xori         gp, a1, 1891
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  srl          t5, t3, t0
  c.addi4spn   a0, sp, 208
  div          a2, a0, s7
  remu         t4, t2, a7
  sll          a1, a4, t6
  c.lui        tp, 28
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  srl          a0, s4, t0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.addi16sp   sp, -16
  xor          ra, sp, s9
  c.slli       a2, 25
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sll          s5, s2, t1
  mul          s5, t6, s0
  mulh         a0, s9, t2
  auipc        t2, 581506
  c.mv         t4, s0
  rem          t1, s0, a2
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sltiu        t1, t2, 1044
  and          t6, a5, s6
  csrrs        s10, 0x7b1, zero
  csrrw        sp, 0xf13, t1
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.andi       s1, -1
  c.mv         t0, s3
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  add          t5, a6, s4
  c.xor        a1, a3
  c.add        a7, t1
  mulh         s5, s8, s4
  c.add        a1, s10
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrs        zero, 0x7b3, zero
  c.slli       s5, 13
  c.li         gp, 10
  csrrsi       s4, 0xb83, 0
  csrrs        ra, 0xf13, zero
  addi         t5, t1, -134
  csrrsi       a2, 0xb88, 0
  csrrw        sp, 0xb08, zero
  divu         t2, t6, s6
  c.addi16sp   sp, -16
  csrrsi       s6, 0x7a1, 0
  add          s3, a7, a4
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mulhu        s10, s0, a7
  remu         s1, a0, a3
  csrrsi       tp, 0x3bb, 0
  nop
  mulhsu       s4, gp, gp
  or           s10, s4, s7
  c.sub        a3, a1
  addi         a2, s1, -1291
  sub          s8, a4, a5
  sra          t1, s6, a1
  add          t1, a2, t2
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  div          s8, s6, s5
  c.addi       t3, -1
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sltiu        s2, s11, 1745
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sltiu        a7, t6, -911
  lui          a0, 870513
  div          a2, sp, s9
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  slt          zero, s5, a7
  add          t3, a7, t4
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mulhu        t1, t0, t2
  sltiu        s0, zero, -737
  sltu         a7, s8, t6
  c.addi16sp   sp, -16
  auipc        s11, 780152
  csrrw        tp, 0x323, t1
  c.addi4spn   a3, sp, 960
  sltu         a7, t3, t5
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  rem          t5, s11, s10
  sub          sp, sp, s10
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrc        s3, 0x328, tp
  slti         s4, s8, -1925
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  auipc        a7, 369474
  csrrw        s10, 0x326, s6
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.addi4spn   a0, sp, 128
  remu         t6, a1, s0
  c.slli       s11, 3
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  remu         s7, a5, s4
  srl          s11, s7, t0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sll          a0, a0, a4
  c.addi16sp   sp, -16
  csrrs        a3, 0xb03, zero
  c.mv         s1, t3
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrwi       tp, 0x7c0, 0
  mulhsu       s8, s4, a7
  nop
  slt          t4, tp, t1
  sll          a2, a5, s9
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  auipc        a3, 256557
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  andi         s2, s4, -1495
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.li         s2, 20
  csrrw        s7, 0x343, s2
  csrrw        a2, 0x343, t1
  xori         a1, t1, 1285
  c.andi       a2, -1
  c.srai       a1, 16
  c.and        a1, a3
  c.li         t6, -1
  addi         s4, ra, -2011
  and          s4, a0, s4
  sltiu        tp, t0, 1959
  sra          gp, s9, t0
  csrrs        a0, 0xf15, zero
  c.li         t3, -1
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrsi       s2, 0xb83, 0
  rem          s3, a4, s0
  csrrs        sp, 0xb8a, a0
  csrrs        s11, 0x3a0, zero
  c.srli       a2, 17
  c.srai       s0, 16
  c.srli       a1, 22
  srl          gp, s9, t3
  sltiu        s8, s4, 264
  c.nop
  sll          t2, t6, t0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  andi         a0, a0, -1176
  c.sub        s1, s0
  addi         s10, s4, -522
  c.sub        a0, a1
  c.addi16sp   sp, -16
  c.or         a1, a4
  c.addi16sp   sp, -16
  andi         t4, a1, -1339
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mulh         a3, a5, a2
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sll          t6, s8, a3
  c.sub        s0, a3
  andi         a6, t5, -510
  div          a1, t4, t1
  add          a1, s6, s5
  srai         t1, ra, 2
  sra          s0, gp, t0
  mulhu        s10, s5, a6
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  rem          t5, s5, a5
  c.nop
  c.or         a0, a4
  c.srli       a3, 10
  c.or         s0, a3
  nop
  c.addi16sp   sp, 480
  sltu         a3, ra, a3
  sltu         t4, a5, s4
  slti         a0, s9, 1207
  csrrwi       t2, 0x30a, 8
  csrrw        t5, 0xb06, t1
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mulh         a2, s2, s3
  auipc        t6, 711072
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.add        s4, s9
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  ori          t2, t3, 451
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  ori          a1, s10, -681
  slli         s7, a5, 17
  csrrc        s2, 0x3b9, zero
  sltu         a0, t2, t3
  srai         s1, gp, 20
  c.add        s11, s2
  sra          s4, sp, t2
  div          s7, s0, a6
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  srl          s5, s0, s7
  c.andi       a1, -1
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.xor        a3, s0
  slli         t2, zero, 14
  srai         gp, ra, 0
  csrrs        t2, 0x3bc, zero
  slli         t3, a6, 23
  mul          s8, s7, a6
  c.mv         tp, t1
  csrrwi       s0, 0x329, 13
  xori         a7, t2, 1321
  or           a3, s9, s3
  xori         t2, sp, 653
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  lui          s4, 727897
  sub          a3, s7, sp
  slt          a7, t1, t6
  csrrc        a7, 0xb87, a2
  mulhu        s8, a4, t2
  mul          s7, gp, a7
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  auipc        s0, 969011
  slti         s3, t5, -1253
  xor          s1, a5, s0
  ori          t2, s10, 1868
  c.andi       a0, 16
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrci       s4, 0x32b, 0
  or           sp, tp, s1
  lui          gp, 279525
  xor          t5, zero, s5
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  ori          s4, a5, 765
  c.xor        a3, s0
  mul          gp, a4, a5
  mulhu        t1, s4, a3
  slli         s2, a1, 21
  xori         ra, s0, -1784
  slli         s8, s1, 29
  divu         t6, t3, s11
  mulhu        s6, s3, t6
  csrrwi       s11, 0xb06, 14
  sltiu        t1, s9, -1593
  c.addi16sp   sp, -16
  csrrw        tp, 0xf12, s6
  c.slli       tp, 15
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrw        s4, 0x32a, t2
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.and        s1, s0
  mulh         s8, s9, a0
  srli         s4, t5, 1
  srai         t0, a0, 19
  c.xor        s0, a1
  csrrs        t6, 0x3b0, zero
  c.andi       s0, 22
  rem          t3, t0, zero
  sub          s0, s3, s9
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  slti         s3, s2, -1587
  and          s1, zero, s1
  mulhu        s6, ra, a3
  nop
  mulh         tp, s5, a0
  c.li         a2, 19
  andi         s7, s3, 2038
  c.and        a0, a0
  auipc        s7, 236452
  ori          zero, t0, 858
  xor          s7, a1, s7
  addi         t6, s8, 239
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mulh         ra, gp, tp
  c.andi       a2, 9
  sub          s11, s8, s8
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sra          s4, s7, t0
  srai         s4, s2, 7
  c.nop
  srli         s8, a2, 30
  c.or         s0, a4
  c.mv         s5, s3
  csrrc        t3, 0x7b3, zero
  xor          ra, t1, s1
  sra          sp, s5, t3
  and          t0, a2, t2
  add          s8, s3, t3
  csrrwi       t1, 0x7c1, 18
  csrrw        t2, 0xb84, s8
  csrrc        tp, 0xb05, zero
  srl          s10, s6, sp
  c.li         ra, -1
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  srai         s7, tp, 10
  c.slli       s11, 19
  csrrsi       gp, 0x305, 0
  ori          t1, s6, 1851
  sll          a7, t6, s0
  c.addi16sp   sp, 416
  mulhu        s7, a7, t0
  csrrw        zero, 0xb00, t5
  srl          a0, t0, s4
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.lui        a6, 25
  c.sub        s1, s1
  xori         s0, s5, -1709
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.xor        a1, a5
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  auipc        t6, 406063
  c.slli       t0, 2
  or           a0, s0, s7
  addi         sp, t6, -13
  c.sub        a3, a3
  and          a0, a6, t2
  c.nop
  or           s4, s8, s9
  c.slli       a1, 15
  sltu         s5, s9, sp
  c.slli       s3, 8
  and          s8, a3, s9
  nop
  c.slli       s8, 9
  addi         t0, a6, -1149
  c.add        s2, a0
  add          s2, s7, s2
  divu         zero, a6, a5
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.srli       s1, 2
  c.lui        s3, 21
  srli         gp, gp, 21
  c.sub        a0, a5
  slli         s11, s8, 5
  c.mv         t6, t3
  c.lui        s2, 2
  lui          t2, 51214
  sltu         s3, zero, s2
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.addi       s7, -1
  nop
  rem          s2, ra, t6
  slli         a3, s8, 17
  and          t4, tp, gp
  c.addi16sp   sp, 224
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.srli       a1, 28
  lui          a1, 730720
  srl          a0, s3, a2
  c.nop
  or           s5, s3, a3
  slli         s10, s2, 31
  c.addi       t1, 8
  srli         s1, a3, 28
  c.addi4spn   a3, sp, 304
  slti         s5, t6, -379
  mulhsu       s4, s6, s10
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mulhsu       a3, t5, a1
  nop
  c.xor        s1, s0
  c.or         a3, a5
  add          s8, s6, a6
  sltu         s6, t6, s8
  and          gp, s11, t2
  srai         t4, a3, 25
  remu         t2, s1, gp
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.and        s0, a3
  div          t4, s11, a0
  mulhsu       t2, a7, zero
  sub          a7, s3, zero
  c.srai       a2, 16
  ori          a6, s0, 1366
  slli         t4, s8, 30
  c.srai       a3, 25
  div          a7, s5, t3
  csrrc        sp, 0x7a0, zero
  c.addi16sp   sp, 336
  rem          s11, s4, t2
  div          ra, zero, zero
  auipc        s10, 460090
  c.mv         gp, tp
  c.nop
  c.srli       a2, 31
  c.and        a2, a4
  c.li         t1, 14
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  and          s4, s2, s6
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.xor        s1, a3
  c.slli       s3, 5
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  div          a3, a5, gp
  csrrw        t6, 0xb07, a3
  srl          a2, a7, s8
  csrrs        s2, 0x32b, zero
  c.nop
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.srli       s1, 28
  add          a1, a2, a3
  divu         t3, s7, s10
  slt          s7, a3, gp
  sltiu        t5, a3, -615
  srli         a7, t5, 9
  c.lui        a2, 7
  c.sub        a2, a1
  c.li         a6, -1
  rem          s10, zero, s6
  mulhu        tp, s8, t5
  c.srai       s1, 18
  c.srli       a1, 8
  slti         a3, s0, -1859
  mul          t6, s6, t2
  div          t1, t5, t2
  lui          a1, 414594
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mulh         s7, a2, a4
  c.sub        a3, s1
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  divu         t3, t1, t4
  addi         a6, a2, -1240
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mulhu        t5, s4, a4
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.addi4spn   a3, sp, 912
  c.addi4spn   a1, sp, 128
  srai         s11, t5, 21
  csrrw        s6, 0x323, s7
  c.add        s8, t3
  slt          gp, s11, a6
  c.addi16sp   sp, 368
  mulhu        t1, t4, gp
  div          a7, s10, s2
  andi         a1, s10, -1559
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.li         s10, -1
  srli         a0, tp, 9
  mul          a1, t0, s4
  csrrsi       s3, 0x301, 0
  auipc        sp, 183423
  c.addi4spn   a1, sp, 928
  mulh         s0, s2, s3
  andi         s10, a6, -769
  slti         s11, s11, 854
  div          t5, a7, t5
  mulh         s8, t3, s0
  slt          sp, t0, s6
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  andi         s1, s3, 82
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  auipc        t3, 534386
  csrrw        t4, 0xb84, s7
  xor          s0, s8, a0
  c.add        s6, s7
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  andi         t2, s4, 1255
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrs        t1, 0x3b1, zero
  sra          t2, zero, s9
  csrrw        a3, 0xb84, sp
  lui          t0, 893778
  xori         s11, s1, -1724
  c.xor        a0, a2
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  lui          a1, 749154
  sll          ra, s6, s11
  csrrs        t2, 0x3b2, zero
  csrrc        t3, 0x3ba, zero
  andi         s4, t2, 1200
  mul          t4, s10, t1
  c.mv         ra, s1
  sra          zero, s4, a1
  c.addi       a3, 7
  sra          t6, s5, ra
  c.mv         t1, s4
  c.addi4spn   a3, sp, 688
  and          a2, s6, s2
  srai         sp, zero, 25
  csrrwi       t3, 0xb09, 18
  remu         a2, s8, s10
  add          ra, a2, s11
  or           ra, t3, t1
  or           tp, s7, s1
  add          a3, t4, a5
  c.li         s5, -1
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.mv         t0, a2
  srl          s11, a7, ra
  nop
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.srai       s0, 10
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrci       t3, 0xb84, 0
  srl          s7, t5, a2
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.xor        a3, a0
  sltiu        t3, a4, -72
  sll          a7, s7, s6
  srl          s2, a5, t5
  xor          tp, t5, s8
  c.slli       t5, 10
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sub          zero, a1, t0
  ori          a0, s11, -757
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sra          a3, ra, s10
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mulh         gp, t1, s4
  lui          t1, 337276
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.nop
  csrrw        a6, 0xb05, s0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop
  csrrw        t3, 0x328, sp
  csrrsi       t3, 0x3a0, 0
  c.li         s10, -1
  c.lui        a6, 26
  ori          s7, s8, -1955
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mulh         t5, s2, s0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  addi         sp, s6, -1129
  c.sub        a2, a0
  csrrsi       a3, 0xb00, 7
  and          s4, a7, s8
  c.slli       t3, 26
  srli         a2, a2, 23
  csrrc        a7, 0x30a, zero
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  xori         ra, s2, -136
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sra          s0, zero, s9
  c.andi       a1, 16
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  divu         s0, s11, ra
  add          a1, s0, t6
  slli         tp, s7, 11
  csrrsi       t5, 0x301, 0
  c.srai       a3, 11
  ori          t1, a6, -274
  slli         s1, t1, 26
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  and          a7, s1, s0
  c.nop
  sub          tp, s6, a4
  and          t2, t5, s2
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  addi         t3, s10, 1514
  sll          a1, a0, s8
  sltu         s1, a5, a0
  mulh         a1, s4, a5
  add          a7, gp, s9
  csrrsi       t1, 0x3bc, 0
  c.nop
  csrrs        s6, 0xb04, s9
  auipc        a7, 107810
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.li         s2, 2
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sub          a2, a5, t3
  xor          s2, a2, s0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mul          gp, a5, s3
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  lui          s3, 78005
  mulh         t3, t4, s3
  c.xor        s1, a4
  slli         s0, a1, 25
  csrrc        s2, 0x7b2, zero
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  addi         t3, a2, -672
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mul          t0, s11, t5
  nop
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.mv         a0, t0
  c.addi16sp   sp, 128
  c.add        s8, a0
  c.addi16sp   sp, 208
  mulhu        t5, zero, s5
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.srli       a0, 18
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  add          t4, a3, s7
  xori         a6, a3, 947
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  and          t3, s1, s3
  mul          gp, s9, a2
  csrrci       s0, 0xb09, 0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  and          tp, t5, t6
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.xor        a3, a3
  ori          a1, t1, 1700
  mulhsu       s3, s5, t3
  csrrw        t1, 0xb04, t3
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.addi4spn   a1, sp, 944
  c.addi4spn   a3, sp, 48
  srl          s2, a0, tp
  nop
  slt          t3, a7, t3
  c.addi16sp   sp, 256
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mul          ra, a5, s11
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  srli         s11, t0, 8
  c.slli       s6, 19
  c.sub        s1, a2
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.addi       gp, -1
  c.lui        s1, 22
  div          s11, t5, tp
  div          ra, a3, a7
  ori          gp, s0, 1955
  c.srai       a1, 18
  c.addi16sp   sp, -16
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sltu         ra, s11, s5
  divu         sp, ra, a4
  and          a2, s2, a2
  srai         a2, a0, 18
  csrrc        s10, 0x30a, zero
  slli         t6, a4, 25
  divu         t5, a7, s4
  add          gp, a6, a3
  sll          s7, a3, s0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.srai       s0, 25
  div          t3, s5, s6
  sll          zero, s11, s7
  auipc        gp, 595578
  csrrsi       tp, 0x327, 0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sltu         t5, gp, ra
  c.li         a6, -1
  sll          s3, a4, a3
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.or         a0, a0
  c.or         a2, s0
  c.xor        a0, a5
  c.srli       a3, 8
  c.addi16sp   sp, 464
  csrrsi       t1, 0x3bf, 0
  ori          s7, ra, -805
  c.srli       a1, 3
  divu         ra, s1, s8
  srl          s6, a0, t2
  csrrc        s8, 0x328, zero
  c.addi       s6, 1
  auipc        s7, 350552
  andi         s1, sp, -1249
  sltiu        s0, a1, -475
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sub          s0, a5, s9
  addi         ra, s2, 798
  srai         t4, s9, 2
  ori          s2, s1, 1712
  c.lui        s11, 28
  csrrwi       s11, 0xf15, 17
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.addi       a0, -1
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.li         s8, -1
  and          t5, a5, s9
  srli         a7, a0, 26
  add          a7, s11, t3
  c.li         s6, -1
  srl          s1, a1, t5
  remu         t5, a5, t3
  c.lui        s11, 30
  c.addi16sp   sp, 496
  c.sub        s1, a1
  or           t0, ra, s3
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sll          s10, a0, a7
  addi         s11, t6, -851
  c.and        a0, a2
  and          t2, s6, t6
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mul          zero, a4, a7
  csrrs        s6, 0x747, zero
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  lui          t3, 280086
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  remu         t6, s10, gp
  slt          a7, t1, a2
  mulh         a0, a1, t3
  c.lui        a1, 22
  c.or         a3, s1
  csrrc        t0, 0x32c, zero
  sub          s1, s11, tp
  rem          t3, s8, a1
  sub          t2, gp, t1
  csrrsi       s10, 0x3b4, 0
  csrrw        s6, 0xb08, a7
  c.addi4spn   a3, sp, 784
  srai         s8, s1, 12
  mulhu        a6, s1, t5
  c.nop
  sll          s10, tp, s3
  sub          s2, a6, s6
  csrrsi       s0, 0xb00, 0
  c.andi       s1, 20
  mulh         s1, a2, a6
  c.addi16sp   sp, -16
  slt          s6, s4, a6
  andi         s8, s9, -1262
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.slli       ra, 20
  c.addi4spn   a1, sp, 368
  addi         s1, t1, -682
  divu         s6, t4, t0
  divu         ra, t4, a7
  div          s10, t6, s6
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.andi       s0, 6
  c.srai       a2, 27
  srai         zero, tp, 31
  c.mv         gp, a0
  csrrc        t4, 0xb0a, zero
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mulhsu       t0, s11, t1
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  slli         t4, t0, 5
  mulhsu       t6, s2, ra
  c.addi4spn   a0, sp, 944
  slt          a2, a6, s2
  c.srli       s1, 9
  andi         s2, ra, -836
  csrrc        t3, 0x300, zero
  sltiu        a2, a1, -637
  csrrc        a2, 0xb07, zero
  lui          t6, 217583
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrsi       t5, 0xb83, 13
  sltiu        a7, a7, -858
  c.li         s4, 14
  c.srli       a3, 12
  xori         t5, s0, 1649
  c.sub        a1, a3
  rem          tp, s5, t5
  c.sub        s1, s1
  lui          s1, 1026245
  c.addi4spn   a1, sp, 144
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  ori          a3, a0, 1423
  slt          sp, t6, sp
  sll          t3, t2, a4
  c.srli       a0, 16
  slti         s0, a6, -1978
  csrrs        s11, 0x323, zero
  addi         s6, a6, -1623
  c.add        sp, a5
  c.or         a2, s0
  remu         gp, t3, s8
  or           s6, s3, t5
  csrrs        s4, 0xb8c, zero
  c.or         s1, a0
  rem          sp, s7, t2
  c.nop
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop
  sltu         s6, t0, s2
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  and          a0, s9, s8
  c.and        s1, a2
  c.addi16sp   sp, 416
  addi         s10, t4, -1875
  srai         a6, a4, 13
  rem          a6, s11, s2
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrwi       tp, 0xb88, 5
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.addi       s0, -1
  addi         a2, t0, -357
  c.add        t6, t2
  mulhu        t2, s0, t3
  c.mv         a2, a5
  addi         t3, zero, -2
  c.slli       s11, 19
  sra          t2, a5, s7
  csrrsi       s0, 0x7b1, 0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mulhu        t3, a6, t2
  mul          s11, s7, ra
  c.nop
  slli         s0, s10, 14
  sltu         s6, s7, a3
  csrrw        s7, 0xb0a, a6
  andi         t6, ra, -787
  and          s10, a5, s6
  srai         s11, s8, 21
  auipc        s11, 586605
  csrrwi       s10, 0xb84, 10
  c.srli       a2, 6
  c.or         a2, a0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  andi         s0, a2, 1333
  c.mv         gp, sp
  csrrwi       s0, 0x327, 25
  and          gp, gp, s7
  c.addi4spn   s0, sp, 608
  div          a7, t0, a5
  sra          gp, zero, s3
  nop
  c.sub        a3, s1
  or           s6, s2, s7
  c.nop
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sltu         s8, zero, s2
  srai         t2, s1, 24
  ori          gp, s2, 1750
  c.andi       a3, 29
  ori          ra, s0, -790
  rem          s7, gp, a7
  slt          s2, s6, sp
  csrrci       s5, 0x324, 1
  lui          t4, 447196
  csrrci       s2, 0x747, 0
  csrrs        t1, 0x3b2, zero
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrw        a3, 0x343, s8
  c.slli       t0, 17
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  auipc        ra, 96853
  and          s0, t1, a6
  sra          t4, s7, t0
  srl          t1, s7, sp
  c.nop
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrwi       a0, 0x7c1, 5
  xor          t0, t4, t3
  sra          s10, a1, t4
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mulhsu       ra, sp, s6
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.addi4spn   a3, sp, 832
  sltiu        sp, s4, 1434
  remu         a7, s3, t6
  srli         t3, a2, 28
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  slt          s10, a4, s10
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sltiu        ra, t4, -899
  srli         tp, a0, 29
  c.sub        a1, a2
  mulhsu       a2, s0, s4
  sltiu        t1, s0, 405
  slti         t2, a5, -1765
  c.or         s1, s0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrw        a7, 0x341, s2
  sltu         s3, a1, s9
  rem          s5, s3, a1
  c.slli       s1, 4
  csrrci       s8, 0x3b1, 0
  lw           s0, 4(a5)
  sra          gp, s6, a4
  addi         t1, s7, -598
  c.srai       a3, 28
  addi         a5, a5, 44
  div          s1, a7, t4
  addi x11, x8, 1
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  addi         s11, t4, -1769
  addi         a5, a5, -48
  slti         a0, s3, 1157
  c.and        a3, s0
  sw           s0, 4(a5)
  c.srai       a1, 21
  c.and        a0, a3
  csrrw        ra, 0x326, t5
  slli         s8, t6, 18
  or           tp, s7, s8
  srl          s1, a6, a2
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrci       a6, 0xf15, 22
  c.srai       a0, 21
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  lui          t1, 669789
  c.xor        a3, s0
  auipc        s4, 354749
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  add          a3, s3, t4
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.mv         s7, s2
  ori          t0, s4, -134
  rem          tp, a5, s1
  c.or         a1, s0
  sub          s1, s4, s11
  c.or         a0, a0
  and          s0, zero, s3
  sra          t0, a4, t1
  ori          zero, s0, 1176
  mulh         a7, gp, s0
  rem          t5, a6, tp
  mulhsu       a3, sp, s11
  csrrsi       s7, 0xb8a, 31
  c.addi16sp   sp, -16
  c.xor        a1, a1
  andi         gp, a4, 1790
  c.andi       a2, -1
  c.addi16sp   sp, -16
  sub          t4, s0, s5
  mulhsu       gp, s10, s10
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  remu         s8, a7, a4
  auipc        a1, 516315
  slt          s10, a0, s10
  slli         s5, t4, 1
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mulhsu       t2, t5, s10
  c.slli       s3, 9
  sltiu        sp, zero, 1174
  add          t3, a1, a7
  c.srai       a1, 2
  c.srai       s0, 12
  xor          s2, s11, a6
  c.srai       s1, 3
  sltiu        t6, zero, -232
  slli         t0, s1, 31
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.addi       s5, -1
  slli         t1, s2, 5
  or           s6, t4, a4
  mulh         zero, a7, a5
  nop
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop
  slli         s8, ra, 5
  c.mv         s11, s0
  mulh         t5, tp, t1
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sra          s8, ra, s10
  or           t3, t1, t5
  and          s10, s6, s6
  slt          s3, t3, s4
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  slt          s7, t3, a7
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mul          t0, s6, t0
  c.add        t1, a0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mulhsu       sp, a2, sp
  sltiu        a3, s11, 1823
  sra          s1, s5, s8
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.addi4spn   s0, sp, 928
  add          s5, sp, ra
  sltiu        s6, s6, -1519
  ori          s3, a2, 672
  csrrci       a1, 0x328, 23
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.li         s3, -1
  mulhsu       a0, t2, ra
  nop
  mulh         sp, t5, s7
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mul          t1, a0, a4
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  srli         a2, a6, 23
  csrrci       gp, 0x3b2, 0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.lui        t2, 21
  csrrw        s5, 0xf15, a0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.addi16sp   sp, -16
  c.sub        a1, a1
  divu         gp, a5, a6
  c.or         a0, a5
  c.lui        s4, 8
  srl          a1, sp, a5
  rem          s2, s4, a5
  c.andi       a0, 30
  slt          a1, s10, s9
  sltiu        t6, s7, 665
  mulh         s4, s10, a4
  slt          t3, a5, t0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  andi         s4, t1, -152
  c.slli       t1, 16
  or           a2, s8, s5
  sltu         s0, a4, gp
  c.addi4spn   a3, sp, 64
  add          a0, a4, s5
  rem          s6, t6, a2
  c.add        a2, s9
  csrrsi       t4, 0x7a1, 0
  srai         s10, t5, 31
  c.li         s0, 20
  sub          s10, a1, t0
  div          gp, s3, gp
  divu         a1, a0, a7
  xori         a7, s1, -281
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sltiu        sp, a0, 528
  divu         t1, a3, t5
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.addi       t3, 21
  xori         t6, a7, 1614
  srl          a1, gp, a6
  sra          s11, a5, a2
  sra          s4, zero, a5
  add          a7, a7, tp
  sub          s0, s0, s9
  c.and        s0, a2
  c.nop
  c.addi       a7, 10
  and          t5, s9, t4
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  divu         s10, a1, a5
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.nop
  mul          t6, tp, s5
  divu         s0, tp, zero
  c.xor        a0, a2
  c.nop
  sltu         t6, zero, tp
  csrrc        s4, 0x341, zero
  auipc        s11, 336030
  lui          zero, 188279
  c.srai       s1, 9
  csrrci       t5, 0xb86, 0
  c.li         t6, 7
  sub          a2, a1, t1
  ori          t1, t6, -1540
  addi         s6, t2, -1757
  sltu         ra, s2, s6
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sub          t2, a1, s4
  sltu         a7, t5, s10
  c.addi4spn   a1, sp, 624
  c.or         a2, a3
  divu         a1, zero, t2
  slli         s7, t6, 20
  nop
  auipc        gp, 178076
  auipc        s7, 465816
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sltu         sp, t2, s9
  csrrs        a0, 0x7a2, zero
  remu         zero, s10, s3
  c.sub        a2, a5
  sll          s1, s8, t2
  c.srai       a0, 20
  remu         a0, s5, gp
  c.srai       a0, 21
  divu         s8, a0, s10
  add          s5, t6, s9
  c.srai       a0, 16
  csrrw        s6, 0xb89, sp
  mul          s10, sp, a7
  c.and        a3, a5
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  xori         t1, a4, 1151
  c.and        s0, a1
  xor          s0, a3, t1
  c.li         a3, -1
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  andi         a7, t4, -658
  csrrc        t5, 0xb0b, zero
  csrrsi       s6, 0x7b3, 0
  mulh         a2, sp, tp
  slli         s11, t2, 31
  remu         zero, s0, a6
  c.lui        a0, 6
  c.srli       s1, 26
  xori         a7, s1, -297
  srl          t4, s1, a5
  srl          a2, t3, a0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.addi16sp   sp, -16
  mulhsu       zero, s6, a7
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop
  c.nop
  srli         ra, tp, 25
  c.add        t6, gp
  mulhsu       t5, a5, t4
  csrrsi       s4, 0x328, 0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  slti         gp, t5, 433
  csrrs        t3, 0x320, zero
  csrrsi       s2, 0x7b0, 0
  sll          t1, s2, ra
  c.andi       s0, 0
  lui          gp, 248343
  sub          t6, s1, ra
  nop
  slt          s5, gp, a2
  and          a7, s9, s11
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrc        t3, 0x310, s5
  andi         a2, a7, -546
  add          a7, s10, t0
  auipc        t0, 17286
  nop
  sll          a6, tp, t5
  addi         t2, t5, -1980
  c.nop
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.addi4spn   s0, sp, 704
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mul          t4, s2, s4
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  ori          a6, t3, -679
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrw        gp, 0xb85, tp
  divu         t5, a5, sp
  slli         s2, s9, 8
  div          s2, s9, s5
  andi         a1, t2, -1428
  mulhsu       a7, t5, t3
  c.xor        a3, a3
  or           a3, a5, a3
  mulhu        s4, a5, s7
  slti         a0, a6, 848
  slt          t1, s4, ra
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sltiu        t3, t2, 1890
  slli         s0, s8, 15
  divu         s4, s9, a1
  csrrci       sp, 0x328, 28
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.lui        s1, 29
  csrrsi       s3, 0x341, 0
  nop
  mulhu        a1, s3, zero
  srl          s3, a3, a2
  csrrwi       t3, 0xb89, 17
  div          s10, t3, s2
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.addi4spn   a0, sp, 736
  c.andi       a3, 17
  csrrci       a1, 0x325, 24
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrc        s10, 0xb0a, zero
  c.mv         t2, t4
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  div          a0, t4, zero
  c.xor        a3, a3
  c.andi       a1, -1
  mul          t3, a0, sp
  sub          t3, a2, s7
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mulhsu       s1, t2, s11
  c.li         ra, 19
  csrrc        s8, 0xb0c, zero
  c.addi       s3, 29
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sltiu        s5, a0, -937
  csrrwi       ra, 0x342, 9
  c.lui        s10, 20
  c.nop
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  slli         s11, a6, 6
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.srai       a1, 7
  nop
  mulhu        t6, sp, t3
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sra          s4, a1, zero
  xori         s4, t6, -2040
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.mv         t6, t1
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  add          t2, s1, s4
  remu         s11, a2, s10
  c.addi16sp   sp, -16
  c.xor        a0, s1
  c.addi       ra, -1
  addi         t1, t5, -524
  csrrw        s0, 0xf15, s10
  slti         a0, a0, -1087
  c.xor        a2, a5
  c.or         s0, a3
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mulhsu       tp, ra, s10
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sra          t4, s1, tp
  rem          s4, s11, a4
  c.srai       s1, 29
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  srl          s0, sp, s9
  csrrci       a2, 0x328, 0
  xori         t4, a6, -1485
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  srl          s1, s1, s1
  c.xor        a0, a1
  mul          a3, s9, t0
  c.andi       a3, 30
  srai         s7, t4, 26
  csrrs        a0, 0x32a, t5
  c.srli       a1, 26
  sltiu        sp, sp, -926
  c.addi16sp   sp, 416
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  auipc        s0, 535096
  div          s2, gp, s9
  sra          s4, tp, t6
  srl          a0, a4, s2
  c.and        a2, a1
  addi         sp, t2, 1991
  csrrw        t0, 0xb07, s2
  c.mv         ra, a0
  c.xor        a3, a0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  remu         tp, s7, s10
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sub          s6, a6, s5
  sltu         sp, t2, t5
  sltiu        s11, a6, -1400
  remu         s10, s4, s4
  and          zero, a5, s11
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sub          t5, a5, t2
  csrrc        s7, 0x7b1, zero
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sltu         s11, s2, ra
  lw           s0, 4(a5)
  addi         a5, a5, 48
  slti         s3, s0, -1615
  andi         a6, s7, -1859
  addi x22, x8, 1
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mulhu        s6, t3, t5
  sltu         a2, s5, t6
  addi         a5, a5, -60
  srai         t1, s5, 5
  slli         t0, s3, 2
  sra          t2, t6, t6
  sw           s0, 4(a5)
  srai         t5, a3, 14
  csrrwi       s7, 0xb08, 17
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  or           s0, s7, a3
  mulhu        s10, a7, a5
  divu         s10, gp, t5
  csrrw        ra, 0xb08, gp
  sltiu        t3, s0, 428
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrw        a0, 0x324, t6
  remu         s6, s1, t0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  remu         t6, a7, s2
  c.and        a0, a2
  addi         a6, a0, 1387
  c.or         s0, a2
  addi         a0, t0, -798
  add          a3, a5, t5
  remu         t2, s2, s0
  c.and        a1, s1
  c.xor        a0, a4
  csrrs        s4, 0x7b1, zero
  c.xor        a0, a4
  c.and        s1, s0
  c.andi       s0, 1
  remu         a1, s9, t4
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.srai       a0, 3
  auipc        a7, 565599
  sltiu        gp, a6, 1665
  csrrw        s4, 0x342, s11
  c.or         a2, s0
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  div          s7, s4, a2
  add          s5, s6, t5
  c.nop
  c.addi4spn   a2, sp, 832
  c.srli       a3, 29
  or           a2, t0, a2
  nop
  mulhsu       a7, s6, tp
  c.nop
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.or         a2, a0
  or           s1, a4, a6
  c.andi       a1, -1
  srai         a6, s6, 6
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  remu         s2, tp, a7
  slt          a3, s8, s9
  auipc        tp, 98255
  auipc        s3, 39651
  slti         t2, a1, -1110
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  or           sp, sp, tp
  c.addi       s8, 3
  mul          s5, t5, a4
  addi         t4, s9, 1586
  slti         gp, t4, -644
  andi         tp, zero, 463
  andi         s11, s6, -2030
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrs        sp, 0xf14, zero
  lui          t1, 524292
  csrrci       a6, 0x7a2, 0
  sltiu        t1, a3, 1853
  slt          a1, a6, s5
  c.slli       s3, 20
  csrrw        s10, 0x329, a2
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  srli         t0, a6, 30
  andi         a0, s3, 77
  xor          zero, s9, ra
  divu         s4, t3, s10
  mulhsu       sp, a0, t6
  sra          t1, a4, a6
  sll          gp, a7, s6
  nop
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  or           a3, s2, tp
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.slli       s11, 2
  mulhu        a0, a2, tp
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  rem          a2, a0, s5
  slli         a6, s11, 8
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrs        gp, 0x7a1, zero
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrw        s7, 0xb89, t0
  c.and        a2, a3
  add          s4, zero, zero
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sltu         a3, a0, gp
  c.srai       a3, 25
  c.srli       s0, 16
  xor          s4, s11, s7
  xori         a0, a5, -2038
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.nop
  c.or         a0, s1
  csrrc        zero, 0x300, zero
  csrrsi       s6, 0x7b2, 0
  c.srai       a1, 10
  csrrsi       t0, 0x310, 0
  csrrw        a7, 0xb8a, ra
  srai         a3, s5, 11
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sltiu        sp, a0, -179
  sra          a7, tp, zero
  c.and        s0, s0
  c.andi       a3, -1
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  slt          a6, a5, s2
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrs        a6, 0xb89, zero
  slli         a6, s2, 7
  c.addi16sp   sp, -16
  c.lui        t2, 30
  add          ra, a2, s3
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrwi       s7, 0xf11, 30
  srai         ra, s6, 25
  and          s8, t4, t0
  c.slli       t4, 28
  mulhsu       sp, a6, s10
  c.addi16sp   sp, -16
  csrrc        s0, 0x324, a5
  csrrci       ra, 0x3a2, 0
  c.addi16sp   sp, 240
  mulh         a6, s8, a4
  mul          s2, s2, s2
  nop
  mulhsu       t4, s1, a2
  mulhu        s2, s4, t2
  mulhu        t1, s2, t3
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mul          sp, t5, a6
  csrrwi       s5, 0xf13, 3
  nop
  slli         gp, s11, 21
  slti         s10, s4, -685
  sub          a3, s1, a3
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.nop
  sra          s10, s3, a1
  and          s0, a0, s4
  div          s4, a6, s10
  csrrci       a0, 0xb88, 0
  sra          s2, s11, s9
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  lui          s6, 1007630
  srli         t3, sp, 5
  addi         t6, t0, -989
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sra          s7, a6, t2
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sltu         s7, s0, t1
  csrrsi       t3, 0x3a1, 0
  nop
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  c.add        s1, a5
  c.srai       a3, 16
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  sltiu        s7, zero, -1365
  c.slli       a3, 3
  mulh         a7, s7, s6
  c.nop
  rem          s0, t1, s4
  c.sub        a1, s1
  addi         t2, a6, 1667
  csrrci       a2, 0xb05, 29
  and          a6, a3, s6
  csrrsi       s1, 0x3a1, 0
  andi         s6, t0, 640
  c.slli       t3, 23
  lw           s0, 4(a5)
  srl          s11, s9, t1
  addi         a5, a5, 60
  slli         s3, a3, 4
  c.addi       t0, -1
  auipc        s3, 210570
  c.add        s7, a2
  nop
  c.add        gp, s6
  sltu         s10, ra, t2
  addi x30, x8, 1
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mul          a1, s6, s4
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  addi         a5, a5, -56
  mulh         a2, t3, t2
  sw           s0, 4(a5)
  c.nop
  div          t1, a6, s3
  andi         s11, t2, -1448
  c.srai       a0, 3
  csrrw        zero, 0xf12, s11
  div          t3, gp, a1
  c.srli       a0, 26
  slti         sp, s5, 1764
  mulh         s4, a6, s5
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  csrrci       s1, 0x300, 0
  sub          t1, ra, a6
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  ori          s7, t5, -2031
  xor          zero, a2, t1
  c.addi       t5, 5
  remu         t0, gp, s6
  c.lui        t4, 11
  c.add        s2, gp
  xor          s1, s5, s10
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mulhu        sp, a2, t1
  andi         s3, t2, 380
  xor          s11, s11, s0
  c.or         a1, s0
  slt          tp, s10, s10
  nop  # BSDCOV_PREFIX_REPLACED_CONTROL_FLOW
  mulhu        t6, s7, t3
  c.addi16sp   sp, -16
  remu         s0, s3, s6
  # BSDCOV_PREFIX_END

  # Re-initialize BSD-Cov template registers after prefix.
  la   x10, bsd_cov_data
  li   x11, 0x11111111
  li   x12, 0x22222222

  # BSDCOV_SUFFIX_BEGIN
  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0000 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x5, 0(x10)
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0000 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x5, 0(x10)
  add  x15, x11, x5

  # BSDCOV_SEQ seq_R_stall_mem_000_0000 region=R_stall_mem_000 template=memory_stall
  lw   x5, 0(x10)
  sw   x5, 4(x10)
  lw   x19, 8(x10)
  sw   x19, 12(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0001 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x6, 4(x10)
  sub  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0001 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x6, 4(x10)
  sub  x16, x11, x6

  # BSDCOV_SEQ seq_R_stall_mem_000_0001 region=R_stall_mem_000 template=memory_stall
  lw   x6, 4(x10)
  sw   x6, 8(x10)
  lw   x20, 12(x10)
  sw   x20, 16(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0002 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x7, 8(x10)
  xor  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0002 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x7, 8(x10)
  xor  x17, x11, x7

  # BSDCOV_SEQ seq_R_stall_mem_000_0002 region=R_stall_mem_000 template=memory_stall
  lw   x7, 8(x10)
  sw   x7, 12(x10)
  lw   x21, 16(x10)
  sw   x21, 20(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0003 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x8, 12(x10)
  or   x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0003 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x8, 12(x10)
  or   x18, x11, x8

  # BSDCOV_SEQ seq_R_stall_mem_000_0003 region=R_stall_mem_000 template=memory_stall
  lw   x8, 12(x10)
  sw   x8, 16(x10)
  lw   x22, 20(x10)
  sw   x22, 24(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0004 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x9, 16(x10)
  and  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0004 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x9, 16(x10)
  and  x19, x11, x9

  # BSDCOV_SEQ seq_R_stall_mem_000_0004 region=R_stall_mem_000 template=memory_stall
  lw   x9, 16(x10)
  sw   x9, 20(x10)
  lw   x23, 24(x10)
  sw   x23, 28(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0005 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x13, 20(x10)
  slt  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0005 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x13, 20(x10)
  slt  x20, x11, x13

  # BSDCOV_SEQ seq_R_stall_mem_000_0005 region=R_stall_mem_000 template=memory_stall
  lw   x13, 20(x10)
  sw   x13, 24(x10)
  lw   x24, 28(x10)
  sw   x24, 32(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0006 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x14, 24(x10)
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0006 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x14, 24(x10)
  add  x21, x11, x14

  # BSDCOV_SEQ seq_R_stall_mem_000_0006 region=R_stall_mem_000 template=memory_stall
  lw   x14, 24(x10)
  sw   x14, 28(x10)
  lw   x25, 32(x10)
  sw   x25, 36(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0007 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x15, 28(x10)
  sub  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0007 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x15, 28(x10)
  sub  x22, x11, x15

  # BSDCOV_SEQ seq_R_stall_mem_000_0007 region=R_stall_mem_000 template=memory_stall
  lw   x15, 28(x10)
  sw   x15, 32(x10)
  lw   x26, 36(x10)
  sw   x26, 40(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0008 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x16, 32(x10)
  xor  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0008 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x16, 32(x10)
  xor  x23, x11, x16

  # BSDCOV_SEQ seq_R_stall_mem_000_0008 region=R_stall_mem_000 template=memory_stall
  lw   x16, 32(x10)
  sw   x16, 36(x10)
  lw   x27, 40(x10)
  sw   x27, 44(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0009 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x17, 36(x10)
  or   x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0009 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x17, 36(x10)
  or   x24, x11, x17

  # BSDCOV_SEQ seq_R_stall_mem_000_0009 region=R_stall_mem_000 template=memory_stall
  lw   x17, 36(x10)
  sw   x17, 40(x10)
  lw   x28, 44(x10)
  sw   x28, 48(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0010 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x18, 40(x10)
  and  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0010 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x18, 40(x10)
  and  x25, x11, x18

  # BSDCOV_SEQ seq_R_stall_mem_000_0010 region=R_stall_mem_000 template=memory_stall
  lw   x18, 40(x10)
  sw   x18, 44(x10)
  lw   x29, 48(x10)
  sw   x29, 52(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0011 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x19, 44(x10)
  slt  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0011 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x19, 44(x10)
  slt  x26, x11, x19

  # BSDCOV_SEQ seq_R_stall_mem_000_0011 region=R_stall_mem_000 template=memory_stall
  lw   x19, 44(x10)
  sw   x19, 48(x10)
  lw   x30, 52(x10)
  sw   x30, 56(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0012 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x20, 48(x10)
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0012 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x20, 48(x10)
  add  x27, x11, x20

  # BSDCOV_SEQ seq_R_stall_mem_000_0012 region=R_stall_mem_000 template=memory_stall
  lw   x20, 48(x10)
  sw   x20, 52(x10)
  lw   x31, 56(x10)
  sw   x31, 60(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0013 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x21, 52(x10)
  sub  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0013 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x21, 52(x10)
  sub  x28, x11, x21

  # BSDCOV_SEQ seq_R_stall_mem_000_0013 region=R_stall_mem_000 template=memory_stall
  lw   x21, 52(x10)
  sw   x21, 56(x10)
  lw   x5, 60(x10)
  sw   x5, 64(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0014 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x22, 56(x10)
  xor  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0014 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x22, 56(x10)
  xor  x29, x11, x22

  # BSDCOV_SEQ seq_R_stall_mem_000_0014 region=R_stall_mem_000 template=memory_stall
  lw   x22, 56(x10)
  sw   x22, 60(x10)
  lw   x6, 64(x10)
  sw   x6, 68(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0015 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x23, 60(x10)
  or   x30, x23, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0015 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x23, 60(x10)
  or   x30, x11, x23

  # BSDCOV_SEQ seq_R_stall_mem_000_0015 region=R_stall_mem_000 template=memory_stall
  lw   x23, 60(x10)
  sw   x23, 64(x10)
  lw   x7, 68(x10)
  sw   x7, 72(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0016 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x24, 64(x10)
  and  x31, x24, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0016 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x24, 64(x10)
  and  x31, x11, x24

  # BSDCOV_SEQ seq_R_stall_mem_000_0016 region=R_stall_mem_000 template=memory_stall
  lw   x24, 64(x10)
  sw   x24, 68(x10)
  lw   x8, 72(x10)
  sw   x8, 76(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0017 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x25, 68(x10)
  slt  x5, x25, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0017 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x25, 68(x10)
  slt  x5, x11, x25

  # BSDCOV_SEQ seq_R_stall_mem_000_0017 region=R_stall_mem_000 template=memory_stall
  lw   x25, 68(x10)
  sw   x25, 72(x10)
  lw   x9, 76(x10)
  sw   x9, 80(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0018 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x26, 72(x10)
  add  x6, x26, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0018 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x26, 72(x10)
  add  x6, x11, x26

  # BSDCOV_SEQ seq_R_stall_mem_000_0018 region=R_stall_mem_000 template=memory_stall
  lw   x26, 72(x10)
  sw   x26, 76(x10)
  lw   x13, 80(x10)
  sw   x13, 84(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0019 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x27, 76(x10)
  sub  x7, x27, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0019 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x27, 76(x10)
  sub  x7, x11, x27

  # BSDCOV_SEQ seq_R_stall_mem_000_0019 region=R_stall_mem_000 template=memory_stall
  lw   x27, 76(x10)
  sw   x27, 80(x10)
  lw   x14, 84(x10)
  sw   x14, 88(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0020 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x28, 80(x10)
  xor  x8, x28, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0020 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x28, 80(x10)
  xor  x8, x11, x28

  # BSDCOV_SEQ seq_R_stall_mem_000_0020 region=R_stall_mem_000 template=memory_stall
  lw   x28, 80(x10)
  sw   x28, 84(x10)
  lw   x15, 88(x10)
  sw   x15, 92(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0021 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x29, 84(x10)
  or   x9, x29, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0021 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x29, 84(x10)
  or   x9, x11, x29

  # BSDCOV_SEQ seq_R_stall_mem_000_0021 region=R_stall_mem_000 template=memory_stall
  lw   x29, 84(x10)
  sw   x29, 88(x10)
  lw   x16, 92(x10)
  sw   x16, 96(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0022 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x30, 88(x10)
  and  x13, x30, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0022 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x30, 88(x10)
  and  x13, x11, x30

  # BSDCOV_SEQ seq_R_stall_mem_000_0022 region=R_stall_mem_000 template=memory_stall
  lw   x30, 88(x10)
  sw   x30, 92(x10)
  lw   x17, 96(x10)
  sw   x17, 100(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0023 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x31, 92(x10)
  slt  x14, x31, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0023 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x31, 92(x10)
  slt  x14, x11, x31

  # BSDCOV_SEQ seq_R_stall_mem_000_0023 region=R_stall_mem_000 template=memory_stall
  lw   x31, 92(x10)
  sw   x31, 96(x10)
  lw   x18, 100(x10)
  sw   x18, 104(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0024 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x5, 96(x10)
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0024 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x5, 96(x10)
  add  x15, x11, x5

  # BSDCOV_SEQ seq_R_stall_mem_000_0024 region=R_stall_mem_000 template=memory_stall
  lw   x5, 96(x10)
  sw   x5, 100(x10)
  lw   x19, 104(x10)
  sw   x19, 108(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0025 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x6, 100(x10)
  sub  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0025 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x6, 100(x10)
  sub  x16, x11, x6

  # BSDCOV_SEQ seq_R_stall_mem_000_0025 region=R_stall_mem_000 template=memory_stall
  lw   x6, 100(x10)
  sw   x6, 104(x10)
  lw   x20, 108(x10)
  sw   x20, 112(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0026 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x7, 104(x10)
  xor  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0026 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x7, 104(x10)
  xor  x17, x11, x7

  # BSDCOV_SEQ seq_R_stall_mem_000_0026 region=R_stall_mem_000 template=memory_stall
  lw   x7, 104(x10)
  sw   x7, 108(x10)
  lw   x21, 112(x10)
  sw   x21, 116(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0027 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x8, 108(x10)
  or   x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0027 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x8, 108(x10)
  or   x18, x11, x8

  # BSDCOV_SEQ seq_R_stall_mem_000_0027 region=R_stall_mem_000 template=memory_stall
  lw   x8, 108(x10)
  sw   x8, 112(x10)
  lw   x22, 116(x10)
  sw   x22, 120(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0028 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x9, 112(x10)
  and  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0028 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x9, 112(x10)
  and  x19, x11, x9

  # BSDCOV_SEQ seq_R_stall_mem_000_0028 region=R_stall_mem_000 template=memory_stall
  lw   x9, 112(x10)
  sw   x9, 116(x10)
  lw   x23, 120(x10)
  sw   x23, 124(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0029 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x13, 116(x10)
  slt  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0029 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x13, 116(x10)
  slt  x20, x11, x13

  # BSDCOV_SEQ seq_R_stall_mem_000_0029 region=R_stall_mem_000 template=memory_stall
  lw   x13, 116(x10)
  sw   x13, 120(x10)
  lw   x24, 124(x10)
  sw   x24, 128(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0030 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x14, 120(x10)
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0030 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x14, 120(x10)
  add  x21, x11, x14

  # BSDCOV_SEQ seq_R_stall_mem_000_0030 region=R_stall_mem_000 template=memory_stall
  lw   x14, 120(x10)
  sw   x14, 124(x10)
  lw   x25, 128(x10)
  sw   x25, 132(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0031 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x15, 124(x10)
  sub  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0031 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x15, 124(x10)
  sub  x22, x11, x15

  # BSDCOV_SEQ seq_R_stall_mem_000_0031 region=R_stall_mem_000 template=memory_stall
  lw   x15, 124(x10)
  sw   x15, 128(x10)
  lw   x26, 132(x10)
  sw   x26, 136(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0032 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x16, 128(x10)
  xor  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0032 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x16, 128(x10)
  xor  x23, x11, x16

  # BSDCOV_SEQ seq_R_stall_mem_000_0032 region=R_stall_mem_000 template=memory_stall
  lw   x16, 128(x10)
  sw   x16, 132(x10)
  lw   x27, 136(x10)
  sw   x27, 140(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0033 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x17, 132(x10)
  or   x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0033 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x17, 132(x10)
  or   x24, x11, x17

  # BSDCOV_SEQ seq_R_stall_mem_000_0033 region=R_stall_mem_000 template=memory_stall
  lw   x17, 132(x10)
  sw   x17, 136(x10)
  lw   x28, 140(x10)
  sw   x28, 144(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0034 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x18, 136(x10)
  and  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0034 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x18, 136(x10)
  and  x25, x11, x18

  # BSDCOV_SEQ seq_R_stall_mem_000_0034 region=R_stall_mem_000 template=memory_stall
  lw   x18, 136(x10)
  sw   x18, 140(x10)
  lw   x29, 144(x10)
  sw   x29, 148(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0035 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x19, 140(x10)
  slt  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0035 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x19, 140(x10)
  slt  x26, x11, x19

  # BSDCOV_SEQ seq_R_stall_mem_000_0035 region=R_stall_mem_000 template=memory_stall
  lw   x19, 140(x10)
  sw   x19, 144(x10)
  lw   x30, 148(x10)
  sw   x30, 152(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0036 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x20, 144(x10)
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0036 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x20, 144(x10)
  add  x27, x11, x20

  # BSDCOV_SEQ seq_R_stall_mem_000_0036 region=R_stall_mem_000 template=memory_stall
  lw   x20, 144(x10)
  sw   x20, 148(x10)
  lw   x31, 152(x10)
  sw   x31, 156(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0037 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x21, 148(x10)
  sub  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0037 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x21, 148(x10)
  sub  x28, x11, x21

  # BSDCOV_SEQ seq_R_stall_mem_000_0037 region=R_stall_mem_000 template=memory_stall
  lw   x21, 148(x10)
  sw   x21, 152(x10)
  lw   x5, 156(x10)
  sw   x5, 160(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0038 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x22, 152(x10)
  xor  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0038 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x22, 152(x10)
  xor  x29, x11, x22

  # BSDCOV_SEQ seq_R_stall_mem_000_0038 region=R_stall_mem_000 template=memory_stall
  lw   x22, 152(x10)
  sw   x22, 156(x10)
  lw   x6, 160(x10)
  sw   x6, 164(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0039 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x23, 156(x10)
  or   x30, x23, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0039 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x23, 156(x10)
  or   x30, x11, x23

  # BSDCOV_SEQ seq_R_stall_mem_000_0039 region=R_stall_mem_000 template=memory_stall
  lw   x23, 156(x10)
  sw   x23, 160(x10)
  lw   x7, 164(x10)
  sw   x7, 168(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0040 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x24, 160(x10)
  and  x31, x24, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0040 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x24, 160(x10)
  and  x31, x11, x24

  # BSDCOV_SEQ seq_R_stall_mem_000_0040 region=R_stall_mem_000 template=memory_stall
  lw   x24, 160(x10)
  sw   x24, 164(x10)
  lw   x8, 168(x10)
  sw   x8, 172(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0041 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x25, 164(x10)
  slt  x5, x25, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0041 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x25, 164(x10)
  slt  x5, x11, x25

  # BSDCOV_SEQ seq_R_stall_mem_000_0041 region=R_stall_mem_000 template=memory_stall
  lw   x25, 164(x10)
  sw   x25, 168(x10)
  lw   x9, 172(x10)
  sw   x9, 176(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0042 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x26, 168(x10)
  add  x6, x26, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0042 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x26, 168(x10)
  add  x6, x11, x26

  # BSDCOV_SEQ seq_R_stall_mem_000_0042 region=R_stall_mem_000 template=memory_stall
  lw   x26, 168(x10)
  sw   x26, 172(x10)
  lw   x13, 176(x10)
  sw   x13, 180(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0043 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x27, 172(x10)
  sub  x7, x27, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0043 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x27, 172(x10)
  sub  x7, x11, x27

  # BSDCOV_SEQ seq_R_stall_mem_000_0043 region=R_stall_mem_000 template=memory_stall
  lw   x27, 172(x10)
  sw   x27, 176(x10)
  lw   x14, 180(x10)
  sw   x14, 184(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0044 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x28, 176(x10)
  xor  x8, x28, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0044 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x28, 176(x10)
  xor  x8, x11, x28

  # BSDCOV_SEQ seq_R_stall_mem_000_0044 region=R_stall_mem_000 template=memory_stall
  lw   x28, 176(x10)
  sw   x28, 180(x10)
  lw   x15, 184(x10)
  sw   x15, 188(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0045 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x29, 180(x10)
  or   x9, x29, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0045 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x29, 180(x10)
  or   x9, x11, x29

  # BSDCOV_SEQ seq_R_stall_mem_000_0045 region=R_stall_mem_000 template=memory_stall
  lw   x29, 180(x10)
  sw   x29, 184(x10)
  lw   x16, 188(x10)
  sw   x16, 192(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0046 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x30, 184(x10)
  and  x13, x30, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0046 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x30, 184(x10)
  and  x13, x11, x30

  # BSDCOV_SEQ seq_R_stall_mem_000_0046 region=R_stall_mem_000 template=memory_stall
  lw   x30, 184(x10)
  sw   x30, 188(x10)
  lw   x17, 192(x10)
  sw   x17, 196(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0047 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x31, 188(x10)
  slt  x14, x31, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0047 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x31, 188(x10)
  slt  x14, x11, x31

  # BSDCOV_SEQ seq_R_stall_mem_000_0047 region=R_stall_mem_000 template=memory_stall
  lw   x31, 188(x10)
  sw   x31, 192(x10)
  lw   x18, 196(x10)
  sw   x18, 200(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0048 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x5, 192(x10)
  add  x15, x5, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0048 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x5, 192(x10)
  add  x15, x11, x5

  # BSDCOV_SEQ seq_R_stall_mem_000_0048 region=R_stall_mem_000 template=memory_stall
  lw   x5, 192(x10)
  sw   x5, 196(x10)
  lw   x19, 200(x10)
  sw   x19, 204(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0049 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x6, 196(x10)
  sub  x16, x6, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0049 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x6, 196(x10)
  sub  x16, x11, x6

  # BSDCOV_SEQ seq_R_stall_mem_000_0049 region=R_stall_mem_000 template=memory_stall
  lw   x6, 196(x10)
  sw   x6, 200(x10)
  lw   x20, 204(x10)
  sw   x20, 208(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0050 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x7, 200(x10)
  xor  x17, x7, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0050 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x7, 200(x10)
  xor  x17, x11, x7

  # BSDCOV_SEQ seq_R_stall_mem_000_0050 region=R_stall_mem_000 template=memory_stall
  lw   x7, 200(x10)
  sw   x7, 204(x10)
  lw   x21, 208(x10)
  sw   x21, 212(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0051 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x8, 204(x10)
  or   x18, x8, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0051 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x8, 204(x10)
  or   x18, x11, x8

  # BSDCOV_SEQ seq_R_stall_mem_000_0051 region=R_stall_mem_000 template=memory_stall
  lw   x8, 204(x10)
  sw   x8, 208(x10)
  lw   x22, 212(x10)
  sw   x22, 216(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0052 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x9, 208(x10)
  and  x19, x9, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0052 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x9, 208(x10)
  and  x19, x11, x9

  # BSDCOV_SEQ seq_R_stall_mem_000_0052 region=R_stall_mem_000 template=memory_stall
  lw   x9, 208(x10)
  sw   x9, 212(x10)
  lw   x23, 216(x10)
  sw   x23, 220(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0053 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x13, 212(x10)
  slt  x20, x13, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0053 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x13, 212(x10)
  slt  x20, x11, x13

  # BSDCOV_SEQ seq_R_stall_mem_000_0053 region=R_stall_mem_000 template=memory_stall
  lw   x13, 212(x10)
  sw   x13, 216(x10)
  lw   x24, 220(x10)
  sw   x24, 224(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0054 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x14, 216(x10)
  add  x21, x14, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0054 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x14, 216(x10)
  add  x21, x11, x14

  # BSDCOV_SEQ seq_R_stall_mem_000_0054 region=R_stall_mem_000 template=memory_stall
  lw   x14, 216(x10)
  sw   x14, 220(x10)
  lw   x25, 224(x10)
  sw   x25, 228(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0055 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x15, 220(x10)
  sub  x22, x15, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0055 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x15, 220(x10)
  sub  x22, x11, x15

  # BSDCOV_SEQ seq_R_stall_mem_000_0055 region=R_stall_mem_000 template=memory_stall
  lw   x15, 220(x10)
  sw   x15, 224(x10)
  lw   x26, 228(x10)
  sw   x26, 232(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0056 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x16, 224(x10)
  xor  x23, x16, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0056 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x16, 224(x10)
  xor  x23, x11, x16

  # BSDCOV_SEQ seq_R_stall_mem_000_0056 region=R_stall_mem_000 template=memory_stall
  lw   x16, 224(x10)
  sw   x16, 228(x10)
  lw   x27, 232(x10)
  sw   x27, 236(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0057 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x17, 228(x10)
  or   x24, x17, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0057 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x17, 228(x10)
  or   x24, x11, x17

  # BSDCOV_SEQ seq_R_stall_mem_000_0057 region=R_stall_mem_000 template=memory_stall
  lw   x17, 228(x10)
  sw   x17, 232(x10)
  lw   x28, 236(x10)
  sw   x28, 240(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0058 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x18, 232(x10)
  and  x25, x18, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0058 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x18, 232(x10)
  and  x25, x11, x18

  # BSDCOV_SEQ seq_R_stall_mem_000_0058 region=R_stall_mem_000 template=memory_stall
  lw   x18, 232(x10)
  sw   x18, 236(x10)
  lw   x29, 240(x10)
  sw   x29, 244(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0059 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x19, 236(x10)
  slt  x26, x19, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0059 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x19, 236(x10)
  slt  x26, x11, x19

  # BSDCOV_SEQ seq_R_stall_mem_000_0059 region=R_stall_mem_000 template=memory_stall
  lw   x19, 236(x10)
  sw   x19, 240(x10)
  lw   x30, 244(x10)
  sw   x30, 248(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0060 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x20, 240(x10)
  add  x27, x20, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0060 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x20, 240(x10)
  add  x27, x11, x20

  # BSDCOV_SEQ seq_R_stall_mem_000_0060 region=R_stall_mem_000 template=memory_stall
  lw   x20, 240(x10)
  sw   x20, 244(x10)
  lw   x31, 248(x10)
  sw   x31, 252(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0061 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x21, 244(x10)
  sub  x28, x21, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0061 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x21, 244(x10)
  sub  x28, x11, x21

  # BSDCOV_SEQ seq_R_stall_mem_000_0061 region=R_stall_mem_000 template=memory_stall
  lw   x21, 244(x10)
  sw   x21, 248(x10)
  lw   x5, 252(x10)
  sw   x5, 256(x10)

  # BSDCOV_SEQ seq_R_stall_ld_hz_001_0062 region=R_stall_ld_hz_001 template=load_use_rs1
  lw   x22, 248(x10)
  xor  x29, x22, x11

  # BSDCOV_SEQ seq_R_stall_ld_hz_000_0062 region=R_stall_ld_hz_000 template=load_use_rs2
  lw   x22, 248(x10)
  xor  x29, x11, x22

  # BSDCOV_SUFFIX_END

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
  .word 0x00001111
  .word 0x00001122
  .word 0x00001133
  .word 0x00001144
  .word 0x00001155
  .word 0x00001166
  .word 0x00001177
  .word 0x00001188
  .word 0x00001199
  .word 0x000011aa
  .word 0x000011bb
  .word 0x000011cc
  .word 0x000011dd
  .word 0x000011ee
  .word 0x000011ff
  .word 0x00001210
  .word 0x00001221
  .word 0x00001232
  .word 0x00001243
  .word 0x00001254
  .word 0x00001265
  .word 0x00001276
  .word 0x00001287
  .word 0x00001298
  .word 0x000012a9
  .word 0x000012ba
  .word 0x000012cb
  .word 0x000012dc
  .word 0x000012ed
  .word 0x000012fe
  .word 0x0000130f
  .word 0x00001320
  .word 0x00001331
  .word 0x00001342
  .word 0x00001353
  .word 0x00001364
  .word 0x00001375
  .word 0x00001386
  .word 0x00001397
  .word 0x000013a8
  .word 0x000013b9
  .word 0x000013ca
  .word 0x000013db
  .word 0x000013ec
  .word 0x000013fd
  .word 0x0000140e
  .word 0x0000141f
  .word 0x00001430
  .word 0x00001441
  .word 0x00001452
  .word 0x00001463
  .word 0x00001474
  .word 0x00001485
  .word 0x00001496
  .word 0x000014a7
  .word 0x000014b8
  .word 0x000014c9
  .word 0x000014da
  .word 0x000014eb
  .word 0x000014fc
  .word 0x0000150d
  .word 0x0000151e
  .word 0x0000152f
  .word 0x00001540
  .word 0x00001551
  .word 0x00001562
  .word 0x00001573
  .word 0x00001584
  .word 0x00001595
  .word 0x000015a6
  .word 0x000015b7
  .word 0x000015c8
  .word 0x000015d9
  .word 0x000015ea
  .word 0x000015fb
  .word 0x0000160c
  .word 0x0000161d
  .word 0x0000162e
  .word 0x0000163f
  .word 0x00001650
  .word 0x00001661
  .word 0x00001672
  .word 0x00001683
  .word 0x00001694
  .word 0x000016a5
  .word 0x000016b6
  .word 0x000016c7
  .word 0x000016d8
  .word 0x000016e9
  .word 0x000016fa
  .word 0x0000170b
  .word 0x0000171c
  .word 0x0000172d
  .word 0x0000173e
  .word 0x0000174f
  .word 0x00001760
  .word 0x00001771
  .word 0x00001782
  .word 0x00001793
  .word 0x000017a4
  .word 0x000017b5
  .word 0x000017c6
  .word 0x000017d7
  .word 0x000017e8
  .word 0x000017f9
  .word 0x0000180a
  .word 0x0000181b
  .word 0x0000182c
  .word 0x0000183d
  .word 0x0000184e
  .word 0x0000185f
  .word 0x00001870
  .word 0x00001881
  .word 0x00001892
  .word 0x000018a3
  .word 0x000018b4
  .word 0x000018c5
  .word 0x000018d6
  .word 0x000018e7
  .word 0x000018f8
  .word 0x00001909
  .word 0x0000191a
  .word 0x0000192b
  .word 0x0000193c
  .word 0x0000194d
  .word 0x0000195e
  .word 0x0000196f
  .word 0x00001980
  .word 0x00001991
  .word 0x000019a2
  .word 0x000019b3
  .word 0x000019c4
  .word 0x000019d5
  .word 0x000019e6
  .word 0x000019f7
  .word 0x00001a08
  .word 0x00001a19
  .word 0x00001a2a
  .word 0x00001a3b
  .word 0x00001a4c
  .word 0x00001a5d
  .word 0x00001a6e
  .word 0x00001a7f
  .word 0x00001a90
  .word 0x00001aa1
  .word 0x00001ab2
  .word 0x00001ac3
  .word 0x00001ad4
  .word 0x00001ae5
  .word 0x00001af6
  .word 0x00001b07
  .word 0x00001b18
  .word 0x00001b29
  .word 0x00001b3a
  .word 0x00001b4b
  .word 0x00001b5c
  .word 0x00001b6d
  .word 0x00001b7e
  .word 0x00001b8f
  .word 0x00001ba0
  .word 0x00001bb1
  .word 0x00001bc2
  .word 0x00001bd3
  .word 0x00001be4
  .word 0x00001bf5
  .word 0x00001c06
  .word 0x00001c17
  .word 0x00001c28
  .word 0x00001c39
  .word 0x00001c4a
  .word 0x00001c5b
  .word 0x00001c6c
  .word 0x00001c7d
  .word 0x00001c8e
  .word 0x00001c9f
  .word 0x00001cb0
  .word 0x00001cc1
  .word 0x00001cd2
  .word 0x00001ce3
  .word 0x00001cf4
  .word 0x00001d05
  .word 0x00001d16
  .word 0x00001d27
  .word 0x00001d38
  .word 0x00001d49
  .word 0x00001d5a
  .word 0x00001d6b
  .word 0x00001d7c
  .word 0x00001d8d
  .word 0x00001d9e
  .word 0x00001daf
  .word 0x00001dc0
  .word 0x00001dd1
  .word 0x00001de2
  .word 0x00001df3
  .word 0x00001e04
  .word 0x00001e15
  .word 0x00001e26
  .word 0x00001e37
  .word 0x00001e48
  .word 0x00001e59
  .word 0x00001e6a
  .word 0x00001e7b
  .word 0x00001e8c
  .word 0x00001e9d
  .word 0x00001eae
  .word 0x00001ebf
  .word 0x00001ed0
  .word 0x00001ee1
  .word 0x00001ef2
  .word 0x00001f03
  .word 0x00001f14
  .word 0x00001f25
  .word 0x00001f36
  .word 0x00001f47
  .word 0x00001f58
  .word 0x00001f69
  .word 0x00001f7a
  .word 0x00001f8b
  .word 0x00001f9c
  .word 0x00001fad
  .word 0x00001fbe
  .word 0x00001fcf
  .word 0x00001fe0
  .word 0x00001ff1
  .word 0x00002002
  .word 0x00002013
  .word 0x00002024
  .word 0x00002035
  .word 0x00002046
  .word 0x00002057
  .word 0x00002068
  .word 0x00002079
  .word 0x0000208a
  .word 0x0000209b
  .word 0x000020ac
  .word 0x000020bd
  .word 0x000020ce
  .word 0x000020df
  .word 0x000020f0
  .word 0x00002101
  .word 0x00002112
  .word 0x00002123
  .word 0x00002134
  .word 0x00002145
  .word 0x00002156
  .word 0x00002167
  .word 0x00002178
  .word 0x00002189
  .word 0x0000219a
  .word 0x000021ab
  .word 0x000021bc
  .word 0x000021cd
  .word 0x000021de
  .word 0x000021ef
  .word 0x00002200
  .space 4096

  TEST_DATA

RVTEST_DATA_END
