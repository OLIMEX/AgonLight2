\ created 1994 by L.C. Benschop.
\ copyleft (c) 1994-2014 by the sbc09 team, see AUTHORS for more details.
\ copyleft (c) 2022 L.C. Benschop for Cerberus 2080.
\ license: GNU General Public License version 3, see LICENSE for more details.
CROSS-COMPILE

\ PART 12:  numeric input.

: DIGIT? ( c -- 0| c--- n -1)
\G Convert character c to its digit value n and return true if c is a
\G digit in the current base. Otherwise return false.
  48 - DUP 0< IF DROP 0 EXIT THEN
  DUP 9 > OVER 17 < AND IF DROP 0 EXIT THEN
  DUP 9 > IF 7 - THEN
  DUP BASE @ < 0= IF DROP 0 EXIT THEN
  -1
;

: >NUMBER ( ud1 c-addr1 u1 --- ud2 c-addr2 u2 )
\G Convert the string at c-addr with length u1 to binary, multiplying ud1
\G by the number in BASE and adding the digit value to it for each digit.
\G c-addr2 u2 is the remainder of the string starting at the first character
\G that is no digit.
  BEGIN
   DUP
  WHILE
   1 - >R
   COUNT DIGIT? 0=
   IF
    R> 1+ SWAP 1 - SWAP  EXIT
   THEN
   SWAP >R
   >R
   SWAP BASE @ UM* ROT BASE @ * 0 SWAP D+ \ Multiply ud by base.
   R> 0 D+                                \ Add new digit.
   R> R>
  REPEAT
;

: CONVERT ( ud1 c-addr1 --- ud2 c-addr2)
\G Convert the string starting at c-addr1 + 1 to binary. c-addr2 is the
\G address of the first non-digit. Digits are added into ud1 as in >NUMBER
  1 - -1 >NUMBER DROP ;

: NUMBER? ( c-addr ---- d f)
\G Convert the counted string at c-addr to a double binary number.
\G f is true if and only if the conversion was successful. DPL contains
\G -1 if there was no point in the number, else the position of the point
\G from the right. Special prefixes: # means decimal, $ means hex.
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

\ PART 13: THE COMPILER

VARIABLE ERROR$ ( --- a-addr )
\G Variable containing string address of ABORT" message.

VARIABLE HANDLER ( --- a-addr )
\G Variable containing return stack address where THROW should return.

: (ABORT") ( f -- - )
\G Runtime part of ABORT"
           IF R>  ERROR$ ! -2 THROW
           ELSE R> COUNT +  >R THEN ;

: THROW ( n --- )
\G If n is nonzero, cause the corresponding CATCH to return with n.
DUP IF
 HANDLER @ IF
  HANDLER @ RP!
  RP@ 4 + @ HANDLER ! \ point to previous exception frame.
  R>                  \ get old stack pointer.
  SWAP >R SP! DROP R> \ save throw code temp. on ret. stack set old sp.
  R> DROP             \ remove address of handler.
                      \ return stack points to return address of CATCH.
 ELSE
  WARM \ Warm start if no exception frame on stack.
 THEN
ELSE
 DROP \ continue if zero.
THEN
;

: ?THROW ( f n --- )
\G Perform n THROW if f is nonzero.
  SWAP IF THROW ELSE DROP THEN ;

: CATCH ( xt --- n )
\G Execute the word with execution token xt. If it returns normally, return
\G 0. If it executes a THROW, return the throw parameter.
 HANDLER @ >R  \ push handler on ret stack.
 SP@ >R        \ push stack pointer on ret stack,
 RP@ HANDLER !
 EXECUTE
 RP@ 4 + @ HANDLER ! \ set handler to previous exception frame.
 R> DROP R> DROP \ remove exception frame.
 0 \ return 0
;

: ALLOT ( n --- )
\G Allot n extra bytes of memory, starting at HERE to the dictionary.
  DP +! ;

: , ( x --- )
\G Append cell x to the dictionary at HERE.
  HERE ! 1 CELLS ALLOT ;

: C, ( n --- )
\G Append character c to the dictionary at HERE.
  HERE C! 1 ALLOT ;

: ALIGN ( --- )
\G Add as many bytes to the dictionary as needed to align dictionary pointer.
  ;

: >NAME ( addr1 --- addr2 )
\G Convert execution token addr1 (address of code) to address of name.
  BEGIN 1- DUP C@ 128 AND UNTIL ;

: NAME> ( addr1 --- addr2 )
\G Convert address of name to address of code.
  COUNT 31 AND +  ;

: HEADER ( --- )
\G Create a header for a new definition without a code field.
  0 , \ Create link field.
  HERE LAST !         \ Set LAST so definition can be linked by REVEAL
  32 WORD UPPERCASE?
           DUP FIND IF ." Redefining: " HERE COUNT TYPE CR THEN DROP
                       \ Give warning if existing word redefined.
  DUP COUNT CURRENT @ 2+ @ HASH 2+ CELLS CURRENT @ + @ HERE CELL- !
                       \ Set link field to point to the right thread
  C@ 1+ HERE C@ 128 + HERE C! ALLOT 
                       \ Allot the name and set bit 7 in length byte.
;

: CALL,  ( ---)
\G Add a CALL opcode to the dictionary.
    $CD C, ;

: REVEAL ( --- )
\G Add the last created definition to the CURRENT wordlist.
  LAST @ DUP COUNT 31 AND \ Get address and length of name
  CURRENT @ 2+ @ HASH        \ compute hash code.
  2+ CELLS CURRENT @ + ! ;

: CREATE ( "ccc" --- )
\G Create a definition that returns its parameter field address when
\G executed. Storage can be added to it with ALLOT.
  HEADER REVEAL CALL, LIT DOVAR , ;

: VARIABLE ( "ccc" --- )
\G Create a variable where 1 cell can be stored. When executed it
\G returns the address.
  CREATE 0 , ;

: CONSTANT ( x "ccc" ---)
\G Create a definition that returns x when executed.
\ Definition contains lit & return in its code field.
  HEADER REVEAL CALL, LIT DOCON , , ;


VARIABLE STATE ( --- a-addr)
\G Variable that holds the compiler state, 0 is interpreting 1 is compiling.

: ]  ( --- )
\G Start compilation mode.
  1 STATE ! ;

