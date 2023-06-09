\ Z80 assembler
\ Copyright 2022 L.C. Benschop, The Netherlands.
\ This program is released under the GNU General Public License v3

BASE @ HEX

: DEFER ( "ccc" --- )
\G Defining word to cretate a word that can be made to execute an arbitrary
\G Forth word.    
    CREATE 0 , DOES> @ EXECUTE ;
: IS  ( xt "ccc" --- )
\G Set the word to be executed by the deferred word.    
    ' >BODY ! ;

\G Vocabulary containing the ASSEMBLER words.
VOCABULARY ASSEMBLER ( --- )
ASSEMBLER ALSO DEFINITIONS

' C! DEFER VC! IS VC! \ Vectorize the important words so we can cross
' C@ DEFER VC@ IS VC@ \ assemble and self-assemble using the same code.
' !  DEFER V!  IS V!
' @  DEFER V@  IS V@
' C, DEFER C_ IS C_
' ,  DEFER ,  IS ,
' HERE DEFER HERE IS HERE
' ALLOT DEFER ALLOT IS ALLOT
: C, C_ ;

VARIABLE VDP
: VHERE ( --- addr)
  VDP @ ;
: VALLOT VDP +! ;
: VC, ( c --- )
  VHERE VC! 1 VALLOT ;
: V, ( n ---)
  VHERE V! 2 VALLOT ;
: ORG VDP ! ;

\ Use din IF/THEN/ELSE/BEGIN/UNTIL/WHILE/REPEAT/AGAIN commands.
: <MARK ( --- addr )
  HERE ;
: <RESOLVE ( addr ---)
  HERE 1+ - C, ;
: >MARK ( --- addr )
  HERE 0 C, ;
: >RESOLVE ( addr --- )
  HERE OVER 1+ - SWAP VC! ;

\ This is a prefix assembler, so the source code looks much like
\ traditional assembler source, for example INC HL or LD DE, $4444
\ It is inspired by the 8086 assembler that came with F-PC under MS-DOS.
\ In 1991-1994 I created such an assembler for the 6809.
\ In 2022 I ported the same concept to the Z80.
\ The Z80 is a very un-orthogonal instruction set. For example the
\ opcodes for the LD mnemonic are literally all over the place.
\ Therefore most instrucitons need a customized handler to compute the
\ opcode from the various operand fields. This is in the IHANDLER variable.

\ Each opcode word sets some of the following variable. Words that
\ represent registers or other operands update some of these words as well.

\ The A; instruction finally assembles the instruction using thes variables.
VARIABLE IXBYTE \  0 when not used DD or FF when instruction needs a DD/FF
                \ prefix. 1DD or 1FF when a dispalcement is also required.
VARIABLE DISPL  \ Displacement for IX instructions.
VARIABLE OPCODE  \ Opcode. FFFF when no instruction, 8-bit value for
                 \ single byte opcdoes, also $CBxx or $EDxx for 2 byte opcode
VARIABLE SRCREG   \ Source register or operand.
VARIABLE DSTREG   \ Destination register or operand/
VARIABLE IHANDLER \ Function to handle the instrruction.
VARIABLE ?OPERAND \ Type of operand on the stack 0 = none, 1 = 1 byte,
                  \ 2 = 2 byte, 3 = 1 byte program counter relative.
