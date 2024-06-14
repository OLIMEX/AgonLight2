\ This is the file kernl80a.4th, included by the cross compiler.
\ created 1994 by L.C. Benschop.
\ copyleft (c) 1994-2014 by the sbc09 team, see AUTHORS for more details.
\ Most Z80 primitives: ; Copyright (c) 1994,1995 Bradford J. Rodriguez
\ copyleft (c) 2022 L.C. Benschop for Cerberus 2080.
\ license: GNU General Public License version 3, see LICENSE for more details.
\ It is extensively commented as it must serve as an introduction to the
\ construction of Forth compilers.

\ Lines starting with \G are comments that are included in the glossary.

ALSO TRANSIENT DEFINITIONS
FORWARD THROW
FORWARD COLD
FORWARD WARM
FORWARD F-STARTUP
PREVIOUS DEFINITIONS

ALSO ASSEMBLER DEFINITIONS

PREVIOUS DEFINITIONS

ASSEMBLE HEX

\ PART 0: Boot vectors.
ORIGIN ORG
 JP $4F A;
 5 ALLOT-T
 RST .LIL 8 RET A; \ RST 8 handler
 5 ALLOT-T
 RST .LIL 010 RET A; \ RST 16 handler
 2D ALLOT-T
 4D C, 4F C, 53 C, 0 C, 0 C, \ Agon MOS header at 64
 46 C, 4F C, 52 C, 54 C, 48 C, 2E C, 42 C, 49 C, 4E C, 0 C, \ FORTH.BIN
\ Here we jump to at start (is at $4F).
 PUSH .LIL IY
 PUSH .LIL IX
 PUSH .LIL BC
 PUSH .LIL DE
 LD IX, 0
 ADD IX, SP
 PUSH .LIL IX 
 EX (SP), HL
 PUSH .LIL HL
 EX (SP), HL
 A; C3 C,  TRANSIENT COLD ASSEMBLER \ Jump to COLD entry point.
ENDASM

DECIMAL
CROSS-COMPILE

\ PART 1: Runtime parts of defining words

\ Note: the NEXT and NEXTHL macros are defined in assmz80.4th.
\ NEXT is expanded in-line.

\ Run-time part for constants:
\ Gets Parameter field addres on data stack from CALL instruction.
LABEL DOCON
  POP HL          \ Get param address
  PUSH BC         \ Store old TOS
  LD C, (HL)
  INC HL
  LD B, (HL)      \ Loads new TOS from paramter field
  NEXT
ENDASM

\ Run-time part for variables
LABEL DOVAR
  POP HL          \ Get param address
  PUSH BC         \ Store old TOS
  LD C, L        
  LD B, H         \ Param address to TOS
  NEXT
ENDASM

\ Run-time part for colon definitions
\ Paramter addres will be new IP
LABEL DOCOL
  DEC IX
  LD 0 (IX+), D 
  DEC IX
  LD 0 (IX+), E   \ Push IP to return stack
  POP HL          \ Get paramter field addres, new IP  
  NEXTHL         
ENDASM

\ Run-time part of CREATE DOES> defining words.
\ Each defined word contains a CALL to the part after DOES>, which
\ starts with a CALL to DODOES.
LABEL DODOES
  DEC IX
  LD 0 (IX+), D 
  DEC IX
  LD 0 (IX+), E  \ Push IP on return stack
  POP HL         \ New instruction ptr, thread after DOES>.
  POP DE         \ PFA of defined word, result of CALL to CALL DODOES        
  PUSH BC        \ Push old 
  LD C, E         
  LD B, D        \ PFA to TOS
  NEXTHL
ENDASM

\ PART 2: Code definitions, laid out by compiler.

CODE LIT ( --- n)
\G Run-time part of LITERAL. Pushes next cell in instruction thread to stack.
    PUSH BC        \ Push old TOS
    EX DE, HL      \ IP now in HL
    LD C, (HL)
    INC HL
    LD B, (HL)     \ Load TOS from next cell in thread.
    INC HL
    NEXTHL
