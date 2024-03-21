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

BYTE spi_transfer(BYTE d);
BYTE spi_read_one(void);
void spi_read(char *buf, unsigned int len);
void spi_write(char *buf, unsigned int len);

#endif SPI_H
