/*
 * Title:			AGON MOS - MOS code
 * Author:			Dean Belfield
 * Created:			10/07/2022
 * Last Updated:	15/04/2023
 * 
 * Modinfo:
 * 11/07/2022:		Removed mos_cmdBYE, Added mos_cmdLOAD
 * 12/07/2022:		Added mos_cmdJMP
 * 13/07/2022:		Added mos_cmdSAVE
 * 14/07/2022:		Added mos_cmdRUN
 * 24/07/2022:		Added mos_getkey
 * 03/08/2022:		Added a handful of MOS API calls
 * 05/08/2022:		Added mos_FEOF
 * 05/09/2022:		Added mos_cmdREN, mos_cmdBOOT; moved mos_EDITLINE into mos_editline.c
 * 25/09/2022:		Added mos_GETERROR, mos_MKDIR
 * 13/10/2022:		Added mos_OSCLI and supporting code
 * 20/10/2022:		Tweaked error handling
 * 13/11/2022:		Added mos_cmp
 * 21/11/2022:		Added support for passing params to executables & ADL mode
 * 14/02/2023:		Added mos_cmdVDU
 * 20/02/2023:		Function mos_getkey now returns a BYTE
 * 09/03/2023:		Added mos_cmdTIME, mos_cmdCREDITS, mos_DIR now accepts a path
 * 14/03/2023:		Added mos_cmdCOPY and mos_COPY
 * 15/03/2023:		Added mos_GETRTC, mos_SETRTC
 * 21/03/2023:		Added mos_SETINTVECTOR
 * 14/04/2023:		Added fat_EOF
 * 15/04/2023:		Added mos_GETFIL, mos_FREAD, mos_FWRITE, mos_FLSEEK
 */

#ifndef MOS_H
#define MOS_H

#include "ff.h"

typedef struct {
	char * name;
	int (*func)(char * ptr);
} t_mosCommand;

typedef struct {
	UINT8	free;
	FIL		fileObject;
} t_mosFileObject;

void 	mos_error(int error);

BYTE	mos_getkey(void);
UINT24	mos_input(char * buffer, int bufferLength);
void *	mos_getCommand(char * ptr);
BOOL 	mos_cmp(char *p1, char *p2);
char *	mos_strtok(char *s1, char * s2);
char *	mos_strtok_r(char *s1, const char *s2, char **ptr);
int		mos_exec(char * buffer);
UINT8 	mos_execMode(UINT8 * ptr);


BOOL 	mos_parseNumber(char * ptr, UINT24 * p_Value);
BOOL	mos_parseString(char * ptr, char ** p_Value);

int		mos_cmdDIR(char * ptr);
int		mos_cmdLOAD(char * ptr);
int 	mos_cmdSAVE(char *ptr);
int		mos_cmdDEL(char * ptr);
int		mos_cmdJMP(char * ptr);
int		mos_cmdRUN(char * ptr);
int		mos_cmdCD(char * ptr);
int		mos_cmdREN(char *ptr);
int		mos_cmdCOPY(char *ptr);
int		mos_cmdMKDIR(char *ptr);
int		mos_cmdSET(char *ptr);
int		mos_cmdVDU(char *ptr);
int		mos_cmdTIME(char *ptr);
int		mos_cmdCREDITS(char *ptr);

UINT24	mos_LOAD(char * filename, UINT24 address, UINT24 size);
UINT24	mos_SAVE(char * filename, UINT24 address, UINT24 size);
UINT24	mos_CD(char * path);
UINT24	mos_DIR(char * path);
UINT24	mos_DEL(char * filename);
UINT24 	mos_REN(char * filename1, char * filename2);
UINT24	mos_COPY(char * filename1, char * filename2);
UINT24	mos_MKDIR(char * filename);
UINT24 	mos_BOOT(char * filename, char * buffer, UINT24 size);

UINT24	mos_FOPEN(char * filename, UINT8 mode);
UINT24	mos_FCLOSE(UINT8 fh);
UINT8	mos_FGETC(UINT8 fh);
void	mos_FPUTC(UINT8 fh, char c);
UINT24	mos_FREAD(UINT8 fh, UINT24 buffer, UINT24 btr);
UINT24	mos_FWRITE(UINT8 fh, UINT24 buffer, UINT24 btw);
UINT8  	mos_FLSEEK(UINT8 fh, UINT32 offset);
UINT8	mos_FEOF(UINT8 fh);

void 	mos_GETERROR(UINT8 errno, UINT24 address, UINT24 size);
UINT24 	mos_OSCLI(char * cmd);
UINT8 	mos_GETRTC(UINT24 address);
void	mos_SETRTC(UINT24 address);
UINT24	mos_SETINTVECTOR(UINT8 vector, UINT24 address);
UINT24	mos_GETFIL(UINT8 fh);

UINT8	fat_EOF(FIL * fp);

#endif MOS_H