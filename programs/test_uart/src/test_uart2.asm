
.syntax unified
.cpu cortex-m4
.thumb

@ --- Register Base Addresses (Conceptual) ---
RCC_BASE        = 0x40021000
GPIOC_BASE      = 0x40020C00
UART4_BASE      = 0x40007800 @ UART4 is on APB1

@ --- RCC Offsets & Bitmasks ---
RCC_AHBENR_OFFSET = 0x14
RCC_APB1ENR_OFFSET = 0x1C
RCC_AHBENR_GPIOCEN = (1 << 18) @ GPIOC clock enable bit
RCC_APB1ENR_UART4EN = (1 << 19) @ UART4 clock enable bit

@ --- GPIOC Offsets & Bitmasks ---
GPIO_MODER_OFFSET = 0x00
GPIO_AFR_HIGH_OFFSET = 0x24 @ AFRH for pins 8-15

@ Pin PC10 (TX) and PC11 (RX) use AF5 for UART4
@ MODER config: 0b10 (Alternate function mode) for bits 21:20 (PC10) and 23:22 (PC11)
@ AF config: AF5 (0b0101) for AFRH10 and AFRH11

@ --- UART4 Offsets & Bitmasks ---
UART_CR1_OFFSET = 0x0C
UART_BRR_OFFSET = 0x10
UART_TDR_OFFSET = 0x28 @ Transmit data register
UART_CR1_UE_ENABLE = (1 << 13) @ UART Enable
UART_CR1_TE_ENABLE = (1 << 3)  @ Transmitter Enable
UART_CR1_RE_ENABLE = (1 << 2)  @ Receiver Enable
UART_ISR_OFFSET = 0x1C @ Interrupt and status register
UART_ISR_TXE = (1 << 7) @ Transmit data register empty flag


@ definition of vector table
.word 0x20000400	@ initialize stack pointer
.word 0x080000ed	@ jump to start of program
.space 0xe4			@ reserve this area for remaining of vector table


    @ Data section for the string
    .section .data
hello_msg:
    .ascii "Hello, STM32F303 UART4!\n\r"
msg_end:
    .byte 0

    .section .text

	bl uart_init

	ldr r0, =hello_msg
	bl uart_send_text

uart_init:
    @ 1. Enable Clocks for GPIOC and UART4
    LDR R0, =RCC_BASE
    LDR R1, [R0, #RCC_AHBENR_OFFSET]
    ORR R1, R1, #RCC_AHBENR_GPIOCEN
    STR R1, [R0, #RCC_AHBENR_OFFSET]

    LDR R1, [R0, #RCC_APB1ENR_OFFSET]
    ORR R1, R1, #RCC_APB1ENR_UART4EN
    STR R1, [R0, #RCC_APB1ENR_OFFSET]

    @ Optional: a few NOPs for clock stabilization
    NOP
    NOP

    @ 2. Configure GPIOC Pins PC10 (TX) and PC11 (RX) to Alternate Function mode (0b10)
    LDR R0, =GPIOC_BASE
    LDR R1, [R0, #GPIO_MODER_OFFSET]
    @ Clear current mode bits for PC10 (bits 21:20) and PC11 (bits 23:22)
    BIC R1, R1, #(0x03 << 20) @ Clear PC10
    BIC R1, R1, #(0x03 << 22) @ Clear PC11
    @ Set alternate function mode (0b10)
    ORR R1, R1, #(0x02 << 20) @ Set PC10
    ORR R1, R1, #(0x02 << 22) @ Set PC11
    STR R1, [R0, #GPIO_MODER_OFFSET]

    @ 3. Configure GPIO Alternate Function High Register (AFRH) for UART4 (AF5 = 0b0101)
    LDR R1, [R0, #GPIO_AFR_HIGH_OFFSET]
    @ Clear current AF bits for PC10 (bits 11:8) and PC11 (bits 15:12) of AFRH
    BIC R1, R1, #(0x0F << 8)  @ Clear PC10 (AFRH10)
    BIC R1, R1, #(0x0F << 12) @ Clear PC11 (AFRH11)
    @ Set AF5 (0b0101)
    ORR R1, R1, #(0x05 << 8)  @ Set PC10
    ORR R1, R1, #(0x05 << 12) @ Set PC11
    STR R1, [R0, #GPIO_AFR_HIGH_OFFSET]

    @ 4. Configure UART4 Baud Rate
    LDR R0, =UART4_BASE
    LDR R1, =0x34 @ BRR value for 9600 baud at 8MHz PCLK
    STR R1, [R0, #UART_BRR_OFFSET]

    @ 5. Enable UART4 (UE bit), Transmitter (TE bit), and Receiver (RE bit)
    LDR R1, [R0, #UART_CR1_OFFSET]
    ORR R1, R1, #UART_CR1_UE_ENABLE 
	orr r1, r1, #UART_CR1_TE_ENABLE
	orr r1, r1, #UART_CR1_RE_ENABLE
    STR R1, [R0, #UART_CR1_OFFSET]

    BX LR @ Return from initialization


uart_send_char:
    @ R0 contains the base address of UART4
    @ R1 contains the character to send
wait_tx_ready:
    LDR R2, [R0, #UART_ISR_OFFSET]
    TST R2, #UART_ISR_TXE @ Check TXE flag (Transmit Empty)
    BEQ wait_tx_ready     @ Loop until TXE is set (ready to receive data)

    @ Load data into TDR
    STRB R1, [R0, #UART_TDR_OFFSET]
    BX LR                 @ Return


uart_send_text:
    @ R0 contains the address of the string
    PUSH {R4, LR}         @ Save R4 and Link Register
    LDR R4, =UART4_BASE   @ R4 holds the UART4 base address permanently in this function

send_loop:
    LDRB R1, [R0], #1     @ Load byte from R0 into R1, then increment R0
    CMP R1, #0            @ Check for null terminator
    BEQ send_done         @ If null, finish

    @ Call the function to send a single character
    PUSH {R0, R4}         @ Save current R0 and R4 before function call modifies registers
    MOV R0, R4            @ Move UART base address to R0 for uart_send_char argument
    BL uart_send_char
    POP {R0, R4}          @ Restore R0 and R4

    B send_loop           @ Continue the loop

send_done:
    POP {R4, LR}          @ Restore R4 and return address
    BX LR

