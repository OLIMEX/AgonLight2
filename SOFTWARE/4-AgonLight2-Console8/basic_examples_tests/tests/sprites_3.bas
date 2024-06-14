   10 REM Sprite Demo
   20 :
   30 MODE 1
   40 SW%=320
   50 SH%=200
   60 C%=64
   70 :
   80 DIM data ((C%*6)-1)
   90 DIM code 1024
  100 :
  110 REM Z80 code
  120 :
  130 FOR I%=0 TO 3 STEP 3
  140   P%=code
  150   [
  160   OPT I%
  170   LD IX,data
  180   LD BC,C%
  190   LD E,0
  200   :
  210   LD A,23:RST &10
  220   LD A,27:RST &10
  230   LD A,15:RST &10
  240   :
  250   .loop
  260   :
  270   PUSH BC
  280   PUSH DE
  290   PUSH IX
  300   LD DE,SW%:CALL movspr
  310   LD DE,SH%:CALL movspr
  320   POP IX
  330   POP DE
  340   CALL setspr
  350   LD BC,6:ADD IX,BC
  360   INC E
  370   POP BC
  380   DEC BC
  390   LD A,B
  400   OR C
  410   JR NZ,loop
  420   RET
  430   :
  440   .movspr
  450   LD L,(IX+0):LD H,(IX+1):LD A,(IX+2):CALL addhla
  460   LD (IX+0),L:LD (IX+1),H
  470   XOR A:SBC HL,DE:JR C,movspr1
  480   LD A,(IX+2):NEG:LD (IX+2),A
  490   .movspr1
  500   LD DE,3:ADD IX,DE
  510   RET
  520   :
  530   .setspr
  540   ;E is the sprite to update
  550   :
  560   LD A,23:RST &10
  570   LD A,27:RST &10
  580   LD A, 4:RST &10
  590   LD A, E:RST &10
  600   LD A,23:RST &10
  610   LD A,27:RST &10
  620   LD A,13:RST &10
  630   LD A,(IX+0):RST &10
  640   LD A,(IX+1):RST &10
  650   LD A,(IX+3):RST &10
  660   LD A,(IX+4):RST &10
  670   RET
  680   :
  690   .addhla
  700   ;Add A to HL (signed)
  710   :
  720   PUSH DE
  730   LD E,A
  740   ADD A,A
  750   SBC A,A
  760   LD D,A
  770   ADD HL,DE
  780   POP DE
  790   RET
  800   :
  810   ]
  820 NEXT
  830 :
  840 MODE 2
  850 :
  860 REM Create a simple bitmap
  870 :
  880 VDU 23,27,0,0: REM Select bitmap 0
  890 READ W%,H%
  900 VDU 23,27,1,W%;H%;
  910 FOR I%=1 TO W%*H%
  920   READ B%
  930   VDU B%,B%,B%,B%
  940 NEXT
  950 :
  960 REM Set up some sprites
  970 :
  980 FOR I%=0 TO C%-1
  990   P%=data+(I%*6)
 1000   X%=RND(SW%)
 1010   Y%=RND(SH%)
 1020   ?(P%+0)=(X% AND &FF)
 1030   ?(P%+1)=(X%/256)
 1040   IF RND(2)=1 THEN ?(P%+2)=1 ELSE ?(P%+2)=255
 1050   ?(P%+3)=(Y% AND &FF)
 1060   ?(P%+4)=(Y%/256)
 1070   IF RND(2)=1 THEN ?(P%+5)=1 ELSE ?(P%+5)=255
 1080   VDU 23,27,4,I%: REM Select sprite I%
 1090   VDU 23,27,5: REM Clear frames for current sprite
 1100   VDU 23,27,6,0: REM Add bitmap 0 as frame 0 of sprite
 1110   VDU 23,27,11: REM Show the sprite
 1120 NEXT
 1130 VDU 23,27,7,C%
 1140 :
 1150 REM Move the sprite
 1160 :
 1170 *FX 19
 1180 CALL code
 1190 GOTO 1170
 1200 :
 1210 REM Bitmap data
 1220 :
 1230 DATA 16,16
 1240 :
 1250 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
 1260 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
 1270 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
 1280 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
 1290 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
 1300 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
 1310 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
 1320 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
 1330 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
 1340 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
 1350 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
 1360 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
 1370 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
 1380 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
 1390 DATA 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
 1400 DATA 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
