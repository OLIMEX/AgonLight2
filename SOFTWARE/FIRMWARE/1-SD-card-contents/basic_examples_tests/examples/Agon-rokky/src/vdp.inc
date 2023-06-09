;; All sprites 16x16. Prepares VDP routines and includes binary

	macro DEFSPRITE arg, file
	db 23, 27, 0
	db arg
	db 23, 27, 1
	dw 16, 16
	incbin file
	endmacro

BMP_NOTHING:	equ $00

BMP_WALK_R0:	equ $01
BMP_WALK_R1:	equ $02
BMP_WALK_L0:	equ $03
BMP_WALK_L1:	equ $04
BMP_GRAVE:	equ $05
BMP_BOULDER:	equ $06
BMP_WALL:	equ $07
BMP_FIELD:	equ $08
BMP_CRYSTAL:	equ $09

BMP_ENEMY0:	equ $0a
BMP_ENEMY1:	equ $0b

BMP_CRASH0:	equ $0c
BMP_CRASH1:	equ $0d

keycode_ptr:	dl	0
frame_ptr:	dl	0
vk_code:	dl	0
key_up:		dl	0

keycode:	db	0
vk:		db	0

c_up:	db	0
c_dn:	db	0
c_lf:	db	0
c_rt:	db	0

VK_U: equ 150
VK_D: equ 152
VK_L: equ 154
VK_R: equ 156

vk_down:
	ld hl, (vk_code)
	ld a, (hl)

	ld hl, c_up
	cp VK_U
	jr z, @write

	inc hl
	cp VK_D
	jr z, @write
	
	inc hl
	cp VK_L
	jr z, @write

	inc hl
	cp VK_R
	jr z, @write
	ret
@write:
	ld a, 1
	ld (hl), a
	ret

vk_up:
	ld hl, (vk_code)
	ld a, (hl)

	ld hl, c_up
	cp VK_U
	jr z, @write

	inc hl
	cp VK_D
	jr z, @write
	
	inc hl
	cp VK_L
	jr z, @write

	inc hl
	cp VK_R
	jr z, @write
	ret
@write:
	xor a
	ld (hl), a
	ret


get_key:
	xor a
	ld (keycode), a

	ld hl, (key_up)
	ld a, (hl)
	and a
	jr z, vk_up	

	call vk_down

	ld hl, (keycode_ptr)
	ld a, (hl)
	ld (keycode), a
	ret

vsync:
	ld hl, (frame_ptr)
	ld a, (hl)
@wait:	push af
	push hl
	call get_key
	pop hl
	pop af
	cp (hl)
	jr z, @wait
	ret

;; Inits screen
vdp_init:
	MOSCALL mos_sysvars
	lea hl, ix+5
	ld (keycode_ptr), hl
	lea hl, ix+$17
	ld  (vk_code), hl
	lea hl, ix+$18
	ld (key_up), hl

	ld (frame_ptr), ix

	ld hl, @cmd
	ld bc, vdp_cls-@cmd
	rst.lil $18
	ret
@cmd:
	db 22, 1 ;; Mode 1
	db 23, 1, 0 ;; Hide cursor
	db "Very important logs(we aren't joking here):", 13, 10
	db "Video mode established", 13, 10
	db "Setting keyboard mode", 13,10
	db 23, 0, $88
	dw 250, 33
	db 255	
	db "Sending bitmaps to VDP", 13, 10

	DEFSPRITE BMP_NOTHING, "imgs/nothing.rgba"
	DEFSPRITE BMP_WALK_R0, "imgs/walk_r0.rgba"
	DEFSPRITE BMP_WALK_R1, "imgs/walk_r1.rgba"
	DEFSPRITE BMP_WALK_L0, "imgs/walk_l0.rgba"
	DEFSPRITE BMP_WALK_L1, "imgs/walk_l1.rgba"
	DEFSPRITE BMP_GRAVE, "imgs/grave.rgba"
	DEFSPRITE BMP_BOULDER, "imgs/rock.rgba"
	DEFSPRITE BMP_WALL, "imgs/wall.rgba"
	DEFSPRITE BMP_FIELD, "imgs/ground.rgba"
	DEFSPRITE BMP_CRYSTAL, "imgs/gem.rgba"
	DEFSPRITE BMP_ENEMY0, "imgs/ghost0.rgba"
	DEFSPRITE BMP_ENEMY1, "imgs/ghost1.rgba"
	DEFSPRITE BMP_CRASH0, "imgs/bang0.rgba"
	DEFSPRITE BMP_CRASH1, "imgs/bang1.rgba"
	db 12
@end:	

;; Clear screen
vdp_cls:
	ld a, 12
	jp putc

; A - number
bmp_select:
	ld (@bmp), a
	ld hl, @cmd
	ld bc, @end-@cmd
	rst.lil $18
	ret
@cmd:
	db 23, 27, 0
@bmp:
	db 0
@end:


; de - coords
bmp_draw:
	ld b, 16
	ld c, e
	mlt bc

	ld a, c
	ld (@c_x), a

	ld a, b
	ld (@c_x+1), a

	ld b, 16
	ld c, d
	mlt bc
	ld hl, 8
	add hl, bc
	
	ld a, l
	ld (@c_y), a

	ld a, h
	ld (@c_y+1), a


	ld hl, @cmd
	ld bc, @end-@cmd
	rst.lil $18
	ret
@cmd:
	db 23, 27, 3
@c_x:
	dw 0
@c_y:	dw 0
@end:



cursor_on:
	ld hl, @cmd
	ld bc, @end-@cmd
	rst.lil $18
	ret
@cmd:
	db 23, 1, 1
@end:

cursor_off:	
	ld hl, @cmd
	ld bc, @end-@cmd
	rst.lil $18
	ret
@cmd:
	db 23, 1, 0
@end:

;; DE - xy
goto_xy:
	push de
	ld a, 31
	call putc
	pop de
	push de
	ld a, e
	call putc
	pop de
	ld a, d
	call putc
	ret

; A - color
set_fg:
	and 63
set_color:	
	push af
	ld a, 17
	call putc
	pop af
	call putc
	ret

; A - color
set_bg:
	or $80
	jr set_color

vdp_close:
	ld hl, @cmd
	ld bc, @end-@cmd
	rst.lil $18
	ret
@cmd:
	db 22, 1
	db 17, 7, 17, $80
	db 23, 1, 1
	db 12
@end:

