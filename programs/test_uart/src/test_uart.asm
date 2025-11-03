    .syntax unified
    .cpu cortex-m4
    .fpu fpv4-sp-d16
    .thumb

    .global  _start
    .global  uart_send_string

@ Define register addresses
RCC_BASE        =     0x40021000
GPIOA_BASE      =     0x48000000
UART4_BASE      =     0x40004C00
RCC_AHBENR      =     0x14
RCC_APB1ENR     =     0x1C
GPIO_MODER      =     0x00
GPIO_AFRL       =     0x20
UART_BRR        =     0x0C
UART_CR1        =     0x08
UART_DR         =     0x04
UART_ISR        =     0x1C

    .section .text
_start:
    @ Setup UART4
    BL  uart4_setup

    @ Test UART4 by sending a string
    LDR R0, =hello_message
    BL  uart_send_string

    @ Infinite loop
infinite_loop:
    B   infinite_loop

uart4_setup:
    @ Enable GPIOA clock
    LDR R0, =RCC_BASE
    LDR R1, [R0, #RCC_AHBENR]
    ORR R1, R1, #(1 << 17)
    STR R1, [R0, #RCC_AHBENR]

    @ Enable UART4 clock
    LDR R0, =RCC_BASE
    LDR R1, [R0, #RCC_APB1ENR]
    ORR R1, R1, #(1 << 19)
    STR R1, [R0, #RCC_APB1ENR]

    @ Configure PA0 and PA1 for AF8
    LDR R0, =GPIOA_BASE
    LDR R1, [R0, #GPIO_MODER]
    BIC R1, R1, #(0b11 << 0)
    ORR R1, R1, #(0b10 << 0)
    BIC R1, R1, #(0b11 << 2)
    ORR R1, R1, #(0b10 << 2)
    STR R1, [R0, #GPIO_MODER]

    LDR R0, =GPIOA_BASE
    LDR R1, [R0, #GPIO_AFRL]
    BIC R1, R1, #(0xF << 0)
    ORR R1, R1, #(0x8 << 0)
    BIC R1, R1, #(0xF << 4)
    ORR R1, R1, #(0x8 << 4)
    STR R1, [R0, #GPIO_AFRL]

    @ Set Baud Rate (115200 @ 8MHz APB1)
    LDR R0, =UART4_BASE
    LDR R1, =0x45
    STR R1, [R0, #UART_BRR]

    @ Enable UART, Transmitter, and Receiver
    LDR R0, =UART4_BASE
    LDR R1, [R0, #UART_CR1]
    ORR R1, R1, #(1 << 3)  @ TE
    ORR R1, R1, #(1 << 2)  @ RE
    ORR R1, R1, #(1 << 0)  @ UE
    STR R1, [R0, #UART_CR1]

    BX LR

uart_send_char:
    @ R0 contains the character to send
    LDR R1, =UART4_BASE
tx_wait_loop:
    LDR R2, [R1, #UART_ISR]
    TST R2, #(1 << 7) @ Wait for TXE (Transmit empty)
    BEQ tx_wait_loop
    STRB R0, [R1, #UART_DR]
    BX LR

uart_send_string:
    @ R0 contains address of null-terminated string
next_char:
    LDRB R1, [R0]
    CMP R1, #0
    BEQ end_send_string
    MOV R0, R1
    BL uart_send_char
    ADD R0, R0, #1
    B next_char
end_send_string:
    BX LR

    .section .data
hello_message:
    .ascii "Hello from STM32F303 UART4!\n"
    .byte 0

