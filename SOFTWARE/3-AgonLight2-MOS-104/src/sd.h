/*
 * Title:			AGON MOS - Low level SD card functionality
 * Author:			RJH
 * Modified By:		Dean Belfield
 * Created:			19/06/2022
 * Last Updated:	08/11/2023
 *
 * Modinfo:
 * 08/11/2023:		Removed redundant defines and function prototypes
 */

#ifndef SD_H
#define SD_H

#define SD_SUCCESS  0
#define SD_ERROR    1
#define SD_READY	0

BYTE	SD_readBlocks(DWORD addr, BYTE *buf, WORD count);
BYTE	SD_writeBlocks(DWORD addr, BYTE *buf, WORD count);

BYTE	SD_init();

#endif SD_H
