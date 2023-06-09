/*
 * Title:			AGON timer interface
 * Author:			Jeroen Venema
 * Created:			06/11/2022
 * Last Updated:	22/01/2023
 * 
 * Modinfo:
 * 06/11/2022:		Initial version
 * 22/01/2023:		Interrupt-based freerunning functions added for timer0
 * 10/04/2023:		Using mos_setintvector
 */

#include <defines.h>
#include <ez80.h>
#include "agontimer.h"
#include "mos-interface.h"

#define TMR0_COUNTER_1ms	(unsigned short)(((18432000 / 1000) * 1) / 16)

void *_timer0_prevhandler;						// used to (re)store the previous handler for the interrupt

// start timer0 on a millisecond interval
// this function registers an interrupt handler and requires timer0_end to de-register the handler after use
void timer0_begin(int interval)
{
	unsigned char tmp;
	unsigned short rr;
	
	_timer0_prevhandler = mos_setintvector(PRT0_IVECT, timer0_handler);

	timer0 = 0;
	TMR0_CTL = 0x00;
	rr = (unsigned short)(((18432000 / 1000) * interval) / 16);
	TMR0_RR_H = (unsigned char)(rr >> 8);
	TMR0_RR_L = (unsigned char)(rr);
	tmp = TMR0_CTL;
    TMR0_CTL = 0x57;
}

void timer0_end(void)
{
	TMR0_CTL = 0;
	mos_setintvector(PRT0_IVECT, _timer0_prevhandler);
}

// delay for number of ms using TMR0
// this routine doesn't use the interrupt handler for TMR0
void delayms(int ms)
{
	unsigned short rr;
	UINT16 timer0;

	rr = TMR0_COUNTER_1ms - 19;	// 1,7% correction for cycles during while(ms) loop
	
	TMR0_CTL = 0x00;	// disable timer0
	
	while(ms)
	{	
		TMR0_RR_H = (unsigned char)(rr >> 8);
		TMR0_RR_L = (unsigned char)(rr);
				
		TMR0_CTL = 0x87; // enable, single pass, stop at 0, start countdown immediately
		do
		{
			timer0 = TMR0_DR_L;
			timer0 = timer0 | (TMR0_DR_H << 8);		
		}
		while(timer0);
		ms--;
	}
}