	AREA from_bytescode, CODE
	ENTRY

	; r0 destination element
	; r1 source bytes
from_bytes proc
	export from_bytes
	push {r4-r11, lr}
	frame push {r4-r11, lr}

	ldm r1, {r5-r12}

	; Fill up first limb
	ubfx r2, r5, #0, #26
	
	; Second limb.
	ubfx r3, r5, #26, #6
	bfi r3, r6, #6, #20
	
	; Third limb
	ubfx r4, r6, #20, #12
	bfi r4, r7, #12, #13

	; Fourth limb
	ubfx r5, r7, #13, #19
	bfi r5, r8, #19, #7
	
	; Fifth limb
	ubfx r6, r8, #7, #25

	; The pattern repeats for the top 5 limbs
	ubfx r7, r9, #0, #26

	ubfx r8, r9, #26, #6
	bfi r8, r10, #6, #20

	ubfx r9, r10, #20, #12
	bfi r9, r11, #12, #13

	ubfx r10, r11, #13, #19
	bfi r10, r12, #19, #7

    ; extract 24 instead of 25 bits because MUST ignore top bit
	ubfx r11, r12, #7, #24

	stm r0, {r2-r11}
	mov r0, #0

	pop {r4-r11, pc}
	endp
	END
