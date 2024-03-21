;
; Title:	AGON MOS - VDP serial protocol
; Author:	Dean Belfield
; Created:	03/08/2022
; Last Updated:	26/09/2023
;
; Modinfo:
; 09/08/2022:	Added vdp_protocol_CURSOR
; 18/08/2022:	Added vpd_protocol_SCRCHAR, vpd_protocol_POINT, vdp_protocol_AUDIO, bounds checking for protocol
; 18/09/2022:	Added vdp_protocol_MODE
; 13/02/2023:	Bug fix vpd_protocol_MODE now returns correct scrheight
; 23/02/2023:	vdp_protocol_MODE now returns number of screen colours
; 04/03/2023:	Added _scrpixelIndex to vpd_protocol_POINT
; 09/03/2023:	Added FabGL virtual key data to vdp_protocol_KEY, reset is now CTRL+ALT+DEL
; 15/03/2023:	Added vdp_protocol_RTC
; 21/03/2023:	Added vdp_protocol_KEYSTATE
; 26/03/2023:	Added vdp_protocol_GP, checks DEL above cursor block for CTRL+ALT+DEL	
; 19/05/2023:	Extended vdp_protocol_MODE to store scrmode
; 03/08/2023:	Added user_kbvector in vdp_protocol_KEY
; 13/08/2023:	Moved keyboard handling to keyboard.asm
; 26/09/2023:	RTC packet length reduced to 6 bytes

			INCLUDE	"macros.inc"
			INCLUDE	"equs.inc"

			.ASSUME	ADL = 1

			DEFINE .STARTUP, SPACE = ROM
			SEGMENT .STARTUP
			
			XDEF	vdp_protocol

			XREF	_keyascii
			XREF	_keycode
			XREF	_keymods
			XREF	_keydown
			XREF	_keycount
			XREF	_cursorX
			XREF	_cursorY
			XREF	_scrchar
			XREF	_scrpixel
			XREF	_audioChannel
			XREF	_audioSuccess
			XREF	_scrwidth
			XREF	_scrheight
			XREF	_scrcols
			XREF	_scrrows
			XREF	_scrcolours
			XREF	_scrpixelIndex
			XREF	_scrmode
			XREF	_rtc
			XREF	_keydelay 
			XREF	_keyrate 
			XREF 	_keyled
			XREF	_mouseX
			XREF	_gp
			XREF	_vpd_protocol_flags
			XREF	_vdp_protocol_state
			XREF	_vdp_protocol_cmd
			XREF	_vdp_protocol_len
			XREF	_vdp_protocol_ptr
			XREF	_vdp_protocol_data

			XREF	_user_kbvector

			XREF	keyboard_handler	; In keyboard.asm
;							
; The UART protocol handler state machine
;
vdp_protocol:		LD	A, (_vdp_protocol_state)
			OR	A
			JR	Z, vdp_protocol_state0
			DEC	A
			JR	Z, vdp_protocol_state1
			DEC	A
			JR	Z, vdp_protocol_state2
			XOR	A
			LD	(_vdp_protocol_state), A
			RET
;
; Wait for control byte (>=80h)
;
vdp_protocol_state0:	LD	A, C			; Wait for a header byte (bit 7 set)
			SUB	80h
			RET	C
			CP	vdp_protocol_vesize	; Check whether the command is in bounds
			RET	NC			; Out of bounds, so just ignore
			LD	(_vdp_protocol_cmd), A	; Store the cmd (discard the top bit)
			LD	(_vdp_protocol_ptr), HL	; Store the buffer pointer
			LD	A, 1			; Switch to next state
			LD	(_vdp_protocol_state), A
			RET
			
;
; Read the packet length in
;
vdp_protocol_state1:	LD	A, C			; Fetch the length byte
			CP	VDPP_BUFFERLEN + 1	; Check if it exceeds buffer length (16)
			JR	C, $F			;
			XOR	A			; If it does exceed buffer length, reset state machine
			LD	(_vdp_protocol_state), A
			RET
