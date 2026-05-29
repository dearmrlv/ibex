.section .text
.globl _start

_start:
    .word 0xf1420003    # lb   x0, -236(x4)     ; lb zero, -236(tp)
    .word 0xf8007fe3    # bgeu x0, x0, -98      ; bgeu zero, zero, -98