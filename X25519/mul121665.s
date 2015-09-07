	AREA mul121665code, CODE
	ENTRY

	; r0 destination element
	; r1 source element
mul121665 proc
	export mul121665
	push {r4-r11, lr}
	frame push {r4-r11, lr}

	push {r0}
	ldm r1, {r0-r9}
	ldr r14, =121665
	smull r0, r10, r0, r14

	; 0 -> 1
	lsr r12, r0, #26
	bfi r12, r10, #6, #26
	sub r0, r12, LSL #26
	smull r1, r11, r1, r14
	adds r1, r12
	adc r11, r10, ASR #26

	; 1 -> 2
	lsr r12, r1, #26
	bfi r12, r11, #6, #26
	sub r1, r12, LSL #26
	smull r2, r10, r2, r14
	adds r2, r12
	adc r10, r11, ASR #26

	; 2 -> 3
	lsr r12, r2, #25
	bfi r12, r10, #7, #25
	sub r2, r12, LSL #25
	smull r3, r11, r3, r14
	adds r3, r12
	adc r11, r10, ASR #25

	; 3 -> 4
	lsr r12, r3, #26
	bfi r12, r11, #6, #26
	sub r3, r12, LSL #26
	smull r4, r10, r4, r14
	adds r4, r12
	adc r10, r11, ASR #26
	
	; 4 -> 5
	lsr r12, r4, #25
	bfi r12, r10, #7, #25
	sub r4, r12, LSL #25
	smull r5, r11, r5, r14
	adds r5, r12
	adc r11, r10, ASR #25
	
	; 5 -> 6
	lsr r12, r5, #26
	bfi r12, r11, #6, #26
	sub r5, r12, LSL #26
	smull r6, r10, r6, r14
	adds r6, r12
	adc r10, r11, ASR #26
	
	; 6 -> 7
	lsr r12, r6, #26
	bfi r12, r10, #6, #26
	sub r6, r12, LSL #26
	smull r7, r11, r7, r14
	adds r7, r12
	adc r11, r10, ASR #26
	
	; 7 -> 8
	lsr r12, r7, #25
	bfi r12, r11, #7, #25
	sub r7, r12, LSL #25
	smull r8, r10, r8, r14
	adds r8, r12
	adc r10, r11, ASR #25
	
	; 8 -> 9
	lsr r12, r8, #26
	bfi r12, r10, #6, #26
	sub r8, r12, LSL #26
	smull r9, r11, r9, r14
	adds r9, r12
	adc r11, r10, ASR #26
	
	; 9 -> 0
	; get full carry, sub from el9
	lsr r10, r9, #25
	bfi r10, r11, #7, #25
	asr r11, r11, #25
	sub r9, r10, LSL #25

	; multiply carry by 38, add to el0 (extend to doubleword)
	mov r14, #38
	umull r10, r12, r10, r14
	mla r11, r11, r14, r12

	adds r0, r10
	adc r10, r11, #0

	; 0 -> 1
	; get half-carry, add to el1
	lsr r11, r0, #26
	bfi r11, r10, #6, #26
	add r1, r11
	sub r0, r11, LSL #26

	pop {r10}
	stm r10, {r0-r9}

	pop {r4-r11, pc}
	endp
	END
