# agon-mos

Part of the official Quark firmware for the Agon series of microcomputers

### What is the Agon

Agon is a modern, fully open-source, 8-bit microcomputer and microcontroller in one small, low-cost board. As a computer, it is a standalone device that requires no host PC: it puts out its own video (VGA), audio (2 identical mono channels), accepts a PS/2 keyboard and has its own mass-storage in the form of a µSD card.

https://www.thebyteattic.com/p/agon.html

### What is a MOS

The MOS is a command line machine operating system, similar to CP/M or DOS, that provides a human interface to the Agon file system.

It also provides an API for file I/O and other common operations for BBC Basic for Z80 and other third-party applications.

### Loadig BBC Basic for Z80

1. Download bbcbasic.bin from [agon-bbc-basic releases](https://github.com/breakintoprogram/agon-bbc-basic/releases)
2. Copy it to the root directory of the Agon SD card
3. Insert the SD card into the AGON and reset/boot it
4. Check the file is on the SD card with a `CAT` or `.` command
5. Type the following commands into MOS:
	- `LOAD bbcbasic.bin`
	- `RUN`
6. You should then be greeted with the BBC Basic for Z80 prompt

### Etiquette

Please do not issue pull requests or issues for this project; it is very much a work-in-progress.
I will review this policy once the code is approaching live status and I have time to collaborate more.

### Build

The eZ80 is programmed via the ZDI connector on the left-hand side of the board. This requires a Zilog Smart Cable that can be purchased from online stockists such as Mouser or RS Components.

There are three compatible cables with the following part numbers:

- `ZUSBSC00100ZACG`: USB Smart Cable (discontinued)
- `ZUSBASC0200ZACG`: USB Smart Cable (in stock - this requires ZDS II version 5.3.5)
- `ZENETSC0100ZACG`: Ethernet Smart Cable (in stock)

Important! Make sure you get the exact model of cable; there are variants for the Zilog Encore CPU that have similar part numbers, but are not compatible with the Acclaim! eZ80 CPU.

You can download the ZDS II tools for free via these links. The software contains an IDE, Debugger, C Compiler and eZ80 Assembler.

- [Zilog ZDS II Tools version 5.3.4](https://zilog.com/index.php?option=com_zcm&task=view&soft_id=38&Itemid=74)
- [Zilog ZDS II Tools version 5.3.5](https://zilog.com/index.php?option=com_zcm&task=view&soft_id=54&Itemid=74)

You will also need a [Hex2Bin utility](https://sourceforge.net/projects/hex2bin/) to convert the MOS.hex file to MOS.bin ready for release.

NB:

- The tools are only available for Windows PC.
- The tools are compatible with Wine on Linux / OSX, but the USB Smart Cable drivers do not work
- The Ethernet Smart Cable may be compatible with the tools running on Wine, though this combination has not been tested by me

I currently build the official Quark software on a Windows XP KVM running on Ubuntu 20.04 LTS, using ZDS II Tools version 5.3.4, connecting to the Agon with the discontinued USB smart cable.

It is recommended that building and testing the MOS is done via the ZDS II tools and a Zilog Smart Cable, otherwise there is an increased risk of bricking the Agon.

Other options for developing C and eZ80 on the Agon are available. Please check the [Agon Programmers Group on Facebook](https://www.facebook.com/groups/667325088311886) for more information.

Any custom settings for Agon development is contained within the project files, so no further configuration will need to be done.

### Documentation

The AGON documentation can now be found on the [Agon Light Documentation Wiki](https://github.com/breakintoprogram/agon-docs/wiki)

### Licenses

This code is released under an MIT license, with the following exceptions:

* FatFS: The license for the [FAT filing system by ChaN](http://elm-chan.org/fsw/ff/00index_e.html) can be found here [src_fatfs/LICENSE](src_fatfs/LICENSE) along with the accompanying code.

### Links

- [Zilog eZ80 User Manual](http://www.zilog.com/docs/um0077.pdf)
- [ZiLOG Developer Studio II User Manual](http://www.zilog.com/docs/devtools/um0144.pdf)
- [FatFS - Generic File System](http://elm-chan.org/fsw/ff/00index_e.html)
- [AVRC Tutorials - Initialising an SD Card](http://www.rjhcoding.com/avrc-sd-interface-1.php)