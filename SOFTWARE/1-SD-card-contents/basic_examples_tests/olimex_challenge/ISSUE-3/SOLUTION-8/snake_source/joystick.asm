; Title:    SNES Joystick button reader
; Author:   Jeroen Venema
; Created:  01/11/2022
;
; Prints out a string of 16 characters, each character representing a button of a SNES controller
; Connections to the SNES controller through level-shifters:
; CLOCK - PC0
; DATA  - PC1
; LATCH - PC2
;

    XDEF _initjoystickpins
    XDEF _joyread
    XDEF _wait1ms
    
	segment CODE
	.assume ADL=1

_initjoystickpins:
	push ix
    ld a,11111000b  ; latch/bit2 and clk/bit0 as output, data temp output, needs to stay high
    out0 (159),a    ; PC_DDR configures input/output
    ld a,0          ; default to ALT1/ALT2
    out0 (160),a
    out0 (161),a

    ld a,00000011b  ; latch/bit2 normally low, data/bit1 and clock/bit0 normally high
    out0 (158),a    ; write to port C

    ld a,11111010b  ; latch/bit2 and clk/bit0 as output, data as input now
    out0 (159),a    ; reconfigure mode - data as input

    ld a,00000011b
    out0 (158),a
	pop ix
    ret

; returns 16bit SNES code in HL
; bit layout:
; bit  0 - B
; bit  1 - Y
; bit  2 - Select
; bit  3 - Start
; bit  4 - Up
; bit  5 - Down
; bit  6 - Left
; bit  7 - Right
; bit  8 - A
; bit  9 - X
; bit 10 - L
; bit 11 - R
; bit 12 - none - always high
; bit 13 - none - always high
; bit 14 - none - always high
; bit 15 - none - always high
;
; Non-pressed buttons return 1
; Pressed buttons return a 0
;
_joyread:
	push ix
    ld a,00000101b
    out0 (158),a    ; latch high, clock stays high
    call wait12us

    ld a,00000001b
    out0 (158),a    ; latch low, clock stays high
    call wait6us

    ld b,16         ; read 16 bit
    ld hl,0         ; zero out result register HL

joyloop:
    push bc
    srl h           ; shift HL right one bit, first run shifts only zeroes
    rr l
    ld a,00000000b  ; clock & latch low
    out0 (158),a
    call wait6us
    in0 a,(158)     ; read all bits from port C
    and a, 00000010b   ; mask out DATA bit
    jr z, checkdone ; 0 received, do nothing
    ld a,h
    or 10000000b    ; 1 received, set highest bit
    ld h,a
checkdone:
    ld a,00000001b  ; clock high & latch low
    out0 (158),a
    call wait6us
    pop bc
    djnz joyloop
	pop ix
    ret

; wait 6us at 18,432Mhz
wait6us:
    ld b,25
wait6usloop:
    djnz wait6usloop
    ret

; wait 12us at 18,432Mhz
wait12us:
    ld b,50
wait12usloop:
    djnz wait12usloop
    ret

; wait 1ms at 18,432Mhz
_wait1ms:
	push ix
    ld de, 2500
wait1msloop:
    dec de
    ld a,d
    or e
    jr nz,wait1msloop
    pop ix
	ret
end