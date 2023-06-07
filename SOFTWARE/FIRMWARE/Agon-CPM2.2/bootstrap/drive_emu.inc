
_trk:
	dl 0
_sec:
	dl 0
_dma:
	dl 0

_drive_home:
	or a
	sbc hl, hl
	ld (_trk), hl
	ret.lil

_drive_trk:
	ld (_trk), bc
	xor a
	ld (_trk+2), a
	ret.lil

_drive_sec:
	ld (_sec), bc
	xor a
	ld (_sec+2), a
	ret.lil

_drive_dma:
	ld (_dma), bc
	ld a, CPM_SEG
	ld (_dma+2), a
	xor a
	ret.lil

_calc_offset:
	ld hl, (_trk)
	
	add hl, hl ; *2
	add hl, hl ; *4
	add hl, hl ; *8
	add hl, hl ; *16
	add hl, hl ; *32
	add hl, hl ; *64

	ld bc, (_sec)
	add hl, bc
	ret

_drive_read:
	xor a
	ld mb, a

	call _calc_offset
	call fs_seek
	call fs_read

	ld a, CPM_SEG
	ld mb, a

	xor a
	ret.lil

_drive_write:
	xor a
	ld mb, a

	call _calc_offset
	call fs_seek
	call fs_write

	ld a, CPM_SEG
	ld mb, a

	xor a
	ret.lil
	

drive:
	db "cpm"
drive_letter:
	db "a.dsk", 0


f_handle: db 0

_drive_change:
	add a, 'a'
	ld (drive_letter), a

	xor a
	ld mb, a

	ld c, 0
	MOSCALL mos_fclose

	ld hl, drive
	ld c, fa_read+fa_write
	MOSCALL mos_fopen

	ld c, a

	ld a, CPM_SEG
	ld mb, a
	ld a, c

	ld (f_handle), a
	or a
	ret.lil

fs_init:
	ld c, 0
	MOSCALL mos_fclose

	ld hl, drive
	ld c, fa_read+fa_write
	MOSCALL mos_fopen
	ld (f_handle), a
	or a
	push af
	MOSCALL mos_sysvars
	xor a
	ld (ix+$28), a
	ld ix, (sys_ix)
	pop af
	ret 

fs_seek:
	add hl, hl ; *2
	add hl, hl ; *4
	add hl, hl ; *8
	add hl, hl ; *16
	add hl, hl ; *32
	add hl, hl ; *64
	add hl, hl ; *128

	ld e, 0
	ld a, (f_handle)
	ld c, a
	MOSCALL mos_flseek
	ret

fs_read:
	ld a, (f_handle)
	ld c, a

	ld de, 128
	ld hl, (_dma)

	MOSCALL mos_fread

	ret

fs_write:
	ld a, (f_handle)
	ld c, a
	ld de, 128
	ld hl, (_dma)
	MOSCALL mos_fwrite
	ret


