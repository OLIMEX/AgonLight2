   10 REM ESP32 RTC TEST
   20 :
   30 INPUT "Year";YR%
   40 INPUT "Month";MO%
   50 INPUT "Day";DA%
   60 INPUT "Hour";HR%
   70 INPUT "Minute";MI%
   80 INPUT "Second";SE%
   90 VDU 23,0,&87,1,YR%-1980,MO%,DA%,HR%,MI%,SE%
  100 : 
  110 CLS
  120 PRINT TAB(2,2);TIME$
  130 GOTO 120
