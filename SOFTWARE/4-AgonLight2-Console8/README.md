The procedure below would upgrade AgonLight2's MOS and VDP to Console8 MOS 2.2.3 and Console8 VPD v2.9.0.

You need microSD card, micro SD card writer tool, USB keyboard (not all USB keyboards would work with AgonLight2, only those with PS/2 compatiblity) and all files from this GitHub repo.

Make sure to format your SD card in FAT32, if you have doubt there is something left over on it, try formatting it with "SD Memory Card Formatter" tool released by "SD Association".

Download all files from GitHub (better download the whole repo) and copy the contents of "4-AgonLight2-Console8" folder and place them in the root folder of an SD card (keep same sub-folders). Insert the SD card into AgonLight2 and power, when possible type:

>*flash all

You will be prompted to agree to flash the firmware. Press "Y" to agree. Wait until upgrade suceeeds.

Console8 MOS (MOS.bin) v2.2.3 downloaded from:

https://github.com/AgonConsole8/agon-mos/releases/

Console8 VPD (firmware.bin) v2.9.0 downloaded from:

https://github.com/AgonConsole8/agon-vdp/releases/

agon-flash v1.7 downloaded from:

https://github.com/envenomator/agon-flash/releases/tag/v1.7