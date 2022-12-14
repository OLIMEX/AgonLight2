# AgonLight-

AgonLight OSHW Retro Z80 computer - updated version with few updates

This is re-dessign with few updates of the original version of AgonLight made by Bernardo Kastrup https://github.com/TheByteAttic/AgonLight

what is new:
- The board schematic and PCB are re-captured and re-layout in KiCad instead of EasyEDA;
- The power of the original AgonLight is delivered by a USB-A connector. We decided to replace it with USB-C connector which is used in all new phones, tablets and devices due to the new EU directive. Usually everyone has such a cable at home to charge and transfer files to their cell phone;
- The Linear voltage regulator is replaced with DCDC which delivers up to 2A current;
- Battery LiPo charger and step-up converter is add, which allows operations even if external power supply is interrupted;
- The original design has a PS2 connector for a keyboard and required a USB to PS2 adapter to operate with the more available USB keyboards. We replaced the PS2 connector with a USB-A connector so a normal USB keyboard (which supports PS2) can be directly plugged-in to AgonLight;
- AS7C34096A-10TCTR SRAM is routed with 40 ohm impedance lines as per the datasheet;
- Fixed a signal naming in the ESP32-PICO-D4, which now is updated in the original AgonLight documentation;
- The bare header 32-pin connector is replaced with a plastic boxed 34-pin connector following the same layout and adding two additional signals Vbat and Vin which allow AgonLight to be powered by this connector too;
- UEXT connector (https://www.olimex.com/Products/Modules/) is add which allows AgonLight to be connected to: temperature sensors, environmental air quality sensors, pressure, humidity, gyroscope, light, RS485, LCDs, LED matrix, relays, Bluettooth, Zigbee, Lora, GSM, RFID reader, GPS, Pulse, EKG, RTC etc;
- Four 3.3mm mount hole with  GND sleeve are add so the board can be mounted to future metal box;

## Licensee
* Hardware is released under CERN Open Hardware Licence Version 2 - Strongly Reciprocal, all silkscreen credits to Bernardo Kastrup and Dean Belfield should remain;
* Software is released under zlib Licensee
* Documentation is released under CC BY-SA 3.0

## Change History

14-12-2022 - Initial upload  of CAD files for first prototypes
