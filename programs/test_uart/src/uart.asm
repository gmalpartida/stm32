.syntax unified
.cpu cortex-m4
.thumb

@ definition of vector table
@.word 0x20000400	@ initialize stack pointer
@.word 0x080000ed	@ jump to start of program
@.space 0xe4			@ reserve this area for remaining of vector table

.equ HELP_CMD_CODE, 0x01
.equ LIST_CMD_CODE, 0x02
.equ INVALID_CMD_CODE, 0x00

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
	bl print_command_prompt

	bl uart4_rx_asciz

	ldr r0, =uart4_rx_buffer
	ldr r1, =help_str
	bl strcmp
	cmp r0, #0
	beq process_help_cmd
	
	ldr r0, =uart4_rx_buffer
	ldr r1, =ls_str
	bl strcmp

	beq process_ls_cmd

	ldr r0, =uart4_rx_buffer
	ldr r1, =clear_str
	bl strcmp
	beq process_clear_cmd

	b process_invalid_cmd

	b command_prompt_loop

process_help_cmd:
	bl do_help_cmd
	b command_prompt_loop

process_ls_cmd:
	bl do_ls_cmd
	b command_prompt_loop

process_clear_cmd:
	bl do_clear_cmd
	b command_prompt_loop

process_invalid_cmd:
	bl do_invalid_cmd
	b command_prompt_loop

halt:
	b halt

@ compares two strings
@ --> r0: address of first string
@ --> r1: address of second string
@ <-- r0: 0 if equal, 1 if r0 > r1, 2 if r0 < r1
strcmp:
	push {r4, r5}
	mov r4, #0
	mov r5, #0

strcmp_loop:
	ldrb r2, [r0, r4]
	ldrb r3, [r1, r4]

	cmp r2, r3
	beq strcmp_equal
	blo strcmp_lessthan

	mov r5, #1
	b strcmp_exit
	
strcmp_lessthan:
	mov r5, #2
	b strcmp_exit

strcmp_equal:
	cmp r2, #0
	beq strcmp_exit
	add r4, r4, #1
	b strcmp_loop

strcmp_exit:
	mov r0, r5
	pop {r4, r5}
	bx lr

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

	ldr r5, =app_menu
	bl uart4_tx_asciz
	bl print_ln

	pop {lr}
	bx lr

do_clear_cmd:
	push {lr}

	bl clear_screen

	pop {lr}
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

print_help_menu:
	ldr r5, =help_menu
	push {lr}
	bl uart4_tx_asciz
	pop {lr}
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
	push {lr}
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
	pop {lr}
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

	
.include "stm32f303xDE.inc"

.section .rodata

pepsico_logo:
	.ascii "\t\t  _____               _           \r\n"
	.ascii "\t\t |  __ \\             (_)          \r\n"
	.ascii "\t\t | |__) |__ _ __  ___ _  ___ ___  \r\n"
	.ascii "\t\t |  ___/ _ \\ '_ \\/ __| |/ __/ _ \\ \r\n"
	.ascii "\t\t | |  |  __/ |_) \\__ \\ | (_| (_) |\r\n"
	.ascii "\t\t |_|   \\___| .__/|___/_|\\___\\___/ \r\n"
	.ascii "\t\t       ____| |      _____          \r\n"
	.ascii "\t\t      |  __ \\|__   |  __ \\         \r\n"
	.ascii "\t\t      | |__) ( _ ) | |  | |        \r\n"
	.ascii "\t\t      |  _  // _ \\/\\ |  | |        \r\n"
	.ascii "\t\t      | | \\ \\ (_>  < |__| |        \r\n"
	.ascii "\t\t      |_|  \\_\\___/\\/_____/         \r\n"
	.byte 0                                  
                                  

help_menu:
	.ascii "\tHelp Menu\r\n\r\n"
	.ascii "\thelp:      print this menu.\r\n"
	.ascii "\tlist:      print list of available applications.\r\n"
	.ascii "\trun [app]: run application.\r\n"
	.byte 0

app_menu:
	.ascii "\tApplication 1\r\n"
	.ascii "\tApplication 2\r\n"
	.ascii "\tApplication 3\r\n"
	.ascii "\tApplication 4\r\n"
	.ascii "\tApplication 5\r\n"
	.byte 0


copyright_text:
	.asciz "\t    Copyright © 2025 Pepsico. All rights reserved.\r\n"

command_prompt:
	.asciz "R&D> "

clear_screen_seq:
	.asciz "\x1B[2J\x1B[H"

help_cmd_txt:
	.asciz "help command received."

ls_cmd_txt:
	.asciz "list command received."

invalid_cmd_txt:
	.asciz "?  Really?"

help_str:
	.asciz "help"
ls_str:
	.asciz "ls"
clear_str:
	.asciz "clear"

.section .data

uart4_rx_buffer:
	.space 4096 * 10





