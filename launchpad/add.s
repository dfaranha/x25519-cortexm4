	AREA addcode, CODE
	ENTRY

	; r0 destination
	; r1 summand a
	; r2 summand b
add proc
	export add
	push {r4-r11, lr}
	frame push {r4-r11, lr}

	ldm r1!, {r3-r7}
	ldm r2!, {r8-r12}
	add r3, r8
	add r4, r9
	add r5, r10
	add r6, r11
	add r7, r12
	stm r0!, {r3-r7}

	ldm r1!, {r3-r7}
	ldm r2!, {r8-r12}
	add r3, r8
	add r4, r9
	add r5, r10
	add r6, r11
	add r7, r12
	stm r0!, {r3-r7}

	pop {r4-r11, pc}
	endp
	END
