    module Boot
boot:
    ld sp, stack
    ld hl, message
    ld bc, 0
    xor a

    LIS
    rst $18

    xor a
    ld (TDRIVE), a
    call SELDSK

    jp gocpm
wboot:
    ld sp, stack
    CALL_GATE GATE_RESTORE
    call HOME
gocpm:
    ld a, $c3 ; JP instruction
    ld (0), a
    ld hl, WBOOT
    ld (1), hl

    ld (5), a
    ld hl, FBASE
    ld (6), hl

    ld (38), a
    ld hl, int_handler
    ld (39), hl

    ld a, 1 : ld (IOBYTE),a
    
    ld bc, $80
    call SETDMA

    ld a, (TDRIVE)
    push af
    call SELDSK
    pop af
    ld c, a
    
    jp CBASE

int_handler:
    reti

message:
    db "CP/M version 2.2", 13, 10
    db "1979 (c) Digital Research", 13, 10
    db "With patches", 13,10
    db "2023 (c) Aleksandr Sharikhin", 13, 10, 13, 10
    db "Agon Quark BIOS", 13, 10
    db "2023 (c) Aleksandr Sharikhin", 13, 10
    db "BIOS built: ", __DATE__, ' ' , __TIME__
    db 13, 10, 13, 10
    db 0
    
    endmodule