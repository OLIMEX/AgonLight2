;
; Title:	AGON MOS - API code
; Author:	Dean Belfield
; Created:	24/07/2022
; Last Updated:	10/11/2023
;
; Modinfo:
; 03/08/2022:	Added a handful of MOS API calls and stubbed FatFS calls
; 05/08/2022:	Added mos_FEOF, saved affected registers in fopen, fclose, fgetc, fputc and feof
; 09/08/2022:	mos_api_sysvars now returns pointer to _sysvars
; 05/09/2022:	Added mos_REN
; 24/09/2022:	Error codes returned for MOS commands
; 13/10/2022:	Added mos_OSCLI and supporting code
; 20/10/2022:	Tweaked error handling
; 13/03/2023:	Renamed keycode to keyascii, fixed mos_api_getkey, added parameter to mos_api_dir
; 15/03/2023:	Added mos_api_copy, mos_api_getrtc, mos_api_setrtc
; 21/03/2023:	Added mos_api_setintvector
; 24/03/2023:	Fixed bugs in mos_api_setintvector
; 28/03/2023:	Function mos_api_setintvector now only accepts a 24-bit pointer
; 29/03/2023:	Added mos_api_uopen, mos_api_uclose, mos_api_ugetc, mos_api_uputc
; 14/04/2023:	Added ffs_api_fopen, ffs_api_fclose, ffs_api_stat, ffs_api_fread, ffs_api_fwrite, ffs_api_feof, ffs_api_flseek
; 15/04/2023:	Added mos_api_getfil, mos_api_fread, mos_api_fwrite and mos_api_flseek
; 30/05/2023:	Fixed mos_api_fgetc to set carry if at end of file
; 03/08/2023:	Added mos_api_setkbvector
; 10/08/2023:	Added mos_api_getkbmap
; 10/11/2023:	Added mos_api_i2c_close, mos_api_i2c_open, mos_api_i2c_read, mos_api_i2c_write


			.ASSUME	ADL = 1
			
			DEFINE .STARTUP, SPACE = ROM
			SEGMENT .STARTUP
			
			XDEF	mos_api	

			XREF	SWITCH_A		; In misc.asm
			XREF	SET_AHL24
			XREF	GET_AHL24
			XREF	SET_ADE24

			XREF	_mos_OSCLI		; In mos.c
			XREF	_mos_EDITLINE
			XREF	_mos_LOAD
			XREF	_mos_SAVE
			XREF	_mos_CD
			XREF	_mos_DIR
			XREF	_mos_DEL
			XREF	_mos_REN
			XREF	_mos_FOPEN
			XREF	_mos_FCLOSE
			XREF	_mos_FGETC
			XREF	_mos_FPUTC
			XREF	_mos_FEOF
			XREF	_mos_GETERROR
			XREF	_mos_MKDIR
			XREF	_mos_COPY
			XREF	_mos_GETRTC 
			XREF	_mos_SETRTC 
			XREF	_mos_SETINTVECTOR
			XREF	_mos_GETFIL
			XREF	_mos_FREAD
			XREF	_mos_FWRITE
			XREF	_mos_FLSEEK
			XREF	_mos_I2C_OPEN
			XREF	_mos_I2C_CLOSE
			XREF	_mos_I2C_WRITE
			XREF	_mos_I2C_READ
			
			XREF	_fat_EOF		; In mos.c

			XREF	_open_UART1		; In uart.c
			XREF	_close_UART1

			XREF	UART1_serial_GETCH	; In serial.asm
			XREF	UART1_serial_PUTCH 
			
			XREF	_keyascii		; In globals.asm
			XREF	_keycount
			XREF	_keydown
			XREF	_sysvars
			XREF	_scratchpad
			XREF	_vpd_protocol_flags
			XREF	_user_kbvector
			XREF	_keymap

			XREF	_f_open			; In ff.c
			XREF	_f_close
			XREF	_f_read 
			XREF	_f_write
			XREF	_f_stat 
			XREF	_f_lseek
			
; Call a MOS API function
; 00h - 7Fh: Reserved for high level MOS calls
; 80h - FFh: Reserved for low level calls to FatFS
;  A: function to call
;
mos_api:		CP	80h			; Check if it is a FatFS command
			JR	NC, $F			; Yes, so jump to next block
			CP	mos_api_block1_size	; Check if out of bounds
			RET	NC			; It is, so do nothing
			CALL	SWITCH_A		; Switch on this table
;
mos_api_block1_start:	DW	mos_api_getkey		; 0x00
			DW	mos_api_load		; 0x01
			DW	mos_api_save		; 0x02
			DW	mos_api_cd		; 0x03
			DW	mos_api_dir		; 0x04
			DW	mos_api_del		; 0x05
			DW	mos_api_ren		; 0x06
			DW	mos_api_mkdir		; 0x07
			DW	mos_api_sysvars		; 0x08
			DW	mos_api_editline	; 0x09
			DW	mos_api_fopen		; 0x0A
			DW	mos_api_fclose		; 0x0B
			DW	mos_api_fgetc		; 0x0C
			DW	mos_api_fputc		; 0x0D
			DW	mos_api_feof		; 0x0E
			DW	mos_api_getError	; 0x0F
			DW	mos_api_oscli		; 0x10
			DW	mos_api_copy		; 0x11
			DW	mos_api_getrtc		; 0x12
			DW	mos_api_setrtc		; 0x13
			DW	mos_api_setintvector	; 0x14
			DW	mos_api_uopen		; 0x15
			DW 	mos_api_uclose		; 0x16
			DW	mos_api_ugetc		; 0x17
			DW	mos_api_uputc		; 0x18
			DW	mos_api_getfil		; 0x19
			DW	mos_api_fread		; 0x1A
			DW	mos_api_fwrite		; 0x1B
			DW	mos_api_flseek		; 0x1C
			DW	mos_api_setkbvector	; 0x1D
			DW	mos_api_getkbmap	; 0x1E
			DW	mos_api_i2c_open	; 0x1F
			DW	mos_api_i2c_close	; 0x20
			DW	mos_api_i2c_write	; 0x21
			DW	mos_api_i2c_read	; 0x22

mos_api_block1_size:	EQU 	($ - mos_api_block1_start) / 2
;			
$$:			AND	7Fh			; Else remove the top bit
			CP	mos_api_block2_size	; Check if out of bounds
			RET	NC			; It is, so do nothing
			CALL	SWITCH_A		; And switch on this table

mos_api_block2_start:	DW	ffs_api_fopen
			DW	ffs_api_fclose
			DW	ffs_api_fread
			DW	ffs_api_fwrite
			DW	ffs_api_flseek
			DW	ffs_api_ftruncate
			DW	ffs_api_fsync
			DW	ffs_api_fforward
			DW	ffs_api_fexpand
			DW	ffs_api_fgets
			DW	ffs_api_fputc
			DW	ffs_api_fputs
			DW	ffs_api_fprintf
			DW	ffs_api_ftell
			DW	ffs_api_feof
			DW	ffs_api_fsize
			DW	ffs_api_ferror
			DW	ffs_api_dopen
			DW	ffs_api_dclose
			DW	ffs_api_dread
			DW	ffs_api_dfindfirst
			DW	ffs_api_dfindnext
			DW	ffs_api_stat
			DW	ffs_api_unlink
			DW	ffs_api_rename
			DW	ffs_api_chmod
			DW	ffs_api_utime
			DW	ffs_api_mkdir
			DW	ffs_api_chdir
			DW	ffs_api_chdrive
			DW	ffs_api_getcwd
			DW	ffs_api_mount
			DW	ffs_api_mkfs
			DW	ffs_api_fdisk		
			DW	ffs_api_getfree
			DW	ffs_api_getlabel
			DW	ffs_api_setlabel
			DW	ffs_api_setcp

mos_api_block2_size:	EQU 	($ - mos_api_block2_start) / 2

; Get keycode
; Returns:
;  A: ASCII code of key pressed, or 0 if no key pressed
;
mos_api_getkey:		PUSH	HL
			LD	HL, _keycount	
mos_api_getkey_1:	LD	A, (HL)			; Wait for a key to be pressed
$$:			CP	(HL)
			JR	Z, $B
			LD	A, (_keydown)		; Check if key is down
			OR	A 
			JR	Z, mos_api_getkey_1	; No, so loop
			POP	HL 
			LD	A, (_keyascii)		; Get the key code
			RET
			
