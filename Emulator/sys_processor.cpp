// *******************************************************************************************************************************
// *******************************************************************************************************************************
//
//		Name:		sys_processor.c
//		Purpose:	Processor Emulation.
//		Created:	29th June 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// *******************************************************************************************************************************
// *******************************************************************************************************************************

#include <stdlib.h>
#ifdef WINDOWS
#include <stdio.h>
#endif
#include "sys_processor.h"
#include "sys_debug_system.h"
#include "hardware.h"

// *******************************************************************************************************************************
//														   Timing
// *******************************************************************************************************************************

#define CYCLES_PER_SCANLINE 	(14)												// Cycles per scan line (14)
#define NTSC_LINES_PER_FRAME	(262)												// NTSC standards
#define NTSC_FRAMES_PER_SECOND	(60)

#define CYCLES_PER_FRAME 		(CYCLES_PER_SCANLINE * NTSC_LINES_PER_FRAME)		// Cycles per frame (3,668)
#define CYCLES_PER_SECOND 		(CYCLES_PER_FRAME * NTSC_FRAMES_PER_SECOND)			// Cycles per second (220,080)
#define CRYSTAL_CLOCK 			(CYCLES_PER_SECOND * 8)								// Clock speed (1,760,640Hz)

#define RENDERING_LINES 		(128)												// Generate video on these scanlines
#define RENDERING_CYCLES		(RENDERING_LINES * CYCLES_PER_SCANLINE)				// How many cycles this takes.


//	3,668 Cycles per frame
// 	262 lines per video frame
//	14 Cycles per scanline (should be :))

// *******************************************************************************************************************************
//														CPU / Memory
// *******************************************************************************************************************************

#include "__1802_macros.h"
static BYTE8 ramMemory[MEMORYSIZE];													

static BYTE8 romMonitor[512] = 
{
	#include "binaries\monitor_rom.h"
};

// *******************************************************************************************************************************
//											 Memory and I/O read and write macros
// *******************************************************************************************************************************

#define READ(a) 	__Read(a)
#define WRITE(a,d) 	__Write(a,d)

static inline BYTE8 __Read(WORD16 addr)
{
	if (addr < MEMORYSIZE) return ramMemory[addr];
	if (addr >= 0x8000) return romMonitor[addr & 0x1FF];
	return DEFAULT_BUS_VALUE;
}

static inline void __Write(WORD16 addr,WORD16 data)
{
	if (addr < MEMORYSIZE) ramMemory[addr] = data;
}

// *******************************************************************************************************************************
//													   Port Interfaces
// *******************************************************************************************************************************

#define INPORT1() 	(HWISetScreenOn(1),DEFAULT_BUS_VALUE)							// INP 1 screen on
#define OUTPORT1(n)	HWISetScreenOn(0)												// OUT 1 screen off
#define OUTPORT2(n) HWIWriteKeypadLatch(n);											// OUT 2 write keyboard latch

#define EFLAG1() 	(1)																// EF1 is always set.
#define EFLAG3() 	(HWIReadKeypadPressed() != 0)									// EF4 is the IN Key.

#include "__1802_ports.h"															// Default connections.

// *******************************************************************************************************************************
//														Reset the CPU
// *******************************************************************************************************************************

void CPUReset(void) {
	RESET();																		// CPU Reset
	HWIReset();																		// Hardware reset

	//
	//	Set up as if Monitor ROM partly booted so we don't have to emulate Out 4.
	//
	R[0] = 0x0008; 																	// R0 = $0008
	R[2] = 0x8008;																	// R2 = $8088
	X = P = 2;																		// X = P = 2

	//romMonitor[0x22] = 0x30;														// Forces Monitor Boot.
}

// *******************************************************************************************************************************
//												Execute a single instruction
// *******************************************************************************************************************************

BYTE8 CPUExecuteInstruction(void) {

	switch(FETCH()) {																// Execute it.
		#include "__1802_opcodes.h"
	}
	if (Cycles >= CYCLES_PER_FRAME-29) {											// If we are at INT time.
		if (IE != 0) {																// and interrupts are enabled
			INTERRUPT();
			Cycles = CYCLES_PER_FRAME - 29;											// Make it EXACTLY 29 Cycles to display start
																					// When breaks on FRAME_RATE then will be at render
		}
	}	
	if (Cycles < CYCLES_PER_FRAME) return 0;										// Not completed a frame.
	HWISetPageAddress(R[0]);														// Set the display address.
	HWIEndFrame();																	// End of Frame code
	Cycles = Cycles - CYCLES_PER_FRAME;												// Adjust this frame rate.
	Cycles = Cycles + RENDERING_CYCLES;												// Fix it back for the video generation.
	return NTSC_FRAMES_PER_SECOND;													// Return frame rate.
}

#ifdef INCLUDE_DEBUGGING_SUPPORT

// *******************************************************************************************************************************
//		Execute chunk of code, to either of two break points or frame-out, return non-zero frame rate on frame, breakpoint 0
// *******************************************************************************************************************************

BYTE8 CPUExecute(WORD16 breakPoint1,WORD16 breakPoint2) { 
	do {
		BYTE8 r = CPUExecuteInstruction();											// Execute an instruction
		if (r != 0) return r; 														// Frame out.
	} while (R[P] != breakPoint1 && R[P] != breakPoint2);							// Stop on breakpoint.
	return 0; 
}

// *******************************************************************************************************************************
//									Return address of breakpoint for step-over, or 0 if N/A
// *******************************************************************************************************************************

WORD16 CPUGetStepOverBreakpoint(void) {
	BYTE8 opcode = CPUReadMemory(R[P]);												// Current opcode.
	if (opcode >= 0xD0 && opcode <= 0xDF) return (R[P]+1) & 0xFFFF;					// If SEP Rx then step is one after.
	return 0;																		// Do a normal single step
}

// *******************************************************************************************************************************
//												Read/Write Memory
// *******************************************************************************************************************************

BYTE8 CPUReadMemory(WORD16 address) {
	return READ(address);
}

void CPUWriteMemory(WORD16 address,BYTE8 data) {
	WRITE(address,data);
}

// *******************************************************************************************************************************
//												Load a binary file into RAM
// *******************************************************************************************************************************

#include <stdio.h>

void CPULoadBinary(const char *fileName) {
	FILE *f = fopen(fileName,"rb");
	fread(ramMemory,1,MEMORYSIZE,f);
	fclose(f);
}

// *******************************************************************************************************************************
//											Retrieve a snapshot of the processor
// *******************************************************************************************************************************

static CPUSTATUS s;																	// Status area

CPUSTATUS *CPUGetStatus(void) {
	s.d = D;s.df = DF;s.p = P;s.x = X;s.t = T;s.q = Q;s.ie = IE;					// Registers
	for (int i = 0;i < 16;i++) s.r[i] = R[i];										// 16 bit Registers
	s.cycles = Cycles;s.pc = R[P];													// Cycles and "PC"
	return &s;
}

#endif
