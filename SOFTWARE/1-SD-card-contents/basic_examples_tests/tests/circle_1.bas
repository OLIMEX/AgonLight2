   10 REM Circle Example
   20 :
   30 CLS
   40 GCOL 0,16+RND(64)
   50 PROCcircle(RND(1280),RND(1024),RND(400))
   60 GOTO 40
   70 :
   80 DEFPROCcircle(X%,Y%,R%) 
   90 S%=10
  100 OX=X%
  110 OY=Y%+R%
  120 FOR A%=10 TO 360 STEP S% 
  130   X=X%+R%*SIN(A%/180*PI)
  140   Y=Y%+R%*COS(A%/180*PI) 
  150   MOVE OX,OY
  160   MOVE X,Y
  170   PLOT 85,X%,Y%
  180   OX=X:OY=Y
  190 NEXT
  200 ENDPROC
