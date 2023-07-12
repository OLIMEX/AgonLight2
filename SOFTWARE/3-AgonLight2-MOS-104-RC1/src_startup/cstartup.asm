;
; Title:	AGON MOS - C Startup Code
; Author:	Copyright (C) 2005 by ZiLOG, Inc.  All Rights Reserved.
; Modified By:	Dean Belfield
; Created:	10/07/2022
; Last Updated:	09/08/2022
;
; Modinfo:
; 01/08/2022:	Moved _errno to globals.asm
; 09/08/2022:	Reformatted

			XDEF __c_startup
			XDEF __cstartup
			XREF _errno
			XREF _main

			XREF __low_bss         ; Low address of bss segment
			XREF __len_bss         ; Length of bss segment
		
			XREF __low_data        ; Address of initialized data section
			XREF __low_romdata     ; Addr of initialized data section in ROM
			XREF __len_data        ; Length of initialized data section

			XREF __copy_code_to_ram
			XREF __len_code
			XREF __low_code
			XREF __low_romcode

__cstartup		EQU %1

			DEFINE .STARTUP, SPACE = ROM
			SEGMENT .STARTUP
			.ASSUME ADL=1

__c_startup:
_c_int0:
;
; Clear the uninitialized data section
;
			LD	BC, __len_bss			; Check for non-zero length
			LD	a, __len_bss >> 16
			OR	A, C
			OR	A, B
			JR	Z, _c_bss_done			; BSS is zero-length ...
			XOR	A, A
			LD 	(__low_bss), A
			SBC	HL, HL				; hl = 0
			DEC	BC				; 1st byte's taken care of
			SBC	HL, BC
			JR	Z, _c_bss_done  	        ; Just 1 byte ...
			LD	HL, __low_bss			; reset hl
			LD	DE, __low_bss + 1		; [de] = bss + 1
			LDIR					; Clear this section

_c_bss_done:
;
; Copy the initialized data section
;
			LD	BC, __len_data			; [bc] = data length
			LD	A, __len_data >> 16		; Check for non-zero length
			OR	A, C
			OR	A, B
			JR	Z, _c_data_done			; __len_data is zero-length ...
			LD	HL, __low_romdata		; [hl] = data_copy
			LD	DE, __low_data			; [de] = data
			LDIR					; Copy the data section

_c_data_done:
;
; Copy CODE (which may be in FLASH) to RAM if the
; copy_code_to_ram symbol is set in the link control file
;
			LD	A, __copy_code_to_ram
			OR	A, A
			JR	Z, _copy_code_to_ram_done
			LD	BC, __len_code			; [bc] = code length
			LD	A, __len_code >> 16		; Check for non-zero length
			OR	A, C
			OR	A, B
			JR	Z, _copy_code_to_ram_done	; __len_code is zero-length ...
			LD	HL, __low_romcode		; [hl] = code_copy
			LD	DE, __low_code			; [de] = code
			LDIR					; Copy the code section

_copy_code_to_ram_done:
;
; C environment created, continue with the initialization process
;
			RET

			END
