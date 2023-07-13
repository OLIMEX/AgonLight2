# AgonLight2

AgonLight OSHW Retro Z80 computer - an updated version with few updates

This is a re-design of the original version of AgonLight made by Bernardo Kastrup: https://github.com/TheByteAttic/AgonLight

What is new:
- The board schematic and PCB were re-captured and re-layout in KiCad instead of EasyEDA, KiCad is open source software – free to download and use, it is a more fitting CAD tool for an Open Source Hardware project;
- The power of the original AgonLight is delivered through USB-A connector. We decided to replace it with USB-C connector which is used in all new phones, tablets, and devices due to the new EU directive. Usually everyone has such a cable at home to charge and transfer files to their cell phone;
- The linear voltage regulator is replaced with DCDC which delivers up to 2A current;
- Battery Li-Po charger and step-up converter were added, this keeps the board fully operational even if the external power supply gets disconnected;
- The original design has a PS2 connector for a keyboard and required a USB to PS2 adapter to operate with the more available USB keyboards. We replaced the PS2 connector with a USB-A connector so a normal USB keyboard (which supports PS2) can be directly plugged-in to AgonLight;
- AS7C34096A-10TCTR SRAM is routed with 40 ohm impedance lines as per the datasheet;
- Fixed a signal naming in the ESP32-PICO-D4, which now is updated in the original AgonLight documentation;
- The bare header 32-pin connector is replaced with a plastic boxed 34-pin connector following the same layout and adding two additional signals Vbat and Vin which allow AgonLight to be powered via this connector too;
- [UEXT connector](https://www.olimex.com/Products/Modules/UEXT/) was added - it allows AgonLight to be expanded easily (without soldering) with: [temperature sensors, environmental air quality sensors, pressure sensors, humidity sensors, gyroscopes, light sensors, RS485, LCDs, LED matrices, relays, Bluetooth modules, Zigbee modules, Lora modules, GSM modules, RFID readers, GPS, pulse, EKG, RTC, etc](https://www.olimex.com/Products/Modules/);
- Added four 3.3mm mount holes with GND sleeve were added so the board can be attached firmly to a box or another board but also kept the original 2.5mm mount holes.

Please do not forget to check AgonLight topics in GitHub for many utilities and code written by AgonLight community: https://github.com/topics/agon-light

## Useful Agon Resources
- Bernardo Katrup https://github.com/TheByteAttic/AgonLight
- Dean Belfield Agon VDP, MOS, BBC-BASIC, Agon DOCs, projects https://github.com/breakintoprogram
- Lennart Benschop FORTH, Nano editor and MOS utilities https://github.com/lennart-benschop
- Jeroen Venema Agon Flash, HexLoad, Z80 assembler, tools, sokoban game https://github.com/envenomator
- Mario Smit Agon ZDI Load and tools https://github.com/S0urceror
- Reinhard Schu Agon Assembly https://github.com/schur/Agon-Light-Assembly
- AgonLight emulator https://github.com/james7780/AgonLightEmuSDL
- Alexander Sharikhin MOS tools https://github.com/nihirash/Agon-MOS-Tools
- Nicholas Pratt Agon Game https://github.com/NicholasPratt/Nova-Star
- Robert Lowe Agon Games collection https://github.com/pngwen
- LuzrBum Agon Games https://github.com/LuzrBum

## Licensee
* Hardware is released under CERN Open Hardware Licence Version 2 - Strongly Reciprocal, all silkscreen credits to Bernardo Kastrup and Dean Belfield should remain;
* Software is released under zlib Licensee
* Documentation is released under CC BY-SA 3.0

## Change History

23-04-2023 - Add Resources

14-12-2022 - Initial upload  of CAD files for first prototypes
