CODE FOO
   LD HL, $F800
   LD A, 33
   EX AF, AF'
   BEGIN
      EX AF, AF'
      LD (HL), A
      EX AF, AF'
      INC HL
      DEC BC
      LD A, C
      OR B
   0= UNTIL
   POP BC
   NEXT
END-CODE

