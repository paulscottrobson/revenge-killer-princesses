; ************************************************************************************************************
; ************************************************************************************************************
;
;											Heartbeat (now meter) code
;
; ************************************************************************************************************
; ************************************************************************************************************

; ************************************************************************************************************
; ************************************************************************************************************
;
;			Calculate minimum distance of nearest princess, also clears bit 6 (move processed)
;
; ************************************************************************************************************
; ************************************************************************************************************

CalculateHeartbeat:
	dec 	r2 																	; make a spot on the stack
	sex 	r2

	lri 	rf,player 															; read player position into RF.1
	ldn 	rf
	phi 	rf
	ldi 	12 																	; best distance in RF.0
	plo 	rf
	lri 	re,map 																; RE points to map.
__CHLoop:
	ldn 	re 																	; read and advance
	ani 	7Fh 																; is there a princess here
	bz 		__CHNext 															; no, go to next

	ldn 	re 																	; clear bit 6 (has moved) flag
	ani 	0BFh
	str 	re

	glo 	re 																	; get princess X
	ani 	0Fh
	str 	r2
	ghi 	rf 																	; subtract player X
	ani 	0Fh
	sd
	bdf 	__CHNotMinusX  														; calculate |dx|
	sdi 	0
__CHNotMinusX:
	phi 	rd 																	; save in RD

	glo 	re 																	; get princess Y
	shr
	shr
	shr
	shr
	str 	r2
	ghi 	rf 																	; subtract princess Y
	shr
	shr
	shr
	shr
	sd 
	bdf 	__CHNotMinusY 														; calculate |dy|
	sdi 	0
__CHNotMinusY:
	str 	r2 																	; calculate |dx|+|dy|
	ghi 	rd
	add 	
	str 	r2
	glo 	rf 																	; calculate best so far - sum
	sm 
	bnf   	__CHNext 															; not best to date
	ldn 	r2																	; get sum back
	plo 	rf 																	; its the new best score.
__CHNext:
	inc 	re 																	; next square
	glo		re 																	; go back if not done all princesses.
	bnz 	__CHLoop

	;	now RF.0 is the distance from the nearest princess, maximum of 10.

	glo 	rf 																	; get RF (0-10)
	sdi 	12 																	; this is the number of half bars to draw.
	plo 	rf

	lri 	re,buffer+8+1

__CHDrawMarker: 																; do in blocks of 8.
	glo 	rf
	ani 	0FEh
	bz 		__CHEndSolid
	dec 	rf
	dec 	rf
	ldi 	0AAh
	str 	re
	inc 	re
	br 		__CHDrawMarker

__CHEndSolid:
	glo 	rf
	bz 		__CHExit
	ldi 	0A0h
	str 	re

__CHExit:
	inc 	r2 																	; dump work byte from stack.
	return