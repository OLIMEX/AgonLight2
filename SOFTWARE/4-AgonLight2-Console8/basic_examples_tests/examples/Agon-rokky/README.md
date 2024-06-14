# Rokky - Small Rocks'n'Diamonds-like game for Agon Light

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/D1D6JVS74)

![screenshot](screenshot.jpg)

## Playing game

Just copy binary to SD card - load and run it from MOS and enjoy game.

## Development

Code written directly on Agon Light and compiled with [agon-ez80asm](https://github.com/envenomator/agon-ez80asm). I'm strongly recommend use latest version of ez80asm - cause it updates often and goes better and better every day.

I'm using [Nano](https://github.com/lennart-benschop/agon-utilities) text editor for Agon Light for writting code directly on Agon.

Images just converted with imagemagick.

Levels was created in CharPad tool(use 32x23 size and `chars.raw` font - included in repo) and you'll can make new levels or edit existings. 

## Known issues

Rarely(really) cursor key can be "locked". Press this direction again and it will be fixed - it happens cause I'm reading OS var for scan codes and even button pressed and button released and it can happens if I lost one even. 

I didn't found another way make controls so responsive without using external devices(like joystick).

## Licensing

Rokky licensed with [Nihirash's Coffeware License](LICENSE). 

It isn't hard to respect it.

Happy hacking!
