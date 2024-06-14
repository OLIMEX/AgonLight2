\
\ tetris.4th	Tetris for terminals, redone in ANSI-Forth.
\		Written 05Apr94 by Dirk Uwe Zoller, e-mail:
\			duz@roxi.rz.fht-mannheim.de.
\		Look&feel stolen from Mike Taylor's "TETRIS FOR TERMINALS"
\
\		Please copy and share this program, modify it for your system
\		and improve it as you like. But don't remove this notice.
\
\		Thank you.
\
\		Changes:
\
\

ONLY FORTH DEFINITIONS
\ S" FORGET-TT" DROP 1 CHARS - FIND NIP [IF] FORGET-TT [THEN]
\ MARKER FORGET-TT

DECIMAL

WORDLIST CONSTANT TETRIS
GET-ORDER TETRIS DUP ROT 2 + SET-ORDER DEFINITIONS


\ Variables, constants

BL BL 2CONSTANT EMPTY		\ an empty position
VARIABLE WIPING			\ if true: wipe brick, else draw brick
2 CONSTANT COL0			\ position of the pit on screen
0 CONSTANT ROW0

10 CONSTANT WIDE		\ size of pit in brick positions
20 CONSTANT DEEP

CHAR J	VALUE LEFT-KEY		\ customize if you don't like them
CHAR K	VALUE ROT-KEY
CHAR L	VALUE RIGHT-KEY
BL	VALUE DROP-KEY
CHAR P	VALUE PAUSE-KEY
12	VALUE REFRESH-KEY
CHAR Q	VALUE QUIT-KEY

VARIABLE SCORE 
VARIABLE PIECES 
VARIABLE LEVELS 
VARIABLE DELAY 

VARIABLE BROW			\ where the brick is
VARIABLE BCOL


\ stupid random number generator

VARIABLE SEED

: RANDOMIZE	0 ." Press any key." CR BEGIN 1+ KEY? UNTIL KEY DROP SEED ! ;

: RANDOM	\ max --- n ; return random number < max
		SEED @ 1103515245 * 12345 + [ HEX ] 07FFF [ DECIMAL ] AND
		DUP SEED !  SWAP MOD ;


\ Access pairs of characters in memory:

: 2C@		DUP 1+ C@ SWAP C@ ;
: 2C!		DUP >R C! R> 1+ C! ;


: <=		> INVERT ;
: >=		< INVERT ;
: D<>		D= INVERT ;


\ Drawing primitives:

: 2EMIT		EMIT EMIT ;

: POSITION	\ row col --- ; cursor to the position in the pit
		2* COL0 + SWAP ROW0 + AT-XY ;

: STONE		\ c1 c2 --- ; draw or undraw these two characters
		WIPING @ IF  2DROP 2 SPACES  ELSE  2EMIT  THEN ;


\ Define the pit where bricks fall into:

: DEF-PIT	CREATE	WIDE DEEP * 2* ALLOT
		DOES>	ROT WIDE * ROT + 2* CHARS + ;

DEF-PIT PIT

: EMPTY-PIT	DEEP 0 DO WIDE 0 DO  EMPTY J I PIT 2C!
		LOOP LOOP ;


\ Displaying:

: DRAW-BOTTOM	\ --- ; redraw the bottom of the pit
		DEEP -1 POSITION
		[CHAR] + DUP STONE
		WIDE 0 DO  [CHAR] = DUP STONE  LOOP
		[CHAR] + DUP STONE ;

: DRAW-FRAME	\ --- ; draw the border of the pit
		DEEP 0 DO
		    I -1   POSITION [CHAR] | DUP STONE
		    I WIDE POSITION [CHAR] | DUP STONE
		LOOP  DRAW-BOTTOM ;

: BOTTOM-MSG	\ addr cnt --- ; output a message in the bottom of the pit
		DEEP OVER 2/ WIDE SWAP - 2/ POSITION TYPE ;

: DRAW-LINE	\ line ---
		DUP 0 POSITION  WIDE 0 DO  DUP I PIT 2C@ 2EMIT  LOOP  DROP ;

: DRAW-PIT	\ --- ; draw the contents of the pit
		DEEP 0 DO  I DRAW-LINE  LOOP ;

