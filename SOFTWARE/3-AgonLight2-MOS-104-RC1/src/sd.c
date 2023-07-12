/*
 * Title:			AGON MOS - Low level SD card functionality
 * Author:			RJH
 * Modified by:		Dean Belfield
 * Created:			19/06/2022
 * Last Updated:	09/03/2023
 * 
 * Code taken from this article: http://www.rjhcoding.com/avrc-sd-interface-1.php
 *
 * Modinfo:
 * 11/07/2022:		Now includes defines.h
 * 13/07/2022:		Fixed bug in SD_writeBlocks
 * 09/03/2023:      Now uses wait_timer0
 */

#include <eZ80.h>
#include <defines.h>

#include <stdio.h>
#include <String.h>

#include "spi.h"
#include "sd.h"
#include "timer.h"

void SD_command(BYTE cmd, DWORD arg, BYTE crc) {
    spi_transfer(cmd|0x40);
    spi_transfer((BYTE)(arg >> 24));
    spi_transfer((BYTE)(arg >> 16));
    spi_transfer((BYTE)(arg >> 8));
    spi_transfer((BYTE)(arg));
    spi_transfer(crc|0x01);
}

BYTE SD_readRes1() {
    BYTE i = 0, res1;

    // keep polling until actual data received
    while((res1 = spi_transfer(0xFF)) == 0xFF) {
        i++;
        // if no data received for 8 bytes, break
        if(i > 8) break;
    }
    return res1;
}

void SD_readRes7(BYTE *res) {
    res[0] = SD_readRes1();

    // if error reading R1, return
    if(res[0] > 1) return;

    // read remaining bytes
    res[1] = spi_transfer(0xFF);
    res[2] = spi_transfer(0xFF);
    res[3] = spi_transfer(0xFF);
    res[4] = spi_transfer(0xFF);
}

BYTE SD_goIdleState() {
	BYTE res1;
//  printf("SD_goIdleState()\n");
    spi_transfer(0xFF);
    SD_CS_enable();
    spi_transfer(0xFF);
    SD_command(CMD0, CMD0_ARG, CMD0_CRC);
    res1 = SD_readRes1();
    spi_transfer(0xFF);
    SD_CS_disable();
    spi_transfer(0xFF);
    return res1;
}

void SD_sendIfCond(BYTE *res) {
//  printf("SD_sendIfCond()\n");
    spi_transfer(0xFF);
    SD_CS_enable();
    spi_transfer(0xFF);
    SD_command(CMD8, CMD8_ARG, CMD8_CRC);
    SD_readRes7(res);
    spi_transfer(0xFF);
    SD_CS_disable();
    spi_transfer(0xFF);
}

UINT8 SD_sendApp() {
	BYTE res1;
//	printf("SD_sendApp()\n");
    spi_transfer(0xFF);
    SD_CS_enable();
    spi_transfer(0xFF);
    SD_command(CMD55, CMD55_ARG, CMD55_CRC);
    res1 = SD_readRes1();
    spi_transfer(0xFF);
    SD_CS_disable();
    spi_transfer(0xFF);
    return res1;
}

UINT8 SD_sendOpCond() {
	BYTE res1;
//  printf("SD_sendOpCond()\n");
    spi_transfer(0xFF);
    SD_CS_enable();
    spi_transfer(0xFF);
    SD_command(ACMD41, ACMD41_ARG, ACMD41_CRC);
    res1 = SD_readRes1();
    spi_transfer(0xFF);
    SD_CS_disable();
    spi_transfer(0xFF);
    return res1;
}

void SD_readOCR(BYTE *res) {
//  printf("SD_readOCR()\n");
    spi_transfer(0xFF);
    SD_CS_enable();
    spi_transfer(0xFF);
    SD_command(CMD58, CMD58_ARG, CMD58_CRC);
    SD_readRes7(res);
    spi_transfer(0xFF);
    SD_CS_disable();
    spi_transfer(0xFF);
}

void SD_powerUpSeq() {
	int i;
//  printf("SD_powerUpSeq()\n");
    SD_CS_disable();
	wait_timer0();
	spi_transfer(0xFF);
    SD_CS_disable();
	for(i = 0; i < SD_INIT_CYCLES; i++) {
        spi_transfer(0xFF);
	}
}

BYTE SD_readBlocks(DWORD addr, BYTE *buf, WORD count) {
	DWORD	sector = addr;
	BYTE	res;
	BYTE	token;
	BYTE *	ptr = buf;
	UINT	i;

	for(i = 0; i < count; i++) {
		res = SD_readSingleBlock(sector, ptr, &token);
		if(SD_R1_NO_ERROR(res) && (token == 0xFE)) {
			sector++;
			ptr += SD_BLOCK_LEN;
		}
		else {
			return SD_ERROR;
		}
	}	
	return SD_SUCCESS;
}

