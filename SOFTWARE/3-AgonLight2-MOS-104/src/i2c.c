/*
 * Title:			AGON MOS - I2C code
 * Author:			Jeroen Venema
 * Created:			07/11/2023
 * Last Updated:	10/11/2023
 * 
 * Modinfo:
 */

#include <ez80.h>
#include "i2c.h"
#include <defines.h>
#include "timer.h"

// Set I2C clock and sampling frequency
void I2C_setfrequency(UINT8 id) {
	switch(id) {
		case(I2C_SPEED_115200):
			I2C_CCR = (0x01<<3) | 0x03;	// 115.2KHz fast-mode (400KHz max), sampling at 4.6MHz
			break;
		case(I2C_SPEED_230400):
			I2C_CCR = (0x01<<3) | 0x02;	// 230.4KHz fast-mode (400KHz max), sampling at 2.3Mhz
			break;
		case(I2C_SPEED_57600):
		default:
			I2C_CCR = (0x01<<3) | 0x04;	// 57.6KHz default standard-mode (100KHz max), sampling at 1.15Mhz
	}
}

// Initializes the I2C bus
void init_I2C(void) {
	i2c_msg_size = 0;
	CLK_PPD1 = CLK_PPD_I2C_OFF;			// Power Down I2C block before enabling it, avoid locking bug
	I2C_CTL = I2C_CTL_ENAB;				// Enable I2C block, don't enable interrupts yet
	I2C_setfrequency(0);
	CLK_PPD1 = 0x0;						// Power up I2C block
}

// Internal function
void I2C_handletimeout(void) {
	// reset the interface
	I2C_CTL = 0;
	init_I2C();
}

// Open the I2C bus, register the driver interrupt
// Parameters: None
// Returns: None
void mos_I2C_OPEN(UINT8 frequency) {
	init_I2C();
	I2C_setfrequency(frequency);
}

// Close the I2C bus, deregister the driver interrupt
// Parameters: None
// Returns: None
void mos_I2C_CLOSE(void) {
	CLK_PPD1 = CLK_PPD_I2C_OFF;			// Power Down I2C block
	I2C_CTL &= ~(I2C_CTL_ENAB);			// Disable I2C block
}

// Write a number of bytes to an address on the I2C bus
// Parameters:
// - i2c_address: I2C address of the slave device
// - size: number of bytes to write
// - buffer: pointer to the first byte to write
// Returns:
// - 0 on success, or errorcode
UINT8 mos_I2C_WRITE(UINT8 i2c_address, UINT8 size, char * buffer) {

	// send maximum of 32 bytes in a single I2C transaction
	if(size > I2C_MAX_BUFFERLENGTH) size = I2C_MAX_BUFFERLENGTH;
	if(i2c_address > 127) return RET_NORESPONSE;
	// wait for IDLE status
	init_timer0(1, 16, 0x00);  		// 1ms timer for delay
	enable_timer0(1);
	while(i2c_role) {
		// anything but IDLE (00)
		if(get_timer0() > I2C_TIMEOUTMS) {
			I2C_handletimeout();
			enable_timer0(0);		// Disable timer
			return RET_ARB_LOST;
		}
	}
	enable_timer0(0);

	i2c_msg_ptr = buffer;
	i2c_msg_size = size;
	i2c_role = I2C_MTX;			// MTX - Master Transmit Mode
	i2c_error = RET_OK;
	i2c_slave_rw = i2c_address << 1;	// shift one bit left, 0 on bit 0 == write action on I2C

	I2C_CTL = I2C_CTL_IEN | I2C_CTL_ENAB | I2C_CTL_STA; // send start condition

	init_timer0(1, 16, 0x00);  		// 1ms timer for delay
	enable_timer0(1);
	while(i2c_role == I2C_MTX) {	// while MTX
		if(get_timer0() > I2C_TIMEOUTMS) {
			I2C_handletimeout();
			enable_timer0(0);		// Disable timer
			return RET_DATA_NACK;
		}
	}

	enable_timer0(0);				// Disable timer
	return i2c_error;
}

// Read a number of bytes from an i2c_address on the I2C bus
// Parameters:
// - i2c_address: I2C address of the slave device
// - size: number of bytes to read
// - buffer: pointer to the first byte to read
// Returns:
// - 0 on success, or errorcode
UINT8 mos_I2C_READ(UINT8 i2c_address, UINT8 size, char* buffer)
{
	if(size == 0) return 0;
	if(i2c_address > 127) return RET_NORESPONSE;
	// receive maximum of 32 bytes in a single I2C transaction
	if(size > I2C_MAX_BUFFERLENGTH) size = I2C_MAX_BUFFERLENGTH;

	// wait for IDLE status
	init_timer0(1, 16, 0x00);  		// 1ms timer for delay
	enable_timer0(1);
	while(i2c_role) {
		// anything but IDLE (00)
		if(get_timer0() > I2C_TIMEOUTMS) {
			I2C_handletimeout();
			enable_timer0(0);		// Disable timer
			return RET_ARB_LOST;
		}
	}
	enable_timer0(0);
	i2c_msg_ptr = buffer;
	i2c_msg_size = size;
	i2c_role = I2C_MRX;			// MRX mode
	i2c_error = RET_OK;
	i2c_slave_rw = (1<<0);				// receive bit 0
	i2c_slave_rw |= i2c_address << 1;	// shift 7-bit address one bit left

	I2C_CTL = I2C_CTL_IEN | I2C_CTL_ENAB | I2C_CTL_STA; // send start condition

	init_timer0(1, 16, 0x00);  		// 1ms timer for delay
	enable_timer0(1);
	while(i2c_role == I2C_MRX) {
		if(get_timer0() > I2C_TIMEOUTMS) {
			I2C_handletimeout();
			enable_timer0(0);		// Disable timer
			return RET_ARB_LOST;
		}
	}
	enable_timer0(0);				// Disable timer
	return i2c_error;
}
