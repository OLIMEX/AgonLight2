;
; Title:	AGON MOS - gpio code
; Author:	Dean Belfield
; Created:	15/07/2022
; Last Updated:	24/07/2022
;
; Modinfo:
; 24/07/2022:	Moved SWITCH_A to misc.asm

			INCLUDE	"macros.inc"
			INCLUDE	"equs.inc"

			.ASSUME	ADL = 1

			DEFINE .STARTUP, SPACE = ROM
			SEGMENT .STARTUP
				
			XDEF	GPIOB_SETMODE				
			XREF	SWITCH_A
			
;  A: Mode
;  B: Pins
;  				
GPIOB_SETMODE:		CALL	SWITCH_A
			DW	GPIOB_M0	; Output
			DW	GPIOB_M1	; Input
			DW	GPIOB_M2	; Open Drain IO
			DW	GPIOB_M3	; Open Source IO
			DW	GPIOB_M4	; Interrupt, Dual Edge
			DW	GPIOB_M5	; Alt Function
			DW	GPIOB_M6	; Interrupt, Active Low
			DW	GPIOB_M7	; Interrupt, Active High
			DW	GPIOB_M8	; Interrupt, Falling Edge
			DW	GPIOB_M9	; Interrupt, Rising Edge

; Output
;
GPIOB_M0:		RES_GPIO PB_DDR,  B
			RES_GPIO PB_ALT1, B
			RES_GPIO PB_ALT2, B
			RET

; Input
;
GPIOB_M1:		SET_GPIO PB_DDR,  B
			RES_GPIO PB_ALT1, B
			RES_GPIO PB_ALT2, B
			RET

; Open Drain IO
;
GPIOB_M2:		RES_GPIO PB_DDR,  B
			SET_GPIO PB_ALT1, B
			RES_GPIO PB_ALT2, B
			RET

; Open Source IO
;
GPIOB_M3:		SET_GPIO PB_DDR,  B
			SET_GPIO PB_ALT1, B
			RES_GPIO PB_ALT2, B
			RET

; Interrupt, Dual Edge
;
GPIOB_M4:		SET_GPIO PB_DR,   B
			RES_GPIO PB_DDR,  B
			RES_GPIO PB_ALT1, B
			RES_GPIO PB_ALT2, B
			RET

; Alt Function
;
GPIOB_M5:		SET_GPIO PB_DDR,  B
			RES_GPIO PB_ALT1, B
			SET_GPIO PB_ALT2, B
			RET

; Interrupt, Active Low
;
GPIOB_M6:		RES_GPIO PB_DR,   B
			RES_GPIO PB_DDR,  B
			SET_GPIO PB_ALT1, B
			SET_GPIO PB_ALT2, B
			RET


; Interrupt, Active High
;
GPIOB_M7:		SET_GPIO PB_DR,   B
			RES_GPIO PB_DDR,  B
			SET_GPIO PB_ALT1, B
			SET_GPIO PB_ALT2, B
			RET


; Interrupt, Falling Edge
;
GPIOB_M8:		RES_GPIO PB_DR,   B
			SET_GPIO PB_DDR,  B
			SET_GPIO PB_ALT1, B
			SET_GPIO PB_ALT2, B
			RET
	
; Interrupt, Rising Edge
;
GPIOB_M9:		SET_GPIO PB_DR,   B
			SET_GPIO PB_DDR,  B
			SET_GPIO PB_ALT1, B
			SET_GPIO PB_ALT2, B
			RET	