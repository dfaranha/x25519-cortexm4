	AREA invertdata, DATA
	ALIGN

t0 space 40
t1 space 40
t2 space 40
t3 space 40

	AREA invertcode, CODE
	ENTRY

	extern mul
	extern sqr

	; r0 destination element
	; r1 source element
invert proc
	export invert
	push {r4-r11, lr}
	frame push {r4-r11, lr}

	mov r4, r0			; out
	mov r5, r1			; in
	ldr r6, =t0
	ldr r7, =t1
	ldr r8, =t2
	ldr r9, =t3

	; sqr(t0,in);
	mov r0, r6
	bl sqr

    ; sqr(t1,t0);
	mov r0, r7
	mov r1, r6
	bl sqr

    ; sqr(t1,t1);
	mov r0, r7
	mov r1, r7
	bl sqr

    ; mul(t1,in,t1);
	mov r0, r7
	mov r1, r5
	mov r2, r7
	bl mul

    ; mul(t0,t0,t1);
	mov r0, r6
	mov r1, r6
	mov r2, r7
	bl mul

	; sqr(t2,t0);
	mov r0, r8
	mov r1, r6
	bl sqr

    ; mul(t1,t1,t2);
	mov r0, r7
	mov r1, r7
	mov r2, r8
	bl mul

	; sqr(t2,t1);
	mov r0, r8
	mov r1, r7
	bl sqr

    ; for (i = 1;i < 5;++i)
    ;     sqr(t2,t2);
	mov r10, #4
loop0
	mov r0, r8
	mov r1, r8
	bl sqr
	subs r10, #1
	bne loop0

    ; mul(t1,t2,t1);
	mov r0, r7
	mov r1, r8
	mov r2, r7
	bl mul

    ; sqr(t2,t1);
    mov r0, r8
	mov r1, r7
	bl sqr

    ; for (i = 1;i < 10;++i)
    ;     sqr(t2,t2);
	mov r10, #9
loop1
	mov r0, r8
	mov r1, r8
	bl sqr
	subs r10, #1
	bne loop1

    ; mul(t2,t2,t1);
	mov r0, r8
	mov r1, r8
	mov r2, r7
	bl mul

    ; sqr(t3,t2);
    mov r0, r9
	mov r1, r8
	bl sqr

    ; for (i = 1;i < 20;++i)
    ;     sqr(t3,t3);
	mov r10, #19
loop2
	mov r0, r9
	mov r1, r9
	bl sqr
	subs r10, #1
	bne loop2

    ; mul(t2,t3,t2);
	mov r0, r8
	mov r1, r9
	mov r2, r8
	bl mul

    ; sqr(t2,t2);
	mov r0, r8
	mov r1, r8
	bl sqr

    ; for (i = 1;i < 10;++i)
    ;     sqr(t2,t2);
	mov r10, #9
loop3
	mov r0, r8
	mov r1, r8
	bl sqr
	subs r10, #1
	bne loop3

    ; mul(t1,t2,t1);
	mov r0, r7
	mov r1, r8
	mov r2, r7
	bl mul

    ; sqr(t2,t1);
	mov r0, r8
	mov r1, r7
	bl sqr

    ; for (i = 1;i < 50;++i)
    ;     sqr(t2,t2);
	mov r10, #49
loop4
	mov r0, r8
	mov r1, r8
	bl sqr
	subs r10, #1
	bne loop4

    ; mul(t2,t2,t1);
	mov r0, r8
	mov r1, r8
	mov r2, r7
	bl mul

    ; sqr(t3,t2);
    mov r0, r9
	mov r1, r8
	bl sqr

    ; for (i = 1;i < 100;++i)
    ;     sqr(t3,t3);
	mov r10, #99
loop5
	mov r0, r9
	mov r1, r9
	bl sqr
	subs r10, #1
	bne loop5

    ; mul(t2,t3,t2);
	mov r0, r8
	mov r1, r9
	mov r2, r8
	bl mul


    ; sqr(t2,t2);
	mov r0, r8
	mov r1, r8
	bl sqr

    ; for (i = 1;i < 50;++i)
    ;     sqr(t2,t2);
	mov r10, #49
loop6
	mov r0, r8
	mov r1, r8
	bl sqr
	subs r10, #1
	bne loop6
	
    ; mul(t1,t2,t1);
	mov r0, r7
	mov r1, r8
	mov r2, r7
	bl mul

    ;  sqr(t1,t1);
	mov r0, r7
	mov r1, r7
	bl sqr

    ; for (i = 1;i < 5;++i)
    ;     sqr(t1,t1);
	mov r10, #4
loop7
	mov r0, r7
	mov r1, r7
	bl sqr
	subs r10, #1
	bne loop7

    ; mul(out,t1,t0);
	mov r0, r4
	mov r1, r7
	mov r2, r6
	bl mul

	pop {r4-r11, pc}
	endp
	END