END-CODE
    
CODE BRANCH ( --- )
\G High-level unconditional jump, loads IP from next cell in instruction
\G thread
LABEL BR
    EX DE, HL
    LD E, (HL)
    INC HL
    LD D, (HL)
    NEXT
END-CODE

CODE ?BRANCH ( f ---)
\G High-level conditonal jump, jumps only if TOS=0    
    LD A, C
    OR B    \ Test TOS=0
    POP BC  \ Pop next entry into TOS
    JR Z, BR
    INC DE  \ skip branch address
    INC DE
    NEXT
END-CODE    

CODE EXECUTE ( xt ---)
\G Execute the word with execution token xt. 
    LD L, C
    LD H, B  \ Move CFA to HL
    POP BC   \ Pop next stack entry into TOS
    JP (HL)  \ Jump to it
END-CODE

CODE EXIT ( --- )
\G Return from colon definition.    
    LD L, 0 (IX+)
    INC IX
    LD H, 0 (IX+)  \ Pop IP from Return stack
    INC IX
    NEXTHL 
END-CODE

CODE UNNEST ( --- )
\G Synonym for EXIT, used by compiler, so decompiler can use this as end of
\G colon definition.   
    LD L, 0 (IX+)
    INC IX
    LD H, 0 (IX+)
    INC IX
    NEXTHL 
END-CODE

CODE (DO) ( n1 n2 ---)
\G Runtime part of DO. n2 is initial counter, n1 is limit
    POP HL
LABEL DO1
    LD A, L
    LD L, C
    LD C, A
    LD A, H
    XOR $80 \ XOR limit with 0x8000
    LD H, B
    LD B, A \ Swap BC and HL. start in HL, limit xor 0x8000 in BC
    AND A
    SBC HL, BC \ HL = start - (limit xor 0x8000)
    DEC IX
    LD 0 (IX+), B
    DEC IX
    LD 0 (IX+), C  \ Push Limit ^ 0x8000  on return stack
    DEC IX
    LD 0 (IX+), H
    DEC IX
    LD 0 (IX+), L  \ Push modified start value on return stack
    \ terminate when crossing limit-1, limit in any directions.
    \ End-of-loop condition is indicated by overflow flag when adding
    \ modified loop variable. 
    \ regardless of positive or negative increment in +LOOP.
    POP BC    \ Load new TOS
    NEXT
END-CODE

CODE (?DO) ( n1 n2 ---)
\G Runtime part of ?DO. n2 is initial counter, n1 is limit
\G The next cell contains a branch address to skip the
\G loop when limit and start are equal.
    POP HL
    AND A
    SBC HL, BC \ Compare start and limit.
    0<> IF
	ADD HL, BC \ Add back to restore HL
	INC DE
	INC DE \ Skip branch address.
	JR DO1 \ Continue into (DO) function.
    THEN
    POP BC  \ Load new TOS
    JP BR   \ Branch beyond loop if operands were equal.
END-CODE

LABEL ENDLOOP
    INC DE
    INC DE   \ Skip branch back address.
    EX DE, HL
    LD DE, 4
    ADD IX, DE \ Remove 2 loop values from return stack
    NEXTHL
ENDASM

CODE (LOOP) ( --- )
\G Runtime part of LOOP
    PUSH BC
    LD BC, 1
    LABEL LOOP1
    LD L, 0 (IX+)
    LD H, 1 (IX+)    \ Get loop variable
    AND A
    ADC HL, BC       \ Add increment to loop variable. Need to use ADC not ADD
                     \ because ADD HL,reg does not change parity/overflow
    POP BC           \ Restore TOS
    JP PE, ENDLOOP   \ End-of-loop when overflow flag is set.
                     \ On Z80 this is even parity.
    LD 0 (IX+), L
    LD 1 (IX+), H    \ Store updated loop variable back
    EX DE, HL
    LD E, (HL)
    INC HL
    LD D, (HL)       \ Load IP from cell after (LOOP), branch back.
    NEXT
