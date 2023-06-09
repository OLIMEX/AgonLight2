 // This header file was generated on
// z5214348.web.cse.unsw.edu.au/header_generator/

// header guard: https://en.wikipedia.org/wiki/Include_guard
// This avoids errors if this file is included multiple times
// in a complex source file setup

#ifndef MAIN_H
#define MAIN_H

// #includes

#include "./agontimer.h"
#include "./mos-interface.h"
#include "./vdp.h"
#include <ctype.h>
#include <defines.h>
#include <eZ80.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// #defines

#define MAX_FILENAME_LENGTH 64

#define STATE_START_MENU 0
#define STATE_GAME_MENU 1
#define STATE_ROOM 2
#define STATE_LOADING 3

//Sprite slot numbers

#define SPRITE_MENU 3
#define SPRITE_SCORE0 0
#define SPRITE_SCORE1 1
#define SPRITE_SCORE2 2
#define SPRITE_FOOD 4

#define SPRITE_START 20

//Bitmap slot numbers

#define SNAKE_HEAD_N 0
#define SNAKE_HEAD_E 1
#define SNAKE_HEAD_S 2
#define SNAKE_HEAD_W 3

#define SNAKE_BODY_HOR 4
#define SNAKE_BODY_VER 5

#define SNAKE_BODY_NE 6
#define SNAKE_BODY_SE 7
#define SNAKE_BODY_SW 8
#define SNAKE_BODY_NW 9

#define SNAKE_TAIL_N 10
#define SNAKE_TAIL_E 11
#define SNAKE_TAIL_S 12
#define SNAKE_TAIL_W 13

#define SNAKE_FOOD 14

#define BACKGROUND_TILE 15

#define FRAME_E 123
#define FRAME_MID 128
#define FRAME_N 121
#define FRAME_NE 122
#define FRAME_NW 120
#define FRAME_S 125
#define FRAME_SE 124
#define FRAME_SW 126
#define FRAME_W 127
#define FRAME_WHOLE 119

//	Structs

typedef struct {
    uint16_t	x;
    uint16_t	y;
    uint16_t	width;
    uint16_t	height;
}
Rect;

// typedef struct {
	// 
	// Rect		rect;
	// bool		alive;
	// 
// }
// Segment;

typedef struct {

	uint16_t screen_width;
	uint16_t screen_height;
	
	Rect current_food;
	uint8_t score;
	uint8_t state;
	uint8_t snake_length;
	Rect snake[150];
	int8_t	vel_x;
	int8_t	vel_y;
	bool	game_over;
	
	uint8_t seg_hor_width;
	uint8_t seg_hor_height;
	uint8_t seg_ver_width;
	uint8_t seg_ver_height;
	uint8_t seg_cor_width;
	uint8_t seg_cor_height;
	
	uint8_t bg_tile_width;
	uint8_t bg_tile_height;
	
	uint8_t tick;


}
game_state;

typedef struct {
	
	uint16_t bmp_width;
	uint16_t bmp_height;
	uint8_t  bmp_bitdepth;
	
} bmp_info;

// Functions

void grow_snake();
void setup_snake(uint8_t length, uint16_t start_x, uint16_t start_y,
				const char *head_n, const char *head_e, const char *head_s, const char *head_w,
				const char *body_hor, const char *body_ver,
				const char *body_ne, const char *body_se, const char *body_sw, const char *body_nw,
				const char *tail_n, const char *tail_e, const char *tail_s, const char *tail_w,
				const char *food, const char *tile);
void move_snake();

// End of header file
#endif
