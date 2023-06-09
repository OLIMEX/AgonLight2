   10 REM SIMON per AgonLight2 in BBC Basic
   20 REM By Paolo Neurox66 Borzini 2023(c)
   30 REM neurox66@gmail.com - www.borzini.it
   40 DIM aSequenzaAL%(60)
   50 MODE 3
   60 VDU23,1,0;0;0;0;
   70 REM ///////////////////////////////
   80 REM // Main / Ciclo principale
   90 REM ///////////////////////////////
  100 tUscita% = 0
  110 REPEAT
  120   CLS
  130   PROC_DISEGNATASTI
  140   tScelta% = FN_MENU
  150   IF tScelta% = 1 THEN PROC_GIOCO
  160   IF tScelta% = 2 THEN PROC_STORIA
  170   IF tScelta% = 3 THEN PROC_ABOUT
  180   IF tScelta% = 4 THEN tUscita% = 1
  190 UNTIL tUscita% = 1
  200 CLS
  210 PRINT "Thanks"
  220 END
  230 REM ///////////////////////////////
  240 REM // Gioco / Simon
  250 REM ///////////////////////////////
  260 DEF PROC_GIOCO
  270 LOCAL tConta%, tCiclo%, tTemp%,tOpz%, tI%
  280 tConta% = 1
  290 tErrore%=0
  300 CLS
  310 REM Crea la sequenza di  colori
  320 FOR tI% = 1 TO 60
  330   aSequenzaAL%(tI%)=RND(4)
  340 NEXT tI%
  350 REPEAT
  360   PRINT TAB(37,2)"ROUND "; tConta%
  370   REM Suona il computer
  380   PRINT TAB(1,53) "Computer Play...  "
  390   FOR tI% = 1 TO tConta%
  400     PROC_DISEGNATASTI
  410     REM tTemp%=aSequenzaAL%(tI%)
  420     PROC_DISEGNATASTO(aSequenzaAL%(tI%),1)
  430     PROC_SUONATASTO(aSequenzaAL%(tI%))
  440   NEXT tI%
  450   REM Ripete lo scimmiotto ;-)
  460   PRINT TAB(1,53) "Player repeat...  "
  470   FOR tI% = 1 TO tConta%
  480     PROC_DISEGNATASTI
  490     tOpz%=VAL(GET$)
  500     IF tOpz% < 1 AND tOpz% > 4 THEN GOTO 500
  510     PROC_DISEGNATASTO(tOpz%,1)
  520     PROC_SUONATASTO(tOpz%)
  530     IF aSequenzaAL%(tI%) <> tOpz% THEN PROC_ERRORE: tErrore%=1: tCiclo%= 1
  540   NEXT tI%
  550   tConta% = tConta% + 1
  560   IF tConta%> 21  THEN  tCiclo%= 1
  570 UNTIL tCiclo%=1
  580 IF tErrore%=0 THEN PRINT TAB(1,53) "Great!!! Compliments!!!" : PROC_WAITCR
  590 ENDPROC
  600 REM ///////////////////////////////
  610 REM // Errore
  620 REM ///////////////////////////////
  630 DEF PROC_ERRORE
  640 PRINT TAB(1,53) "Wrong sequence!"
  650 PROC_WAITCR
  660 REM GOTO 120
  670 ENDPROC
  680 REM ///////////////////////////////
  690 REM // Storia del gioco
  700 REM ///////////////////////////////
  710 DEF PROC_STORIA
  720 CLS
  730 REM                      1         2         3         4         5         6         7         8
  740 REM             12345678901234567890123456789012345678901234567890123456789012345678901234567890
  750 PRINT TAB(1,2) "Simon is an electronic game from Milton Bradley, invented by Ralph Baer (also"
  760 PRINT TAB(1,3) "creator of the first video game console, the 1972 Magnavox Odyssey) and Howard "
  770 PRINT TAB(1,4) "J. Morrison. It was launched in the United States in 1978 and later spread "
  780 PRINT TAB(1,5) "around the world, gaining enormous success and becoming a pop culture symbol in"
  790 PRINT TAB(1,6) "the 1980s.The game is a kind of electronic variant of the children's game known"
  800 PRINT TAB(1,7) "in the English-speaking world as Simon Says. 'Simon' takes the form of a disc "
  810 PRINT TAB(1,8) "with four large buttons in red, blue, green and yellow. These buttons light up"
  820 PRINT TAB(1,9) "in a random sequence; the illumination of each button is also associated with"
  830 PRINT TAB(1,10)"the emission of a certain musical note. Once the sequence is complete, the "
  840 PRINT TAB(1,11)"player must repeat it by pressing the buttons in the same order."
  850 PRINT TAB(1,12)"If he succeeds in this task, the player is offered a new sequence, the same as"
  860 PRINT TAB(1,13)"the previous one with the addition of a new button/tone; the sequence to be"
  870 PRINT TAB(1,14)"repeated then becomes longer and longer and the player's task more difficult."
      PRINT TAB(1,16) "Test from Wikipedia"
  880 PROC_WAITCR
  890 ENDPROC
  900 REM ///////////////////////////////
  910 REM // About
  920 REM ///////////////////////////////
  930 DEF PROC_ABOUT
  940 CLS
  950 PRINT TAB(1,2) "My name is Paolo Neurox66 Borzini and I live in Italy."
  960 PRINT TAB(1,3) "I wrote this version of the game Simon for AgonLight2 in BBC Basic."
  970 PRINT TAB(1,4) "Obviously, the software is a first version and is not free of bugs :-)"
  980 PRINT TAB(1,7) "The keys to be used in the game are:"
  990 PRINT TAB(1,8) " KEY  -  COLOUR"
 1000 PRINT TAB(1,9) "  1   :  Red"
 1010 PRINT TAB(1,10) "  2   :  Green"
 1020 PRINT TAB(1,11) "  3   :  Yellow"
 1030 PRINT TAB(1,12)"  4   :  Blue"
 1040 PRINT TAB(1,15)"If you want to contact me for suggestions..."
 1050 PRINT TAB(1,16)"    neurox66@gmail.com - www.borzini.it"
 1060 PROC_WAITCR
 1070 ENDPROC
 1080 REM ///////////////////////////////
 1090 REM // Aspetta CR / Invio
 1100 REM ///////////////////////////////
 1110 DEF PROC_WAITCR
 1120 PRINT TAB(32,53)"Press CR to continue..."
 1130 REPEAT UNTIL GET=13
 1140 ENDPROC
 1150 REM ///////////////////////////////
 1160 REM // Menu
 1170 REM ///////////////////////////////
 1180 DEF FN_MENU
 1190 LOCAL tOpz%, tCiclo%
 1200 PRINT TAB(28,2)"SIMON GAME FOR AGONLIGHT2"
 1210 PRINT TAB(26,22) "1) Play Simon for AgonLight2 "
 1220 PRINT TAB(26,24) "2) Story of Simon Game "
 1230 PRINT TAB(26,26) "3) About "
 1240 PRINT TAB(26,28) "4) End "
 1250 tOpz%=VAL(GET$)
 1260 IF tOpz% < 1 AND tOpz% > 4 THEN GOTO   1250
 1270 =tOpz%
 1280 REM ///////////////////////////////
 1290 REM // Disegna tutti i tasti
 1300 REM ///////////////////////////////
 1310 DEF PROC_DISEGNATASTI
 1320 PROC_DISEGNATASTO(1,0)
 1330 PROC_DISEGNATASTO(2,0)
 1340 PROC_DISEGNATASTO(3,0)
 1350 PROC_DISEGNATASTO(4,0)
 1360 ENDPROC
 1370 REM ///////////////////////////////
 1380 REM // Disegna il tasto richiesto
 1390 REM ///////////////////////////////
 1400 DEF PROC_DISEGNATASTO(pTasto%,pAcceso%)
 1410 IF pAcceso%=1 THEN pAcceso%=8 ELSE pAcceso%=0
 1420 IF pTasto% = 3 THEN PROC_RECT(340,230,3+pAcceso%)
 1430 IF pTasto% = 4 THEN PROC_RECT(650,230,4+pAcceso%)
 1440 IF pTasto% = 1 THEN PROC_RECT(340,550,1+pAcceso%)
 1450 IF pTasto% = 2 THEN PROC_RECT(650,550,2+pAcceso%)
 1460 ENDPROC
 1470 REM ///////////////////////////////
 1480 REM // Suona la nota corrispondente al tasto
 1490 REM ///////////////////////////////
 1500 DEF PROC_SUONATASTO(pTasto%)
 1510 IF pTasto% = 1 THEN SOUND 1,-15,136,6
 1520 IF pTasto% = 2 THEN SOUND 1,-15,164,6
 1530 IF pTasto% = 3 THEN SOUND 1,-15,128,6
 1540 IF pTasto% = 4 THEN SOUND 1,-15,116,6
 1550 N=INKEY(70)
 1560 ENDPROC
 1570 REM ///////////////////////////////
 1580 REM // Disegna rettangolo in base al colore passato
 1590 REM ///////////////////////////////
 1600 DEF PROC_RECT(pX%,pY%,pC%)
 1610 LOCAL tDim%
 1620 tDim% = 300
 1630 GCOL 0,pC%
 1640 MOVE pX%,pY%
 1650 MOVE pX%+tDim%,pY%
 1660 PLOT 85,pX%,pY%+tDim%
 1670 PLOT 85,pX%+tDim%,pY%+tDim%
 1680 ENDPROC