; Load an area of memory from a file.
; HLU: Address of filename (zero terminated)
; DEU: Address at which to load
; BCU: Maximum allowed size (bytes)
; Returns:
; - A: File error, or 0 if OK
; - F: Carry reset indicates no room for file.
;
mos_api_load:		LD	A, MB		; Check if MBASE is 0
			OR	A, A
			JR	Z, $F		; If it is, we can assume HL and DE are 24 bit
;
; Now we need to mod HLU and DEU to include the MBASE in the U byte
;
			CALL	SET_AHL24
			CALL	SET_ADE24
;
; Finally, we can do the load
;
$$:			PUSH	BC		; UINT24   size
			PUSH	DE		; UNIT24   address
			PUSH	HL		; char   * filename
			CALL	_mos_LOAD	; Call the C function mos_LOAD
			LD	A, L		; Return value in HLU, put in A
			POP	HL
			POP	DE
			POP	BC
			SCF			; Flag as successful
			RET

; Save a file to the SD card from RAM
; HLU: Address of filename (zero terminated)
; DEU: Address to save from
; BCU: Number of bytes to save
; Returns:
; - A: File error, or 0 if OK
; - F: Carry reset indicates no room for file
;
mos_api_save:		LD	A, MB		; Check if MBASE is 0
			OR	A, A
			JR	Z, $F		; If it is, we can assume HL and DE are 24 bit
;
; Now we need to mod HLU and DEU to include the MBASE in the U byte
;
			CALL	SET_AHL24
			CALL	SET_ADE24
;
; Finally, we can do the save
;
$$:			PUSH	BC		; UINT24   size
			PUSH	DE		; UNIT24   address
			PUSH	HL		; char   * filename
			CALL	_mos_SAVE	; Call the C function mos_LOAD
			LD	A, L		; Return vaue in HLU, put in A
			POP	HL
			POP	DE
			POP	BC
			SCF			; Flag as successful
			RET
			
; Change directory
; HLU: Address of path (zero terminated)
; Returns:
; - A: File error, or 0 if OK
;			
mos_api_cd:		LD	A, MB		; Check if MBASE is 0
			OR	A, A
;
; Now we need to mod HLU to include the MBASE in the U byte
;
			CALL	NZ, SET_AHL24	; If it is running in classic Z80 mode, set U to MB
;
; Finally, we can do the load
;
			PUSH	HL		; char   * filename	
			CALL	_mos_CD
			LD	A, L		; Return vaue in HLU, put in A
			POP	HL
			RET

; Directory listing
; HLU: Address of path (zero terminated)
; Returns:
; - A: File error, or 0 if OK
;	
mos_api_dir:		LD	A, MB		; Check if MBASE is 0
			OR	A, A
;
; Now we need to mod HLU to include the MBASE in the U byte
;
			CALL	NZ, SET_AHL24	; If it is running in classic Z80 mode, set U to MB
;
; Finally, we can run the command
;
			PUSH	HL		; char * path
			CALL	_mos_DIR
			LD	A, L		; Return value in HLU, put in A
			POP	HL
			RET
			
; Delete a file from the SD card
; HLU: Address of filename (zero terminated)
; Returns:
; - A: File error, or 0 if OK
;
mos_api_del:		LD	A, MB		; Check if MBASE is 0
			OR	A, A
;
; Now we need to mod HLU to include the MBASE in the U byte
;
			CALL	NZ, SET_AHL24	; If it is running in classic Z80 mode, set U to MB
;
; Finally, we can do the delete
;
			PUSH	HL		; char   * filename
			CALL	_mos_DEL	; Call the C function mos_DEL
			LD	A, L		; Return vaue in HLU, put in A
			POP	HL
			RET

; Rename a file on the SD card
; HLU: Address of filename1 (zero terminated)
; DEU: Address of filename2 (zero terminated)
; Returns:
; - A: File error, or 0 if OK
;
mos_api_ren:		LD	A, MB		; Check if MBASE is 0
			OR	A, A
			JR	Z, $F		; If it is, we can assume HL and DE are 24 bit
;
; Now we need to mod HLU and DEu to include the MBASE in the U byte
; 
			CALL	SET_AHL24
			CALL	SET_ADE24
;
; Finally we can do the rename
; 
$$:			PUSH	DE		; char * filename2
			PUSH	HL		; char * filename1
			CALL	_mos_REN	; Call the C function mos_REN
			LD	A, L		; Return vaue in HLU, put in A
			POP	HL
			POP	DE
			RET

