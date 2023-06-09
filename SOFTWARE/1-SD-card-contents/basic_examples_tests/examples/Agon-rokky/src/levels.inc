MAX_LEVEL:	equ 12

current_level:
	db 0

level_table:
	dl level1
	dl level2
	dl level3
	dl level4
	dl level5
	dl level6
	dl level7
	dl level8
	dl level9
	dl level10
	dl level11
	dl level12

check_next:
	ld a, (crystals_total)
	ld hl, crystals_got
	xor (hl)

	ret nz

	ld a, (current_level)
	inc a
	;; Check maximum level
	ld (current_level), a
	cp MAX_LEVEL
	jp z, final
	call win_snd
	call slide_off

load_level:
	ld hl, level_table
	ld a, (current_level)
	and a
	jr z, @start
	ld b, a
	add a, a
	add a, b
	ld bc, 0
	ld c, a
	add hl, bc
@start:
	ld hl, (hl)
	ld de, level_buffer
	ld bc, 736
	ldir
	call extract_info
	call draw_buffer
	call draw_ui
	ret
	


level1:
	incbin "levels/level1"

level2:
	incbin "levels/level2"

level3:
	incbin "levels/level3"

level4:
	incbin "levels/level4"

level5:
	incbin "levels/level5"

level6:
	incbin "levels/level6"

level7:
	incbin "levels/level7"

level8:
	incbin "levels/level8"

level9:
	incbin "levels/level9"

level10:
	incbin "levels/level10"

level11:
	incbin "levels/level11"

level12:
	incbin "levels/level12"

