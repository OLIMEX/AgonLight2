;
; Title:	AGON MOS - Useful Macros
; Author:	Dean Belfield
; Created:	15/07/2022
; Last Updated:	08/06/2023
;
; Modinfo:
; 08/08/2022:	Added GET_GPIO
; 09/09/2022:	Commented
; 08/06/2023:	Add timer-related macros

; Used by macros
		INCLUDE	"equs.inc"

; References to functions called by Macros
		XREF	_timer0_delay


; Add A to HL (unsigned)
;
ADD8U_HL:		MACRO 
			ADD	A, L 
			LD	L, A 
			ADC	A, H
			SUB	L
			LD	H, A 
			ENDMACRO 

; Set a GPIO register
; Parameters:
; - REG: Register to set
; - VAL: Bit(s) to set (1: set, 0: ignore)
;
SET_GPIO:		MACRO	REG, VAL
			IN0	A,(REG)
			OR	VAL
			OUT0	(REG),A
			ENDMACRO

; Reset a GPIO register
; Parameters:
; - REG: Register to set
; - VAL: Bit(s) to reset (1: reset, 0: ignore)
;	
RES_GPIO:		MACRO	REG, VAL
			PUSH	BC
			LD	A, VAL
			CPL
			LD	C, A
			IN0	A,(REG)
			AND	C
			OUT0	(REG),A
			POP	BC
			ENDMACRO

; Get a GPIO register
; Parameters:
; - REG: Register to test
; - VAL: Bit(s) to test
;	
GET_GPIO:		MACRO	REG, VAL
			IN0	A,(REG)
			TST	A, VAL
			ENDMACRO

; Set a TIMER to the value in register BC
; Parameters:
; - TIMER: Timer to set
;
TIMER_SET_BC:		MACRO	TIMER
			IF	TIMER >= 0 && TIMER <= 5
				LD	A,%0C
				OUT0	(TMR&TIMER&_CTL),A
				OUT0	(TMR&TIMER&_RR_L),C
				OUT0	(TMR&TIMER&_RR_H),B
			ELSE
				ERROR
			ENDIF
			ENDMACRO

; Set a timer to the given *constant* value in milliseconds
; Parameters:
; - TIMER:    Timer set set
; - DELAY_MS: Constant delay in milliseconds
;
TIMER_SET:		MACRO	TIMER,DELAY_MS
			IF	DELAY_MS < 1 || DELAY_MS > 910
				ERROR
			ENDIF
			LD		BC,MASTERCLOCK / 1000 / 256 * DELAY_MS
			TIMER_SET_BC	0
			ENDMACRO

;Start a timer
; Parameters:
; - TIMER: Timer to start
;
TIMER_START:		MACRO	TIMER
			IF	TIMER >= 0 && TIMER <= 5
				IN0	A,(TMR&TIMER&_CTL)
				OR	A,%03
				OUT0	(TMR&TIMER&_CTL),A
			ENDIF
			ENDMACRO

; Reset a timer to stop it running
; Leaves the rest of the timer configuration unchanged so it can be restarted
; Parameters:
; - TIMER: Timer to reset
;
TIMER_RESET:		MACRO	TIMER
			IF	TIMER >= 0 && TIMER <= 5
				IN0	A,(TMR&TIMER&_CTL)
				AND	A,11111100b
				OUT0	(TMR&TIMER&_CTL),A
			ELSE
				ERROR
			ENDIF
			ENDMACRO

; Test if the given timer has expired
; Parameters:
; - TIMER: Timer to test
; Output:
; - AF: Carry Flag set or clear depending on whether timer has expired
;
TIMER_EXP?:		MACRO	TIMER
			IF	TIMER >= 0 && TIMER <= 5
				IN0	A,(TMR&TIMER&_CTL)
			ELSE
				ERROR
			ENDIF
			RLA
			ENDMACRO

; Wait for a timer to count down to zero
; Parameters:
; - TIMER: Timer to wait on
;
TIMER_WAIT:		MACRO	TIMER
$$loop:			TIMER_EXP?	TIMER
			JR		NC,$$loop
			ENDMACRO

; Delay for the given (constant) number of milliseconds using *Timer 0*
; Parameters:
; - DELAY_MS: Number of milliseconds to delay
;
; NB: Can wait between 1 and 910 milliseconds based on 18.432MHz clock
;
DELAY_MS:		MACRO	DELAY_MS
			IF	DELAY_MS < 1 || DELAY_MS > 910
				ERROR
			ENDIF
			LD	BC,MASTERCLOCK / 1000 / 256 * DELAY_MS
			PUSH	BC
			CALL	_timer0_delay
			POP	BC
			ENDMACRO

END
