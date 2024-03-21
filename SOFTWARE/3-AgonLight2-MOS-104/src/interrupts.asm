;
; Title:	AGON MOS - Interrupt handlers
; Author:	Dean Belfield
; Created:	03/08/2022
; Last Updated:	29/03/2023
;
; Modinfo:
; 09/03/2023:	No longer uses timer interrupt 0 for SD card timing
; 29/03/2023:	Added support for UART1
; 10/11/2023:	Added support for I2C

			INCLUDE	"macros.inc"
			INCLUDE	"equs.inc"
			INCLUDE "ez80f92.inc"
			INCLUDE "i2c.inc"

			.ASSUME	ADL = 1

			DEFINE .STARTUP, SPACE = ROM
			SEGMENT .STARTUP
			
			XDEF	_vblank_handler
			XDEF	_uart0_handler
			XDEF	_i2c_handler

			XREF	_clock
			XREF	_vdp_protocol_data
			
			XREF	UART0_serial_RX
			XREF	UART0_serial_TX
			XREF	mos_api
			XREF	vdp_protocol			
			
			XREF	_i2c_slave_rw
			XREF	_i2c_error
			XREF	_i2c_role
			XREF	_i2c_msg_ptr
			XREF	_i2c_msg_size

; AGON Vertical Blank Interrupt handler
;
_vblank_handler:	DI
			PUSH		AF
			SET_GPIO 	PB_DR, 2		; Need to set this to 2 for the interrupt to work correctly
			PUSH		BC
			PUSH		DE
			PUSH		HL	
			LD 		HL, (_clock)		; Increment the 32-bit clock counter
			LD		BC, 2			; By 2, effectively timing in centiseconds
			ADD		HL, BC
			LD		(_clock), HL
			LD		A, (_clock + 3)
			ADC		A, 0
			LD		(_clock + 3), A			
			POP		HL
			POP		DE
			POP		BC
			POP		AF
			EI	
			RETI.L
			
; AGON UART0 Interrupt Handler
;
_uart0_handler:		DI
			PUSH		AF
			PUSH		BC
			PUSH		DE
			PUSH		HL
			CALL		UART0_serial_RX
			LD		C, A		
			LD		HL, _vdp_protocol_data
			CALL		vdp_protocol
			POP		HL
			POP		DE
			POP		BC
			POP		AF
			EI
			RETI.L	

; AGON I2C Interrupt handler
;
_i2c_handler:
			DI
			PUSH	AF
			PUSH	HL
			PUSH	DE
			IN0		A, (I2C_SR)				; input I2C status register - switch case to this status value
			AND		11111000b				; cancel lower 3 bits, so we can use RRA. This will save 1 T-state
			RRA
			RRA
			RRA								; bits [7:3] contain the jumpvector
			CALL	i2c_handle_sr_vector
			; and switch on the vectors in this table
			DW		i2c_case_buserror		; 00h
			DW		i2c_case_master_start	; 08h
			DW		i2c_case_invalid		; 10h
			DW		i2c_case_aw_acked		; 18h
			DW		i2c_case_aw_nacked		; 20h
			DW		i2c_case_db_acked		; 28h
			DW		i2c_case_db_nacked		; 30h
			DW		i2c_case_arblost		; 38h
			DW		i2c_case_mr_ar_ack		; 40h
			DW		i2c_case_mr_ar_nack		; 48h
			DW		i2c_case_mr_dbr_ack		; 50h
			DW		i2c_case_mr_dbr_nack	; 58h
			DW		i2c_case_toimplement	; 60h - slave
			DW		i2c_case_toimplement	; 68h - slave
			DW		i2c_case_toimplement	; 70h - slave
			DW		i2c_case_toimplement	; 78h - slave
			DW		i2c_case_toimplement	; 80h - slave
			DW		i2c_case_toimplement	; 88h - slave
			DW		i2c_case_toimplement	; 90h - slave
			DW		i2c_case_toimplement	; 98h - slave
			DW		i2c_case_toimplement	; A0h - slave
			DW		i2c_case_toimplement	; A8h - slave
			DW		i2c_case_toimplement	; B0h - slave
			DW		i2c_case_toimplement	; B8h - slave
			DW		i2c_case_toimplement	; C0h - slave
			DW		i2c_case_toimplement	; C8h - slave
			DW		i2c_case_toimplement	; D0h - 10bit I2C address
			DW		i2c_case_toimplement	; D8h - 10bit I2C address
			DW		i2c_case_invalid		; E0h
			DW		i2c_case_invalid		; E8h
			DW		i2c_case_invalid		; F0h
			DW		i2c_case_invalid		; F8h - Should never produce an interrupt

