#ifndef _I2C_H_
#define _I2C_H_

#include <defines.h>


extern volatile char	i2c_slave_rw;
extern volatile char	i2c_error;
extern volatile char	i2c_role;
extern volatile UINT8	i2c_msg_size;
extern volatile char *	i2c_msg_ptr;

// I2C_CTL register bits
#define I2C_CTL_IEN		(1<<7)
#define I2C_CTL_ENAB	(1<<6)
#define I2C_CTL_STA		(1<<5)
#define I2C_CTL_STP		(1<<4)
#define I2C_CTL_IFLG	(1<<3)
#define I2C_CTL_AAK		(1<<2)

// ez80 PPD register bits
#define CLK_PPD_I2C_OFF	(1<<2)

// I2C return codes to caller
#define RET_OK			0x00
#define RET_NORESPONSE	0x01
#define RET_DATA_NACK	0x02
#define RET_ARB_LOST	0x04
#define RET_BUS_ERROR	0x08

// I2C constants
#define I2C_MAX_BUFFERLENGTH	32
#define I2C_TIMEOUTMS			2000
#define I2C_SPEED_57600			0x01
#define I2C_SPEED_115200		0x02
#define I2C_SPEED_230400		0x03

// I2C role state
#define I2C_IDLE				0x00
#define I2C_MTX					0x01
#define I2C_MRX					0x02
#define I2C_SRX					0x04
#define I2C_STX					0x08

void init_I2C(void);
void	mos_I2C_OPEN(UINT8 frequency);
void	mos_I2C_CLOSE(void);
UINT8	mos_I2C_WRITE(UINT8 i2c_address, UINT8 size, char * buffer);
UINT8	mos_I2C_READ(UINT8 i2c_address, UINT8 size, char * buffer);

#endif _I2C_H_