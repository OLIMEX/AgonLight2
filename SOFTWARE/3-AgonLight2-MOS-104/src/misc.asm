;
; Title:	AGON MOS - Miscellaneous helper functions
; Author:	Dean Belfield
; Created:	24/07/2022
; Last Updated: 15/04/2023
;
; Modinfo:
; 03/08/2022:	Added SET_AHL24 and SET_ADE24
; 10/08/2022:	Optimised SET_ADE24
; 08/11/2022:	Fixed return value bug in exec16
; 19/11/2022:	Added exec24 and params for exec16/24 functions
; 09/03/2023:	Added wait_timer0
; 20/03/2023:	Function exec24 now preserves MB
; 15/04/2023:	Added GET_AHL24

			INCLUDE	"macros.inc"
			INCLUDE	"equs.inc"

			.ASSUME	ADL = 1

			DEFINE .STARTUP, SPACE = ROM
			SEGMENT .STARTUP
							
			XDEF	SWITCH_A
			XDEF	SET_AHL24
			XDEF	GET_AHL24
			XDEF	SET_ADE24
			
			XDEF	__exec16
			XDEF	__exec24
			XDEF	__wait_timer0 
			
			XDEF	_exec16			
			XDEF	_exec24
			XDEF	_wait_timer0
			XDEF	_timer0_delay

			XREF	_callSM
			
; Switch on A - lookup table immediately after call
;  A: Index into lookup table
;
SWITCH_A:		EX	(SP), HL		; Swap HL with the contents of the top of the stack
			ADD	A, A			; Multiply A by two
			ADD8U_HL 			; Add to HL (macro)
			LD	A, (HL)			; follow the call. Fetch an address from the
			INC	HL 			; table.
			LD	H, (HL)
			LD	L, A
			EX	(SP), HL		; Swap this new address back, restores HL
			RET				; Return program control to this new address			
			
; Set the MSB of HL (U) to A
;
SET_AHL24:		PUSH	HL			
			LD	HL, 2
			ADD	HL, SP
			LD	(HL), A
			POP	HL
			RET	

; Get the MSB of HL (U) in A
;
GET_AHL24:		PUSH	HL 
			LD	HL, 2
			ADD	HL, SP
			LD	A, (HL)
			POP	HL
			RET

; Set the MSB of DE (U) to A
;
SET_ADE24:		EX	DE, HL
			PUSH	HL
			LD	HL, 2
			ADD	HL, SP
			LD	(HL), A
			POP	HL
			EX	DE, HL
			RET

; Execute a program in RAM
; int * _exec24(UINT24 address, char * params)
; Params:
; - address: The 24-bit address to call
; - params: 24-bit pointer to the params buffer
;
; This function will call the 24 bit address and keep the eZ80 in ADL mode
; The called function must do a RET and take care of preserving registers
;
__exec24:
_exec24:		PUSH 	IY
			LD	IY, 0
			ADD	IY, SP		; Standard prologue
			PUSH 	AF		; Stack any registers being used
			PUSH	DE
			PUSH	IX
			LD	A, MB 		; Preserve the MBASE register
			PUSH	AF 
			LD	DE, (IY+6)	; Get the address
			LD	A, (IY+8)	; And the high byte for the code segment
			LD	HL, (IY+9)	; Load HLU with the pointer to the params
;
; Write out a short subroutine "JP (DE)" to RAM
;			
			LD	IX, _callSM	; Storage for the self modified routine
			LD	(IX + 0), C3h	; JP llhhuu
			LD	(IX + 1), E
			LD	(IX + 2), D
			LD	(IX + 3), A	
;
			JR	_execSM		; Save some bytes, jump to _exec16 to finish the call

; Execute a program in RAM
; int * _exec16(UINT24 address, char * params)
; Params:
; - address: The 24-bit address to call
; - params: 24-bit pointer to the params buffer
;
; This function will call the 24 bit address and switch the eZ80 into Z80 mode (ADL=0)
; The called function must do a RET.LIS (49h, C9h) and take care of preserving registers
;
__exec16:
_exec16:		PUSH 	IY
			LD	IY, 0
			ADD	IY, SP		; Standard prologue
			PUSH 	AF		; Stack any registers being used
			PUSH	DE
			PUSH	IX
			LD	A, MB		; Preserve the MBASE register
			PUSH	AF
			LD	DE, (IY+6)	; Get the address
			LD	A, (IY+8)	; And the high byte for the code segment
			LD	MB, A		; Set the MBASE register
			LD	HL, (IY+9)	; Load HLU with the pointer to the params			
;
; Write out a short subroutine "CALL.IS (DE): RET" to RAM
;

			LD	IX, _callSM	; Storage for the self modified routine
			LD	(IX + 0), 49h	; CALL.IS llhh
			LD	(IX + 1), CDh
			LD	(IX + 2), E
			LD	(IX + 3), D
			LD	(IX + 4), C9h	; RET		
;
_execSM:		CALL	_callSM		; Call the subroutine
;
			POP	AF		; Restore the MBASE register
			LD	MB, A
			POP	IX
			POP	DE
			POP 	AF
			LD	SP, IY          ; Standard epilogue
			POP	IY
			RET	

; Wait for timer0 to hit 0
;
__wait_timer0:
_wait_timer0:		PUSH	AF 
			PUSH	BC 
			IN0	A, (TMR0_CTL)	; Enable the timer
			OR	3
			OUT0	(TMR0_CTL), A
$$:			IN0	B, (TMR0_DR_L)	; Fetch the counter L
			IN0 	A, (TMR0_DR_H)	; And the counter H
			OR	B 
			JR	NZ, $B
			POP	BC 
			POP	AF 
			RET

_timer0_delay:
			POP		HL
			POP		BC
			PUSH		BC
			TIMER_SET_BC	0
			TIMER_START	0
			TIMER_WAIT	0
			JP		(HL)

END
