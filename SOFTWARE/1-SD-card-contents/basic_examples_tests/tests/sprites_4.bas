   10 REM Sprite Demo
   20 :
   30 MODE 1
   40 SW%=320
   50 SH%=200
   60 C%=32
   70 MB%=&40000
   80 :
   90 DIM data ((C%*6)-1)
  100 DIM code 1024
  110 DIM graphics 1024
  120 :
  130 REM Z80 code
  140 :
  150 FOR I%=0 TO 3 STEP 3
  160   P%=code
  170   [
  180   OPT I%
  190   LD IX,data
  200   LD BC,C%
  210   LD E,0
  220   :
  230   LD A,23:RST &10
  240   LD A,27:RST &10
  250   LD A,15:RST &10
  260   :
  270   .loop
  280   :
  290   PUSH BC
  300   PUSH DE
  310   PUSH IX
  320   LD DE,SW%:CALL movspr
  330   LD DE,SH%:CALL movspr
  340   POP IX
  350   POP DE
  360   CALL setspr
  370   LD BC,6:ADD IX,BC
  380   INC E
  390   POP BC
  400   DEC BC
  410   LD A,B
  420   OR C
  430   JR NZ,loop
  440   RET
  450   :
  460   .movspr
  470   LD L,(IX+0):LD H,(IX+1):LD A,(IX+2):CALL addhla
  480   LD (IX+0),L:LD (IX+1),H
  490   XOR A:SBC HL,DE:JR C,movspr1
  500   LD A,(IX+2):NEG:LD (IX+2),A
  510   .movspr1
  520   LD DE,3:ADD IX,DE
  530   RET
  540   :
  550   .setspr
  560   ;E is the sprite to update
  570   :
  580   LD A,23:RST &10
  590   LD A,27:RST &10
  600   LD A, 4:RST &10
  610   LD A, E:RST &10
  620   LD A,23:RST &10
  630   LD A,27:RST &10
  640   LD A,13:RST &10
  650   LD A,(IX+0):RST &10
  660   LD A,(IX+1):RST &10
  670   LD A,(IX+3):RST &10
  680   LD A,(IX+4):RST &10
  690   :
  700   LD A,23:RST &10
  710   LD A,27:RST &10
  720   LD A,8:RST &10
  730   :
  740   RET
  750   :
  760   .addhla
  770   ;Add A to HL (signed)
  780   :
  790   PUSH DE
  800   LD E,A
  810   ADD A,A
  820   SBC A,A
  830   LD D,A
  840   ADD HL,DE
  850   POP DE
  860   RET
  870   :
  880   ]
  890 NEXT
  900 :
  910 REM Load the sprites in
  920 :
  930 PROCloadSprite("../resources/pacman1.rgb",0,16,16)
  940 PROCloadSprite("../resources/pacman2.rgb",1,16,16)
  950 :
  960 MODE 2
  970 :
  980 REM Set up some sprites
  990 :
 1000 FOR I%=0 TO C%-1
 1010   P%=data+(I%*6)
 1020   X%=RND(SW%)
 1030   Y%=RND(SH%)
 1040   ?(P%+0)=(X% AND &FF)
 1050   ?(P%+1)=(X%/256)
 1060   IF RND(2)=1 THEN ?(P%+2)=1 ELSE ?(P%+2)=255
 1070   ?(P%+3)=(Y% AND &FF)
 1080   ?(P%+4)=(Y%/256)
 1090   IF RND(2)=1 THEN ?(P%+5)=1 ELSE ?(P%+5)=255
 1100   VDU 23,27,4,I%: REM Select sprite I%
 1110   VDU 23,27,5: REM Clear frames for current sprite
 1120   VDU 23,27,6,0: REM Add bitmap 0 as frame 0 of sprite
 1130   VDU 23,27,6,1: REM Add bitmap 1 as frame 1 of sprite
 1140   VDU 23,27,11: REM Show the sprite
 1150 NEXT
 1160 VDU 23,27,7,C%
 1170 :
 1180 REM Move the sprite
 1190 :
 1200 *FX 19
 1210 CALL code
 1220 GOTO 1200
 1230 :
 1240 REM Load a bitmap into VDP RAM
 1250 REM F$ - Filename of bitmap
 1260 REM N% - Bitmap number
 1270 REM W% - Bitmap width
 1280 REM H% - Bitmap height
 1290 :
 1300 DEF PROCloadSprite(F$,N%,W%,H%)
 1310 OSCLI("LOAD " + F$ + " " + STR$(MB%+graphics))
 1320 VDU 23,27,0,N%
 1330 VDU 23,27,1,W%;H%;
 1340 FOR I%=0 TO (W%*H%*3)-1 STEP 3
 1350   VDU 255
 1360   VDU ?(graphics+I%+2)
 1370   VDU ?(graphics+I%+1)
 1380   VDU ?(graphics+I%+0)
 1390 NEXT
 1400 ENDPROC
