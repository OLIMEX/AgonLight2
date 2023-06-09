   10 CX% = 640 - 240
   15 CY% = 512 + 120
   20 R% = 300
   30 DX% = 50
   35 DY% = 50
   40 RED% = 1
   42 GREEN% = 2
   44 YELLOW% = 3
   46 BLUE% = 4
   50 WHITE% = 0
   60 MAXLEVEL% = 255
   70 :
   80 REM (Pseudo)random sequence of tiles
   90 DIM GENMOVES%(MAXLEVEL%)
  100 :
  110 REM Sounds when pressing a tile
  120 DIM FREQ%(4)
  130 FREQ%(RED%) = 141 : FREQ%(GREEN%) = 117 : FREQ%(YELLOW%) = 153 : FREQ%(BLUE%) = 165
  140 :
  150 REPEAT
  155   MODE 3
  157   VDU 23, 1, 0
  160   GCOL 0, 15
  170   GCOL 0, 136
  180   CLS
  190   CLG
  200   :
  210   REM Draw a circle around 4 colored tiles
  220   MOVE CX%, CY%
  230   PLOT &95, 700, 700
  240   :
  250   REM Draw the 4 colored tiles
  260   PROC_drawTile(RED%, FALSE)
  270   PROC_drawTile(GREEN%, FALSE)
  280   PROC_drawTile(YELLOW%, FALSE)
  290   PROC_drawTile(BLUE%, FALSE)
  300   :
  310   REM Draw the command menu and waits for user input
  320   COLOUR 3
  330   COLOUR 128
  340   PRINT TAB(50,6)"S|s - Start a new game"
  350   PRINT TAB(50,7)"Q|q - Quit"
  360   :
  370   key$ = GET$
  380   IF key$ = "S" OR key$ = "s" PROC_newGame(1)
  390 UNTIL (key$ = "Q") OR (key$ = "q")
  400 :
  401 MODE 3
  402 CLG
  403 CLS
  410 END
  420 :
  430 :
  440 REM Play a new game, starting from level 1
  450 DEF PROC_newGame(LVL%)
  460 :
  470 PROC_drawTile(RED%, FALSE)
  480 PROC_drawTile(GREEN%, FALSE)
  490 PROC_drawTile(YELLOW%, FALSE)
  500 PROC_drawTile(BLUE%, FALSE)
  510 COLOUR 3
  520 COLOUR 128
  530 PRINT TAB(50,6)"R|r - Tap the red tile"
  540 PRINT TAB(50,7)"G|g - Tap the green tile"
  550 PRINT TAB(50,8)"Y|y - Tap the yellow tile"
  560 PRINT TAB(50,9)"B|b - Tap the blue tile"
  570 PRINT TAB(50,10)"C|c - Cancel current game"
  580 :
  590 FOR I% = 1 TO MAXLEVEL%
  600   GENMOVES%(I%) = RND(4)
  610 NEXT
  620 :
  630 currLevel% = 1
  640 done = FALSE
  650 REPEAT
  660   res% = FN_PlayOneLevel(currLevel%)
  670   IF res% = -1 THEN done = TRUE : GOTO 840
  680   IF res% > 0 THEN PRINT TAB(50,16)"Wrong tile!" : PRINT TAB(50,17)"Press any key." : key$ = GET$ : done = TRUE : GOTO 840
  690   IF res% = 0 THEN currLevel% = currLevel% + 1
  710   IF currLevel% > MAXLEVEL% THEN PRINT TAB(50,16)"Game completed successfully!" : PRINT TAB(50,17)"Press any key." : key$ = GET$ : done = TRUE
  840 UNTIL done
  850 :
  860 ENDPROC
  870 :
  880 :
  890 REM Play a single game level
  900 REM The number of tiles the user has to replay is provided as a parameter
  910 REM Return values:
  920 REM  -1 -> the user has cancelled the game
  930 REM   0 -> the user successfully completed the level by replaying the correct sequence of tiles
  940 REM  >0 -> the user made a wrong guess
  950 DEF FN_PlayOneLevel(LVL%)
  960 LOCAL return%
  980 currMove% = 0
  990 :
 1000 PRINT TAB(50,13)"Current level: ";LVL%;" of ";MAXLEVEL%
 1005 PRINT TAB(50,14)"Taps remaining: ";LVL%;"   "
 1010 :
 1020 PROC_delay(100)
 1030 FOR I% = 1 TO LVL%
 1035   move% = GENMOVES%(I%)
 1040   PROC_pressTile(move%)
 1050 NEXT
 1060 :
 1070 REPEAT
 1080   currTile% = 0
 1090   key$ = GET$
 1100   IF key$ = "R" OR key$ = "r" currTile% = RED% : GOTO 1150
 1110   IF key$ = "G" OR key$ = "g" currTile% = GREEN% : GOTO 1150
 1120   IF key$ = "Y" OR key$ = "y" currTile% = YELLOW% : GOTO 1150
 1130   IF key$ = "B" OR key$ = "b" currTile% = BLUE% : GOTO 1150
 1140   IF key$ = "C" OR key$ = "c" return% = -1 : GOTO 1150
 1150   IF currTile% = 0 GOTO 1300
 1160   PROC_pressTile(currTile%)
 1170   currMove% = currMove% + 1
 1180   PRINT TAB(50,14)"Taps remaining: ";LVL%-currMove%;"   "
 1200   IF GENMOVES%(currMove%) <> currTile% GOTO 1260
 1210   IF currMove% <> LVL% GOTO 1300
 1220   return% = 0
 1230   key$ = "c"
 1240   GOTO 1300
 1260   return% = currMove%
 1270   key$ = "c"
 1300 UNTIL (key$ = "C") OR (key$ = "c")
 1310 =return%
 1320 :
 1330 REM Draw a filled triangle given its 3 vertices and fill color
 1340 DEF PROC_drawTriangle(P1X%, P1Y%, P2X%, P2Y%, P3X%, P3Y%, COL%)
 1350 GCOL 0, COL%
 1360 MOVE P1X%, P1Y%
 1370 MOVE P2X%, P2Y%
 1380 PLOT &55, P3X%, P3Y%
 1390 ENDPROC
 1400 :
 1410 REM Draw a single colored tile
 1420 DEF PROC_drawTile(TILE%, PRESSED%)
 1430 COL% = TILE% + 8
 1440 IF PRESSED% THEN COL% = WHITE%
 1450 IF TILE% = RED% PROC_drawTriangle(CX%+DX%/2, CY%+DY%/2, CX%+R%-DX%/2, CY%+DY%/2, CX%+DX%/2, CY%+R%-DY%/2, COL%) : PROC_drawTriangle(CX%, CY%, CX%+R%/3, CY%, CX%, CY%+R%/3, WHITE%) : GOTO 1650
 1500 IF TILE% = GREEN% PROC_drawTriangle(CX%-DX%/2, CY%+DY%/2, CX%-R%+DX%/2, CY%+DY%/2, CX%-DX%/2, CY%+R%-DY%/2, COL%) : PROC_drawTriangle(CX%, CY%, CX%-R%/3, CY%, CX%, CY%+R%/3, WHITE%) : GOTO 1650
 1550 IF TILE% = YELLOW% PROC_drawTriangle(CX%-DX%/2, CY%-DY%/2, CX%-R%+DX%/2, CY%-DY%/2, CX%-DX%/2, CY%-R%+DY%/2, COL%) : PROC_drawTriangle(CX%, CY%, CX%-R%/3, CY%, CX%, CY%-R%/3, WHITE%) : GOTO 1650
 1600 IF TILE% = BLUE% PROC_drawTriangle(CX%+DX%/2, CY%-DY%/2, CX%+R%-DX%/2, CY%-DY%/2, CX%+DX%/2, CY%-R%+DY%/2, COL%) : PROC_drawTriangle(CX%, CY%, CX%+R%/3, CY%, CX%, CY%-R%/3, WHITE%) : GOTO 1650
 1650 ENDPROC
 1660 :
 1670 REM Press a given tile
 1680 DEF PROC_pressTile(TILE%)
 1690 PROC_drawTile(TILE%, TRUE)
 1700 PROC_delay(25)
 1710 SOUND 1, -15, FREQ%(TILE%), 5
 1720 PROC_drawTile(TILE%, FALSE)
 1730 PROC_delay(25)
 1740 ENDPROC
 1750 :
 1760 DEF PROC_delay(T%)
 1770 FOR N=1 TO 200*T%:NEXT
 1780 ENDPROC
