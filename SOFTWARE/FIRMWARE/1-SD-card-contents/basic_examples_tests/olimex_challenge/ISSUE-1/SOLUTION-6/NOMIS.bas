10000 ::::::::::::::::::::::::::::::::::::::::::::::
10010 :: REM NOMIS                                ::
10020 :: REM NOMIS Only May Impersonate Simon     ::
10030 ::::::::::::::::::::::::::::::::::::::::::::::
10040 :: REM by https://github.com/tonedef71 for  ::
10050 :: REM Olimex Weekend Programming Challenge ::
10060 :: REM Issue #1                             ::
10070 ::::::::::::::::::::::::::::::::::::::::::::::
10080 :: REM Best experienced on 40+ column, 16+  ::
10090 :: REM color display                        ::
10100 ::::::::::::::::::::::::::::::::::::::::::::::
10110 CLEAR
10120 PROC_setup
10130 PROC_defaultColors
10140 REPEAT CLS:MO$=FN_prompt(0,0,"MODE (1,2,3,...):","2"):UNTIL VAL(MO$) > 0:MODE VAL(MO$)
10150 PROC_welcome
10160 PROC_selectDifficulty:PROC_newSequence(DifficultyLevel%)
10170 LostGame% = 0:NumRounds% = DIFFICULTY_LEVELS(DifficultyLevel% - 1)
10180 CLS:PROC_paintGameboard
10190 PROC_cursorOff
10200 PROC_mainloop:REM Invoke main loop
10210 PROC_defaultColors
10220 IF LostGame% = 0 THEN PRINT TAB(0, 14)"Congratulations! You won.":PROC_playMusicCue(WIN_CUE%):ELSE PRINT TAB(0, 14)"So sorry! You lost.":PROC_playMusicCue(LOSE_CUE%)
10230 PROC_cursorOn
10240 R$ = FN_playAgain:IF R$ = "Y" THEN 10150
10250 PROC_goodbye
10260 END
10270 ::::::::::::::::::::::::
10280 ::   REM Setup Game   ::
10290 ::::::::::::::::::::::::
10300 DEF PROC_setup
10310 LOCAL d%, i%, j%, l%, p%
10320 BLACK = 0:YELLOW = 3:BLUE = 4:RED = 1:GREEN = 2:WHITE = 7:WIN_CUE% = 0:LOSE_CUE% = 1:WRONG_PAD_CUE% = 2:
10330 DIM DIFFICULTY_LEVELS(4),Sequence%(32),PAD$(4, 2),PAD%(4, 2),PAD_COLOR%(4),PAD_PITCH%(4),PAD_KEY$(4),SoundCues%(3, 41)
10340 PAUSE_TIME% = 500:PAD_SOUND_TIME% = 12:PAD_LIT_TIME% = 0
10350 FOR i% = 0 TO 3:READ DIFFICULTY_LEVELS(i%):NEXT i%
10360 DATA 8,14,20,31
10370 FOR i% = 0 TO 3:
10380   READ PAD_COLOR%(i%),PAD_PITCH%(i%),PAD_KEY$(i%),PAD%(i%, 0),PAD%(i%, 1):
10390   READ n%:PAD$(i%, 0) = STRING$(n%, " "):READ n%:PAD$(i%, 1) = STRING$(n%, " ")
10400 NEXT i%
10410 REM PAD_COLOR_VALUE,PAD_SOUND_VALUE,PAD_KEY,PAD_X,PAD_Y,PAD_TOP_WIDTH,PAD_BOTTOM_WIDTH
10420 DATA GREEN,213,"R",0,0,10,5,RED,185,"I",11,0,10,5,YELLOW,201,"F",0,7,5,10,BLUE,165,"J",11,7,5,10
10430 FOR i% = 0 TO 2:READ l%:SoundCues%(i%, 0) = l%:
10440   FOR j% = 1 TO l%*2 STEP 2
10450     READ p%:READ d%:SoundCues%(i%, j%) = p%:SoundCues%(i%, j% + 1) = d%
10460   NEXT j%
10470 NEXT i%
10480 REM COUNT,PITCH,DURATION,...
10490 DATA 6,129,1,149,1,165,1,177,4,165,2,177,8
10500 DATA 8,81,2,81,2,81,2,69,20,73,2,73,2,73,2,61,24
10510 DATA 1,5,20
10520 ENDPROC
10530 ::::::::::::::::::::::::::
10540 :: REM Inverse Video On ::
10550 ::::::::::::::::::::::::::
10560 DEF PROC_invOn(fg%, bg%):COLOUR 128+fg%:COLOUR bg%:ENDPROC
10570 :::::::::::::::::::::::::::
10580 :: REM Inverse Video Off ::
10590 :::::::::::::::::::::::::::
10600 DEF PROC_invOff(fg%, bg%):COLOUR fg%:COLOUR 128+bg%:ENDPROC
10610 ::::::::::::::::::::::::::
10620 ::     REM Main Loop    ::
10630 ::::::::::::::::::::::::::
10640 DEF PROC_mainloop
10650 LOCAL index%, i%, n%, currentRound%, delayTime%
10660 LostGame% = 0
10670 FOR currentRound% = 0 TO NumRounds% - 1
10680   PROC_sleep(PAUSE_TIME% * .3):REM Give player a moment to get ready for next entry in sequence
10690   PROC_displayRound(currentRound% + 1, NumRounds%)
10700   FOR i% = 0 TO currentRound%:REM Present sequence revealed thus far
10710     delayTime% = PAD_SOUND_TIME% - (currentRound% >= 5)*-PAD_SOUND_TIME%/6 + (currentRound% >= 9)*-PAD_SOUND_TIME%/6 + (currentRound% >= 13)*-PAD_SOUND_TIME%/6
10720     n% = Sequence%(i%):PROC_paintPad(n%, -1):PROC_padSound(n%, delayTime%):PROC_paintPad(n%, 0)
10730   NEXT i%
10740   FOR i% = 0 TO currentRound%
10750     PROC_emptyKeyboardBuffer
10760     n% = Sequence%(i%):index% = FN_padPress
10770     IF index% <> -1 THEN PROC_paintPad(index%, -1) ELSE GOTO 10800
10780     IF index% = n% THEN PROC_padSound(index%, PAD_SOUND_TIME%*.6):PROC_paintPad(index%, 0):GOTO 10810
10790     PROC_paintPad(index%, 0)
10800     LostGame% = -1:PROC_paintPad(n%, -1):PROC_playMusicCue(WRONG_PAD_CUE%):PROC_paintPad(n%, 0):i% = currentRound%:currentRound% = NumRounds%
10810   NEXT i%
10820 NEXT currentRound%
10830 ENDPROC
10840 ::::::::::::::::::::::::::
10850 :: REM Paint Game Board ::
10860 ::::::::::::::::::::::::::
10870 DEF PROC_paintGameboard
10880 LOCAL i%
10890 FOR i% = 0 TO 3
10900   PROC_paintPad(i%, 0)
10910 NEXT i%
10920 PROC_invOff(WHITE+8, BLACK):PRINT TAB(8,6)"NOMIS"
10930 PRINT TAB(7, 3)PAD_KEY$(0)TAB(13, 3)PAD_KEY$(1)TAB(7, 9)PAD_KEY$(2)TAB(13, 9)PAD_KEY$(3)
10940 ENDPROC
10950 ::::::::::::::::::::::::::
10960 ::   REM New Sequence   ::
10970 ::::::::::::::::::::::::::
10980 DEF PROC_newSequence(difficulty_level%)
10990 LOCAL i%
11000 IF difficulty_level% < 1 OR difficulty_level% > 4 THEN difficulty_level% = 1
11010 FOR i% = 0 TO DIFFICULTY_LEVELS(difficulty_level% - 1) - 1
11020   Sequence%(i%) = RND(4) - 1
11030 NEXT i%
11040 Sequence%(i%) = -1:REM Signal end of sequence with terminating value of -1
11050 ENDPROC
11060 :::::::::::::::::::::::::::::::
11070 :: REM Empty Keyboard Buffer ::
11080 :::::::::::::::::::::::::::::::
11090 DEF PROC_emptyKeyboardBuffer:REPEAT UNTIL INKEY(0) = -1:ENDPROC
11100 ::::::::::::::::::::::::::
11110 ::    REM Paint Pad     ::
11120 ::::::::::::::::::::::::::
11130 DEF PROC_paintPad(index%, is_lit%)
11140 LOCAL i%, x%, y%, p$
11150 IF index% < 0 OR index% > 3 THEN 11240
11160 PROC_invOn(PAD_COLOR%(index%) + -8 * (is_lit% <> 0), BLACK)
11170 FOR i% = 0 TO 5
11180   x% = PAD%(index%, 0):y% = PAD%(index%, 1) + i%
11190   p$ = PAD$(index%, (i% > 2) * -1):IF (LEN(p$) < 10) AND (index% MOD 2 = 1) THEN x% = x% + 5
11200   VDU 31, x%, y%
11210   PRINT p$
11220 NEXT i%
11230 ENDPROC
11240 ::::::::::::::::::::::::::
11250 ::  REM Play Pad Sound  ::
11260 ::::::::::::::::::::::::::
11270 DEF PROC_padSound(index%, duration%)
11280 LOCAL p%,dummy$:p% = PAD_PITCH%(index%)
11290 SOUND 2, -6, p%, duration%
11300 SOUND 2, 0, p%, 1:REM Stacatto the currently playing sound
11310 dummy$=INKEY$(PAD_LIT_TIME%):PROC_emptyKeyboardBuffer:REM Allow some time for pad to remain lit
11320 ENDPROC
11330 ::::::::::::::::::::::::::
11340 ::      REM Sleep       ::
11350 ::::::::::::::::::::::::::
11360 DEF PROC_sleep(hundredths)
11370 LOCAL ti%
11380 ti% = TIME
11390 REPEAT UNTIL (TIME - ti%) >= hundredths:REM Pause for the given duration
11400 ENDPROC
11410 ::::::::::::::::::::::::::
11420 ::   REM To Uppercase   ::
11430 ::::::::::::::::::::::::::
11440 DEF FN_toUpper(ch$):LOCAL ch%:ch% = ASC(ch$):ch$ = CHR$(ch% + 32 * (ch% >= 97 AND ch% <= 122)):=ch$
11450 ::::::::::::::::::::::::::
11460 ::   REM Hide Cursor    ::
11470 ::::::::::::::::::::::::::
11480 DEF PROC_cursorOff:VDU 23,1,0;0;0;0;:ENDPROC
11490 ::::::::::::::::::::::::::
11500 ::   REM Show Cursor    ::
11510 ::::::::::::::::::::::::::
11520 DEF PROC_cursorOn:VDU 23,1,1;0;0;0;:ENDPROC
11530 ::::::::::::::::::::::::::
11540 :: REM Handle Pad Press ::
11550 ::::::::::::::::::::::::::
11560 DEF FN_padPress
11570 LOCAL br%,ch$
11580 ch$ = INKEY$(PAUSE_TIME%*.7):IF ch$ <> "" THEN ch$ = FN_toUpper(ch$)
11590 br% = (ch$ = PAD_KEY$(0))*-1 + (ch$ = PAD_KEY$(1))*-2 + (ch$ = PAD_KEY$(2))*-3 + (ch$ = PAD_KEY$(3))*-4
11600 br% = br% - 1
11610 PROC_emptyKeyboardBuffer
11620 = br%
11630 ::::::::::::::::::::::::::
11640 ::  REM Display Round   ::
11650 ::::::::::::::::::::::::::
11660 DEF PROC_displayRound(currentRound%, numRounds%)
11670 COLOUR 128+BLACK:COLOUR WHITE:PRINT TAB(0, 13)"Round "STR$(currentRound%)" of "STR$(numRounds%)
11680 ENDPROC
11690 ::::::::::::::::::::::::::
11700 :: REM Play Musical Cue ::
11710 ::::::::::::::::::::::::::
11720 DEF PROC_playMusicCue(index%)
11730 LOCAL d%, j%, l%, p%
11740 IF index% < 0 OR index% > 3 THEN 11790
11750 l% = SoundCues%(index%, 0):FOR j% = 1 TO l%*2 STEP 2:p% = SoundCues%(index%, j%):d% = SoundCues%(index%, j% + 1):IF p% >= 0 AND d% > -1 THEN SOUND 1, -6, p%, d%:ELSE j% = l%*2:GOTO 11770
11760   SOUND 1,0,p%,1:REM Stacatto the currently playing sound
11770 NEXT j%
11780 PROC_sleep(PAUSE_TIME% * .4)
11790 ENDPROC
11800 :::::::::::::::::::::::::::::
11810 :: REM Prompt For Response ::
11820 :::::::::::::::::::::::::::::
11830 DEF FN_prompt(x%, y%, text$, default$)
11840 LOCAL r$
11850 PRINT TAB(x%, y%)text$;" ";default$:PRINT TAB(x% + LEN(text$) + 1, y%);
11860 r$ = GET$:r$ = FN_toUpper(r$):IF r$ = CHR$(13) THEN r$ = default$
11870 = r$
11880 :::::::::::::::::::::::::::::::::
11890 :: REM Select Difficulty Level ::
11900 :::::::::::::::::::::::::::::::::
11910 DEF PROC_selectDifficulty
11920 r$ = FN_prompt(0, 14, "Difficulty Level (1-4):", "1")
11930 r% = VAL(r$):IF r% < 1 OR r% >4 THEN 11920
11940 DifficultyLevel% = r%
11950 ENDPROC
11960 :::::::::::::::::::::::::::
11970 :: REM Play Another Game ::
11980 :::::::::::::::::::::::::::
11990 DEF FN_playAgain
12000 LOCAL r$
12010 PROC_emptyKeyboardBuffer
12020 REPEAT r$ = FN_prompt(0, 15, "Would you like to play again (Y/N)?", "N") UNTIL INSTR("YN", r$) <> 0
12030 = r$
12040 :::::::::::::::::::::
12050 :: REM Say Goodbye ::
12060 :::::::::::::::::::::
12070 DEF PROC_goodbye
12080 PROC_cursorOff
12090 CLS:PRINT"So long and thank you for playing..."
12100 FOR i% = 1 TO 15:PRINTTAB(0,1)STRING$(i%," ")CHR$(17)CHR$(i%)"NOMIS":PROC_sleep(20):NEXT i%
12110 PROC_defaultColors
12120 PROC_cursorOn
12130 ENDPROC
12140 ::::::::::::::::::::::::::::::::
12150 :: REM Restore Default Colors ::
12160 ::::::::::::::::::::::::::::::::
12170 DEF PROC_defaultColors
12180 COLOUR 128+BLACK:COLOUR WHITE
12190 ENDPROC
12200 ::::::::::::::::::::::::::::
12210 :: REM Welcome The Player ::
12220 ::::::::::::::::::::::::::::
12230 DEF PROC_welcome
12240 CLS:PRINT"Welcome to NOMIS:":PRINT"  A colorful and musical game":PRINT"    of 'Follow the Leader'":PRINT
12250 PROC_invOn(WHITE, BLACK):PRINT"Object of the game":PROC_invOff(WHITE, BLACK)::PRINT"  Correctly repeat a longer and":PRINT"    longer sequence of signals":PRINT
12260 PROC_invOn(WHITE, BLACK):PRINT"Controls":PROC_invOff(WHITE, BLACK)::PRINT"  The following keys press the":PRINT"    sensor pad of the":PRINT"      corresponding color:";
12270 PRINT" "CHR$(17)CHR$(PAD_COLOR%(0))PAD_KEY$(0)" "CHR$(17)CHR$(PAD_COLOR%(1))PAD_KEY$(1)" "CHR$(17)CHR$(PAD_COLOR%(2))PAD_KEY$(2)" "CHR$(17)CHR$(PAD_COLOR%(3))PAD_KEY$(3)CHR$(17)CHR$(WHITE)
12280 ENDPROC