END-CODE

CODE (+LOOP) ( n ---)
\G Runtime part of +LOOP    
    JR LOOP1        \ Loop increment is already in BC
END-CODE

CODE (LEAVE) ( ---)
\G Runtime of LEAVE
    EX DE, HL
    LD DE, 4
    ADD IX, DE      \ Remove two cells from return stack
    LD E, (HL)
    INC HL
    LD D, (HL)      \ Load IP from cell after LEAVE, branch out.
    NEXT
END-CODE

\ PART 3: Code definitions used in programs.

CODE I ( --- n)
\G Get loop variable of innermost loop.
\ As the loop variable is stored in modifed form to facilitate end-of-loop
\ testing, we need to reverse this when obtaining I.    
    PUSH BC           \ Save old TOS
    LD L, 0 (IX+)
    LD H, 1 (IX+)     \ Load (modified) loop variable
    LD C, 2 (IX+)
    LD B, 3 (IX+)
    ADD HL, BC        \ Add limit^xor 0x8000 to obtain original loop variable.
    LD C, L            
    LD B, H           \ Put in TOS
    NEXT
END-CODE

CODE I' ( ---n)
\G Get limit variable of innermost loop.    
    PUSH BC
    LD C, 2 (IX+)
    LD A, 3 (IX+)
    XOR $80          \ Undo the XOR 0x8000  
    LD B, A
    NEXT
END-CODE

CODE J ( ---n)
\G Get loop variable of next outer loop.    
    PUSH BC            \ Save old TOS
    LD L, 4 (IX+)
    LD H, 5 (IX+)      \ Load (modified) loop variable
    LD C, 6 (IX+)
    LD B, 7 (IX+)
    ADD HL, BC         \ Add limit to obtain original loop variable.
    LD C, L
    LD B, H            \ Put in TOS
    NEXT
END-CODE

CODE UNLOOP ( --- )
\G Undo return stack effect of loop, can be followed by EXIT    
    EX DE, HL
    LD DE, 4
    ADD IX, DE    \ Remove 2 cells from return stack.
    NEXTHL
END-CODE

CODE R@ ( --- x)
\G x is a copy of the top of the return stack.
    PUSH BC
    LD C, 0 (IX+)
    LD B, 1 (IX+)
    NEXT
END-CODE

CODE >R ( x ---)
\G Push x on the return stack. 
    DEC IX
    LD 0 (IX+), B
    DEC IX
    LD 0 (IX+), C
    POP BC
    NEXT
END-CODE

CODE R> ( --- x)
\G Pop the top of the return stack and place it on the stack.
    PUSH BC
    LD C, 0 (IX+)
    INC IX
    LD B, 0 (IX+)
    INC IX
    NEXT
END-CODE

CODE RP@ ( --- a-addr)
\G Return the address of the return stack pointer.
    PUSH BC
    PUSH IX
    POP BC
    NEXT
END-CODE

CODE RP! ( a-addr --- )
\G Set the return stack pointer to a-addr.
    PUSH BC
    POP IX
    POP BC
    NEXT
END-CODE

CODE SP@ ( --- a-addr)
\G Return the address of the stack pointer (before SP@ was executed).
\G Note: TOS is in a register, hence stack pointer points to next cell.
    LD HL, 0
    ADD HL, SP
    PUSH BC
    LD C, L
    LD B, H
    NEXT
END-CODE

CODE SP! ( a-addr ---)
\G Set the stack pointer to a-addr.
    LD L, C
    LD H, B
    LD SP, HL
    NEXT
END-CODE

