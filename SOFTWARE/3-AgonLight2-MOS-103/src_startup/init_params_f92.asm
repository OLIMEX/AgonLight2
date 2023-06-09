;
; Title:	AGON MOS - C Startup Code
; Author:	Copyright (C) 2005 by ZiLOG, Inc.  All Rights Reserved.
; Modified By:	Dean Belfield
; Created:	10/07/2022
; Last Updated: 01/08/2022
;
; Modinfo:
; 14/07/2022:	Added coldBoot detection, exec16 function
; 15/07/2022:	Added further hardware/firmware initialisation in __init
; 24/07/2022:	Added timer2 global variable and moved exec_16 to misc.asm
; 26/07/2022:	Added _tmpLHU
; 01/08/2022:	Moved global variables to globals.asm

			INCLUDE	"../src/macros.inc"
			INCLUDE	"../src/equs.inc"

			INCLUDE "ez80f92.inc"

			XREF	__stack
			XREF	__init_default_vectors
			XREF	__c_startup
			XREF	__cstartup
			XREF	_main
			XREF	__CS0_LBR_INIT_PARAM
			XREF	__CS0_UBR_INIT_PARAM
			XREF	__CS0_CTL_INIT_PARAM
			XREF	__CS1_LBR_INIT_PARAM
			XREF	__CS1_UBR_INIT_PARAM
			XREF	__CS1_CTL_INIT_PARAM
			XREF	__CS2_LBR_INIT_PARAM
			XREF	__CS2_UBR_INIT_PARAM
			XREF	__CS2_CTL_INIT_PARAM
			XREF	__CS3_LBR_INIT_PARAM
			XREF	__CS3_UBR_INIT_PARAM
			XREF	__CS3_CTL_INIT_PARAM
			XREF	__CS0_BMC_INIT_PARAM
			XREF	__CS1_BMC_INIT_PARAM
			XREF	__CS2_BMC_INIT_PARAM
			XREF	__CS3_BMC_INIT_PARAM
			XREF	__FLASH_CTL_INIT_PARAM
			XREF	__FLASH_ADDR_U_INIT_PARAM
			XREF	__RAM_CTL_INIT_PARAM
			XREF	__RAM_ADDR_U_INIT_PARAM

			XDEF	__init
			XDEF	_abort
			XDEF	__exit
			XDEF	_exit
			
			XREF	__exec16
			XREF	_exec16
			
			XREF	GPIOB_SETMODE
			
			XREF 	_coldBoot		
			XREF 	_keycode
			XREF 	_timer2
			XREF 	_callSM
			XREF 	_tmpLHU			
;			
; Startup code
;
			DEFINE .STARTUP, SPACE = ROM
			SEGMENT .STARTUP
			
			.ASSUME ADL = 1

; Minimum default initialization
;
; Disable internal peripheral interrupt sources
; -- this will help during a RAM debug session --
;
__init:			ld a, %FF
			out0 (PB_DDR), a         ; GPIO
			out0 (PC_DDR), a         ;
			out0 (PD_DDR), a         ;
			ld a, %00
			out0 (PB_ALT1), a        ;
			out0 (PC_ALT1), a        ;
			out0 (PD_ALT1), a        ;
			out0 (PB_ALT2), a        ;
			out0 (PC_ALT2), a        ;
			out0 (PD_ALT2), a        ;
			out0 (TMR0_CTL), a       ; timers
			out0 (TMR1_CTL), a       ;
			out0 (TMR2_CTL), a       ;
			out0 (TMR3_CTL), a       ;
			out0 (TMR4_CTL), a       ;
			out0 (TMR5_CTL), a       ;
			out0 (UART0_IER), a      ; UARTs
			out0 (UART1_IER), a      ;
			out0 (I2C_CTL), a        ; I2C
			out0 (FLASH_IRQ), a      ; Flash
			ld a, %04
			out0 (SPI_CTL), a        ; SPI
			in0 a, (RTC_CTRL)        ; RTC, Writing to the RTC_CTRL register also
			and a, %BE               ;      resets the RTC count prescaler allowing
			out0 (RTC_CTRL), a       ;      the RTC to be synchronized to another time source
;
; Configure external memory/io
;
			ld a, __CS0_LBR_INIT_PARAM
			out0 (CS0_LBR), a
			ld a, __CS0_UBR_INIT_PARAM
			out0 (CS0_UBR), a
			ld a, __CS0_BMC_INIT_PARAM
			out0 (CS0_BMC), a
			ld a, __CS0_CTL_INIT_PARAM
			out0 (CS0_CTL), a

			ld a, __CS1_LBR_INIT_PARAM
			out0 (CS1_LBR), a
			ld a, __CS1_UBR_INIT_PARAM
			out0 (CS1_UBR), a
			ld a, __CS1_BMC_INIT_PARAM
			out0 (CS1_BMC), a
			ld a, __CS1_CTL_INIT_PARAM
			out0 (CS1_CTL), a

			ld a, __CS2_LBR_INIT_PARAM
			out0 (CS2_LBR), a
			ld a, __CS2_UBR_INIT_PARAM
			out0 (CS2_UBR), a
			ld a, __CS2_BMC_INIT_PARAM
			out0 (CS2_BMC), a
			ld a, __CS2_CTL_INIT_PARAM
			out0 (CS2_CTL), a

			ld a, __CS3_LBR_INIT_PARAM
			out0 (CS3_LBR), a
			ld a, __CS3_UBR_INIT_PARAM
			out0 (CS3_UBR), a
			ld a, __CS3_BMC_INIT_PARAM
			out0 (CS3_BMC), a
			ld a, __CS3_CTL_INIT_PARAM
			out0 (CS3_CTL), a
;   
; Enable internal memory
;
			ld a, __FLASH_ADDR_U_INIT_PARAM
			out0 (FLASH_ADDR_U), a
			ld a, __FLASH_CTL_INIT_PARAM
			out0 (FLASH_CTRL), a

			ld a, __RAM_ADDR_U_INIT_PARAM
			out0 (RAM_ADDR_U), a
			ld a, __RAM_CTL_INIT_PARAM
			out0 (RAM_CTL), a
;
; Setup Stack Pointer
;
			ld sp, __stack
;
; Detect warm or cold boot
;
			ld a, i			; Register I should be 0 on cold boot
			or a, a		
			ld a, 1			; Set to 1 if cold boot
			jr z, $F
			dec a			; Otherwise set to 0
$$:			push af 		; Stack AF, will store later as __c_startup clears globals area
;
; Initialize the interrupt vector table
;
			call __init_default_vectors
;
; Further hardware/firmware initialisation
;
			LD	A, GPIOMODE_INTRE
			LD	B, 2
			CALL	GPIOB_SETMODE
;
; Start application
;
			ld a, __cstartup
			or a, a
			jr z, __no_cstartup
			call __c_startup

			pop af			; Pop the coldboot value
			ld (_coldBoot), a	; And store


__no_cstartup:		ld hl, 0                ; hl = NULL
			push hl                 ; argv[0] = NULL
			ld ix, 0
			add ix, sp              ; ix = &argv[0]
			push ix                 ; &argv[0]
			pop hl
			ld de, 0                ; argc = 0
			call _main              ; int main(int argc, char *argv[]))
			pop de			; clean the stack

__exit:
_exit:
_abort:			jr $                	; If we return from main loop forever here


; Define global constants
;
			XREF _SYS_CLK_FREQ
			XDEF _SysClkFreq

_SysClkFreq:		DL _SYS_CLK_FREQ
			
			END
