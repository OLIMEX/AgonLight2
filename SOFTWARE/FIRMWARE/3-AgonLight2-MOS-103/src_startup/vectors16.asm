;
; Title:	AGON MOS - C Startup Code
; Author:	Copyright (C) 2005 by ZiLOG, Inc.  All Rights Reserved.
; Modified By:	Dean Belfield
; Created:	10/07/2022
; Last Updated:	29/03/2023
;
; Modinfo:
; 11/07/2022:	Added RST_10 code - TX
; 15/07/2022:	Added __vertical_blank_handler
; 24/07/2022:	Added RST_08 code - MOS API and moved Timer2 ISR into here from timer.c
; 25/07/2022:	Runs in STMIX mode
; 03/08/2022:	Added RST handlers, moved interrupt handlers to interrupts.asm
; 08/08/2022:	RST_10 now calls check_CTS before sending
; 17/03/2023:	Added RST_18 code
; 22/03/2023:	Moved putch to serial.asm, renamed serial_PUTCH
; 29/03/2023:	Added support for UART1

			INCLUDE	"../src/macros.inc"
			INCLUDE	"../src/equs.inc"

			XREF 	__init
			XREF 	__low_rom
			
			XDEF 	_reset
			XDEF 	__default_nmi_handler
			XDEF 	__default_mi_handler
			XDEF 	__nvectors
			XDEF 	_init_default_vectors
			XDEF 	__init_default_vectors
			XDEF 	_set_vector
			XDEF	__set_vector
			XDEF	__2nd_jump_table
			XDEF	__1st_jump_table
			XDEF	__vector_table
			
			XREF	mos_api
			XREF	UART0_serial_PUTCH 
			XREF	SET_AHL24

NVECTORS 		EQU 48			; Number of interrupt vectors

; Save Interrupt State
;
SAVEIMASK		MACRO
			LD	A, I		; Sets parity bit to value of IEF2
			PUSH	AF
			DI			; Disable interrupts while loading table 
			MACEND

; Restore Interrupt State
;
RESTOREIMASK		MACRO
			POP	AF
			JP	PO, $+5		; Parity bit is IEF2
			EI
			MACEND

; Reset and all RST nn's
;
			DEFINE .RESET, SPACE = ROM
			SEGMENT .RESET

_reset:	
_rst0:			DI
			STMIX
			JP.LIL	__init
		
_rst8:			JP.LIL	_rst_08_handler
			DS	3
		
_rst10:			JP.LIL	_rst_10_handler
			DS	3

_rst18:			JP.LIL	_rst_18_handler
			DS	3
		
_rst20:			RET
			DS	7
		
_rst28:			RET
			DS	7

_rst30:			RET
			DS	7

_rst38:			RET
			DS 	%2D
		
_nmi:			JP.LIL	__default_nmi_handler

;
; Startup code
;
			DEFINE .STARTUP, SPACE = ROM
			SEGMENT .STARTUP

			.ASSUME ADL=1

; Number of vectors supported
;
__nvectors:		DW NVECTORS            ; extern unsigned short _num_vectors;

;	
; AGON RST handlers
;

; Execute an API command
; Parameters
; - A: The API command to run
;
_rst_08_handler:	CALL	mos_api
			RET.L

; Output a single character to the ESP32
; Parameters:
; - A: The character
;
_rst_10_handler:	CALL	UART0_serial_PUTCH
			RET.L

; Write a block of bytes out to the ESP32
; Parameters:
; - HLU: Buffer address
; -  BC: Size of buffer
; -   A: Delimiter (only if BCU = 0)
;
_rst_18_handler:	LD	E, A 			; Preserve the delimiter
			LD	A, MB			; Check if MBASE is 0
			OR	A, A 
			CALL	NZ, SET_AHL24		; No, so create a 24-bit pointer
			LD	A, B			; Check for BC = 0
			OR	C 			; Yes, so run in delimited mode?
			JR	Z, _rst_18_handler_1
;
; Standard loop mode
;
_rst_18_handler_0:	LD 	A, (HL)			; Fetch the character
			CALL	UART0_serial_PUTCH	; Output
			INC 	HL 			; Increment the buffer pointer
			DEC	BC 			; Decrement the loop counter
			LD	A, B 			; Is it 0?
			OR 	C 
			JR	NZ, _rst_18_handler_0	; No, so loop
			RET.L
;
; Delimited mode
;
_rst_18_handler_1:	LD 	A, (HL)			; Fetch the character
			CP 	E 			; Is it the delimiter?
			RET.L	Z 			; Yes, so return
			CALL	UART0_serial_PUTCH	; Output
			INC 	HL 			; Increment the buffer pointer
			JR 	_rst_18_handler_1	; Loop

; Default Non-Maskable Interrupt handler
;
__default_nmi_handler:	RETN.LIL

; Default Maskable Interrupt handler
;
__default_mi_handler:	EI
			RETI.L
					
; Initialize all potential interrupt vector locations with a known
; default handler.
;
; void _init_default_vectors(void);
;
__init_default_vectors:
_init_default_vectors:	PUSH	AF
			SAVEIMASK
			LD	HL, __default_mi_handler
			LD	A, %C3
			LD 	(__2nd_jump_table), A		; Place jp opcode
			LD 	(__2nd_jump_table + 1), HL	; __default_hndlr
			LD 	HL, __2nd_jump_table
			LD	DE, __2nd_jump_table + 4
			LD	BC, NVECTORS * 4 - 4
			LDIR
			IM	2
			LD 	A, __vector_table >> 8
			LD 	I, A				; Load interrupt vector base
			RESTOREIMASK
			POP	AF
			RET

