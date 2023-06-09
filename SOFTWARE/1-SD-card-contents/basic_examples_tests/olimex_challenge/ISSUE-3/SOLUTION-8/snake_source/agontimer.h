/*
 * Title:			AGON timer interface
 * Author:			Jeroen Venema
 * Created:			06/11/2022
 * Last Updated:	22/01/2023
 * 
 * Modinfo:
 * 06/11/2022:		Initial version
 * 22/01/2023:      Freerunning timer0 code added, needs interrupt handler code
 */

#include <defines.h>

#ifndef AGONTIMER_H
#define AGONTIMER_H

#define REL_1MS 1152
#define CLK_1MS 16

#define REL_7350 626
#define CLK_7350 4

extern volatile UINT24 timer0;
extern void	timer0_handler(void);

extern volatile UINT24 timer1;
extern void	timer1_handler(void);

//void timer0_begin(int interval);
void timer0_begin(int interval, int clkdiv);
void timer0_end(void);

void timer1_begin(int interval, int clkdiv);
void timer1_end(void);

void delayms(int ms);

#endif AGONTIMER_H