CODE UM* ( u1 u2 --- ud)
\G Multiply two unsigned numbers, giving double result. 
    PUSH BC    \ store TOS
    EXX        \ Use shadow register set.
    POP BC     \ Get TOS back (operand 1)
    POP DE     \ Get other operand.
    LD HL, 0   \ Initialize MSW of result, DE will be replaced by LSW
    LD A, $11  \ 17 iteration
    OR A       \ Clear carry
    BEGIN
	RR H   \ Rotate HL:DE 1 bit right (LSB of DE gets to carry).
	RR L
	RR D
	RR E
	U< IF
	    ADD HL, BC \ If carry, add BC operand.
	THEN   \ Any carry from this add will be shifted back in.
	DEC A  
    0= UNTIL
    PUSH DE    \ Push result
    PUSH HL
    EXX        \ Back to normal registers
    POP BC
    NEXT
END-CODE

CODE UM/MOD  ( ud u1 --- urem uquot)
\G Divide the unsigned double number ud by u1, giving unsigned quotient
\G and remainder.        
    PUSH BC   \ Store divisor
    EXX       \ Use shadow registers
    POP BC    \ Get divisor back
    POP HL    
    POP DE    \ Get dividend in HL:DE
    LD A, $10 \ 16 iterations
    SLA E       
    RL D      \ Shift HL:DE left. 
    BEGIN
	ADC HL, HL  \ Continue left shift
	U< IF
	    OR A    \ If carry, unconditionally subtract BC 
	    SBC HL, BC
	    OR A    \ and clear carry
	ELSE
	    SBC HL, BC \ else conditonal subtraction
	    U< IF
		ADD HL, BC \ if borrow, undo subtraction
		SCF        \ and set carry
	    THEN
	THEN
	RL E               \ shift quotient bit in.
	RL D
	DEC A
    0= UNTIL
    LD A, D       
    CPL
    LD B, A
    LD A, E
    CPL
    LD C, A               \ Complement quotient, to BC
    PUSH HL               \ Push remainder
    PUSH BC               \ Push quotient
    EXX                   \ back to normal registers
    POP BC                \ quotient to TOS
    NEXT
END-CODE

CODE + ( n1 n2 ---n3)
\G Add the top two numbers on the stack.
    POP HL
    ADD HL, BC
    LD C, L
    LD B, H
    NEXT
END-CODE

CODE - ( w1 w2 ---w3)
\G Subtract the top two numbers on the stack (w2 from w1).
    POP HL
    AND A
    SBC HL, BC
    LD C, L
    LD B, H
    NEXT
END-CODE

CODE NEGATE ( n1 --- -n1)
\G Negate top number on the stack.    
    LD HL, 0
    AND A
    SBC HL, BC
    LD C, L
    LD B, H
    NEXT
END-CODE

CODE AND ( x1 x2 ---x3)
\G Bitwise and of the top two cells on the stack. 
    POP HL
    LD A, C
    AND L
    LD C, A
    LD A, B
    AND H
    LD B, A
    NEXT
END-CODE

CODE OR ( x1 x2 ---x3)
\G Bitwise or of the top two cells on the stack. 
    POP HL
    LD A, C
    OR L
    LD C, A
    LD A, B
    OR H
    LD B, A
    NEXT
END-CODE

CODE XOR ( x1 x2 ---x3)
\G Bitwise exclusive or of the top two cells on the stack.
    POP HL
    LD A, C
    XOR L
    LD C, A
    LD A, B
    XOR H
    LD B, A
    NEXT
END-CODE

CODE 1+ ( w1 --- w2)
\G Add 1 to the top of the stack.
    INC BC
    NEXT
END-CODE

CODE 1- ( w1 --- w2)
\G Subtract 1 from the top of the stack.
    DEC BC
    NEXT
END-CODE

CODE 2+ ( w1 --- w2)
\G Add 2 to the top of the stack.
    INC BC
    INC BC
    NEXT
END-CODE

CODE 2- ( w1 --- w2)
\G Subtract 2 from the top of the stack.
    DEC BC
    DEC BC
    NEXT
END-CODE

CODE 2* ( w1 --- w2)
\G Multiply w1 by 2.
    SLA C
    RL B
    NEXT
