
tile_ptr:	dl 0

; A - tile number
is_enemy:
	cp ENEMY_LEFT
	ret z
	cp ENEMY_RIGHT
	ret z
	cp ENEMY_UP
	ret z
	cp ENEMY_DOWN
	ret

kill_enemy:
	push hl
	call big_bang
	pop hl
	ret

big_bang:
	dec hl
	ld a, (hl)

	cp BRICK
	jr z, @n
	cp CRYSTAL
	jr z, @n
	cp FALLING_CRYSTAL
	jr z, @n
	ld a, ENEMY_DEAD
	call map_poke
@@:
	inc hl
	ld a, (hl)
	cp BRICK
	jr z, @n
	cp CRYSTAL
	jr z, @n
	cp FALLING_CRYSTAL
	jr z, @n
	

	ld a, ENEMY_DEAD
	call map_poke
@@:
	inc hl
	ld a, (hl)
	
	cp BRICK
	jr z, @n
	cp CRYSTAL
	jr z, @n
	cp FALLING_CRYSTAL
	jr z, @n
	
	ld a, ENEMY_DEAD
	call map_poke
@@:
	push de
	ld de, 30
	add hl, de
	pop de
	;; If I had DUP it should be used here :-)

	;; dup 3
	; 1
	ld a, (hl)
	
	cp BRICK
	jr z, @n
	cp CRYSTAL
	jr z, @n
	cp FALLING_CRYSTAL
	jr z, @n
	

	ld a, ENEMY_DEAD
	call map_poke
@@:	
	inc hl
	; 2
	ld a, (hl)
	
	cp BRICK
	jr z, @n
	cp CRYSTAL
	jr z, @n
	cp FALLING_CRYSTAL
	jr z, @n


	ld a, ENEMY_DEAD
	call map_poke
@@:	
	inc hl
	; 3
	ld a, (hl)
	
	cp BRICK
	jr z, @n
	cp CRYSTAL
	jr z, @n
	cp FALLING_CRYSTAL
	jr z, @n

	ld a, ENEMY_DEAD
	call map_poke
@@:	
	ret
	
enemies_move:
	ld hl, level_buffer
	ld bc, 736
em_loop:
	push bc
	push hl
	ld (tile_ptr), hl
	ld a, (hl)
	
	cp ENEMY_UP
	jr z, enemy_up

	cp ENEMY_LEFT
	jr z, enemy_left
em_loop_e:
	pop hl
	pop bc
	inc hl
	dec bc

	ld a,b
	or c
	jr nz, em_loop

	ld hl, end_level_buffer
	ld b, 32
em_r_loop:
	push bc
	push hl
	ld b, 23
em_c_loop:
	push hl
	push bc

	ld a, (hl)
	ld (tile_ptr), hl
	
	cp ENEMY_RIGHT
	jr z, enemy_right

	cp ENEMY_DOWN
	jr z, enemy_down
em_rd_loop_e:
	pop bc
	pop hl

	ld de, -32
	add hl, de
	djnz em_c_loop
	pop hl
	pop bc
	dec hl
	djnz em_r_loop
	
	ret
e_kill:
	pop bc
	pop bc
	jp die

e_kill_dr:
	pop bc
	pop bc
	pop bc
	pop bc
	jp die
enemy_up:
	or a
	ld de, 32
	sbc hl, de

	ld a, (hl)
	and a
	jr z, force_move

	call is_player
	jp z, e_kill

	;; Check for players
	ld d, ENEMY_LEFT
	call change_direction
	jp em_loop_e

enemy_left:
	dec hl
	ld a, (hl)
	and a
	jr z, force_move
	;; Check for players
	call is_player
	jp z, e_kill

	ld d, ENEMY_DOWN
	call change_direction
	jp em_loop_e

enemy_down:
	ld de, 32
	add hl, de
	ld a, (hl)
	and a
	jr z, force_move_dr
	;; Check for players
	call is_player
	jp z, e_kill_dr

	ld d, ENEMY_RIGHT
	call change_direction
	jp em_rd_loop_e

enemy_right:
	inc hl
	ld a, (hl)
	and a
	jr z, force_move_dr
	;; Check for players
	call is_player
	jp z, e_kill_dr
	ld d, ENEMY_UP
	call change_direction
	jp em_rd_loop_e

force_move:
	push hl
	push hl
	ld hl, (tile_ptr)
	ld a, (hl)
	pop hl
	call map_poke

	xor a
	ld hl, (tile_ptr)
	call map_poke

	pop hl
	jp em_loop_e

force_move_dr:
	push hl
	push hl
	ld hl, (tile_ptr)
	ld a, (hl)
	pop hl
	call map_poke

	xor a
	ld hl, (tile_ptr)
	call map_poke

	pop hl
	jp em_rd_loop_e

change_direction:
	ld hl, (tile_ptr)
	ld a, d
	call map_poke
	ret


