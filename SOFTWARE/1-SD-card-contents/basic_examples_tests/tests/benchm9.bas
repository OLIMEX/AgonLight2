   10 REM File Benchmarks
   20 :
   30 C=5000
   40 :
   50 T%=TIME
   60 f=OPENOUT "file.txt"
   70 FOR I=1 TO C
   80   PRINT #f,"Hello World " + STR$(I)
   90 NEXT
  100 CLOSE#f
  110 PRINT "Write: ";(TIME-T%)/120
  120 :
  130 T%=TIME
  140 f=OPENIN "file.txt"
  150 FOR I=1 TO C
  160   INPUT#f,S$
  170 NEXT
  180 CLOSE#f
  190 PRINT "Read: ";(TIME-T%)/120
  200 :
  210 OSCLI("ERASE file.txt")
