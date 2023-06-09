KEY_LEFT: 	equ	8
KEY_RIGHT:	equ	21
KEY_UP: 	equ	11
KEY_DOWN:	equ	10


p_pos:		dl	level_buffer+33
p_sprite:	db	PLAYER_RIGHT

is_player:
	cp 1
	ret z
	cp 2
	ret z
	cp 3
	ret z
	cp 4
	ret

player_process:
	ld a, (p_sprite)
	ld hl, (p_pos)
	call map_poke
	

	ld a, (c_lf)
	and a
	jp nz, p_left

	ld a, (c_rt)
	and a
	jp nz, p_right

	ld a, (c_up)
	and a
	jp nz, p_up

	ld a, (c_dn)
	and a
	jp nz, p_down

	ret

p_left:
	ld a, PLAYER_LEFT
	ld (p_sprite), a

	ld hl, (p_pos)
	dec hl

	ld a, (hl)
	and a
	jr z, p_move

	cp FIELD
	jr z, p_move

	cp CRYSTAL
	jr z, p_crystal

	cp BOULDER
	ret nz
	push hl
	pop de

	dec de
	ld a, (de)
	and a
	ret nz
	
	ld a, BOULDER
	call map_poke_de
	xor a
	call map_poke
	ld hl, (p_pos)
	xor a
	call map_poke
	dec hl

	ld (p_pos), hl

	ld a, (p_sprite)
	call map_poke
	ret

p_crystal:
	push hl
	call beep
	ld hl, crystals_got
	inc (hl)
	pop hl
p_move:
	and a
	jr z, @move
	call noise
@move:
	
	ex de, hl
	ld hl, (p_pos)
	xor a
	call map_poke
	ex de, hl
	ld (p_pos), hl

	ld a, (p_sprite)
	call map_poke
	ret

p_right:
	ld a, PLAYER_RIGHT
	ld (p_sprite), a

	ld hl, (p_pos)
	inc hl

	ld a, (hl)
	and a
	jr z, p_move

	cp FIELD
	jr z, p_move

	cp CRYSTAL
	jr z, p_crystal

	cp BOULDER
	ret nz
	push hl
	pop de

	inc de
	ld a, (de)
	and a
	ret nz
	
	ld a, BOULDER
	call map_poke_de
	xor a
	call map_poke
	ld hl, (p_pos)
	xor a
	call map_poke
	inc hl

	ld (p_pos), hl

	ld a, (p_sprite)
	call map_poke
	ret

p_down:
	ld hl, (p_pos)
	ld de, 32
	add hl, de
	
	ld a, (hl)
	and a
	jr z, p_move

	cp FIELD
	jp z, p_move

	cp CRYSTAL
	jp z, p_crystal

	ret

p_up:
	ld hl, (p_pos)
	ld de, -32
	add hl, de

	ld a, (hl)
	and a
	jp z, p_move

	cp FIELD
	jp z, p_move

	cp CRYSTAL
	jp z, p_crystal

	ret

die:
	ld hl, (p_pos)
	ld a, 11
	call map_poke

	call die_snd
	
	call shake
	ld hl, (p_pos)
	call big_bang
	ld b, 20
@loop:
	push bc
	call level_life
	pop bc
	djnz @loop
	call load_level
	ret