END-CODE

CODE 2/ ( n1 --- n2)
\G Divide signed number n1 by 2.
    SRA B
    RR C
    NEXT
END-CODE

CODE D+ ( d1 d2 --- d3)
\G Add the double numbers d1 and d2.
    EXX
    POP HL
    POP DE
    POP BC
    ADD HL, BC
    PUSH HL
    PUSH DE
    EXX
    POP HL
    ADC HL, BC
    LD C, L
    LD B, H
    NEXT
END-CODE

CODE DNEGATE ( d1 --- d2)
\G Negate the top double number on the stack.
    POP HL
    LD A, L
    CPL
    LD L, A
    LD A, H
    CPL
    LD H, A
    INC HL
    PUSH HL
    LD A, C
    CPL
    LD C, A
    LD A, B
    CPL
    LD B, A
    LD A, L
    OR H
    0= IF
	INC BC
    THEN
    NEXT
END-CODE

CODE LSHIFT ( x1 u --- x2)
\G Shift x1 left by u bits, zeros are added to the right.
    POP HL
    LD B, C
    LD A, C
    AND A
    0<> IF
	BEGIN
	    ADD HL, HL
	B--0= UNTIL
    THEN
    LD C, L
    LD B, H
    NEXT
END-CODE

CODE RSHIFT ( x1 u --- x2)
\G Shift x1 right by u bits, zeros are added to the left.
    POP HL
    LD B, C
    LD A, C
    AND A
    0<> IF
	BEGIN
	    SRL H
	    RR L
	B--0= UNTIL
    THEN
    LD C, L
    LD B, H
    NEXT
END-CODE

CODE DROP ( x --- )
\G Discard the top item on the stack.        
    POP BC
    NEXT
END-CODE

CODE DUP   ( x --- x x )
\G Duplicate the top cell on the stack.    
    PUSH BC
    NEXT
END-CODE

CODE SWAP  ( n1 n2 --- n2 n1)
\G Swap the two top items on the stack.
    POP HL
    PUSH BC
    LD C, L
    LD B, H
    NEXT
END-CODE

CODE OVER  ( x1 x2 --- x1 x2 x1)
\G Copy the second cell of the stack. 
    POP HL
    PUSH HL
    PUSH BC
    LD C, L
    LD B, H
    NEXT
END-CODE

CODE ROT ( x1 x2 x3 --- x2 x3 x1)
\G Rotate the three top items on the stack.  
    POP HL
    EX (SP), HL
    PUSH BC
    LD C, L
    LD B, H
    NEXT
END-CODE

CODE -ROT ( x1 x2 x3 --- x3 x1 x2)
\G Rotate the three top items on the stack reverse direction compared to ROT.  
    LD L, C
    LD H, B
    POP BC
    EX (SP), HL
    PUSH HL
    NEXT
END-CODE

CODE 2DROP ( d ---)
\G Discard the top double number on the stack.
    POP BC
    POP BC
    NEXT
END-CODE

CODE 2DUP ( d --- d d )
\G Duplicate the top cell on the stack, but only if it is nonzero.
    POP HL
    PUSH HL
    PUSH BC
    PUSH HL
    NEXT
END-CODE

CODE 2SWAP ( d1 d2 --- d2 d1)
\G Swap the top two double numbers on the stack.
    EXX
    POP HL
    EXX
    POP HL
    EXX
    EX (SP), HL
    EXX
    PUSH BC
    EXX
    PUSH HL
    EXX
    LD C, L
    LD B, H
    NEXT
END-CODE

CODE 2OVER ( d1 d2 --- d1 d2 d1)
\G Take a copy of the second double number of the stack and push it on the 
\G stack.
    EXX
    POP DE
    POP BC
    POP HL
    PUSH HL
    PUSH BC
    PUSH DE
    EXX
    PUSH BC
    EXX
    PUSH HL
    PUSH BC
    EXX
    POP BC
    NEXT
