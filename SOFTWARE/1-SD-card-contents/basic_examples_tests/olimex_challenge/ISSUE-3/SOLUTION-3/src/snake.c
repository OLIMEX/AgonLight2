#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "vdp.h"
#include "sprite.h"
#include "agontimer.h"
#include "mos-keycode.h"

#define BOARD_HEIGHT 30
#define BOARD_WIDTH  40

#define MAX_LEVEL 10

#define STATE_OK        0
#define STATE_COLLISION 1
#define STATE_CANCELLED 2

#define CELL_EMPTY 0
#define CELL_FRUIT 1
#define CELL_SNAKE 2
#define CELL_WALL  3

#define NONE  0
#define UP    1
#define LEFT  2
#define DOWN  3
#define RIGHT 4

#define TILE_SNAKE	0
#define TILE_FLOOR	1
#define TILE_WALL	2
#define TILE_APPLE	3

#define BITMAP_WIDTH  16
#define BITMAP_HEIGHT 16

int opt_delay;
int opt_apples_per_level;
int opt_start_level;
int errno;

UINT32 apple_data[256] = {
0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xff000000, 0xff000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 
0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xff000000, 0xff008000, 0xff008000, 0xff000000, 0xff000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 
0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xff000000, 0xff000000, 0xff008000, 0xff008000, 0xff000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 
0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xff000000, 0xff000000, 0xff008000, 0xff000000, 0xff000000, 0xff000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 
0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xff000000, 0xff0000ff, 0xff000000, 0xff008000, 0xff000000, 0xff0000ff, 0xff0000ff, 0xff000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 
0x00000000, 0x00000000, 0x00000000, 0xff000000, 0xff0000ff, 0xff0000ff, 0xff0000ff, 0xff008000, 0xff0000ff, 0xff0000ff, 0xff0000ff, 0xff0000ff, 0xff000000, 0x00000000, 0x00000000, 0x00000000, 
0x00000000, 0x00000000, 0xff000000, 0xff000080, 0xff0000ff, 0xff0000ff, 0xff0000ff, 0xff0000ff, 0xff0000ff, 0xff0000ff, 0xffffffff, 0xffffffff, 0xff0000ff, 0xff000000, 0x00000000, 0x00000000, 
0x00000000, 0xff000000, 0xff000080, 0xff0000ff, 0xff000080, 0xff0000ff, 0xff0000ff, 0xff0000ff, 0xffffffff, 0xff0000ff, 0xffffffff, 0xffffffff, 0xff0000ff, 0xff0000ff, 0xff000000, 0x00000000, 
0x00000000, 0xff000000, 0xff0000ff, 0xff000080, 0xff0000ff, 0xff0000ff, 0xff0000ff, 0xff0000ff, 0xff0000ff, 0xff0000ff, 0xff0000ff, 0xff0000ff, 0xff0000ff, 0xff0000ff, 0xff000000, 0x00000000, 
0x00000000, 0xff000000, 0xff000080, 0xff0000ff, 0xff000080, 0xff0000ff, 0xff0000ff, 0xff0000ff, 0xff0000ff, 0xff0000ff, 0xff0000ff, 0xff0000ff, 0xff0000ff, 0xff0000ff, 0xff000000, 0x00000000, 
0x00000000, 0xff000000, 0xff0000ff, 0xff000080, 0xff0000ff, 0xff000080, 0xff0000ff, 0xff0000ff, 0xff0000ff, 0xff0000ff, 0xff0000ff, 0xff000080, 0xff0000ff, 0xff000080, 0xff000000, 0x00000000, 
0x00000000, 0xff000000, 0xff000080, 0xff0000ff, 0xff000080, 0xff0000ff, 0xff000080, 0xff0000ff, 0xff000080, 0xff0000ff, 0xff000080, 0xff0000ff, 0xff000080, 0xff0000ff, 0xff000000, 0x00000000, 
0x00000000, 0x00000000, 0xff000000, 0xff000080, 0xff0000ff, 0xff000080, 0xff0000ff, 0xff000080, 0xff0000ff, 0xff000080, 0xff0000ff, 0xff000080, 0xff0000ff, 0xff000000, 0x00000000, 0x00000000, 
0x00000000, 0x00000000, 0x00000000, 0xff000000, 0xff000080, 0xff0000ff, 0xff000080, 0xff0000ff, 0xff000080, 0xff0000ff, 0xff000080, 0xff0000ff, 0xff000000, 0x00000000, 0x00000000, 0x00000000, 
0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xff000000, 0xff000080, 0xff0000ff, 0xff000080, 0xff000000, 0xff000080, 0xff0000ff, 0xff000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 
0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xff000000, 0xff000000, 0xff000000, 0x00000000, 0xff000000, 0xff000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000
};

