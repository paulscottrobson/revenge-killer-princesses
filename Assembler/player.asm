; ************************************************************************************************************
; ************************************************************************************************************
;
;												Reset the Player
;
;	use RF.
; ************************************************************************************************************
; ************************************************************************************************************

ResetPlayer:
	lri 	rf,Player 															; initialise pointer, use RF as index
	sex 	rf
	ldi 	7*16+7																; player at (7,7)
	stxd
	ldi 	2 																	; direction 2 
	stxd

	return

; ************************************************************************************************************
; ************************************************************************************************************
;
;						Get Player Position as a result of a move in current direction +/- n
;										D is position RF points to the map
;
;	use RE,RF
; ************************************************************************************************************
; ************************************************************************************************************

GetPlayerNextCurrent:
	ldi 	0 																	; set offset to 0
GetPlayerNextOffset:
	sex 	r2
	str 	r2
	lri 	rf,Direction 														; load player direction.
	ldn 	rf
	add 	 																	; get into D + offset
	ani 	3 																	; force into a position.
	adi 	PlayerDirectionTable & 255 											; get an address in the table
	plo 	re 																	; point RE to that value.
	ldi 	PlayerDirectionTable / 256
	phi 	re
	lri 	rf,Player 															; point RF to the position.
	sex 	re 																	; R(X) points to the direction table
	ldn 	rf 																	; read position
	add 																		; add direction and exit.
	plo 	rf 																	; put in RF
	ldi 	Map/256 	
	phi 	rf 																	; point RF to the map entry
	glo 	rf 																	; restore D
	return
	br 		GetPlayerNextOffset 												; re-entrant into next offset.

PlayerDirectionTable:
	db 		1,16,-1,-16 														; direction -> offset table.

; ************************************************************************************************************
; ************************************************************************************************************
;
;		Draw player view at depth D (0 = outermost, 3 = innermost). Returns DF = 0 if can move forward.
;		D returned unchanged. Store new position at (RC) and increment RC.
;		  
;	Uses GetPlayerNextOffset (RE/RF) and DoorOpen(RE/RF). Runs in R4.
; ************************************************************************************************************
; ************************************************************************************************************

DrawPlayerViewAtDepth:
	plo 	r6 																	; save the depth in R6.

	lri 	r5,GetPlayerNextOffset												; call to identify left/right
	ldi 	-1 																	; can we look left ?
	recall 	r5    
	ldn 	rf 																	; get what's there into R7.0
	plo 	r7
	ldi 	1 																	; can we look right ?
	recall 	r5
	ldn 	rf 																	; get what's there into R7.1
	phi 	r7
	ldi 	0 																	; look ahead
	recall 	r5
	str 	rc 																	; save position at (RC)
	ldn 	rf 																	; get what's there into R8.0
	plo 	r8 	

	lri 	rf,Player 															; update the player position from R8.1
	ldn 	rc 																	; read read position and update it
	str 	rf
	inc 	rc 																	; increment position vector pointer.

	lri 	r5,DoorOpen 														; prepare to show open door.
	glo 	r7 																	; wall on left side ?
	shl
	bdf 	__DPVNoLeftWall
	glo 	r6 																	; open depth up
	recall 	r5 
__DPVNoLeftWall:
	ghi 	r7 																	; wall on right side ?
	shl
	bdf 	__DPVNoRightWall
	glo 	r6 																	; open 7-depth up.
	xri 	7
	recall 	r5
__DPVNoRightWall:
	glo 	r8 																	; get what's in front.
	shl 
	bnf 	__DPVExit 															; if clear exit with DF = 0

	glo 	r6 																	; calculate start position
	adi 	1 																	; move in one
	sex 	r2 																	; depth * 8 + depth
	str 	r2
	shl 																		; *8 * 4
	shl
	shl
	shl
	shl
	add 	 																	; *9
	plo 	rf 																	; set RF to point to first block. 
	ldi 	Display/256
	phi 	rf
	ldi 	0FFh 																; set writing value to $AA
	plo 	re
__DPVDrawWall:
	glo 	r6 																	; 0123 for depths
	xri 	3 																	; 3210 for depths
	shl 																		; 6420 for depths
	bz 		__DPVExitWall 														; if nothing to draw skip.
	plo 	r7
	glo 	rf 																	; save the start position of row.
	phi 	re	
__DPVDrawLine:
	glo 	re 																	; copy one wall piece over.
	str 	rf
	inc 	rf	
	dec 	r7 																	; do required number of times
	glo 	r7
	bnz 	__DPVDrawLine
	plo 	re 																	; draw spaces from here on.
	ghi 	re 																	; get start of line RE.1
	adi 	8
	plo 	rf 																	; point RF.0 one line down.
	shl
	bnf 	__DPVDrawWall 														; go back if not reached half way.
__DPVExitWall:
	ldi 	0FFh 																; set DF.
	shl
__DPVExit:
	glo 	r6 																	; restore D.
	return
	br 		DrawPlayerViewAtDepth

