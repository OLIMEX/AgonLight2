/*
 * Title:			AGON MOS - MOS line editor
 * Author:			Dean Belfield
 * Created:			18/09/2022
 * Last Updated:	22/03/2023
 * 
 * Modinfo:
 * 28/09/2022:		Added clear parameter to mos_EDITLINE
 * 22/03/2023:		Added defines for command history
 */

#ifndef MOS_EDITOR_H
#define MOS_EDITOR_H

#define cmd_historyWidth	255

UINT24	mos_EDITLINE(char * filename, int bufferLength, UINT8 clear);

#endif MOS_EDITOR_H