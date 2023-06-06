   10 REM "Wordy Bird" by www.luzrbum.com 2023
   20 MODE 1: REM SHOULD WORK IN ANY MODE SINCE NO COLOUR
   30 REM **** SET UP PHYSICS
   40 t%=0:      REM time (since start of the universe)
   50 dx%=1:     REM velocity (sideways)
   60 y%=16:     REM height
   70 dy%=1:     REM velocity (upwards)
   80 g%=2:      REM gravity
   90 f%=1:      REM force (of bird)
  100 maxdy%=5:  REM terminal velocity
  110 lives% = 1:REM Note to self: turn off reincarnation before release
  120 
  130 REM **** SET UP EXTENDED MEMORY
  140 HIMEM=&FB00
  150 PROC_empInit
  155 memEnd%=&60000:REM the file WBL.TXT support up to 128k = &70000 but the load time was AGONizing
  160 memStart%=&50000:memSize%=memEnd%-memStart%:memCurrent%=memStart%
  170 PROC_memWriteS(memStart%,"www.LuzrBum.com 2023")
  180 PRINT FN_memReadS(memStart%)
  190 PRINT" ":PRINT "Welcome to *Wordy Bird* for the Agon light (TM)":PRINT" ":PRINT "Submission in the category:"
  200 PRINT" *Highest ratio of game content to game code by raw byte*"
  210 PRINT "in the 2nd Olimex Agon Light Weekend Programming Challenge 2023":PRINT" "
  220 PRINT "Please wait for game content to load (64k)"
  230 PROC_memLoad("WBL.TXT")
  240 MODE1
  250 PRINT TAB(25,17)"PRESS SPACE TO FLY"
  260 PRINT TAB(0,0)"########################################################"
  270 PRINT TAB(0,30)"########################################################"
  280 
  290 REM **** RUN UNIVERSE
  300 REPEAT
  310   t%=t%+1
  320   IF (t% MOD 16)=0 THEN y%=y%+dy%:REM **** Laws of motion
  330   IF (t% MOD 100)=0 THEN dy%=dy%+g%:REM **** Law of gravity
  340   IF (t% MOD 8)=0 THEN FOR i%=0 TO 31:PRINT TAB(63,i%)MID$(FN_memReadS(memCurrent%),i%,1):NEXT:REM **** The Matrix
  350   IF (t% MOD 64)=0 THEN PRINT TAB(53,RND(32))CHR$(RND(64)+32):REM **** Fake free will
  360   IF (t% MOD 512)=0 THEN PRINT TAB(31,32)STR$(t%);" ticks,";STR$(lives%);" lives, 0x";STR$~(memCurrent%);" ";STR$((memCurrent%-memStart%)/&20):REM **** Measure success
  370   IF y%<=0 THEN y%=31:REM 2D hyperspace
  380   IF y%>30 THEN y%=0
  390   VDU 23,7,0,1,dx%
  400   k$=INKEY$(1)
  410   IF k$=" " THEN y%=y%-1:dy%=-1*f%:REM **** Laws of aerodynamics
  420   PRINT TAB(1,y%)"BIRD"
  430   IF GET$(5,y%)<>" " THEN PROC_death
  440   IF (t% MOD 8)=0 THEN memCurrent%=memCurrent%+&20
  450   IF memCurrent%>memEnd% THEN memCurrent%=memStart%: REM **** SIMPLIFYING ASSUMPTION ABOUT THE NATURE OF TIME
  460 UNTIL FALSE
  470 END
  480 REM **** END OF THE UNIVERSE (Restaurant service available)
  490 
  500 DEF PROC_death
  510 lives%=lives%+1
  520 dy%=0
  530 IF y%<=2 THEN y%=3
  540 IF y%>28 THEN y%=27
  550 PROC_coolPrint("YOU DIED AT T="+STR$(t%)):REM END here = Hardcore mode :)
  560 PROC_coolPrint("REINCARNATING                                  ")
  570 ENDPROC
  580 
  590 REM **** Extended Memory Procedures
  600 DEF PROC_memWriteS(address%,myString$)
  610 REM IF (address%<memEnd% AND address%>=memStart%) THEN:REM memory safety is somebody else´s problem
  620 !emdSA%=address%: CALL empGS%: !emdDA%=address%: $emdVS%=myString$: CALL empPS%
  630 ENDPROC
  640 DEF FN_memReadS(address%)
  650 !emdSA%=address%: CALL empGS%
  660 = $emdVS%
  670 ENDPROC
  680 REM **** All credit below to https://github.com/TurboVega/agon512k
  690 DEF PROC_empInit
  700 emdAI%=&FC08
  710 emdDA%=&FC04
  720 emdIS%=&FC0C
  730 emdRC%=&FC10
  740 emdSA%=&FC00
  750 emdV16%=&FB00
  760 emdV24%=&FB00
  770 emdV32%=&FB00
  780 emdV8%=&FB00
  790 emdVS%=&FB00
  800 emfG16%=&FC52
  810 emfG16AI%=&FC4D
  820 emfG24%=&FC6C
  830 emfG24AI%=&FC67
  840 emfG32%=&FC89
  850 emfG32AI%=&FC84
  860 emfG8%=&FC3B
  870 emfG8AI%=&FC36
  880 empCMBD%=&FDE7
  890 empCMBI%=&FDD2
  900 empGF%=&FCD6
  910 empGFAI%=&FCCD
  920 empGS%=&FCA9
  930 empGSAI%=&FCA4
  940 empI%=&FC14
  950 empP16%=&FD1E
  960 empP16AI%=&FD19
  970 empP24%=&FD40
  980 empP24AI%=&FD3B
  990 empP32%=&FD5A
 1000 empP32AI%=&FD55
 1010 empP8%=&FD04
 1020 empP8AI%=&FCFF
 1030 empPF%=&FDA9
 1040 empPFAI%=&FDA0
 1050 empPS%=&FD7C
 1060 empPSAI%=&FD77
 1070 empXMB%=&FE04
 1080 empZMB%=&FE4B
 1090 emBase%=&40000
 1100 FOR address%=&FC14 TO &FF46
 1110   READ assembly%
 1120   ?address%=assembly%
 1130 NEXT address%
 1140 DATA &AF, &5B, &DD, &21, &00, &00, &05, &06, &06, &57, &5F, &5B, &DD, &77, &00, &49
 1150 DATA &DD, &23, &1D, &20, &F6, &15, &20, &F3, &05, &20, &F0, &5B, &DD, &22, &04, &FC
 1160 DATA &04, &C9, &5B, &CD, &AF, &FE, &04, &5B, &DD, &2A, &00, &FC, &04, &5B, &DD, &6E
 1170 DATA &00, &AF, &67, &D9, &AF, &6F, &67, &4F, &C9, &5B, &CD, &AA, &FE, &04, &5B, &DD
 1180 DATA &2A, &00, &FC, &04, &5B, &DD, &6E, &00, &5B, &DD, &66, &01, &AF, &D9, &AF, &6F
 1190 DATA &67, &4F, &C9, &5B, &CD, &A5, &FE, &04, &5B, &DD, &2A, &00, &FC, &04, &5B, &DD
 1200 DATA &6E, &00, &5B, &DD, &66, &01, &AF, &D9, &AF, &5B, &DD, &6E, &02, &67, &4F, &C9
 1210 DATA &5B, &CD, &A0, &FE, &04, &5B, &DD, &2A, &00, &FC, &04, &5B, &DD, &6E, &00, &5B
 1220 DATA &DD, &66, &01, &AF, &D9, &AF, &5B, &DD, &6E, &02, &5B, &DD, &66, &03, &4F, &C9
 1230 DATA &5B, &CD, &E6, &FE, &04, &5B, &DD, &2A, &00, &FC, &04, &5B, &FD, &21, &00, &FB
 1240 DATA &04, &06, &00, &5B, &DD, &7E, &00, &5B, &FD, &77, &00, &FE, &0D, &28, &09, &49
 1250 DATA &DD, &23, &49, &FD, &23, &05, &20, &EB, &C9, &DD, &E5, &5B, &CD, &9B, &FE, &04
 1260 DATA &DD, &E1, &DD, &7E, &00, &FE, &01, &20, &21, &DD, &7E, &01, &FE, &05, &20, &1A
 1270 DATA &DD, &31, &02, &5B, &DD, &2A, &00, &FC, &04, &06, &05, &5B, &DD, &7E, &00, &FD
 1280 DATA &77, &00, &49, &DD, &23, &FD, &23, &05, &20, &F1, &C9, &5B, &CD, &93, &FE, &04
 1290 DATA &5B, &DD, &21, &00, &FB, &04, &5B, &FD, &2A, &04, &FC, &04, &5B, &DD, &7E, &00
 1300 DATA &5B, &FD, &77, &00, &C9, &5B, &CD, &8E, &FE, &04, &5B, &DD, &21, &00, &FB, &04
 1310 DATA &5B, &FD, &2A, &04, &FC, &04, &5B, &DD, &7E, &00, &5B, &FD, &77, &00, &5B, &DD
 1320 DATA &7E, &01, &5B, &FD, &77, &01, &C9, &5B, &CD, &89, &FE, &04, &5B, &DD, &21, &00
 1330 DATA &FB, &04, &5B, &FD, &2A, &04, &FC, &04, &5B, &DD, &17, &00, &5B, &FD, &1F, &00
 1340 DATA &C9, &5B, &CD, &84, &FE, &04, &5B, &DD, &21, &00, &FB, &04, &5B, &FD, &2A, &04
 1350 DATA &FC, &04, &5B, &DD, &17, &00, &5B, &FD, &1F, &00, &5B, &DD, &7E, &03, &5B, &FD
 1360 DATA &77, &03, &C9, &5B, &CD, &DE, &FE, &04, &5B, &DD, &21, &00, &FB, &04, &5B, &FD
 1370 DATA &2A, &04, &FC, &04, &06, &00, &5B, &DD, &7E, &00, &5B, &FD, &77, &00, &FE, &0D
 1380 DATA &28, &09, &49, &DD, &23, &49, &FD, &23, &05, &20, &EB, &C9, &DD, &E5, &5B, &CD
 1390 DATA &7F, &FE, &04, &DD, &E1, &DD, &7E, &00, &FE, &01, &20, &21, &DD, &7E, &01, &FE
 1400 DATA &05, &20, &1A, &DD, &37, &02, &5B, &FD, &2A, &04, &FC, &04, &06, &05, &DD, &7E
 1410 DATA &00, &5B, &FD, &77, &00, &DD, &23, &49, &FD, &23, &05, &20, &F1, &C9, &5B, &2A
 1420 DATA &00, &FC, &04, &5B, &ED, &5B, &04, &FC, &04, &5B, &ED, &4B, &10, &FC, &04, &5B
 1430 DATA &ED, &B0, &C9, &5B, &2A, &00, &FC, &04, &5B, &ED, &5B, &04, &FC, &04, &5B, &ED
 1440 DATA &4B, &10, &FC, &04, &49, &2B, &49, &1B, &5B, &ED, &B8, &49, &23, &49, &13, &C9
 1450 DATA &5B, &DD, &2A, &00, &FC, &04, &5B, &2A, &04, &FC, &04, &5B, &FD, &21, &10, &FC
 1460 DATA &04, &FD, &46, &02, &FD, &56, &01, &FD, &5E, &00, &5B, &DD, &4E, &00, &5B, &7E
 1470 DATA &5B, &71, &5B, &DD, &77, &00, &49, &DD, &23, &49, &23, &7B, &D6, &01, &5F, &7A
 1480 DATA &DE, &00, &57, &78, &DE, &00, &47, &B2, &B3, &20, &DF, &5B, &DD, &22, &00, &FC
 1490 DATA &04, &5B, &22, &04, &FC, &04, &C9, &5B, &DD, &2A, &04, &FC, &04, &5B, &FD, &21
 1500 DATA &10, &FC, &04, &FD, &46, &02, &FD, &56, &01, &FD, &5E, &00, &AF, &5B, &DD, &77
 1510 DATA &00, &49, &DD, &23, &7B, &D6, &01, &5F, &7A, &DE, &00, &57, &78, &DE, &00, &47
 1520 DATA &B2, &B3, &20, &E8, &5B, &DD, &22, &04, &FC, &04, &C9, &5B, &CD, &93, &FE, &04
 1530 DATA &5B, &CD, &93, &FE, &04, &5B, &CD, &93, &FE, &04, &5B, &CD, &93, &FE, &04, &5B
 1540 DATA &DD, &21, &04, &FC, &04, &18, &1A, &5B, &CD, &AF, &FE, &04, &5B, &CD, &AF, &FE
 1550 DATA &04, &5B, &CD, &AF, &FE, &04, &5B, &CD, &AF, &FE, &04, &5B, &DD, &21, &00, &FC
 1560 DATA &04, &5B, &3A, &08, &FC, &04, &5B, &DD, &86, &00, &5B, &DD, &77, &00, &5B, &3A
 1570 DATA &09, &FC, &04, &5B, &DD, &8E, &01, &5B, &DD, &77, &01, &5B, &3A, &0A, &FC, &04
 1580 DATA &5B, &DD, &8E, &02, &5B, &DD, &77, &02, &49, &C9, &5B, &DD, &21, &04, &FC, &04
 1590 DATA &18, &06, &5B, &DD, &21, &00, &FC, &04, &DD, &E5, &5B, &DD, &21, &08, &FC, &04
 1600 DATA &5B, &FD, &21, &0C, &FC, &04, &5B, &DD, &46, &01, &5B, &FD, &4E, &01, &ED, &4C
 1610 DATA &D9, &5B, &DD, &46, &00, &5B, &FD, &4E, &00, &ED, &4C, &5B, &DD, &56, &01, &5B
 1620 DATA &FD, &5E, &00, &ED, &5C, &5B, &DD, &66, &00, &5B, &FD, &6E, &01, &ED, &6C, &DD
 1630 DATA &E1, &79, &5B, &DD, &86, &00, &5B, &DD, &77, &00, &78, &8B, &8D, &5B, &DD, &8E
 1640 DATA &01, &5B, &DD, &77, &01, &7A, &8C, &D9, &89, &5B, &DD, &8E, &02, &5B, &DD, &77
 1650 DATA &02, &49, &C9
 1660 ENDPROC
 1670 REM **** String & memory manipulation
 1680 DEF PROC_coolPrint(myString$)
 1690 delay%=4096
 1700 FOR j%=-1 TO 1
 1710   PRINT TAB(1,y%+j%)myString$
 1720   FOR i%=0 TO delay%:z%=0:NEXT
 1730 NEXT
 1740 FOR j%=-1 TO 1
 1750   FOR i%=0 TO delay%:z%=0:NEXT
 1760   PRINT TAB(1,y%+j%)"                                                  "
 1770 NEXT
 1780 ENDPROC
 1790 
 1800 DEF PROC_insertC(memOffset%, row%, myString$)
 1810 tempString$=FN_memReadS(memOffset%)
 1820 finalString$= LEFT$(tempString$,row%-1)+LEFT$(myString$,1)+MID$(tempString$,row%+1)
 1830 PROC_memWriteS(memOffset%, finalString$)
 1840 ENDPROC
 1850 
 1860 DEF PROC_memWriteT(memOffset%, row%, myString$)
 1870 FOR i%=1 TO LEN(myString$)
 1880   myChar$=MID$(myString$,i%,1)
 1890   PROC_insertC(memOffset%+i%*&20, row%, myChar$)
 1900 NEXT
 1910 ENDPROC
 1920 
 1930 DEF PROC_memLoad(filename$)
 1940 tempString$=""
 1950 PRINT "Loading memory from 0x";STR$~(memStart%);" to 0x"; STR$~(memEnd%);" from file ";filename$
 1960 txt=OPENIN(filename$)
 1970 FOR i%=memStart% TO memEnd% STEP &20:INPUT#txt,tempString$:PROC_memWriteS(i%,tempString$):PRINT TAB(25,0)"0x";STR$~(i%):NEXT
 1980 CLOSE#txt
 1990 ENDPROC
 2000 
 2010 DEF PROC_memSave(filename$)
 2020 PRINT "Saving memory from 0x";STR$~(memStart%);" to 0x"; STR$~(memEnd%);" to file ";filename$
 2030 txt=OPENOUT(filename$)
 2040 FOR i%=memStart% TO memEnd% STEP &20:PRINT#txt,FN_memReadS(i%):PRINT TAB(20,0)"0x";STR$~(i%):NEXT
 2050 CLOSE#txt
 2060 ENDPROC
 2070 
 2080 DEF PROC_memInit:REM Just write SOMETHING to memory
 2090 PRINT "Writing default content to memory from 0x";STR$~(memStart%);" to 0x"; STR$~(memEnd%)
 2100 FOR i%=memStart% TO memEnd% STEP &20
 2110   PRINT TAB(20,0)"0x";STR$~(i%)
 2120   PROC_memWriteS(i%,"##                           ##")
 2130 NEXT
 2140 ENDPROC
 2150 
 2160 REM Following lineS ARE never reached, used to *EDIT for testing
 2170 PRINT FN_memReadS(memStart%)
 2180 PRINT FN_memReadS(&50000+(&20*7))
