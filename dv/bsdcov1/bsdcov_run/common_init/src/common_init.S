/* Architectural initialization prefix shared with cpu_init. */

.option norvc

.equ STACK_TOP, 0x8ffff000

.section .text.init, "ax", @progbits
.globl _start
.org 0x80
_start:
  /* Establish the same deterministic machine-mode environment as cpu_init. */
  la    t0, trap_handler
  csrw  mtvec, t0
  csrwi mie, 0
  csrwi mscratch, 0
  csrwi mepc, 0
  li    t0, 0x1800
  csrw  mstatus, t0

  /* Initialize all writable integer registers. x0 remains hardwired to zero. */
  li    ra, 0
  li    sp, STACK_TOP
  li    gp, 0
  li    tp, 0
  li    t0, 0
  li    t1, 0
  li    t2, 0
  li    s0, 0
  li    s1, 0
  li    a0, 0
  li    a1, 0
  li    a2, 0
  li    a3, 0
  li    a4, 0
  li    a5, 0
  li    a6, 0
  li    a7, 0
  li    s2, 0
  li    s3, 0
  li    s4, 0
  li    s5, 0
  li    s6, 0
  li    s7, 0
  li    s8, 0
  li    s9, 0
  li    s10, 0
  li    s11, 0
  li    t3, 0
  li    t4, 0
  li    t5, 0
  li    t6, 0
