\ Graphics package for Agon Forth

FORGET HXS
DECIMAL

VARIABLE HXS VARIABLE HYS \ Half X size and half Y size of screen.
640 HXS ! 512 HYS !
: MODE ( n ---)
\G Select graphics mode
  22 EMIT DUP EMIT ;

: 2EMIT ( n ---)
\G Emit n as two characters, LSB first.
  DUP 8 RSHIFT SWAP EMIT EMIT ;

: PLOT ( x y mode ---)
\G Perform the VDU plot command.
  25 EMIT EMIT SWAP 2EMIT 2EMIT ;


: MOVETO ( x y ---)
\G Move the graphics position.
  4 PLOT ;

: LINETO ( x y ---)
\G Draw a line to the given position.
  5 PLOT ;

 0 CONSTANT BLACK
 1 CONSTANT RED
 2 CONSTANT GREEN
 3 CONSTANT YELLOW
 4 CONSTANT BLUE
 5 CONSTANT MAGENTA
 6 CONSTANT CYAN
 7 CONSTANT LIGHT-GREY 7 CONSTANT LIGHT-GRAY
 8 CONSTANT DARK-GREY 8 CONSTANT DARK-GRAY
 9 CONSTANT BRIGHT-RED
10 CONSTANT BRIGHT-GREEN
11 CONSTANT BRIGHT-YELLOW
12 CONSTANT BRIGHT-BLUE
13 CONSTANT BRIGHT-MAGENTA
14 CONSTANT BRIGHT-CYAN
15 CONSTANT WHITE


: FG ( c ---)
  17 EMIT EMIT ;
: BG ( c ---)
  17 EMIT 128 + EMIT ;
: GC ( c ---)
  18 EMIT 0 EMIT EMIT ;

CREATE SINTAB
\ Table of fixed-point sine values (scaled to 16384)
    0 ,   286 ,   572 ,   857 ,  1143 , 
 1428 ,  1713 ,  1997 ,  2280 ,  2563 , 
 2845 ,  3126 ,  3406 ,  3686 ,  3964 , 
 4240 ,  4516 ,  4790 ,  5063 ,  5334 , 
 5604 ,  5872 ,  6138 ,  6402 ,  6664 , 
 6924 ,  7182 ,  7438 ,  7692 ,  7943 , 
 8192 ,  8438 ,  8682 ,  8923 ,  9162 , 
 9397 ,  9630 ,  9860 , 10087 , 10311 , 
10531 , 10749 , 10963 , 11174 , 11381 , 
11585 , 11786 , 11982 , 12176 , 12365 , 
12551 , 12733 , 12911 , 13085 , 13255 , 
13421 , 13583 , 13741 , 13894 , 14044 , 
14189 , 14330 , 14466 , 14598 , 14726 , 
14849 , 14968 , 15082 , 15191 , 15296 , 
15396 , 15491 , 15582 , 15668 , 15749 , 
15826 , 15897 , 15964 , 16026 , 16083 , 
16135 , 16182 , 16225 , 16262 , 16294 , 
16322 , 16344 , 16362 , 16374 , 16382 , 
16384 ,

: SIN ( n1 --- n2)
\G Compute scaled sine of an angle in degrees.
  S>D 360 FM/MOD DROP \ Modulo 360
  DUP 90 < IF 
      CELLS SINTAB + @
  ELSE DUP 180 < IF
      180 SWAP - CELLS SINTAB + @
  ELSE DUP 270 < IF
      180 - CELLS SINTAB + @ NEGATE
  ELSE 360 SWAP - CELLS SINTAB + @ NEGATE
  THEN THEN THEN
 ;


: COS ( n1 --- n2)
\G Compute scaled cosine of an angle in degrees.
  90 SWAP - SIN ;


: SCALE14 ( d1 --- n3 n4)
\G Divided d1 by 2**14 and give result in n3, remainder in n4
  2 LSHIFT OVER 14 RSHIFT + 
  SWAP 16383 AND ;


VARIABLE PEN-STATE

VARIABLE POSX VARIABLE ERRX
VARIABLE POSY VARIABLE ERRY

: PEN-UP 4 PEN-STATE ! ;
: PEN-DOWN 5 PEN-STATE ! ;

\G Turtle graphics use scaled and translated coordinates.
\G 1 screen pixel corresponds to 8 turtle steps. For example 80 FORWARD
\G will move a distance of 10 screen pixels.
\G The origin is in the centre of the screen and the positive Y direction is
\G UP. 

: COORD-TRANSLATE ( x1 y1 --- x2 y2)
\G Translate turtle coordinates (0,0) at the centre, positive Y moves up,
\G to VDP coordinates (0,0) at left top, positive Y moves down.
\G also the turtle coordinates are 8x the pixel coordinates.
  2/ 2/ HYS @ SWAP + SWAP 2/ 2/ HXS @ + SWAP ;

: SETPOS ( x y ---)
\G Set the turtle position to the given turtle coordinates.
  POSY ! POSX ! 0 ERRX ! 0 ERRY !
  POSX @ POSY @ COORD-TRANSLATE 4 PLOT ;


: DRAWTO ( x y ---)
\G Draw to the given turtle coorinates (if pen is down).
  POSY ! POSX ! 0 ERRX ! 0 ERRY !
  POSX @ POSy @ COORD-TRANSLATE PEN-STATE @ PLOT ;

VARIABLE HEADING 
: SETHEADING ( angle ---)
\G Set the heading of the turtle. 0 faces to right, positive degrees 
\G counter-clockwise.
  S>D 360 FM/MOD DROP HEADING ! ;

: HOME
\G Set the turtle in the home position.
  0 0 SETPOS 0 SETHEADING PEN-DOWN ;


: LEFT ( angle ---) 
\G Turn turtle to the left.
  HEADING @ + SETHEADING ;
: RIGHT ( angle ---)
\G Turn turtle to the right.
  NEGATE LEFT ;

: FORWARD ( dist ---)
\G move turtle forward 
  DUP HEADING @ COS M* ERRX @ 0 D+ SCALE14 ERRX ! POSX +!
      HEADING @ SIN M* ERRY @ 0 D+ SCALE14 ERRY ! POSY +!
      POSX @ POSY @ COORD-TRANSLATE PEN-STATE @ PLOT ;

: BACKWARD ( dist ---)
\G move turtle backward.
  NEGATE FORWARD ;

: LT LEFT ;
: RT RIGHT ;
: FD FORWARD ;
: BK BACKWARD ;
: PU PEN-UP ;
: PD PEN-DOWN ;

VARIABLE SEED 
SYSVARS XC@ SEED !

: RAND ( n1 --- n2)
\G A simple random generator return a number in range 0..n2-1
  SEED @ 3533 * 433 + DUP SEED ! UM* NIP ;

: CUROFF ( ---)
\G Switch cursor off
  23 EMIT 1 EMIT 0 EMIT ;

: CURON ( ---)
\G Switch cursor on
  23 EMIT 1 EMIT 1 EMIT ;

 