END-CODE

CODE PICK ( u --- x)
\G place a copy of stack cell number u on the stack. 0 PICK is DUP, 1 PICK
\G is OVER etc.
    LD L, C
    LD H, B
    ADD HL, HL
    ADD HL, SP
    LD C, (HL)
    INC HL
    LD B, (HL)
    NEXT
END-CODE

CODE ROLL ( u ---)
\G  Move stack cell number u to the top. 1 ROLL is SWAP, 2 ROLL is ROT etc.
    PUSH BC
    EXX
    EX (SP), HL
    INC HL
    ADD HL, HL
    LD C, L
    LD B, H
    ADD HL, SP
    LD E, (HL)
    INC HL
    LD D, (HL)
    PUSH DE
    LD E, L
    LD D, H
    DEC HL
    DEC HL
    LDDR
    POP HL
    POP BC
    EX (SP), HL
    EXX
    POP BC
    NEXT
END-CODE

CODE C@ ( c-addr --- c)
\G Fetch character c at c-addr.
    LD A, (BC)
    LD C, A
    LD B, 0
    NEXT
END-CODE

CODE @ ( a-addr --- x)
\G Fetch cell x at a-addr.
    LD A, (BC)
    LD L, A
    INC BC
    LD A, (BC)
    LD C, L
    LD B, A
    NEXT
END-CODE

CODE C! ( c c-addr ---)
\G Store character c at c-addr
    POP HL
    LD A, L
    LD (BC), A
    POP BC
    NEXT
END-CODE

CODE ! ( x a-addr ---)
\G Store cell x at a-addr
    POP HL
    LD A, L
    LD (BC), A
    INC BC
    LD A, H
    LD (BC), A
    POP BC
    NEXT
END-CODE

CODE +! ( w a-addr ---)
\G Add w to the contents of the cell at a-addr.
    POP HL
    LD A, (BC)
    ADD A, L
    LD (BC), A
    INC BC
    LD A, (BC)
    ADC A, H
    LD (BC), A
    POP BC
    NEXT
END-CODE

CODE 2@ ( a-addr --- d)
\G Fetch double number d at a-addr. 
    LD L, C
    LD H, B
    LD  C, (HL)
    INC HL
    LD  B, (HL)
    INC HL
    LD  A, (HL)
    INC HL
    LD  H, (HL)
    LD  L, A
    PUSH HL
    NEXT
END-CODE

CODE 2! ( d a-addr ---)
\G Store the double number d at a-addr.
    LD L, C
    LD H, B
    POP BC
    LD (HL), C
    INC HL
    LD (HL), B
    INC HL
    POP BC
    LD (HL), C
    INC HL
    LD (HL), B
    POP BC
    NEXT
END-CODE

CODE P@ ( p-addr --- c)
\G Read a byte from an I/O port
    IN C, (C)
    LD B, 0
    NEXT
END-CODE

CODE P! ( c p-addr ---)
\G Write a byte to an I/O port
    POP HL
    OUT (C), L
    POP BC
    NEXT
END-CODE    

CODE SYSVARS ( --- d-addr)
\G Obtain the address of the system variables.
    PUSH BC    
    PUSH IX
    LD A, $8
    RST $8
    PUSH .LIL IX         \ Push address onto SPL
    LD .LIL HL, 2 A; 0 C, \ extra 0 byte to extend immediate value for LIL
    ADD .LIL HL, SP
    LD .LIL C, (HL) \ Pick most significant byte of psuhed value
    LD B, 0
    POP .LIL HL  \ Pull the value into HL
    POP IX
    PUSH HL \ Put LSB address onto SPS
    NEXT
END-CODE    

CODE XC@ ( d-addr --- c)
\G Read a byte value from an extended address.
    POP HL
    PUSH IX
    PUSH .LIL HL
    LD .LIL IX, 0 A; 0 C,
    ADD .LIL IX, SP
    LD .LIL 2 (IX+), C  \ Add MSB to value on stack
    POP .LIL HL  \ Extended address now in UHL
    POP IX
    LD .LIL C, (HL)
    NEXT
