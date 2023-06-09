    DISPLAY "BIOS: ", $
    ALIGN 256
BOOT:	JP	Boot.boot		; Should be here
WBOOT:	JP	Boot.wboot
CONST:	JP	Gate.const     ; Should call compatibility layer
CONIN:	JP	Gate.conin
CONOUT:	JP	Gate.conout
LIST:	JP	nothing     ; Can be unimplemented
PUNCH:	JP	nothing
READER:	JP	rdr
HOME:	JP	Gate.home     ; Compatility layer
SELDSK:	JP	seldisk
SETTRK:	JP	Gate.settrk
SETSEC:	JP	Gate.setsec
SETDMA:	JP	Gate.setdma
READ:	JP	Gate.read
WRITE:	JP	Gate.write
PRSTAT:	JP	nothing     
SECTRN:	JP	sectran ;   here

dbp:
    dw  $0000, $0000
    dw  $0000, $0000
    dw	dirbf, dpblk
    dw	$0000, all00
dbp_size = $ - dbp
    dw  $0000, $0000
    dw  $0000, $0000
    dw	dirbf, dpblk
    dw	$0000, all01

    dw  $0000, $0000
    dw  $0000, $0000
    dw	dirbf, dpblk
    dw	$0000, all02

    dw  $0000, $0000
    dw  $0000, $0000
    dw	dirbf, dpblk
    dw	$0000, all03

    dw  $0000, $0000
    dw  $0000, $0000
    dw	dirbf, dpblk
    dw	$0000, all04

    dw  $0000, $0000
    dw  $0000, $0000
    dw	dirbf, dpblk
    dw	$0000, all05

    dw  $0000, $0000
    dw  $0000, $0000
    dw	dirbf, dpblk
    dw	$0000, all06

    dw  $0000, $0000
    dw  $0000, $0000
    dw	dirbf, dpblk
    dw	$0000, all07

    dw  $0000, $0000
    dw  $0000, $0000
    dw	dirbf, dpblk
    dw	$0000, all08

    dw  $0000, $0000
    dw  $0000, $0000
    dw	dirbf, dpblk
    dw	$0000, all09

    dw  $0000, $0000
    dw  $0000, $0000
    dw	dirbf, dpblk
    dw	$0000, all10

    dw  $0000, $0000
    dw  $0000, $0000
    dw	dirbf, dpblk
    dw	$0000, all10

    dw  $0000, $0000
    dw  $0000, $0000
    dw	dirbf, dpblk
    dw	$0000, all11

    dw  $0000, $0000
    dw  $0000, $0000
    dw	dirbf, dpblk
    dw	$0000, all12

    dw  $0000, $0000
    dw  $0000, $0000
    dw	dirbf, dpblk
    dw	$0000, all13

    dw  $0000, $0000
    dw  $0000, $0000
    dw	dirbf, dpblk
    dw	$0000, all14

    dw  $0000, $0000
    dw  $0000, $0000
    dw	dirbf, dpblk
    dw	$0000, all15

dpblk:	;disk parameter block for all disks.
    dw	64	;sectors per track
    db	6		;block shift factor
    db	63		;block mask
    db	3   	;null mask
    dw	1023	;disk size-1
    dw	2047 	;directory max
    db	$ff		;alloc 0
    db	0		;alloc 1
    dw	0	    ;check size - don't care about it - SD card isn't removable
    dw	0	    ;track offset

rdr:
    ld a, 26
    ret

sectran:
    ld hl, bc
    ret

nothing:
    ld a, #ff
    ret

seldisk:
    cp 16
    jr nc, .ouch

    ld (.drive_num), a ;; It's more safe than joungling with stack(ONLY HERE!)

    di
    ld (sp_save), sp
    ld sp, stack
    
    LIL
    call  GATE_SELECT
    db $4

    ld sp, (sp_save)
    ei

    or a        ;; Was file opened?
    jr z, .ouch

    ld a, 1
.drive_num = $ - 1

    ld hl, dbp
    ld e, 0
    and a
    ret z

    ld bc, dbp_size
.loop
    add hl, bc
    dec a
    jr nz, .loop
    ld e, a
    ret
.ouch
    xor a
    ld (TDRIVE), a
    ld hl, 0
    scf
    ret

    include "gate.asm"
    include "boot.asm"

sp_save: dw 0


all00:  ds 128
all01:  ds 128 
all02:  ds 128 
all03:  ds 128 
all04:  ds 128 
all05:  ds 128 
all06:  ds 128 
all07:  ds 128 
all08:  ds 128
all09:  ds 128 
all10:  ds 128 
all11:  ds 128 
all12:  ds 128
all13:  ds 128 
all14:  ds 128 
all15:  ds 128
dirbf:  ds 128

stack = $ffff
    DISPLAY "BIOS END: ", $