UINT32 wall_data[256] = {
0xff008080, 0xff008080, 0xff008080, 0xff008080, 0xff008080, 0xff008080, 0xff008080, 0xff404040, 0xff008080, 0xff008080, 0xff008080, 0xff008080, 0xff008080, 0xff008080, 0xff008080, 0xff008080, 
0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff808080, 0xff404040, 0xff008080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 
0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff808080, 0xff404040, 0xff008080, 0xff000080, 0xff808080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 
0xff000080, 0xff000080, 0xff808080, 0xff808080, 0xff000080, 0xff000080, 0xff808080, 0xff404040, 0xff008080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 
0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff808080, 0xff404040, 0xff008080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 
0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff808080, 0xff404040, 0xff008080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff808080, 0xff808080, 0xff000080, 
0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff404040, 0xff008080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 
0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 
0xff404040, 0xff008080, 0xff008080, 0xff008080, 0xff008080, 0xff008080, 0xff008080, 0xff008080, 0xff008080, 0xff008080, 0xff008080, 0xff008080, 0xff008080, 0xff008080, 0xff008080, 0xff008080, 
0xff404040, 0xff008080, 0xff008080, 0xff000080, 0xff808080, 0xff808080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff808080, 
0xff404040, 0xff008080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff808080, 
0xff404040, 0xff008080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff808080, 0xff808080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff808080, 
0xff404040, 0xff008080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff808080, 0xff000080, 0xff808080, 
0xff404040, 0xff008080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff000080, 0xff808080, 
0xff404040, 0xff008080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 
0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040
};

UINT32 snake_data[256] = {
0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xff008000, 0xff008000, 0xff008000, 0x00000000, 0x00000000, 0xff008000, 0xff008000, 0xff008000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 
0x00000000, 0x00000000, 0x00000000, 0xff008000, 0xff008000, 0xff008000, 0xff008000, 0x00000000, 0x00000000, 0xff008000, 0xff008000, 0xff008000, 0xff008000, 0x00000000, 0x00000000, 0x00000000, 
0x00000000, 0x00000000, 0xff008000, 0xff008000, 0xff008000, 0xff008000, 0x00000000, 0xff008000, 0xff008000, 0x00000000, 0xff008000, 0xff008000, 0xff008000, 0xff008000, 0x00000000, 0x00000000, 
0x00000000, 0xff008000, 0xff008000, 0xff008000, 0xff008000, 0x00000000, 0x00000000, 0xff008000, 0xff008000, 0x00000000, 0x00000000, 0xff008000, 0xff008000, 0xff008000, 0xff008000, 0x00000000, 
0xff008000, 0xff008000, 0xff008000, 0xff008000, 0x00000000, 0x00000000, 0x00000000, 0xff008000, 0xff008000, 0x00000000, 0x00000000, 0x00000000, 0xff008000, 0xff008000, 0xff008000, 0xff008000, 
0xff008000, 0xff008000, 0xff008000, 0x00000000, 0x00000000, 0xff008000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xff008000, 0x00000000, 0x00000000, 0xff008000, 0xff008000, 0xff008000, 
0xff008000, 0xff008000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xff008000, 0xff008000, 
0x00000000, 0x00000000, 0xff008000, 0xff008000, 0xff008000, 0x00000000, 0x00000000, 0xff00ff00, 0xff00ff00, 0x00000000, 0x00000000, 0xff008000, 0xff008000, 0xff008000, 0x00000000, 0x00000000, 
0x00000000, 0x00000000, 0xff008000, 0xff008000, 0xff008000, 0x00000000, 0x00000000, 0xff00ff00, 0xff00ff00, 0x00000000, 0x00000000, 0xff008000, 0xff008000, 0xff008000, 0x00000000, 0x00000000, 
0xff008000, 0xff008000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xff008000, 0xff008000, 
0xff008000, 0xff008000, 0xff008000, 0x00000000, 0x00000000, 0xff008000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xff008000, 0x00000000, 0x00000000, 0xff008000, 0xff008000, 0xff008000, 
0xff008000, 0xff008000, 0xff008000, 0xff008000, 0x00000000, 0x00000000, 0x00000000, 0xff008000, 0xff008000, 0x00000000, 0x00000000, 0x00000000, 0xff008000, 0xff008000, 0xff008000, 0xff008000, 
0x00000000, 0xff008000, 0xff008000, 0xff008000, 0xff008000, 0x00000000, 0x00000000, 0xff008000, 0xff008000, 0x00000000, 0x00000000, 0xff008000, 0xff008000, 0xff008000, 0xff008000, 0x00000000, 
0x00000000, 0x00000000, 0xff008000, 0xff008000, 0xff008000, 0xff008000, 0x00000000, 0xff008000, 0xff008000, 0x00000000, 0xff008000, 0xff008000, 0xff008000, 0xff008000, 0x00000000, 0x00000000, 
0x00000000, 0x00000000, 0x00000000, 0xff008000, 0xff008000, 0xff008000, 0xff008000, 0x00000000, 0x00000000, 0xff008000, 0xff008000, 0xff008000, 0xff008000, 0x00000000, 0x00000000, 0x00000000, 
0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xff008000, 0xff008000, 0xff008000, 0x00000000, 0x00000000, 0xff008000, 0xff008000, 0xff008000, 0x00000000, 0x00000000, 0x00000000, 0x00000000
};

