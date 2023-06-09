;; CP/M loader and MOS calls wrapper
;; (c) 2023 Aleksandr Sharikhin
CPM_SEG:	equ $5

	include "crt.inc"
	include "bios_gate.inc"
	include "terminal.inc"
	include "drive_emu.inc"

sys_ix: dl 0
sys_iy: dl 0

_main:
	ld (sys_ix), ix
	ld (sys_iy), iy

	xor a
	ld mb, a

	call fs_init
	and a
	jp z, _error

	call _term_init
	call.lil _cpm_restore
	
	ld a, CPM_SEG
	ld mb, a
	stmix
	jp.sis $DCFD

_error:
	xor a
	ld mb, a

	ld c, 0
	MOSCALL mos_fclose

	ld hl, @msg
	xor a
	ld bc, 0
	rst.lil $18
	ret
@msg:
	db "Error initing OS", 13, 10
	db "Check system files and try again", 13, 10, 0

_cpm_restore:
	ld hl, _cpm_image
	ld de, $5dcfd
	ld bc, _cpm_end - _cpm_image
	ldir
	ret.lil

_cpm_image:
	incbin "cpm.sys"
_cpm_end:

