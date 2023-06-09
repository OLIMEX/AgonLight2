/*
 * Title:			AGON MOS - UART code
 * Author:			Dean Belfield
 * Created:			06/07/2022
 * Last Updated:	29/03/2023
 * 
 * Modinfo:
 * 22/03/2023:		Moved putch and getch to serial.asm
 * 23/03/2023:		Fixed maths overflow in init_UART0 to work with bigger baud rates
 * 29/03/2023:		Added support for UART1
 */

#ifndef UART_H
#define UART_H

#include <gpio.h>

#define MASTERCLOCK				20000000	        	//!< The default system clock speed for eZ80F92.
#define CLOCK_DIVISOR_16		16			        	//!< The default clock divisor 

#if !defined(UART0_IVECT) 								//!< If it is not defined 
#define UART0_IVECT				0x18		        	//!< The UART0 interrupt vector.
#endif

#if !defined(UART1_IVECT) 								//!< If it is not defined 
#define UART1_IVECT				0x1A		        	//!< The UART1 interrupt vector.
#endif

#define DATABITS_8				8						//!< The default number of bits per character used in the driver.
#define DATABITS_7				7
#define DATABITS_6				6
#define DATABITS_5				5

#define STOPBITS_1				1
#define STOPBITS_2				2						//!< The default number of stop bits used in the driver.

#define PAR_NOPARITY			0	    	        	//!< No parity.
#define PAR_ODPARITY			1	    	        	//!< Odd parity.
#define PAR_EVPARITY			3	    	        	//!< Even parity.

#define FCTL_NONE				0						//!< No flow control
#define FCTL_HW					1						//!< Hardware flow control

#define	UART_ERR_NONE					((BYTE)0x00)	//!< The error code for success.
#define	UART_ERR_KBHIT					((BYTE)0x01)	//!< The error code for keyboard hit.			
#define	UART_ERR_FRAMINGERR				((BYTE)0x02)	//!< The error code returned when Framing error occurs in the character received.		
#define	UART_ERR_PARITYERR				((BYTE)0x03)	//!< The error code returned when Parity error occurs in the character received.			
#define	UART_ERR_OVERRUNERR				((BYTE)0x04)	//!< The error code returned when Overrun error occurs in the receive buffer register.		
#define	UART_ERR_BREAKINDICATIONERR		((BYTE)0x05)	//!< The error code returned when Break Indication Error occurs.		
#define	UART_ERR_CHARTIMEOUT			((BYTE)0x06)	//!< The error code returned when a character time-out occurs while receiving.			
#define	UART_ERR_INVBAUDRATE			((BYTE)0x07)	//!< The error code returned when baud rate specified is invalid.			
#define	UART_ERR_INVPARITY				((BYTE)0x08)	//!< The error code returned when parity option specified is invalid.			
#define	UART_ERR_INVSTOPBITS			((BYTE)0x09)	//!< The error code returned when stop bits specified is invalid.			
#define	UART_ERR_INVDATABITS			((BYTE)0x0A)	//!< The error code returned when data bits per character specified is invalid.			
#define	UART_ERR_INVTRIGGERLEVEL		((BYTE)0x0B)	//!< The error code returned when receive FIFO trigger level specified is invalid.			
#define	UART_ERR_FIFOBUFFERFULL			((BYTE)0x0C)	//!< The error code returned when the transmit FIFO buffer is full.		
#define	UART_ERR_FIFOBUFFEREMPTY		((BYTE)0x0D)	//!< The error code returned when the receive FIFO buffer is empty.			
#define	UART_ERR_RECEIVEFIFOFULL		((BYTE)0x0E)	//!< The error code returned when the software receive FIFO buffer is full.			
#define	UART_ERR_RECEIVEFIFOEMPTY		((BYTE)0x0F)	//!< The error code returned when the software receive FIFO buffer is empty.			
#define	UART_ERR_PEEKINPOLL				((BYTE)0x10)	//!< The error code returned when 'peek a character' is done in polling mode, which is invalid.		
#define	UART_ERR_USERBASE				((BYTE)0x11)	//!< The error code base value for user applications.
#define	UART_ERR_FAILURE				((BYTE)-1)		//!< The error code for failures.

#define UART_IIR_LINESTATUS				((unsigned char)0x06)		//!< Receive Line Status interrupt code in IIR.
#define UART_IIR_DATAREADY_TRIGLVL		((unsigned char)0x04)		//!< Receive Data Ready or Trigger Level indication in IIR.
#define UART_IIR_CHARTIMEOUT			((unsigned char)0x0C)		//!< Character Time-out interrupt code in IIR.
#define UART_IIR_TRANSCOMPLETE			((unsigned char)0x0A)		//!< Transmission Complete interrupt code in IIR.
#define UART_IIR_TRANSBUFFEREMPTY		((unsigned char)0x02)		//!< Transmit Buffer Empty interrupt code in IIR.
#define UART_IIR_MODEMSTAT				((unsigned char)0x00)		//!< Modem Status interrupt code in IIR.

#define UART_LSR_DATA_READY				((unsigned char)0x01)		//!< Data ready indication in LSR.
#define UART_LSR_OVERRRUNERR			((unsigned char)0x02)		//!< Overrun error indication in LSR.
#define UART_LSR_PARITYERR				((unsigned char)0x04)		//!< Parity error indication in LSR.
#define UART_LSR_FRAMINGERR				((unsigned char)0x08)		//!< Framing error indication in LSR.
#define UART_LSR_BREAKINDICATIONERR		((unsigned char)0x10)		//!< Framing error indication in LSR.
#define UART_LSR_THREMPTY				((unsigned char)0x20)		//!< Transmit Holding Register empty indication in LSR.
#define UART_LSR_TEMT					((unsigned char)0x40)		//!< Transmit is empty.
#define UART_LSR_FIFOERR				((unsigned char)0x80)		//!< Error in FIFO indication in LSR.

#define UART_IER_RECEIVEINT				((unsigned char)0x01)		//!< Receive Interrupt bit in IER.
#define UART_IER_TRANSMITINT			((unsigned char)0x02)		//!< Transmit Interrupt bit in IER.
#define UART_IER_LINESTATUSINT			((unsigned char)0x04)		//!< Line Status Interrupt bit in IER.
#define UART_IER_MODEMINT				((unsigned char)0x08)		//!< Modem Interrupt bit in IER.
#define UART_IER_TRANSCOMPLETEINT		((unsigned char)0x10)		//!< Transmission Complete Interrupt bit in IER.
#define UART_IER_ALLINTMASK				((unsigned char)0x1F)		//!< Mask for all the interrupts listed above for IER.

// UART_IER bits
//
#define UART_IER_MIIE					UART_IER_MODEMINT
#define UART_IER_LSIE					UART_IER_LINESTATUSINT
#define UART_IER_TIE					UART_IER_TRANSMITINT
#define UART_IER_RIE					UART_IER_RECEIVEINT

// UART_IIR bits
//
#define UART_IIR_FIFOEN					((unsigned char)0xC0)
#define UART_IIR_ISCMASK				((unsigned char)0x0E)
#define UART_IIR_RLS					UART_IIR_LINESTATUS
#define UART_IIR_RDR					UART_IIR_DATAREADY_TRIGLVL
#define UART_IIR_CTO					UART_IIR_CHARTIMEOUT
#define UART_IIR_TBE					UART_IIR_TRANSBUFFEREMPTY
#define UART_IIR_MS						UART_IIR_MODEMSTAT
#define UART_IIR_INTBIT					((unsigned char)0x01)

// UART_FCTL bits
//
#define UART_FCTL_TRIGMASK				((unsigned char)0x00)
#define UART_FCTL_TRIG_1				((unsigned char)0x00)
#define UART_FCTL_TRIG_4				((unsigned char)0x40)
#define UART_FCTL_TRIG_8				((unsigned char)0x80)
#define UART_FCTL_TRIG_14				((unsigned char)0xC0)
#define UART_FCTL_CLRTxF				((unsigned char)0x04)
#define UART_FCTL_CLRRxF				((unsigned char)0x02)
#define UART_FCTL_FIFOEN				((unsigned char)0x01)

// UART_LCTL bits
//
#define UART_LCTL_DLAB					((unsigned char)0x80)		//!< DLAB bit in LCTL.
#define UART_LCTL_SB					((unsigned char)0x40)		//!< Send Break bit in LCTL.
#define UART_LCTL_FPE					((unsigned char)0x20)		//!< Force Parity Error bit in LCTL.
#define UART_LCTL_EPS					((unsigned char)0x10)		//!< Even Parity Select bit in LCTL.
#define UART_LCTL_PEN					((unsigned char)0x08)		//!< Parity Enable bit in LCTL.
#define UART_LCTL_2STOPBITS				((unsigned char)0x04)
#define UART_LCTL_5DATABITS				((unsigned char)0x00)
#define UART_LCTL_6DATABITS				((unsigned char)0x01)
#define UART_LCTL_7DATABITS				((unsigned char)0x02)
#define UART_LCTL_8DATABITS				((unsigned char)0x03)

// UART_MCTL bits
//
#define UART_MCTL_LOOP					((unsigned char)0x10)
#define UART_MCTL_OUT2					((unsigned char)0x08)
#define UART_MCTL_OUT1					((unsigned char)0x04)
#define UART_MCTL_RTS					((unsigned char)0x02)
#define UART_MCTL_DTR					((unsigned char)0x01)

// UART_LSR bits 
//
#define UART_LSR_ERR					((unsigned char)0x80)
#define UART_LSR_TEMT					((unsigned char)0x40)
#define UART_LSR_THRE					UART_LSR_THREMPTY
#define UART_LSR_BI						UART_LSR_BREAKINDICATIONERR
#define UART_LSR_FE						UART_LSR_FRAMINGERR
#define UART_LSR_PE						UART_LSR_PARITYERR
#define UART_LSR_OE						UART_LSR_OVERRRUNERR
#define UART_LSR_DR						UART_LSR_DATA_READY

// UART_MSR bits
//
#define UART_MSR_DCD					((unsigned char)0x80)
#define UART_MSR_RI						((unsigned char)0x40)
#define UART_MSR_DSR					((unsigned char)0x20)
#define UART_MSR_CTS					((unsigned char)0x10)
#define UART_MSR_DDCD					((unsigned char)0x08)
#define UART_MSR_TERI					((unsigned char)0x04)
#define UART_MSR_DDSR					((unsigned char)0x02)
#define UART_MSR_DCTS					((unsigned char)0x01)

// UART settings for open_UART0
//
typedef struct {
   UINT24	baudRate;					// The baudrate 
   BYTE		dataBits;					// The number of databits per character to be used
   BYTE		stopBits;					// The number of stopbits to be used
   BYTE		parity;						// The parity bit option to be used
   BYTE 	flowControl;				// The flow control option (0: None, 1: Hardware)
   BYTE		interrupts;					// The enabled interrupts
} UART;

void init_UART0();
void init_UART1();

BYTE open_UART0(UART * pUART);
BYTE open_UART1(UART * pUART);

void close_UART1();

extern volatile BYTE serialFlags;		// In globals.asm

extern INT putch(INT ich);				// Now in serial.asm
extern INT getch(VOID);					// Now in serial.asm

#endif UART_H