; Copy a file on the SD card
; HLU: Address of filename1 (zero terminated)
; DEU: Address of filename2 (zero terminated)
; Returns:
; - A: File error, or 0 if OK
;
mos_api_copy:		LD	A, MB		; Check if MBASE is 0
			OR	A, A
			JR	Z, $F		; If it is, we can assume HL and DE are 24 bit
;
; Now we need to mod HLU and DEu to include the MBASE in the U byte
; 
			CALL	SET_AHL24
			CALL	SET_ADE24
;
; Finally we can do the rename
; 
$$:			PUSH	DE		; char * filename2
			PUSH	HL		; char * filename1
			CALL	_mos_COPY	; Call the C function mos_COPY
			LD	A, L		; Return vaue in HLU, put in A
			POP	HL
			POP	DE
			RET

; Make a folder on the SD card
; HLU: Address of filename (zero terminated)
; Returns:
; - A: File error, or 0 if OK
;
mos_api_mkdir:		LD	A, MB		; Check if MBASE is 0
			OR	A, A
;
; Now we need to mod HLU to include the MBASE in the U byte
;
			CALL	NZ, SET_AHL24	; If it is running in classic Z80 mode, set U to MB
;
; Finally, we can do the load
;
			PUSH	HL		; char   * filename
			CALL	_mos_MKDIR	; Call the C function mos_DEL
			LD	A, L		; Return vaue in HLU, put in A
			POP	HL
			RET

; Get a pointer to a system variable
; Returns:
; IXU: Pointer to system variables (see mos_api.asm for more details)
;
mos_api_sysvars:	LD	IX, _sysvars
			RET
			
; Invoke the line editor
; HLU: Address of the buffer
; BCU: Buffer length
;   E: 0 to not clear buffer, 1 to clear
; Returns:
;   A: Key that was used to exit the input loop (CR=13, ESC=27)
;
mos_api_editline:	LD	A, MB		; Check if MBASE is 0
			OR	A, A
;
; Now we need to mod HLU to include the MBASE in the U byte
;
			CALL	NZ, SET_AHL24	; If it is running in classic Z80 mode, set U to MB
;
			PUSH	DE		; UINT8	  clear
			PUSH	BC		; int 	  bufferLength
			PUSH	HL		; char	* buffer
			CALL	_mos_EDITLINE
			LD	A, L		; return value, only interested in lowest byte
			POP	HL
			POP	BC
			POP	DE
			RET

; Open a file
; HLU: Filename
;   C: Mode
; Returns:
;   A: Filehandle, or 0 if couldn't open
;
mos_api_fopen:		PUSH	BC
			PUSH	DE
			PUSH	HL
			PUSH	IX
			PUSH	IY
;
			LD	A, MB		; Check if MBASE is 0
			OR	A, A
;
; Now we need to mod HLU and DEU to include the MBASE in the U byte
;
			CALL	NZ, SET_AHL24	; If it is running in classic Z80 mode, set U to MB
;
			LD	A, C	
			LD	BC, 0
			LD	C, A
			PUSH	BC		; byte	  mode
			PUSH	HL		; char	* buffer
			CALL	_mos_FOPEN
			LD	A, L		; Return fh
			POP	HL
			POP	BC
;
			POP	IY
			POP	IX
			POP	HL
			POP	DE
			POP	BC
			RET

; Close a file
;   C: Filehandle
; Returns
;   A: Number of files still open
;
mos_api_fclose:		PUSH	BC
			PUSH	DE
			PUSH	HL
			PUSH	IX
			PUSH	IY
;
			LD	A, C
			LD	BC, 0
			LD	C, A
			PUSH	BC		; byte 	  fh
			CALL	_mos_FCLOSE
			LD	A, L		; Return # files still open
			POP	BC
;
			POP	IY
			POP	IX
			POP	HL
			POP	DE
			POP	BC
			RET
			
; Get a character from a file
;   C: Filehandle
; Returns:
;   A: Character read
;   F: C set if last character in file, otherwise NC
;
mos_api_fgetc:		PUSH	BC
			PUSH	DE
			PUSH	HL
			PUSH	IX
			PUSH	IY
;			
			LD	DE, 0
			LD	E, C
			PUSH	DE		; byte	  fh
			CALL	_mos_FGETC	; Read the character
			POP	DE
			LD	A, L 		; A: Character read
			SRL	H 		; F: C = EOF
