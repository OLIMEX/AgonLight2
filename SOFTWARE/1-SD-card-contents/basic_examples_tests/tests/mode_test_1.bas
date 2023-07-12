   10 REM Mode Test
   20 :
   30 NUMMODES=3
   40 DIM S%(NUMMODES,4)
   50 :
   60 FOR I%=0 TO 100
   70   FOR M%=0 TO NUMMODES
   80     MODE M%
   90     W%=FN_getWordVDP(&0F)
  100     H%=FN_getWordVDP(&11)
  110     C%=FN_getByteVDP(&13)
  120     R%=FN_getByteVDP(&14)
  130     D%=FN_getByteVDP(&15)
  140     PRINT TAB(2,1)"Iteration:"I%
  150     PRINT TAB(2,2)"W:"W%
  160     PRINT TAB(2,3)"H:"H%
  170     PRINT TAB(2,4)"C:"C%
  180     PRINT TAB(2,5)"R:"R%
  190     PRINT TAB(2,6)"#:"D%
  200     IF I%=0 THEN S%(M%,0)=W%:S%(M%,1)=H%:S%(M%,2)=C%:S%(M%,3)=R%:S%(M%,4)=D%:GOTO 230
  210     IF S%(M%,0)=W% AND S%(M%,1)=H% AND S%(M%,2)=C% AND S%(M%,3)=R% AND S%(M%,4)=D% THEN GOTO 230
  220     PRINT "ERROR!":STOP
  230     A%=INKEY(2000)
  240   NEXT
  250 NEXT
  260 END
  270 :
  280 DEF FN_getByteVDP(var%)
  290 A%=&A0
  300 L%=var%
  310 =USR(&FFF4)
  320 :
  330 DEF FN_getWordVDP(var%)
  340 =FN_getByteVDP(var%)+256*FN_getByteVDP(var%+1)
