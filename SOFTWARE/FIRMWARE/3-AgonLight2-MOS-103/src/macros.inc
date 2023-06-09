;
; Title:	AGON MOS - Useful Macros
; Author:	Dean Belfield
; Created:	15/07/2022
; Last Updated:	19/09/2022
;
; Modinfo:
; 08/08/2022:	Added GET_GPIO
; 09/09/2022:	Commented

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
				
