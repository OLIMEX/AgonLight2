# tests

A handful of BBC BASIC programs I use for regression and soak testing:

- `assembler_stub.bas`: A stubbed assembly file
- `benchm9.bas`: Benchmark the file IO
- `circle_1.bas`: Draws circles using filled triangles
- `circle_2.bas`: Draws circle primitives
- `cube.bas`: Tests the graphics and floating point maths
- `fireworks.bas`: Tests palette animation
- `gpio_port_1.bas`: Writes out data to an eZ80 GPIO port
- `hatgraph.bas`: The iconic fedora hat graph
- `keyboard_1.bas`: Tests GET$
- `lines.bas`: Tests the line drawing
- `mandlebrot_1.bas`: A Mandlebrot set renderer
- `mode_test_1.bas`: Check mode memory allocation is working correctly
- `mode_test_2.bas`: Testcard to check resolution, colours, and monitor alignment
- `palette_1.bas`: Displays the full colour palette
- `rtc.bas`: Setting and getting the real-time clock
- `scroll_1.bas`: Scrolling stars demo (requires VDP 1.02)
- `scroll_2.bas`: Scrolling scramble-like landscape demo (requires VDP 1.02)
- `shadows.bas`: Tests the graphics commands for BBC Micro compatibility
- `sound_1.bas`: Tests the SOUND command, should play Amazing Grace
- `sprites_1.bas`: Demonstrates sprites in BBC BASIC
- `sprites_2.bas`: As sprites_1.bbc, but using PEEK and POKE rather than DIM to store the data
- `sprites_3.bas`: As sprites_2.bbc, but using machine code to move the sprites
- `sprites_4.bas`: As sprites_3.bbc, but loading a sprite animation from a file
- `sprites_5.bas`: As sprites_4.bbc, but includes scrolling stars (requires VDP 1.02)
- `sysvars.bas`: Using OSBYTE &A0 to fetch a MOS system variable (first 2 bytes of sysvar_time)
- `triangles.bas`: Tests the filled triangle drawing
- `udg.bas` Defines UDGs using VDU 23

And there are also a set of Rugg/Feldman (PCW) benchmark programs; benchm1.bas to benchm8.bas

NB: 
1. These have been saved now as text files, so will need BBC BASIC 1.04 to load
2. Any examples using graphics will require VDP and MOS 1.03 for logical graphics coordinates and palette animation