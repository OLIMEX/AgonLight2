   10 REM GPIO Port Test
   20 :
   30 PB_DR% = &9A
   40 PB_DDR% = &9B
   50 PB_ALT1% = &9C
   60 PB_ALT2% = &9D
   70 :
   80 PC_DR% = &9E
   90 PC_DDR% = &9F
  100 PC_ALT1% = &A0
  110 PC_ALT2% = &A1
  120 :
  130 REM Set all GPIO on Port C to output
  140 :
  150 PROCres_gpio(PC_DDR%, &FF)
  160 PROCres_gpio(PC_ALT1%, &FF)
  170 PROCres_gpio(PC_ALT2%, &FF)
  180 :
  182 REM Loop, outputting the byte values 0->255 to Port C
  184 :
  190 FOR I%=0 TO 255
  200   PUT PC_DR%, I%
  210 NEXT
  220 PRINT ".";
  230 GOTO 190
  970 :
  980 STOP
  990 :
  992 REM Set bits V% in GPIO port R%
  994 :
 1000 DEF PROCset_gpio(R%, V%)
 1010 LOCAL A%
 1020 A% = GET(R%)
 1030 A% = A% OR V%
 1040 PUT R%, A%
 1050 ENDPROC
 1060 :
 1062 REM Reset bits V% in GPIO port R%
 1064 :
 1070 DEF PROCres_gpio(R%, V%)
 1080 LOCAL A%
 1090 A% = GET(R%)
 1100 A% = A% AND (V% EOR &FF)
 1110 PUT R%, A%
 1120 ENDPROC
