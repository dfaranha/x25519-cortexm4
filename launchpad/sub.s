	AREA subcode, CODE
	ENTRY

	; r0 destination
	; r1 minuend
	; r2 subtrahend
sub proc
	export sub
	push {r4-r11, lr}
	frame push {r4-r11, lr}

	ldm r1!, {r3-r7}
	ldm r2!, {r8-r12}
	sub r3, r8
	sub r4, r9
	sub r5, r10
	sub r6, r11
	sub r7, r12
	stm r0!, {r3-r7}

	ldm r1!, {r3-r7}
	ldm r2!, {r8-r12}
	sub r3, r8
	sub r4, r9
	sub r5, r10
	sub r6, r11
	sub r7, r12
	stm r0!, {r3-r7}

	pop {r4-r11, pc}
	endp
	END
