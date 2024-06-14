   10 COLOUR 15
   20 MODE 3
   21 CLS
   30 DIM Moves%(100)
   40 PRINT "Agon says for olimex contest 2023"
   50 PRINT "By S.Schneider"
   60 PROC_DrawGame
   61 PROC_Wait(180)
   70 PROC_Init
   71 COLOUR 1,16
   72 COLOUR 2,4
   73 COLOUR 3,20
   74 COLOUR 4,1
   75 PRINT ""
   76 PRINT "Press any key to start."
   77 I%=GET
   80 FOR Limit%=0 TO 99
   81   IF Limit% > 0 AND Limit% MOD 5=0 THEN PRINT "Yeah, you scored ";Limit%;" already!"
   90   FOR Move%=0 TO Limit%
  110     Current% = Moves%(Move%)
  120     PROC_ShowDirection(Current%)
  140   NEXT Move%
  150   FOR Move%=0 TO Limit%
  160     I% = GET
  180     Current% = Moves%(Move%)
  190     IF I%=8 THEN DIR%=1
  200     IF I%=21 THEN DIR%=2
  210     IF I%=10 THEN DIR%=3
  220     IF I%=11 THEN DIR%=4
  230     IF DIR% = Current% THEN PROC_ShowDirection(DIR%) ELSE PROC_Lose(Limit%) : GOTO 70
  240   NEXT Move%
  250   PROC_Wait(30)
  270 NEXT Limit%
  280 END
  290 DEF PROC_Init
  300 FOR Move%=0 TO 99
  310   Moves%(Move%) = RND(4)
  320 NEXT Move%
  330 ENDPROC
  340 DEF PROC_ShowDirection(Dir%)
  350 REM COLOUR Dir%+8
  360 SOUND 1,-5,60*Dir%,10
  371 IF Dir% = 1 THEN COLOUR 1,32
  372 IF Dir% = 2 THEN COLOUR 2,12
  373 IF Dir% = 3 THEN COLOUR 3,56
  374 IF Dir% = 4 THEN COLOUR 4,3
  410 PROC_Wait(30)
  421 IF Dir% = 1 THEN COLOUR 1,16
  422 IF Dir% = 2 THEN COLOUR 2,4
  423 IF Dir% = 3 THEN COLOUR 3,20
  424 IF Dir% = 4 THEN COLOUR 4,1
  425 PROC_Wait(30)
  430 ENDPROC
  440 DEF PROC_Wait(Frames%)
  450 FOR I=0 TO Frames%
  460   *FX 19
  470 NEXT I
  480 ENDPROC
  490 DEF PROC_Lose(Score%)
  500 SOUND 1,-5,40,5
  510 SOUND 1,-5,20,10
  520 PRINT "Sorry you lose. But you scored: ";Score%;" Press any key to restart."
  530 I% = GET
  550 ENDPROC
  560 DEF PROC_DrawGame
  580 REM LEFT
  620 GCOL 0,1
  630 X=640-150
  640 D=100
  650 Y=480-25
  660 FOR I=0 TO 50
  670   MOVE X,Y+I
  680   PLOT 5, X+D, Y+I
  690 NEXT I
  700 Y=480
  710 MOVE X,Y+52
  720 MOVE X,Y-50
  730 PLOT 85,X-50,Y
  740 REM RIGHT
  750 GCOL 0,2
  760 X=640+50
  770 D=100
  780 Y=480-25
  790 FOR I=0 TO 50
  800   MOVE X,Y+I
  810   PLOT 5, X+D, Y+I
  820 NEXT I
  830 X=X+D
  840 Y=480
  850 MOVE X,Y+52
  860 MOVE X,Y-50
  870 PLOT 85,X+50,Y
  880 REM DOWN
  890 GCOL 0,3
  900 X=640-25
  910 D=100
  920 Y=480-50
  930 FOR I=0 TO 50
  940   MOVE X+I,Y
  950   PLOT 5, X+I, Y-D
  960 NEXT I
  970 X=X+25
  980 Y=Y-D
  990 MOVE X+52,Y
 1000 MOVE X-50,Y
 1010 PLOT 85,X,Y-50
 1020 REM UP
 1030 GCOL 0,4
 1040 X=640-25
 1050 D=100
 1060 Y=480+50
 1070 FOR I=0 TO 50
 1080   MOVE X+I,Y
 1090   PLOT 5, X+I, Y+D
 1100 NEXT I
 1110 X=X+25
 1120 Y=Y+D
 1130 MOVE X+52,Y
 1140 MOVE X-50,Y
 1150 PLOT 85,X,Y+50
 1160 ENDPROC
