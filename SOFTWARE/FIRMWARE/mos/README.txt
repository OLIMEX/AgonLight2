To update follow the instructions here:
https://github.com/envenomator/agon-flash

With the provided in the mos directory MOS firmware 1.03 you can use the following command:
	FLASH firmware103.bin 0x81E397C9

In case you are still running the basic (seen > at the start of each line) you may have to leave it first by typing "BYE" or instead you can just use a '*' at the start:
	*FLASH firmware103.bin 0x81E397C9

For newer versions you have to correct the checksum at the end.
If you don't have any tool to generate it just run this command with a random checksum (for example 0):
	*FLASH firmware103.bin 0

And at the end it will fail because it's wrong BUT will also tell you what is the expected checksum.
	Testing CRC32: 0x00000000
	CRC32 result: <the real checksum>
	
	Mismatch - aborting

Then rerun the FLASH command with the checksum you have seen.