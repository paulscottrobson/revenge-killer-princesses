
	include 1802.inc

display = 	0F00h																; this page has the display in it
map = 		0E00h 																; this page has the map in it.
stack = 	0DF0h 																; stack top

ppvector =  0DF9h																; player position vector.
player = 	0DF8h 																; player offset in map
direction = 0DF7h 																; 0 = right,1 = down, 2 = left, 3 = up

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

	call 	r4,CreateMaze
	call 	r4,ResetPlayer
Repaint:
	call 	r4,RepaintDisplay 													; clear screen and draw walls

	lri 	rc,ppVector-1 														; point to player (vector -1)
	ldn 	rc 																	; read player position
	inc 	rc
	str 	rc 																	; save in vector[0]
	inc 	rc 																	; set up vector to point to 1st element
	lri 	r4,DrawPlayerViewAtDepth 

	ldi 	0
	recall 	r4
	bdf 	__RepaintExit
	ldi 	1
	recall 	r4
	bdf 	__RepaintExit
	ldi 	2
	recall 	r4
	bdf 	__RepaintExit
	ldi 	3
	recall 	r4
__RepaintExit:
	ldi 	(ppVector & 255)													; fix up the vector pointer to [0]
	plo 	rc
	ldn 	rc 																	; reread the first player position
	dec 	rc
	str 	rc 																	; update actual player position.

	call 	r4,MirrorDisplay 													; mirror top of display to bottom

	; draw princess
	; draw status.

	lri 	r4,Direction
	ldn 	r4
	adi 	1
	ani 	3
	str 	r4

	lri 	r4,40000
delay:
	dec 	r4
	ghi 	r4
	bnz 	delay	
	br 		Repaint
wait:
	br 		wait

	org 	100h

code:
;
;	Block 0
;
	include interrupt.asm														; screen driver ($1E)
	include maze.asm 															; maze creator & RNG ($7B)
	include repaint.asm 														; repaint outline/mirror ($64)
;
;	Block 1
;
	org 	code+100h
	include door.asm 															; door "opening" code. ($3C)
	include player.asm 															; player reset and depth view ()
;
;	TODO: 	
;			Put princesses in the maze.
;			Add visual on princesses
;			Add basic control ?