END-CODE

CODE XC! ( c d-addr ---)
\G Store a byte value into an extended address.    
    POP HL
    PUSH IX
    PUSH .LIL HL
    LD .LIL IX, 0 A; 0 C,
    ADD .LIL IX, SP
    LD .LIL 2 (IX+), C  \ Add MSB to value on stack
    POP .LIL HL  \ Extended address now in UHL
    POP IX
    POP BC
    LD .LIL (HL), C
    POP BC
    NEXT
END-CODE    

CODE 0= ( x --- f)
\G f is true if and only if x is 0.
    LD A, B
    OR C
    SUB 1     \ Get a carry if and only if BC=0
    SBC A, A  \ Get 0 if no carry, 0FFh if carry.
    LD C, A
    LD B, A   \ Flag value to TOS
    NEXT
END-CODE

CODE 0< ( n --- f)
\G f is true if and only if n is less than 0.
    RL B      \ Get MSB of TOS to carry 
    SBC A, A  \ Get 0 if no carry, 0FFh if carry.
    LD C, A
    LD B, A   \ Flag value to TOS
    NEXT
END-CODE

LABEL YES       \ Store a true flag on stack.
 DEC BC         \ Change false to true flag.
 NEXT
ENDASM

LABEL LESS_OVF \ overflow detected, less if not negative
    JP P, YES
    NEXT
ENDASM

CODE < ( n1 n2 --- f)
\G f is true if and only if signed number n1 is less than n2. 
    POP HL
    XOR A
    SBC HL, BC \ Subtract n1-n2
    LD BC, 0  \ False result to TOS
    JP PE, LESS_OVF
    JP M, YES \ No overflow, less if negative
    NEXT
END-CODE

CODE U< ( u1 u2 --- f)
\G f is true if and only if unsigned number u1 is less than u2.   
    POP HL
    XOR A
    SBC HL, BC \ Subtract u1-u2
    SBC A, A   \ Get 0 if no carry, 0FFh if carry.
    LD B, A       
    LD C, A    \ Flag value to TOS
    NEXT
END-CODE

CODE = ( x1 x2 --- f)
\G f is true if and only if x1 is equal to x2.
    POP HL
    AND A
    SBC HL, BC
    LD BC, 0
    JR Z, YES
    NEXT
END-CODE

