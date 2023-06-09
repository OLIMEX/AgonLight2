    macro CALL_GATE addr
    ld (sp_save), sp
    ld sp, stack

    LIL
    call addr
    db $4

    ld sp, (sp_save)
    endm

GATE_ADDRESS:   equ $61
GATE_RESTORE:   equ GATE_ADDRESS 
GATE_CONST:     equ GATE_RESTORE + 4
GATE_CONIN:     equ GATE_CONST + 4
GATE_CONOUT:    equ GATE_CONIN + 4
GATE_HOME:      equ GATE_CONOUT + 4
GATE_SETTRK:    equ GATE_HOME + 4
GATE_SETSEC:    equ GATE_SETTRK + 4
GATE_SETDMA:    equ GATE_SETSEC + 4
GATE_READ:      equ GATE_SETDMA + 4
GATE_WRITE:     equ GATE_READ + 4
GATE_SELECT:    equ GATE_WRITE + 4

    module Gate

const:
    CALL_GATE GATE_CONST
    ret

conin:
    CALL_GATE GATE_CONIN
    ret

conout:
    CALL_GATE GATE_CONOUT
    ret
    
home:
    CALL_GATE GATE_HOME
    ret

settrk:
    CALL_GATE GATE_SETTRK
    ret

setsec:
    CALL_GATE GATE_SETSEC
    ret

setdma:
    CALL_GATE GATE_SETDMA
    ret

read:
    CALL_GATE GATE_READ
    xor a
    ret

write:
    CALL_GATE GATE_WRITE
    xor a
    ret

    endmodule