/*
 * Title:			AGON MOS - MOS c setvector interface
 * Author:			Jeroen Venema
 * Created:			21/01/2023
 * Last Updated:	21/01/2023
 * 
 * Modinfo:
 */

#ifndef MOSSETVECTOR_H
#define MOSSETVECTOR_H

#include <defines.h>

// MOS setvector version check
// returns true if fingerprint compatible
BOOL MOS_SV_Check(void);            

// Helper function to set the interrupt vector
// vector: maskable interrupt, see page 45 of https://ixapps.ixys.com/DataSheet/ps0153.pdf
// handler: interrupt handler to be registered to the given maskable interrupt vector
// returns the previously registered handler
void* mos_setvector(unsigned int vector, void(*handler)(void));

#endif MOSSETVECTOR_H