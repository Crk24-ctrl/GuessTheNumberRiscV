# ------------------------------------------------------------
# project.asm
# Guess the Number (RISC-V, RARS/venus)
# 1) Choose difficulty (1..3) or Exit (4)
# 2) Random target in [1..bound] using syscall 30
# 3) Validate guesses, count lives, print messages
# ------------------------------------------------------------

    .data
difficulty_prompt:  .string "Choose difficulty:\n1 - Easy (1 to 10)\n2 - Medium (1 to 50)\n3 - Hard (1 to 100)\n4 - Exit\n"
guess_prompt:       .string "Enter your guess: "
win_msg:            .string "You won!\n"
womp_msg:           .string "Womp womp, you still have "
tries_left_msg:     .string " tries\n"
one_try_msg:        .string " try\n"
lose_msg:           .string "You lost!\n"
invalid_choice:     .string "Invalid choice\n"
invalid_guess:      .string "Invalid guess\n"
reveal_msg:         .string "The correct number was: "
newline:            .string "\n"
goodbye_msg:        .string "Goodbye!\n"

    .text
    .globl main

# ------------------------------------------------------------
# main → menu
# ------------------------------------------------------------
main:
    j       choose_difficulty

# ------------------------------------------------------------
# Menu + read choice (t0)
#   sets:
#     t1 = upper bound (10/50/100)
#     s1 = lives       (5/4/3)
#     s0 = target in [1..t1]
# ------------------------------------------------------------
choose_difficulty:
    # show menu
    li      a7, 4
    la      a0, difficulty_prompt
    ecall

    # read int choice → a0
    li      a7, 5
    ecall
    addi    t0, a0, 0              # t0 = choice

    # exit if choice == 4
    li      t4, 4
    beq     t0, t4, exit_game

    # valid choices: 1, 2, 3
    li      t4, 1
    beq     t0, t4, set_easy
    li      t4, 2
    beq     t0, t4, set_medium
    li      t4, 3
    beq     t0, t4, set_hard

    # invalid menu input
    li      a7, 4
    la      a0, invalid_choice
    ecall
    j       choose_difficulty

# ------------------------------------------------------------
# Difficulty setters (define bound in t1 and lives in s1)
# ------------------------------------------------------------
set_easy:
    li      t1, 10                 # bound
    li      s1, 5                  # lives
    j       set_random

set_medium:
    li      t1, 50
    li      s1, 4
    j       set_random

set_hard:
    li      t1, 100
    li      s1, 3
    # fallthrough to set_random

# ------------------------------------------------------------
# Generate random target s0 in [1..t1]
# ------------------------------------------------------------
set_random:
    li      a7, 30                 # random int → a0
    ecall
    rem     a0, a0, t1             # a0 = a0 % t1
    addi    a0, a0, 1              # shift to [1..t1]
    addi    s0, a0, 0              # s0 = target

    j       guess_loop

# ------------------------------------------------------------
# Guess loop:
#  - asks for guess (t5)
#  - validates in [1..t1]
#  - compares vs s0
#  - handles lives in s1
# ------------------------------------------------------------
guess_loop:
get_guess:
    # prompt
    li      a7, 4
    la      a0, guess_prompt
    ecall

    # read guess → a0
    li      a7, 5
    ecall
    addi    t5, a0, 0              # t5 = guess

    # range check: if t5 < 1 or t5 > t1 → invalid
    li      t6, 1
    blt     t5, t6, invalid_guess_handler
    bgt     t5, t1, invalid_guess_handler

    # correct?
    beq     t5, s0, win

    # wrong → lose a life
    addi    s1, s1, -1
    beqz    s1, lose

    # print "Womp ... <lives> tries"
    li      a7, 4
    la      a0, womp_msg
    ecall

    addi    a0, s1, 0              # print lives number
    li      a7, 1
    ecall

    li      t6, 1
    beq     s1, t6, print_singular # "try" vs "tries"

    li      a7, 4
    la      a0, tries_left_msg
    ecall
    j       guess_loop

print_singular:
    li      a7, 4
    la      a0, one_try_msg
    ecall
    j       guess_loop

invalid_guess_handler:
    li      a7, 4
    la      a0, invalid_guess
    ecall
    j       get_guess

# ------------------------------------------------------------
# End states
# ------------------------------------------------------------
win:
    li      a7, 4
    la      a0, win_msg
    ecall
    j       choose_difficulty

lose:
    li      a7, 4
    la      a0, lose_msg
    ecall

    li      a7, 4
    la      a0, reveal_msg
    ecall

    addi    a0, s0, 0              # print target
    li      a7, 1
    ecall

    li      a7, 4
    la      a0, newline
    ecall

    j       choose_difficulty

exit_game:
    li      a7, 4
    la      a0, goodbye_msg
    ecall

    li      a7, 10
    ecall
