
.syntax unified
.cpu cortex-m4
.thumb
.section .rodata
.align 2

.global reset_str
.global help_str
.global ls_str
.global run_str
.global clear_str
.global pepsico_logo
.global help_menu
.global copyright_text
.global command_prompt
.global clear_screen_seq
.global invalid_cmd_txt
.global app_table

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
	.ascii "\thelp:		print this menu.\r\n"
	.ascii "\tls:		print list of available applications.\r\n"
	.ascii "\trun [app]:	run application.\r\n"
	.ascii "\tclear:		clears the screen and homes the cursor.\r\n"
	.ascii "\treset:		soft-resets the system.\r\n"
	.byte 0

copyright_text:
	.asciz "\t    Copyright © 2025 Pepsico. All rights reserved.\r\n"

command_prompt:
	.asciz "R&D> "

clear_screen_seq:
	.asciz "\x1B[2J\x1B[H"

invalid_cmd_txt:
	.asciz "?  Really?"

help_str:
	.asciz "help"
ls_str:
	.asciz "ls"
clear_str:
	.asciz "clear"
run_str:
	.asciz "run"
reset_str:
	.asciz "reset"

@ application table

app1_name:	.asciz "pwm"
app2_name:	.asciz "adc"
app3_name:	.asciz "dac"
app4_name:	.asciz "spi"
app5_name:	.asciz "counter"

app1_desc:	.asciz "Configures PWM"
app2_desc:	.asciz "Configures ADC"
app3_desc:	.asciz "Configures DAC"
app4_desc:	.asciz "Configures SPI"
app5_desc:	.asciz "Configure Counter"

.equ APP1_ENTRY, timer2_pwm_config
.equ APP2_ENTRY, timer2_pwm_config
.equ APP3_ENTRY, timer2_pwm_config
.equ APP4_ENTRY, timer2_pwm_config
.equ APP5_ENTRY, timer2_pwm_config

app_table:
	.word app1_name, app1_desc, APP1_ENTRY
	.word app2_name, app2_desc, APP2_ENTRY
	.word app3_name, app3_desc, APP3_ENTRY
	.word app4_name, app4_desc, APP4_ENTRY
	.word app5_name, app5_desc, APP5_ENTRY
	.word 0, 0						@ end of table


