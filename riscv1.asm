# ------------------------------------------------------------
# riscv1.asm
# Demo: print a string and compute its length (null-terminated)
# RARS/venus syscalls
# ------------------------------------------------------------

    .data
myLabel:        .asciz  "American Uni of B\n"

    .text
    .globl main
main:
    # --- Print the string ---
    li      a7, 4                  # print_string
    la      a0, myLabel
    ecall

    # --- Compute string length: len in x7 ---
    la      a1, myLabel            # a1 = base address
    li      x7, 0                  # x7 = length counter

len_loop:
    lbu     a2, 0(a1)              # read byte
    beq     a2, x0, len_done       # stop at '\0'
    addi    x7, x7, 1              # ++len
    addi    a1, a1, 1              # move to next char
    j       len_loop

len_done:
    # x7 now contains the string length (without the null)

    li      a7, 10                 # exit
    ecall
