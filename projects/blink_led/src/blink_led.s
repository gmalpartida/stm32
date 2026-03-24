.syntax unified
.cpu cortex-m4
.thumb

.include "stm32f303xDE.inc"

@ Initialize Staprog1ck Pointer
@LDR R0, =_estack
@MOV SP, R0

@ Enable GPIOA Clock (example, adjust for your LED port)
ldr r0, =RCC_AHBENR
LDR R1, [R0]
ORR R1, R1, #(1 << 17) @ Set bit for GPIOA enable
STR R1, [R0]

@ Configure PA5 as Output (example, adjust for your LED pin)
LDR R0, =GPIOA_MODER
LDR R1, [r0]
BIC R1, R1, #(3 << (5 * 2)) @ Clear bits for PA5 mode
ORR R1, R1, #(1 << (5 * 2)) @ Set bits for output mode
STR R1, [r0]

MainLoop:
    @ Turn LED ON (example: PA5)
	ldr r0, =GPIOA_BSRR
    LDR R1, [r0]
    ORR R1, R1, #(1 << 5) @ Set PA5 bit
    STR R1, [r0]

    @ Call Delay Subroutine
    BL Delay

    @ Turn LED OFF (example: PA5)
	ldr r0, =GPIOA_BSRR
    LDR R1, [r0]
    ORR R1, R1, #(1 << (5 + 16)) @ Reset PA5 bit (bit 5 + 16 for reset section)
    STR R1, [r0]

    @ Call Delay Subroutine
    BL Delay

    B MainLoop @ Loop indefinitely

Delay:
    @ Implement delay loop (e.g., decrementing a register)
    ldr R0, =1000000
DelayLoop:
    SUBS R0, R0, #1
    BNE DelayLoop
    BX LR @ Return from subroutine

	
