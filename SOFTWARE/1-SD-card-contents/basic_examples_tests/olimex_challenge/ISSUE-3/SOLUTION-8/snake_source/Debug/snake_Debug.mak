SHELL = cmd.exe

#
# ZDS II Make File - snake project, Debug configuration
#
# Generated by: ZDS II - eZ80Acclaim! 5.3.5 (Build 23020901)
#   IDE component: d:5.3.0:23020901
#   Install Path: C:\ZiLOG\ZDSII_eZ80Acclaim!_5.3.5\
#

RM = del

# ZDS base directory
ZDSDIR = C:\ZiLOG\ZDSII_eZ80Acclaim!_5.3.5
ZDSDIR_ESCSPACE = C:\ZiLOG\ZDSII_eZ80Acclaim!_5.3.5

# ZDS bin directory
BIN = $(ZDSDIR)\bin

# ZDS include base directory
INCLUDE = C:\ZiLOG\ZDSII_eZ80Acclaim!_5.3.5\include
INCLUDE_ESCSPACE = C:\ZiLOG\ZDSII_eZ80Acclaim!_5.3.5\include

# ZTP base directory
ZTPDIR = C:\ZiLOG\ZDSII_eZ80Acclaim!_5.3.5\ZTP2.5.1
ZTPDIR_ESCSPACE = C:\ZiLOG\ZDSII_eZ80Acclaim!_5.3.5\ZTP2.5.1

# project directory
PRJDIR = D:\AGON\snake
PRJDIR_ESCSPACE = D:\AGON\snake

# intermediate files directory
WORKDIR = D:\AGON\snake\Debug
WORKDIR_ESCSPACE = D:\AGON\snake\Debug

# output files directory
OUTDIR = D:\AGON\snake\Debug\
OUTDIR_ESCSPACE = D:\AGON\snake\Debug\

# tools
CC = @"$(BIN)\eZ80cc"
AS = @"$(BIN)\eZ80asm"
LD = @"$(BIN)\eZ80link"
AR = @"$(BIN)\eZ80lib"
WEBTOC = @"$(BIN)\mkwebpage"

CFLAGS =  \
-define:_DEBUG -define:_EZ80F92 -define:_EZ80ACCLAIM! -genprintf  \
-keepasm -keeplst -NOlist -NOlistinc -NOmodsect -optspeed  \
-promote -NOreduceopt  \
-stdinc:"\"..;C:\ZiLOG\ZDSII_eZ80Acclaim!_5.3.5\include\std;C:\ZiLOG\ZDSII_eZ80Acclaim!_5.3.5\include\zilog\""  \
-usrinc:"\"..;\"" -NOmultithread -NOpadbranch -debug -cpu:eZ80F92  \
-asmsw:"   \
	-define:_EZ80ACCLAIM!=1  \
	-include:\"..;C:\ZiLOG\ZDSII_eZ80Acclaim!_5.3.5\include\std;C:\ZiLOG\ZDSII_eZ80Acclaim!_5.3.5\include\zilog\"  \
	-list -NOlistmac -pagelen:0 -pagewidth:80 -quiet -sdiopt -warn  \
	-debug -NOigcase -cpu:eZ80F92"

ASFLAGS =  \
-define:_EZ80ACCLAIM!=1  \
-include:"\"..;C:\ZiLOG\ZDSII_eZ80Acclaim!_5.3.5\include\std;C:\ZiLOG\ZDSII_eZ80Acclaim!_5.3.5\include\zilog\""  \
-list -NOlistmac -name -pagelen:0 -pagewidth:80 -quiet -sdiopt  \
-warn -debug -NOigcase -cpu:eZ80F92

LDFLAGS = @..\template.linkcmd
build: snake relist

buildall: clean snake relist

relink: deltarget snake

deltarget: 
	@if exist "$(WORKDIR)\template.lod"  \
            $(RM) "$(WORKDIR)\template.lod"
	@if exist "$(WORKDIR)\template.hex"  \
            $(RM) "$(WORKDIR)\template.hex"
	@if exist "$(WORKDIR)\template.map"  \
            $(RM) "$(WORKDIR)\template.map"

