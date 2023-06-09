/*
 * Title:			AGON MOS - Real Time Clock
 * Author:			Dean Belfield
 * Created:			09/03/2023
 * Last Updated:	15/03/2023
 *
 * Modinfo:
 * 15/03/2023:		Added rtc_getDateString, rtc_update
 */

#ifndef RTC_H
#define RTC_H

#define EPOCH_YEAR	1980

void init_rtc();           				// In rtc.asm

void rtc_update();
void rtc_formatDateTime(char * buffer, int year, int month, int day, int dayOfWeek, int hour, int minute, int second);

#endif RTC_H