;
			POP	IY
			POP	IX
			POP	HL
			POP	DE
			POP	BC
			RET
	
; Write a character to a file
;   C: Filehandle
;   B: Character to write
;
mos_api_fputc:		PUSH	AF
			PUSH	BC
			PUSH	DE
			PUSH	HL
			PUSH	IX
			PUSH	IY
;		
			LD	DE, 0
			LD	E, B		
			PUSH	DE		; byte	  char
			LD	E, C
			PUSH	DE		; byte	  fh
			CALL	_mos_FPUTC
			POP	DE
			POP	DE
;			
			POP	IY
			POP	IX
			POP	HL
			POP	DE
			POP	BC
			POP	AF
			RET
			
; Check whether we're at the end of the file
;   C: Filehandle
; Returns:
;   A: 1 if at end of file, otherwise 0
;     
mos_api_feof:		PUSH	BC
			PUSH	DE
			PUSH	HL
			PUSH	IX
			PUSH	IY
;			
			LD	DE, 0
			LD	E, C
			PUSH	DE		; byte	  fh
			CALL	_mos_FEOF
			POP	DE
;			
			POP	IY
			POP	IX
			POP	HL
			POP	DE
			POP	BC
			RET
			
; Copy an error message
;   E: The error code
; HLU: Address of buffer to copy message into
; BCU: Size of buffer
;
mos_api_getError:	LD	A, MB		; Check if MBASE is 0
			OR	A, A
			CALL	NZ, SET_AHL24	; If it is running in classic Z80 mode, set U to MB
;
; Now copy the error message
;
			PUSH	BC		; UINT24 size
			PUSH	HL		; UINT24 address
			PUSH	DE		; byte   errno
			CALL	_mos_GETERROR
			POP	DE
			POP	HL
			POP	BC			
			RET

; Execute a MOS command
; HLU: Pointer the the MOS command string
; DEU: Pointer to additional command structure
; BCU: Number of additional commands
; Returns:
;   A: MOS error code
;
mos_api_oscli:		LD	A, MB		; Check if MBASE is 0
			OR	A, A				
			CALL	NZ, SET_AHL24	; If it is running in classic Z80 mode, set U to MB
;
; Now execute the MOS command
;
			PUSH	HL		; char * buffer
			CALL	_mos_OSCLI
			LD	A, L		; Return vaue in HLU, put in A			
			POP	HL
			RET

; Fetch a RTC string
; HLU: Pointer to a buffer to copy the string to
; Returns:
;   A: Length of time
;
mos_api_getrtc:		LD	A, MB		; Check if MBASE is 0
			OR	A, A 
			CALL	NZ, SET_AHL24	; If it is running in classic Z80 mode, set U to MB
;
; Now fetch the time
;		
			PUSH	HL		; UINT24 address
			CALL	_mos_GETRTC
			POP	HL
			RET 

; Set the RTC
; HLU: Pointer to a buffer with the time data in
;
mos_api_setrtc:		LD	A, MB		; Check if MBASE is 0
			OR	A, A 
			CALL	NZ, SET_AHL24	; If it is running in classic Z80 mode, set U to MB
;
; Now fetch the time
;		
			PUSH	HL		; UINT24 address
			CALL	_mos_SETRTC
			POP	HL
			RET 

; Set an interrupt vector
; HLU: Pointer to the interrupt vector (24-bit pointer)
;   E: Vector # to set
; Returns:
; HLU: Pointer to the previous vector
;
mos_api_setintvector:	LD	A, E 
			LD	DE, 0 		; Clear DE
			LD	E, A 		; Store the vector #
			PUSH	HL		; void(*handler)(void)
			PUSH	DE 		; byte vector
			CALL	_mos_SETINTVECTOR
			POP	DE 
			POP	DE
			RET 
			
; Set a VDP keyboard packet receiver callback
;   C: If non-zero then set the top byte of HLU(callback address)  to MB (for ADL=0 callers)
; HLU: Pointer to callback
;
mos_api_setkbvector:	PUSH	DE
			XOR	A
			OR	C		; If C!=0 set top byte (bits 16:23) to MB
			JR	Z, $F
			LD	A, MB
			CALL	SET_AHL24
$$:			PUSH	HL
			POP	DE
			LD	HL, _user_kbvector
			LD	(HL),DE		
			POP	DE
			RET

