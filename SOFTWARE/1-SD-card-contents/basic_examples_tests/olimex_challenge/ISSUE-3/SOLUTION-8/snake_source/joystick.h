/*
 * Title:			AGON joystick header interface
 * Author:			Jeroen Venema
 * Created:			06/11/2022
 * Last Updated:	06/11/2022
 * 
 * Modinfo:
 * 06/11/2022:		Initial version
 */

#include <defines.h>

#ifndef JOYSTICK_H
#define JOYSTICK_H

extern void initjoystickpins(void);
extern UINT16 joyread(void);
extern void wait1ms(void);

#endif JOYSTICK_H
