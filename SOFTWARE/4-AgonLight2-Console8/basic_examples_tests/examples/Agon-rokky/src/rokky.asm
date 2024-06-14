MAX_ARGS:	equ 1
	include "crt.inc"
	include "vdp.inc"
	include "render.inc"
	include "level.inc"
	include "enemy.inc"
	include "player.inc"
	include "gravity.inc"
	include "levels.inc"
	include "fx.inc"
	include "pages.inc"
_main:
	call vdp_init
	call show_intro
	call load_level
@loop:
	call level_life
	call player_process
	call check_next

	
	ld a, (keycode)
	cp 27
	jr z, exit

	cp 'R'
	call z, die
	cp 'r'
	call z, die

	jr @loop
exit:	
	call die_snd	
	call slide_off
	call vdp_close
	ld hl, bye
	jp printZ
bye:
	db "Thank you for playing Rokky!",13,10
	db "(c) 2023 Aleksandr Sharikhin", 13, 10, 13, 10
	db "You can support my projects: ", 13, 10
	db "https://ko-fi.com/nihirash",13, 10, 0


level_life:
	call delay
	call swap_tiles
	call enemies_move
	call process_gravity
	call bang_anim
	call draw_ui	
	ret

delay:
	ld b, 7
@@:	call vsync
	djnz @p
	ret