UINT8 levels[][64] = {
{
	// level 1
	4,
	0, 0, BOARD_HEIGHT - 1, 0,
	BOARD_HEIGHT - 1, 0, BOARD_HEIGHT - 1, BOARD_WIDTH - 1,
	0, BOARD_WIDTH - 1, BOARD_HEIGHT - 1, BOARD_WIDTH - 1,
	2, 0, 2, BOARD_WIDTH - 1
},
{
	// level 2
	5,
	0, 0, BOARD_HEIGHT - 1, 0,
	BOARD_HEIGHT - 1, 0, BOARD_HEIGHT - 1, BOARD_WIDTH - 1,
	0, BOARD_WIDTH - 1, BOARD_HEIGHT - 1, BOARD_WIDTH - 1,
	2, 0, 2, BOARD_WIDTH - 1,
	1 + (BOARD_HEIGHT - 2)/2, BOARD_WIDTH/4, 1 + (BOARD_HEIGHT - 2)/2, BOARD_WIDTH - 1 - BOARD_WIDTH/4
},
{
	// level 3
	6,
	0, 0, BOARD_HEIGHT - 1, 0,
	BOARD_HEIGHT - 1, 0, BOARD_HEIGHT - 1, BOARD_WIDTH - 1,
	0, BOARD_WIDTH - 1, BOARD_HEIGHT - 1, BOARD_WIDTH - 1,
	2, 0, 2, BOARD_WIDTH - 1,
	1 + (BOARD_HEIGHT - 2)/2, BOARD_WIDTH/4, 1 + (BOARD_HEIGHT - 2)/2, BOARD_WIDTH - 1 - BOARD_WIDTH/4,
	BOARD_HEIGHT/4, BOARD_WIDTH/2, BOARD_HEIGHT - BOARD_HEIGHT/4, BOARD_WIDTH/2,
},
{
	// level 4
	8,
	0, 0, BOARD_HEIGHT - 1, 0,
	BOARD_HEIGHT - 1, 0, BOARD_HEIGHT - 1, BOARD_WIDTH - 1,
	0, BOARD_WIDTH - 1, BOARD_HEIGHT - 1, BOARD_WIDTH - 1,
	2, 0, 2, BOARD_WIDTH - 1,

	BOARD_HEIGHT/4,                        BOARD_WIDTH/4, BOARD_HEIGHT - BOARD_HEIGHT/4,         BOARD_WIDTH/4,

	(BOARD_HEIGHT - 2)/4,                  BOARD_WIDTH/4, (BOARD_HEIGHT - 2)/4,                  BOARD_WIDTH - 1 - BOARD_WIDTH/4,
	1 + (BOARD_HEIGHT - 2)/2,              BOARD_WIDTH/4, 1 + (BOARD_HEIGHT - 2)/2,              BOARD_WIDTH - 1 - BOARD_WIDTH/4,
	BOARD_HEIGHT - ((BOARD_HEIGHT - 2)/4), BOARD_WIDTH/4, BOARD_HEIGHT - ((BOARD_HEIGHT - 2)/4), BOARD_WIDTH - 1 - BOARD_WIDTH/4,
},
{
	// level 5
	8,

	0, 0, BOARD_HEIGHT - 1, 0,
	BOARD_HEIGHT - 1, 0, BOARD_HEIGHT - 1, BOARD_WIDTH - 1,
	0, BOARD_WIDTH - 1, BOARD_HEIGHT - 1, BOARD_WIDTH - 1,
	2, 0, 2, BOARD_WIDTH - 1,

	1 + (BOARD_HEIGHT - 2)/2, BOARD_WIDTH/4, 1 + (BOARD_HEIGHT - 2)/2, BOARD_WIDTH - 1 - BOARD_WIDTH/4,

	BOARD_HEIGHT/4, BOARD_WIDTH/4,               BOARD_HEIGHT - BOARD_HEIGHT/4, BOARD_WIDTH/4,
	BOARD_HEIGHT/4, BOARD_WIDTH/2,               BOARD_HEIGHT - BOARD_HEIGHT/4, BOARD_WIDTH/2,
	BOARD_HEIGHT/4, BOARD_WIDTH - BOARD_WIDTH/4, BOARD_HEIGHT - BOARD_HEIGHT/4, BOARD_WIDTH - BOARD_WIDTH/4,
},
{
	// level 6
	9,

	0, 0, BOARD_HEIGHT - 1, 0,
	BOARD_HEIGHT - 1, 0, BOARD_HEIGHT - 1, BOARD_WIDTH - 1,
	0, BOARD_WIDTH - 1, BOARD_HEIGHT - 1, BOARD_WIDTH - 1,
	2, 0, 2, BOARD_WIDTH - 1,

	BOARD_HEIGHT/4,                BOARD_WIDTH/4,               BOARD_HEIGHT/4,                BOARD_WIDTH/2 - 3,
	BOARD_HEIGHT/4,                BOARD_WIDTH/2 + 3,           BOARD_HEIGHT/4,                BOARD_WIDTH - BOARD_WIDTH/4,
	BOARD_HEIGHT/4,                BOARD_WIDTH/4,               BOARD_HEIGHT - BOARD_HEIGHT/4, BOARD_WIDTH/4,
	BOARD_HEIGHT/4,                BOARD_WIDTH - BOARD_WIDTH/4, BOARD_HEIGHT - BOARD_HEIGHT/4, BOARD_WIDTH - BOARD_WIDTH/4,
	BOARD_HEIGHT - BOARD_HEIGHT/4, BOARD_WIDTH/4,               BOARD_HEIGHT - BOARD_HEIGHT/4, BOARD_WIDTH - BOARD_WIDTH/4,
},
{
	// level 7
	9,

	0, 0, BOARD_HEIGHT - 1, 0,
	BOARD_HEIGHT - 1, 0, BOARD_HEIGHT - 1, BOARD_WIDTH - 1,
	0, BOARD_WIDTH - 1, BOARD_HEIGHT - 1, BOARD_WIDTH - 1,
	2, 0, 2, BOARD_WIDTH - 1,

	BOARD_HEIGHT/4, BOARD_WIDTH/4,                   BOARD_HEIGHT - BOARD_HEIGHT/4, BOARD_WIDTH/4,
	BOARD_HEIGHT/4, BOARD_WIDTH - 1 - BOARD_WIDTH/4, BOARD_HEIGHT - BOARD_HEIGHT/4, BOARD_WIDTH - 1 - BOARD_WIDTH/4,

	(BOARD_HEIGHT - 2)/4,                  BOARD_WIDTH/4 + 5, (BOARD_HEIGHT - 2)/4,                  BOARD_WIDTH - 1 - BOARD_WIDTH/4,
	1 + (BOARD_HEIGHT - 2)/2,              BOARD_WIDTH/4,     1 + (BOARD_HEIGHT - 2)/2,              BOARD_WIDTH - 1 - BOARD_WIDTH/4 - 5,
	BOARD_HEIGHT - ((BOARD_HEIGHT - 2)/4), BOARD_WIDTH/4 + 5, BOARD_HEIGHT - ((BOARD_HEIGHT - 2)/4), BOARD_WIDTH - 1 - BOARD_WIDTH/4,
},
{
	// level 8
	11,

	0, 0, BOARD_HEIGHT - 1, 0,
	BOARD_HEIGHT - 1, 0, BOARD_HEIGHT - 1, BOARD_WIDTH - 1,
	0, BOARD_WIDTH - 1, BOARD_HEIGHT - 1, BOARD_WIDTH - 1,
	2, 0, 2, BOARD_WIDTH - 1,

	BOARD_HEIGHT/4, BOARD_WIDTH/4 - 2,  BOARD_HEIGHT - BOARD_HEIGHT/4, BOARD_WIDTH/4 - 2,
	BOARD_HEIGHT/4, BOARD_WIDTH/4 + 2,  BOARD_HEIGHT - BOARD_HEIGHT/4, BOARD_WIDTH/4 + 2,
	BOARD_HEIGHT/4, BOARD_WIDTH/4 + 6,  BOARD_HEIGHT - BOARD_HEIGHT/4, BOARD_WIDTH/4 + 6,
	BOARD_HEIGHT/4, BOARD_WIDTH/4 + 10, BOARD_HEIGHT - BOARD_HEIGHT/4, BOARD_WIDTH/4 + 10,
	BOARD_HEIGHT/4, BOARD_WIDTH/4 + 14, BOARD_HEIGHT - BOARD_HEIGHT/4, BOARD_WIDTH/4 + 14,
	BOARD_HEIGHT/4, BOARD_WIDTH/4 + 18, BOARD_HEIGHT - BOARD_HEIGHT/4, BOARD_WIDTH/4 + 18,
	BOARD_HEIGHT/4, BOARD_WIDTH/4 + 22, BOARD_HEIGHT - BOARD_HEIGHT/4, BOARD_WIDTH/4 + 22,
},
{
	// level 9
	11,

	0, 0, BOARD_HEIGHT - 1, 0,
	BOARD_HEIGHT - 1, 0, BOARD_HEIGHT - 1, BOARD_WIDTH - 1,
	0, BOARD_WIDTH - 1, BOARD_HEIGHT - 1, BOARD_WIDTH - 1,
	2, 0, 2, BOARD_WIDTH - 1,

	BOARD_HEIGHT/4, BOARD_WIDTH/4,                   BOARD_HEIGHT - BOARD_HEIGHT/4, BOARD_WIDTH/4,
	BOARD_HEIGHT/4, BOARD_WIDTH - 1 - BOARD_WIDTH/4, BOARD_HEIGHT - BOARD_HEIGHT/4, BOARD_WIDTH - 1 - BOARD_WIDTH/4,

	(BOARD_HEIGHT - 2)/4,                    BOARD_WIDTH/4,     (BOARD_HEIGHT - 2)/4,                    BOARD_WIDTH - 1 - BOARD_WIDTH/4 - 5,
	1 + (BOARD_HEIGHT - 2)/2,                BOARD_WIDTH/4,     1 + (BOARD_HEIGHT - 2)/2,                BOARD_WIDTH - 1 - BOARD_WIDTH/4 - 5,
	BOARD_HEIGHT - ((BOARD_HEIGHT - 2)/4),   BOARD_WIDTH/4,     BOARD_HEIGHT - ((BOARD_HEIGHT - 2)/4),   BOARD_WIDTH - 1 - BOARD_WIDTH/4 - 5,
	
	(BOARD_HEIGHT - 2)/2 - BOARD_HEIGHT/4 + 4,   BOARD_WIDTH/4 + 5, (BOARD_HEIGHT - 2)/2 - BOARD_HEIGHT/4 + 4,   BOARD_WIDTH - 1 - BOARD_WIDTH/4,
	(BOARD_HEIGHT - 2)/2 + BOARD_HEIGHT/4 - 2,   BOARD_WIDTH/4 + 5, (BOARD_HEIGHT - 2)/2 + BOARD_HEIGHT/4 - 2,   BOARD_WIDTH - 1 - BOARD_WIDTH/4,
},
{
	// level 10
	11,

	0, 0, BOARD_HEIGHT - 1, 0,
	BOARD_HEIGHT - 1, 0, BOARD_HEIGHT - 1, BOARD_WIDTH - 1,
	0, BOARD_WIDTH - 1, BOARD_HEIGHT - 1, BOARD_WIDTH - 1,
	2, 0, 2, BOARD_WIDTH - 1,

	BOARD_HEIGHT/4,                BOARD_WIDTH/4, BOARD_HEIGHT/4,                BOARD_WIDTH - BOARD_WIDTH/4,
	BOARD_HEIGHT - BOARD_HEIGHT/4, BOARD_WIDTH/4, BOARD_HEIGHT - BOARD_HEIGHT/4, BOARD_WIDTH - BOARD_WIDTH/4,

	BOARD_HEIGHT/4,     BOARD_WIDTH/4,               BOARD_HEIGHT/2 - 3,            BOARD_WIDTH/4,
	BOARD_HEIGHT/2 + 3, BOARD_WIDTH/4,               BOARD_HEIGHT - BOARD_HEIGHT/4, BOARD_WIDTH/4,
	BOARD_HEIGHT/4,     BOARD_WIDTH - BOARD_WIDTH/4, BOARD_HEIGHT/2 - 3,            BOARD_WIDTH - BOARD_WIDTH/4,
	BOARD_HEIGHT/2 + 3, BOARD_WIDTH - BOARD_WIDTH/4, BOARD_HEIGHT - BOARD_HEIGHT/4, BOARD_WIDTH - BOARD_WIDTH/4,

	BOARD_HEIGHT/4, BOARD_WIDTH/2, BOARD_HEIGHT - BOARD_HEIGHT/4, BOARD_WIDTH/2,
}
};