;
$$:			LD	(_vdp_protocol_len), A	; Store the length
			OR	A			; If it is zero
			JR	Z, vdp_protocol_exec	; Then we can skip fetching bytes, otherwise
			LD	A, 2			; Switch to next state
			LD	(_vdp_protocol_state), A
			RET
			
; Read the packet body in
;
vdp_protocol_state2:	LD	HL, (_vdp_protocol_ptr)	; Get the buffer pointer
			LD	(HL), C			; Store the byte in it
			INC	HL			; Increment the buffer pointer
			LD	(_vdp_protocol_ptr), HL
			LD	A, (_vdp_protocol_len)	; Decrement the length
			DEC	A
			LD	(_vdp_protocol_len), A
			RET	NZ			; Stay in this state if there are still bytes to read
;
; When len is 0, we can action the packet
;

vdp_protocol_exec:	XOR	A			; Reset the state
			LD	(_vdp_protocol_state), A	
			LD	DE, vdp_protocol_vector
			LD	HL, 0			; Index into the jump table
			LD	A, (_vdp_protocol_cmd)	; Get the command byte...
			LD	L, A			; ...in HLU
			ADD	HL, HL			; Multiply by four, as each entry is 4 bytes
			ADD	HL, HL			; And add the address of the vector table
			ADD	HL, DE
			JP	(HL)			; And jump to the entry in the jump table
;
; Jump table for UART commands
;
vdp_protocol_vector:	JP	vdp_protocol_GP
			JP	vdp_protocol_KEY
			JP	vdp_protocol_CURSOR
			JP	vpd_protocol_SCRCHAR
			JP	vdp_protocol_POINT
			JP	vdp_protocol_AUDIO
			JP	vdp_protocol_MODE
			JP	vdp_protocol_RTC
			JP	vdp_protocol_KEYSTATE
			JP	vdp_protocol_MOUSE
;
vdp_protocol_vesize:	EQU	($-vdp_protocol_vector)/4
	
; General Poll
;
vdp_protocol_GP:	LD	A, (_vdp_protocol_data + 0)
			LD	(_gp), A
			RET

; Keyboard Data
; Received after a keypress event in the VPD
;
vdp_protocol_KEY:	LD	HL, (_user_kbvector)		; If a user kbvector is set, call it
			LD	DE, 0
			OR	A
			SBC	HL, DE
			JR	Z, $F
			LD	HL, $F
			PUSH	HL				; Push return address from user routine
			LD	HL, (_user_kbvector)
			LD	DE, _vdp_protocol_data		; Pass keyboard packet address to user routine in DE (24-bit)
			JP	(HL)
;
$$:			LD	A, (_vdp_protocol_data + 0)	; ASCII key code
			LD	(_keyascii), A
			LD	A, (_vdp_protocol_data + 1)	; Key modifiers (SHIFT, ALT, etc)
			LD	(_keymods), A
			LD	A, (_vdp_protocol_data + 3)	; Key down? (1=down, 0=up)
			LD	C, A				; C: Keydown
			LD	(_keydown), A
			LD	A, (_keycount)			; Increment the key event counter
			INC	A
			LD	(_keycount), A
			LD	A, (_vdp_protocol_data + 2)	; Virtual key code
			LD	B, A 				; B: Virtual keycode
			LD	(_keycode), A
;
			JP	keyboard_handler		; Call the handle keyboard routine (in keyboard.asm)

; Cursor data
; Received after the cursor position is updated in the VPD
;
; Byte: Cursor X
; Byte: Cursor Y
;
; Sets vpd_protocol_flags to flag receipt to apps
;
vdp_protocol_CURSOR:	LD	A, (_vdp_protocol_data+0)
			LD	(_cursorX), A
			LD	A, (_vdp_protocol_data+1)
			LD	(_cursorY), A
			LD	A, (_vpd_protocol_flags)
			OR	VDPP_FLAG_CURSOR
			LD	(_vpd_protocol_flags), A
			RET
			