; Get the address of the keyboard map
; Returns:
; IXU: Base address of the keymap
; 
mos_api_getkbmap:	LD	IX, _keymap
			RET 

; Open the I2C bus as master
;   C: Frequency ID
;
mos_api_i2c_open:	PUSH	BC
			PUSH	DE
			PUSH	HL
			PUSH	IX
			PUSH	IY
;			
			LD	HL,0
			LD	L, C
			PUSH	HL
			CALL	_mos_I2C_OPEN
			POP	HL
;			
			POP	IY
			POP	IX
			POP	HL
			POP	DE
			POP	BC
			RET

; Close the I2C bus
;
mos_api_i2c_close:	PUSH	BC
			PUSH	DE
			PUSH	HL
			PUSH	IX
			PUSH	IY
;			
			CALL	_mos_I2C_CLOSE
;			
			POP	IY
			POP	IX
			POP	HL
			POP	DE
			POP	BC
			RET

; Write n bytes to the I2C bus
;   C: I2C address
;   B: Number of bytes to write, maximum 32
; HLU: Address of buffer containing the bytes to send
; 
mos_api_i2c_write:	PUSH	DE
			PUSH	IX
			PUSH	IY
;
			LD	A, MB		; Check if MBASE is 0
			OR	A, A 
			CALL	NZ, SET_AHL24	; If it is running in classic Z80 mode, set U to MB
;			
			PUSH	HL		; Address of buffer
			LD	HL,0
			LD	L, B
			PUSH	HL		; Count
			LD	L, C
			PUSH	HL		; I2C address
			CALL	_mos_I2C_WRITE
			POP	HL
			POP	HL
			POP	HL
;			
			POP	IY
			POP	IX
			POP	DE
			RET

; Read n bytes from the I2C bus
;   C: I2C address
;   B: Number of bytes to read, maximum 32
; HLU: Address of buffer to read bytes to
;
mos_api_i2c_read:	PUSH	DE
			PUSH	IX
			PUSH	IY
;
			LD	A, MB		; Check if MBASE is 0
			OR	A, A 
			CALL	NZ, SET_AHL24	; If it is running in classic Z80 mode, set U to MB
;			
			PUSH	HL		; Address of buffer
			LD	HL,0
			LD	L, B
			PUSH	HL		; Count
			LD	L, C
			PUSH	HL		; I2C address
			CALL	_mos_I2C_READ
			POP	HL
			POP	HL
			POP	HL
;			
			POP	IY
			POP	IX
			POP	DE
			RET

; Open UART1
; IXU: Pointer to UART struct
;	+0: Baud rate (24-bit, little endian)
;	+3: Data bits
;	+4: Stop bits
;	+5: Parity bits
;	+6: Flow control (0: None, 1: Hardware)
;	+7: Enabled interrupts
; Returns:
;   A: Error code (0 = no error)
;
mos_api_uopen:		LEA	HL, IX + 0	; HLU: Pointer to struct
			LD	A, MB 		; If in 64K segment when
			OR	A, A 		; MB != 0 then
			CALL	NZ, SET_AHL24 	; Convert to a 24-bit absolute pointer
			PUSH	HL		; UART * pUART
			CALL	_open_UART1	; Initialise the UART port
			LD	A, L 		; The return value is in HLU
			POP	HL 		; Tidy up the stack
			RET 

; Close UART1
;
mos_api_uclose:		JP	_close_UART1

; Get a character from UART1
; Returns:
;   A: Character read
;   F: C if successful
;   F: NC if the UART is not open
;
mos_api_ugetc		JP	UART1_serial_GETCH

; Write a character to UART1
;   C: Character to write
; Returns:
;   F: C if successful
;   F: NC if the UART is not open
;
mos_api_uputc:		LD	A, C 
			JP	UART1_serial_PUTCH

; Convert a file handle to a FIL structure pointer
;   C: Filehandle
; Returns:
; HLU: Pointer to a FIL struct
;
mos_api_getfil:		PUSH	BC		; UINT8 fh
			CALL	_mos_GETFIL
			POP	BC 
			RET

; Read a block of data from a file
;   C: Filehandle
; HLU: Pointer to where to write the data to
; DEU: Number of bytes to read
; Returns:
; DEU: Number of bytes read
;
mos_api_fread:		PUSH	DE		; UINT24 btr
			PUSH	HL		; UINT24 buffer
			PUSH	BC		; UINT8 fh
			CALL	_mos_FREAD
			LD	(_scratchpad), HL 
			POP	BC
			POP	HL
			POP	DE
			LD	DE, (_scratchpad)
			RET