INT16 score;

typedef struct snake_t {
	struct {
		UINT8 link : 4;
		UINT8 cell : 4;
	} board[BOARD_HEIGHT][BOARD_WIDTH];
	UINT8  head_row, head_col;
	UINT8  tail_row, tail_col;
	UINT8  first_row, first_col;
	UINT8  last_row, last_col;
	UINT8  direction;
	UINT8  state;
	UINT8  key_up;
	UINT8  key_left;
	UINT8  key_down;
	UINT8  key_right;
	UINT8  level;
	UINT16 fruits;
	BOOL   fruit_eaten;
} snake_t;


void send_sprite_data(void) {
	vdp_bitmapSendData(TILE_WALL, BITMAP_WIDTH, BITMAP_HEIGHT, wall_data);
	vdp_bitmapSendData(TILE_APPLE, BITMAP_WIDTH, BITMAP_HEIGHT, apple_data);
	vdp_bitmapSendData(TILE_SNAKE, BITMAP_WIDTH, BITMAP_HEIGHT, snake_data);
	vdp_bitmapCreateSolidColor(TILE_FLOOR, BITMAP_WIDTH, BITMAP_HEIGHT, 0xff000000);
}

void display_score(struct snake_t* snake) {
	vdp_fgcolour(BRIGHT_YELLOW);
	vdp_cursorGoto(2, 2);
	printf("SCORE: %05d    APPLES LEFT: %d    LEVEL: %d/%d  ", (int)score, opt_apples_per_level - (int)snake->fruits, (int)snake->level, MAX_LEVEL);
}