clean: 
	@if exist "$(WORKDIR)\template.lod"  \
            $(RM) "$(WORKDIR)\template.lod"
	@if exist "$(WORKDIR)\template.hex"  \
            $(RM) "$(WORKDIR)\template.hex"
	@if exist "$(WORKDIR)\template.map"  \
            $(RM) "$(WORKDIR)\template.map"
	@if exist "$(WORKDIR)\init.obj"  \
            $(RM) "$(WORKDIR)\init.obj"
	@if exist "$(WORKDIR)\init.lis"  \
            $(RM) "$(WORKDIR)\init.lis"
	@if exist "$(WORKDIR)\init.lst"  \
            $(RM) "$(WORKDIR)\init.lst"
	@if exist "$(WORKDIR)\main.obj"  \
            $(RM) "$(WORKDIR)\main.obj"
	@if exist "$(WORKDIR)\main.lis"  \
            $(RM) "$(WORKDIR)\main.lis"
	@if exist "$(WORKDIR)\main.lst"  \
            $(RM) "$(WORKDIR)\main.lst"
	@if exist "$(WORKDIR)\main.src"  \
            $(RM) "$(WORKDIR)\main.src"
	@if exist "$(WORKDIR)\mos-interface.obj"  \
            $(RM) "$(WORKDIR)\mos-interface.obj"
	@if exist "$(WORKDIR)\mos-interface.lis"  \
            $(RM) "$(WORKDIR)\mos-interface.lis"
	@if exist "$(WORKDIR)\mos-interface.lst"  \
            $(RM) "$(WORKDIR)\mos-interface.lst"
	@if exist "$(WORKDIR)\vdp.obj"  \
            $(RM) "$(WORKDIR)\vdp.obj"
	@if exist "$(WORKDIR)\vdp.lis"  \
            $(RM) "$(WORKDIR)\vdp.lis"
	@if exist "$(WORKDIR)\vdp.lst"  \
            $(RM) "$(WORKDIR)\vdp.lst"
	@if exist "$(WORKDIR)\vdp.src"  \
            $(RM) "$(WORKDIR)\vdp.src"
	@if exist "$(WORKDIR)\agontimer.obj"  \
            $(RM) "$(WORKDIR)\agontimer.obj"
	@if exist "$(WORKDIR)\agontimer.lis"  \
            $(RM) "$(WORKDIR)\agontimer.lis"
	@if exist "$(WORKDIR)\agontimer.lst"  \
            $(RM) "$(WORKDIR)\agontimer.lst"
	@if exist "$(WORKDIR)\agontimer.src"  \
            $(RM) "$(WORKDIR)\agontimer.src"
	@if exist "$(WORKDIR)\agontimer-timer0.obj"  \
            $(RM) "$(WORKDIR)\agontimer-timer0.obj"
	@if exist "$(WORKDIR)\agontimer-timer0.lis"  \
            $(RM) "$(WORKDIR)\agontimer-timer0.lis"
	@if exist "$(WORKDIR)\agontimer-timer0.lst"  \
            $(RM) "$(WORKDIR)\agontimer-timer0.lst"

relist: 
	$(AS) $(ASFLAGS) -relist:"D:\AGON\snake\Debug\template.map" \
            D:\AGON\snake\init.asm
	$(AS) $(ASFLAGS) -relist:"D:\AGON\snake\Debug\template.map" \
            D:\AGON\snake\Debug\main.src
	$(AS) $(ASFLAGS) -relist:"D:\AGON\snake\Debug\template.map" \
            D:\AGON\snake\mos-interface.asm
	$(AS) $(ASFLAGS) -relist:"D:\AGON\snake\Debug\template.map" \
            D:\AGON\snake\Debug\vdp.src
	$(AS) $(ASFLAGS) -relist:"D:\AGON\snake\Debug\template.map" \
            D:\AGON\snake\Debug\agontimer.src
	$(AS) $(ASFLAGS) -relist:"D:\AGON\snake\Debug\template.map" \
            D:\AGON\snake\agontimer-timer0.asm

# pre-4.11.0 compatibility
rebuildall: buildall 

LIBS = 

OBJS =  \
            $(WORKDIR_ESCSPACE)\init.obj  \
            $(WORKDIR_ESCSPACE)\main.obj  \
            $(WORKDIR_ESCSPACE)\mos-interface.obj  \
            $(WORKDIR_ESCSPACE)\vdp.obj  \
            $(WORKDIR_ESCSPACE)\agontimer.obj  \
            $(WORKDIR_ESCSPACE)\agontimer-timer0.obj

snake: $(OBJS)
	 $(LD) $(LDFLAGS)

$(WORKDIR_ESCSPACE)\init.obj :  \
            $(PRJDIR_ESCSPACE)\init.asm
	 $(AS) $(ASFLAGS) "$(PRJDIR)\init.asm"

