/*
 * Title:			AGON MOS - SPI
 * Author:			Cocoacrumbs
 * Modified by:		Dean Belfield
 * Created:			19/06/2022
 * Last Updated:	11/07/2022
 * 
 * Thank you to @CoCoaCrumbs fo this code https://www.cocoacrumbs.com/
 *
 * Modinfo:
 * 11/07/2022:		Now includes defines.h; init_hw renamed to init_spi
 */

#include <ez80.h>
#include <defines.h>

#include "spi.h"
#include "timer.h"

// Delays, SPI and SD card retry constants 
//
#define WAIT4RESET  8000
#define SPIRETRY    1000

#define SD_CS       4	// PB4, was PB0

#define SPI_MOSI    7   // PB7
#define SPI_MISO    6   // PB6
#define SPI_CLK     3   // PB3


// Clear, set bits in registers
//
#define BIT(n)              (1 << n)
#define CLEAR_BIT(reg, n)   (reg &= ~(1 << n))
#define SET_BIT(reg, n)     (reg |=  (1 << n))

void SD_CS_enable() {
     PB_DR &= ~BIT(SD_CS);
} 

void SD_CS_disable() {
     PB_DR |= BIT(SD_CS); 
} 

BYTE spi_transfer(BYTE d) {
    int i = 0;

    // Write the data to exchange 
	//
    SPI_TSR = d;
    do {
        if (SPI_SR & (1 << 7))  {
            break;
        } 
        i++;
    } while (i < SPIRETRY);
    return SPI_RBR;
} 


// Reset system devices
void init_spi() {
    long i;

    // SS must remain high for SPI to work properly 
	//
    PB_DR   |=  BIT(2);
    PB_ALT1 &= ~BIT(2);
    PB_ALT2 &= ~BIT(2);
    PB_DDR  &= ~BIT(2);

    // Enable the chip select outputs and deselect
	//
    PB_DR   |=  BIT(SD_CS);
    PB_ALT1 &= ~BIT(SD_CS);
    PB_ALT2 &= ~BIT(SD_CS);
    PB_DDR  &= ~BIT(SD_CS);
	
    // Set port B pins 7 (MOSI), 6 (MISO), 3 (SCK), 2 (/SS) to SPI 
	//
    PB_ALT1 &= ~(BIT(SPI_MOSI) | BIT(SPI_MISO) | BIT(SPI_CLK));
    PB_ALT2 |=  (BIT(SPI_MOSI) | BIT(SPI_MISO) | BIT(SPI_CLK));
	
    mode_spi(4);

    i = 0;
    while (i < WAIT4RESET)
        i++;
} 


void mode_spi(int d) {
    // Disable SPI
	//
    SPI_CTL = 0;

    // SPI Data Rate (bps) = System Clock Frequency / (2 X SPI Baud Rate Generator Divisor)
	//
    SPI_BRG_H = d / 256;
    SPI_BRG_L = d % 256;

    // Enable SPI
	//
    SPI_CTL = 0x30;         // [5] SPI is enabled.
                            // [4] When enabled, the SPI operates as a master.
} 
