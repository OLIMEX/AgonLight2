/*
 * Title:			AGON MOS
 * Author:			Dean Belfield
 * Created:			19/06/2022
 * Last Updated:	16/05/2023
 *
 * Modinfo:
 * 11/07/2022:		Version 0.01: Tweaks for Agon Light, Command Line code added
 * 13/07/2022:		Version 0.02
 * 15/07/2022:		Version 0.03: Warm boot support, VBLANK interrupt
 * 25/07/2022:		Version 0.04; Tweaks to initialisation and interrupts
 * 03/08/2022:		Version 0.05: Extended MOS for BBC Basic, added config file
 * 05/08/2022:		Version 0.06: Interim release with hardware flow control enabled
 * 10/08/2022:		Version 0.07: Bug fixes
 * 05/09/2022:		Version 0.08: Minor updates to MOS
 * 02/10/2022:		Version 1.00: Improved error handling for languages, changed bootup title to Quark
 * 03/10/2022:		Version 1.01: Added SET command, tweaked error handling
 * 20/10/2022:					+ Tweaked error handling
 * 13/11/2022:		Version 1.02
 * 14/03/2023		Version 1.03: SD now uses timer0, does not require interrupt
 *								+ Stubbed command history
 * 22/03/2023:					+ Moved command history to mos_editor.c
 * 23/03/2023:				RC2	+ Increased baud rate to 1152000
 * 								+ Improved ESP32->eZ80 boot sync
 * 29/03/2023:				RC3 + Added UART1 initialisation, tweaked startup sequence timings
 * 16/05/2023:		Version 1.04: Fixed MASTERCLOCK value in uart.h, added startup beep
 */

#include <eZ80.h>
#include <defines.h>
#include <stdio.h>
#include <CTYPE.h>
#include <String.h>

#include "defines.h"
#include "config.h"
#include "uart.h"
#include "spi.h"
#include "timer.h"
#include "ff.h"
#include "clock.h"
#include "mos.h"

#define		MOS_version		1
#define		MOS_revision 	4
#define		MOS_rc			1

extern void *	set_vector(unsigned int vector, void(*handler)(void));

extern void 	vblank_handler(void);
extern void 	uart0_handler(void);

extern char 			coldBoot;		// 1 = cold boot, 0 = warm boot
extern volatile	char 	keycode;		// Keycode 
extern volatile char	gp;				// General poll variable

static FATFS 	fs;						// Handle for the file system
static char  	cmd[256];				// Array for the command line handler

// Wait for the ESP32 to respond with a GP packet to signify it is ready
// Parameters:
// - pUART: Pointer to a UART structure
// - baudRate: Baud rate to initialise UART with
// Returns:
// - 1 if the function succeeded, otherwise 0
//
int wait_ESP32(UART * pUART, UINT24 baudRate) {	
	int	i, t;

	pUART->baudRate = baudRate;			// Initialise the UART object
	pUART->dataBits = 8;
	pUART->stopBits = 1;
	pUART->parity = PAR_NOPARITY;
	pUART->flowControl = FCTL_HW;
	pUART->interrupts = UART_IER_RECEIVEINT;

	open_UART0(pUART);					// Open the UART 
	init_timer0(10, 16, 0x00);  		// 10ms timer for delay
	gp = 0;								// Reset the general poll byte	
	for(t = 0; t < 20; t++) {			// A timeout loop (20 x 50ms = 1s)
		putch(23);						// Send a general poll packet
		putch(0);
		putch(VDP_gp);
		putch(1);
		for(i = 0; i < 5; i++) {		// Wait 50ms
			wait_timer0();
		}
		if(gp == 1) break;				// If general poll returned, then exit for loop
	}
	enable_timer0(0);					// Disable the timer
	return gp;
}

// Initialise the interrupts
//
void init_interrupts(void) {
	set_vector(PORTB1_IVECT, vblank_handler); 	// 0x32
	set_vector(UART0_IVECT, uart0_handler);		// 0x18
}

// The main loop
//
int main(void) {
	UART 	pUART0;

	DI();											// Ensure interrupts are disabled before we do anything
	init_interrupts();								// Initialise the interrupt vectors
	init_rtc();										// Initialise the real time clock
	init_spi();										// Initialise SPI comms for the SD card interface
	init_UART0();									// Initialise UART0 for the ESP32 interface
	init_UART1();									// Initialise UART1
	EI();											// Enable the interrupts now
	
	if(!wait_ESP32(&pUART0, 1152000)) {				// Try to lock onto the ESP32 at maximum rate
		if(!wait_ESP32(&pUART0, 384000))	{		// If that fails, then fallback to the lower baud rate
			gp = 2;									// Flag GP as 2, just in case we need to handle this error later
		}
	}	
	if(coldBoot == 0) {								// If a warm boot detected then
		putch(12);									// Clear the screen
	}
	printf("Agon Quark MOS Version %d.%02d", MOS_version, MOS_revision);
	#if MOS_rc > 0
		printf(" RC%d", MOS_rc);
	#endif
	printf("\n\r\n\r");
	#if	DEBUG > 0
	printf("@Baud Rate: %d\n\r\n\r", pUART0.baudRate);
	#endif

	f_mount(&fs, "", 1);							// Mount the SD card
	
	putch(7);										// Startup beep

	// Load the autoexec.bat config file
	//
	#if enable_config == 1	
	if(coldBoot > 0) {								// Check it's a cold boot (after reset, not RST 00h)
		mos_BOOT("autoexec.txt", cmd, sizeof cmd);	// Then load and run the config file
	}	
	#endif

	// The main loop
	//
	while(1) {
		if(mos_input(&cmd, sizeof(cmd)) == 13) {
			int err = mos_exec(&cmd);
			if(err > 0) {
				mos_error(err);
			}
		}
		else {
			printf("%cEscape\n\r", MOS_prompt);
		}
	}

	return 0;
}