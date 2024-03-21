/*
 * Title:			AGON MOS - MOS code
 * Author:			Dean Belfield
 * Created:			10/07/2022
 * Last Updated:	11/11/2023
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
 * 30/05/2023:		Function mos_FGETC now returns EOF flag
 * 08/07/2023		Added mos_trim function
 * 11/11/2023:		Added mos_cmdHELP, mos_cmdTYPE, mos_cmdCLS, mos_cmdMOUNT
 */

#ifndef MOS_H
#define MOS_H

#include "ff.h"

typedef struct {
	char * name;
	int (*func)(char * ptr);
	char * args;
	char * help;
	char * aliases;
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
char *	mos_trim(char * s);
char *	mos_strtok(char *s1, char * s2);
char *	mos_strtok_r(char *s1, const char *s2, char **ptr);
int		mos_exec(char * buffer);
UINT8 	mos_execMode(UINT8 * ptr);

int		mos_mount(void);

BOOL 	mos_parseNumber(char * ptr, UINT24 * p_Value);
BOOL	mos_parseString(char * ptr, char ** p_Value);

int		mos_cmdDIR(char * ptr);
int		mos_cmdLOAD(char * ptr);
int		mos_cmdSAVE(char *ptr);
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
int		mos_cmdTYPE(char *ptr);
int		mos_cmdCLS(char *ptr);
int		mos_cmdMOUNT(char *ptr);
int		mos_cmdHELP(char *ptr);

UINT24	mos_LOAD(char * filename, UINT24 address, UINT24 size);
UINT24	mos_SAVE(char * filename, UINT24 address, UINT24 size);
UINT24	mos_TYPE(char * filename);
UINT24	mos_CD(char * path);
UINT24	mos_DIR(char * path);
UINT24	mos_DEL(char * filename);
UINT24 	mos_REN(char * filename1, char * filename2);
UINT24	mos_COPY(char * filename1, char * filename2);
UINT24	mos_MKDIR(char * filename);
UINT24 	mos_BOOT(char * filename, char * buffer, UINT24 size);

UINT24	mos_FOPEN(char * filename, UINT8 mode);
UINT24	mos_FCLOSE(UINT8 fh);
UINT24	mos_FGETC(UINT8 fh);
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

#define HELP_CAT			"Directory listing of the current directory\r\n"
#define HELP_CAT_ARGS		"<path>"
#define HELP_CAT_ALIASES	"DIR and ."
#define HELP_DIR_ALIASES	"CAT and ."
#define HELP_DOT_ALIASES	"CAT and DIR"

#define HELP_CD				"Change current directory\r\n"
#define HELP_CD_ARGS		"<path>"

#define HELP_COPY			"Create a copy of a file\r\n"
#define HELP_COPY_ARGS		"<filename1> <filename2>"

#define HELP_CREDITS		"Output credits and version numbers for\r\n" \
							"third-party libraries used in the Agon firmware\r\n"

#define HELP_DELETE			"Delete a file or folder (must be empty)\r\n"
#define HELP_DELETE_ARGS	"<filename>"
#define HELP_DELETE_ALIASES	"ERASE"
#define HELP_ERASE_ALIASES	"DELETE"

#define HELP_JMP			"Jump to the specified address in memory\r\n"
#define HELP_JMP_ARGS		"<addr>"

#define HELP_LOAD			"Load a file from the SD card to the specified address.\r\n" \
							"If no `addr` parameter is passed it will" \
							"default to &40000\r\n"
#define HELP_LOAD_ARGS		"<filename> [<addr>]"

#define HELP_MKDIR			"Create a new folder on the SD card\r\n"
#define HELP_MKDIR_ARGS		"<filename>"

#define HELP_RENAME			"Rename a file in the same folder\r\n"
#define HELP_RENAME_ARGS	"<filename1> <filename2>"
#define HELP_RENAME_ALIASES	"MOVE"
#define HELP_MOVE_ALIASES	"RENAME"

#define HELP_RUN			"Call an executable binary loaded in memory.\r\n" \
							"If no parameters are passed, then addr will " \
							"default to &40000.\r\n"
#define HELP_RUN_ARGS		"[<addr>]"

#define HELP_SAVE			"Save a block of memory to the SD card\r\n"
#define HELP_SAVE_ARGS		"<filename> <addr> <size>"

#define HELP_SET			"Set a system option\r\n\r\n" \
							"Keyboard Layout\r\n" \
							"SET KEYBOARD n: Set the keyboard layout\r\n" \
							"    0: UK (default)\r\n" \
							"    1: US\r\n" \
							"    2: German\r\n" \
							"    3: Italian\r\n" \
							"    4: Spanish\r\n" \
							"    5: French\r\n" \
							"    6: Belgian\r\n" \
							"    7: Norwegian\r\n" \
							"    8: Japanese\r\n" \
							"    9: US International\r\n" \
							"   10: US International (alternative)\r\n" \
							"   11: Swiss (German)\r\n" \
							"   12: Swiss (French)\r\n" \
							"   13: Danish\r\n" \
							"   14: Swedish\r\n" \
							"   15: Portuguese\r\n\r\n" \
							"Serial Console\r\n" \
							"SET CONSOLE n: Serial console\r\n" \
							"    0: Console off (default)\r\n" \
							"    1: Console on\r\n"
#define HELP_SET_ARGS		"<option> <value>"

#define HELP_TIME			"Set and read the ESP32 real-time clock\r\n"
#define HELP_TIME_ARGS		"[ <yyyy> <mm> <dd> <hh> <mm> <ss> ]"

#define HELP_VDU			"Write a stream of characters to the VDP\r\n" \
							"Character values are converted to bytes before sending\r\n"
#define HELP_VDU_ARGS		"<char1> <char2> ... <charN>"

#define HELP_TYPE			"Display the contents of a file on the screen\r\n"
#define HELP_TYPE_ARGS		"<filename>"

#define HELP_CLS			"Clear the screen\r\n"

#define HELP_MOUNT			"(Re-)mount the MicroSD card\r\n"

#define HELP_HELP			"Display help on a single or all commands.\r\n"	\
							"List of commands:\r\n" \
							"CAT, CD, COPY, CREDITS, DELETE, JMP, \r\n"	\
							"LOAD, MKDIR, RENAME, RUN, SAVE, SET, \r\n"	\
							"TIME, VDU, TYPE, CLS, MOUNT, HELP.\r\n"
#define HELP_HELP_ARGS		"[ <command> | all ]"

#endif MOS_H
