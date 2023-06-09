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
			XDEF	_timer1_handler
			XDEF	_timer1

; AGON Timer 0 Interrupt Handler
;
_timer0_handler:	
			DI
			PUSH	AF
			IN0		A,(TMR0_CTL)		; Clear the timer interrupt
			PUSH	HL
			PUSH	DE
			
			LD		DE, 11
			LD		HL, (_timer0)		; Increment the delay timer
			
			ADD		HL, DE
			
			; INC		BC
			; INC		BC
			; INC		BC
			; INC		BC
			; INC		BC; x5
			
			; INC		BC
			; INC		BC
			; INC		BC
			; INC		BC
			; INC		BC ;x5

			; INC		BC
			; INC		BC
			; INC		BC
			; INC		BC
			; INC		BC ;x5	

			LD		(_timer0), HL
			POP		DE
			POP		HL
			POP		AF
			EI
			RETI.L
			
_timer1_handler:	
			DI
			PUSH	AF
			IN0		A,(TMR1_CTL)		; Clear the timer interrupt
			PUSH	BC
			LD		BC, (_timer1)		; Increment the delay timer
			INC		BC
			LD		(_timer1), BC
			POP		BC
			POP		AF
			EI
			RETI.L			
	
			SEGMENT DATA
			
_timer0			DS	3		
_timer1			DS	3