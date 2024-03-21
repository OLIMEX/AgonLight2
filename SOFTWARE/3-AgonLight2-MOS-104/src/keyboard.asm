;
; Title:	AGON MOS - Keyboard routines
; Author:	Dean Belfield
; Created:	13/08/2023
; Last Updated:	13/08/2023
;
; Modinfo:
			INCLUDE	"macros.inc"
			INCLUDE	"equs.inc"

			.ASSUME	ADL = 1

			DEFINE .STARTUP, SPACE = ROM
			SEGMENT .STARTUP

			XDEF	keyboard_handler

			XREF	_keymods 			; In globals.asm
			XREF	_keyascii
			XREF	_keycode
			XREF	_keymap

; Agon keyboard routines
;  C: Keydown state (1 = pressed 0 = depressed)
;  B: Virtual keycode
;
keyboard_handler:	LD	A, B
			OR	A
			CALL	NZ, keyboard_map
			JP	keyboard_reset

; Write key up and down states to the keymap
;  C: Keydown state (1 = pressed 0 = depressed)
;  A: Virtual keycode
;
keyboard_map:		DEC	A 				;  A: Virtual keycode - 1
			LD	DE, keyboard_lookup		; DE: Address of keyboard lookup table
			LD	HL, 0
			LD	L, A 
			ADD	HL, HL 
			ADD	HL, HL				; HL: Virtual keycode x 4
			ADD	HL, DE				; HL: Address of key data in keyboard lookup
			LD	A, (HL)				;  A: Bit to set
			OR	A				; Check for empty entry
			RET	Z				; Yep, nothing to set here, so return
			INC	HL
			LD	HL, (HL)			; HL: Address to set into
			BIT 	0, C				; Is the key down or up?
			JR	NZ, $F 				; It is down so jump to the code that sets a bit
			CPL					; It is up so complement the bit
			AND	(HL)				; Then AND it with the keymap entry
			LD	(HL), A
			RET 
;
$$:			OR	(HL)				; OR with the keymap entry
			LD	(HL), A
			RET 
;			
; Now check for CTRL+ALT+DEL
;
keyboard_reset:		LD	A, B				; Get the virtual key code
			CP	130				; Check for DEL (cursor keys)
			JR	Z, $F
			CP	131				; Check for DEL (no numlock)
			JR	Z , $F
			CP	88				; And DEL (numlock)
			RET	NZ
$$:			LD	A, (_keymods)			; DEL is pressed so check CTRL + ALT
			AND	05h				; Bit 0 and 2
			CP	05h
			RET	NZ				; Exit if not pressed
;
; Here we're just waiting for the key to go up
;
			LD	A, C				; Get key down
			DEC	A				; Check for 0 (key up)
			JP	NZ, 0				; Yes so reset
			LD	(_keyascii), A			; Otherwise clear the keycode so no interaction with console 
			LD	(_keycode), A 
			RET

; Lookup table to convert virtual keycodes to physical keys (BBC BASIC specification)
; Uses the macro KEY to store each key as an index and a bit
; Four bytes of data per key
; - 1 byte:  The bit data to set into the keymap
; - 3 bytes: The address to set (precalculated)
;
KEY:			MACRO VKEYCODE 
			IF	VKEYCODE = 0
			DL 	0
			ELSE
			DB	1 << ((VKEYCODE - 1) & 00000111b)
			DW24	_keymap + (((VKEYCODE - 1) & 11111000b) >> 3)
			ENDIF 
			ENDMACRO 
