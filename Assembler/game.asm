; ************************************************************************************************************
; ************************************************************************************************************
;
;									Revenge of the Killer Princesses
;									================================
;
;								  Written by Paul Robson June/July 2016
;	
;	  Written for the Cosmac VIP but should port to other 1802/1861 devices with sufficient RAM memory.
;
; ************************************************************************************************************
; ************************************************************************************************************

	include 1802.inc

screen =  	0F00h																; this is the display screen.
buffer = 	0E00h																; this page has the buffer in it
map = 		0D00h 																; this page has the map in it.
stack = 	0CF0h 																; stack top

ppvector =  0CF9h																; player position vector.
player = 	0CF8h 																; player offset in map
direction = 0CF7h 																; 0 = right,1 = down, 2 = left, 3 = up

	ret 																		; 1802 interrupts on. 
	nop
	lri 	r1,Interrupt 														; set interrupt vector
	lri 	r2,Stack 															; set stack address
	ldi 	Main & 255 															; switch to R3 as program pointer
	plo 	r3
	sep 	r3 																	; go to main routine
Main:
	sex 	r2 																	; turn video on
	inp		1

; ************************************************************************************************************
; ************************************************************************************************************
;
;											Initialisation code
;
; ************************************************************************************************************
; ************************************************************************************************************

	call 	r4,CreateMaze 														; create the maze
	call 	r4,ResetPlayer 														; reset the player

	lri 	r4, map+075h
	ldi 	1
	str 	r4

Loop:
	call 	r4,Repaint
	lri 	r4,Direction
	ldn 	r4
	adi 	1
	ani 	3
	str 	r4
	inc 	r8
	br 		Loop

wait:
	br 		wait

	org 	100h

code:
;
;	Block 0
;
	include interrupt.asm														; screen driver ($1E)
	include maze.asm 															; maze creator & RNG ($7B)
	include drawing.asm 														; repaint outline/mirror ($64)
;
;	Block 1
;
	org 	code+100h
	include door.asm 															; door "opening" code. ($3C)
	include player.asm 															; player reset/depth view ($B0)
;
;	Block 2
;
	org	 	code+200h
	include repaint.asm 														; repaint ($8B)
	include sprites.asm 														; sprite drawing ($30)

	org  	stack-240h 															; put gfx data at the end.	
SpriteData:	
	include graphics.inc 														

;	TODO: 	
; 			Player Movement
; 			Add closeness sound effect / heartbeat
;			Princess movement (for arbitrary placed princess)
;			Put princesses in the maze.
