\ CROSS COMPILER FOR THE ZILOG Z80 PROCESSOR
\ created 1995 by L.C. Benschop.
\ copyleft (c) 1995-2014 by the sbc09 team, see AUTHORS for more details.
\ copyleft (c) 2022 L.C. Benschop for Cerberus 2080.
\ license: GNU General Public License version 3, see LICENSE for more details.
\
\ This serves as an introduction to Forth cross compiling, so it is extensively
\ commented.
\
\ This cross compiler can be run on any ANS Forth with the necessary
\ extension wordset that is at least 16-bit, including Z80 Forth.
\
\ It creates the memory image of a new Forth system that is to be run
\ by the Zilog Z80 processor.
\
\ The cross compiler (or meta compiler or target compiler) is similar
\ to a regular Forth compiler, except that it builds definitions in
\ a dictionary in the memory image of a different Forth system.
\ We call this the target dictionary in the target space of the
\ target system.
\
\ As the new definitions are for a different Forth system, the cross
\ compiler cannot EXECUTE them. Neither can it easily find the new
\ definitions in the target dictionary. Hence a shadow definition
\ for each target definition is made in the normal Forth dictionary.
\
\ The names of the new definitions overlap with the names of existing
\ elementary. Forth words. Therefore they need to be in a wordlist
\ different from the normal Forth wordlist.

\ PART 1: THE VOCABULARIES.

VOCABULARY TARGET
\ This vocabulary will hold shadow definitions for all words that are in
\ the target dictionary. When a shadow definition is executed, it
\ performs the compile action in the target dictionary.

VOCABULARY TRANSIENT
\ This vocabulary will hold definitions that must be executed by the
\ host system ( the system on which the cross compiler runs) and that
\ compile to the target system.

\ Expl: The word IF occurs in all three vocabularies. The word IF in the
\       FORTH vocabulary is run by the host system and is used when
\       compiling host definitions. A different version is in the
\       TRANSIENT vocabulary. This one runs on the host system and
\       is used when compiling target definitions. The version in the
\       TARGET vocabulary is the version that will run on the target
\       system.

\ : \D ; \ Uncomment one of these. If uncommented, display debug info.
: \D POSTPONE \ ; IMMEDIATE

\ PART 2: THE TARGET DICTIONARY SPACE.

\ Next we need to define the target space and the words to access it.

    0 CONSTANT ORIGIN \ Start address of Forth image.
12000 CONSTANT IMAGE_SIZE


CREATE IMAGE IMAGE_SIZE CHARS ALLOT \ This space contains the target image.
       IMAGE IMAGE_SIZE 0 FILL      \ Initialize it to zero.

\ Fetch and store characters in the target space.
: C@-T ( t-addr --- c) ORIGIN - CHARS IMAGE + C@ ;
: C!-T ( c t-addr ---) ORIGIN - CHARS IMAGE + C! ;

\ Fetch and store cells in the target space.
\ Z80 is little endian 16 bit so store explicitly little-endian.
: @-T  ( t-addr --- x)
       ORIGIN - CHARS IMAGE + DUP C@  SWAP 1 CHARS + C@ 8 LSHIFT + ;

: !-T  ( x t-addr ---)
       ORIGIN - CHARS IMAGE + OVER OVER C! SWAP 8 RSHIFT SWAP 1 CHARS + C! ;

\ A dictionary is constructed in the target space. Here are the primitives
\ to maintain the dictionary pointer and to reserve space.

VARIABLE DP-T                       \ Dictionary pointer for target dictionary.
ORIGIN DP-T !                       \ Initialize it to origin.
: THERE ( --- t-addr) DP-T @ ;      \ Equivalent of HERE in target space.
: ALLOT-T ( n --- ) DP-T +! ;       \ Reserve n bytes in the dictionary.
: CHARS-T ( n1 --- n2 ) ;
: CELLS-T ( n1 --- n2 ) 1 LSHIFT ;  \ Cells are 2 chars.
: ALIGN-T ;                          \ No alignment used.
: ALIGNED-T ( n1 --- n2 ) ;
: C,-T  ( c --- )  THERE C!-T 1 CHARS ALLOT-T ;
: ,-T   ( x --- )  THERE !-T  1 CELLS-T ALLOT-T ;

: PLACE-T ( c-addr len t-addr --- ) \ Move counted string to target space.
  OVER OVER C!-T 1+ CHARS ORIGIN - IMAGE + SWAP CHARS CMOVE ;

\ Z80 cross assembler already loaded, configure it for cross assembly.

FORTH ' ,-T ASSEMBLER IS ,
FORTH ' C,-T ASSEMBLER IS C_ 
FORTH ' !-T ASSEMBLER IS V!
FORTH ' @-T ASSEMBLER IS V@
FORTH ' C!-T ASSEMBLER IS VC!
FORTH ' C@-T ASSEMBLER IS VC@
FORTH ' THERE ASSEMBLER IS HERE
FORTH

