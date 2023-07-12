/*
 * Title:			AGON MOS - Real Time Clock
 * Author:			Dean Belfield
 * Created:			09/03/2023
 * Last Updated:	05/06/2023
 * 
 * Modinfo:
 * 15/03/2023:		Added rtc_getDateString, rtc_update
 * 21/03/2023:		Uses VDP values from defines.h
 * 05/06/2023:		Added RTC enable flag
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

// Format a date/time string
//
void rtc_formatDateTime(char * buffer, int year, int month, int day, int dayOfWeek, int hour, int minute, int second) {
	sprintf(buffer, "%s, %02d/%02d/%4d %02d:%02d:%02d", rtc_days[dayOfWeek][0], day, month + 1, year + EPOCH_YEAR, hour, minute, second);
}