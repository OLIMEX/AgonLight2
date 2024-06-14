# AgonLight_GPIO

## Background
Agon Light is a compact low-cost board that is both a microcomputer and a BASIC-programmed microcontroller. It is intended to be easily hackable and allow interfacing with the outside world. It features 20x GPIO, plus SPI, I2C, UART for serial communication and allows a great opportunity for learning and experimentation.

## Introduction 

This repo is intended to provide some simple add on boards for gpio examples and experiments. Although I am of the 8 bit vintage, I consider myself a novice. I enjoy hardware making as a way to better understand the inner hardware workings and to ultimately improve my coding. All is a work in progress and is open to contributions and ideas, within the stated aims and limitations of this project.

## Aims
* Provide a range of simple IO hardware to aid coding in BBC BASIC.
* To be useful in gaining a general understanding of GPIO usage and real world interfacing.
* Stick to the general GPIOs only.
* Avoid cables and breadboards and try to fit a standardised form factor. In this case a plugable "faceplate" for the exiting gpio port. The board should avoid constraining any existing ports and access.
* Ideally, provide onboard visual feedback to aid learning.
* Avoid additional hardware processing on the add on board. Keeping access to the low level hardware prevents adding more complications when learning. I.e. GALs, additional controller ICs are to be avoided.

## The PCBs

KiCad, Schematics and Gerbers are provided. Renders of the boards are shown in the KiCad directory. Please review before making a commitment. No warranties or support are provided. As of this date PCBs are not yet tested but I will mark as such once done.

#### #1 - The Blinkenlight. - tested working
![](https://github.com/Kayto/AgonLight_GPIO/blob/main/KiCad/%231_Blinkenlight/%231_Blinkenlight-front_display.jpg)

Every 8 bit computer needs blinky lights. Not only do they look like good, they are useful for debugging and understanding what is going on at a bit level.
The Blinkenlight PCB is pretty much the breadboard example from the official documentation but without the fiddly wires. It directly plugs into the GPIO header and provides an easily viewable "faceplate". This presents the form for future boards.

#### #2 - 7 segment display. - tested working
![](https://github.com/Kayto/AgonLight_GPIO/blob/main/KiCad/%232_7Segment/%232_7segment-front_display.jpg)

This is a single 7 segment display linked to the Port C GPIOs. Allows a simple message display with a delay. Ok its only single digits but something to build on.
A caution on this is that you need a 7 segment display to suit the pin out (they do vary). Review the schematics, Pin 3 and 8 are power.I have provided a solder jumper for setting of common anode and common cathode displays. Note that for common anode the coding assumes a LOW signal for on and HIGH for off.

#### #3 - Double Seven
![](https://github.com/Kayto/AgonLight_GPIO/blob/main/KiCad/%232_7Segment/%233_7segment_double.jpg)

**In progress.**

This is a **double** 7 segment display linked to the Port C GPIOs for data and 2No. Port D GPIOs to do the multiplexing.
To save space resistor networks are used instead of individual resistors.

#### #4 - Moody. - tested working
![](https://github.com/Kayto/AgonLight_GPIO/blob/main/KiCad/%232_7Segment/%234_Moody_front.jpg)

This is an RGB LED linked to the Port C GPIOs, 2No. push buttons are also provided. The two push buttons on PC_3 and PC_4 are to establish some input and mode switching capability. 

## The Code

I have created some code to introduce the boards. As said, codng is not my strength so excuse the code, in some cases its not a great example but enough to get things going and for a challenge to improve.

| Board | Code | Description |
|:----------|:-------------|:-----|
|[#1_Blinkenlight](https://github.com/Kayto/AgonLight_GPIO/tree/main/KiCad/%231_Blinkenlight) | [PortC_blink.bbc](https://github.com/Kayto/AgonLight_GPIO/tree/main/Code) | select individual LEDs, set number of blinks and speed. |
|[#1_Blinkenlight](https://github.com/Kayto/AgonLight_GPIO/tree/main/KiCad/%231_Blinkenlight) | [gpioknight.bbc](https://github.com/Kayto/AgonLight_GPIO/tree/main/Code)| Some blinky patterns. Excuse the code, its a bad example with lots of inefficient duplication to get things done. The **challenge** is open to simplify this, perhaps a data array for the gpio commands and a single procedure for the delay?|
|[#2_seven_segment](https://github.com/Kayto/AgonLight_GPIO/tree/main/KiCad/%232_7Segment)|  [diceroll.bbc](https://github.com/Kayto/AgonLight_GPIO/tree/main/Code) | A random 1-6 generator for board games, handy. | 
|[#2_seven_segment](https://github.com/Kayto/AgonLight_GPIO/tree/main/KiCad/%232_7Segment)|  [counter.bbc](https://github.com/Kayto/AgonLight_GPIO/tree/main/Code) | A single digit counter, you're welcome. | 
|[#4_Moody](https://github.com/Kayto/AgonLight_GPIO/tree/main/KiCad/%234_Moody)|  [moodyfade.bbc](https://github.com/Kayto/AgonLight_GPIO/tree/main/Code) | An RGB fade using some crude PWM in BBC BASIC. | 
|[#4_Moody](https://github.com/Kayto/AgonLight_GPIO/tree/main/KiCad/%234_Moody)|  [moodybutton.bbc](https://github.com/Kayto/AgonLight_GPIO/tree/main/Code) | The RGB fade but now includes buttons. Button A for on and off. Button B to increase the fade speed.| 

## Disclaimer & Credits

Just a note that I am not in any way affiliated or linked with the Agon project.
I am just an aspiring maker, sharing hobbyist builds.
Thanks to the Agon project and supporters.




