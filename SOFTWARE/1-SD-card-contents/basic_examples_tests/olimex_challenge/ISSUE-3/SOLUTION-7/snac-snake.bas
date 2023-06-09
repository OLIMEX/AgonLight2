10000 REM :::::::::::::::::::::::::::::::::::::::::::::
10010 REM :: SNAC-SNAKE FOR AgonLight (BBC BASIC v3) ::
10020 REM :::::::::::::::::::::::::::::::::::::::::::::
10030 REM :: by https://github.com/tonedef71 for     ::
10040 REM :: Olimex Weekend Programming Challenge    ::
10050 REM :: Issue #3                                ::
10060 REM :::::::::::::::::::::::::::::::::::::::::::::
10070 REM :: Best experienced on 40+ column, 16+     ::
10080 REM :: color display                           ::
10090 REM :::::::::::::::::::::::::::::::::::::::::::::
10100 CLEAR
10110 REPEAT CLS:MO$=FN_PROMPT(0,0,"MODE (1,2,3,...):","2"):UNTIL VAL(MO$) > 0:MODE VAL(MO$)
10120 REPEAT CLS:KY$=FN_PROMPT(0,0,"TARGET (A)gon or (B)BC B-SDL:","A"):UNTIL ((FN_TO_UPPER(KY$) = "A" OR FN_TO_UPPER(KY$) = "B"))
10130 IF KY$ = "B" THEN LEFT = 136:RIGHT = 137:DOWN = 138:UP = 139:DL% = 2:ELSE LEFT = 8:RIGHT = 21:DOWN = 10:UP = 11:DL% = 6
10140 PROC_SETUP
10150 :
10160 PROC_WELCOME
10170 PROC_NEW_GAME
10180 PROC_MAIN_LOOP:REM Invoke main loop
10190 PROC_DEATH_ANIMATION(X(P), Y(P)):VDU 17,YELLOW:PROC_CENTER_TEXT("G A M E  O V E R"):
10200 R$ = FN_PLAY_AGAIN:IF R$ = "Y" THEN 10170:ELSE PROC_GOODBYE
10210 END
10220 :
10230 REM ::::::::::::::::::::
10240 REM ::   Setup Game   ::
10250 REM ::::::::::::::::::::
10260 DEF PROC_SETUP
10270 BLACK = 0:RED = 1:GREEN = 2:YELLOW = 3:BLUE = 4:MAGENTA = 5:CYAN = 6:WHITE = 7
10280 BLANK = 32:DOT = 46
10290 MON_WHITE = 134:MON_BLUE = 135:MON_RED = 136:MON_PINK = 137:MON_CYAN = 138:MON_GREEN = 139
10300 E_HEART = 129:E_DIAMOND = 130:E_FRUIT = 131:E_CIRC = 132:E_DISC = 133
10310 B_VERT = 140:B_HORZ = 141:B_UR = 142:B_UL = 143:B_DL = 144:B_DR = 145
10320 SN_W = 128:SN_L = 123:SN_R = 124:SN_D = 125:SN_U = 126
10330 SN_D1 = 150:SN_D2 = 151:SN_D3 = 152:SN_D4 = 153:SN_D5 = 154:SN_D6 = 155
10340 PROC_DEFAULT_COLORS
10350 PROC_REDEFINE_CHARS
10360 TK = TIME:PROC_SLEEP(100):TK = TIME - TK:REM CALIBRATE TIME TICKS
10370 CW%=40:CH%=20:UX%=1:UY%=1:LX%=CW% - 2:LY%=CH% - 2:REM Playing Field Boundaries
10380 UB% = (LX% - UX%) + (LY% - UY%) * LX%
10390 MAX_SIZE% = 99:REM Maximum Size of Snake
10400 MAX_MONSTERS% = 4:REM Maximum Number Of Monsters
10410 DIM X(MAX_SIZE%),Y(MAX_SIZE%),MP%(MAX_MONSTERS%),MT%(UB%)
10420 ENDPROC
10430 :
10440 REM ::::::::::::::::::::::
10450 REM ::     New Game     ::
10460 REM ::::::::::::::::::::::
10470 DEF PROC_NEW_GAME
10480 LOCAL i%
10490 TI = 0:TIME = 0:Dead% = FALSE:Score% = 0:Size% = 2
10500 P = 1:REM Index Of Initial Position Of Snake's Head
10510 AF = 0:REM Initial Animation Frame For Snake's Head
10520 X(1) = CW% DIV 2:Y(1) = CH% DIV 2:X(0) = X(1):Y(0) = Y(1) - 1:REM Snake Starting Position
10530 D% = 3:REM Initial Direction For Snake (down)
10540 SP% = 14:REM Speed Throttler (smaller value speeds up the game)
10550 Monster_State% = 0:REM Monster State
10560 M_Position% = 0:REM Monster Position Index
10570 Portal_State% = 0:REM Portal State
10580 M_Count% = 0:REM Number Of Active Monsters
10590 Rvs_Dir% = FALSE:REM Reverse Direction Flag
10600 FOR i% = 0 TO UB%:MT%(i%) = BLANK:NEXT i%
10610 FOR i% = 0 TO MAX_MONSTERS%:MP%(i%)=-1:NEXT i%
10620 CLS
10630 PROC_HIDE_CURSOR
10640 PROC_DRAW_BOUNDARY
10650 VDU 17,YELLOW:PROC_CENTER_TEXT("GET READY!"):REM Display GET READY Message
10660 PROC_SLEEP(200):PROC_CENTER_TEXT(STRING$(10, " ")):REM Erase GET READY Message after 2 Seconds
10670 PROC_DRAW(X(0),Y(0),SN_W, TRUE):PROC_DRAW(X(1),Y(1),SN_W, TRUE):REM Draw Snake at Initial Position
10680 PROC_EMPTY_KEYBOARD_BUFFER
10690 ENDPROC
10700 :
10710 REM ::::::::::::::::::::::
10720 REM ::     Main Loop    ::
10730 REM ::::::::::::::::::::::
10740 DEF PROC_MAIN_LOOP
10750 LOCAL dd%,i%
10760 REPEAT
10770   TI = TIME
10780   IF TI MOD 272 = 0 THEN PROC_UPDATE_PORTAL_STATE
10790   IF TI MOD 212 = 0 THEN SP% = FN_MAX(6, SP% - Size%):REM FN_MAX(6, SP% - 2)
10800   dd% = FN_MAP_INPUT(INKEY(DL%)):IF dd% > 0 THEN Rvs_Dir% = FN_CHECK_FOR_REVERSE_DIRECTION(D%, dd%):D% = dd%
10810   PROC_COUT("SCORE "+STR$(Score%), 0):REM PROC_COUT(STR$(X(P))+","+STR$(Y(P))+" ")
10820   PROC_GROW_SNAKE(D%)
10830   PROC_RANDOM_EVENT
10840   PROC_SLEEP(TI + SP% - TIME):REM Throttle Speed (e.g. TI + SP% - TIME)
10850 UNTIL Dead%
10860 ENDPROC
10870 :
10880 REM :::::::::::::::::::::::::
10890 REM :: Prompt For Response ::
10900 REM :::::::::::::::::::::::::
10910 DEF FN_PROMPT(x%, y%, text$, default$)
10920 LOCAL r$
10930 PRINT TAB(x%, y%)text$;" ";default$:PRINT TAB(x% + LEN(text$) + 1, y%);
10940 r$ = GET$:r$ = FN_TO_UPPER(r$):IF r$ = CHR$(13) THEN r$ = default$
10950 = r$
10960 :
10970 REM ::::::::::::::::::::::
10980 REM ::   To Uppercase   ::
10990 REM ::::::::::::::::::::::
11000 DEF FN_TO_UPPER(ch$):LOCAL ch%:ch% = ASC(ch$):ch$ = CHR$(ch% + 32 * (ch% >= 97 AND ch% <= 122)):=ch$
11010 :
11020 REM :::::::::::::::::::::::
11030 REM :: Play Another Game ::
11040 REM :::::::::::::::::::::::
11050 DEF FN_PLAY_AGAIN
11060 LOCAL message$,r$
11070 message$ = "Play Again?(Y/N)":PROC_EMPTY_KEYBOARD_BUFFER
11080 REPEAT r$ = FN_PROMPT((CW% - LEN(message$)) DIV 2, CH% DIV 2 + 2, message$, "") UNTIL INSTR("YN", r$) <> 0
11090 = r$
11100 :
11110 REM :::::::::::::::::
11120 REM :: Say Goodbye ::
11130 REM :::::::::::::::::
11140 DEF PROC_GOODBYE
11150 LOCAL game$
11160 PROC_HIDE_CURSOR
11170 CLS:PROC_CENTER_TEXT("So long and thank you for playing..."):game$="SNAC-SNAKE"
11180 FOR i% = 1 TO (CW% - LEN(game$)) DIV 2:PRINTTAB(0,CH% DIV 2 + 2)STRING$(i%," ")CHR$(17)CHR$(i%)game$:PROC_SLEEP(20):NEXT i%
11190 PROC_DEFAULT_COLORS
11200 PROC_SHOW_CURSOR
11210 ENDPROC
11220 :
11230 REM ::::::::::::::::::::::::::::
11240 REM :: Restore Default Colors ::
11250 REM ::::::::::::::::::::::::::::
11260 DEF PROC_DEFAULT_COLORS
11270 COLOUR 128+BLACK:COLOUR WHITE
11280 ENDPROC
11290 :
11300 REM :::::::::::::::::::::::::::
11310 REM :: Empty Keyboard Buffer ::
11320 REM :::::::::::::::::::::::::::
11330 DEF PROC_EMPTY_KEYBOARD_BUFFER:REPEAT UNTIL INKEY(0) = -1:ENDPROC
11340 :
11350 DEF PROC_HIDE_CURSOR:VDU 23,1,0;0;0;0;:ENDPROC
11360 DEF PROC_SHOW_CURSOR:VDU 23,1,1;0;0;0;:ENDPROC
11370 DEF PROC_CENTER_TEXT(text$):VDU 31,(CW% - LEN(text$)) DIV 2, CH% DIV 2:PRINT text$;:ENDPROC
11380 DEF PROC_ERASE(x%, y%):VDU 31,x%,y%,17,BLACK,BLANK:ENDPROC
11390 DEF PROC_SLEEP(hundredth_seconds%):LOCAL t:t = TIME:REPEAT UNTIL ((TIME - t) > hundredth_seconds%):ENDPROC
11400 DEF PROC_COUT(text$, row%):VDU 31,0,CH%+row%,17,WHITE:PRINT text$:ENDPROC
11410 DEF FN_X_DELTA(d%):=(d% = 1) + (d% = 2)*-1 + (d% = 3)*0 + (d% = 4)*0
11420 DEF FN_Y_DELTA(d%):=(d% = 1)*0 + (d% = 2)*0 + (d% = 3)*-1 + (d% = 4)
11430 DEF FN_MAX(x, y):= y + (x > y) * (y - x)
11440 DEF FN_MIN(x, y):= y + (x < y) * (y - x)
11450 DEF FN_MAP_INPUT(n%):=(n% = LEFT)*-1 + (n% = RIGHT)*-2 + (n% = DOWN)*-3 + (n% = UP)*-4
11460 DEF FN_NEXT_POS(i%):=(i% + 1) MOD MAX_SIZE%
11470 DEF FN_NEXT_MONSTER(i%):=(i% + 1) MOD MAX_MONSTERS%
11480 DEF FN_PAUSED(n):=NOT((TIME - TI) > n):REM Attempt To Determine If Game Should Throttle Down
11490 DEF FN_HASH(x%, y%):=(x% - 1) + (y% - 1) * LX%
11500 DEF FN_RND_PCT(n%):=RND(1) > (n% / 100):REM Returns TRUE or FALSE
11510 DEF FN_RND_INT(lo%, hi%):=INT(RND(1) * (hi% - lo%)) + lo%
11520 DEF FN_RND_EDIBLE:LOCAL r%:r% = FN_RND_INT(1, 5):= (r% < 4)*-(E_HEART + r% - 1) + (r% > 3)*-(E_CIRC + r% - 4)
11530 DEF FN_RND_X:=FN_RND_INT(UX%, LX%):REM 1 - 38
11540 DEF FN_RND_Y:=FN_RND_INT(UY%, LY%):REM 1 - 23
11550 DEF FN_GETXY(x%, y%):VDU 23,0,&83, x%; y%;:= &83
11560 :
11570 DEF PROC_DRAW(x%, y%, c%, overwrite%)
11580 LOCAL f$
11590 f$ = GET$(x%, y%):REM Is Position Currently Unoccupied?
11600 IF (f$ = CHR$(BLANK) OR overwrite%) THEN VDU 31,x%,y%,17,FN_COLOR_MAP(c%),c%
11610 ENDPROC
11620 :
11630 REM ::::::::::::::::::::::::::::::::
11640 REM ::       Clockwise Beam       ::
11650 REM ::::::::::::::::::::::::::::::::
11660 DEF PROC_CLOCKWISE_BEAM(cc%, color%, char%)
11670 LOCAL cx%, cy%, a%, b%, c%
11680 a% = CW% + CH% - 2:b% = a% + CW%:c% = b% + CH% - 2
11690 cx% = (cc% < CW%) * -cc% + (cc% > (CW% - 1) AND cc% < a%) * -(CW% - 1)
11700 cx% = cx% + (cc% >= a% AND cc% < b%) * (cc% - (b% - 1)) + (cc% >= b%) * 0
11710 cy% = (cc% < CW%) * 0 + (cc% > (CW% - 1) AND cc% < a%) * -(cc% - (CW% - 1))
11720 cy% = cy% + (cc% >= a% AND cc% < b%) * -(CH% - 1) + (cc% >= b%) * -((CH% - 2) - (cc% - b%))
11730 VDU 31,cx%,cy%,17,color%,char%
11740 ENDPROC
11750 :
11760 REM ::::::::::::::::::
11770 REM ::  Frame Wait  ::
11780 REM ::::::::::::::::::
11790 DEF PROC_WAIT(frames%)
11800 LOCAL i%
11810 FOR i% = 1 TO frames%
11820   *FX 19
11830 NEXT i%
11840 ENDPROC
11850 :
11860 REM ::::::::::::::::::::
11870 REM ::  Random Event  ::
11880 REM ::::::::::::::::::::
11890 DEF PROC_RANDOM_EVENT
11900 LOCAL c%,f%,r,rx%,ry%
11910 r = RND(1):IF r < .90 THEN 11980:REM NO NEW OBSTACLE
11920 r = RND(1)
11930 c% = (r >= 0 AND r < .65)*-DOT + (r >= .65 AND r < .8)*-FN_RND_EDIBLE + (r >= .8 AND r < 1)*-(MON_RED + (M_Position% MOD 4))
11940 rx% = FN_RND_X:ry% = FN_RND_Y:REM Determine Random Position
11950 f% = (GET$(rx%, ry%) = CHR$(BLANK))
11960 IF (f% AND c% >= MON_RED AND c% <= MON_GREEN) THEN PROC_MANAGE_MONSTER(c%, rx%, ry%, TRUE):GOTO 11980
11970 PROC_DRAW(rx%, ry%, c%, FALSE):PROC_SOUND(3.5, 2)
11980 ENDPROC
11990 :
12000 REM :::::::::::::::::::::::::
12010 REM ::  Map Char To Color  ::
12020 REM :::::::::::::::::::::::::
12030 DEF FN_COLOR_MAP(c%)
12040 LOCAL r%
12050 r% = (c% = E_HEART OR c% = MON_RED)*-RED + (c% = E_FRUIT OR c% = MON_GREEN)*-GREEN + ((c% >= SN_L AND c% <= SN_U) OR c% = SN_W)*-YELLOW
12060 r% = r% + (c% = MON_BLUE OR c% = B_VERT OR c% = B_HORZ OR (c% >= B_UR AND c% <= B_DR))*-BLUE
12070 r% = r% + (c% = MON_PINK)*-MAGENTA + (c% = E_DIAMOND OR c% = MON_CYAN)*-CYAN + (c% = DOT OR c% = MON_WHITE OR c% = E_CIRC OR c% = E_DISC)*-WHITE
12080 := r%
12090 :
12100 REM :::::::::::::::::
12110 REM ::   REM Eat   ::
12120 REM :::::::::::::::::
12130 DEF FN_EAT(x%, y%)
12140 LOCAL c%, n%, r%
12150 r% = TRUE:c% = ASC(GET$(x%, y%))
12160 n% = (c% = BLANK)*0 + ((c% = SN_W AND NOT Rvs_Dir%) OR (c% >= MON_RED AND c% <= MON_GREEN))*-1 + (c% = E_CIRC)*-2 + (c% = E_DISC)*-3
12170 n% = n% + (c% = DOT OR (c% >= E_HEART AND c% <= E_FRUIT))*-4 + (c% = MON_WHITE OR c% = MON_BLUE)*-5
12180 n% = n% + (c% = B_VERT OR c% = B_HORZ OR c% = B_UR OR c% = B_UL OR c% = B_DL OR c% = B_DR)*-6
12190 ON n% GOTO 12200,12210,12220,12240,12270,12290:ELSE 12300
12200 Dead% = TRUE:r% = FALSE:GOTO 12310:REM Collided with deadly monster
12210 PROC_INC_SIZE(-1):n% = FN_SHRINK_SNAKE:GOTO 12250:REM The open circle shrinks the snake
12220 PROC_UPDATE_MONSTER_STATE(MON_BLUE):REM The filled circle makes existing monsters vulnerable
12230 GOTO 12250
12240 PROC_INC_SIZE(1):REM Edible increases size of snake
12250 Score% = Score% + (c% = DOT)*-10 + (c% = E_HEART)*-100 + (c% = E_DIAMOND)*-200 + (c% = E_FRUIT)*-500 + (c% = E_CIRC OR c% = E_DISC)*-25
12260 GOTO 12300
12270 Score% = Score% + (c% = MON_BLUE)*-500 + (c% = MON_WHITE)*-1000:PROC_MANAGE_MONSTER(c%, x%, y%, FALSE):n% = FN_SHRINK_SNAKE:REM Eating cowardly monster shrinks the snake
12280 GOTO 12300
12290 Dead% = TRUE:r% = FALSE:REM Collided with boundary
12300 IF (r% = TRUE AND c% <> BLANK AND c% <> SN_W) THEN PROC_SOUND(16, 2)
12310 :=r%
12320 :
12330 REM :::::::::::::::::::::::::::
12340 REM :: Shrink Down The Snake ::
12350 REM :::::::::::::::::::::::::::
12360 DEF FN_SHRINK_SNAKE
12370 LOCAL i%
12380 i% = P - Size%:IF i% < 0 THEN i% = i% + MAX_SIZE%
12390 PROC_ERASE(X(i%), Y(i%))
12400 := i%
12410 :
12420 REM ::::::::::::::::::::::::::
12430 REM ::  Grow Out The Snake  ::
12440 REM ::::::::::::::::::::::::::
12450 DEF PROC_GROW_SNAKE(d%)
12460 LOCAL i%, ch%, dx%, dy%, nx%, ny%
12470 dx% = FN_X_DELTA(d%):dy% = FN_Y_DELTA(d%)
12480 nx% = X(P) + dx%:ny% = Y(P) + dy%
12490 IF NOT FN_EAT(nx%, ny%) THEN 12610
12500 IF nx% < UX% THEN nx% = LX%:REM Snake entered Left Portal; Exit Out Right Portal
12510 IF nx% > LX% THEN nx% = UX%:REM Snake entered Right Portal; Exit Out Left Portal
12520 IF ny% < UY% THEN ny% = LY%:REM Snake entered Top Portal; Exit Out Bottom Portal
12530 IF ny% > LY% THEN ny% = UY%:REM Snake entered Bottom Portal; Exit Out Top Portal
12540 P = FN_NEXT_POS(P):X(P) = nx%:Y(P) = ny%
12550 i% = FN_SHRINK_SNAKE
12560 i% = FN_NEXT_POS(i%):IF i% = P THEN 12580
12570 REPEAT:PROC_DRAW(X(i%), Y(i%), SN_W, TRUE):i% = FN_NEXT_POS(i%):UNTIL i% = P
12580 ch% = (AF <> 0) * -SN_W + (AF = 0) * -(d% + SN_L - 1):REM Which Animation Frame To Display For Snake's Head
12590 PROC_DRAW(X(P), Y(P), ch%, TRUE)
12600 AF = (AF + 1) MOD 2
12610 ENDPROC
12620 :
12630 REM ::::::::::::::::::::::::::::::::
12640 REM :: Increase The Size Of Snake ::
12650 REM ::::::::::::::::::::::::::::::::
12660 DEF PROC_INC_SIZE(n%)
12670 Size% = (Size% + n%) MOD MAX_SIZE%:IF Size% < 2 THEN Size% = 2
12680 ENDPROC
12690 :
12700 REM :::::::::::::::::::::::::::::::::::::
12710 REM :: Check For Reversal Of Direction ::
12720 REM :::::::::::::::::::::::::::::::::::::
12730 DEF FN_CHECK_FOR_REVERSE_DIRECTION(old%, new%)
12740 REM 4 = UP; 3= DOWN; 1 = LEFT; 2 = RIGHT
12750 := (old% = 4 AND new% = 3) OR (old% = 3 AND new% = 4) OR (old% = 1 AND new% = 2) OR (old% = 2 AND new% = 1)
12760 :
12770 REM :::::::::::::::::::::::::::::
12780 REM :: Manage Monster Instance ::
12790 REM :::::::::::::::::::::::::::::
12800 DEF PROC_MANAGE_MONSTER(c%, x%, y%, state%)
12810 LOCAL i%:REM PROC_COUT(STR$(x%)+","+STR$(y%)+" "+STR$(c%)+"  ", 2)
12820 i% = FN_HASH(x%, y%)
12830 IF state% = FALSE THEN MT%(i%) = BLANK:PROC_CLEAR_MONSTER_POS(i%)
12840 IF state% = TRUE AND M_Count% <> MAX_MONSTERS% THEN MT%(i%) = c%:M_Position% = FN_NEXT_MONSTER(M_Position%):MP%(M_Position%) = i%:M_Count% = M_Count% + 1:PROC_DRAW(x%, y%, c%, TRUE)
12850 IF state% = MON_BLUE OR state% = MON_WHITE THEN PROC_DRAW(x%, y%, state%, TRUE)
12860 ENDPROC
12870 :
12880 DEF PROC_MANAGE_MONSTER_BY_INDEX(c%, index%)
12890 LOCAL x%, y%, i%
12900 i% = MP%(index%)
12910 IF -1 <> i% THEN y% = i% DIV LX% - UY%:x% = i% MOD LX% - UX%:PROC_MANAGE_MONSTER(c%, x%, y%, TRUE)
12920 ENDPROC
12930 :
12940 DEF FN_FIND_MONSTER_INDEX(index%)
12950 LOCAL i%, found%, r%
12960 i% = 0:
12970 REPEAT found% = (index% = MP%(i%))
12980   i% = FN_NEXT_MONSTER(i%)
12990 UNTIL found% OR i% = 0
13000 IF found% THEN r% = i%:ELSE r% = -1
13010 := r%
13020 :
13030 DEF PROC_CLEAR_MONSTER_POS(index%)
13040 LOCAL i%
13050 i% = FN_FIND_MONSTER_INDEX(index%)
13060 IF (-1 <> i%) THEN MP(i%) = -1:M_Count% = M_Count% - 1
13070 ENDPROC
13080 :
13090 DEF PROC_UPDATE_MONSTER_STATE(state%)
13100 LOCAL i%
13110 FOR i% = 0 TO MC%:PROC_MANAGE_MONSTER_BY_INDEX(state%, MP%(i%)):NEXT i%
13120 ENDPROC
13130 :
13140 REM :::::::::::::::::::::::::::
13150 REM ::  Update Portal State  ::
13160 REM :::::::::::::::::::::::::::
13170 DEF PROC_UPDATE_PORTAL_STATE
13180 LOCAL horizontal%, vertical%
13190 Portal_State% = (Portal_State% + 1) MOD 4
13200 IF Portal_State% = 0 THEN horizontal% = FALSE: vertical% = FALSE
13210 IF Portal_State% = 1 THEN horizontal% = TRUE: vertical% = FALSE
13220 IF Portal_State% = 2 THEN horizontal% = TRUE: vertical% = TRUE
13230 IF Portal_State% = 3 THEN horizontal% = FALSE: vertical% = TRUE
13240 PROC_DRAW_PORTALS(horizontal%, vertical%)
13250 ENDPROC
13260 :
13270 REM :::::::::::::::::::::::
13280 REM ::  Death Animation  ::
13290 REM :::::::::::::::::::::::
13300 DEF PROC_DEATH_ANIMATION(x%, y%)
13310 LOCAL ch%, fr$, i%, n%
13320 REPEAT:Size% = Size% - 1:n% = FN_SHRINK_SNAKE:PROC_SOUND(2 * Size%, 2):PROC_SOUND(0, 0):PROC_SLEEP(10):UNTIL Size% < 2
13330 fr$ = RIGHT$("0"+STR$(SN_W), 3)+STR$(SN_U)+STR$(SN_D1)+STR$(SN_D2)+STR$(SN_D3)+STR$(SN_D4)+STR$(SN_D5)+STR$(SN_D6)+"032"
13340 FOR i% = 1 TO LEN(fr$) DIV 3 STEP 2
13350   ch% = VAL(MID$(fr$, 3 * (i% - 1) + 1, 3))
13360   VDU 31, x%, y%, 17, YELLOW, ch%:PROC_SOUND(i% + 8, 2):PROC_SLEEP(20)
13370 NEXT i%:PROC_SOUND(4, 3)
13380 ENDPROC
13390 :
13400 REM :::::::::::::::::::::::::
13410 REM ::  Draw Playing Field ::
13420 REM :::::::::::::::::::::::::
13430 DEF PROC_DRAW_BOUNDARY
13440 LOCAL i%, cx%, cy%, a%, b%, c%
13450 a% = CW% + CH% - 2:b% = a% + CW%:c% = b% + CH% - 2
13460 FOR i% = 0 TO c% - 1
13470   cx% = (i% < CW%) * -i% + (i% > (CW%-1) AND i% < a%) * -(CW%-1) + (i% >= a% AND i% < b%) * (i% - (b% - 1)) + (i% >= b%) * 0
13480   cy% = (i% < CW%) * 0 + (i% > (CW%-1) AND i% < a%) * -(i% - (CW%-1)) + (i% >= a% AND i% < b%) * -(CH%-1) + (i% >= b%) * -((CH%-2) - (i% - b%))
13490   char% = ((i% > 0 AND i% < (CW%-1)) OR (i% > a% AND i% < (b% - 1)))* -B_HORZ
13500   char% = char% + ((i% > (CW%-1) AND i% < a%) OR (i% >= b% AND i% <= 125))*-B_VERT
13510   char% = char% + (i% = 0)*-B_UR + (i% = (CW%-1))*-B_UL + (i% = a%)*-B_DL + (i% = (b% - 1))*-B_DR
13520   VDU 31,cx%,cy%:COLOUR BLUE:VDU char%
13530 NEXT i%
13540 ENDPROC
13550 :
13560 REM :::::::::::::::::::
13570 REM :: Draw Portals  ::
13580 REM :::::::::::::::::::
13590 DEF PROC_DRAW_PORTALS(vertical%, horizontal%)
13600 LOCAL color%:color% = CYAN
13610 IF (vertical%) THEN VDU 31,18,0:COLOUR color%:VDU B_DL,BLANK:COLOUR color%:VDU B_DR,31,18,LY%+1:COLOUR color%:VDU B_UL,BLANK:COLOUR color%:VDU B_UR
13620 IF (horizontal%) THEN VDU 31,0,11:COLOUR color%:VDU B_DL,10,8,BLANK,10,8:COLOUR color%:VDU B_UL,31,LX%+1,11:COLOUR color%:VDU B_DR,31,LX%+1,12,BLANK,31,LX%+1,13:COLOUR color%:VDU B_UR
13630 ENDPROC
13640 :
13650 REM :::::::::::::::::::
13660 REM ::    Welcome    ::
13670 REM :::::::::::::::::::
13680 DEF PROC_WELCOME
13690 LOCAL C%, cc%, ex%, t%
13700 cc% = 0:ex% = FALSE:c% = 2 * (CH% - 2) + 2 * CW%: t% = 2
13710 CLS:PROC_HIDE_CURSOR
13720 PRINT TAB(8,t%)"Welcome to SNAC-SNAKE!":PRINT
13730 PRINT TAB(t%)"This work-in-progress is an 80s"
13740 PRINT TAB(t%)"themed variant of the classic SNAKE"
13750 PRINT TAB(t%)"game.":PRINT
13760 PRINT TAB(t%)"Use the four arrow keys to maneuver"
13770 PRINT TAB(t%)"the starving little snake to snack"
13780 PRINT TAB(t%)"on pellets and other tasty morsels.":PRINT
13790 PRINT TAB(t%)"Avoid the walls and spooky little"
13800 PRINT TAB(t%)"monsters while trying to avoid "
13810 PRINT TAB(t%)"chomping on yourself like an"
13820 PRINT TAB(t%)"Ouroboros. Good luck and have fun!":PRINT
13830 PRINT TAB(9)"HIT A KEY TO START"
13840 REPEAT
13850   PROC_CLOCKWISE_BEAM(cc%, cc% MOD 6 + 1, ASC("."))
13860   TI = TIME
13870   PROC_SLEEP(2)
13880   PROC_CLOCKWISE_BEAM(cc%, 0, 32)
13890   cc% = (cc% + 1) MOD c%
13900   IF INKEY(DL%) > 0 THEN ex% = TRUE
13910 UNTIL ex%
13920 PROC_DEFAULT_COLORS
13930 ENDPROC
13940 :
13950 REM :::::::::::::::::::::::
13960 REM :: Play Simple Sound ::
13970 REM :::::::::::::::::::::::
13980 DEF PROC_SOUND(index%, duration%)
13990 LOCAL constant%:constant% = 12.2
14000 SOUND 1, -10, index% * constant%, duration%
14010 ENDPROC
14020 :
14030 REM ::::::::::::::::::::::::::::::
14040 REM :: Define Custom Characters ::
14050 REM ::::::::::::::::::::::::::::::
14060 DEF PROC_REDEFINE_CHARS
14070 VDU 23,SN_L,0,60,30,14,14,30,60,0:REM LEFT(3)
14080 VDU 23,SN_R,0,60,120,112,112,120,60,0:REM RIGHT(3)
14090 VDU 23,SN_D,0,60,126,126,102,66,0,0:REM DOWN(3)
14100 VDU 23,SN_U,0,0,66,102,126,126,60,0:REM UP(3)
14110 VDU 23,SN_W,0,60,126,126,126,126,60,0:REM WHOLE(3)
14120 VDU 23,E_HEART,54,127,127,127,62,28,8,0:REM HEART(1)
14130 VDU 23,E_DIAMOND,8,28,62,127,62,28,8,0:REM DIAMOND(6)
14140 VDU 23,E_FRUIT,0,12,24,60,60,60,24,0:REM FRUIT(2)
14150 VDU 23,E_CIRC,0,60,126,102,102,126,60,0:REM CIRCLE(7)
14160 VDU 23,E_DISC,0,60,126,126,126,126,60,0:REM FILLED CIRCLE(7)
14170 VDU 23,MON_WHITE,0,60,126,90,126,126,90,0:REM WHITE(7)
14180 VDU 23,MON_BLUE,0,60,126,90,126,126,90,0:REM BLUE(4)
14190 VDU 23,MON_RED,0,60,126,90,126,126,90,0:REM RED(1)
14200 VDU 23,MON_PINK,0,60,126,90,126,126,90,0:REM MAGENTA(5)
14210 VDU 23,MON_CYAN,0,60,126,90,126,126,90,0:REM CYAN(6)
14220 VDU 23,MON_GREEN,0,60,126,90,126,126,90,0:REM GREEN(2)
14230 VDU 23,B_VERT,24,24,24,24,24,24,24,24:REM VERTICAL(4)
14240 VDU 23,B_HORZ,0,0,0,255,255,0,0,0:REM HORIZONTAL(4)
14250 VDU 23,B_UR,0,0,0,7,15,28,24,24:REM UPRIGHT C(4)
14260 VDU 23,B_UL,0,0,0,224,240,56,24,24:REM UPLEFT C(4)
14270 VDU 23,B_DL,24,24,56,240,224,0,0,0:REM DOWNLEFT C(4)
14280 VDU 23,B_DR,24,24,28,15,7,0,0,0:REM DOWN RIGHT C(4)
14290 VDU 23,SN_D1,0,0,0,102,126,126,60,0:REM DYING 1
14300 VDU 23,SN_D2,0,0,0,0,126,126,60,0:REM DYING 2
14310 VDU 23,SN_D3,0,0,0,0,126,126,60,0:REM DYING 3
14320 VDU 23,SN_D4,0,0,0,0,24,60,60,0:REM DYING 4
14330 VDU 23,SN_D5,0,0,0,0,24,24,60,0:REM DYING 5
14340 VDU 23,SN_D6,0,0,0,0,8,24,16,0:REM DYING 6
14350 ENDPROC
