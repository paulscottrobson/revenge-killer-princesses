; ************************************************************************************************************
; ************************************************************************************************************
;
;						Keyboard Scanner - returns Key_xxxx other values are ignored
;
;	Uses RE,RF
; ************************************************************************************************************
; ************************************************************************************************************

Key_Forward = 2 																; keyboard allocation 
Key_Left = 4 																	
Key_Right = 6
Key_Around = 8
Key_Fire = 15

ScanKeyboard:
	sex 	r2 																	; use R2 as index
	ldi 	15 																	; start scanning from key 'F'
	plo 	rf
__SKLoop:
	glo 	rf  																; write current value to keypad latch.
	dec 	r2 															
	str 	r2
	out 	2

	nop 																		; debounce time	 
	nop
	b3 		__SKExit
	glo 	rf 																	; get current checked
	dec 	rf 																	; do next
	bnz 	__SKLoop 															; back round if not just checked $0
__SKExit:
	glo 	rf 																	; return value in RF.
	return