BYTE SD_writeBlocks(DWORD addr, BYTE *buf, WORD count) {
	DWORD	sector = addr;
	BYTE	res;
	BYTE	token;
	BYTE *	ptr = buf;
	UINT	i;

	for(i = 0; i < count; i++) {
		res = SD_writeSingleBlock(sector, ptr, &token);
		if(res == 0x00 && token == SD_DATA_ACCEPTED) {
			sector++;
			ptr += SD_BLOCK_LEN;
		}
		else {
			return SD_ERROR;
		}
	}	
	return SD_SUCCESS;	
}

BYTE SD_writeSingleBlock(DWORD addr, BYTE *buf, BYTE *token) {
    BYTE	res1;
	BYTE 	readAttempts;
	BYTE	read = 0x00;
	WORD	i;
	//
    // Set token to none
	//
    *token = 0xFF;
	//
    // Assert chip select
	//
    spi_transfer(0xFF);
	SD_CS_enable();
    spi_transfer(0xFF);
	//
    // Send CMD24
	//
    SD_command(CMD24, addr, CMD24_CRC);
	//
    // Read response
	//
    res1 = SD_readRes1();

    // If no error
    if(res1 == SD_READY) {
		//
        // Send start token
		//
        spi_transfer(SD_START_TOKEN);

        // Write buffer to card
		//
        for(i = 0; i < SD_BLOCK_LEN; i++) {
			spi_transfer(buf[i]);
		}
		//
        // Wait for a response (timeout = 250ms)
		//
        readAttempts = 0;
        while(++readAttempts != SD_MAX_WRITE_ATTEMPTS)
            if((read = spi_transfer(0xFF)) != 0xFF) {
				*token = 0xFF;
				break;
			}
		//
        // If data accepted
		//
        if((read & 0x1F) == 0x05) {
			//
            // Set token to data accepted
			//
            *token = 0x05;
			//
            // Wait for write to finish (timeout = 250ms)
			//
            readAttempts = 0;
            while(spi_transfer(0xFF) == 0x00) {
                if(++readAttempts == SD_MAX_WRITE_ATTEMPTS) {
					*token = 0x00;
					break;
				}
			}
        }
    }
	//
    // Deassert chip select
	//
    spi_transfer(0xFF);
    SD_CS_disable();
    spi_transfer(0xFF);

    return res1;	
}

BYTE SD_readSingleBlock(DWORD addr, BYTE *buf, BYTE *token)
{
    BYTE	res1;
	BYTE	read = 0x00;
    WORD	readAttempts, i;
	//
    // Set token to none
	//
    *token = 0xFF;
	//
    // Assert chip select
	//
    spi_transfer(0xFF);
    SD_CS_enable();
    spi_transfer(0xFF);
	//
    // Send CMD17
	//
    SD_command(CMD17, addr, CMD17_CRC);
	//
    // Read R1
	//
    res1 = SD_readRes1();
	//
    // If response received from card
	//
    if(res1 != 0xFF) {
		//
        // Wait for a response token (timeout = 100ms)
		//
        readAttempts = 0;
        while(++readAttempts != SD_MAX_READ_ATTEMPTS) 
            if((read = spi_transfer(0xFF)) != 0xFF)
				break;
		//
        // If response token is 0xFE
		//
        if(read == SD_START_TOKEN) {
			//
            // Read 512 byte block
			//
            for(i = 0; i < SD_BLOCK_LEN; i++) {
				*buf++ = spi_transfer(0xFF);
			}
			//
            // Read 16-bit CRC
			//
            spi_transfer(0xFF);
            spi_transfer(0xFF);
        }
		//
        // Set token to card response
		//
        *token = read;
    }
	//
    // Deassert chip select
	//
    spi_transfer(0xFF);
    SD_CS_disable();
    spi_transfer(0xFF);

    return res1;
}

BYTE SD_init(void) {
	BYTE res[5], cmdAttempts = 0;

	init_timer0(10, 16, 0x00);  // 10ms timer for delay

	SD_powerUpSeq();
	//
    // Command card to idle
	//
    while((res[0] = SD_goIdleState()) != 0x01) {
        cmdAttempts++;
        if(cmdAttempts > 10) return SD_ERROR;
    }
	//
    // Send interface conditions
	//
    SD_sendIfCond(res);
    if(res[0] != 0x01) {
        return SD_ERROR;
    }
	//
    // Check echo pattern
	//
    if(res[4] != 0xAA) {
        return SD_ERROR;
    }
	//
    // Attempt to initialize card
	//
    cmdAttempts = 0;
    do {
        if(cmdAttempts > 100) return SD_ERROR;
		//
        // Send app cmd
		//
        res[0] = SD_sendApp();
		//
        // If no error in response
		//
        if(res[0] < 2) {
            res[0] = SD_sendOpCond();
        }
		//
        // Wait
		//
        wait_timer0();
        cmdAttempts++;
    }
    while(res[0] != SD_READY);
	//
    // Read OCR
	//
    SD_readOCR(res);
    //
    // Disable 10ms timer
    //
   	enable_timer0(0);
	//
    // Check card is ready
	//
    if(!(res[1] & 0x80)) return SD_ERROR;

    return SD_SUCCESS;	
}

