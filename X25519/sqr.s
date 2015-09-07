	AREA sqrcode, CODE
	ENTRY

	; r0 destination element
	; r1 source element
sqr proc
	export sqr
	push {r4-r11, lr}
	frame push {r4-r11, lr}

	sub sp, #128
	strd r1, r0, [sp, #120]
	mov r14, sp

	ldm r1, {r0-r4}

	; F0F00
	smull r5, r6, r0, r0
	
	; F0F01
	smull r7, r8, r0, r1
	adds r7, r7
	adc r8, r8

	; F0F02
	smull r9, r10, r0, r2
	adds r9, r9
	adc r10, r10
	smlal r9, r10, r1, r1

	stm r14!, {r5-r10}

	; F0F03
	smull r5, r6, r1, r2
	adds r5, r5
	adc r6, r6
	smlal r5, r6, r0, r3
	adds r5, r5
	adc r6, r6

	; F0F04
	smull r7, r8, r0, r4
	smlal r7, r8, r1, r3
	smlal r7, r8, r2, r2
	adds r7, r7
	adc r8, r8

	; F0F05
	smull r9, r10, r1, r4
	smlal r9, r10, r2, r3
	lsl r10, r10, #2
	orr r10, r9, LSR #30
	lsl r9, r9, #2

	stm r14!, {r5-r10}

	; F0F06
	smull r5, r6, r2, r4
	lsl r6, r6, #2
	orr r6, r5, LSR #30
	lsl r5, r5, #2
	smlal r5, r6, r3, r3

	; F0F07
	smull r7, r8, r3, r4
	adds r7, r7
	adc r8, r8

	; F0F08
	smull r9, r10, r4, r4
	adds r9, r9
	adc r10, r10

	stm r14, {r5-r10}

	; Compute F1F1, fold in with tmp, reduced
	ldr r0, [sp, #120]
	add r0, #20
	ldm r0, {r0-r4}
	
	; F1F10
	smull r5, r6, r0, r0
	ldrd r11, r12, [sp, #40]
	subs r5, r11, r5
	sbc r6, r12, r6

	; F1F11
	smull r7, r8, r0, r1
	adds r7, r7
	adc r8, r8
	ldrd r11, r12, [sp, #48]
	subs r7, r11, r7
	sbc r8, r12, r8

	; F1F12
	smull r9, r10, r0, r2
	adds r9, r9
	adc r10, r10
	smlal r9, r10, r1, r1
	ldrd r11, r12, [sp, #56]
	subs r9, r11, r9
	sbc r10, r12, r10
	
	add r14, sp, #40
	stm r14!, {r5-r10}
	
	; F1F13
	smull r5, r6, r1, r2
	adds r5, r5
	adc r6, r6
	smlal r5, r6, r0, r3
	adds r5, r5
	adc r6, r6
	ldrd r11, r12, [sp, #64]
	subs r5, r11, r5
	sbc r6, r12, r6
	
	; F1F14
	smull r7, r8, r0, r4
	smlal r7, r8, r1, r3
	smlal r7, r8, r2, r2
	adds r7, r7
	adc r8, r8

	stm r14, {r5-r8}
	mov r0, #38

	; F1F15
	smull r5, r6, r1, r4
	smlal r5, r6, r2, r3
	lsl r6, r6, #2
	orr r6, r5, LSR #30
	lsl r5, r5, #2
	umull r5, r14, r5, r0
	mla r6, r6, r0, r14
	ldrd r11, r12, [sp, #0]
	subs r5, r11, r5
	sbc r6, r12, r6

	; F1F16
	smull r7, r8, r2, r4
	lsl r8, r8, #2
	orr r8, r7, LSR #30
	lsl r7, r7, #2
	smlal r7, r8, r3, r3
	umull r7, r14, r7, r0
	mla r8, r8, r0, r14
	ldrd r11, r12, [sp, #8]
	subs r7, r11, r7
	sbc r8, r12, r8

	; F1F17
	smull r9, r10, r3, r4
	adds r9, r9
	adc r10, r10
	umull r9, r14, r9, r0
	mla r10, r10, r0, r14
	ldrd r11, r12, [sp, #16]
	subs r9, r11, r9
	sbc r10, r12, r10

	; F1F18
	smull r11, r12, r4, r4
	adds r11, r11
	adc r12, r12
	umull r11, r14, r11, r0
	mla r12, r12, r0, r14
	ldrd r1, r2, [sp, #24]
	subs r11, r1, r11
	sbc r12, r2, r12

	stm sp, {r5-r12}

	; Compute tmp - 2^128tmp, nonreduced
	add r14, sp, #40		; tmp5
	ldm r14!, {r0-r9}
	stm r14, {r0-r9}
	ldm sp, {r10-r12,r14}
	subs r0, r10
	sbc r1, r11
	subs r2, r12
	sbc r3, r14
	add r14, sp, #40
	stm r14, {r0-r3}
	add r14, sp, #16
	ldm r14, {r0-r3, r10-r11}
	subs r4, r0
	sbc r5, r1
	subs r6, r2
	sbc r7, r3
	adds r8, r10
	adc r9, r11
	add r14, sp, #56
	stm r14, {r4-r9}

	; Compute (F0+F1)(F0+F1) and add to tmp, reduced
	ldr r14, [sp, #120]
	ldm r14, {r0-r9}
	add r0, r5
	add r1, r6
	add r2, r7
	add r3, r8
	add r4, r9
	
	add r14, sp, #40
	
	; F01F010
	smull r5, r6, r0, r0
	ldrd r11, r12, [sp, #40]
	adds r5, r11
	adc r6, r12

	; F01F011
	smull r7, r8, r0, r1
	adds r7, r7
	adc r8, r8
	ldrd r11, r12, [sp, #48]
	adds r7, r11
	adc r8, r12

	; F01F012
	smull r9, r10, r0, r2
	adds r9, r9
	adc r10, r10
	smlal r9, r10, r1, r1
	ldrd r11, r12, [sp, #56]
	adds r9, r11
	adc r10, r12

	stm r14!, {r5-r10}

	; F01F013
	smull r5, r6, r1, r2
	adds r5, r5
	adc r6, r6
	smlal r5, r6, r0, r3
	adds r5, r5
	adc r6, r6
	ldrd r11, r12, [sp, #64]
	adds r5, r11
	adc r6, r12

	; F01F014
	smull r7, r8, r0, r4
	smlal r7, r8, r1, r3
	smlal r7, r8, r2, r2
	adds r7, r7
	adc r8, r8
	ldrd r11, r12, [sp, #72]
	subs r7, r11
	sbc r8, r12

	; F01F015
	smull r9, r10, r1, r4
	smlal r9, r10, r2, r3
	lsl r10, r10, #2
	orr r10, r9, LSR #30
	lsl r9, r9, #2
	ldrd r11, r12, [sp, #80]
	subs r0, r11, r9
	sbc r1, r12, r10

	stm r14!, {r5-r8}
	
	; F01F016
	smull r5, r6, r2, r4
	lsl r6, r6, #2
	orr r6, r5, LSR #30
	lsl r5, r5, #2
	smlal r5, r6, r3, r3
	ldrd r11, r12, [sp, #88]
	subs r5, r11, r5
	sbc r6, r12, r6

	; F01F017
	smull r7, r8, r3, r4
	adds r7, r7
	adc r8, r8
	ldrd r11, r12, [sp, #96]
	subs r7, r11, r7
	sbc r8, r12, r8
	
	; F01F018
	smull r9, r10, r4, r4
	adds r9, r9
	adc r10, r10
	ldrd r11, r12, [sp, #104]
	subs r9, r11, r9
	sbc r10, r12, r10

	; Perform reduction.
	;tmp10 is at r0, r1. tmp11-13 are r5-r10

	mov r14, #38

	; Multiply tmp10 through tmp12 by 38
	umull r0, r12, r0, r14
	mla r1, r1, r14, r12
	umull r5, r12, r5, r14
	mla r6, r6, r14, r12
	umull r7, r12, r7, r14
	mla r8, r8, r14, r12
	
	; Bring in tmp0-tmp2, subtract, store
	ldm sp, {r2-r4,r11,r12,r14}
	subs r0, r2, r0
	sbc r1, r3, r1
	subs r2, r4, r5
	sbc r3, r11, r6
	subs r4, r12, r7
	sbc r5, r14, r8
	stm sp, {r0-r5}
	
	; bring in tmp3, tmp4, tmp14, multiply tmp13,tmp14, subtract/add, store
	ldrd r11, r12, [sp, #112]
	add r14, sp, #24
	ldm r14, {r0-r3}
	mov r8, #38
	umull r9, r7, r9, r8
	mla r10, r10, r8, r7
	umull r11, r7, r11, r8
	mla r12, r12, r8, r7
	subs r0, r0, r9
	sbc r1, r1, r10
	adds r2, r11
	adc r3, r12
	stm r14, {r0-r3}

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
	; r9 is carryL, r11 is carryH
	
	; Administration. Store results, load new elements
	ldr r12, [sp, #124]
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

	add sp, #128
	pop {r4-r11, pc}
	endp
	END
