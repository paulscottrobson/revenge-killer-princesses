
	cpu 	1802


display = 00Fh																	; this page has the display in it
map = 00Eh 																		; this page has the map in it.
stack = 00Dh 																	; this page has the stack in it.

r0 = 0
r1 = 1
r2 = 2
r3 = 3
r4 = 4
r5 = 5
r6 = 6
r7 = 7
r8 = 8
r9 = 9
rf = 15

	ghi 	r0
	phi		r1

	ldi 	stack
	phi		r2
	ldi 	0FFh
	plo 	r2

	ldi 	Main / 256
	phi 	r3
	ldi 	Main & 255
	plo 	r3

	ldi 	Interrupt / 256
	phi 	r1
	ldi 	Interrupt & 255
	plo 	r1

	sex 	r2
	inp		1

	sep 	r3

Return:
	ldxa
	ret
Interrupt:
	dec 	r2
	sav
	dec 	r2
	str 	r2
	nop
	nop
	nop
	ldi 	display
	phi 	r0
	ldi 	0
	plo 	r0
Refresh:
	glo 	r0
	sex 	r2

	sex 	r2
	dec 	r0
	plo 	r0

	sex 	r2
	dec 	r0
	plo 	r0

	sex 	r2
	dec 	r0
	plo 	r0

	bn1 	Refresh
	br 		Return

	org 	0100h

Main:

; ************************************************************************************************************
; ************************************************************************************************************
;
;												Repaint entire display
;
; ************************************************************************************************************
; ************************************************************************************************************

RepaintDisplay:
	ldi 	display 															; r4 points to display position.
	phi 	r4 																	; so does R5 as we're going to clear it
	phi 	r5 																	; the top half of the screen
	ldi 	0
	plo 	r4
	plo 	r5
_RDClear:
	glo 	r4 																	; R4.0 is zero
	str 	r5 																	; fill display RAM with it.
	inc 	r5
	glo 	r5
	shlc 																		; only do it half way as we copy
	bnf 	_RDClear 															; the bottom half.

; ************************************************************************************************************
;									    Come back here to reset the masks
; ************************************************************************************************************

RepaintDisplayResetMasks:
	ldi 	0C0h 																; r7.0 is 11000000 (left write)
	plo 	r7
	ldi 	3 																	; r7.1 is 00000011 (right write)
	phi 	r7

; ************************************************************************************************************
;				Main repaint loop. R4 points to the line position. R7.0 left mask R7.1 right mask
; ************************************************************************************************************

RepaintDisplayLoop:
	ghi		r4 																	; copy R4.1 to R5.1 and R6.1
	phi 	r5 																	
	phi 	r6
	glo 	r4 																	; are there no solid blocks yet ?
	ani 	7
	bz 		RepaintNoSolid
	glo 	r4 																	; R5.0 will point to left bit
	plo 	r5
	xri 	7																	; R5.1 will point to right bit
	plo 	r6																	
	dec 	r5

PaintSolidBlocks:
	ldi 	0FFh 																; write solid block on left.
	str 	r5
	str 	r6
	dec 	r5 																	; move left left and right right
	inc 	r6
	glo 	r6 																	; if right hasn't wrapped around
	ani 	7
	bnz 	PaintSolidBlocks
RepaintNoSolid:

	glo 	r4 																	; set R5 and R6 to point to write
	plo 	r5
	xri 	7
	plo 	r6

	glo 	r4 																	; point R4 to the next line.
	adi 	8
	plo 	r4

	glo 	r7																	; write left mask
	str 	r5
	shrc 																		; update the left mask.
	shrc	
	ori 	0C0h
	plo 	r7

	ghi 	r7 																	; write right mask
	str 	r6
	shlc 																		; update the right mask.
	shlc 
	ori 	3
	phi	 	r7

	bnf 	RepaintDisplayLoop
	inc 	r4 																	; step out 1.
	glo 	r4 																	; if not half way down loop back.
	shlc
	bnf 	RepaintDisplayResetMasks

; ************************************************************************************************************
;									Now copy top half to bottom half upside down
; ************************************************************************************************************
	
	ldi 	Display 															; R4 points to screen top
	phi 	r4 
	ldi 	0  															
	plo 	r4 
MirrorLoop:
	glo 	r4 																	; set up bottom pointer r5
	xri 	0F8h
	plo 	r5	
	ghi	 	r4
	phi 	r5
	lda 	r4 																	; copy data bumping R4
	str 	r5
	inc 	r5
	glo 	r4
	shlc 	
	bnf 	MirrorLoop

wait:
	br 		wait
	