; Installs a user interrupt handler in the 2nd interrupt vector jump table
;
; void * _set_vector(unsigned int vector, void(*handler)(void));
;
__set_vector:
_set_vector:		PUSH	IY
			LD	IY, 0
			ADD	IY, SP				; Standard prologue
			PUSH	AF
			SAVEIMASK
			LD	BC, 0				; Clear BC
			LD	B, 2				; Calculate 2nd jump table offset
			LD	C, (IY + 6)			; Vector offset
			MLT	BC				; BC is 2nd jp table offset
			LD	HL, __2nd_jump_table
			ADD	HL, BC				; HL is location of jp in 2nd jp table
			LD 	(HL), %C3			; Place jp opcode just in case
			INC	HL				; HL is jp destination address
			LD	BC, (IY + 9)			; BC is isr address
			LD 	DE, (HL)			; Save previous handler
			LD 	(HL), BC			; Store new isr address
			PUSH	DE
			POP	HL				; Return previous handler
			RESTOREIMASK
			POP	AF
			LD 	SP, IY				; Standard epilogue
			POP	IY
			RET

			DEFINE IVJMPTBL, SPACE = RAM
			SEGMENT IVJMPTBL

; 2nd Interrupt Vector Jump Table
;  - this table must reside in RAM anywhere in the 16M byte range
;  - each 4-byte entry is a jump to an interrupt handler
;
__2nd_jump_table:	DS NVECTORS * 4


; Interrupt Vector Table
;  - this segment must be aligned on a 256 byte boundary anywhere below
;    the 64K byte boundry
;  - each 2-byte entry is a 2-byte vector address
;
			DEFINE .IVECTS, SPACE = ROM, ALIGN = 100h
			SEGMENT .IVECTS

__vector_table:		DW __1st_jump_table + %00
			DW __1st_jump_table + %04
			DW __1st_jump_table + %08
			DW __1st_jump_table + %0c
			DW __1st_jump_table + %10
			DW __1st_jump_table + %14
			DW __1st_jump_table + %18
			DW __1st_jump_table + %1c
			DW __1st_jump_table + %20
			DW __1st_jump_table + %24
			DW __1st_jump_table + %28
			DW __1st_jump_table + %2c
			DW __1st_jump_table + %30
			DW __1st_jump_table + %34
			DW __1st_jump_table + %38
			DW __1st_jump_table + %3c
			DW __1st_jump_table + %40
			DW __1st_jump_table + %44
			DW __1st_jump_table + %48
			DW __1st_jump_table + %4c
			DW __1st_jump_table + %50
			DW __1st_jump_table + %54
			DW __1st_jump_table + %58
			DW __1st_jump_table + %5c
			DW __1st_jump_table + %60
			DW __1st_jump_table + %64
			DW __1st_jump_table + %68
			DW __1st_jump_table + %6c
			DW __1st_jump_table + %70
			DW __1st_jump_table + %74
			DW __1st_jump_table + %78
			DW __1st_jump_table + %7c
			DW __1st_jump_table + %80
			DW __1st_jump_table + %84
			DW __1st_jump_table + %88
			DW __1st_jump_table + %8c
			DW __1st_jump_table + %90
			DW __1st_jump_table + %94
			DW __1st_jump_table + %98
			DW __1st_jump_table + %9c
			DW __1st_jump_table + %a0
			DW __1st_jump_table + %a4
			DW __1st_jump_table + %a8
			DW __1st_jump_table + %ac
			DW __1st_jump_table + %b0
			DW __1st_jump_table + %b4
			DW __1st_jump_table + %b8
			DW __1st_jump_table + %bc

; 1st Interrupt Vector Jump Table
;  - this table must reside in the first 64K bytes of memory
;  - each 4-byte entry is a jump to the 2nd jump table plus offset
;
__1st_jump_table:	JP __2nd_jump_table + %00
			JP __2nd_jump_table + %04
			JP __2nd_jump_table + %08
			JP __2nd_jump_table + %0c
			JP __2nd_jump_table + %10
			JP __2nd_jump_table + %14
			JP __2nd_jump_table + %18
			JP __2nd_jump_table + %1c
			JP __2nd_jump_table + %20
			JP __2nd_jump_table + %24
			JP __2nd_jump_table + %28
			JP __2nd_jump_table + %2c
			JP __2nd_jump_table + %30
			JP __2nd_jump_table + %34
			JP __2nd_jump_table + %38
			JP __2nd_jump_table + %3c
			JP __2nd_jump_table + %40
			JP __2nd_jump_table + %44
			JP __2nd_jump_table + %48
			JP __2nd_jump_table + %4c
			JP __2nd_jump_table + %50
			JP __2nd_jump_table + %54
			JP __2nd_jump_table + %58
			JP __2nd_jump_table + %5c
			JP __2nd_jump_table + %60
			JP __2nd_jump_table + %64
			JP __2nd_jump_table + %68
			JP __2nd_jump_table + %6c
			JP __2nd_jump_table + %70
			JP __2nd_jump_table + %74
			JP __2nd_jump_table + %78
			JP __2nd_jump_table + %7c
			JP __2nd_jump_table + %80
			JP __2nd_jump_table + %84
			JP __2nd_jump_table + %88
			JP __2nd_jump_table + %8c
			JP __2nd_jump_table + %90
			JP __2nd_jump_table + %94
			JP __2nd_jump_table + %98
			JP __2nd_jump_table + %9c
			JP __2nd_jump_table + %a0
			JP __2nd_jump_table + %a4
			JP __2nd_jump_table + %a8
			JP __2nd_jump_table + %ac
			JP __2nd_jump_table + %b0
			JP __2nd_jump_table + %b4
			JP __2nd_jump_table + %b8
			JP __2nd_jump_table + %bc

			END