; Write a block of data to a file
;  C: Filehandle
; HLU: Pointer to where the data is
; DEU: Number of bytes to write
; Returns:
; DEU: Number of bytes read
;
mos_api_fwrite:		PUSH	DE		; UINT24 btr
			PUSH	HL		; UINT24 buffer
			PUSH	BC		; UINT8 fh
			CALL	_mos_FWRITE
			LD	(_scratchpad), HL 
			POP	BC
			POP	HL
			POP	DE
			LD	DE, (_scratchpad)
			RET

; Move the read/write pointer in a file
;   C: Filehandle
; HLU: Least significant 3 bytes of the offset from the start of the file (DWORD)
;   E: Most significant byte of the offset
; Returns:
;   A: FRESULT
;
mos_api_flseek:		PUSH 	DE		; UINT32 offset (msb)
			PUSH	HL 		; UINT32 offset (lsb)
			PUSH	BC		; UINT8 fh
			CALL	_mos_FLSEEK
			LD	A, L 		; FRESULT
			POP	BC
			POP	HL
			POP	DE
			RET

; Open a file
; HLU: Pointer to a blank FIL struct
; DEU: Pointer to the filename (0 terminated)
;   C: File mode
; Returns:
;   A: FRESULT
;
ffs_api_fopen:		LD	A, MB		; A: MB
			OR	A, A 		; Check whether MB is 0, i.e. in 24-bit mode
			JR	Z, $F		; It is, so skip as all addresses can be assumed to be 24-bit
			CALL 	SET_ADE24	; Convert DE to an address in segment A (MB)
			CALL	GET_AHL24	; Get MSB of HL
			OR	A, A 		; Does it already contain a value? (fetched using mos_api_getfil?)
			LD	A, MB		; A: MB
			CALL	Z, SET_AHL24	; No it's zero, so convert HL to an address in segment A (MB)
;
$$:			PUSH	BC		; BYTE mode
			PUSH	DE		; const TCHAR * path
			PUSH	HL		; FIL * fp
			CALL	_f_open 
			LD	A, L 		; FRESULT
			POP	HL 		
			POP	DE
			POP	BC
			RET

; Close a file
; HLU: Pointer to a blank FIL struct
; Returns:
;   A: FRESULT
;
ffs_api_fclose:		LD	A, MB
			OR	A, A 
			JR	Z, $F
			CALL	GET_AHL24
			OR 	A, A 
			LD	A, MB
			CALL	Z, SET_AHL24
;
$$:			PUSH	HL		; FIL * fp
			CALL	_f_close 
			LD	A, L		; FRESULT
			POP	HL 
			RET

; Read data from a file
; HLU: Pointer to a FIL struct
; DEU: Pointer to where to write the file out
; BCU: Number of bytes to read
; Returns:
;   A: FRESULT
; BCU: Number of bytes read
;
ffs_api_fread:		LD	A, MB		; A: MB
			OR	A, A 		; Check whether MB is 0, i.e. in 24-bit mode
			JR	Z, $F		; It is, so skip as all addresses can be assumed to be 24-bit
			CALL 	SET_ADE24	; Convert DE to an address in segment A (MB)
			CALL	GET_AHL24	; Get MSB of HL
			OR	A, A 		; Does it already contain a value? (fetched using mos_api_getfil?)
			LD	A, MB		; A: MB
			CALL	Z, SET_AHL24	; No it's zero, so convert HL to an address in segment A (MB)
;
$$:			EXX		
			LD	HL, _scratchpad	; Scratchpad RAM
			PUSH	HL		; UINT * br
			EXX 
			PUSH	BC		; UINT btr
			PUSH	DE		; void * buff
			PUSH	HL		; FILE * fp
			CALL	_f_read 
			LD	A, L 		; FRESULT
			POP	HL
			POP	DE 
			POP	BC 
			POP	BC
			LD	BC, (_scratchpad)
			RET 