CODE INVERT ( x1 --- x2)
\G Invert all the bits of x1 (one's complement)
    LD A, C
    CPL
    LD C, A
    LD A, B
    CPL
    LD B, A
    NEXT
END-CODE    
    
CODE CMOVE ( c-addr1 c-addr2 u ---)
\G Copy u bytes starting at c-addr1 to c-addr2, proceeding in ascending
\G order.
    PUSH BC
    EXX
    POP BC
    POP DE
    POP HL
    LD A, C
    OR B
    0<> IF
	LDIR
    THEN
    EXX
    POP BC
    NEXT
END-CODE

CODE CMOVE> ( c-addr1 c-addr2 u ---)
\G Copy a block of u bytes starting at c-addr1 to c-addr2, proceeding in
\G descending order.
    PUSH BC
    EXX
    POP BC
    POP DE
    POP HL
    LD A, C
    OR B
    0<> IF
	ADD HL, BC
	DEC HL
	EX DE, HL
	ADD HL, BC
	DEC HL
	EX DE, HL
	LDDR
    THEN
    EXX
    POP BC
    NEXT
END-CODE

CODE FILL ( c-addr u c ---)
\G Fill a block of u bytes starting at c-addr with character c.
    LD A, C
    EXX
    POP BC
    POP HL
    EX AF, AF'
    LD A, C
    OR B
    0<> IF
	EX AF, AF'
	LD (HL), A \ Write first byte
	LD E, L
	LD D, H
	INC DE
	DEC BC
	LD A, C
	OR B
	0<> IF
	    LDIR \ Copy byte to next lcoation repeatedly.
	THEN
    THEN
    EXX
    POP BC
    NEXT
END-CODE

CODE (FIND) ( c-addr u nfa  --- cfa/word f )
\G find the string at c-addr, length u in the dictionary starting at nfa.
\G Search in a single hash chain. Return the cfa of the found word. If
\G If the word is not found, return the string addres instead. Flag values:
\G 0 for not found, 1 for immediate word, -1 for normal word.   
    PUSH BC
    EXX
    POP DE
    POP BC     \ Get string length in C
    PUSH DE
    BEGIN
	POP DE  \ nfa in DE
	POP HL  \ string start in HL
	PUSH HL
	PUSH DE
	LD A, (DE) \ Get count byte at nfa
	INC DE
	AND $1F    \ remove flag bits
	CP C      \ Compare with string length.
	0= IF     \ count bytes match
	    LD B, A
	    LABEL CMPLOOP
	    LD A, (DE)
	    INC DE
	    CP (HL)
	    INC HL
	    0= IF
		DJNZ CMPLOOP
		\ Got here, word is found
		EX DE, HL
		POP DE
		POP BC
		LD A, (DE)
		AND $40 \ Check immedate flag
		0= IF
		    LD BC, $FFFF
		ELSE
		    LD BC, $0001
		THEN
		PUSH HL
		PUSH BC
		EXX
		POP BC
		NEXT
	    THEN
	THEN
	POP HL
	DEC HL
	LD D, (HL)
	DEC HL
	LD E, (HL)  \ Get next link in the chain (precdes name).
	PUSH DE
	LD A, E
	OR D        \ Test for zero.
    0= UNTIL
    EXX             \ Not found, zero value already on stack.
    POP BC
    NEXT
END-CODE

CODE SCAN ( c-addr1 u11 c --- c-addr2 u2 )
\G Find the first occurrence of character c in the string c-addr1 u1
\G c-addr2 u2 is the remaining part of the string starting with that char.
\G It is a zero-length string if c was not found.
    LD A, C     \ character to A
    EXX         \ Use shadow registers
    POP BC      \ Get length
    POP HL      \ and address
    LD E, A     \ character to E
    LD A, B    
    OR C        \ Test for zero length.
    0<> IF
	LD A, E \ char back to A.
	CPIR    \ Use CPIR to find mactching character
	0= IF
	    INC BC \ Match found, go back one character.
	    DEC HL 
	THEN
    THEN
LABEL SCANDONE
    PUSH HL   
    PUSH BC       \ Push address and length
    EXX           \ Back to normal registers
    POP BC        \ Get legnth into TOS
    NEXT    
END-CODE

CODE SKIP ( c-addr1 u1 c --- c-addr2 u2 )
\G Find the first character not equal to c in the string c-addr1 u1
\G c-addr2 u2 is the remaining part of the string starting with the
\G nonmatching char. It is a zero-length string if no other chars found.
    LD A, C     \ character to A
    EXX         \ Use shadow registers
    POP BC      \ Get length
    POP HL      \ and address
    LD E, A     \ character to E
    LD A, B    
    OR C        \ Test for zero length.
    0<> IF
	LD A, E \ char back to A.  
	LABEL SKIPLOOP
	CPI     \ Test character pointed to by HL
	0= IF
	    JP PE, SKIPLOOP \ If still matching test parity flag to determine
	    \ if we can search further.
	    JR SCANDONE \ No non-matching character found.
	THEN
	INC BC  \ Back 1 character up.
	DEC HL
    THEN
    PUSH HL     
    PUSH BC     \ Push address and length.
    EXX         \ Back to normal registers
    POP BC      \ Get legnth into TOS
    NEXT
END-CODE

CODE NOOP ( --- )
\G No operation    
    NEXT
END-CODE    

END-CROSS
