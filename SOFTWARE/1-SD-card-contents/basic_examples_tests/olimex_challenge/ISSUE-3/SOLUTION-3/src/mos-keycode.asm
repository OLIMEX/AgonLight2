	.include "mos_api.inc"
			
	SEGMENT CODE
	.ASSUME	ADL = 1
			
	XDEF	_getfullkeycode
	
_getfullkeycode:
	push ix
	ld a, mos_sysvars
	rst.lil 08h

	ld a, (ix+sysvar_keyascii)
	ld h, (ix+sysvar_vkeydown)
	ld l,a
	xor a
	ld (ix+sysvar_keyascii),a
	
	pop ix
	ret				; return hl as h:vkeydown(1/0), l:keycode
end