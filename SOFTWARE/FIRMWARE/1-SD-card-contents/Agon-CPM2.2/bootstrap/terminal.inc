PORT:		EQU	$C0
REG_RBR:	EQU	PORT+0
REG_THR:	EQU	PORT+0
REG_DLL:	EQU	PORT+0
REG_IER:	EQU	PORT+1
REG_MSR:	EQU	PORT+6
REG_FTC:	EQU	PORT+2
REG_LSR:	EQU	PORT+5
UART_LSR_ETX:	EQU $40
UART_LSR_ETH:	EQU $20
UART_LSR_RDY:	EQU $01

PD_DR:		EQU $a2

;; Init terminal
_term_init:
	ld hl, vdu_init
	ld bc, init_end - vdu_init
	rst.lil $18
	
	ld ix, serial_cfg
	MOSCALL mos_uopen

	ld a, 7
	out0 (REG_FTC), a ; Disable fifo

	ld a, 0
	out0 (REG_IER), a ; Disable ints

@wait:
	in0 a, (REG_LSR)
	and UART_LSR_RDY
	jr z, @wait

	in0 a, (REG_RBR)
	ret

serial_cfg:
	dl 115200
	db 8
	db 1
	db 0
	db 0
	db 0

vdu_init:
	db 23, 0, 255 ; Switch to terminal emulation
init_end:


_ser_out:
	in0 a, ($D5)
	and UART_LSR_ETX
	jr z, _ser_out

	ld a, c
	out0 ($D0), a
	xor a
	ret.lil

_ser_in:
	in0 a, ($D5)
	and UART_LSR_RDY
	jr z, _ser_in
	in0 a, ($d0)
	ret.lil

_ser_status:
	in0 a, ($D5)
	and UART_LSR_RDY
	ret.lil z
	ld a, $ff
	ret.lil
	
_term_out:
	ld a, ($50003)
	and 3
	jp z, _ser_out
_tty_out:
	in0 a, (PD_DR)
	tst a, 8
	jr nz, _term_out
@wait:
	in0 a, (REG_LSR)
	and UART_LSR_ETX
	jr z, @wait

	ld a, c
	out0 (REG_THR), a

	xor a
	ret.lil

_term_in:
	ld a, ($50003)
	and 3
	jp z, _ser_in
_tty_in:
	in0 a, (REG_LSR)
	and UART_LSR_RDY
	jr z, _tty_in
	in0 a, (REG_RBR)
;; ^@ fix
	and a
	jr z, _tty_in

;; TTY replacements
	cp 127
	jr nz, @f
	ld a, 8
@@:
	ret.lil

_term_status:
	ld a, ($50003)
	and 3
	jp z, _ser_status
_tty_status:
	in0 a, (REG_LSR)
	and UART_LSR_RDY
	ret.lil z
	ld a, $ff
	ret.lil