: [  ( --- )
\G Leave compilation mode.
  0 STATE ! ; IMMEDIATE

: LITERAL ( n --- )
\G Add a literal to the current definition.
 POSTPONE LIT , ; IMMEDIATE

: COMPILE, ( xt --- )
\G Add the execution semantics of the definition xt to the current definition.
 ,
;

VARIABLE CSP ( --- a-addr )
\G This variable is used for stack checking between : and ;

VARIABLE 'LEAVE ( --- a-addr)
\ This variable is used for LEAVE address resolution.

: !CSP ( --- )
\G Store current stack pointer in CSP.
   SP@ CSP ! ;

: ?CSP ( --- )
\G Check that stack pointer is equal to value contained in CSP.
   SP@ CSP @ - -22 ?THROW ;

: ; ( --- )
\G Finish the current definition by adding a return to it, make it
\G visible and leave compilation mode.
    POSTPONE UNNEST [
    ?CSP REVEAL
; IMMEDIATE

: (POSTPONE) ( --- )
\G Runtime for POSTPONE.
\ has inline argument.
  R> DUP @ SWAP CELL+ >R
  DUP >NAME C@ 64 AND IF EXECUTE ELSE COMPILE, THEN
;

: : ( "ccc" --- )
\G Start a new definition, enter compilation mode.
  !CSP HEADER CALL, LIT DOCOL , ] ;

: BEGIN ( --- x )
\G Start a BEGIN UNTIL or BEGIN WHILE REPEAT loop.
  HERE ; IMMEDIATE

: UNTIL ( x --- )
\G Form a loop with matching BEGIN.
\G Runtime: A flag is take from the stack
\G each time UNTIL is encountered and the loop iterates until it is nonzero.
  POSTPONE ?BRANCH , ; IMMEDIATE

: IF    ( --- x)
\G Start an IF THEN or IF ELSE THEN construction.
\G Runtime: At IF a flag is taken from
\G the stack and if it is true the part between IF and ELSE is executed,
\G otherwise the part between ELSE and THEN. If there is no ELSE, the part
\G between IF and THEN is executed only if flag is true.
   POSTPONE ?BRANCH HERE 1 CELLS ALLOT ; IMMEDIATE

: THEN ( x ---)
\G End an IF THEN or IF ELSE THEN construction.
   HERE SWAP ! ; IMMEDIATE

: ELSE ( x1 --- x2)
\G part of IF ELSE THEN construction.
   POSTPONE BRANCH HERE 1 CELLS ALLOT SWAP POSTPONE THEN ; IMMEDIATE

: WHILE  ( x1 --- x2 x1 )
\G part of BEGIN WHILE REPEAT construction.
\G Runtime: At WHILE a flag is taken from the stack. If it is false,
\G  the program jumps out of the loop, otherwise the part between WHILE
\G  and REPEAT is executed and the loop iterates to BEGIN.
  POSTPONE IF SWAP ; IMMEDIATE

: REPEAT ( x1 x2 --- )
\G part of BEGIN WHILE REPEAT construction.
  POSTPONE BRANCH , POSTPONE THEN ; IMMEDIATE

VARIABLE POCKET ( --- a-addr )
\G Buffer for S" strings that are interpreted.
  254 ALLOT-T

: '  ( "ccc" --- xt)
\G Find the word with name ccc and return its execution token.
  32 WORD UPPERCASE? FIND 0= -13 ?THROW ;

: ['] ( "ccc" ---)
\G Copile the execution token of the word with name ccc as a literal.
  ' LITERAL ; IMMEDIATE

: CHAR ( "ccc" --- c)
\G Return the first character of "ccc".
  BL WORD 1 + C@ ;

: [CHAR] ( "ccc" --- )
\G Compile the first character of "ccc" as a literal.
  CHAR LITERAL ; IMMEDIATE

: DO ( --- x1 x2)
\G Start a DO LOOP.
\G Runtime: ( n1 n2 --- ) start a loop with initial count n2 and
\G limit n1.
\ While compiling x1 is previous contents of 'LEAVE (for nested loops) and
\ x2 is address after (DO) to branch back from (LOOP)    
  POSTPONE (DO) 'LEAVE @ HERE 0 'LEAVE ! ; IMMEDIATE

: ?DO ( --- x1 x2 )
\G Start a ?DO LOOP.
\G Runtime: ( n1 n2 --- ) start a loop with initial count n2 and
\G limit n1. Exit immediately if n1 = n2.    
  POSTPONE (?DO) 'LEAVE @ HERE 'LEAVE ! 0 , HERE ; IMMEDIATE

: LEAVE ( --- )
\G Runtime: leave the matching DO LOOP immediately.
\ All places where a leave address for the loop is needed are in a linked
\ list, starting with 'LEAVE variable, the other links in the cells where
\ the leave addresses will come.
  POSTPONE (LEAVE) HERE 'LEAVE @ , 'LEAVE ! ; IMMEDIATE

: RESOLVE-LEAVE
\G Resolve the references to the leave addresses of the loop.
          'LEAVE @
          BEGIN DUP WHILE DUP @ HERE ROT ! REPEAT DROP ;

: LOOP  ( x1 x2 --- )
\G End a DO LOOP.
\G Runtime: Add 1 to the count and if it is equal to the limit leave the loop.
  POSTPONE (LOOP) , RESOLVE-LEAVE 'LEAVE ! ; IMMEDIATE

: +LOOP ( x1 x2 --- )
\G End a DO +LOOP
\G Runtime: ( n ---) Add n to the count and exit if this crosses the
\G boundary between limit-1 and limit.
  POSTPONE (+LOOP) , RESOLVE-LEAVE 'LEAVE ! ; IMMEDIATE

: RECURSE ( --- )
\G Compile a call to the current (not yet finished) definition.
  LAST @ NAME> COMPILE, ; IMMEDIATE

: ."  ( "ccc<quote>" --- )
\G Parse a string delimited by " and compile the following runtime semantics.
\G Runtime: type that string.
   POSTPONE (.") 34 WORD C@ 1+ ALLOT ; IMMEDIATE


: S"  ( "ccc<quote>" --- )
\G Parse a string delimited by " and compile the following runtime semantics.
\G Runtime: ( --- c-addr u) Return start address and length of that string.
  STATE @ IF POSTPONE (S") 34 WORD C@ 1+ ALLOT 
             ELSE 34 WORD COUNT POCKET PLACE POCKET COUNT THEN ; IMMEDIATE

: ABORT"  ( "ccc<quote>" --- )
\G Parse a string delimited by " and compile the following runtime semantics.
\G Runtime: ( f --- ) if f is nonzero, print the string and abort program.
  POSTPONE (ABORT") 34 WORD C@ 1+ ALLOT ; IMMEDIATE

: ABORT ( --- )
\G Abort unconditionally without a message.
 -1 THROW ;

: POSTPONE ( "ccc" --- )
\G Parse the next word delimited by spaces and compile the following runtime.
\G Runtime: depending on immediateness EXECUTE or compile the execution
\G semantics of the parsed word.
  POSTPONE (POSTPONE) ' , ; IMMEDIATE

: IMMEDIATE ( --- )
\G Make last definition immediate, so that it will be executed even in
\G compilation mode.
  LAST @ DUP C@ 64 OR SWAP C! ;

: ( ( "ccc<rparen>" --- )
\G Comment till next ).
  41 PARSE DROP DROP ; IMMEDIATE

: \
\G Comment till end of line.
  SOURCE >IN ! DROP ; IMMEDIATE

: >BODY ( xt --- a-addr)
\G Convert execution token to parameter field address.
  3 + ;

: (;CODE) ( --- )
\G Runtime for DOES>, exit calling definition and make last defined word
\G execute the calling definition after (;CODE)
  R> LAST @ NAME> 1+ ! ;

: DOES>  ( --- )
\G Word that contains DOES> will change the behavior of the last created
\G word such that it pushes its parameter field address onto the stack
\G and then executes whatever comes after DOES>
  POSTPONE (;CODE)
  CALL, LIT DODOES ,
; IMMEDIATE

\ PART 14: TOP LEVEL OF INTERPRETER

: ?STACK ( ---)
\G Check for stack over/underflow and abort with an error if needed.
  DEPTH DUP 0< -4 ?THROW 255 > -3 ?THROW HERE 128 + $FE00 U> -5 ?THROW ;

: INTERPRET ( ---)
\G Interpret words from the current source until the input source is exhausted.
  BEGIN
   32 WORD UPPERCASE?  DUP C@
  WHILE
   FIND DUP
   IF
    -1 = STATE @ AND
    IF
     COMPILE,
    ELSE
     EXECUTE
    THEN
   ELSE DROP
    NUMBER? 0= -13 ?THROW
    DPL @ 1+ IF
     STATE @ IF SWAP LITERAL LITERAL THEN
    ELSE
     DROP STATE @ IF LITERAL THEN
    THEN
   THEN  ?STACK
  REPEAT   DROP
;


: EVALUATE ( c-addr u --- )
\G Evaluate the string c-addr u as if it were typed on the terminal.
  SID @ >R SRC @ >R #SRC @ >R  >IN @ >R
  #SRC ! SRC ! 0 >IN ! -1 SID ! INTERPRET
  R> >IN ! R> #SRC ! R> SRC ! R> SID ! ;

VARIABLE ERRORS ( --- a-addr)
\G This variable contains the head of a linked list of error messages.

: ERROR-SOURCE ( --- )
\G Print location of error source.
     SID @ 0 > IF
      ." in line " LOADLINE @ .
     THEN
     HERE COUNT TYPE CR WARM
;

VARIABLE INCLUDE-BUFFER ( --- a-addr)
\G This is the buffer where the lines of included files are stored.
510 ALLOT-T

VARIABLE INCLUDE-POINTER ( --- a-addr)
\G This variable holds the address where the included line is stored.

: REFILL ( --- f)
\G Refill the current input source when it is exhausted. f is
\G true if it was successfully refilled.
  SOURCE-ID -1 = IF
   0 \ Not refillable for EVALUATE
  ELSE
      SOURCE-ID IF
	  SRC @ 256 SOURCE-ID READ-LINE -37 ?THROW
	  SWAP #SRC ! 0 >IN !
	  #SRC @ IF SOURCE OVER + SWAP DO I C@ 9 = IF 32 I C! THEN LOOP THEN
	  1 LOADLINE +!
	  \ Change tabs to space. 
	  \ flag from READ-LINE is returned (no success at EOF)
      ELSE
	  QUERY #TIB @ #SRC !  \ Always successful from terminal.
	  0 >IN ! -1
      THEN
  THEN
;


: INCLUDE-FILE ( fid --- ) 
\G Read lines from the file identified by fid and interpret them.
\G INCLUDE and EVALUATE nest in arbitrary order.
  INCLUDE-POINTER @ >R SID @ >R SRC @ >R #SRC @ >R >IN @ >R
  LOADLINE >R
  #SRC @ INCLUDE-POINTER +! INCLUDE-POINTER @ SRC !
  SID ! 0 LOADLINE !
  BEGIN
   REFILL
  WHILE
   INTERPRET
  REPEAT
  R> LOADLINE !
  R> >IN ! R> #SRC ! R> SRC ! R> SID ! R> INCLUDE-POINTER ! 
;

: INCLUDED  ( c-addr u ---- )
\G Open the file with name c-addr u and interpret all lines contained in it.
  R/O OPEN-FILE -38 ?THROW 
  DUP >R INCLUDE-FILE
  R> CLOSE-FILE DROP      
; 

: OK ( ---)
    CURFILENAME C@ 0= -38 ?THROW
    CURFILENAME ASCIIZ> INCLUDED ;
: FLOAD ( --- )
  OPEN OK ;

VARIABLE COLDSTARTUP ( --- addr)
-2 ALLOT-T
LABEL COLDSTARTADDR ENDASM
02 ALLOT-T
\ Set when system is started up.

: QUIT ( --- )
\G This word resets the return stack, resets the compiler state, the include
\G buffer and then it reads and interprets terminal input.
  R0 @ RP! [
  TIB SRC ! 0 SID !
  INCLUDE-BUFFER INCLUDE-POINTER !  
  BEGIN
      CURFILENAME C@ COLDSTARTUP @ AND COLDSTARTUP OFF IF
	  ['] OK \ Load any file on command line.
      ELSE
	  REFILL DROP ['] INTERPRET
      THEN CATCH DUP 0= IF
	  DROP STATE @ 0= IF ." OK" THEN CR
   ELSE \ throw occured.
     DUP -2 = IF
      ERROR$ @ COUNT TYPE SPACE
     ELSE
      ERRORS @
      BEGIN DUP WHILE
       OVER OVER @ = IF 4 + COUNT TYPE SPACE ERROR-SOURCE THEN CELL+ @
      REPEAT DROP
      ." Error " .
     THEN ERROR-SOURCE
   THEN
  0 UNTIL
;

:  WARM ( ---)
\G This word is called when an error occurs. Clears the stacks, sets
\G BASE to decimal, closes the files and resets the search order.
    R0 @ RP! S0 @ SP! DECIMAL
    9 1 DO I CLOSE-FILE DROP LOOP  
    2 #ORDER !
    FORTH-WORDLIST CONTEXT !
    FORTH-WORDLIST CONTEXT CELL+ !
    FORTH-WORDLIST CURRENT !
    0 HANDLER !
    QUIT ;

: F-STARTUP
\G This is the first colon definition called after a (cold) startup.    
    ." Agon 16-bit Z80 Forth v0.07, 2023-03-29 GPLv3" CR
    ." Copyright (C) 2023 L.C. Benschop, Brad Rodriguez" CR
    0 SYSVARS 5 0 D+ XC!
    WARM ;

CODE COLD ( --- )
    \G The first word that is called at the start of Forth.
    LD SP, $FF00
    LD S0ADDR (), SP
    LD IX, $FFF0
    LD R0ADDR (), IX
    LD DE, $FFFF
    LD COLDSTARTADDR (), DE
    LD DE, CURFILEADDR
    BEGIN
	LD .LIL A, (HL)
	INC .LIL HL
	CP $20             \ Skip spaces
    0<> UNTIL
    DEC .LIL HL
    BEGIN
	LD .LIL A, (HL)    \ Copy next parameter on command line to file buf.
	CP $21
	U>= WHILE
	    INC .LIL HL
	    LD (DE), A
	    INC DE
    REPEAT
    XOR A
    LD (DE), A
    A; $C3 C, F-STARTUP
END-CODE


END-CROSS

\ PART 15: FINISHING AND SAVING THE TARGET IMAGE.

\ Resolve the forward references created by the cross compiler.
RESOLVE DOCOL RESOLVE DOCON RESOLVE LIT RESOLVE BRANCH RESOLVE ?BRANCH
RESOLVE (DO) RESOLVE DOVAR RESOLVE DODOES RESOLVE UNNEST
RESOLVE (LOOP) RESOLVE (.")
RESOLVE COLD RESOLVE WARM RESOLVE F-STARTUP
RESOLVE THROW
RESOLVE (POSTPONE)

\ Store appropriate values into some of the new Forth's variables.
: CELLS>TARGET
  0 DO OVER I CELLS + @ OVER I CELLS-T + !-T LOOP 2DROP ;

#THREADS T' FORTH-WORDLIST >BODY-T 2 + !-T
TLINKS T' FORTH-WORDLIST >BODY-T 4 + #THREADS CELLS>TARGET
THERE   T' DP             >BODY-T !-T

CR .( Type the following command:)
CR IMAGE U.  THERE ORIGIN - U. .( BSAVE kernel80.bin)
CR
