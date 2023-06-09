\ Z80 meta compiler to be run from an ANSI standard FORTH system
\ that contains the FILE wordset.

\ We need the word VOCABULARY. It's not in the standard though it will
\ be in most actual implementations.
: VOCABULARY WORDLIST CREATE  ,  \ Make a new wordlist and store it in def.
  DOES> >R                      \ Replace last item in the search order.
  GET-ORDER SWAP DROP R> @ SWAP SET-ORDER ;

.( Loading the assembler "asmz80.4th") CR
S" asmz80.4th" INCLUDED

.( Loading the meta compiler "metaz80.4th") CR
S" metaz80.4th" INCLUDED

\ .( Compiling the asm test from "asmtst80.4th") CR
\ S" asmtst80.4th" INCLUDED

.( Compiling the kernel from "kernl80a.4th") CR
S" kernl80a.4th" INCLUDED
.( Compiling the kernel from "kernl80b.4th") CR
S" kernl80b.4th" INCLUDED
.( Compiling the kernel from "kernl80c.4th") CR
S" kernl80c.4th" INCLUDED

\ Save the binary image of the Forth system.
VARIABLE FILEHAND
DECIMAL
: SAVE-IMAGE ( --- )
    S" kernel80.bin" W/O CREATE-FILE THROW FILEHAND !  
  IMAGE THERE ORIGIN - FILEHAND @ WRITE-FILE THROW
  FILEHAND @ CLOSE-FILE THROW
;
SAVE-IMAGE 
.( Image saved as "kernel80.bin") CR

BYE
