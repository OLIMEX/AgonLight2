   10 REM Scrolling Stars Demo
   15 :
   20 MODE 2
   30 VDU 23,1,0
   40 *FX 19
   50 GCOL 0,RND(16)
   60 PLOT &40,1279,RND(1024)
   70 VDU 23,7,0,1,1
   80 GOTO 40
