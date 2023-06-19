   10 REM OSBYTE &A0 Example
   20 REM Gets System Variables
   30 :
   40 REM This example fetches a 32 bit timer
   50 :
   60 PRINT FN_getTimer
   70 STOP
   80 :
   90 DEF FN_getTimer
  100 REM A% is the OSBYTE command to run
  110 A%=&A0
  120 REM L% is the sysvar to fetch
  130 L%=&00
  140 T%=USR(&FFF4)
  150 L%=&01
  160 T%=T% OR USR(&FFF4)*&FF
  170 =T%
