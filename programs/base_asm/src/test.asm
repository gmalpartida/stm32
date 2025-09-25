.syntax unified
.cpu cortex-m4
.thumb

@ definition of vector table
.word 0x20000400	@ initialize stack pointer
.word 0x080000ed	@ jump to start of program
.space 0xe4			@ reserve this area for remaining of vector table

.include "stm32f303xDE.inc"

	bl config_hsi_clock
	
	bl config_gpiob

	@bl config_uart4

	bl toggle_led

toggle_led:
	@ set GPIOB pin 7 to high
	ldr r1, =GPIOB_ODR
	ldr r2, [r1]
	eor r2, r2, 0x80		@ reverse bit
	str r2, [r1]
	ldr r0, =1000
	bl delay_ms
	b toggle_led

	bx lr

delay_ms:
    @ Input: R0 = delay in milliseconds
    @ clk_freq = core clock frequency in Hz
    @ Loop takes 3 clock cycles per iteration
    @ Example:
    @   - Core clock = 8 MHz
    @   - Delay = 1 ms
    @   - Cycles = 8000 (8 MHz * 0.001 s)
    @   - Iterations = Cycles / 3 = 2666.66...  (approx 2667)
    @   - Initialize R1 with (2667 * 3) / 2 = 3999.5, round up to 4000
    @       Because the loop takes 2 cycles per iteration (SUBS, BNE)

    @ Calculate loop iterations
    movs  r1, r0         @ R1 = delay (milliseconds)
    ldr   r2, =8000     @ R2 = core clock frequency (8 MHz, example)
    mul   r1, r1, r2     @ R1 = delay * clock frequency (cycles)
    lsrs  r1, r1, #1     @ R1 = (delay * clock frequency) / 2 (approximate)
    
    @ Initialize loop counter
    movs  r2, r1         @ R2 = loop counter
    
delay_loop:
    subs  r2, #1          @ Subtract 1 from the counter
    bne   delay_loop      @ Branch back if not zero
    
    @ Return
    bx lr	

config_hsi_clock:
@ enable default system clock, HSI 8Mhz
	ldr r1, =RCC_CR
	ldr r0, [r1]
	orr r0, 0x01
	str r0, [r1]

hsi_not_ready:				@ wait for HSI to be ready
	ldr r0, [r1]
	tst r0, 1 << 1
	beq hsi_not_ready

	@ select HSI as system clock source
	ldr r1, =RCC_CFGR
	ldr r0, [r1]
	bic	r0, r0, #0b11
	str r0, [r1]

	@ wait for system clock ready

sysclk_not_ready:
	ldr r0, [r1]
	tst r0, #0b1100
	bne sysclk_not_ready	

	bx lr

config_gpiob:
@ enable GPIOB clock
	ldr 	r1,	=RCC_AHBENR		
	ldr 	r0, [r1]
	orr 	r0,	0x00040000
	str		r0,	[r1]

@ set GPIOB to output mode
	ldr r1, =GPIOB_MODER 
	ldr     r0, [r1]
	orr r0, 0x00004000
	str r0, [r1]

	bx lr

config_uart4:	
	@ enable uart4 clock
	ldr 	r1, =RCC_APB1ENR
	ldr 	r0, [r1]
	orr 	r0, 0x00040000   @ 00000000000001000000000000000000 
	str 	r0, [r1]

	@ define word length, 8 data bits, oversampling by 8, no parity
	ldr r1, =UART4_CR1
	ldr r0, [r1]
	and ro, 0x0fffebff
	str r0, [r1]

	@ 1 stop bit
	ldr r1, =UART4_CR2
	ldr r0, [r1]
	and r0, 0xffffcfff
	str r0, [r1]

	@ baud rate setup to 9600 bps
	@ USARTDIV = (2 * 8Mhz) / 9600 = 1666.66 = 1667 = 0x0683 = 0b 0000 0110 1000 0011
	@ BRR[3:0] = 0011 >> 1 = 0001
	@ BRR = 0x681

	ldr r1, =UART4_BRR
	ldr r0, [r1]
	orr r0, =0x681
	str r0, [r1]

	@ enable UART4 and start receiver
	ldr r1, =UART4_CR1
	ldr r0, [r1]
	orr r0, 0x05

	str r0, [r1]

	bx lr