UINT16 count_empty_cells(struct snake_t* snake) {
	UINT16 count;
	UINT8 row, col;
	
	count = 0;
	for (row = snake->first_row; row <= snake->last_row; row++) {
		for (col = snake->first_col; col <= snake->last_col; col++) {
			if (snake->board[row][col].cell == CELL_EMPTY) {
				count++;
			}
		}
	}
	
	return count;
}

BOOL random_empty_cell(struct snake_t* snake, UINT8* rrow, UINT8* rcol) {
	UINT8 row, col;
	UINT16 empty_cells, pos;
	
	empty_cells = count_empty_cells(snake);
	pos = rand() % empty_cells;

	for (row = snake->first_row; row <= snake->last_row; row++) {
		for (col = snake->first_col; col <= snake->last_col; col++) {
			if (snake->board[row][col].cell == CELL_EMPTY) {
				if (pos-- == 0) {
					*rrow = row;
					*rcol = col;
					return true;
				}
			}
		}
	}
	
	return false;
}

void random_fruit(struct snake_t* snake) {
	UINT8 row, col;

	if (random_empty_cell(snake, &row, &col)) {
		snake->board[row][col].cell = CELL_FRUIT;
		vdp_bitmapDraw(TILE_APPLE, col * BITMAP_WIDTH, row * BITMAP_HEIGHT);
	} else {
		snake->state = STATE_CANCELLED;
	}
	snake->fruit_eaten = false;
}

