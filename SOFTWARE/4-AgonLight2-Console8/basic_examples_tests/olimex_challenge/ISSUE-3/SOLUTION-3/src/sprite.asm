	.include "mos_api.inc"
	
	XDEF _vdp_spriteWaitRefresh
	
	segment CODE
	.assume ADL=1

_vdp_spriteWaitRefresh:
	push	ix
	ld		a, mos_sysvars
	rst.lil 08h

	ld		hl, refreshdata     ; preload before critical vblank wait
	ld		bc, 3               ; preload

	ld.lil	a, (ix + sysvar_time + 0)
$$:	cp.lil	a, (ix + sysvar_time + 0)
	jr		z, $B

	ld		a, 0
	rst.lil	18h			        ; send refresh command

	pop		ix
	ret

    SEGMENT DATA
refreshdata: db 23,27,15,0

