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

	ld ix,argv
	call _parse_args
	ld a,c
	ld (argc),a

	call _main
	pop iy
	pop ix

	ld hl,0
	ret

_parse_args:
	call _skip_spaces
	ld bc,0
	ld b,MAX_ARGS
_parse1:
	push bc
	push hl
	call _get_token
	ld a,c
	pop de
	pop bc
	and a
	ret z

	ld (ix+0),de
	push hl
	pop de
	call _skip_spaces
	xor a
	ld (de),a
	inc ix
	inc ix
	inc ix
	inc c
	ld a, c
	cp b
	jr c,_parse1
	ret

_get_token:
	ld c,0
@loop:
	ld a,(hl)
	or a
	ret z

	cp 13
	ret z

	cp 32
	ret z

	inc hl
	inc c
	jr @loop

_skip_spaces:
	ld a,(hl)
	cp 32
	ret nz
	inc hl
	jr _skip_spaces

argc:	db	0
argv:	ds	3*MAX_ARGS

;; Constants
mos_getkey:	equ	$00
mos_load:	equ	$01
mos_sysvars:	equ	$08
mos_editline:	equ	$09
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