: SHOW-KEY	\ char --- ; visualization of that character
		DUP BL <
		IF  [CHAR] @ OR  [CHAR] ^ EMIT  EMIT  SPACE
		ELSE  [CHAR] ` EMIT  EMIT  [CHAR] ' EMIT
		THEN ;

: SHOW-HELP	\ --- ; display some explanations
		30  1 AT-XY ." ***** T E T R I S *****"
		30  2 AT-XY ." ======================="
		30  4 AT-XY ." Use keys:"
		32  5 AT-XY LEFT-KEY	SHOW-KEY ."  Move left"
		32  6 AT-XY ROT-KEY	SHOW-KEY ."  Rotate"
		32  7 AT-XY RIGHT-KEY	SHOW-KEY ."  Move right"
		32  8 AT-XY DROP-KEY	SHOW-KEY ."  Drop"
		32  9 AT-XY PAUSE-KEY	SHOW-KEY ."  Pause"
		32 10 AT-XY REFRESH-KEY	SHOW-KEY ."  Refresh"
		32 11 AT-XY QUIT-KEY	SHOW-KEY ."  Quit"
		32 13 AT-XY ." -> "
		30 16 AT-XY ." Score:"
		30 17 AT-XY ." Pieces:"
		30 18 AT-XY ." Levels:"
		 0 22 AT-XY ."  ======= This program was written 1994 in ANS Forth by Dirk Uwe Zoller ========"
		 0 23 AT-XY ."  =================== Copy it, port it, play it, enjoy it! =====================" ;

: UPDATE-SCORE	\ --- ; display current score
		38 16 AT-XY SCORE @ 3 .R
		38 17 AT-XY PIECES @ 3 .R
		38 18 AT-XY LEVELS @ 3 .R ;

: REFRESH	\ --- ; redraw everything on screen
		PAGE DRAW-FRAME DRAW-PIT SHOW-HELP UPDATE-SCORE ;


\ Define shapes of bricks:

: DEF-BRICK	CREATE	4 0 DO
			    ' EXECUTE  0 DO  DUP I CHARS + C@ C,  LOOP DROP
			    REFILL DROP
			LOOP
		DOES>	ROT 4 * ROT + 2* CHARS + ;

DEF-BRICK BRICK1	S"         "
			S" ######  "
			S"   ##    "
			S"         "

DEF-BRICK BRICK2	S"         "
			S" <><><><>"
			S"         "
			S"         "

DEF-BRICK BRICK3	S"         "
			S"   {}{}{}"
			S"   {}    "
			S"         "

DEF-BRICK BRICK4	S"         "
			S" ()()()  "
			S"     ()  "
			S"         "

DEF-BRICK BRICK5	S"         "
			S"   [][]  "
			S"   [][]  "
			S"         "

DEF-BRICK BRICK6	S"         "
			S" @@@@    "
			S"   @@@@  "
			S"         "

DEF-BRICK BRICK7	S"         "
			S"   %%%%  "
			S" %%%%    "
			S"         "

\ this brick is actually in use:

DEF-BRICK BRICK		S"         "
			S"         "
			S"         "
			S"         "

DEF-BRICK SCRATCH	S"         "
			S"         "
			S"         "
			S"         "

CREATE BRICKS	' BRICK1 ,  ' BRICK2 ,  ' BRICK3 ,  ' BRICK4 ,
		' BRICK5 ,  ' BRICK6 ,  ' BRICK7 ,

CREATE BRICK-VAL 1 C, 2 C, 3 C, 3 C, 4 C, 5 C, 5 C,


: IS-BRICK	\ brick --- ; activate a shape of brick
		>BODY ['] BRICK >BODY 32 CMOVE ;

: NEW-BRICK	\ --- ; select a new brick by random, count it
		1 PIECES +!  7 RANDOM
		BRICKS OVER CELLS + @ IS-BRICK
		BRICK-VAL SWAP CHARS + C@ SCORE +! ;

: ROTLEFT	4 0 DO 4 0 DO
		    J I BRICK 2C@  3 I - J SCRATCH 2C!
		LOOP LOOP
		['] SCRATCH IS-BRICK ;

: ROTRIGHT	4 0 DO 4 0 DO
		    J I BRICK 2C@  I 3 J - SCRATCH 2C!
		LOOP LOOP
		['] SCRATCH IS-BRICK ;

: DRAW-BRICK	\ row col ---
		4 0 DO 4 0 DO
		    J I BRICK 2C@  EMPTY D<>
		    IF  OVER J + OVER I +  POSITION
			J I BRICK 2C@  STONE
		    THEN
		LOOP LOOP  2DROP ;

: SHOW-BRICK	FALSE WIPING ! DRAW-BRICK ;
: HIDE-BRICK	TRUE  WIPING ! DRAW-BRICK ;

: PUT-BRICK	\ row col --- ; put the brick into the pit
		4 0 DO 4 0 DO
		    J I BRICK 2C@  EMPTY D<>
		    IF  OVER J +  OVER I +  PIT
			J I BRICK 2C@  ROT 2C!
		    THEN
		LOOP LOOP  2DROP ;

: REMOVE-BRICK	\ row col --- ; remove the brick from that position
		4 0 DO 4 0 DO
		    J I BRICK 2C@  EMPTY D<>
		    IF  OVER J + OVER I + PIT EMPTY ROT 2C!  THEN
		LOOP LOOP  2DROP ;

: TEST-BRICK	\ row col --- flag ; could the brick be there?
		4 0 DO 4 0 DO
		    J I BRICK 2C@ EMPTY D<>
		    IF  OVER J +  OVER I +
			OVER DUP 0< SWAP DEEP >= OR
			OVER DUP 0< SWAP WIDE >= OR
			2SWAP PIT 2C@  EMPTY D<>
			OR OR IF  UNLOOP UNLOOP 2DROP FALSE  EXIT  THEN
		    THEN
		LOOP LOOP  2DROP TRUE ;

: MOVE-BRICK	\ rows cols --- flag ; try to move the brick
		BROW @ BCOL @ REMOVE-BRICK
		SWAP BROW @ + SWAP BCOL @ + 2DUP TEST-BRICK
		IF  BROW @ BCOL @ HIDE-BRICK
		    2DUP BCOL ! BROW !  2DUP SHOW-BRICK PUT-BRICK  TRUE
		ELSE  2DROP BROW @ BCOL @ PUT-BRICK  FALSE
		THEN ;

: ROTATE-BRICK	\ flag --- flag ; left/right, success
		BROW @ BCOL @ REMOVE-BRICK
		DUP IF  ROTRIGHT  ELSE  ROTLEFT  THEN
		BROW @ BCOL @ TEST-BRICK
		OVER IF  ROTLEFT  ELSE  ROTRIGHT  THEN
		IF  BROW @ BCOL @ HIDE-BRICK
		    IF  ROTRIGHT  ELSE  ROTLEFT  THEN
		    BROW @ BCOL @ PUT-BRICK
		    BROW @ BCOL @ SHOW-BRICK  TRUE
		ELSE  DROP FALSE  THEN ;

: INSERT-BRICK	\ row col --- flag ; introduce a new brick
		2DUP TEST-BRICK
		IF  2DUP BCOL ! BROW !
		    2DUP PUT-BRICK  DRAW-BRICK  TRUE
		ELSE  2DROP FALSE  THEN ;

: DROP-BRICK	\ --- ; move brick down fast
		BEGIN  1 0 MOVE-BRICK 0=  UNTIL ;

: MOVE-LINE	\ from to ---
		OVER 0 PIT  OVER 0 PIT  WIDE 2*  CMOVE  DRAW-LINE
		DUP 0 PIT  WIDE 2*  BLANK  DRAW-LINE ;

: LINE-FULL	\ line-no --- flag
		TRUE  WIDE 0
		DO  OVER I PIT 2C@ EMPTY D=
		    IF  DROP FALSE  LEAVE  THEN
		LOOP NIP ;

: REMOVE-LINES	\ ---
		DEEP DEEP
		BEGIN
		    SWAP
		    BEGIN  1- DUP 0< IF  2DROP EXIT  THEN  DUP LINE-FULL
		    WHILE  1 LEVELS +!  10 SCORE +!  REPEAT
		    SWAP 1-
		    2DUP <> IF  2DUP MOVE-LINE  THEN
		AGAIN ;

: TO-UPPER	\ char --- char ; convert to upper case
		DUP [CHAR] a >= OVER [CHAR] z <= AND
		IF  [ CHAR A CHAR a - ] LITERAL +  THEN ;

: DISPATCH	\ key --- flag
		CASE  TO-UPPER
		    LEFT-KEY	OF  0 -1 MOVE-BRICK DROP  ENDOF
		    RIGHT-KEY	OF  0  1 MOVE-BRICK DROP  ENDOF
		    ROT-KEY	OF  0 ROTATE-BRICK DROP  ENDOF
		    DROP-KEY	OF  DROP-BRICK  ENDOF
		    PAUSE-KEY	OF  S"  Paused " BOTTOM-MSG  KEY DROP
				    DRAW-BOTTOM  ENDOF
		    REFRESH-KEY	OF  REFRESH  ENDOF
		    QUIT-KEY	OF  FALSE EXIT  ENDOF
		ENDCASE  TRUE ;

: INITIALIZE	\ --- ; prepare for playing
		RANDOMIZE EMPTY-PIT REFRESH
		0 SCORE !  0 PIECES !  0 LEVELS !  100 DELAY ! ;

: ADJUST-DELAY	\ --- ; make it faster with increasing score
		LEVELS @
		DUP  50 < IF  100 OVER -  ELSE
		DUP 100 < IF   62 OVER 4 / -  ELSE
		DUP 500 < IF   31 OVER 16 / -  ELSE  0  THEN THEN THEN
		DELAY !  DROP ;

: PLAY-GAME	\ --- ; play one tetris game
		BEGIN
		    NEW-BRICK
		    -1 3 INSERT-BRICK
		WHILE
		    BEGIN  4 0
			DO  35 13 AT-XY
			    DELAY @ MS KEY?
			    IF  BEGIN  KEY KEY? WHILE  DROP  REPEAT
				DISPATCH 0=
				IF  UNLOOP EXIT  THEN
			    THEN
			LOOP
			1 0 MOVE-BRICK  0=
		    UNTIL
		    REMOVE-LINES
		    UPDATE-SCORE
		    ADJUST-DELAY
		REPEAT ;

FORTH DEFINITIONS

: TT		\ --- ; play the tetris game
		INITIALIZE
		S"  Press any key " BOTTOM-MSG KEY DROP DRAW-BOTTOM
		BEGIN
		    PLAY-GAME
		    S"  Again? " BOTTOM-MSG KEY TO-UPPER [CHAR] Y =
		WHILE  INITIALIZE  REPEAT
		0 23 AT-XY CR ;

ONLY FORTH ALSO DEFINITIONS
