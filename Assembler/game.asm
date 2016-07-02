; ************************************************************************************************************
; ************************************************************************************************************
;
;									Revenge of the Killer Princesses
;									================================
;
;								  Written by Paul Robson June/July 2016
;	
;	  Written for the Cosmac VIP but should port to other 1802/1861 devices with sufficient RAM memory.
;	  Main porting issue is the keyboard routine.
;
; ************************************************************************************************************
; ************************************************************************************************************

	include 1802.inc

screen =  	0F00h																; this is the display screen.
buffer = 	0E00h																; this page has the buffer in it
map = 		0D00h 																; this page has the map in it.
stack = 	0CF0h 																; stack top

timers = 	0CFCh 																; 4 timers must end at page top.
ppvector =  0CF4h																; player position vector.
player = 	0CF3h 																; player offset in map
direction = 0CF2h 																; 0 = right,1 = down, 2 = left, 3 = up

moveTimer = timers 																; first timer controls move/turn.
fireTimer = timers+1 															; second timer controls firing

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
	call	r4,MovePlayer
	br 		Loop

	org 	100h

code:
;
;	Block 0
;
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
	include interrupt.asm														; screen driver ($1E)
;
; 	Block 3 
;
	org 	code+300h
	include move.asm

	org  	0A80h 																; put gfx data at the end.	
	include keyboard.asm  														; keyboard driver here so can port.
SpriteData:	
	include graphics.inc 														; all the graphic data

;	TODO: 	
;			Shooting effect (think ....)
;			Shooting Princesses :) 
; 			Add closeness sound effect / heartbeat.
;			Put princesses in the maze.
;			Princess movement (for arbitrary placed princess)
