sound:
	ld a, l
	ld (@w_freq), a
	
	ld a, h
	ld (@w_freq+1), a

	ld a, (@chan)
	xor 3
	ld (@chan), a	

	ld hl, @cmd
	ld bc, @end-@cmd
	rst.lil $18
	ret
@cmd:
	db 23, 0, $85
@chan:  db 1
	db 1, 127
@w_freq:
	dw 0
	dw 50
@end:

noise:
	push af
	push bc
	push de
	push hl
	ld hl, 40
	call sound
	pop hl
	pop de
	pop bc
	pop af
	ret

win_snd:
	push af
	push bc
	push de
	push hl
	ld hl, 392
	call sound
	call delay

	ld hl, 494
	call sound
	call delay

	ld hl, 587
	call sound
	call delay

	pop hl
	pop de
	pop bc
	pop af
	ret


die_snd:
	push af
	push bc
	push de
	push hl
	ld hl, 349
	call sound
	call delay

	ld hl, 208
	call sound
	call delay

	ld hl, 130
	call sound
	call delay

	pop hl
	pop de
	pop bc
	pop af
	ret

beep:
	push af
	push bc
	push hl
	push de
	ld hl, 1500
	call sound
	pop de
	pop hl
	pop bc
	pop af
	ret

fall:
	push af
	push bc
	push hl
	push de
	ld hl, 60
	call sound
	pop de
	pop hl
	pop bc
	pop af
	ret


shake:
	push af
	push bc
	push hl
	push de
	ld b, 4
@loop:
	push bc

	call vsync
	ld hl, @cmd1
	call do_scroll
	call vsync
	ld hl, @cmd2
	call do_scroll

	pop bc

	djnz @loop
	pop de
	pop hl
	pop bc
	pop af
	ret

@cmd1:
	db 23, 7, 1, 1, 4
@cmd2:
	db 23, 7, 1, 0, 4

do_scroll:
	ld bc, 5
	rst.lil $18
	ret


slide_off:
	ld b, $3f
@loop:
	push bc
	call vsync
	ld hl, @cmd
	call do_scroll
	pop bc
	djnz @loop
	ret
@cmd:
	db 23, 7, 1, 2, 8
@end:
