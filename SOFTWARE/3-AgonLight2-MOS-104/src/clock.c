/*
 * Title:			AGON MOS - Real Time Clock
 * Author:			Dean Belfield
 * Created:			09/03/2023
 * Last Updated:	26/09/2023
 * 
 * Modinfo:
 * 15/03/2023:		Added rtc_getDateString, rtc_update
 * 21/03/2023:		Uses VDP values from defines.h
 * 05/06/2023:		Added RTC enable flag
 * 26/09/2023:		Timestamps now packed into 6 bytes
 */

#include <ez80.h>
#include <defines.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "defines.h"
#include "uart.h"
#include "clock.h"

extern volatile BYTE vpd_protocol_flags;		// In globals.asm
extern volatile BYTE rtc_enable;				// In globals.asm

const char * rtc_days[7][2] = {	
	{ "Sun", "Sunday" },
	{ "Mon", "Monday" },
	{ "Tue", "Tuesday" },
	{ "Wed", "Wednesday" },
	{ "Thu", "Thursday" },
	{ "Fri", "Friday" },
	{ "Sat", "Saturday" },
};

const char * rtc_months[12][2] = {
	{ "Jan", "January" },
	{ "Feb", "February" },
	{ "Mar", "March" },
	{ "Apr", "April" },
	{ "May", "May" },
	{ "Jun", "June" },
	{ "Jul", "July" },
	{ "Aug", "August" },
	{ "Sep", "September" },
	{ "Oct", "October" },
	{ "Nov", "November" },
	{ "Dec", "December" },
};

// Request an update of the RTC from the ESP32
//
void rtc_update() {
	if(!rtc_enable) {
		return;
	}
	vpd_protocol_flags &= 0xDF;	// Reset bit 5

	putch(23);					// Request the time from the ESP32
	putch(0);
	putch(VDP_rtc);
	putch(0);					// 0: Get time

	while((vpd_protocol_flags & 0x20) == 0);	
}

// Unpack a 6-byte RTC packet into time struct
// Parameters:
// - buffer: Pointer to the RTC packet data
// - t: Pointer to the time structure to populate
// 
void rtc_unpack(UINT8 * buffer, vdp_time_t * t) {
	UINT32	d = *(UINT32 *)buffer;

	t->month =		(d & 0x0000000F);		// uint32_t month : 4; 		00000000 00000000 00000000 0000xxxx : 00 00 00 0F >> 0
	t->day =		(d & 0x000001F0) >> 4;	// uint32_t day : 5;		00000000 00000000 0000000x xxxx0000 : 00 00 01 F0 >> 4
	t->dayOfWeek = 	(d & 0x00000E00) >> 9;	// uint32_t dayOfWeek : 3;	00000000 00000000 0000xxx0 00000000 : 00 00 0E 00 >> 9
	t->dayOfYear = 	(d & 0x001FF000) >> 12;	// uint32_t dayOfYear : 9;	00000000 000xxxxx xxxx0000 00000000 : 00 1F F0 00 >> 12
	t->hour = 		(d & 0x03E00000) >> 21;	// uint32_t hour : 5;		000000xx xxx00000 00000000 00000000 : 03 E0 00 00 >> 21
	t->minute =		(d & 0xFC000000) >> 26;	// uint32_t minute : 6;		xxxxxx00 00000000 00000000 00000000 : FC 00 00 00 >> 26

	t->second = buffer[4];
	t->year = (char)buffer[5] + EPOCH_YEAR ;
}

// Format a date/time string
//
void rtc_formatDateTime(char * buffer, vdp_time_t * t) {
	sprintf(buffer, "%s, %02d/%02d/%4d %02d:%02d:%02d", rtc_days[t->dayOfWeek][0], t->day, t->month + 1, t->year, t->hour, t->minute, t->second);
}