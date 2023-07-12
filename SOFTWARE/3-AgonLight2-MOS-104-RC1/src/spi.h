/*
 * Title:			AGON MOS - SPI
 * Author:			Cocoacrumbs
 * Modified by:		Dean Belfield
 * Created:			19/06/2022
 * Last Updated:	11/07/2022
 *
 * Modinfo:
 * 11/07/2022:		Now includes defines.h; init_hw renamed to init_spi
 */

#ifndef SPI_H
#define SPI_H

void init_spi();
void mode_spi(int d);

BYTE spi_transfer(BYTE d);

void SD_CS_enable();
void SD_CS_disable();

#endif SPI_H