; Write data to a file
; HLU: Pointer to a FIL struct
; DEU: Pointer to the data to write out
; BCU: Number of bytes to write
; Returns:
;   A: FRESULT
; BCU: Number of bytes written
;
ffs_api_fwrite:		LD	A, MB		; A: MB
			OR	A, A 		; Check whether MB is 0, i.e. in 24-bit mode
			JR	Z, $F		; It is, so skip as all addresses can be assumed to be 24-bit
			CALL 	SET_ADE24	; Convert DE to an address in segment A (MB)
			CALL	GET_AHL24	; Get MSB of HL
			OR	A, A 		; Does it already contain a value? (fetched using mos_api_getfil?)
			LD	A, MB		; A: MB
			CALL	Z, SET_AHL24	; No it's zero, so convert HL to an address in segment A (MB)
;
$$:			EXX		
			LD	HL, _scratchpad	; Scratchpad RAM
			PUSH	HL		; UINT * bw
			EXX 
			PUSH	BC		; UINT btw
			PUSH	DE		; void * buff
			PUSH	HL		; FILE * fp
			CALL	_f_write 
			LD	A, L 		; FRESULT
			POP	HL
			POP	DE 
			POP	BC 
			POP	BC
			LD	BC, (_scratchpad)
			RET 	

; Check file exists
; HLU: Pointer to a FILINFO struct
; DEU: Pointer to the filename (0 terminated)
; Returns:
;   A: FRESULT
;
ffs_api_stat:		LD	A, MB		; A: MB
			OR	A, A 		; Check whether MB is 0, i.e. in 24-bit mode
			JR	Z, $F		; It is, so skip as all addresses can be assumed to be 24-bit
			CALL 	SET_ADE24	; Convert DE to an address in segment A (MB)
			CALL	GET_AHL24	; Get MSB of HL
			OR	A, A 		; Does it already contain a value? (fetched using mos_api_getfil?)
			LD	A, MB		; A: MB
			CALL	Z, SET_AHL24	; No it's zero, so convert HL to an address in segment A (MB)
;
$$:			PUSH	HL		; FILEINFO * fil
			PUSH	DE		; const TCHAR * path
			CALL	_f_stat 
			LD	A, L 		; FRESULT
			POP	DE 
			POP	HL
			RET

; Check for EOF
; HLU: Pointer to a FILINFO struct
; Returns:
;   A: 1 if end of file, otherwise 0
;
ffs_api_feof:		LD	A, MB
			OR	A, A 
			JR	Z, $F
			CALL	GET_AHL24
			OR 	A, A 
			LD	A, MB
			CALL	Z, SET_AHL24
;
$$:			PUSH	HL		; FILEINFO * fil
			CALL	_fat_EOF 
			LD	A, L 		; EOF
			POP	HL
			RET 

; Move the read/write pointer in a file
; HLU: Pointer to a FIL struct
; DEU: Least significant 3 bytes of the offset from the start of the file (DWORD)
;   C: Most significant byte of the offset
; Returns:
;   A: FRESULT
;
ffs_api_flseek:		LD	A, MB
			OR	A, A 
			JR	Z, $F
			CALL	GET_AHL24
			OR 	A, A 
			LD	A, MB
			CALL	Z, SET_AHL24
;
$$:			PUSH	BC 		; FSIZE_t ofs (msb)
			PUSH	DE		; FSIZE_t ofs (lsw)
			PUSH	HL		; FIL * fp
			CALL	_f_lseek 
			LD	A, L
			POP	HL		
			POP	DE
			POP	BC
			RET 

;		
; Commands that have not been implemented yet
;
ffs_api_ftruncate:	
ffs_api_fsync:		
ffs_api_fforward:	
ffs_api_fexpand:	
ffs_api_fgets:		
ffs_api_fputc:		
ffs_api_fputs:		
ffs_api_fprintf:	
ffs_api_ftell:		
ffs_api_fsize:		
ffs_api_ferror:		
ffs_api_dopen:		
ffs_api_dclose:		
ffs_api_dread:		
ffs_api_dfindfirst:	
ffs_api_dfindnext:	
ffs_api_unlink:		
ffs_api_rename:		
ffs_api_chmod:		
ffs_api_utime:		
ffs_api_mkdir:		
ffs_api_chdir:		
ffs_api_chdrive:	
ffs_api_getcwd:		
ffs_api_mount:		
ffs_api_mkfs:		
ffs_api_fdisk		
ffs_api_getfree:	
ffs_api_getlabel:	
ffs_api_setlabel:	
ffs_api_setcp:		
			RET