; Screen character data
; Received after VDU 23,0,0,x;y;
;
; Byte: ASCII code of character 
;
; Sets vpd_protocol_flags to flag receipt to apps
;
vpd_protocol_SCRCHAR:	LD	A, (_vdp_protocol_data+0)
			LD	(_scrchar), A
			LD	A, (_vpd_protocol_flags)
			OR	VDPP_FLAG_SCRCHAR
			LD	(_vpd_protocol_flags), A
			RET
			
; Pixel value data (RGB)
; Received after VDU 23,0,1,x;y;
;
; Byte: Red component of read pixel
; Byte: Green component of read pixel
; Byte: Blue component of read pixel
; Byte: The palette index
;
; Sets vpd_protocol_flags to flag receipt to apps
;
vdp_protocol_POINT:	LD	HL, (_vdp_protocol_data+0)
			LD	(_scrpixel), HL
			LD	A, (_vdp_protocol_data+3)
			LD	(_scrpixelIndex), A
			LD	A, (_vpd_protocol_flags)
			OR	VDPP_FLAG_POINT
			LD	(_vpd_protocol_flags), A
			RET
			
; Audio acknowledgement
; Received after VDU 23,0,5,channel,volume,frequency,duration
;
; Byte: channel
; Byte: success (1 if successful, otherwise 0)
;
; Sets vpd_protocol_flags to flag receipt to apps
;
vdp_protocol_AUDIO:	LD	A, (_vdp_protocol_data+0)
			LD	(_audioChannel), A
			LD	A, (_vdp_protocol_data+1)
			LD	(_audioSuccess), A
			LD	A, (_vpd_protocol_flags)
			OR	VDPP_FLAG_AUDIO
			LD	(_vpd_protocol_flags), A
			RET
			
; Screen mode details
; Received after VDU 23,0,6 or VDU 17, n
;
; Word: Screen width in pixels
; Word: Screen height in pixels
; Byte: Screen width in characters
; Byte: Screen height in characters
; Byte: Number of colours
; Byte: Screen mode
;
; Sets vpd_protocol_flags to flag receipt to apps
;
vdp_protocol_MODE:	LD	A, (_vdp_protocol_data+0)
			LD	(_scrwidth), A
			LD	A, (_vdp_protocol_data+1)
			LD	(_scrwidth+1), A
			LD	A, (_vdp_protocol_data+2)
			LD	(_scrheight), A
			LD	A, (_vdp_protocol_data+3)
			LD	(_scrheight+1), A
			LD	A, (_vdp_protocol_data+4)
			LD	(_scrcols), A
			LD	A, (_vdp_protocol_data+5)
			LD	(_scrrows), A
			LD	A, (_vdp_protocol_data+6)
			LD	(_scrcolours), A
			LD	A, (_vdp_protocol_data+7)
			LD	(_scrmode), A
			LD	A, (_vpd_protocol_flags)
			OR	VDPP_FLAG_MODE
			LD	(_vpd_protocol_flags), A			
			RET

; RTC
; Received after VDU 23,0,7
;
; See vdp_time_t struct in clock.h for details
;
; Sets vpd_protocol_flags to flag receipt to apps
;
vdp_protocol_RTC:	LD	HL, _vdp_protocol_data
			LD	DE, _rtc 
			LD	BC,  6
			LDIR 
			LD	A, (_vpd_protocol_flags)
			OR	VDPP_FLAG_RTC
			LD	(_vpd_protocol_flags), A			
			RET

; Keyboard status
; Received after VDU 23,0,8,delay;rate;led
;
; Word:	delay
; Word: rate
; Byte: led status
;
vdp_protocol_KEYSTATE:	LD	HL, _vdp_protocol_data
			LD	DE, _keydelay
			LD	BC, 5
			LDIR 
			RET

; Mouse data
; Received after a mouse movement event, if mouse has been activated
;
; Word: X position
; Word: Y position
; Byte: Button state
; Byte: Wheel delta
; Word: X delta
; Word: Y delta
;
vdp_protocol_MOUSE:	LD	HL, _vdp_protocol_data
			LD	DE, _mouseX
			LD	BC, 10
			LDIR 
			LD	A, (_vpd_protocol_flags)
			OR	VDPP_FLAG_MOUSE
			LD	(_vpd_protocol_flags), A
			RET