: NOINSTR \ Clear the instruction related variables.
    IXBYTE OFF ['] NOOP IHANDLER ! FFFF OPCODE ! ?OPERAND OFF
    SRCREG OFF DSTREG OFF
;
NOINSTR
\ : H. BASE @ HEX SWAP U. BASE ! ;
: A; \ Assemble current instruction and reset instruction variables
    IHANDLER @ EXECUTE
    IXBYTE @ IF IXBYTE @ C, THEN
    OPCODE @ FFFF = IF EXIT THEN
    \ ." Assembling instruction " IXBYTE @ H. OPCODE @ H. ?OPERAND @ H. SRCREG @ H. DSTREG @ H. CR
    OPCODE @ FF U> IF
	OPCODE @ 8 RSHIFT C, \ Assemble first byte CB or ED of opcode.
	IXBYTE @ FF U> IF
	    DISPL @ C,  \ For CB opcodes displacement between CB and main opcode
	    0 IXBYTE !
	THEN	
    THEN
    OPCODE @ C, \ Set main opcode
    IXBYTE @ FF U> IF
	DISPL @ C,
    THEN
    ?OPERAND @ IF
	CASE ?OPERAND @
	    1 OF C, ENDOF \ 8 bit operand
	    2 OF , ENDOF \ 16 bit operand
	    3 OF HERE 1+ - C, ENDOF \ relative address
	ENDCASE
    THEN
    NOINSTR
;

\ Most instruction categories have both a customized IHANDLER
\ (to select the correct opcode for the operands) and a defining word.
\ Some instructions have s simple colon definition instead of the defining word.
\ Some instructions do not use the UHGANDLER fuction.

\ Instructions with no operands.
: INS0
    CREATE , DOES> >R A; R> @ OPCODE ! ;
00 INS0 NOP
07 INS0 RLCA 0f INS0 RRCA
17 INS0 RLA  1F INS0 RRA
27 INS0 DAA  2F INS0 CPL
37 INS0 SCF  3F INS0 CCF
76 INS0 HALT D9 INS0 EXX
F3 INS0 DI   FB INS0 EI
ED44 INS0 NEG
ED45 INS0 RETN ED4D INS0 RETI
ED67 INS0 RRD  ED6F INS0 RLD
EDA0 INS0 LDI  EDA1 INS0 CPI
EDA2 INS0 INI  EDA3 INS0 OUTI
EDA8 INS0 LDD  EDA9 INS0 CPD
EDAA INS0 IND  EDAB INS0 OUTD
EDB0 INS0 LDIR EDB1 INS0 CPIR
EDB2 INS0 INIR EDB3 INS0 OTIR
EDB8 INS0 LDDR EDB9 INS0 CPDR
EDBA INS0 INDR EDBB INS0 OTDR

\ INC and DEC instructions
: INCDEC-HANDLER
    SRCREG @ 1FF > IF
	OPCODE @ 8 RSHIFT SRCREG @ FF AND 10 * + OPCODE ! \ 16 bit
    ELSE
	OPCODE @ FF AND SRCREG @ FF AND 8 * +  OPCODE ! \ 8 bit
    THEN
;
: INCDEC
    CREATE ,
  DOES> >R A; R> @ OPCODE ! ['] INCDEC-HANDLER IHANDLER ! ;
0304 INCDEC INC
0B05 INCDEC DEC

\ PUSH and POP instructions
: PUSHPOP-HANDLER
    SRCREG @ FF AND 10 * OPCODE +! 
;
: PUSHPOP
    CREATE ,
  DOES> >R A; R> @ OPCODE ! ['] PUSHPOP-HANDLER IHANDLER ! ;
C1 PUSHPOP POP C5 PUSHPOP PUSH

\ Rotate and shift instructions
: ROT-SHIFT-HANDLER
    SRCREG @ FF AND OPCODE +!
;
: ROT-SHIFT
    CREATE ,
    DOES> >R A; R> @ OPCODE ! ['] ROT-SHIFT-HANDLER IHANDLER ! ;
CB00 ROT-SHIFT RLC CB08 ROT-SHIFT RRC
CB10 ROT-SHIFT RL  CB18 ROT-SHIFT RR
CB20 ROT-SHIFT SLA CB28 ROT-SHIFT SRA
CB38 ROT-SHIFT SRL

\ Bit operations, SET. RES, BIT
: BITOP-HANDLER
      8 * \ bit number expected on stack
      SRCREG @ FF AND + OPCODE +! ;
: BITOP
    CREATE ,
    DOES> >R A; R> @ OPCODE ! ['] BITOP-HANDLER IHANDLER ! ;
CB40 BITOP BIT CB80 BITOP RES
CBC0 BITOP SET

\ Jump instructions JP, CALL, RET, JR
: JMP-HANDLER
    SRCREG @ 106 = IF
	0 ?OPERAND ! E9 OPCODE ! EXIT \ JP (HL)
    THEN
    ?OPERAND @ 0= IF SRCREG ELSE DSTREG THEN @
    DUP 101 = IF DROP 503 THEN
    \ Get proper value for C (not C register but Carry condition) 
    DUP 0= IF
	DROP OPCODE @ 8 RSHIFT OPCODE ! \ Non-conditional.
    ELSE
	FF AND 8 * OPCODE @ FF AND + OPCODE !
    THEN
;
\ Defining word takes  both opcode (for conditiona & nonconditonal)
\ and operand inputs
: JMPINST
    CREATE , ,
  DOES> >R A; R> DUP @ ?OPERAND ! CELL+ @ OPCODE ! ['] JMP-HANDLER IHANDLER ! ;
1820 3  JMPINST JR
C3C2 2  JMPINST JP
C9C0 0  JMPINST RET
CDC4 2  JMPINST CALL
\ Sepcial 
: DJNZ A; 10 OPCODE ! 3 ?OPERAND !  ;

\ RST instruction.
: RST-HANDLER
   C7 + OPCODE !
;
: RST A; ['] RST-HANDLER IHANDLER !  0 OPCODE ! ;

\ IM instruction
: IM-HANDLER
    DUP 0 >  IF 1+ THEN 8 *  ED46 + OPCODE ! ;
: IM A; ['] IM-HANDLER IHANDLER !  0 OPCODE ! ;

\ IN instruction
: IN-HANDLER
    SRCREG @ 300 = IF
	DSTREG @ FF AND 8 * ED40 + OPCODE !
    ELSE
	1 ?OPERAND ! DB OPCODE !
    THEN ;
: IN A; ['] IN-HANDLER IHANDLER !  0 OPCODE ! ;
\ OUT instruction
: OUT-HANDLER
    DSTREG @ 300 = IF
	SRCREG @ FF AND 8 * ED41 + OPCODE !
    ELSE
	1 ?OPERAND ! D3 OPCODE !
    THEN ;

: OUT A; ['] OUT-HANDLER IHANDLER !  0 OPCODE ! ;

\ EX has only 3 single-byte opcodes, but they are unrelated to one another.
: EX-HANDLER
    CASE DSTREG @
	0201 OF 0EB OPCODE ! ENDOF \ EX DE. HL
	0302 OF 0E3 OPCODE ! ENDOF \ EX (SP), HL
	0203 OF 008 OPCODE ! ENDOF \ EX AF, AF'
    ENDCASE
;
: EX
    A; ['] EX-HANDLER IHANDLER !  0 OPCODE ! ;

\ The LD instruction is by far the most complex to handle.
: LD-HANDLER
    CASE DSTREG @ 8 RSHIFT
	01 OF \ Destination is 8-bit register incuding (HL).
	    CASE SRCREG @ 8 RSHIFT
		00 OF \ immediate
		    06 DSTREG @ FF AND 8 * + OPCODE ! 1 ?OPERAND !
		ENDOF
		01 OF \ 8 bit register to register
		    40 DSTREG @ FF AND 8 * + SRCREG @ FF AND + OPCODE !
		ENDOF
		03 OF \ LD A, (BC) or LD A, (DE)
		    SRCREG @ FF AND 10 * 0A + OPCODE !
		ENDOF
		04 OF \ LD A, direct
		    2 ?OPERAND ! 3A OPCODE !
		ENDOF
		06 OF \ LD A, I or LD A, R
		    SRCREG @ FF AND 8 * ED57 + OPCODE !
		ENDOF
	    ENDCASE
	ENDOF
	02 OF \ Destination is 16-bit register pair.
	    CASE SRCREG @ 8 RSHIFT 
		00 OF \ Immeditate
		    2 ?OPERAND !
		    DSTREG @ FF AND 10 * 01 + OPCODE !
		ENDOF
		02 OF \ LD SP, HL
		    F9 OPCODE !
		ENDOF
		04 OF \ LD rp,(direct)
		    2 ?OPERAND !
		    DSTREG @ 202 = IF
			2A OPCODE ! \ HL
		    ELSE
			DSTREG @ FF AND 10 * ED4B + OPCODE !
		    THEN
		ENDOF
	    ENDCASE
	ENDOF
	03 OF \ Destination is (BC) or (DE)
	    \ source is only A, we don't check this
	    DSTREG @ FF AND 10 * 02 + OPCODE !
	ENDOF
	04 OF \ Destination is direct address
	    2 ?OPERAND !
	    SRCREG @ 0107 = IF
		32 OPCODE ! \ LD (direct), A
	    ELSE
		SRCREG @ 0202 = IF
		    22 OPCODE ! \ LD (direct), HL
		ELSE
		    SRCREG @ FF AND 10 * ED43 + OPCODE !
		THEN
	    THEN
	ENDOF
	06 OF \ Destination is I or R register
	    DSTREG @ FF AND 8 * ED47 + OPCODE !
	ENDOF
    ENDCASE 
;
: LD
    A; ['] LD-HANDLER IHANDLER ! 0 OPCODE ! ;

\ Arithmetic instructions
: ARITH-HANDLER
    DSTREG @ 1FF > IF
	OPCODE @ 8 RSHIFT SRCREG @ FF AND  10 * + OPCODE ! \ HL,rp 16 bit ops
	OPCODE @ 3F > IF ED00 OPCODE +! THEN \ ADC and SBC
    ELSE
	SRCREG @ 0= IF
	 OPCODE @ FF AND 46  + OPCODE ! 1 ?OPERAND ! \ A, Immediate
	ELSE    
	    OPCODE @ FF AND SRCREG @ FF AND + OPCODE ! \ 8 bit A,Reg
	THEN
    THEN
;
: ARITH
    CREATE ,
  DOES> >R A; R> @ OPCODE ! ['] ARITH-HANDLER IHANDLER ! ;
\ This instruction category comes last to prevent AND OR and XOR from
\ being shadowed by the assembler words.
0980 ARITH ADD 4A88 ARITH ADC
  90 ARITH SUB 4298 ARITH SBC
  A0 ARITH AND   A8 ARITH XOR
  B0 ARITH OR    B8 ARITH CP  


\ This definition of LABEL is only useful when cross-assemling/metacompiling.
\ In its current form supports no forward references.
\ When cross-assembling it contains a definition in the host dictionary only,
\ not in the target dictionary.
: LABEL A; HERE CONSTANT ;


\ The following small words define source/destination registers and
\ other operation modes (), and () for direct addressing.
\ Condition codes for jp/jr/call/ret are also included here.
\ These come at the end, primarily to prevent C, from being shadowed
\ by the assembler word.
: SRC-REG
    CREATE ,
  DOES> @ SRCREG ! ;
: DST-REG
    CREATE ,
  DOES> @ DSTREG ! ;

\ 0x01xx 8-bit regs + (HL)
0100 DST-REG B, 0100 SRC-REG B
0101 SRC-REG C
\ This is a dirty trick. When C, is called after an instruction it will
\ act like a DSTREG type word (sets destination register to C).
\ Outside an instruction it acts as the regular C, word (allot and store 1 byte)
: C, OPCODE @ FFFF  = IF C, ELSE 0101 DSTREG ! THEN ;
0102 DST-REG D, 0102 SRC-REG D
0103 DST-REG E, 0103 SRC-REG E
0104 DST-REG H, 0104 SRC-REG H
0105 DST-REG L, 0105 SRC-REG L
0106 DST-REG (HL), 0106 SRC-REG (HL)
0107 DST-REG A, 0107 SRC-REG A
\ $02xx 16 bit registers (pairs)
0200 DST-REG BC, 0200 SRC-REG BC
0201 DST-REG DE, 0201 SRC-REG DE
0202 DST-REG HL, 0202 SRC-REG HL
0203 DST-REG SP, 0203 SRC-REG SP
0203 DST-REG AF, 0203 SRC-REG AF
0203 SRC-REG AF' \ Only used in EX AF, AF'
\ $03xx indirect via 16-bit register pair.
0300 DST-REG (BC), 0300 SRC-REG (BC)
0301 DST-REG (DE), 0301 SRC-REG (DE)
0300 DST-REG (C), 300 SRC-REG (C) \ For IN and OUT
0302 DST-REG (SP), \ Only used in EX (SP), HL
0500 DST-REG NZ, 0500 SRC-REG NZ
\ $05xx jump conditon codes.
0501 DST-REG Z,  0501 SRC-REG Z
0502 DST-REG NC, 0502 SRC-REG NC
\ JP, CALL, JR and RET convert 0101 value for C, C to 0503
0504 DST-REG PO, 0504 SRC-REG PO
0505 DST-REG PE, 0505 SRC-REG PE
0506 DST-REG P,  0506 SRC-REG P
0507 DST-REG M,  0507 SRC-REG M
\ $06xx I and R registers.
0600 DST-REG I,  0600 SRC-REG I
0601 DST-REG R,  0601 SRC-REG R
\ $04xx direct addressing 
: (), 0400 DSTREG ! 2 ?OPERAND ! ; \ Direct addressing LD addr (), HL
: ()  0400 SRCREG ! 2 ?OPERAND ! ; \ Direct addressing LD A, addr ()
\ Soem words to handle IX/IY registers.
: (IX+), 1DD IXBYTE ! DISPL ! (HL), ;
: (IY+), 1FD IXBYTE ! DISPL ! (HL), ;
: (IX+)  1DD IXBYTE ! DISPL ! (HL) ;
: (IY+)  1FD IXBYTE ! DISPL ! (HL) ;
: (IX) DD IXBYTE ! (HL) ; \ Only used with JP (IX)
: (IY) FD IXBYTE ! (HL) ; \ Only used with JP (IY)
: IX DD IXBYTE ! HL ;   
: IY FD IXBYTE ! HL ;
: IX, DD IXBYTE ! HL, ;   
: IY, FD IXBYTE ! HL, ;

\ Structured assembler constructs.
\ These use JR instruction. The only available condition codes here are:
\ 0= 0<> (for Z flag) and U< U>= (for carry flag)
\ and B--0= for decrement B and test for zero (DJNZ instruction).
: IF >R A; R> C_ >MARK ;
: THEN A; >RESOLVE ;
: ELSE A; 18 C_ >MARK SWAP >RESOLVE ;
: BEGIN A; <MARK ;
: UNTIL >R A; R> C_ <RESOLVE ;
: WHILE >R A; R> C_ >MARK ;
: REPEAT A; 18 C_ SWAP <RESOLVE >RESOLVE ;
: AGAIN 18 UNTIL ;
10 CONSTANT B--0= 
30 CONSTANT U<  38 CONSTANT U>=
20 CONSTANT 0=  28 CONSTANT 0<>

\ Register assinment was taken from CamelForth:
\ BC is top of stack
\ DE is Instruction pointer (IP)
\ HL is free register (shadow registers and AF also free).
\ IX is return stack pointer, grows down.
\ SP is data stack pointer, grows down.

\ IY (used for user pointer in CamelForth, not used in this implementation).

\ Forth is direct threading, the runtimes for non-code words always
\ contain a CALL instruction.

\ Next will be expanded in-line after every code word.
\ Some words have IP in HL, they use NEXTHL
: NEXTHL
    LD E, (HL) \ Load address of next word from IP
    INC HL
    LD D, (HL)
    INC HL
    EX DE, HL \ Put IP back in DE, address of next word in HL
    JP (HL)   \ Jump to it.
;

\ Normal NEXT where IP is in DE
: NEXT
    EX DE, HL \ Temporarily put IP in HL
    NEXTHL
;

: .LIL 005B C_ ;

: ENDASM \ End assembly.
  A; PREVIOUS ;
FORTH DEFINITIONS
: ASSEMBLE ( ---)
\G Start assembling.
  ALSO ASSEMBLER NOINSTR ;

: CODE ( "ccc" --- )
\G Defining word to create a code definition.
    CREATE -3 ALLOT \ Remove the CALL made by CREATE.
    ASSEMBLE ;
: END-CODE ( --- )
\G Terminate a code definition
  [ ASSEMBLER ] ENDASM [ FORTH ] ;


PREVIOUS FORTH DEFINITIONS

BASE ! \ Restore the original base.
