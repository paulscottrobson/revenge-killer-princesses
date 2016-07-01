// *******************************************************************************************************************************
// *******************************************************************************************************************************
//
//		Name:		hardware.cpp
//		Purpose:	Hardware Interface
//		Created:	26th June 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// *******************************************************************************************************************************
// *******************************************************************************************************************************

#include <stdlib.h>
#include "sys_processor.h"
#include "hardware.h"

#ifdef WINDOWS
#include "gfx.h"																// Want the keyboard access.
#endif

static WORD16 videoMemoryAddress = 0xFFFF;										// 1802 Video Memory Address
static BYTE8  screenIsOn = 0;													// 1861 turned on
static BYTE8  keypadLatch = 0;													// 74922 keyboard latch (Elf)
static BYTE8  ledDisplay = 0;													// 8 LED / 2 Digit display (Elf)

// *******************************************************************************************************************************
//													Hardware Reset
// *******************************************************************************************************************************

void HWIReset(void) {
}

// *******************************************************************************************************************************
//											Process keys passed from debugger
// *******************************************************************************************************************************

BYTE8 HWIProcessKey(BYTE8 key,BYTE8 isRunMode) {
	if (isRunMode) {															// In run mode, push 0-9 A-F
		if (key >= '0' && key <= '9') 											// into keyboard latch.
			keypadLatch = (keypadLatch << 4) | (key - '0');
		if (key >= 'a' && key <= 'f')
			keypadLatch = (keypadLatch << 4) | (key - 'a' + 10);
	}
	return key;
}

// *******************************************************************************************************************************
//									Get/Set the 7 Segment Display And/Or LEDs
// *******************************************************************************************************************************

void HWISetDigitDisplay(BYTE8 led) {
	ledDisplay = led;
}

BYTE8 HWIGetDigitDisplay(void) {
	return ledDisplay;
}

// *******************************************************************************************************************************
//							Get/Set the page address (1802 and Physical) for the video.
// *******************************************************************************************************************************

void HWISetPageAddress(WORD16 r0) {
	videoMemoryAddress = r0;
}

WORD16 HWIGetPageAddress(void) {
	return videoMemoryAddress;
}

// *******************************************************************************************************************************
//											Get/Set the screen on flag
// *******************************************************************************************************************************

void HWISetScreenOn(BYTE8 isOn) {
	screenIsOn = (isOn != 0);
}
BYTE8 HWIGetScreenOn(void) {
	return screenIsOn;
}

// *******************************************************************************************************************************
//											  Check if IN is pressed
// *******************************************************************************************************************************

BYTE8 HWIIsInPressed(void) {
	return (GFXIsKeyPressed(GFXKEY_RETURN) != 0);
}

// *******************************************************************************************************************************
//											Read the 749C22 Keyboard Latch
// *******************************************************************************************************************************

BYTE8 HWIReadKeypadLatch(void) {
	return keypadLatch;
}

// *******************************************************************************************************************************
//												Called at End of Frame
// *******************************************************************************************************************************

void HWIEndFrame(void) {
}