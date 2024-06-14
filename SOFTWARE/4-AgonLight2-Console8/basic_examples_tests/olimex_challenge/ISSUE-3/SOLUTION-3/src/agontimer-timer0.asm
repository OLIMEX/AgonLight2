;
; Title:	AGON Interrupt handler for timer0 in userspace
; Author:	Jeroen Venema
; Created:	22/01/2023
; Last Updated:	22/01/2023

			INCLUDE "ez80f92.inc"

			.ASSUME	ADL = 1
			SEGMENT CODE
			
			XDEF	_timer0_handler
			XDEF	_timer0

; AGON Timer 0 Interrupt Handler
;
_timer0_handler:	
			DI
			PUSH	AF
			IN0		A,(TMR0_CTL)		; Clear the timer interrupt
			PUSH	BC
			LD		BC, (_timer0)		; Increment the delay timer
			INC		BC
			LD		(_timer0), BC
			POP		BC
			POP		AF
			EI
			RETI.L
	
			SEGMENT DATA
			
_timer0			DS	3