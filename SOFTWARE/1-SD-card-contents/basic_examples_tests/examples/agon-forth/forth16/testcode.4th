\ Example code definitions.

CODE 3* ( n1 --- n2)
\G Multiply a number by 3
  LD L, C
  LD H, B      \ Copy TOS to HL
  ADD HL, HL   \ Times 2
  ADD HL, BC   \ Add original value, so times 3
  LD C, L
  LD B, H      \ Copy result to TOS
  NEXT
END-CODE


CODE CLZ ( u --- n)
\G Count leading zeros.
   LD L, C
   LD H, B  \ Copy TOS to HL
   LD A, L  
   OR H     \ Test HL=0
   0= IF
     LD BC, $10 \ If zero we have 16 leading zeros.
   ELSE
     LD BC, $FFFF \ Start at -1 as we increment 1 more than leading zeros.
     BEGIN
	ADD HL, HL \ Shift left
     	INC BC     \ Count one more
     U< UNTIL      \ Until the last bit shifted out is 1.
   THEN
   NEXT
END-CODE   
