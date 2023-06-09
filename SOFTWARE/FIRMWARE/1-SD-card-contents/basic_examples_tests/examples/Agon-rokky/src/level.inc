PLAYER_RIGHT:		equ	1
PLAYER_LEFT:		equ	3
BOULDER:		equ 	6
FALLING_BOULDER:	equ	7
BRICK:			equ	5
FIELD:			equ	8	
CRYSTAL:		equ	9
FALLING_CRYSTAL:	equ	10
PLAYER_DEAD:		equ	11
ENEMY_LEFT:		equ	12
ENEMY_RIGHT:		equ	13
ENEMY_UP:		equ	14
ENEMY_DOWN:		equ	15
ENEMY_DEAD:		equ	16

crystals_total:	db 0
crystals_got: db 0

; HL - addr
; Basicly removing level_buffer offset and division by 32 with reminder
addr_to_coords:
	push hl
	push af
	ld de, level_buffer

	or a
	sbc hl, de

	;; Now HL is offset from level_buffer
	;; We have 32 columns(can be found just by and 31)

	ld a, l
	and 31
	ld e, a

	;; And next code just implements quick division by 32

	xor a
	add hl, hl
	rla
	add hl, hl
	rla
	add hl, hl
	rla
	ld d, h
	pop af
	pop hl
	ret


map_poke_de:
	push hl
	push de
	ex de, hl
	call map_poke
	pop de 
	pop hl
	ret

; A - tile
; HL - addr
; Writes in level buffer and draws new tile on screen
map_poke:
	;; Trying make it maximum invisible for other code
	push af
	push bc
	push de
	push hl

	ld (hl), a
	push hl
	call find_replacement
	call bmp_select
	pop hl
	call addr_to_coords
	call bmp_draw	

	pop hl
	pop de
	pop bc
	pop af
	ret

extract_info:
	xor a
	ld (crystals_total), a
	ld (crystals_got), a
	ld hl, end_level_buffer
	ld bc, 736
@loop:
	ld a, (hl)
	and a
	jr z, @skip

	cp 05
	call c, @start

	cp CRYSTAL
	call z, @crystal
@skip:
	dec hl
	dec bc
	ld a, b
	or c
	jr nz, @loop
	ret
@start:
	ld (p_pos), hl
	ret
@crystal:
	push hl
	ld hl, crystals_total
	inc (hl)
	pop hl
	ret
