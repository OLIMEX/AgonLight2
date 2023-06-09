/*
 * Title:			AGON MOS - Low level SD card functionality
 * Author:			RJH
 * Modified By:		Dean Belfield
 * Created:			19/06/2022
 * Last Updated:	19/06/2022
 *
 * Modinfo:
 */

#ifndef SD_H
#define SD_H

#define CMD0        0
#define CMD0_ARG    0x00000000
#define CMD0_CRC    0x94

#define CMD8        8
#define CMD8_ARG    0x0000001AA
#define CMD8_CRC    0x86 //(1000011 << 1)

#define CMD17       17
#define CMD17_CRC   0x00

#define CMD24       24
#define CMD24_CRC   0x00

#define CMD55       55
#define CMD55_ARG   0x00000000
#define CMD55_CRC   0x00

#define CMD58       58
#define CMD58_ARG   0x00000000
#define CMD58_CRC   0x00

#define ACMD41      41
#define ACMD41_ARG  0x40000000
#define ACMD41_CRC  0x00

#define PARAM_ERROR(X)      X & 0x40
#define ADDR_ERROR(X)       X & 0x20
#define ERASE_SEQ_ERROR(X)  X & 0x10
#define CRC_ERROR(X)        X & 0x08
#define ILLEGAL_CMD(X)      X & 0x04
#define ERASE_RESET(X)      X & 0x02
#define IN_IDLE(X)          X & 0x01


#define CMD_VER(X)          ((X >> 4) & 0xF0)
#define VOL_ACC(X)          (X & 0x1F)

#define VOLTAGE_ACC_27_33   0x01
#define VOLTAGE_ACC_LOW     0x02
#define VOLTAGE_ACC_RES1    0x04
#define VOLTAGE_ACC_RES2    0x08

#define POWER_UP_STATUS(X)  X & 0x40
#define CCS_VAL(X)          X & 0x40
#define VDD_2728(X)         X & 0x80
#define VDD_2829(X)         X & 0x01
#define VDD_2930(X)         X & 0x02
#define VDD_3031(X)         X & 0x04
#define VDD_3132(X)         X & 0x08
#define VDD_3233(X)         X & 0x10
#define VDD_3334(X)         X & 0x20
#define VDD_3435(X)         X & 0x40
#define VDD_3536(X)         X & 0x80

#define SD_R1_NO_ERROR(X)	X < 0x02

#define SD_SUCCESS  0
#define SD_ERROR    1
#define SD_READY	0

#define	SD_INIT_CYCLES          10
#define SD_MAX_READ_ATTEMPTS    1563
#define SD_MAX_WRITE_ATTEMPTS   3907

#define SD_START_TOKEN          0xFE
#define SD_ERROR_TOKEN          0x00

#define SD_DATA_ACCEPTED        0x05
#define SD_DATA_REJECTED_CRC    0x0B
#define SD_DATA_REJECTED_WRITE  0x0D

#define SD_BLOCK_LEN            0x200

#define	SD_TYPE_FAT16			0x01
#define	SD_TYPE_FAT32			0x02

void	SD_command(BYTE cmd, DWORD arg, BYTE crc);

BYTE	SD_readRes1();
void	SD_readRes7(BYTE *res);

BYTE	SD_goIdleState();
void	SD_sendIfCond(BYTE *res);
BYTE	SD_sendApp();
BYTE	SD_sendOpCond();
void	SD_readOCR(BYTE *res);
void	SD_powerUpSeq();

BYTE	SD_readBlocks(DWORD addr, BYTE *buf, WORD count);
BYTE	SD_writeBlocks(DWORD addr, BYTE *buf, WORD count);

BYTE	SD_readSingleBlock(DWORD addr, BYTE *buf, BYTE *token);
BYTE	SD_writeSingleBlock(DWORD addr, BYTE *buf, BYTE *token);

BYTE	SD_init();

#endif SD_H