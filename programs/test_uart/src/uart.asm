.syntax unified
.cpu cortex-m4
.thumb

@ definition of vector table
.word 0x20000400	@ initialize stack pointer
.word 0x080000ed	@ jump to start of program
.space 0xe4			@ reserve this area for remaining of vector table

	@ enable gpio C clock
	ldr r0, =RCC_AHBENR
	ldr r1, [r0]
	orr r1, #(0b0001 << 19)
	str r1, [r0]

	@ enable uart4 clock
	ldr r0, =RCC_APB1ENR
	ldr r1, [r0]
	orr r1, #(0b0001 << 19)
	str r1, [r0]

	@ set pins PC10 and PC11 to alternate function mode
	ldr r0, =GPIOC_MODER
	ldr r1, [r0]
	orr r1, #(0b1010 << 20)
	str r1, [r0]

	@ set uart4 tx, rx as the alternate function for pins PC10 and PC11
	ldr r0, =GPIOC_AFRH
	ldr r1, [r0]
	ldr r2, =(0b0101010100000000)		
	orr r1, r2
	str r1, [r0]	

	@ set uart4 baud rate to 9600 bps, oversampling by 16
	ldr r0, =UART4_BRR
	ldr r1, [r0]
	ldr r2, =0x0045
	orr r1, r2
	str r1, [r0]

	@ enable TE, RE and UE
	ldr r0, =UART4_CR1
	ldr r1, [r0]
	orr r1, #0b1101
	str r1, [r0]

	@ send a character to host

	mov r0, #'G'
	@ldr r1, =UART4_ISR
@uart4_tx_wait:
@	tst r1, #(1 << 7)
@	beq uart4_tx_wait
	ldr r2, =UART4_TDR
	strb r0, [r2]

halt:
	b halt
		
		




.include "stm32f303xDE.inc"

