A properly operating AgonLight2 system has three software components: Quark™ VDP + Quark™ MOS + Quark™ BBC BASIC. By default each Olimex AgonLight2 board comes with VDP and MOS already programmed. You only need to download the contents of folder "1-SD-card-contents" to a micro SD card to start using the AgonLight2 board. You need an micro SD card in FAT or FAT32 format.

Notice that certain combinations of versions of VDP, MOS, and BBC BASIC might be incompatible. Meaning that you might need to upgrade or downgrade MOS, VDP, BASIC in order to run the board. If in doubt, use the versions we provide.

We load the versions currently at this GitHub but the board that was not purchased directly from us might arrive with previous version of VDP and MOS.

It is always recommended to get the latest files and instructions from the official VDP, MOS, BASIC locations listed below, however if you enounter problems use the versions we have provided, we have tested them and confirmed them to work. 

    • Quark™ BBC BASIC – https://github.com/breakintoprogram/agon-bbc-basic/releases - BBC Basic interpreter
    • Quark™ MOS - https://github.com/breakintoprogram/agon-mos/releases - command line machine operating system, similar to CP/M or DOS
    • Quark™ VDP - https://github.com/breakintoprogram/agon-vdp/releases - the VDP is a serial graphics terminal that takes a BBC basic text output stream as input. The output is via the VGA connector on the Agon.

The "1-SD-card-contents" folder contains sub-folders with files for the SD card, also mos files that can be flashed via bootloader without programmer (if possible);

The "2-AgonLight2-VDP-XXX" folder contains VDP;

The "3-AgonLight2-MOS-XXX" folder contains MOS that can be flashed via programmer;

The "4-AgonLight2-Console8" folder contains Console8 versions of VDP, MOS, BBC basic that can be used to upgrade the system via SD card. Refer to the README.md file in the folder for details on how to switch to Console8 VPD, MOS, BBC basic.

Copy the contents in from the "SD Card Content" into the root directory of the card. The contents are:

1) bbcbasic.bin (for the latest version check: https://github.com/breakintoprogram/agon-bbc-basic);
2) autoexec.txt which runs the BASIC on restart;
3) basic_examples_tests – various BASIC examples/test/games programs;
4) Agon-CPM2.2 – contains CPM;
5) mos – contains files suitable for updating mos without programmer.

**Updating the Agon Quark VDP on the ESP32 chip with a binary:**

1. If you don't want to compile the source code you can just upload the binary (if you wish to compile from source check next chapter)
2.  Download all contents from /2-AgonLight2-VDP-104/binary-flasher - https://github.com/OLIMEX/AgonLight2/tree/main/SOFTWARE/2-AgonLight2-VDP-104/binary-flasher
3.  Open terminal or command line to the folder where the contents are
4.  Execute flash.sh followed by com port number of device assigned by operating system (usually COMx in Windows, TTYx in Linux).

**To compile and update the Agon Quark VDP on the ESP32 chip you have to install IDE, package and libraries:**

1. Arduino IDE

    1.1. Go to: https://www.arduino.cc/en/software

    1.2 While this will most likely work with 2.x.x we recommend you to download 1.8.9 which is shown a little bit below in the section "Legacy IDE (1.8.x)"

    1.3. Download, install and run it

2. Install the ESP32 package

    2.1. Go to "Main menu --> Preferences" (CTRL+,)

    2.2. In the "Additional Boards Manager URLs" add in a new line: https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json

    2.3. Go to "Main menu -> Tools -> Board -> Boards manager..."

    2.4. Look for the package "ESP32" (since there are lots of packages you can filter them by typing "ESP32" in the search bar on the top)

    2.5. Install the package (it is tested with v2.0.14, notice that versions 3.x.x are confirmed not working)

3. Install the FabGL library

    3.1. Go to "Main menu -> Sketch -> Include Library -> Manage Libraries..." (CTRL+SHIFT+I)

    3.2. Look for library FabGL (just like the packages earlier you can filter all the libraries by typing "FabGL" in the search bar)

    3.3. Install it (it is tested with 1.0.8, newer versions of the library may not work)

4. VDP compile and update
   
    4.1. Open the sketch /2-AgonLight2-VDP-104/Source/Video/video.ino (the provided one is version 1.04, for the latest one check https://github.com/breakintoprogram/agon-vdp )

    4.2. Go to "Main menu -> Tools -> Board -> ESP32 Arduino" and select "ESP32 Dev Module"

    4.3. Plug the USB to the AgonLight2 board

    4.4. In Device manager you can see the COM# at which our device has connected

    4.5. Go to "Main menu -> Tools -> Port" select the one ESP32 has connected

    4.6. Go to "Main menu -> Tools -> PSRAM" select Enabled

    4.7. Compile and Upload (every time after opening the project in Arduino the first compilation is VERY slow - be patient)

**Updating the Agon Quark MOS on the eZ80 chip:**

1. Usually you can update the MOS without the need of programmer (the board needs to have MOS 1.02). Follow the instructions in /1-SD-card-contents/mos/README.txt - https://github.com/OLIMEX/AgonLight2/tree/main/SOFTWARE/1-SD-card-contents/mos

2. If there is no MOS at all or it's older than 1.02 you must have "ZILOG eZ80F92" programmer and have to install IDE:

    2.1. Download "ZDS II - eZ80Acclaim!" from here: https://zilog.com/index.php?option=com_zcm&task=view&soft_id=54&Itemid=74 (tested with 5.3.5 but should work with newer versions)

    2.2. Install the IDE and run it

    2.3. Go to "Main menu -> File -> Open Project" and navigate to  "3-AgonLight2-MOS-104/MOS.zdsproj" (the provided versions is 1.04, for the latest one check https://github.com/breakintoprogram/agon-mos )

    2.4. Build the project (F7)

    2.5. Connect the programmer to the ZDI connector on the AgonLight2 board

    2.6. Go to "Main menu -> Debug -> Download the code"

    2.7. When the download is complete go again to "Main menu --> Debug --> Stop Debugging" (SHIFT + F5)

    2.8. Disconnect the programmer from the board