$(WORKDIR_ESCSPACE)\main.obj :  \
            $(PRJDIR_ESCSPACE)\main.c  \
            $(INCLUDE_ESCSPACE)\std\CTYPE.H  \
            $(INCLUDE_ESCSPACE)\std\Format.h  \
            $(INCLUDE_ESCSPACE)\std\Stdarg.h  \
            $(INCLUDE_ESCSPACE)\std\Stdio.h  \
            $(INCLUDE_ESCSPACE)\std\Stdlib.h  \
            $(INCLUDE_ESCSPACE)\std\String.h  \
            $(INCLUDE_ESCSPACE)\zilog\cio.h  \
            $(INCLUDE_ESCSPACE)\zilog\defines.h  \
            $(INCLUDE_ESCSPACE)\zilog\eZ80190.h  \
            $(INCLUDE_ESCSPACE)\zilog\eZ80F91.h  \
            $(INCLUDE_ESCSPACE)\zilog\eZ80F92.h  \
            $(INCLUDE_ESCSPACE)\zilog\eZ80F93.h  \
            $(INCLUDE_ESCSPACE)\zilog\eZ80L92.h  \
            $(INCLUDE_ESCSPACE)\zilog\ez80.h  \
            $(INCLUDE_ESCSPACE)\zilog\gpio.h  \
            $(INCLUDE_ESCSPACE)\zilog\uart.h  \
            $(INCLUDE_ESCSPACE)\zilog\uartdefs.h  \
            $(PRJDIR_ESCSPACE)\agontimer.h  \
            $(PRJDIR_ESCSPACE)\main.h  \
            $(PRJDIR_ESCSPACE)\mos-interface.h  \
            $(PRJDIR_ESCSPACE)\vdp.h
	 $(CC) $(CFLAGS) "$(PRJDIR)\main.c"

$(WORKDIR_ESCSPACE)\mos-interface.obj :  \
            $(PRJDIR_ESCSPACE)\mos-interface.asm  \
            $(PRJDIR_ESCSPACE)\mos_api.inc
	 $(AS) $(ASFLAGS) "$(PRJDIR)\mos-interface.asm"

$(WORKDIR_ESCSPACE)\vdp.obj :  \
            $(PRJDIR_ESCSPACE)\vdp.c  \
            $(INCLUDE_ESCSPACE)\zilog\defines.h  \
            $(PRJDIR_ESCSPACE)\mos-interface.h  \
            $(PRJDIR_ESCSPACE)\vdp.h
	 $(CC) $(CFLAGS) "$(PRJDIR)\vdp.c"

$(WORKDIR_ESCSPACE)\agontimer.obj :  \
            $(PRJDIR_ESCSPACE)\agontimer.c  \
            $(INCLUDE_ESCSPACE)\std\Format.h  \
            $(INCLUDE_ESCSPACE)\std\Stdarg.h  \
            $(INCLUDE_ESCSPACE)\std\Stdio.h  \
            $(INCLUDE_ESCSPACE)\zilog\cio.h  \
            $(INCLUDE_ESCSPACE)\zilog\defines.h  \
            $(INCLUDE_ESCSPACE)\zilog\eZ80190.h  \
            $(INCLUDE_ESCSPACE)\zilog\eZ80F91.h  \
            $(INCLUDE_ESCSPACE)\zilog\eZ80F92.h  \
            $(INCLUDE_ESCSPACE)\zilog\eZ80F93.h  \
            $(INCLUDE_ESCSPACE)\zilog\eZ80L92.h  \
            $(INCLUDE_ESCSPACE)\zilog\ez80.h  \
            $(INCLUDE_ESCSPACE)\zilog\gpio.h  \
            $(INCLUDE_ESCSPACE)\zilog\uart.h  \
            $(INCLUDE_ESCSPACE)\zilog\uartdefs.h  \
            $(PRJDIR_ESCSPACE)\agontimer.h  \
            $(PRJDIR_ESCSPACE)\mos-interface.h
	 $(CC) $(CFLAGS) "$(PRJDIR)\agontimer.c"

$(WORKDIR_ESCSPACE)\agontimer-timer0.obj :  \
            $(PRJDIR_ESCSPACE)\agontimer-timer0.asm  \
            $(INCLUDE_ESCSPACE)\zilog\ez80F92.inc
	 $(AS) $(ASFLAGS) "$(PRJDIR)\agontimer-timer0.asm"

