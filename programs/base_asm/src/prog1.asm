.syntax unified
.cpu cortex-m4
.thumb

@ definition of vector table
.word 0x20000400	@ initialize stack pointer
.word 0x080000ed	@ jump to start of program
.space 0xe4			@ reserve this area for remaining of vector table

.include "stm32f303xDE.inc"

@ enable system clock
ldr r1, =RCC + 0x00
ldr r0, [r1]
orr r0, 0x01
str r0, [r1]

@ enable GPIOB clock
ldr 	r1,	=0x40021014		
ldr 	r0, [r1]
orr 	r0,	0x00040000
str		r0,	[r1]

@ set GPIOB to output mode
ldr r1, =GPIOA_MODER 
ldr     r0, [r1]
orr r0, 0x00004000
str r0, [r1]

@ set GPIOB pin 7 to high
ldr r1, =0x48000414
turn_led_on:
ldr r2, [r1]
@ orr r0, 0x0080
@mvn r0, r0 			@ reverse all bits
eor r2, r2, 0x80		@ reverse bit
str r2, [r1]
b turn_led_on