void handle_key(struct snake_t* snake, UINT8 key) {
	int old_direction;
	
	if (key == 27) { // Escape
		snake->state = STATE_CANCELLED;
	}
	if (snake->state != STATE_OK) {
		return;
	}

	old_direction = (int)snake->direction;

	if (key == snake->key_left && snake->direction != RIGHT) {
		snake->direction = LEFT;
	}
	else if (key == snake->key_right && snake->direction != LEFT) {
		snake->direction = RIGHT;
	}
	else if (key == snake->key_up && snake->direction != DOWN) {
		snake->direction = UP;
	}
	else if (key == snake->key_down && snake->direction != UP) {
		snake->direction = DOWN;
	}
}

void move(struct snake_t* snake) {
	BOOL fruit_eaten;
	UINT8 link, cell;
	
	if (snake->state != STATE_OK) {
		return ;
	}

	fruit_eaten = false;
	
	// Move the snake's head

	if (snake->direction == LEFT && snake->head_col > snake->first_col) {
		vdp_bitmapDraw(TILE_SNAKE, snake->head_col * BITMAP_WIDTH, snake->head_row * BITMAP_HEIGHT);
		snake->board[snake->head_row][snake->head_col].link = LEFT;
		snake->head_col--;
		vdp_bitmapDraw(TILE_SNAKE, snake->head_col * BITMAP_WIDTH, snake->head_row * BITMAP_HEIGHT);
	}
	else if (snake->direction == RIGHT && snake->head_col < snake->last_col) {
		vdp_bitmapDraw(TILE_SNAKE, snake->head_col * BITMAP_WIDTH, snake->head_row * BITMAP_HEIGHT);
		snake->board[snake->head_row][snake->head_col].link = RIGHT;
		snake->head_col++;
		vdp_bitmapDraw(TILE_SNAKE, snake->head_col * BITMAP_WIDTH, snake->head_row * BITMAP_HEIGHT);
	}
	else if (snake->direction == UP && snake->head_row > snake->first_row) {
		vdp_bitmapDraw(TILE_SNAKE, snake->head_col * BITMAP_WIDTH, snake->head_row * BITMAP_HEIGHT);
		snake->board[snake->head_row][snake->head_col].link = UP;
		snake->head_row--;
		vdp_bitmapDraw(TILE_SNAKE, snake->head_col * BITMAP_WIDTH, snake->head_row * BITMAP_HEIGHT);
	}
	else if (snake->direction == DOWN && snake->head_row < snake->last_row) {
		vdp_bitmapDraw(TILE_SNAKE, snake->head_col * BITMAP_WIDTH, snake->head_row * BITMAP_HEIGHT);
		snake->board[snake->head_row][snake->head_col].link = DOWN;
		snake->head_row++;
		vdp_bitmapDraw(TILE_SNAKE, snake->head_col * BITMAP_WIDTH, snake->head_row * BITMAP_HEIGHT);
	}
	else {
		return;
	}

	// Check if the head bumped into an apple / wall / snake's body

	fruit_eaten = false;
	cell = snake->board[snake->head_row][snake->head_col].cell;
	if (cell == CELL_WALL || cell == CELL_SNAKE) {
		snake->state = STATE_COLLISION;
	}
	else if (cell == CELL_FRUIT) {
		snake->fruits++;
		fruit_eaten = true;
		vdp_bitmapDraw(TILE_FLOOR, snake->head_col * BITMAP_WIDTH, snake->head_row * BITMAP_HEIGHT);
		vdp_audio(0, 200, 1000, 10);
	}
	snake->board[snake->head_row][snake->head_col].cell = CELL_SNAKE;

	// Move the snake's tail, if needed

	if (fruit_eaten) {
		snake->fruit_eaten = true;
	}
	else {
		link = snake->board[snake->tail_row][snake->tail_col].link;

		snake->board[snake->tail_row][snake->tail_col].cell = CELL_EMPTY;
		snake->board[snake->tail_row][snake->tail_col].link = NONE;
		vdp_bitmapDraw(TILE_FLOOR, snake->tail_col * BITMAP_WIDTH, snake->tail_row * BITMAP_HEIGHT);

		if (link == LEFT) {
			snake->tail_col--;
			vdp_bitmapDraw(TILE_SNAKE, snake->tail_col * BITMAP_WIDTH, snake->tail_row * BITMAP_HEIGHT);
		}
		else if (link == RIGHT) {
			snake->tail_col++;
			vdp_bitmapDraw(TILE_SNAKE, snake->tail_col * BITMAP_WIDTH, snake->tail_row * BITMAP_HEIGHT);
		}
		else if (link == UP) {
			snake->tail_row--;
			vdp_bitmapDraw(TILE_SNAKE, snake->tail_col * BITMAP_WIDTH, snake->tail_row * BITMAP_HEIGHT);
		}
		else if (link == DOWN) {
			snake->tail_row++;
			vdp_bitmapDraw(TILE_SNAKE, snake->tail_col * BITMAP_WIDTH, snake->tail_row * BITMAP_HEIGHT);
		}
		else {
			snake->tail_row = snake->head_row;
			snake->tail_col = snake->head_col;
		}
	}
	
	if (fruit_eaten) {
		score += 10;
		display_score(snake);
	}

	vdp_spriteWaitRefresh();
}

