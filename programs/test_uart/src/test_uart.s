.syntax unified
.cpu cortex-m4
.thumb

@ definition of vector table
@.word 0x20000400	@ initialize stack pointer
@.word 0x080000ed	@ jump to start of program
@.space 0xe4			@ reserve this area for remaining of vector table

.global timer2_pwm_config
.equ HELP_CMD_CODE, 0x01
.equ LIST_CMD_CODE, 0x02
.equ INVALID_CMD_CODE, 0x00

.section .text

.global main

main:
	bl uart4_config

	bl clear_screen
	bl print_pepsico_logo
	bl print_ln
	bl print_copyright_text
	bl print_ln
	bl print_ln

	bl print_help_menu
	bl print_ln
	bl print_ln

command_prompt_loop:
	ldr r0, =uart4_rx_buffer
	mov r1, #0
	mov r2, #256
	bl memset
	bl print_command_prompt

	ldr r0, =uart4_rx_buffer
	@mov r1, #0
	@str r1, [r0]
	bl uart4_rx_asciz

	ldr r0, =uart4_rx_buffer
	bl skip_blanks
	ldr r1, [r0]
	cmp r1, #0
	beq command_prompt_loop

	@ldr r0, =uart4_rx_buffer
	ldr r1, =run_str
	mov r2, #3
	push {r0}
	bl strncmp
	cmp r0, #0
	pop {r0}
	beq process_run_cmd

	@ldr r0, =uart4_rx_buffer
	ldr r1, =help_str
	mov r2, #4
	push {r0}
	bl strncmp
	cmp r0, #0
	pop {r0}
	beq process_help_cmd

	@ldr r0, =uart4_rx_buffer
	ldr r1, =ls_str
	mov r2, #2
	push {r0}
	bl strncmp
	cmp r0, #0
	pop {r0}
	beq process_ls_cmd

	@ldr r0, =uart4_rx_buffer
	ldr r1, =clear_str
	mov r2, #5
	push {r0}
	bl strncmp
	cmp r0, #0
	pop {r0}
	beq process_clear_cmd

	@ldr r0, =uart4_rx_buffer
	ldr r1, =reset_str
	mov r2, #5
	push {r0}
	bl strncmp
	cmp r0, #0
	pop {r0}
	beq process_reset_cmd

	b process_invalid_cmd

process_help_cmd:
	bl do_help_cmd
	b command_prompt_loop

process_ls_cmd:
	bl do_ls_cmd
	b command_prompt_loop

process_clear_cmd:
	bl do_clear_cmd
	b command_prompt_loop

process_run_cmd:
	bl do_run_cmd
	b command_prompt_loop

process_reset_cmd:
	b main

process_invalid_cmd:
	bl do_invalid_cmd
	b command_prompt_loop

halt:
	b halt

do_invalid_cmd:
	push {lr}
	ldr r5, =uart4_rx_buffer
	bl uart4_tx_asciz
	ldr r5, =invalid_cmd_txt
	bl uart4_tx_asciz
	bl print_ln
	pop {lr}
	bx lr

do_help_cmd:
	push {lr}

	bl print_help_menu
	bl print_ln

	pop {lr}
	bx lr

do_ls_cmd:
	push {lr}

	bl print_app_list

	pop {lr}
	bx lr

do_clear_cmd:
	push {lr}

	bl clear_screen

	pop {lr}
	bx lr

do_run_cmd:
	push {r5, lr}
	ldr r0, =uart4_rx_buffer
	add r0, r0, #3

	bl skip_blanks

	ldr r2, =app_table
do_run_cmd_loop:
	ldr r1, [r2]
	cbz r1, do_run_cmd_exit
	push {r2}
	bl strcmp
	pop {r2}
	cbz r0, do_run_app
	add r2, r2, #12
	b do_run_cmd_loop

