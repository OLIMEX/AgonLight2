template:
	incbin "page.bin"
show_template:
	ld hl, template
	ld de, level_buffer
	ld bc, 736
	ldir
	call draw_buffer
	ret

final:
	call slide_off
	call show_template

	ld hl, txt_finish
	call printZ

	MOSCALL mos_getkey
	pop hl
	jp exit
txt_finish:
	db 31, 28, 22
	db "That's all"
	db 31, 6, 26
	db "Thank you for playing Rokki!"
	db 31, 6, 28
	db "I wish you enjoyed it!"
	db 31, 6, 30
	db "Feel free dig into sources and make your own"
	db 31, 6, 32
	db "games based on it"

	db 31, 6, 36
	db "Sources: https://github.com/Agon-rokky"

	db 31, 11, 39
	db "(c) 2023 Aleksandr Sharikhin aka Nihirash"
	db 31, 11, 40
	db "Made for good of all good beings"

	db 0


show_intro:
	call show_template
	ld hl, txt_intro
	call printZ

	MOSCALL mos_getkey	
	cp 27
	jr z, @exit
	call win_snd
	call slide_off
	ret
@exit:
	pop hl
	jp vdp_close
	
txt_intro:
	db 31, 28, 22
	db "CONTROLS"

	db 31, 6, 26
	db "Use cursor keys on your keyboard to control hero"
	db 31, 6, 28
	db "If you stuck somewhere use key R to restart level"
	db 31, 6, 30
	db "If you want quit game use key ESC!"

	db 31, 12, 35
	db "Press any key for starting game!"

	db 31, 11, 39
	db "(c) 2023 Aleksandr Sharikhin aka Nihirash"
	db 31, 11, 40
	db "Made for good of all good beings"

	db 0
