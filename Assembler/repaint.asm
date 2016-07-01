; ************************************************************************************************************
; ************************************************************************************************************
;
;								Repaint whole display. No registers guaranteed
;	
; ************************************************************************************************************
; ************************************************************************************************************

Repaint:
	call 	r5,RepaintDisplayOutline 											; clear screen and draw walls

	lri 	rc,ppVector-1 														; point to player (vector -1)
	ldn 	rc 																	; read player position
	inc 	rc
	str 	rc 																	; save in vector[0]
	inc 	rc 																	; set up vector to point to 1st element

	lri 	r5,DrawPlayerViewAtDepth 											; draw maze at given depth
	ldi 	0 																	; draw at each level
	recall 	r5
	bdf 	__RepaintExit 														; abandon draw on solid wall
	ldi 	1
	recall 	r5
	bdf 	__RepaintExit
	ldi 	2
	recall 	r5
	bdf 	__RepaintExit
	ldi 	3
	recall 	r5
__RepaintExit:

	ldi 	(ppVector & 255)													; fix up the vector pointer to [0]
	plo 	rc
	ldn 	rc 																	; reread the first player position
	dec 	rc 																	; we changed it so copy it from the vector
	str 	rc 																	; update actual player position.

	call 	r5,MirrorDisplay 													; mirror top of display to bottom

	lri 	r5,DrawSpriteGraphic 
	ldi 	0
	recall 	r5
	recall 	r5
	ldi 	8
	recall 	r5
	recall 	r5
	
	; draw status.

	ldi 	Screen/256 															; not double buffered ?
	xri 	Buffer/256
	bz 		__RepaintNoCopy

	lri 	rf,Screen 															; copy buffer to screen.
	lri 	re,Buffer
	sex 	re
__RepaintCopy:
	ldxa
	str 	rf
	inc 	rf
	ldxa
	str 	rf
	inc 	rf
	glo 	rf
	bnz 	__RepaintCopy	
__RepaintNoCopy:
	return

; ************************************************************************************************************
; ************************************************************************************************************
;
;												Draw sprite graphic D
;
;	Uses RE,RF
; ************************************************************************************************************
; ************************************************************************************************************

DrawSpriteGraphic:
	dec		r2 																	; save at R2
	str 	r2
	shl 																		; double the sprite number
	adi 	SpriteData & 255 													; add to sprite address, put in RF
	plo 	rf
	ldi 	SpriteData / 256
	adci 	0
	phi 	rf
	lda 	rf 																	; read address into RE.
	phi 	re
	lda 	rf
	plo 	re 

	lda 	re 																	; read the start drawing address
	plo 	rf 																	; put into RF.
	ldi 	buffer/256 															; make into screen address
	phi 	rf
	sex 	re 																	; RX is data

__DSGLoop:
	ldn 	re 																	; read mask.
	xri 	0FFh 																; if $FF then finished
	bz 		__DSGFinished
	ldn 	rf 																	; read screen
	and 																		; and with mask
	inc 	re
	or 																			; or with data
	str 	rf 																	; write out.
	inc 	re 																	; next down
	glo 	rf 																	 
	adi 	8
	plo 	rf
	br 		__DSGLoop

__DSGFinished:
	lda 	r2
	adi 	1
	return


	br 		DrawSpriteGraphic