do_run_app:

	ldr r3, [r2, #8]
	orr r3, r3, #1
	blx r3

do_run_cmd_exit:
	pop {r5, lr}
	bx lr

clear_screen:
	ldr r5, =clear_screen_seq
	push {lr}
	bl uart4_tx_asciz
	pop {lr}
	bx lr

print_command_prompt:

	push {lr}
	ldr r5, =command_prompt
	bl uart4_tx_asciz
	pop {lr}
	bx lr


print_copyright_text:
	ldr r5, =copyright_text
	push {lr}
	bl uart4_tx_asciz
	pop {lr}
	bx lr

print_pepsico_logo:
	ldr r5, =pepsico_logo
	push {lr}
	bl uart4_tx_asciz
	pop {lr}
	bx lr

print_ln:
	mov r0, #'\r'
	push {lr}
	bl uart4_tx_char
	mov r0, #'\n'
	bl uart4_tx_char
	pop {lr}
	bx lr

print_tab:
	mov r0, #'\t'
	push {lr}
	bl uart4_tx_char
	pop {lr}

	bx lr

print_help_menu:
	ldr r5, =help_menu
	push {lr}
	bl uart4_tx_asciz
	pop {lr}
	bx lr

@ advances pointer till a non-blank character is found
@ --> r0: points to start address of memory string to check
@ <-- r0: points to address of non-blank character, or 0 if at end of string
skip_blanks:
	ldrb r1, [r0]
	cmp r1, #' '
	bne skip_blanks_exit
	add r0, r0, #1
	b skip_blanks

skip_blanks_exit:
	cmp r1, #0
	it eq
	moveq r0, #0
	bx lr


uart4_tx_asciz:
	ldrb r0, [r5], #1
	cmp r0, #0
	beq uart4_tx_asciz_exit
	push {lr}
	bl uart4_tx_char
	pop {lr}
	b uart4_tx_asciz
uart4_tx_asciz_exit:
	bx lr

uart4_rx_asciz:
	push {r5, lr}
	ldr r5, =uart4_rx_buffer

uart4_rx_asciz_loop:

	bl uart4_rx_char

	cmp r0, #'\n'
	beq uart4_rx_asciz_exit

	cmp r0, #'\r'
	beq uart4_rx_asciz_exit

	strb r0, [r5]
	add r5, r5, #1

	b uart4_rx_asciz_loop

uart4_rx_asciz_exit:
	mov r0, #0
	strb r0, [r5]
	pop {r5, lr}
	bx lr

uart4_tx_char:
	ldr r1, =UART4_ISR
	ldr r3, [r1]
	tst r3, #(1 << 7)
	beq uart4_tx_char
	ldr r2, =UART4_TDR
	strb r0, [r2]
	bx lr

uart4_rx_char:
	ldr r1, =UART4_ISR
	ldr r3, [r1]
	tst r3, #(1 << 5)
	beq uart4_rx_char
	ldr r2, =UART4_RDR
	ldrh r0, [r2]
	bx lr

uart4_config:
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
	mov r1, #833		@ replace r1 with #833
	str r1, [r0]

	@ enable TE, RE and UE
	ldr r0, =UART4_CR1
	ldr r1, [r0]
	orr r1, 0x01
	str r1, [r0]		@ enable UE
	orr r1, #0b1100
	str r1, [r0]		@ enable TE and RE

	bx lr

timer2_pwm_config:

	@ enable timer 2 clock
	ldr r0, =RCC_APB1ENR
	ldr r1, [r0]
	orr r1, 0x01
	str r1, [r0]

	@ enable gpioa clock
	ldr r0, =RCC_AHBENR
	ldr r1, [r0]
	orr r1, (0x01 << 17)
	str r1, [r0]

	@ set PA0 to alternate function mode
	ldr r0, =GPIOA_MODER
	ldr r1, [r0]
	bic r1, r1, 0x03		@ clear bits 1:0
	orr r1, 0x02
	str r1, [r0]

	@ set PA0 to AF1
	ldr r0, =GPIOA_AFRL
	ldr r1, [r0]
	bic r1, r1, #0x0f		@ clear bits 3:0
	orr r1, 0x01
	str r1, [r0]

	@ set PA0 to very high speed
	ldr r0, =GPIOA_OSPEEDR
	ldr r1, [r0]
	orr r1, r1, #0x03
	str r1, [r0]

	@ set auto-reload 999 = timer will reset to 0 after 999 steps, total = 1000 steps

	ldr r0, =TIM2_ARR
	ldr r1, [r0]
	mov r1, #3
	str r1, [r0]

	@ set 50% duty cycle, pwm will be high 500 steps out of 1000
	ldr r0, =TIM2_CCR1
	ldr r1, [r0]
	mov r1, #2
	str r1, [r0]

	@ set pwm mode 1
	ldr r0, =TIM2_CCMR1
	ldr r1, [r0]
	mov r1, #0x60
	str r1, [r0]

	@ enable channel 1 output
	ldr r0, =TIM2_CCER
	ldr r1, [r0]
	mov r1, #1
	str r1, [r0]

	@ trigger update
	ldr r0, =TIM2_EGR
	ldr r1, [r0]
	orr r1, r1, #1
	str r1, [r0]

	@ start timer
	ldr r0, =TIM2_CR1
	ldr r1, [r0]
	orr r1, r1, #1
	str r1, [r0]

	bx lr

print_app_list:
	push {r4, r5, r6, lr}
	ldr r4, =app_table
	mov r6, #0
print_app_list_loop:

	ldr r5, [r4]
	cbz r5, print_app_list_exit
	bl print_tab


	add r6, r6, #1
	mov r0, r6
	add r0, #0x30
	bl uart4_tx_char

	mov r0, #')'
	bl uart4_tx_char

	mov r0, #' '
	bl uart4_tx_char

	bl uart4_tx_asciz
	bl print_tab
	bl uart4_tx_char

	ldr r5, [r4, #4]
	bl uart4_tx_asciz

	bl print_ln

	add r4, r4, #12				@move to next entry in table
	b print_app_list_loop

print_app_list_exit:
	pop {r4, r5, r6, lr}
	bx lr

.include "stm32f303xDE.inc"


.section .data

uart4_rx_buffer:
	.space 256








