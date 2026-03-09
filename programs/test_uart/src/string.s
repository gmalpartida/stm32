
.syntax unified
.cpu cortex-m4
.thumb

.section .text

.equ	NULL,	0


.global strcmp
.type strcmp, %function

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

.global strncmp
.type strncmp, %function

@ compare the first n bytes of two strings
@ --> r0: address of first string
@ --> r1: address of second string
@ --> r2: how many bytes to compare
@ --> r0: 0 if equal, otherwise 1
strncmp:
	
strncmp_loop:
	ldrb r3, [r0]
	ldrb r12, [r1]
	cmp r3, r12
	bne strncmp_no_match
	subs r2, r2, #1
	cbz r2, strncmp_exit
	add r0, r0, #1
	add r1, r1, #1
	b strncmp_loop

strncmp_no_match:
	mov r0, #1
	bx lr
strncmp_exit:
	mov r0, #0
	bx lr





@ searches for first occurrence of a character in the first bytes of a memory area
@ --> r0: contains address of memory to be searched
@ --> r1: contains character to search for
@ --> r2: contains how many bytes to be included in search
@ <-- r0: contains address at which character was found.  Otherwise contains NULL
.global memchr
.type memchr, %function	

memchr:
	cbz r2, 2f				@ exit immediately if count of bytes is 0

1:	@loop
	ldrb r3, [r0]	
	cmp r3, r1
	beq 3f						@ chr found, exit, r0 points to location of char
	add r0, r0, #1				@ move on to next byte
	subs r2, r2, #1
	beq 2f						@ chr not found and count of bytes exhausted, exit
	b 1b						@ loop

2: @ not found, return 0 in r0
	mov r0, #0
3: @ if found, r0 will contain location of char
	bx lr

@ copies a character to the first n bytes of a buffer
@ --> r0: contains address of buffer
@ --> r1: character to copy
@ --> r2: count of bytes

.global memset
.type memset,%function

memset:
.Lmemset_loop:
	cbz r2, .Lmemset_exit
		
	str r1, [r0]				@ copy char to memory location given in r0

	add r0, r0, #1				@ advance to next location
	subs r2, r2, #1				@ decrement count of bytes set
	b .Lmemset_loop

.Lmemset_exit:

	bx lr

@ compares the first n bytes of two memory buffers
@ --> r0: addresss of first buffer
@ --> r1: addresss of second buffer
@ --> r2: how many bytes to compare
@ <-- r0: 0 if equal, -1 if first buffer is less than second buffer, 1 if first buffer is
@			greater than second buffer
.global memcmp
.type memcmp, %function
memcmp:
	mov r5, #0
.Lmemcmp_loop:
	cbz r2, .Lmemcmp_exit
	ldr r3, [r0]
	ldr r4, [r1]
	cmp r3, r4
	bmi .Lmemcmp_less
	bpl .Lmemcmp_greater
	add r0, r0, #1
	add r1, r1, #1
	subs r2, r2, #1
	b .Lmemcmp_loop

.Lmemcmp_less:
	mov r5, -1
	b .Lmemcmp_exit
.Lmemcmp_greater:
	mov r5, 1
.Lmemcmp_exit:
	mov r0, r5

	bx lr


@ copies the first n bytes from one memory buffer to another
@ --> r0: address of source buffer
@ --> r1: address of destination buffer
@ --> r2: how many bytes to copy
.global memcpy
.type memcpy, %function
memcpy:
	
.Lmemcpy_loop:
	cbz r2, .Lmemcpy_exit
	ldr r3, [r0]
	str r3, [r1]
	add r0, r0, #1
	subs r2, r2, #1
	b .Lmemcpy_loop

.Lmemcpy_exit:
	bx lr








