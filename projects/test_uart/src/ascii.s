.syntax unified
.cpu cortex-m4
.thumb

.global atoi

@ Input: r0 = pointer to string (e.g., "999")
@ Output: r0 = integer value (999)
atoi:
    mov r1, #0          @ Result accumulator
    mov r2, #10         @ Multiplier
.Latoi_next_digit:
    ldrb r3, [r0], #1   @ Load byte and post-increment pointer
    cmp r3, #0          @ Null terminator?
    beq .Ldone_atoi
    cmp r3, #32         @ Space? (if arguments are space-separated)
    beq .Ldone_atoi

    sub r3, r3, #48     @ Convert ASCII '0'-'9' to 0-9
    mla r1, r1, r2, r3  @ Result = (Result * 10) + digit
    b .Latoi_next_digit
.Ldone_atoi:
    mov r0, r1
    bx lr