\ PART 3: CREATING NEW DEFINITIONS IN THE TARGET SYSTEM.

\ These words create new target definitions, both the shadow definition
\ and the header in the target dictionary. The layout of target headers
\ can be changed but FIND in the target system must be changed accordingly.

\ All definitions are linked together in a number of threads. Each word
\ is linked in only one thread. Which thread the word is linked to, can be
\ determined from the name by a 'hash' code. To find a word, one can compute
\ the hash code and then one can search just one thread that contains a
\ small fraction of the words.

4 CONSTANT #THREADS \ Number of threads

CREATE TLINKS #THREADS CELLS ALLOT   \ This array points to the names
                           \ of the last definition in each thread.
TLINKS #THREADS CELLS 0 FILL

VARIABLE LAST-T          \ Address of last definition.

: HASH ( c-addr u #threads --- n)
  >R OVER C@ 1 LSHIFT OVER 1 > IF ROT CHAR+ C@ 2 LSHIFT XOR ELSE ROT DROP
   THEN XOR
  R> 1- AND
;

: "HEADER >IN @ CREATE >IN ! \ Create the shadow definition.
  BL WORD
  DUP COUNT #THREADS HASH >R \ Compute the hash code.
  ALIGN-T TLINKS R@ CELLS + @ ,-T        \ Lay out the link field.
\D  DUP COUNT CR ." Creating: " TYPE ."  Hash:" R@ .
  COUNT DUP >R THERE PLACE-T  \ Place name in target dictionary.
  THERE TLINKS R> R> SWAP >R CELLS + !
  THERE LAST-T !
  THERE C@-T 128 OR THERE C!-T R> 1+ ALLOT-T ALIGN-T ;
      \ Set bit 7 of count byte as a marker.

\ : "HEADER CREATE ALIGN-T ;  \ Alternative for "HEADER in case the target system
                      \ is just an application without headers.


ALSO TRANSIENT DEFINITIONS
: IMMEDIATE LAST-T @ DUP C@-T 64 OR SWAP C!-T ;
            \ Set the IMMEDIATE bit of last name.
PREVIOUS DEFINITIONS

\ PART 4: FORWARD REFERENCES

\ Some definitions are referenced before they are defined. A definition
\ in the TRANSIENT voc is created for each forward referenced definition.
\ This links all addresses together where the forward reference is used.
\ The word RESOLVE stores the real address everywhere it is needed.

: FORWARD
  CREATE 0 ,              \ Store head of list in the definition.
  DOES>
        DUP @ ,-T THERE 1 CELLS-T - SWAP ! \ Reserve a cell in the dictionary
                  \ where the call to the forward definition must come.
	          \ As the call address is unknown, store link to next
                  \ reference instead.
;

: RESOLVE
  ALSO TARGET >IN @ ' >BODY @ >R >IN ! \ Find the resolving word in the
                          \ target voc. and take the CFA out of the definition.
\D >IN @ BL WORD COUNT CR ." Resolving: " TYPE >IN !
  TRANSIENT ' >BODY  @                 \ Find the forward ref word in the
                                       \ TRANSIENT VOC and take list head.
  BEGIN
   DUP                              \ Traverse all the links until end.
  WHILE
   DUP @-T                             \ Take address of next link from dict.
   R@ ROT !-T                           \ Set resolved address in dict.
  REPEAT DROP R> DROP PREVIOUS
;


\ PART 5: CODE GENERATION

\ Zilog Z80 Forth is a direct threaded Forth. It uses the following
\ registers: SP for stack pointer, IX for return stack pointer, DE for
\ BC for TOS
\ The code field of a definition contains a CALL instruction.

: CALL, [ HEX ] 0CD C,-T [ DECIMAL ] ;

VARIABLE STATE-T 0 STATE-T ! \ State variable for cross compiler.
: T] 1 STATE-T ! ;
: T[ 0 STATE-T ! ;

VARIABLE CSP   \ Stack pointer checking between : and ;
: !CSP DEPTH CSP ! ;
: ?CSP DEPTH CSP @ - ABORT" Incomplete control structure" ;

TRANSIENT DEFINITIONS FORTH
FORWARD LIT
FORWARD DOCOL
FORWARD DOCON
FORWARD DOVAR
FORWARD UNNEST
FORWARD BRANCH
FORWARD ?BRANCH
FORWARD DODOES
FORTH DEFINITIONS

: LITERAL-T ( n --- )
\D DUP ."  Literal:" . CR
  [ TRANSIENT ] LIT [ FORTH ] ,-T ;

TRANSIENT DEFINITIONS FORTH
\ Now define the words that do compile code.


: : !CSP "HEADER THERE , CALL, [ TRANSIENT ] DOCOL [ FORTH ]  T]
    DOES> @ ,-T ;

: ; [ TRANSIENT ] UNNEST [ FORTH ] \ Compile the unnest primitive.
   T[ ?CSP \ Quit compilation state.
  ;


: CODE "HEADER ASSEMBLE THERE ,
  DOES> @ ,-T ;
: END-CODE  [ ASSEMBLER ] ENDASM [ FORTH ] ;
: LABEL THERE CONSTANT ASSEMBLE ;

FORTH DEFINITIONS

\ PART 6: DEFINING WORDS.

TRANSIENT DEFINITIONS FORTH

: VARIABLE "HEADER THERE , CALL, [ TRANSIENT ] DOVAR [ FORTH ]  0 ,-T
\ Create a variable.
DOES> @ ,-T ;

: CONSTANT "HEADER THERE , CALL, [ TRANSIENT ] DOCON [ FORTH ]
  ,-T
  DOES> @ ,-T ;

FORTH DEFINITIONS

: T' ( --- t-addr) \ Find the execution token of a target definition.
  ALSO TARGET '
\D ." T' shadow address, target address " DUP . DUP >BODY @ .
  >BODY @ \ Get the address from the shadow definition.
  PREVIOUS
;

: >BODY-T ( t-addr1 --- t-addr2 ) \ Convert executing token to param address.
  3 + ;

\ PART 7: COMPILING WORDS

TRANSIENT DEFINITIONS FORTH

\ The TRANSIENT definitions for IF, THEN etc. compile the
\ branch primitives BRAMCH and ?BRANCH.

: BEGIN  THERE ;
: UNTIL  [ TRANSIENT ] ?BRANCH [ FORTH ] ,-T ;
: IF [ TRANSIENT ] ?BRANCH [ FORTH ] THERE 1 CELLS-T ALLOT-T ;
: THEN  THERE SWAP !-T ; TARGET
: ELSE [ TRANSIENT ] BRANCH THERE 1 CELLS-T ALLOT-T SWAP THEN [ FORTH ] ;
: WHILE [ TRANSIENT ] IF [ FORTH ] SWAP ; TARGET
: REPEAT [ TRANSIENT ] BRANCH ,-T THEN [ FORTH ] ;

FORWARD (DO)
FORWARD (LOOP)
FORWARD (.")
FORWARD (POSTPONE)

: DO [ TRANSIENT ] (DO) [ FORTH ] THERE ;
: LOOP [ TRANSIENT ] (LOOP) [ FORTH ] ,-T ;
: ." [ TRANSIENT ] (.") [ FORTH ] 34 WORD COUNT DUP 1+ >R
      THERE PLACE-T R> ALLOT-T ALIGN-T ;
: POSTPONE [ TRANSIENT ] (POSTPONE) [ FORTH ] T' ,-T ;

: \ POSTPONE \ ; IMMEDIATE
: \G POSTPONE \ ; IMMEDIATE
: ( POSTPONE ( ; IMMEDIATE \ Move duplicates of comment words to TRANSIENT
: CHARS-T CHARS-T ; \ Also words that must be executed while cross compiling.
: CELLS-T CELLS-T ;
: ALLOT-T ALLOT-T ;
: ['] T' LITERAL-T ;

FORTH DEFINITIONS

\ PART 8: THE CROSS COMPILER ITSELF.

VARIABLE DPL
: NUMBER? ( c-addr ---- d f)
  -1 DPL !
  BASE @ >R
  COUNT
  OVER C@ 45 = DUP >R IF 1 - SWAP 1 + SWAP THEN \ Get any - sign
  OVER C@ 36 = IF 16 BASE ! 1 - SWAP 1 + SWAP THEN   \ $ sign for hex.
  OVER C@ 35 = IF 10 BASE ! 1 - SWAP 1 + SWAP THEN   \ # sign for decimal
  DUP  0 > 0= IF  R> DROP R> BASE ! 0 EXIT THEN   \ Length 0 or less?
  >R >R 0 0 R> R>
  BEGIN
   >NUMBER
   DUP IF OVER C@ 46 = IF 1 - DUP DPL ! SWAP 1 + SWAP ELSE \ handle point.
         R> DROP R> BASE ! 0 EXIT THEN   \ Error if anything but point
       THEN
  DUP 0= UNTIL DROP DROP R> IF DNEGATE THEN
  R> BASE ! -1
;

: CROSS-COMPILE
  ONLY TARGET DEFINITIONS ALSO TRANSIENT \ Restrict search order.
  BEGIN
   BL WORD
 \D CR DUP COUNT TYPE
   DUP C@ 0= IF \ Get new word
    DROP REFILL DROP                      \ If empty, get new line.
   ELSE
    DUP COUNT S" END-CROSS" COMPARE 0=    \ Exit cross compiler on END-CROSS
    IF
     ONLY FORTH ALSO DEFINITIONS          \ Normal search order again.
     DROP EXIT
    THEN
    FIND IF                               \ Execute if found.
     EXECUTE
    ELSE
     NUMBER? 0= ABORT" Undefined word" DROP
     STATE-T @ IF \ Parse it as a number.
      LITERAL-T   \ If compiling then compile as a literal.
     THEN
    THEN
   THEN
  0 UNTIL
;

