#include <string.h>
#include "mos-setvector.h"

// MOS setvector routine in ROM
#define MOS102_SETVECTOR	   0x000956		// as assembled in MOS 1.02, until set_vector becomes a API call in a later MOS version
#define MOS102_FP_SIZE			     26		// 26 bytes to check from the SET_VECTOR address, kludgy, but works for now
extern char mos102_setvector_fingerprint; // needs to be extern to C, in assembly DB with a label, or the ZDS C compiler will put it in ROM space

typedef void * rom102_set_vector(unsigned int vector, void(*handler)(void));

BOOL MOS_SV_Check(void)
{
	// Check for MOS 1.02 fingerprint
	return !(memcmp((char *)MOS102_SETVECTOR,&mos102_setvector_fingerprint,MOS102_FP_SIZE)); // needs exact fingerprint match
}

void* mos_setvector(unsigned int vector, void(*handler)(void))
{
   	void *oldvector;
	rom102_set_vector *set_vector = (rom102_set_vector *)MOS102_SETVECTOR; // cast to address

   	oldvector = set_vector(vector, handler);	// register interrupt handler

    return oldvector;
}