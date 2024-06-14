	ASSUME ADL=1
;; USE org $40000 for usual application
;; or $B0000 for MOS command
	org $40000
	jp _start

	align 64
	db "MOS" ; Header
	db 00    ; Version
	db 01 	 ; ADL
_start:
	push ix
	push iy

;	ld a, mos_sysvars
;	rst.lil $08

;	xor a
;	ld (ix+$28), a

	call _main
	pop iy
	pop ix

	ld hl, 0
	ret


;; Constants
mos_getkey:	equ	$00
mos_load:	equ	$01
mos_sysvars:	equ	$08
mos_fopen:	equ	$0a
mos_fclose:	equ	$0b
mos_fgetc:	equ	$0c
mos_fputc:	equ	$0d
mos_feof:	equ	$0e
mos_uopen:	equ	$15
mos_uclose:	equ	$16
mos_ugetc:	equ	$17
mos_uputc:	equ	$18
mos_fread:	equ	$1a
mos_fwrite:	equ	$1b
mos_flseek:	equ	$1c

;; File modes
fa_read:	equ	$01
fa_write:	equ	$02
fa_exist:	equ	$00
fa_create:	equ	$04
fa_cr_always:	equ	$08
fa_op_always:	equ	$10
fa_append:	equ	$30

;; A - character to print
putc:
	rst.lil $10
	ret

;; HLU - pointer to string
printZ:
	ld bc,0
	xor a
	rst.lil $18
	ret

	macro MOSCALL func
	ld a, func
	rst.lil $08
	endmacro


