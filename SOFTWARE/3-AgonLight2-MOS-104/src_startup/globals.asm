;
; Title:	AGON MOS - Globals
; Author:	Dean Belfield
; Created:	01/08/2022
; Last Updated:	11/11/2023
;
; Modinfo:
; 09/08/2022:	Added sysvars structure, cursorX, cursorY
; 18/08/2022:	Added scrchar, scrpixel, audioChannel, audioSuccess, vdp_protocol_flags
; 18/09/2022:	Added scrwidth, scrheight, scrcols, scrrows
; 23/02/2023:	Added scrcolours, fixed offsets in sysvars comments
; 04/03/2023:	Added scrpixelIndex
; 09/03/2023:	Added vdp_protocol_count, keyascii, keydown; swapped keyascii with keycode, removed timer2
; 15/03/2023:	Added rtc
; 21/03/2023:	Added keydelay, keyrate, keyled
; 23/03/2023:	Added gp
; 29/03/2023:	Added serialFlags
; 14/04/2023:	Added scratchpad
; 19/05/2023	Added scrmode
; 05/06/2023:	Added RTC enable flag
; 03/08/2023:	Added user_kbvector
; 13/08/2023:	Added keymap
; 11/11/2023:	Added i2c

			INCLUDE	"../src/equs.inc"
			
			XDEF	_sysvars
			
			XDEF 	_keycode
			XDEF	_keymods
			XDEF	_keyascii
			XDEF	_keydown
			XDEF	_keycount
			XDEF	_clock
			XDEF	_cursorX
			XDEF	_cursorY
			XDEF	_scrchar
			XDEF	_scrpixel
			XDEF	_audioChannel
			XDEF	_audioSuccess
			XDEF	_scrwidth
			XDEF	_scrheight
			XDEF	_scrcols
			XDEF	_scrrows
			XDEF	_scrcolours
			XDEF	_scrpixelIndex
			XDEF	_rtc
			XDEF	_keydelay 
			XDEF	_keyrate 
			XDEF 	_keyled
			XDEF	_scrmode
			XDEF	_rtc_enable
			XDEF	_mouseX
			XDEF	_mouseY
			XDEF	_mouseButtons
			XDEF	_mouseWheel
			XDEF	_mouseXDelta
			XDEF	_mouseYDelta

			XDEF	_errno
			XDEF 	_coldBoot
			XDEF	_gp
			XDEF	_serialFlags
			XDEF 	_callSM
			XDEF	_scratchpad
			XDEF	_keymap 

			XDEF	_vpd_protocol_flags
			XDEF	_vdp_protocol_state
			XDEF	_vdp_protocol_cmd
			XDEF	_vdp_protocol_len
			XDEF	_vdp_protocol_ptr
			XDEF	_vdp_protocol_data

			XDEF	_user_kbvector

			XDEF	_history_no
			XDEF	_history_size			

			XDEF	_i2c_slave_rw
			XDEF	_i2c_error
			XDEF	_i2c_role
			XDEF	_i2c_msg_ptr
			XDEF	_i2c_msg_size

			SEGMENT BSS		; This section is reset to 0 in cstartup.asm
			
_sysvars:					; Please make sure the sysvar offsets match those in mos_api.inc
;
_clock			DS	4		; + 00h: Clock timer in centiseconds (incremented by 2 every VBLANK)
_vpd_protocol_flags:	DS	1		; + 04h: Flags to indicate completion of VDP commands
_keyascii:		DS	1		; + 05h: ASCII keycode, or 0 if no key is pressed
_keymods:		DS	1		; + 06h: Keycode modifiers
_cursorX:		DS	1		; + 07h: Cursor X position
_cursorY:		DS	1		; + 08h: Cursor Y position
_scrchar		DS	1		; + 09h: Character read from screen
_scrpixel:		DS	3		; + 0Ah: Pixel data read from screen (R,B,G)
_audioChannel:		DS	1		; + 0Dh: Audio channel 
_audioSuccess:		DS	1		; + 0Eh: Audio channel note queued (0 = no, 1 = yes)
_scrwidth:		DS	2		; + 0Fh: Screen width in pixels
_scrheight:		DS	2		; + 11h: Screen height in pixels
_scrcols:		DS	1		; + 13h: Screen columns in characters
_scrrows:		DS	1		; + 14h: Screen rows in characters
_scrcolours:		DS	1		; + 15h: Number of colours displayed
_scrpixelIndex:		DS	1		; + 16h: Index of pixel data read from screen
_keycode:		DS	1		; + 17h: Virtual key code from FabGL
_keydown:		DS	1		; + 18h; Virtual key state from FabGL (0=up, 1=down)
_keycount:		DS	1		; + 19h: Incremented every time a key packet is received
_rtc:			DS	6		; + 1Ah: Real time clock data
			DS	2		; + 20h: Spare, previously used by rtc
_keydelay:		DS	2		; + 22h: Keyboard repeat delay
_keyrate:		DS	2		; + 24h: Keyboard repeat rate
_keyled:		DS	1		; + 26h: Keyboard LED status
_scrmode:		DS	1		; + 27h: Screen mode
_rtc_enable:		DS	1		; + 28h: RTC enable status
_mouseX:		DS	2		; + 29h: Mouse X position
_mouseY:		DS	2		; + 2Bh: Mouse Y position
_mouseButtons:		DS	1		; + 2Dh: Mouse left+right+middle buttons (bits 0-2, 0=up, 1=down)
_mouseWheel:		DS	1		; + 2Eh: Mouse wheel delta
_mouseXDelta:		DS	2		; + 2Fh: Mouse X delta
_mouseYDelta:		DS	2		; + 31h: Mouse Y delta

_errno:			DS 	3		; extern int _errno
_coldBoot:		DS	1		; extern char _coldBoot
_gp:			DS	1		; extern char _gp

; Serial Flags:
;
; - Bit 0: UART0 enabled
; - Bit 1: UART0 hardware flow control
; - Bit 4: UART1 enabled
; - Bit 5: UART1 hardware flow control
;
_serialFlags:		DS	1		; extern char _serialFlags

_callSM:		DS	5		; Self-modding code for CALL.IS (HL)
_scratchpad:		DS	8		; General purpose scratchpad RAM for use within functions

; Keyboard map
;
_keymap:		DS	16		; A bitmap of pressed keys

; VDP Protocol Flags
;
; Bit 0: Cursor packet received
; Bit 1: Screen character packet received
; Bit 2: Pixel point packet received
; Bit 3: Audio packet received
; Bit 4: Mode packet received
; Bit 5: RTC packet received
; Bit 6: Mouse packet received
; Bit 7: Unused
;
; VDP protocol variables
;
_vdp_protocol_state:	DS	1		; UART state
_vdp_protocol_cmd:	DS	1		; Command
_vdp_protocol_len:	DS	1		; Size of packet data
_vdp_protocol_ptr:	DS	3		; Pointer into data
_vdp_protocol_data:	DS	VDPP_BUFFERLEN

;
; Userspace hooks
;
_user_kbvector: 	DS	3		; Pointer to keyboard function

; I2C
;
_i2c_slave_rw:		DS	1		; 7 bit slave address + R/W bit
_i2c_error:		DS	1		; Error report to caller application
_i2c_role:		DS	1		; I2C current state
_i2c_msg_ptr:		DS	3		; Pointer to the current buffer
_i2c_msg_size:		DS	1		; The (remaining) message size

; Command history
;
_history_no:		DS	1
_history_size:		DS 	1

			SECTION DATA		; This section is copied to RAM in cstartup.asm

			END