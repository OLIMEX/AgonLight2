gravity_l:
	db $09
gravity_h:
	db $0a

process_gravity:
	ld a, $09
	ld (gravity_l), a
	ld a, $0a
	ld (gravity_h), a

	call falling

	ld a, $06
	ld (gravity_l), a
	ld a, $07
	ld (gravity_h), a

	call falling
	ret

falling:
	ld hl, end_level_buffer
	ld bc, 736
@loop:
	ld a, (gravity_l)
	ld e, a
	ld a, (gravity_h)
	ld d, a

	ld a, (hl)
	cp e
	jr z, @usual_item
	cp d
	jr z, @falling_item
	
@skip:
	dec hl
	dec bc
	ld a, b
	or c
	jr nz, @loop
	ret

@usual_item:
	push hl
	ld de, 32
	add hl, de
	
	ld a, (hl)
	;; Kill enemy
	pop hl
	or a
	jr nz, @check_sides

	ld a, (gravity_h)
	call map_poke
	jr @skip

@check_sides:
	push hl
	ld de, 33
	add hl, de
	ld a, (hl)
	and a
	jr nz, @check_left

	pop hl
	push hl
	inc hl
	ld a, (hl)
	ld de, 32
	add hl, de
	and a
	jr nz, @check_left

	;; check enemy
	call is_enemy
	call z, kill_enemy

	ld a, (gravity_h)
	call map_poke
	pop hl
	xor a
	call map_poke
	jr @skip
@check_left:
	pop hl
	push hl
	ld de, 31
	add hl, de
	ld a, (hl)
	or a
	jr nz, @not_move

	pop hl
	push hl

	dec hl
	ld a, (hl)
	ld de, 32
	add hl, de
	and a

	jr nz, @not_move

	ld a, (hl)
	;; Check enemy
	ld a, (gravity_h)
	call map_poke
	pop hl

	xor a
	call map_poke
	jr @skip
@not_move:
	pop hl
	jr @skip
@falling_item:
	push hl
	ld  de, 32
	add hl, de
	ld a, (hl)
	;; check kill
	call is_player
	jp z, @die
	;; check enemy
	call is_enemy
	call z, kill_enemy

	pop hl
	or a
	jr nz, @not_fall
	xor a
	call map_poke
	push hl
	add hl,de
	ld a, (gravity_h)
	call map_poke
	pop hl
	jp @skip
@not_fall:
	ld a, (gravity_l)
	call map_poke
	call fall
	jp @skip
@die:
	pop hl
	jp die
