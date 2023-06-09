/*
 * Title:			AGON MOS - MOS line editor
 * Author:			Dean Belfield
 * Created:			18/09/2022
 * Last Updated:	31/03/2023
 * 
 * Modinfo:
 * 28/09/2022:		Added clear parameter to mos_EDITLINE
 * 20/02/2023:		Fixed mos_EDITLINE to handle the full CP-1252 character set
 * 09/03/2023:		Added support for virtual keys; improved editing functionality
 * 14/03/2023:		Tweaks ready for command history
 * 21/03/2023:		Improved backspace, and editing of long lines, after scroll, at bottom of screen
 * 22/03/2023:		Added a single-entry command line history
 * 31/03/2023:		Added timeout for VDP protocol
 */

#include <eZ80.h>
#include <defines.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "defines.h"
#include "mos.h"
#include "uart.h"
#include "timer.h"
#include "mos_editor.h"

extern volatile BYTE vpd_protocol_flags;		// In globals.asm
extern volatile BYTE keyascii;					// In globals.asm
extern volatile BYTE keycode;					// In globals.asm
extern volatile BYTE keydown;					// In globals.asm
extern volatile BYTE keycount;					// In globals.asm

extern BYTE cursorX;
extern BYTE cursorY;
extern BYTE scrcols;

// Storage for the command history
//
static char	cmd_history[cmd_historyWidth + 1];

// Get the current cursor position from the VPD
//
void getCursorPos() {
	vpd_protocol_flags &= 0xFE;					// Clear the semaphore flag
	putch(23);									// Request the cursor position
	putch(0);
	putch(VDP_cursor);
	wait_VDP(0x01);								// Wait until the semaphore has been set, or a timeout happens
}

// Get the current screen dimensions from the VDU
//
void getModeInformation() {
	vpd_protocol_flags &= 0xEF;					// Clear the semaphore flag
	putch(23);
	putch(0);
	putch(VDP_mode);
	wait_VDP(0x10);								// Wait until the semaphore has been set, or a timeout happens
}

// Move cursor left
//
void doLeftCursor() {
	getCursorPos();
	if(cursorX > 0) {
		putch(0x08);
	}
	else {
		while(cursorX < (scrcols - 1)) {
			putch(0x09);
			cursorX++;
		}
		putch(0x0B);
	}
}

// Move Cursor Right
// 
void doRightCursor() {
	getCursorPos();
	if(cursorX < (scrcols - 1)) {
		putch(0x09);
	}
	else {
		while(cursorX > 0) {
			putch(0x08);
			cursorX--;
		}
		putch(0x0A);
	}
}

// Insert a character in the input string
// Parameters:
// - buffer: Pointer to the line edit buffer
// - c: Character to insert
// - insertPos: Position in the input string to insert the character
// - len: Length of the input string (before the character is inserted)
// - limit: Max number of characters to insert
// Returns:
// - true if the character was inserted, otherwise false
//
BOOL insertCharacter(char *buffer, char c, int insertPos, int len, int limit) {
	int	i;
	int count = 0;
	
	if(len < limit) {
		putch(c);
		for(i = len; i >= insertPos; i--) {
			buffer[i+1] = buffer[i];
		}
		buffer[insertPos] = c;
		for(i = insertPos + 1; i <= len; i++, count++) {
			putch(buffer[i]);
		}
		for(i = 0; i < count; i++) {
			doLeftCursor();
		}
		return 1;
	}	
	return 0;
}

// Remove a character from the input string
// Parameters:
// - buffer: Pointer to the line edit buffer
// - insertPos: Position in the input string of the character to be deleted
// - len: Length of the input string before the character is deleted
// Returns:
// - true if the character was deleted, otherwise false
//
BOOL deleteCharacter(char *buffer, int insertPos, int len) {
	int	i;
	int count = 0;
	if(insertPos > 0) {
		doLeftCursor();
		for(i = insertPos - 1; i < len; i++, count++) {
			BYTE b = buffer[i+1];
			buffer[i] = b;
			putch(b ? b : ' ');
		}
		for(i = 0; i < count; i++) {
			doLeftCursor();
		}
		return 1;
	}	
	return 0;
}

