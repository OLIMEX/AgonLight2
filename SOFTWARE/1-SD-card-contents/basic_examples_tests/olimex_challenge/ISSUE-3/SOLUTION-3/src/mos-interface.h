/*
 * Title:			AGON MOS - MOS c header interface
 * Author:			Jeroen Venema
 * Created:			15/10/2022
 * Last Updated:	15/10/2022
 * 
 * Modinfo:
 * 15/10/2022:		Added putch, getch
 * 22/10/2022:		Added waitvblank, mos_f* functions
 * 10/01/2023:      Added getsysvar_cursorX/Y functions, removed generic getsysvar8/16/24bit functions
 * 25/03/2023:      Added MOS 1.03 functions / sysvars
 * 16/04/2023:      Added MOS 1.03RC4 mos_fread / mos_fwrite / mos_flseek functions
 */

#ifndef MOS_H
#define MOS_H

#include <defines.h>

// File access modes - from mos_api.inc
#define fa_read				    0x01
#define fa_write			    0x02
#define fa_open_existing	    0x00
#define fa_create_new		    0x04
#define fa_create_always	    0x08
#define fa_open_always		    0x10
#define fa_open_append		    0x30

// Indexes into sysvar - from mos_api.inc
#define sysvar_time			    0x00    // 4: Clock timer in centiseconds (incremented by 2 every VBLANK)
#define sysvar_vpd_pflags	    0x04    // 1: Flags to indicate completion of VDP commands
#define sysvar_keyascii		    0x05    // 1: ASCII keycode, or 0 if no key is pressed
#define sysvar_keymods		    0x06    // 1: Keycode modifiers
#define sysvar_cursorX		    0x07    // 1: Cursor X position
#define sysvar_cursorY		    0x08    // 1: Cursor Y position
#define sysvar_scrchar		    0x09    // 1: Character read from screen
#define sysvar_scrpixel		    0x0A    // 3: Pixel data read from screen (R,B,G)
#define sysvar_audioChannel	    0x0D    // 1: Audio channel
#define syscar_audioSuccess	    0x0E    // 1: Audio channel note queued (0 = no, 1 = yes)
#define sysvar_scrWidth	        0x0F	// 2: Screen width in pixels
#define sysvar_scrHeight	    0x11	// 2: Screen height in pixels
#define sysvar_scrCols		    0x13	// 1: Screen columns in characters
#define sysvar_scrRows		    0x14	// 1: Screen rows in characters
#define sysvar_scrColours	    0x15	// 1: Number of colours displayed
#define sysvar_scrpixelIndex    0x16	// 1: Index of pixel data read from screen
#define sysvar_vkeycode	        0x17	// 1: Virtual key code from FabGL
#define sysvar_vkeydown			0x18	// 1: Virtual key state from FabGL (0=up, 1=down)
#define sysvar_vkeycount	    0x19	// 1: Incremented every time a key packet is received
#define sysvar_rtc		        0x1A	// 8: Real time clock data
#define sysvar_keydelay	        0x22	// 2: Keyboard repeat delay
#define sysvar_keyrate		    0x24	// 2: Keyboard repeat reat
#define sysvar_keyled		    0x26	// 1: Keyboard LED status

// Flags for the VPD protocol - sysvar_vpd_pflags
#define vdp_pflag_cursor        0x01
#define vdp_pflag_scrchar       0x02
#define vdp_pflag_point         0x04
#define vdp_pflag_audio         0x08
#define vdp_pflag_mode          0x10
#define vdp_pflag_rtc           0x20

// UART settings for open_UART1
//
typedef struct {
   INT24 baudRate ;				//!< The baudrate to be used.
   BYTE dataBits ;				//!< The number of databits per character to be used.
   BYTE stopBits ;				//!< The number of stopbits to be used.
   BYTE parity ;				   //!< The parity bit option to be used.
   BYTE flowcontrol ;
   BYTE eir ;
} UART ;

// Generic IO
extern int   putch(int a);
extern char  getch(void);
extern void  waitvblank(void);
extern void  mos_puts(char * buffer, UINT24 size, char delimiter);

// Get system variables
extern UINT8  getsysvar_vpd_pflags();
extern UINT8  getsysvar_keyascii();
extern UINT8  getsysvar_keymods();
extern UINT8  getsysvar_cursorX();
extern UINT8  getsysvar_cursorY();
extern UINT8  getsysvar_scrchar();
extern UINT24 getsysvar_scrpixel();
extern UINT8  getsysvar_audioChannel();
extern UINT8  getsysvar_audioSuccess();
extern UINT16 getsysvar_scrwidth();
extern UINT16 getsysvar_scrheight();
extern UINT8  getsysvar_scrCols();
extern UINT8  getsysvar_scrRows();
extern UINT8  getsysvar_scrColours();
extern UINT8  getsysvar_scrpixelIndex();
extern UINT8  getsysvar_vkeycode();
extern UINT8  getsysvar_vkeydown();
extern UINT8  getsysvar_vkeycount();
extern UINT8* getsysvar_rtc();
extern UINT16 getsysvar_keydelay();
extern UINT16 getsysvar_keyrate();
extern UINT8  getsysvar_keyled();

// MOS API calls
extern UINT8  mos_load(char *filename, UINT24 address, UINT24 maxsize);
extern UINT8  mos_save(char *filename, UINT24 address, UINT24 nbytes);
extern UINT8  mos_cd(char *path);
extern UINT8  mos_dir(char *path);
extern UINT8  mos_del(char *filename);
extern UINT8  mos_ren(char *filename, char *newname);
extern UINT8  mos_copy(char *source, char *destination);
extern UINT8  mos_mkdir(char *path);
extern UINT8* mos_sysvars(void);
extern UINT8  mos_editline(char *buffer, UINT24 bufferlength, UINT8 clearbuffer);
extern UINT8  mos_fopen(char * filename, UINT8 mode); // returns filehandle, or 0 on error
extern UINT8  mos_fclose(UINT8 fh);					 // returns number of still open files
extern char	  mos_fgetc(UINT8 fh);					 // returns character from file
extern void	  mos_fputc(UINT8 fh, char c);			 // writes character to file
extern UINT8  mos_feof(UINT8 fh);					 // returns 1 if EOF, 0 otherwise
extern void   mos_getError(UINT8 code, char *buffer, UINT24 bufferlength);
extern UINT8  mos_oscli(char *command, char **argv, UINT24 argc);
extern UINT8  mos_getrtc(char *buffer);
extern void   mos_setrtc(UINT8 *timedata);
extern void*  mos_setintvector(UINT8 vector, void(*handler)(void));
extern UINT8  mos_uopen(UART *settings);
extern void   mos_uclose(void);
extern int    mos_ugetc(void);                      // 0-255 valid character - >255 error
extern UINT8  mos_uputc(int a);                     // returns 0 if error
extern UINT24 mos_fread(UINT8 fh, char *buffer, UINT24 numbytes);
extern UINT24 mos_fwrite(UINT8 fh, char *buffer, UINT24 numbytes);
extern UINT8  mos_flseek(UINT8 fh, UINT32 offset);
#endif MOS_H