void init_snake(struct snake_t* snake, UINT8 level, uint8_t first_row, uint8_t last_row, uint8_t first_col, uint8_t last_col, int8_t key_up, int8_t key_left, int8_t key_down, int8_t key_right) {
	UINT8 row, col, row1, col1, nlines, line, k;
	UINT8* p;

	memset(snake, 0, sizeof(struct snake_t));
	
	snake->first_row = first_row;
	snake->last_row = last_row;
	snake->first_col = first_col;
	snake->last_col = last_col;
	snake->direction = NONE;
	snake->key_up = key_up;
	snake->key_left = key_left;
	snake->key_down = key_down;
	snake->key_right = key_right;
	snake->state = STATE_OK;
	snake->fruits = 0;
	snake->fruit_eaten = false;
	snake->level = level;

	for (row = 0; row < BOARD_HEIGHT; row++) {
		for (col = 0; col < BOARD_WIDTH; col++) {
			snake->board[row][col].cell = CELL_EMPTY;
			snake->board[row][col].link = NONE;
		}
	}

	p = levels[level - 1];
	nlines = *p++;
	for (line = 0; line < nlines; line++) {
		row = *p++;
		col = *p++;
		row1 = *p++;
		col1 = *p++;
		if (row == row1) {
			for (k = col; k <= col1; k++) {
				snake->board[row][k].cell = CELL_WALL;
			}
		} else if (col == col1) {
			for (k = row; k <= row1; k++) {
				snake->board[k][col].cell = CELL_WALL;
			}
		}
	}

	random_empty_cell(snake, &row, &col);
	snake->head_row = row;
	snake->head_col = col;
	snake->tail_row = row;
	snake->tail_col = col;

	snake->board[snake->head_row][snake->head_col].cell = CELL_SNAKE;
	snake->board[snake->head_row][snake->head_col].link = NONE;

	random_fruit(snake);	
}

void snake_display(struct snake_t* snake) {
	UINT8 row, col;		
	UINT16 ystart, xstart, x, y;
	UINT8 c;
	
	xstart = snake->first_col * BITMAP_WIDTH;
	ystart = snake->first_row * BITMAP_HEIGHT;
	
	y = ystart;
	for (row = snake->first_row; row <= snake->last_row; row++) {
		x = xstart;

		for (col = snake->first_col; col <= snake->last_col; col++) {
			c = snake->board[row][col].cell;
			switch(c) {
				case CELL_WALL:
					vdp_bitmapDraw(TILE_WALL, x, y);
					break;
				case CELL_FRUIT:
					vdp_bitmapDraw(TILE_APPLE, x, y);
					break;
				case CELL_SNAKE:
					vdp_bitmapDraw(TILE_SNAKE, x, y);					
					break;
				case CELL_EMPTY:
					vdp_bitmapDraw(TILE_FLOOR, x, y);			
					break;
				default:
					break;
			}
			x += BITMAP_WIDTH;
		}
		y += BITMAP_HEIGHT;
	}
}

char get_response(struct snake_t* snake, char *message, char option1, char option2) {
	UINT8 n;
	UINT8 len = strlen(message);
	UINT8 start = (80 - len) / 2;
	char ret = 0;
	
	for (n = start - 1; n < start + len + 1; n++) {
		vdp_cursorGoto(n, 27);
		putch(' ');
		vdp_cursorGoto(n, 29);
		putch(' ');
	}
	vdp_cursorGoto(start - 1, 28);
	putch(' ');
	printf("%s ", message);

	while((ret != option1) && (ret != option2)) {
		ret = getch();
	}
	
	snake_display(snake);

	return ret;
}

