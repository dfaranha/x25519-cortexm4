	AREA measuretimingcode, CODE, READONLY
	ENTRY

	extern scalarmult
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
measuretiming proc
	export measuretiming
	push {r4-r11, lr}
	frame push {r4-r11, lr}

	; SysTick base address
	mov r4, #0xe000e000
	; Maximum interval value SysTick supports
	mov r5, #0x00ffffff
	; SysTick enabled by writing this to Ctrl
	mov r6, #5
	; ...and disabled with this. Also initializes Val
	mov r7, #0
	
	; Write interval to Load
	str r5, [r4, #0x14]
	
	; Write init to Val
	str r7, [r4, #0x18]
	
	; Enable timer
	str r6, [r4, #0x10]
	
	; Seems I get good results letting the thing initialize or whatever
	mov r10, r10
	mov r10, r10
	mov r10, r10
	
	; Read start value
	ldr r8, [r4, #0x18]
	
	bl scalarmult
	
	; Read end value
	ldr r9, [r4, #0x18]
	
	; Stop timer
	str r7, [r4, #0x10]
	
	; Return cycle count
	sub r0, r8, r9
	sub r0, #2		; Count inflated by two due to ldr latency

	pop {r4-r11, pc}
	endp
	END