;
keyboard_lookup:	KEY(099)	; VK_SPACE
			KEY(040)	; VK_0
			KEY(049)	; VK_1
			KEY(050)	; VK_2
			KEY(018)	; VK_3
			KEY(019)	; VK_4
			KEY(020)	; VK_5
			KEY(053)	; VK_6
			KEY(037)	; VK_7
			KEY(022)	; VK_8
			KEY(039)	; VK_9
			KEY(107)	; VK_KP_0
			KEY(108)	; VK_KP_1
			KEY(125)	; VK_KP_2
			KEY(109)	; VK_KP_3
			KEY(123)	; VK_KP_4
			KEY(124)	; VK_KP_5
			KEY(027)	; VK_KP_6
			KEY(028)	; VK_KP_7
			KEY(043)	; VK_KP_8
			KEY(044)	; VK_KP_9
			KEY(066)	; VK_a
			KEY(101)	; VK_b
			KEY(083)	; VK_c
			KEY(051)	; VK_d
			KEY(035)	; VK_e
			KEY(068)	; VK_f
			KEY(084)	; VK_g
			KEY(085)	; VK_h
			KEY(038)	; VK_i
			KEY(070)	; VK_j
			KEY(071)	; VK_k
			KEY(087)	; VK_l
			KEY(102)	; VK_m
			KEY(086)	; VK_n
			KEY(055)	; VK_o
			KEY(056)	; VK_p
			KEY(017)	; VK_q
			KEY(052)	; VK_r
			KEY(082)	; VK_s
			KEY(036)	; VK_t
			KEY(054)	; VK_u
			KEY(100)	; VK_v
			KEY(034)	; VK_w
			KEY(067)	; VK_x
			KEY(069)	; VK_y
			KEY(098)	; VK_z
			KEY(066)	; VK_A
			KEY(101)	; VK_B
			KEY(083)	; VK_C
			KEY(051)	; VK_D
			KEY(035)	; VK_E
			KEY(068)	; VK_F
			KEY(084)	; VK_G
			KEY(085)	; VK_H
			KEY(038)	; VK_I
			KEY(070)	; VK_J
			KEY(071)	; VK_K
			KEY(087)	; VK_L
			KEY(102)	; VK_M
			KEY(086)	; VK_N
			KEY(055)	; VK_O
			KEY(056)	; VK_P
			KEY(017)	; VK_Q
			KEY(052)	; VK_R
			KEY(082)	; VK_S
			KEY(036)	; VK_T
			KEY(054)	; VK_U
			KEY(100)	; VK_V
			KEY(034)	; VK_W
			KEY(067)	; VK_X
			KEY(069)	; VK_Y
			KEY(098)	; VK_Z              
			KEY(046)	; VK_GRAVEACCENT
			KEY(000)	; VK_ACUTEACCENT
			KEY(000)	; VK_QUOTE
			KEY(000)	; VK_QUOTEDBL
			KEY(094)	; VK_EQUALS
			KEY(024)	; VK_MINUS
			KEY(060)	; VK_KP_MINUS
			KEY(094)	; VK_PLUS
			KEY(059)	; VK_KP_PLUS
			KEY(092)	; VK_KP_MULTIPLY
			KEY(000)	; VK_ASTERISK
			KEY(000)	; VK_BACKSLASH
			KEY(075)	; VK_KP_DIVIDE
			KEY(105)	; VK_SLASH
			KEY(077)	; VK_KP_PERIOD
			KEY(104)	; VK_PERIOD
			KEY(073)	; VK_COLON
			KEY(103)	; VK_COMMA
			KEY(088)	; VK_SEMICOLON
			KEY(000)	; VK_AMPERSAND
			KEY(000)	; VK_VERTICALBAR
			KEY(000)	; VK_HASH
			KEY(072)	; VK_AT  
			KEY(025)	; VK_CARET
			KEY(000)	; VK_DOLLAR
			KEY(000)	; VK_POUND
			KEY(000)	; VK_EURO
			KEY(000)	; VK_PERCENT
			KEY(000)	; VK_EXCLAIM
			KEY(000)	; VK_QUESTION
			KEY(000)	; VK_LEFTBRACE
			KEY(000)	; VK_RIGHTBRACE
			KEY(057)	; VK_LEFTBRACKET
			KEY(089)	; VK_RIGHTBRACKET
			KEY(000)	; VK_LEFTPAREN
			KEY(000)	; VK_RIGHTPAREN
			KEY(103)	; VK_LESS
			KEY(104)	; VK_GREATER
			KEY(096)	; VK_UNDERSCORE
			KEY(000)	; VK_DEGREE
			KEY(000)	; VK_SECTION
			KEY(046)	; VK_TILDE
			KEY(024)	; VK_NEGATION
			KEY(004)	; VK_LSHIFT
			KEY(007)	; VK_RSHIFT
			KEY(006)	; VK_LALT
			KEY(009)	; VK_RALT
			KEY(005)	; VK_LCTRL
			KEY(008)	; VK_RCTRL
			KEY(126)	; VK_LGUI
			KEY(127)	; VK_RGUI
			KEY(113)	; VK_ESCAPE
			KEY(033)	; VK_PRINTSCREEN
			KEY(000)	; VK_SYSREQ
			KEY(062)	; VK_INSERT
			KEY(062)	; VK_KP_INSERT
			KEY(090)	; VK_DELETE
			KEY(076)	; VK_KP_DELETE
			KEY(048)	; VK_BACKSPACE
			KEY(063)	; VK_HOME
			KEY(063)	; VK_KP_HOME
			KEY(106)	; VK_END 
			KEY(106)	; VK_KP_END
			KEY(000)	; VK_PAUSE
			KEY(045)	; VK_BREAK
			KEY(032)	; VK_SCROLLLOCK
			KEY(078)	; VK_NUMLOCK
			KEY(065)	; VK_CAPSLOCK
			KEY(097)	; VK_TAB 
			KEY(074)	; VK_RETURN
			KEY(061)	; VK_KP_ENTER
			KEY(128)	; VK_APPLICATION
			KEY(064)	; VK_PAGEUP
			KEY(064)	; VK_KP_PAGEUP
			KEY(079)	; VK_PAGEDOWN
			KEY(079)	; VK_KP_PAGEDOWN
			KEY(058)	; VK_UP  
			KEY(058)	; VK_KP_UP
			KEY(042)	; VK_DOWN
			KEY(042)	; VK_KP_DOWN
			KEY(026)	; VK_LEFT
			KEY(026)	; VK_KP_LEFT
			KEY(122)	; VK_RIGHT
			KEY(122)	; VK_KP_RIGHT
			KEY(000)	; VK_KP_CENTER
			KEY(114)	; VK_F1  
			KEY(115)	; VK_F2  
			KEY(116)	; VK_F3  
			KEY(021)	; VK_F4  
			KEY(117)	; VK_F5  
			KEY(118)	; VK_F6  
			KEY(023)	; VK_F7  
			KEY(119)	; VK_F8  
			KEY(120)	; VK_F9  
			KEY(031)	; VK_F10 
			KEY(029)	; VK_F11 
			KEY(030)	; VK_F12 
			KEY(000)	; VK_GRAVE_a
			KEY(000)	; VK_GRAVE_e
			KEY(000)	; VK_GRAVE_i
			KEY(000)	; VK_GRAVE_o
			KEY(000)	; VK_GRAVE_u
			KEY(000)	; VK_GRAVE_y
			KEY(000)	; VK_ACUTE_a
			KEY(000)	; VK_ACUTE_e
			KEY(000)	; VK_ACUTE_i
			KEY(000)	; VK_ACUTE_o
			KEY(000)	; VK_ACUTE_u
			KEY(000)	; VK_ACUTE_y
			KEY(000)	; VK_GRAVE_A
			KEY(000)	; VK_GRAVE_E
			KEY(000)	; VK_GRAVE_I
			KEY(000)	; VK_GRAVE_O
			KEY(000)	; VK_GRAVE_U
			KEY(000)	; VK_GRAVE_Y
			KEY(000)	; VK_ACUTE_A
			KEY(000)	; VK_ACUTE_E
			KEY(000)	; VK_ACUTE_I
			KEY(000)	; VK_ACUTE_O
			KEY(000)	; VK_ACUTE_U
			KEY(000)	; VK_ACUTE_Y
			KEY(000)	; VK_UMLAUT_a
			KEY(000)	; VK_UMLAUT_e
			KEY(000)	; VK_UMLAUT_i
			KEY(000)	; VK_UMLAUT_o
			KEY(000)	; VK_UMLAUT_u
			KEY(000)	; VK_UMLAUT_y
			KEY(000)	; VK_UMLAUT_A
			KEY(000)	; VK_UMLAUT_E
			KEY(000)	; VK_UMLAUT_I
			KEY(000)	; VK_UMLAUT_O
			KEY(000)	; VK_UMLAUT_U
			KEY(000)	; VK_UMLAUT_Y
			KEY(000)	; VK_CARET_a
			KEY(000)	; VK_CARET_e
			KEY(000)	; VK_CARET_i
			KEY(000)	; VK_CARET_o
			KEY(000)	; VK_CARET_u
			KEY(000)	; VK_CARET_y
			KEY(000)	; VK_CARET_A
			KEY(000)	; VK_CARET_E
			KEY(000)	; VK_CARET_I
			KEY(000)	; VK_CARET_O
			KEY(000)	; VK_CARET_U
			KEY(000)	; VK_CARET_Y
			KEY(000)	; VK_CEDILLA_c
			KEY(000)	; VK_CEDILLA_C
			KEY(000)	; VK_TILDE_a
			KEY(000)	; VK_TILDE_o
			KEY(000)	; VK_TILDE_n
			KEY(000)	; VK_TILDE_A
			KEY(000)	; VK_TILDE_O
			KEY(000)	; VK_TILDE_N
			KEY(000)	; VK_UPPER_a
			KEY(000)	; VK_ESZETT
			KEY(000)	; VK_EXCLAIM_INV
			KEY(000)	; VK_QUESTION_INV
			KEY(000)	; VK_INTERPUNCT
			KEY(000)	; VK_DIAERESIS
			KEY(000)	; VK_SQUARE
			KEY(000)	; VK_CURRENCY
			KEY(000)	; VK_MU  
			KEY(000)	; VK_aelig
			KEY(000)	; VK_oslash
			KEY(000)	; VK_aring
			KEY(000)	; VK_AELIG
			KEY(000)	; VK_OSLASH
			KEY(000)	; VK_ARING
			KEY(000)	; VK_YEN
			KEY(000)	; VK_MUHENKAN
			KEY(000)	; VK_HENKAN
			KEY(000)	; VK_KATAKANA_HIRAGANA_ROMAJI
			KEY(000)	; VK_HANKAKU_ZENKAKU_KANJI
			KEY(000)	; VK_SHIFT_0
			KEY(000)	; VK_ASCII