// Wait for a key to be pressed
//
void waitKey() {
	BYTE	c;
	do {
		c = keycount;				
		while(c == keycount);		// Wait for a key event
	} while (keydown == 0);			// Loop until we get a key down value (keydown = 1)
}

// The main line edit function
// Parameters:
// - buffer: Pointer to the line edit buffer
// - bufferLength: Size of the buffer in bytes
// - clear: Set to 0 to not clear, 1 to clear on entry
// Returns:
// - The exit key pressed (ESC or CR)
//
UINT24 mos_EDITLINE(char * buffer, int bufferLength, UINT8 clear) {
	BYTE keya = 0;					// The ASCII key	
	BYTE keyc = 0;					// The FabGL keycode
	BYTE keyr = 0;					// The ASCII key to return back to the calling program

	int  limit = bufferLength - 1;	// Max # of characters that can be entered
	int	 insertPos;					// The insert position
	int  len = 0;					// Length of current input
	
	getModeInformation();			// Get the current screen dimensions
	
	if(clear) {						// Clear the buffer as required
		buffer[0] = 0;	
		insertPos = 0;
	}
	else {
		printf("%s", buffer);		// Otherwise output the current buffer
		insertPos = strlen(buffer);	// And set the insertpos to the end
	}

	// Loop until an exit key is pressed
	//
	while(keyr == 0) {
		len = strlen(buffer);
		waitKey();
		keya = keyascii;
		keyc = keycode;
		switch(keyc) {
			//
			// First any extended (non-ASCII keys)
			//
			case 0x85: {	// HOME
				while(insertPos > 0) {
					doLeftCursor();
					insertPos--;
				}
			} break;
			case 0x87: {	// END
				while(insertPos < len) {
					doRightCursor();
					insertPos++;
				}
			} break;
			//
			// Now the ASCII keys
			//
			default: {
				if(keya > 0) {
					if(keya >= 0x20 && keya != 0x7F) {
						if(insertCharacter(buffer, keya, insertPos, len, limit)) {
							insertPos++;
						}
					}
					else {				
						switch(keya) {
							case 0x0D:		// Enter
								if(len > 0) {										// If there is data in the buffer
									strncpy(cmd_history, buffer, cmd_historyWidth);	// Save in the history and fall through to next case
								}
							case 0x1B:	{	// Escape
								keyr = keya;
							} break;
							case 0x08:	{	// Cursor Left
								if(insertPos > 0) {
									doLeftCursor();
									insertPos--;
								}
							} break;
							case 0x15:	{	// Cursor Right
								if(insertPos < len) {
									doRightCursor();
									insertPos++;
								}
							} break;
							case 0x0A: {	// Cursor Down
								if(insertPos <= (len - scrcols)) {
									putch(0x0A);
									insertPos += scrcols;
								}
							} break;
							case 0x0B:	{	// Cursor Up
								if(len == 0) {										// If the buffer is empty
									strncpy(buffer, cmd_history, limit);			// Copy from the history to the buffer
									printf("%s", buffer);							// Output the buffer
									insertPos = strlen(buffer);						// Set cursor to end of string
								}
								else {
									if(insertPos >= scrcols) {
										putch(0x0B);
										insertPos -= scrcols;
									}
								}
							} break;
							case 0x7F: {	// Backspace
								if(deleteCharacter(buffer, insertPos, len)) {
									insertPos--;
								}
							} break;
						}					
					}
				}
			}
		}
	}
	len-=insertPos;					// Now just need to cursor to end of line; get # of characters to cursor

	while(len >= scrcols) {			// First cursor down if possible
		putch(0x0A);
		len-=scrcols;
	}
	while(len-- > 0) putch(0x09);	// Then cursor right for the remainder

	return keyr;					// Finally return the keycode
}