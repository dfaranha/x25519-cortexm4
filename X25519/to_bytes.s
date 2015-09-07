	AREA to_bytescode, CODE
	ENTRY

	; r0 destination bytes
	; r1 source element
to_bytes proc
	export to_bytes
	push {r4-r11, lr}
	frame push {r4-r11, lr}

	ldm r1, {r1-r10}

	; Reduce element mod p
	mov r14, #19
	mul r11, r10, r14
	add r11, r1, r11, asr #24
	add r11, r2, r11, asr #26
	add r11, r3, r11, asr #26
	add r11, r4, r11, asr #25
	add r11, r5, r11, asr #26
	add r11, r6, r11, asr #25
	add r11, r7, r11, asr #26
	add r11, r8, r11, asr #26
	add r11, r9, r11, asr #25
	add r11, r10, r11, asr #26
	asr r11, #24
	mla r1, r11, r14, r1

	; Compress back into 25.5 bit limbs
	; No need to subtract excess bits. No limbs are negative
	; since there was a full compression before in mul,
	; and rearranging to bytes means extra bits will be ignored.
	add r2, r1, asr #26
	add r3, r2, asr #26
	add r4, r3, asr #25
	add r5, r4, asr #26
	add r6, r5, asr #25
	add r7, r6, asr #26
	add r8, r7, asr #26
	add r9, r8, asr #25
	add r10, r9, asr #26

	; Rearrange into series of bytes
	; First word
	bfi r1, r2, #26, #6
	
	; Second word
	lsr r2, #6
	bfi r2, r3, #20, #12
	
	; Third word
	lsr r3, #12
	bfi r3, r4, #13, #19
	
	; Fourth word
	lsr r4, #19
	bfi r4, r5, #7, #25 	; same as orr with LSL #7

	; repeat for second half
	bfi r6, r7, #26, #6
	lsr r7, #6
	bfi r7, r8, #20, #12
	lsr r8, #12
	bfi r8, r9, #13, #19
	lsr r9, #19
	bfi r9, r10, #7, #24	; There's only 24 bits left in top limb

	stm r0, {r1-r4, r6-r9}

	pop {r4-r11, pc}
	endp
	END
