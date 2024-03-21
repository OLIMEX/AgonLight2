@ECHO OFF
SET "comport="
SET "baudrate="
CALL SET "comport=%%1"
CALL SET "baudrate=%%2"
IF defined comport GOTO :baudrate

:nocomport
@ECHO Usage: flash ^[COM_PORT^] ^<BAUDRATE^>
exit /b %ERRORLEVEL%

:baudrate
IF defined baudrate GOTO :flash
CALL SET "baudrate=921600"

:flash
ECHO Flashing to ESP32...
".\esptool.exe" --chip esp32 --port %comport% --baud %baudrate%  --before default_reset --after hard_reset write_flash  -z --flash_mode dio --flash_freq 80m --flash_size 4MB 0x1000 ".\bootloader.bin" 0x8000 ".\partitions.bin"  0x10000 ".\firmware.bin" 
exit