i2c_handle_sr_vector:
			EX		(SP), HL	; Swap HL with the contents of the top of the stack
			ADD		A, A		; Multiply A by two
			ADD		A, L 
			LD		L, A 
			ADC		A, H
			SUB		L
			LD		H, A		; Add 8bit A to HL 
			LD		A, (HL)		; Fetch vector adress from the table
			INC		HL
			LD		H, (HL)
			LD		L, A
			EX		(SP), HL	; Swap this new address back, restores HL
			RET					; Return program control to this new address		

i2c_case_buserror: ; 00h
			LD		A, RET_BUS_ERROR
			LD		(_i2c_error),A
			
			; perform software reset of the bus
			XOR		A
			OUT0	(I2C_SRR),A
			LD		HL, _i2c_role
			LD		A, I2C_IDLE	; READY state
			LD		(HL),A

			POP		DE
			POP		HL
			POP		AF
			EI
			RETI.L

i2c_case_master_start:		; 08h
i2c_case_master_repstart:	; 10h
			LD		A, (_i2c_slave_rw)		; load slave address and r/w bit
			OUT0	(I2C_DR), A		; store to I2C Data Register
			LD		A, I2C_CTL_IEN | I2C_CTL_ENAB | I2C_CTL_AAK
			OUT0	(I2C_CTL),A		; set to Control register

			POP		DE
			POP		HL
			POP		AF
			EI
			RETI.L

i2c_case_aw_acked:	; 18h
i2c_case_db_acked:	; 28h
			; Check size and size--
			LD		A, (_i2c_msg_size)
			OR		A
			JR		Z, i2c_sendstop
			DEC		A
			LD		(_i2c_msg_size), A

			; load pointer
			LD		HL, _i2c_msg_ptr
			LD		DE, HL
			LD		HL, (HL)

			; Load indexed byte from buffer
			LD		A, (HL)

			OUT0	(I2C_DR), A		; store to I2C Data Register
			LD		A, I2C_CTL_IEN | I2C_CTL_ENAB | I2C_CTL_AAK
			OUT0	(I2C_CTL),A		; set to Control register

			INC		HL				; pointer++
			EX		DE, HL
			LD		(HL), DE

			POP		DE
			POP		HL
			POP		AF
			EI
			RETI.L

i2c_case_aw_nacked:	; 20h
i2c_case_mr_ar_nack: ; 48h
			LD		A, RET_NORESPONSE
			LD		(_i2c_error),A
			JP		i2c_sendstop
			
i2c_case_db_nacked:	; 30h
			LD		A, RET_DATA_NACK
			LD		(_i2c_error),A
			JP 		i2c_sendstop

i2c_case_arblost:	; 38h
			LD		A, RET_ARB_LOST
			LD		(_i2c_error),A
			JP 		i2c_sendstop

i2c_case_mr_dbr_ack: ; 50h
			; calculate offset address into i2c_mbuffer
			LD		HL, _i2c_msg_ptr
			LD		DE, HL
			LD		HL, (HL)

			IN0		A,(I2C_DR)		; load byte from I2C Data Register
			LD		(HL),A			; store in buffer at calculated index

			INC		HL				; pointer++
			EX		DE, HL
			LD		(HL), DE
;			; intentionally falling through to next case
i2c_case_mr_ar_ack: ; 40h		
			LD		A, (_i2c_msg_size)
			CP		1					; last byte to receive?
			JR		Z, $F

			LD		A, I2C_CTL_IEN | I2C_CTL_ENAB | I2C_CTL_AAK	; reply with ACK
			JR		$end
$$:
			LD		A, I2C_CTL_IEN | I2C_CTL_ENAB				; reply without ACK	
$end:		OUT0	(I2C_CTL),A		; set to Control register
			; size--
			LD		A, (_i2c_msg_size)
			DEC		A
			LD		(_i2c_msg_size), A

			POP		DE
			POP		HL
			POP		AF
			EI
			RETI.L
			
i2c_case_mr_dbr_nack: ; 58h
			; load pointer
			LD		HL, _i2c_msg_ptr
			LD		HL, (HL)

			IN0		A,(I2C_DR)			; load byte from I2C Data Register
			LD		(HL),A				; store in buffer at calculated index
						
			JR		i2c_sendstop

i2c_case_invalid:
i2c_case_toimplement:
i2c_sendstop:
			; send stop first to go to idle state
			LD		A, I2C_CTL_ENAB | I2C_CTL_STP			
			OUT0	(I2C_CTL),A		; set to Control register			
$$:
			IN0		A,(I2C_CTL)
			AND		I2C_CTL_STP		; STP bit still in place?
			JR		NZ, $B
			
			; Release control of the bus
			XOR		A				; all bits of I2C_CTL to 0
			OUT0	(I2C_CTL),A		; set to Control register I2C_CTL
			LD		HL, _i2c_role
			LD		A, I2C_IDLE	; IDLE state
			LD		(HL),A

			POP		DE
			POP		HL
			POP		AF
			EI
			RETI.L
	
			END
