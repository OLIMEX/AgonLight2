#! /bin/bash
BAUD=921600

if [ "$#" -eq 0 ] || [ "$#" -gt 2 ]; then
    echo Usage: flash [SERIAL_PORT] \<BAUDRATE\>
    exit 1
fi

if [ "$#" -eq 1 ]; then
    SERIAL=$1
fi

if [ "$#" -eq 2 ]; then
    SERIAL=$1
    BAUD=$2
fi
echo Flashing to ESP32...
esptool.py --chip esp32 --port "$SERIAL" --baud $BAUD --before default_reset --after hard_reset write_flash  -z --flash_mode dio --flash_freq 80m --flash_size 4MB 0x1000 "./bootloader.bin" 0x8000 "./partitions.bin" 0x10000 "./firmware.bin" 
