	AREA scalarmultdata, DATA
	ALIGN

x1 space 40
x2 space 40
x3 space 40
z2 space 40
z3 space 40
t0 space 40
t1 space 40
e space 32 

	AREA scalarmultcode, CODE
	ENTRY

	extern add
	extern copy
	extern cswap
	extern from_bytes
	extern invert
	extern mul
	extern mul121665
	extern sqr
	extern sub
	extern to_bytes

	; r0 q
	; r1 n
	; r2 p

scalarmult proc
	export scalarmult
	push {r4-r11, lr}
	frame push {r4-r11, lr}

	; stack, bottom to top: e (32B), q_ptr (4B)
	sub sp, #36
	; q is only required at output, will get it out of the way
	str r0, [sp, #32]

	; load scalar, clear/set required bits
	ldm r1, {r3-r10}
	bic r3,  #0x00000007
	bic r10, #0x80000000
	orr r10, #0x40000000
	stm sp, {r3-r10}

	; produce 25.5 bit limbs from point p
	ldr r0, =x1
	mov r1, r2
	bl from_bytes

	; copy bytes
	ldr r1, =x1
	ldr r0, =x3
	ldm r1, {r2-r11}
	stm r0, {r2-r11}

	; load data pointers for loop
	mov r4, #0			; swap
	ldr r5, =x2
	mov r6, r0			; x3
	ldr r7, =z2
	ldr r8, =z3
	ldr r9, =t0
	ldr r10, =t1

	; initialize z2 to 0 and x2 & z3 to 1
	mov r0, #1
	mov r1, #0
	mov r2, #0
	mov r3, #0
	mov r11, #0
	stm r7!, {r1-r4,r11}
	stm r7, {r1-r4,r11}
	stm r5!, {r0-r4}
	stm r5, {r1-r4,r11}
	stm r8!, {r0-r4}
	stm r8, {r1-r4,r11}
	sub r5, #20
	sub r7, #20
	sub r8, #20
	
	; Main loop for Montgomery ladder
	mov r11, #254
scalarmultloop
	; get relevant bit in e and perform conditional swap
	lsr r0, r11, #3
	ldrb r1, [sp, r0]
	and r0, r11, #7
	lsr r1, r1, r0
	and r1, #1
	eor r4, r1
	push {r1}
	mov r0, r5
	mov r1, r6
	mov r2, r4
	bl cswap
	mov r0, r7
	mov r1, r8
	mov r2, r4
	bl cswap
	pop {r4}
	
	mov r0, r9
	mov r1, r5
	mov r2, r7
	bl add

	mov r0, r10
	mov r1, r6
	mov r2, r8
	bl add

	mov r0, r5
	mov r1, r5
	mov r2, r7
	bl sub

	mov r0, r8
	mov r1, r6
	mov r2, r8
	bl sub

	mov r0, r10
	mov r1, r10
	mov r2, r5
	bl mul

	mov r0, r8
	mov r1, r8
	mov r2, r9
	bl mul

	mov r0, r6
	mov r1, r8
	mov r2, r10
	bl add

	mov r0, r8
	mov r1, r8
	mov r2, r10
	bl sub

	mov r0, r6
	mov r1, r6
	bl sqr

	mov r0, r8
	mov r1, r8
	bl sqr

	mov r0, r8
	ldr r1, =x1
	mov r2, r8
	bl mul

	mov r0, r9
	mov r1, r9
	bl sqr

	mov r0, r10
	mov r1, r5
	bl sqr

	mov r0, r5
	mov r1, r9
	mov r2, r10
	bl mul

	mov r0, r10
	mov r1, r9
	mov r2, r10
	bl sub

	mov r0, r7
	mov r1, r10
	bl mul121665

	mov r0, r7
	mov r1, r9
	mov r2, r7
	bl add

	mov r0, r7
	mov r1, r7
	mov r2, r10
	bl mul

	subs r11, #1
	bpl scalarmultloop

	mov r0, r5
	mov r1, r6
	mov r2, r4
	bl cswap

	mov r0, r7
	mov r1, r8
	mov r2, r4
	bl cswap

	mov r0, r7
	mov r1, r7
	bl invert

	mov r0, r5
	mov r1, r5
	mov r2, r7
	bl mul

	ldr r0, [sp, #32]
	mov r1, r5
	bl to_bytes

	add sp, #36
	pop {r4-r11, pc}
	endp
	END
