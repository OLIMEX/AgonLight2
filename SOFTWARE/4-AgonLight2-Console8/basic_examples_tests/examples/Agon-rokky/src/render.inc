
level_buffer:
	incbin "levels/level9"
end_level_buffer:


tile_table:
	db 00, BMP_NOTHING
	db 01, BMP_WALK_R0
	db 02, BMP_WALK_R0
	db 03, BMP_WALK_L0
	db 04, BMP_WALK_L0

	db 05, BMP_WALL
	db 06, BMP_BOULDER
	db 07, BMP_BOULDER
	db 08, BMP_FIELD
	db 09, BMP_CRYSTAL
	db 10, BMP_CRYSTAL
	db 11, BMP_GRAVE

	db 12, BMP_ENEMY0
	db 13, BMP_ENEMY0
	db 14, BMP_ENEMY0
	db 15, BMP_ENEMY0
	db 16, BMP_CRASH0
	db 17, BMP_CRASH1


tile_table2:
	db 00, BMP_NOTHING
	db 01, BMP_WALK_R1
	db 02, BMP_WALK_R1
	db 03, BMP_WALK_L1
	db 04, BMP_WALK_L1

	db 05, BMP_WALL
	db 06, BMP_BOULDER
	db 07, BMP_BOULDER
	db 08, BMP_FIELD
	db 09, BMP_CRYSTAL
	db 10, BMP_CRYSTAL
	db 11, BMP_GRAVE

	db 12, BMP_ENEMY1
	db 13, BMP_ENEMY1
	db 14, BMP_ENEMY1
	db 15, BMP_ENEMY1
	db 16, BMP_CRASH0
	db 17, BMP_CRASH1
	
; A - tile
find_replacement:
	ld b, 18
	push hl
	ld hl, (active_table)
@loop:
	cp (hl)
	jr z, @found
	inc hl
	inc hl

	djnz @loop
	ld a, BMP_NOTHING
	pop hl
	ret
@found:
	inc hl
	ld a, (hl)
	pop hl
	ret

active_table: dl tile_table
sprite_state: db 0

swap_tiles:
	ld a, (sprite_state)
	ld hl, tile_table
	xor $ff
	jr z, @do
	ld hl, tile_table2
@do:
	ld (active_table), hl
	ld (sprite_state), a
	ret

;; Draws buffer to screen
draw_buffer:
	ld a, 12
	call putc	

	ld hl, level_buffer	
	ld bc, 736
@loop:
	push bc
	push hl

	ld a, (hl)
	call map_poke
	pop hl
	inc hl
	pop bc
	dec bc
	ld a, b
	or c
	jr nz, @loop

	ret

bang_anim:
	ld hl, level_buffer
	ld bc, 736
@loop:
	ld a, (hl)
	cp ENEMY_DEAD
	jr z, @next
	cp ENEMY_DEAD+1
	jr z, @zero
@exit:
	inc hl
	dec bc
	ld a, c
	or b
	jr nz, @loop
	ret
@next:
	inc a
	call map_poke
	jr @exit
@zero:
	xor a
	call map_poke
	jr @exit

draw_ui:
	ld a, (crystals_got)
	ld de, str_c_got
	call p_num

	ld a, (crystals_total)
	ld de, str_c_total
	call p_num

	ld a, (current_level)
	inc a
	ld de, str_lvl
	call p_num

	ld hl, top_line
	ld bc, top_end-top_line
	rst.lil $18
	ret


p_num:
	ld hl, @table
	ld b, 3
@db1:
	ld c, '0'-1
@db2:
	inc c
	sub (hl)
	jr nc, @db2
	add a, (hl)
	push af
	ld a, c
	ld (de), a
	inc de
	pop af
	inc hl
	djnz @db1
	ret
@table:
	db 100, 10, 1

top_line:
	db 31, 18, 0
	db "Crystals: "
str_c_got:
	db "000/"
str_c_total:
	db "000  Level: "
str_lvl:
	db "000"
top_end:
