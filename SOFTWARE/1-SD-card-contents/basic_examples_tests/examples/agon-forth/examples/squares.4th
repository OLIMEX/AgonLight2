\ Example forth source file

FORGET SQUARES

: SQUARES ( n --- )
    \ Print squares from 1 up to
    \ and including n
    1+ 1 DO
	CR I 6 .R I DUP UM* 11 D.R
        ?TERMINAL IF LEAVE THEN
    LOOP ;


    