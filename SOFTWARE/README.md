A properly operating AgonLight2 system has three software components Quark™ VDP + Quark™ MOS + Quark™ BBC BASIC. By default each Olimex AgonLight2 board comes with VDP and MOS already programmed. You only need to download the basic and the examples to an SD card to start using the AgonLight2 board. For the BASIC, MOS updater, CP/M and other examples and test programs you need an SD card in FAT or FAT32 format.

Notice that certain combinations of versions of VDP, MOS and basic might be incompatible. Meaning that you might need to upgrade or downgrade MOS, VDP, basic in order to run the board. If in doubt, use the versions we provide.

It is always recommended to get the latest files and instructions from the official VDP, MOS, BASIC locations listed below, however if you enounter problems use the versions we have provided, we have tested them and confirmed them to work.

    • Quark™ BBC BASIC – https://github.com/breakintoprogram/agon-bbc-basic/releases - BBC Basic interpreter
    • Quark™ MOS - https://github.com/breakintoprogram/agon-mos/releases - command line machine operating system, similar to CP/M or DOS
    • Quark™ VDP - https://github.com/breakintoprogram/agon-vdp/releases - the VDP is a serial graphics terminal that takes a BBC basic text output stream as input. The output is via the VGA connector on the Agon.

This "FIRMWARE" folder contains subfolders with files for the SD card (basic + examples) and also folders with file for VDP and MOS)

For the BASIC, MOS updater, CP/M and other examples, and test programs you need an SD card formatted in FAT or FAT32.

Copy the content in from the "SD Card Content" into the root directory of the card.
The content involves:
1) bbcbasic.bin (current version is 1.04, for the latest one check: https://github.com/breakintoprogram/agon-bbc-basic )
2) autoexec.txt which runs the BASIC on restart
3) mos (folder) - there is the MOS updater tool and a bin file for MOS 1.03 (provided by envenomator https://github.com/envenomator/agon-flash ). For more info read the README inside the mos fodler.
4) CP/B (folder) - Control Program/Monitor (provided by Nihirash: https://github.com/nihirash/Agon-CPM2.2 )
5) basic_examples_tests - various BASIC examples/test/games programs

For the Agon Quark VDP on the ESP32 chip you have to install IDE, package and libraries:

1) Arduino IDE
1.1) Go to: https://www.arduino.cc/en/software
1.2) While this will most likely work with 2.x.x we recommend you to download 1.8.9 which is shown a little bit below in the section "Legacy IDE (1.8.x)"
1.3) Download, install and run it

4) Install the ESP32 package
	2.1) Go to "Main menu --> Preferences" (CTRL+,)
	2.2) In the "Additional Boards Manager URLs" add in a new line: https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
	2.3) Go to "Main menu --> Tools --> Board --> Boards manager..."
	2.4) Look for the package "ESP32" (since there are lots of packages you can filter them by typing "ESP32" in the search bar on the top)
	2.5) Install the package (it is tested with 2.0.9v but later are likely to work)

5) Install the FabGL library
	3.1) Go to "Main menu --> Sketch --> Include Library --> Manage Libraries..." (CTRL+SHIFT+I)
	3.2) Look for library FabGL (just like the packages earlier you can filter all the libraries by typing "FabGL" in the search bar)
	3.3) Install it (it is tested with 1.0.8, newer versions of the library may not work)

6) Compile and Upload the firmware (Agon Quark VDP)
	4.1) Open the sketch AgonLigh2/AgonLight2.ino (the provided one is version 1.03, for the latest one check https://github.com/breakintoprogram/agon-vdp )
	4.2) Go to "Main menu --> Tools --> Board --> ESP32 Arduino" and select "ESP32 Dev Module"
	4.3) Plug the USB to the AgonLight2 board
	4.4) In Device manager you can see the COM# at which our device has connected
	4.5) Go to "Main menu --> Tools --> Port" select the one ESP32 has connected
	4.6) Go to "Main menu --> Tools --> PSRAM" select Enabled
	4.7) Compile and Upload (every time after opening the project in Arduino the first compilation is VERY slow - be patient)

For the Agon Quark MOS on the eZ80 chip:

1) If there is no MOS at all or it's older than 1.02 you must have "ZILOG eZ80F92" programmer and have to install IDE:
	1.1) Download "ZDS II - eZ80Acclaim!" from here: https://zilog.com/index.php?option=com_zcm&task=view&soft_id=54&Itemid=74 (tested with 5.3.5 but should work with newer versions)
	1.2) Install the IDE and run it
	1.3) Go to "Main menu --> File --> Open Project" and navigate to  "agon-mos-1.03/MOS.zdsproj" (the provided versions is 1.03, for the latest one check https://github.com/breakintoprogram/agon-mos )
	1.4) Build the project (F7)
	1.5) Connect the programmer to the ZDI connector on the AgonLight2 board
	1.6) Go to "Main menu --> Debug --> Download the code"
	1.7) When the download is complete go again to "Main menu --> Debug --> Stop Debugging" (SHIFT + F5)
	1.8) Disconnect the programmer from the board
2) If there is MOS 1.02 and you want to update it to a newer version you can still use the method described above but you can also do it from the console on the AgonLight2 board itself without the need of the programmer and IDE