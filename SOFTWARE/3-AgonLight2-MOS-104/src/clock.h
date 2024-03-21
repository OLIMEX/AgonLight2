/*
 * Title:			AGON MOS - Real Time Clock
 * Author:			Dean Belfield
 * Created:			09/03/2023
 * Last Updated:	26/09/2023
 *
 * Modinfo:
 * 15/03/2023:		Added rtc_getDateString, rtc_update
 * 26/09/2023:		Timestamps now packed into 6 bytes
 */

#ifndef RTC_H
#define RTC_H

#define EPOCH_YEAR	1980

// RTC time structure
//
typedef struct {
	UINT16 year;
	UINT8  month;
	UINT8  day;
	UINT8  dayOfWeek;
	UINT16 dayOfYear;
	UINT8  hour;
	UINT8  minute;
	UINT8  second;
} vdp_time_t;

void init_rtc();           				// In rtc.asm

void rtc_update();
void rtc_unpack(UINT8 * buffer, vdp_time_t * t);
void rtc_formatDateTime(char * buffer, vdp_time_t * t);

#endif RTC_H
