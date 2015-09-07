	AREA mulcode, CODE, ALIGN=3
	ENTRY

	; r0 destination
	; r1 multiplicand a
	; r2 multiplicand b
mul proc
	export mul
	push {r4-r11, lr}
	frame push {r4-r11, lr}
	push {r0-r2}
	sub sp, #120

	; setup for schoolbook F0G0
	mov r11, r2
	ldm r1, {r0-r4}
	ldm r11, {r5-r9}

	; This partial multiplier uses SP directly.
	; Doing so frees up r14, making 2 to 3 states fit
	; and allowing writes to RAM to be batched. 

	; F0G00
	; F0 * G0
	smull r10, r11, r0, r5

	; F0G01
	; F0 * G1 + F1 * G0
	smull r12, r14, r0, r6
	smlal r12, r14, r1, r5
	stm sp!, {r10-r12,r14}

	; F0G02
	; F0 * G2 + F1 * G1 + F2 * G0
	smull r10, r11, r0, r7
	smlal r10, r11, r1, r6
	smlal r10, r11, r2, r5

	; F0G03
	; (F1 * G2 + F2 * G1) * 2 + F3 * G0 + F0 * G3
	smull r12, r14, r1, r7
	smlal r12, r14, r2, r6
	adds r12, r12
	adc r14, r14
	smlal r12, r14, r3, r5
	smlal r12, r14, r0, r8
	stm sp!, {r10-r12,r14}

	; F0G04
	; F2 * G2 * 2 + F0 * G4 + F1 * G3 + F3 * G1 + F4 * G0
	smull r10, r11, r2, r7
	adds r10, r10
	adc r11, r11
	smlal r10, r11, r0, r9
	smlal r10, r11, r1, r8
	smlal r10, r11, r3, r6
	smlal r10, r11, r4, r5

	; F0G05
	; (F1 * G4 + F2 * G3 + F3 * G2 + F4 * G1) * 2
	smull r12, r14, r1, r9
	smlal r12, r14, r2, r8
	smlal r12, r14, r3, r7
	smlal r12, r14, r4, r6
	adds r12, r12
	adc r14, r14
	stm sp!, {r10-r12,r14}

	; F0G06
	; (F2 * G4 + F4 * G2) * 2 + F3 * G3
	smull r0, r1, r2, r9
	smlal r0, r1, r4, r7
	adds r0, r0
	adc r1, r1
	smlal r0, r1, r3, r8

	; F0G07
	; F3 * G4 + F4 * G3
	smull r10, r11, r3, r9
	smlal r10, r11, r4, r8

	; F0G08
	; F4 * G4 * 2
	smull r12, r14, r4, r9
	adds r12, r12
	adc r14, r14
	stm sp!, {r0-r1,r10-r12,r14}

	sub sp, #72

	; setup for schoolbook F1G1.
	; Subtraction F0G0 - 2^128 * F1G1 is interleaved in here.
	ldrd r10, r11, [sp, #124]
	add r10, #20		; point to second set of 5 limbs
	add r11, #20
	ldm r10, {r0-r4}
	ldm r11, {r5-r9}

	; compute F1G1
	; F1G10
	smull r10, r11, r0, r5
	ldrd r12, r14, [sp, #40]
	subs r12, r10
	sbc r14, r11
	strd r12, r14, [sp, #40]

	; F1G11
	smull r10, r11, r0, r6
	smlal r10, r11, r1, r5
	ldrd r12, r14, [sp, #48]
	subs r12, r10
	sbc r14, r11
	strd r12, r14, [sp, #48]	; store at tmp[6]

	; F1G12
	smull r10, r11, r0, r7
	smlal r10, r11, r1, r6
	smlal r10, r11, r2, r5
	ldrd r12, r14, [sp, #56]
	subs r12, r10
	sbc r14, r11
	strd r12, r14, [sp, #56]	; store at tmp[7]

	; F1G13
	smull r10, r11, r1, r7
	smlal r10, r11, r2, r6
	adds r10, r10
	adc r11, r11
	smlal r10, r11, r3, r5
	smlal r10, r11, r0, r8
	ldrd r12, r14, [sp, #64]
	subs r12, r10
	sbc r14, r11
	strd r12, r14, [sp, #64]	; store at tmp[8]

	; F1G14
	smull r10, r11, r2, r7
	adds r10, r10
	adc r11, r11
	smlal r10, r11, r0, r9
	smlal r10, r11, r1, r8
	smlal r10, r11, r3, r6
	smlal r10, r11, r4, r5
	strd r10, r11, [sp, #72]	; store at tmp[9], implicitly negated

	; For 5-8 not only is there subtraction,
	; F1G1x is also multiplied by 38. Luckily,
	; r0 (F1_0) and r5 (G1_0) are retired.
	; F1G15
	mov r0, #38
	smull r10, r11, r1, r9
	smlal r10, r11, r2, r8
	smlal r10, r11, r3, r7
	smlal r10, r11, r4, r6
	adds r10, r10
	adc r11, r11
	umull r10, r5, r10, r0
	mla r11, r11, r0, r5
	ldrd r12, r14, [sp, #0]
	subs r12, r10
	sbc r14, r11
	strd r12, r14, [sp, #0]	; store at tmp[0]

	; F1G16
	smull r10, r11, r2, r9
	smlal r10, r11, r4, r7
	adds r10, r10
	adc r11, r11
	smlal r10, r11, r3, r8
	umull r10, r5, r10, r0		; Does not register carry bit
	mla r11, r11, r0, r5
	ldrd r12, r14, [sp, #8]
	subs r12, r10
	sbc r14, r11
	strd r12, r14, [sp, #8]	; store at tmp[1]

	; F1G17
	smull r10, r11, r3, r9
	smlal r10, r11, r4, r8
	umull r10, r5, r10, r0
	mla r11, r11, r0, r5
	ldrd r12, r14, [sp, #16]
	subs r12, r10
	sbc r14, r11
	strd r12, r14, [sp, #16]	; store at tmp[2]

	; F1G18
	smull r10, r11, r4, r9
	adds r10, r10
	adc r11, r11
	umull r10, r5, r10, r0
	mla r11, r11, r0, r5
	ldrd r12, r14, [sp, #24]
	subs r12, r10
	sbc r14, r11
	strd r12, r14, [sp, #24]	; store at tmp[3]

	; subtract 2^128 * out from tmp
	; tmp10 through tmp14 = tmp5 through tmp9, implicitly negated
	add r10, sp, #40				; tmp[0] to tmp[5]
	ldm r10!, {r0-r9}
	stm r10, {r0-r9}
	sub r10, #80				; tmp[10] to tmp[0]
	ldm r10, {r6-r9,r11-r12}
	subs r0, r6
	sbc r1, r7
	subs r2, r8
	sbc r3, r9
	subs r4, r11
	sbc r5, r12
	add r10, #40				; tmp[0] to tmp[5]
	stm r10!, {r0-r5}			; tmp[5] to tmp[8]
	ldm r10, {r0-r3}
	sub r10, #40				; tmp[8] to tmp[3]
	ldm r10, {r4-r7}
	subs r0, r4
	sbc r1, r5
	adds r2, r6
	adc r3, r7
	add r10, #40				; tmp[3] to tmp[8]
	stm r10, {r0-r3}

	; Compute (F0 + F1)(G0 + G1), add to tmp
	ldrd r12, r14, [sp, #124]
	ldm r12, {r0-r9}
	add r0, r5
	add r1, r6
	add r2, r7
	add r3, r8
	add r4, r9
	push {r0-r4}
	ldm r14, {r0-r9}
	add r5, r0
	add r6, r1
	add r7, r2
	add r8, r3
	add r9, r4
	pop {r0-r4}

	; F0F1G0G10
	smull r10, r11, r0, r5
	ldrd r12, r14, [sp, #40]
	adds r12, r10
	adc r14, r11
	strd r12, r14, [sp, #40]	; store at tmp[5]

	; F0F1G0G11
	smull r10, r11, r0, r6
	smlal r10, r11, r1, r5
	ldrd r12, r14, [sp, #48]
	adds r12, r10
	adc r14, r11
	strd r12, r14, [sp, #48]	; store at tmp[6]

	; F0F1G0G12
	smull r10, r11, r0, r7
	smlal r10, r11, r1, r6
	smlal r10, r11, r2, r5
	ldrd r12, r14, [sp, #56]
	adds r12, r10
	adc r14, r11
	strd r12, r14, [sp, #56]	; store at tmp[7]

	; F0F1G0G13
	smull r10, r11, r1, r7
	smlal r10, r11, r2, r6
	adds r10, r10
	adc r11, r11
	smlal r10, r11, r3, r5
	smlal r10, r11, r0, r8
	ldrd r12, r14, [sp, #64]
	adds r12, r10
	adc r14, r11
	strd r12, r14, [sp, #64]	; store at tmp[8]

	; F0F1G0G14. Special: need to do F0F1G0G14 - out9 due to impl.neg.
	smull r10, r11, r2, r7
	adds r10, r10
	adc r11, r11
	smlal r10, r11, r0, r9
	smlal r10, r11, r1, r8
	smlal r10, r11, r3, r6
	smlal r10, r11, r4, r5
	ldrd r12, r14, [sp, #72]
	subs r10, r12
	sbc r11, r14
	strd r10, r11, [sp, #72]	; store at tmp[9]

	mov r0, #38

	; F0F1G0G15
	smull r10, r11, r1, r9
	smlal r10, r11, r2, r8
	smlal r10, r11, r3, r7
	smlal r10, r11, r4, r6
	adds r10, r10
	adc r11, r11
	ldrd r12, r14, [sp, #80]
	subs r12, r10
	sbc r14, r11
	umull r12, r5, r12, r0
	mla r14, r14, r0, r5
	ldrd r10, r11, [sp, #0]
	subs r10, r12
	sbc r11, r14
	strd r10, r11, [sp, #0]	; store at tmp[0]

	; F0F1G0G16
	smull r10, r11, r2, r9
	smlal r10, r11, r4, r7
	adds r10, r10
	adc r11, r11
	smlal r10, r11, r3, r8
	ldrd r12, r14, [sp, #88]
	subs r12, r10
	sbc r14, r11
	umull r12, r5, r12, r0
	mla r14, r14, r0, r5
	ldrd r10, r11, [sp, #8]
	subs r10, r12
	sbc r11, r14
	strd r10, r11, [sp, #8]	; store at tmp[1]

	; F0F1G0G17
	smull r10, r11, r3, r9
	smlal r10, r11, r4, r8
	ldrd r12, r14, [sp, #96]
	subs r12, r10
	sbc r14, r11
	umull r12, r5, r12, r0
	mla r14, r14, r0, r5
	ldrd r10, r11, [sp, #16]
	subs r10, r12
	sbc r11, r14
	strd r10, r11, [sp, #16]	; store at tmp[2]

	; F0F1G0G18
	smull r10, r11, r4, r9
	adds r10, r10
	adc r11, r11
	ldrd r12, r14, [sp, #104]
	subs r12, r10
	sbc r14, r11
	umull r12, r5, r12, r0
	mla r14, r14, r0, r5
	ldrd r10, r11, [sp, #24]
	subs r10, r12
	sbc r11, r14
	strd r10, r11, [sp, #24]	; store at tmp[3]

	; tmp4 += 38 * tmp14
	ldrd r1, r2, [sp, #32]
	ldrd r3, r4, [sp, #112]
	umull r3, r5, r3, r0
	mla r4, r4, r0, r5
	adds r1, r3
	adc r2, r4
	strd r1, r2, [sp, #32]

	; carry chain
	mov r14, sp
	ldm r14!, {r0-r11}

	; 0 -> 1
	lsr r12, r0, #26
	bfi r12, r1, #6, #26
	adds r2, r12
	adc r3, r1, asr #26
	sub r0, r12, LSL #26

	; 1 -> 2
	lsr r12, r2, #26
	bfi r12, r3, #6, #26
	adds r4, r12
	adc r5, r3, asr #26
	sub r2, r12, LSL #26

	; 2 -> 3
	lsr r12, r4, #25
	bfi r12, r5, #7, #25
	adds r6, r12
	adc r7, r5, asr #25
	sub r4, r12, LSL #25

	; 3 -> 4
	lsr r12, r6, #26
	bfi r12, r7, #6, #26
	adds r8, r12
	adc r9, r7, asr #26
	sub r6, r12, LSL #26

	; 4 -> 5
	lsr r12, r8, #25
	bfi r12, r9, #7, #25
	adds r10, r12
	adc r11, r9, asr #25
	sub r8, r12, LSL #25

	; 5 -> 6 (partial)
	lsr r12, r10, #26
	bfi r12, r11, #6, #26
	sub r10, r12, LSL #26
	mov r9, r12

	; Administration. Store results, load new elements
	ldr r12, [sp, #120]
	add r12, #8
	stm r12!, {r4,r6,r8,r10}
	mov r8, r0
	mov r10, r2
	ldm r14, {r0-r7}

	; 5 -> 6 (remainder)
	adds r0, r9
	adc r1, r11, asr #26

	; 6 -> 7
	lsr r11, r0, #26
	bfi r11, r1, #6, #26
	adds r2, r11
	adc r3, r1, asr #26
	sub r0, r11, LSL #26

	; 7 -> 8
	lsr r11, r2, #25
	bfi r11, r3, #7, #25
	adds r4, r11
	adc r5, r3, asr #25
	sub r2, r11, LSL #25

	; 8 -> 9
	lsr r11, r4, #26
	bfi r11, r5, #6, #26
	adds r6, r11
	adc r7, r5, asr #26
	sub r4, r11, LSL #26

	; 9 -> 0 (partial)
	lsr r11, r6, #25
	bfi r11, r7, #7, #25
	sub r6, r11, lsl #25
	asr r7, #25

	; elements 6 through 9 ready for storage to make some room
	stm r12, {r0,r2,r4,r6}

	; 9 -> 0 (remainder)
	; multiply carry by 38
	mov r14, #38
	umull r4, r6, r11, r14
	mla r5, r7, r14, r6
	; add carry to tmp0
	adds r0, r8, r4
	adc r1, r5, #0

	; 0 -> 1
	lsr r11, r0, #26
	bfi r11, r1, #6, #26
	sub r0, r11, lsl #26
	add r10, r11

	; Store 0 and 1
	strd r0, r10, [r12, #-24]!

	add sp, #132				; tmp + 3 arguments

	pop {r4-r11, pc}
	endp
	END