UINT8 snake_loop()
{
	struct snake_t* snake;
	UINT8 len;
	UINT8* p;
	unsigned seed;
	UINT8 level;
	UINT16 fullkey;
    char rtcbuf[32];
	char c;

	snake = (void *)0x60000;

	len = mos_getrtc(rtcbuf);
	seed = 3141592;
	p = (UINT8*)rtcbuf;
	while (len-- > 0) {
		seed ^= *p << len;
		p++;
	}
	srand(seed);
	
	level = opt_start_level;
	score = 0;
	while (true) {
		init_snake(snake, level, 2, BOARD_HEIGHT - 1, 0, BOARD_WIDTH - 1, 11, 8, 10, 21);
		snake_display(snake);
		display_score(snake);

		while (true) {
			if (snake->fruit_eaten) {
				random_fruit(snake);
			}

			delayms(opt_delay);
			fullkey = getfullkeycode();

			if (fullkey > 0xFF) {
				handle_key(snake, fullkey & 0xFF);
				if (snake->state == STATE_CANCELLED) {
					c = get_response(snake, "Press 'q' to quit the game or 'c' to continue playing.", 'q', 'c');
					if (c == 'q') {
						return 1;
					} else {
						snake->state = STATE_OK;
					}
				}
			}
			
			move(snake);
			
			if (snake->state == STATE_COLLISION) {
				vdp_audio(0, 200, 100, 1000);
				if (level >= MAX_LEVEL) {
					c = get_response(snake, "Collision! Press 'r' to replay the level or 'q' to quit the game.", 'r', 'q');
					if (c == 'q') {
						return 0;
					}
					score -= 50;
					if (score < 0) {
						score = 0;
					}
				} else {
					c = get_response(snake, "Collision! Press 'r' to replay the level or 'n' to skip to next level.", 'r', 'n');
					if (c == 'n') {
						level++;
						score -= 100;
					} else {
						score -= 50;
					}
					if (score < 0) {
						score = 0;
					}
				}
				break;
			} else if (snake->state == STATE_OK) {
				if (snake->fruits == opt_apples_per_level) {
					if (level >= MAX_LEVEL) {
						c = get_response(snake, "All levels completed. Press 'q' to quit the game or 'r' to replay the level.", 'q', 'r');
						if (c == 'q') {
							return 0;
						}
					} else {
						c = get_response(snake, "Level completed. Press 'n' to go to next level or 'r' to replay the level.", 'r' , 'n');
						if (c == 'n') {
							level++;
						}
					}
					break;
				}
			}
		}
	}

	return 0;
}

void parse_cmdline(int argc, char *argv[]) {
	UINT8 k;

	// Sane default delay value for AgonLight2
	opt_delay = 100;
	opt_apples_per_level = 20;
	opt_start_level = 1;
	
	if (argc <= 1 || (argc % 2) == 0) {
		return;
	}
	
	k = 1;
	while (k < argc) {
		if (strcmp(argv[k], "-delay") == 0) {
			opt_delay = atoi(argv[k + 1]);
		} else if (strcmp(argv[k], "-apl") == 0) {
			opt_apples_per_level = atoi(argv[k + 1]);
		} else if (strcmp(argv[k], "-level") == 0) {
			opt_start_level = atoi(argv[k + 1]);
		}
		k += 2;
	}
}

char* splash[] = {
	".ooo....ooo....ooo...o...o...ooo.",
	"o...o..o...o..o...o..o..o...o...o",
	"o......o...o..o...o..o.o....o....",
	".ooo...o...o..ooooo..oo.....oooo.",
	"....o..o...o..o...o..o.o....o....",
	"o...o..o...o..o...o..o..o...o...o",
	".ooo...o...o..o...o..o...o...ooo.",
};

void game_splash_screen() {
	UINT8 row, col;
	char* p;
	
	vdp_cls();

	vdp_cursorGoto(0, 40);
	vdp_cursorDisable();

	row = 4;
	for (col = 2; col < BOARD_WIDTH - 2; col++) {
		vdp_bitmapDraw(TILE_APPLE, col * BITMAP_WIDTH, row * BITMAP_HEIGHT);
	}

	for (row = 0; row < 7; row++) {
		p = splash[row];
		col = 2;
		while (*p != 0) {
			if (*p == 'o') {
				vdp_bitmapDraw(TILE_SNAKE, (col + 2) * BITMAP_WIDTH, (row + 7) * BITMAP_HEIGHT);
			}
			p++;
			col++;
		}
	}
	
	row += 9;
	for (col = 2; col < BOARD_WIDTH - 2; col++) {
		vdp_bitmapDraw(TILE_APPLE, col * BITMAP_WIDTH, row * BITMAP_HEIGHT);
	}

	vdp_fgcolour(DARK_WHITE);
	puts("    Game code / graphics - (c) 2023 Ilian Iliev\r\n");
	puts("    Template / VDP code  - (c) 2023 Jeroen Venema\r\n");
	puts("\r\n");
	vdp_fgcolour(BRIGHT_RED);
	puts("    Press any key to start the game\r\n");
}

int main(int argc, char *argv[]) {
	parse_cmdline(argc, argv);

	vdp_mode(VDPMODE_640x480_16C);
	delayms(opt_delay);
	vdp_cursorDisable();

	send_sprite_data();		

	game_splash_screen();
	getch();

	vdp_cls();

	snake_loop();

	vdp_mode(VDPMODE_DEFAULT);
	delayms(opt_delay);
	vdp_cursorEnable();

	puts("Thank you for playing Snake\r\n");
	return 0;
}
