/*
 * Title:			AGON Low level disk I/O module for FatFs 
 * Modified By:		Dean Belfield
 * Created:			19/06/2022
 * Last Updated:	15/03/2023
 *
 * Credits:
 * Based upon a skeleton framework (C)ChaN, 2019
 *
 * Modinfo:
 * 11/07/2023:		Tweaked to compile without ZDL enabled in project settings
 * 15/03/2023:		Added get_fattime
 */

#include "ff.h"			// Obtains integer types
#include "diskio.h"		// Declarations of disk functions

#include "sd.h"			// Physical SD card layer for eZ80
#include "clock.h"		// Clock for timestamp

extern BYTE rtc;		// In globals.asm

// Get Drive Status (Not implemented in AGON)
// Parameters:
// - pdrv: Physical drive number to identify the drive
// Returns:
// - DSTATUS
// 
DSTATUS disk_status(BYTE pdrv) {
	return 0;
}

// Initialise a drive
// Parameters:
// - pdrv: Physical drive number to identify the drive
// Returns:
// - DSTATUS
//
DSTATUS disk_initialize(BYTE pdrv) {
	BYTE err = SD_init();
	if(err == SD_SUCCESS) {
		return RES_OK;
	}
	return RES_ERROR;
}

// Read Sector(s)
// Parameters:
// - pdrv: Physical drive nmuber to identify the drive
// - buff: Data buffer to store read data
// - sector: Start sector in LBA
// - count: Number of sectors to read
// Returns:
// - DSTATUS
//
DRESULT disk_read(BYTE pdrv, BYTE *buff, LBA_t sector, UINT count) {
	BYTE err = SD_readBlocks(sector, buff, count);
	if(err == SD_SUCCESS) {
		return RES_OK;
	}
	return RES_ERROR;
}

#if FF_FS_READONLY == 0

// Write Sector(s)
// Parameters:
// - pdrv: Physical drive nmuber to identify the drive
// - buff: Data to be written
// - sector: Start sector in LBA
// - count: Number of sectors to write
// Returns:
// - DSTATUS
//
DRESULT disk_write(BYTE pdrv, const BYTE *buff, LBA_t sector, UINT count){
	BYTE err = SD_writeBlocks(sector, buff, count);
	if(err == SD_SUCCESS) {
		return RES_OK;
	}
	
	return RES_ERROR;
}

#endif

// Disk I/O Control (Not implemented in AGON)
// Parameters:
// - pdrv: Physical drive nmuber (0..)
// - cmd: Control code
// - buff: Buffer to send/receive control data
// Returns:
// - DSTATUS
//
DRESULT disk_ioctl(BYTE pdrv, BYTE cmd, void *buff) {
	return RES_OK;
}

// Get RTC time for filestamps
// Returns:
// - TIME (bit packed)
//
//    0 to  4: Seconds/2 (0 to 29)
//    5 to 10: Minutes (0 to 59)
//   11 to 15: Hours (0 to 23)
//   16 to 20: Day of Month (1 to 31)
//   21 to 24: Month (1 to 12)
//   25 to 31: Year-1980 (0 to 127)
//
DWORD get_fattime(void) {
	DWORD	yr, mo, da, hr, mi, se;
	BYTE *	p = &rtc;

	rtc_update();

	yr =  *(p+0)    << 25;
	mo = (*(p+1)+1) << 21;
	da =  *(p+2)    << 16;
	hr =  *(p+5)    << 11;
	mi =  *(p+6)    <<  5;
	se =  *(p+7)    >>  1;

	return se | mi | hr | da | mo | yr;
}
