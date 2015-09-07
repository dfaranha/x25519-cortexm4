	AREA cswapcode, CODE
	ENTRY

	; r0 field element a
	; r1 field element b
	; r2 swap-bit
cswap proc
	export cswap
	push {r4-r11, lr}
	frame push {r4-r11, lr}

	rsb r2, #0
	
	; This cswap operates in two batches of five.
	; First read from both pointers
	ldm r0, {r3-r7}
	ldm r1, {r8-r12}
	
	; Create the dummy
	eor r8, r3
	eor r9, r4
	eor r10, r5
	eor r11, r6
	eor r12, r7
	
	; Apply the mask
	and r8, r2
	and r9, r2
	and r10 ,r2
	and r11 ,r2
	and r12 ,r2
	
	; Read from a again, apply the mask and write back
	ldm r0, {r3-r7}
	eor r3, r8
	eor r4, r9
	eor r5, r10
	eor r6, r11
	eor r7, r12
	stm r0!, {r3-r7}
	
	; Repeat for b
	ldm r1, {r3-r7}
	eor r3, r8
	eor r4, r9
	eor r5, r10
	eor r6, r11
	eor r7, r12
	stm r1!, {r3-r7}
	
	;Now repeat the entire procedure for the second batch
	ldm r0, {r3-r7}
	ldm r1, {r8-r12}
	eor r8, r3
	eor r9, r4
	eor r10, r5
	eor r11, r6
	eor r12, r7
	and r8, r2
	and r9, r2
	and r10 ,r2
	and r11 ,r2
	and r12 ,r2
	ldm r0, {r3-r7}
	eor r3, r8
	eor r4, r9
	eor r5, r10
	eor r6, r11
	eor r7, r12
	stm r0!, {r3-r7}
	ldm r1, {r3-r7}
	eor r3, r8
	eor r4, r9
	eor r5, r10
	eor r6, r11
	eor r7, r12
	stm r1!, {r3-r7}

	pop {r4-r11, pc}
	endp
	END
