//Copyright HeathenUK 2023, others' copyrights (Envenomator, Dean Belfield, etc.) unaffected.

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
//#include <stdint.h>
#include <string.h>
#include <eZ80.h>
#include <defines.h>
#include "./main.h"
#include "./mos-interface.h"
#include "./vdp.h"
#include "./agontimer.h"

extern void write16bit(uint16_t w);
extern void write32bit(uint32_t w);

game_state game;

//#define game.screen_width 640
//#define game.screen_height 480

void delay_secs(UINT16 ticks_end) { //1 sec ticks
	
	UINT32 ticks = 0;
	ticks_end *= 60;
	while(true) {
		
		waitvblank();
		ticks++;
		if(ticks >= ticks_end) break;
		
	}
	
}

int min(int a, int b) {
    if (a > b)
        return b;
    return a;
}

int max(int a, int b) {
    if (a > b)
        return a;
    return b;
}

void clear_screen(uint8_t sprites) {

    vdp_cls();
    vdp_spriteActivateTotal(sprites);

}

void refresh_screen(uint8_t sprites) {

    vdp_spriteActivateTotal(sprites);
    vdp_spriteRefresh();
    vdp_spriteActivateTotal(0);

}

void dump_sprites() {

    vdp_spriteActivateTotal(0);
    vdp_spriteRefresh();

}

bool isKthBitSet(uint8_t data, uint8_t k) {
    return (data & (1U << k)) != 0;
}

bool isKthBitSet_16(uint16_t data, uint8_t k) {
    return (data & (1U << k)) != 0;
}

bool isKthBitSet_24(uint24_t data, uint8_t k) {
    return (data & (1UL << k)) != 0;
}

uint8_t setKthBit(uint8_t data, uint8_t k) {
    return data | (1U << k);
}

uint16_t setKthBit_16(uint16_t data, uint8_t k) {
    return data | (1U << k);
}

uint24_t setKthBit_24(uint24_t data, uint8_t k) {
    return data | (1UL << k);
}

void play_sound(int channel, int vol, int duration, int frequency) {

    putch(23);
    putch(0);
    putch(133);

    putch(channel);
    putch(0);
    putch(vol);

    write16bit(frequency);
    write16bit(duration);

}

void twiddle_buffer(char* buffer, int width, int height) {
    int row, col;
    char* rowPtr;
	char* oppositeRowPtr;
	char* tempRow = (char*)malloc(width * 4);

    //Iterate over each row
    for (row = 0; row < height / 2; row++) {
        rowPtr = buffer + row * width * 4;
        oppositeRowPtr = buffer + (height - row - 1) * width * 4;

        //Swap bytes within each row (BGRA to RGBA)
        for (col = 0; col < width; col++) {
            tempRow[col * 4] = oppositeRowPtr[col * 4 + 2]; // R
            tempRow[col * 4 + 1] = oppositeRowPtr[col * 4 + 1]; // G
            tempRow[col * 4 + 2] = oppositeRowPtr[col * 4]; // B
            tempRow[col * 4 + 3] = oppositeRowPtr[col * 4 + 3]; // A

            oppositeRowPtr[col * 4] = rowPtr[col * 4 + 2]; // R
            oppositeRowPtr[col * 4 + 1] = rowPtr[col * 4 + 1]; // G
            oppositeRowPtr[col * 4 + 2] = rowPtr[col * 4]; // B
            oppositeRowPtr[col * 4 + 3] = rowPtr[col * 4 + 3]; // A

            rowPtr[col * 4] = tempRow[col * 4]; // R
            rowPtr[col * 4 + 1] = tempRow[col * 4 + 1]; // G
            rowPtr[col * 4 + 2] = tempRow[col * 4 + 2]; // B
            rowPtr[col * 4 + 3] = tempRow[col * 4 + 3]; // A
        }
    }
}


bmp_info load_bmp_direct(const char * filename, UINT8 slot) { //Sends whole file

    int32_t width, height, bit_depth, row_padding = 0, y, x, i;
    uint8_t pixel[4], file, r, g, b, index;
    char header[54], color_table[1024];
    uint32_t pixel_value, color_table_size, bytes_per_row;
    uint32_t biSize;
    FIL * fo;
	bmp_info return_info;

    char * src;
    char * image_buffer;
	
	//if (game.vgm_file != NULL) parse_vgm_file(game.vgm_file);
	
	return_info.bmp_width = 0;
	return_info.bmp_height = 0;
	return_info.bmp_bitdepth = 0;	

    file = mos_fopen(filename, fa_read);
    if (!file) {
        printf("Error: could not open %s.\r\n", filename);
        return return_info;
    }
    fo = (FIL * ) mos_getfil(file);

    mos_fread(file, header, 54);

    biSize = * (uint32_t * ) & header[14];
    width = * (INT32 * ) & header[18];
    height = * (INT32 * ) & header[22];
    bit_depth = * (uint16_t * ) & header[28];
    color_table_size = * (uint32_t * ) & header[46];

    image_buffer = (char * ) malloc(width * height * (bit_depth / 8));

    if (color_table_size == 0 && bit_depth == 8) {
        color_table_size = 256;
    }

    if (color_table_size > 0) mos_fread(file, color_table, color_table_size * 4);

    else if (biSize > 40) { //If for any reason there's yet more data in the header

        i = biSize - 40;
        while (i--> 0) {
            mos_fgetc(file);
        }

    }

    if ((bit_depth != 32) && (bit_depth != 24) && (bit_depth != 8)) {
        printf("Error: unsupported bit depth (not 8, 24 or 32-bit).\n");
        mos_fclose(file);
        return return_info;
    }

    row_padding = (4 - (width * (bit_depth / 8)) % 4) % 4;

    vdp_bitmapSelect(slot);
    putch(23); // vdu_sys
    putch(27); // sprite command
    putch(1); // send data to selected bitmap

    write16bit(width);
    write16bit(height);

	if (bit_depth == 8) {
		// Process 8-bit BMP image
		int buffer_index = 0; // Index for image_data_buffer

		for (y = height - 1; y >= 0; y--) {
			for (x = 0; x < width; x++) {
				index = (UINT8)mos_fgetc(file);
				b = color_table[index * 4];
				g = color_table[index * 4 + 1];
				r = color_table[index * 4 + 2];

				// Store pixel data in the buffer
				image_buffer[buffer_index++] = b;
				image_buffer[buffer_index++] = g;
				image_buffer[buffer_index++] = r;
				image_buffer[buffer_index++] = 0xFF; //a
			}

			for (i = 0; i < row_padding; i++) {
				mos_fgetc(file);
			}
		}
		twiddle_buffer(image_buffer, width, height);
		mos_puts(image_buffer, width * height * 4, 0);
	
	} else if (bit_depth == 24) {
        // Process 24-bit BMP image
        uint32_t buffer_index = 0; // Index for image_data_buffer

        for (y = height - 1; y >= 0; y--) {
            for (x = 0; x < width; x++) {
                b = (UINT8)mos_fgetc(file);
                g = (UINT8)mos_fgetc(file);
                r = (UINT8)mos_fgetc(file);

                // Store pixel data in the buffer
                image_buffer[buffer_index++] = b;
                image_buffer[buffer_index++] = g;
                image_buffer[buffer_index++] = r;
                image_buffer[buffer_index++] = 0xFF; // Fixed alpha value
            }

            for (i = 0; i < row_padding; i++) {
                mos_fgetc(file);
            }
        }
        twiddle_buffer(image_buffer, width, height);
		mos_puts(image_buffer, width * height * 4, 0);

    } else if (bit_depth == 32) {
		uint32_t buffer_index = 0; // Index for image_data_buffer
		uint16_t non_pad_row = width * bit_depth / 8;
		bytes_per_row = (width * bit_depth / 8) + row_padding;

		src = (char*)malloc(non_pad_row);

		for (y = height - 1; y >= 0; y--) {
			mos_fread(file, src, non_pad_row);
			memcpy(image_buffer + buffer_index, src, non_pad_row);
			buffer_index += non_pad_row;
			mos_flseek(file, fo->fptr + row_padding);
			
		}
		twiddle_buffer(image_buffer, width, height);
		mos_puts(image_buffer, width * height * 4, 0);
	}

    mos_fclose(file);
    free(image_buffer);
    //return width * height;
	return_info.bmp_width = width;
	return_info.bmp_height = height;
	return_info.bmp_bitdepth = bit_depth;
	return return_info;

}


void load_font_frame() {

    printf("Loading font & frame...\r\n");
    load_bmp_direct("snake_assets/f_blue/nw.bmp", FRAME_NW); //NW
    load_bmp_direct("snake_assets/f_blue/n.bmp", FRAME_N); //N
    load_bmp_direct("snake_assets/f_blue/ne.bmp", FRAME_NE); //NE
    load_bmp_direct("snake_assets/f_blue/e.bmp", FRAME_E); //E
    load_bmp_direct("snake_assets/f_blue/se.bmp", FRAME_SE); //SE
    load_bmp_direct("snake_assets/f_blue/s.bmp", FRAME_S); //S
    load_bmp_direct("snake_assets/f_blue/sw.bmp", FRAME_SW); //SW
    load_bmp_direct("snake_assets/f_blue/w.bmp", FRAME_W); //W
    load_bmp_direct("snake_assets/f_blue/mid.bmp", FRAME_MID); //W

    //load_bmp_direct("snake_assets/font/32.bmp", 132); //Space

    load_bmp_direct("snake_assets/font/33.bmp", 133); //!
    load_bmp_direct("snake_assets/font/36.bmp", 136); //$
    load_bmp_direct("snake_assets/font/38.bmp", 138); //&
    load_bmp_direct("snake_assets/font/39.bmp", 139); //'
    load_bmp_direct("snake_assets/font/44.bmp", 144); //,
    load_bmp_direct("snake_assets/font/46.bmp", 146); //.

    load_bmp_direct("snake_assets/font/48.bmp", 148); //0
    load_bmp_direct("snake_assets/font/49.bmp", 149); //1
    load_bmp_direct("snake_assets/font/50.bmp", 150); //2
    load_bmp_direct("snake_assets/font/51.bmp", 151); //3
    load_bmp_direct("snake_assets/font/52.bmp", 152); //4
    load_bmp_direct("snake_assets/font/53.bmp", 153); //5
    load_bmp_direct("snake_assets/font/54.bmp", 154); //6
    load_bmp_direct("snake_assets/font/55.bmp", 155); //7
    load_bmp_direct("snake_assets/font/56.bmp", 156); //8
    load_bmp_direct("snake_assets/font/57.bmp", 157); //9

    load_bmp_direct("snake_assets/font/62.bmp", 162); //>
	load_bmp_direct("snake_assets/font/63.bmp", 163); //?

    load_bmp_direct("snake_assets/font/65.bmp", 165); //A
    load_bmp_direct("snake_assets/font/66.bmp", 166); //B
    load_bmp_direct("snake_assets/font/67.bmp", 167); //C
    load_bmp_direct("snake_assets/font/68.bmp", 168); //D
    load_bmp_direct("snake_assets/font/69.bmp", 169); //E
    load_bmp_direct("snake_assets/font/70.bmp", 170); //F
    load_bmp_direct("snake_assets/font/71.bmp", 171); //G
    load_bmp_direct("snake_assets/font/72.bmp", 172); //H
    load_bmp_direct("snake_assets/font/73.bmp", 173); //I
    load_bmp_direct("snake_assets/font/74.bmp", 174); //J
    load_bmp_direct("snake_assets/font/75.bmp", 175); //K
    load_bmp_direct("snake_assets/font/76.bmp", 176); //L
    load_bmp_direct("snake_assets/font/77.bmp", 177); //M
    load_bmp_direct("snake_assets/font/78.bmp", 178); //N
    load_bmp_direct("snake_assets/font/79.bmp", 179); //O
    load_bmp_direct("snake_assets/font/80.bmp", 180); //P
    load_bmp_direct("snake_assets/font/81.bmp", 181); //Q
    load_bmp_direct("snake_assets/font/82.bmp", 182); //R
    load_bmp_direct("snake_assets/font/83.bmp", 183); //S
    load_bmp_direct("snake_assets/font/84.bmp", 184); //T
    load_bmp_direct("snake_assets/font/85.bmp", 185); //U
    load_bmp_direct("snake_assets/font/86.bmp", 186); //V
    load_bmp_direct("snake_assets/font/87.bmp", 187); //W
    load_bmp_direct("snake_assets/font/88.bmp", 188); //X
    load_bmp_direct("snake_assets/font/89.bmp", 189); //Y
    load_bmp_direct("snake_assets/font/90.bmp", 190); //Z

}

uint8_t count(const char * text, char test) {
    uint8_t count = 0, k = 0;
    while (text[k] != '\0') {
        if (text[k] == test)
            count++;
        k++;
    }
    return count;
}

uint8_t longest_stretch(char * str) {
    uint8_t len = 0, max_len = 0;
    char * p = str;

    while ( * p != '\0') {
        if ( * p == '\n') {
            if (len > max_len) {
                max_len = len;
            }
            len = 0;
        } else {
            len++;
        }
        p++;
    }

    if (len > max_len) {
        max_len = len;
    }

    return max_len;
}

void raw_text(const char * text, uint16_t x, uint16_t y) {
    uint8_t i, l;
    uint16_t w;
    l = strlen(text);

    if (l > 30) return;

    w = (l * 8);

    vdp_bitmapDraw(FRAME_NW, x, y);
    vdp_bitmapDraw(FRAME_NE, x + w, y);

    for (i = 1; i < (w / 8); i++) {
        vdp_bitmapDraw(FRAME_N, x + (i * 8), y);
        vdp_bitmapDraw(FRAME_S, x + (i * 8), y + 8);
    }

    vdp_bitmapDraw(FRAME_SW, x, y + 8);
    vdp_bitmapDraw(FRAME_SE, x + w, y + 8);

    for (i = 0; i < l; i++) vdp_bitmapDraw(toupper(text[i]) + 100, x + 4 + (8 * i), y + 4);
}

uint16_t raw_text_multi_centre(const char * text, uint16_t y) {
    uint8_t i, l, j, h, col = 0, line = 0;
    uint16_t w, x;
    l = strlen(text);

    if (longest_stretch(text) > 30) return 0;

    h = (count(text, '\n') * 8) + 8;

    w = (longest_stretch(text) * 8);
    x = (game.screen_width - w) / 2;

    vdp_bitmapDraw(FRAME_NW, x, y);
    vdp_bitmapDraw(FRAME_NE, x + w, y);

    for (i = 1; i < (w / 8); i++) {

        vdp_bitmapDraw(FRAME_N, x + (i * 8), y);
        for (j = 1; j < (h / 8); j++) vdp_bitmapDraw(FRAME_MID, x + (i * 8), y + (j * 8));
        vdp_bitmapDraw(FRAME_S, x + (i * 8), y + h);

    }

    for (i = 1; i < (h / 8); i++) {

        vdp_bitmapDraw(FRAME_W, x, y + (i * 8));
        vdp_bitmapDraw(FRAME_E, x + w, y + (i * 8));

    }

    vdp_bitmapDraw(FRAME_SW, x, y + h);
    vdp_bitmapDraw(FRAME_SE, x + w, y + h);

    col = 0;
    for (i = 0; i < l; i++) {

        if (text[i] == '\n') {
            line++;
            col = 0;
        } else {
            vdp_bitmapDraw(toupper(text[i]) + 100, x + 2 + (col * 8), y + (line * 10) + 2);
            col++;
        }

    }

    return x + 4;
}

void raw_text_centre(const char * text, uint16_t y) {
    uint8_t i, l;
    uint16_t w, x;
    l = strlen(text);
    if (l > 30) return;

    w = (l * 8);
    x = (320 - w) / 2;

    vdp_bitmapDraw(FRAME_NW, x, y);
    vdp_bitmapDraw(FRAME_NE, x + w, y);

    for (i = 1; i < (w / 8); i++) {
        vdp_bitmapDraw(FRAME_N, x + (i * 8), y);
        vdp_bitmapDraw(FRAME_S, x + (i * 8), y + 8);
    }

    vdp_bitmapDraw(FRAME_SW, x, y + 8);
    vdp_bitmapDraw(FRAME_SE, x + w, y + 8);

    for (i = 0; i < l; i++) {

        vdp_bitmapDraw(toupper(text[i]) + 100, x + 4 + (8 * i), y + 4);

    }
}

uint24_t alt_atoi(const char * str) {
    uint24_t result = 0;

    while (isdigit( * str)) {
        result = result * 10 + ( * str - '0');
        str++;
    }

    return result;
}


size_t safe_strcpy(char* dest, const char* src, size_t size) {
    size_t src_len = strlen(src);
    size_t copy_len = (src_len < size) ? src_len : (size - 1);
    
    memcpy(dest, src, copy_len);
    dest[copy_len] = '\0';
    
    return src_len;
}

void setup_text_sprites() {

    vdp_spriteClearFrames(SPRITE_SCORE0);
    vdp_spriteAddFrameSelected(100 + '0'); //0
    vdp_spriteAddFrameSelected(149); //1
    vdp_spriteAddFrameSelected(150); //2
    vdp_spriteAddFrameSelected(151); //3
    vdp_spriteAddFrameSelected(152); //4
    vdp_spriteAddFrameSelected(153); //5
    vdp_spriteAddFrameSelected(154); //6
    vdp_spriteAddFrameSelected(155); //7
    vdp_spriteAddFrameSelected(156); //8
    vdp_spriteAddFrameSelected(157); //9
    vdp_spriteHideSelected();

    vdp_spriteClearFrames(SPRITE_SCORE1);
    vdp_spriteAddFrameSelected(148); //0
    vdp_spriteAddFrameSelected(149); //1
    vdp_spriteAddFrameSelected(150); //2
    vdp_spriteAddFrameSelected(151); //3
    vdp_spriteAddFrameSelected(152); //4
    vdp_spriteAddFrameSelected(153); //5
    vdp_spriteAddFrameSelected(154); //6
    vdp_spriteAddFrameSelected(155); //7
    vdp_spriteAddFrameSelected(156); //8
    vdp_spriteAddFrameSelected(157); //9
    vdp_spriteHideSelected();
	
    vdp_spriteClearFrames(SPRITE_SCORE2);
    vdp_spriteAddFrameSelected(148); //0
    vdp_spriteAddFrameSelected(149); //1
    vdp_spriteAddFrameSelected(150); //2
    vdp_spriteAddFrameSelected(151); //3
    vdp_spriteAddFrameSelected(152); //4
    vdp_spriteAddFrameSelected(153); //5
    vdp_spriteAddFrameSelected(154); //6
    vdp_spriteAddFrameSelected(155); //7
    vdp_spriteAddFrameSelected(156); //8
    vdp_spriteAddFrameSelected(157); //9
    vdp_spriteHideSelected();	

}

void draw_bottom_frame() {

    uint8_t i;
    vdp_bitmapDraw(FRAME_NW, 0, game.screen_height - 16);
    vdp_bitmapDraw(FRAME_NE, game.screen_width - 8, game.screen_height - 16);
    vdp_bitmapDraw(FRAME_SW, 0, game.screen_height - 8);
    vdp_bitmapDraw(FRAME_SE, game.screen_width - 8, game.screen_height - 8);

    for (i = 1; i < ((game.screen_width - 16) / 8) + 1; i++) {

        vdp_bitmapDraw(FRAME_N, 8 * i, game.screen_height - 16);
        vdp_bitmapDraw(FRAME_S, 8 * i, game.screen_height - 8);

    }

}

void draw_top_frame() {

    uint8_t i;
    vdp_bitmapDraw(FRAME_NW, 0, 0);
    vdp_bitmapDraw(FRAME_NE, game.screen_width - 8, 0);
    vdp_bitmapDraw(FRAME_SW, 0, 8);
    vdp_bitmapDraw(FRAME_SE, game.screen_width - 8, 8);

    for (i = 1; i < ((game.screen_width - 16) / 8) + 1; i++) {

        vdp_bitmapDraw(FRAME_N, 8 * i, 0);
        vdp_bitmapDraw(FRAME_S, 8 * i, 8);

    }

}

void show_score() {

    vdp_spriteSetFrame(SPRITE_SCORE0, game.score / 100);		//Hundreds
    vdp_spriteSetFrame(SPRITE_SCORE1, (game.score % 100) / 10);	//Tens
	vdp_spriteSetFrame(SPRITE_SCORE2, game.score % 10);			//Units

}

void change_score() {

    if (game.score + 1 > 100) game.score = 100;
    else game.score++;
    vdp_spriteSetFrame(SPRITE_SCORE0, game.score / 100);		//Hundreds
    vdp_spriteSetFrame(SPRITE_SCORE1, (game.score % 100) / 10);	//Tens
	vdp_spriteSetFrame(SPRITE_SCORE2, game.score % 10);			//Units

}

bool check_collision(Rect rect1, Rect rect2) {
    // Calculate the coordinates of the edges of the rectangles
    int rect1Left = rect1.x;
    int rect1Right = rect1.x + rect1.width;
    int rect1Top = rect1.y;
    int rect1Bottom = rect1.y + rect1.height;
    
    int rect2Left = rect2.x;
    int rect2Right = rect2.x + rect2.width;
    int rect2Top = rect2.y;
    int rect2Bottom = rect2.y + rect2.height;
    
    // Check for collision by comparing the edges
    if (rect1Right <= rect2Left || rect1Left >= rect2Right ||
        rect1Bottom <= rect2Top || rect1Top >= rect2Bottom) {
        return false;  // No collision
    }
    
    return true;  // Collision detected
}

uint24_t xorshift24(uint24_t *state) {
    uint24_t x = *state;
    x ^= x << 13;
    x ^= x >> 17;
    x ^= x << 5;
    *state = x;
    return x;
}

int prand(int min, int max) {
    uint24_t state = timer1;
    uint24_t range = max - min + 1;
    uint24_t randomValue = xorshift24(&state) % range;
    return randomValue + min;
}

void move_snake() {
    uint8_t i = 0, j = 0;

	//Reconstruct the snake in its next position
	
	//Body
	
    for (i = game.snake_length; i > 0; i--) {
        game.snake[i].x = game.snake[i - 1].x;
        game.snake[i].y = game.snake[i - 1].y;
        vdp_spriteMoveTo(SPRITE_START + i, game.snake[i].x, game.snake[i].y);
		
    }
	
	//Head

    if (game.vel_x < 0) {
        if (game.snake[0].x - game.snake[0].width >= 0) {
            game.snake[0].x -= game.snake[0].width;
            vdp_spriteMoveTo(SPRITE_START + 0, game.snake[0].x, game.snake[0].y);
			vdp_spriteSetFrameSelected(SNAKE_HEAD_W);
        } else {
            play_sound(0, 120, 200, 440);
			game.game_over = true;
            return;
        }
    } else if (game.vel_x > 0) {
        if (game.snake[0].x + game.snake[0].width + game.snake[0].width <= game.screen_width) {
            game.snake[0].x += game.snake[0].width;
            vdp_spriteMoveTo(SPRITE_START + 0, game.snake[0].x, game.snake[0].y);
			vdp_spriteSetFrameSelected(SNAKE_HEAD_E);
        } else {
            play_sound(0, 120, 200, 440);
			game.game_over = true;
            return;
        }
    } else if (game.vel_y < 0) {
        if (game.snake[0].y - game.snake[0].height >= 0) {
            game.snake[0].y -= game.snake[0].height;
            vdp_spriteMoveTo(SPRITE_START + 0, game.snake[0].x, game.snake[0].y);
			vdp_spriteSetFrameSelected(SNAKE_HEAD_N);
        } else {
            play_sound(0, 120, 200, 440);
			game.game_over = true;
            return;
        }
    } else if (game.vel_y > 0) {
        if (game.snake[0].y + game.snake[0].height + game.snake[0].height <= game.screen_height) {
            game.snake[0].y += game.snake[0].height;
            vdp_spriteMoveTo(SPRITE_START + 0, game.snake[0].x, game.snake[0].y);
			vdp_spriteSetFrameSelected(SNAKE_HEAD_S);
        } else {
            play_sound(0, 120, 200, 440);
			game.game_over = true;
            return;
        }
    }
	
	//Iterate over the body to determine orientation, excluding the head and the end
	
	for (i = 1; i < game.snake_length; i++) {
		Rect currentRect = game.snake[i];
		Rect nextRect = game.snake[i - 1];
		Rect prevRect = game.snake[i + 1];

		if (currentRect.y == prevRect.y && currentRect.y == nextRect.y) {
			vdp_spriteSetFrame(SPRITE_START + i, 0); // Horizontal segment
			game.snake[i].width = game.seg_hor_width;
			game.snake[i].height = game.seg_hor_height;
			continue;
			
		} else if (currentRect.x == prevRect.x && currentRect.x == nextRect.x) {
			vdp_spriteSetFrame(SPRITE_START + i, 1); // Vertical segment
			game.snake[i].width = game.seg_ver_width;
			game.snake[i].height = game.seg_ver_height;
			continue;
		}
		
		else if (nextRect.x > currentRect.x && nextRect.y == currentRect.y && prevRect.y > currentRect.y && prevRect.x == currentRect.x) {
			vdp_spriteSetFrame(SPRITE_START + i, 5); // Northwest corner
			game.snake[i].width = game.seg_cor_width;
			game.snake[i].width = game.seg_cor_height;
			continue;
		}
		else if (nextRect.x == currentRect.x && nextRect.y > currentRect.y && prevRect.y == currentRect.y && prevRect.x > currentRect.x) {
			vdp_spriteSetFrame(SPRITE_START + i, 5); // Northwest corner
			game.snake[i].width = game.seg_cor_width;
			game.snake[i].width = game.seg_cor_height;			
			continue;
		}
		
		else if (nextRect.x == currentRect.x && nextRect.y > currentRect.y && prevRect.x < currentRect.x && prevRect.y == currentRect.y) {
			vdp_spriteSetFrame(SPRITE_START + i, 2); // Northeast corner
			game.snake[i].width = game.seg_cor_width;
			game.snake[i].width = game.seg_cor_height;			
			continue;
		}
		else if (nextRect.x < currentRect.x && nextRect.y == currentRect.y && prevRect.x == currentRect.x && prevRect.y > currentRect.y) {
			vdp_spriteSetFrame(SPRITE_START + i, 2); // Northeast corner
			game.snake[i].width = game.seg_cor_width;
			game.snake[i].width = game.seg_cor_height;			
			continue;
		}

		else if (nextRect.x < currentRect.x && nextRect.y == currentRect.y && prevRect.x == currentRect.x && prevRect.y < currentRect.y) {
			vdp_spriteSetFrame(SPRITE_START + i, 3); // Southeast corner
			game.snake[i].width = game.seg_cor_width;
			game.snake[i].width = game.seg_cor_height;			
			continue;
		}
		else if (nextRect.x == currentRect.x && nextRect.y < currentRect.y && prevRect.x < currentRect.x && prevRect.y == currentRect.y) {
			vdp_spriteSetFrame(SPRITE_START + i, 3); // Southeast corner
			game.snake[i].width = game.seg_cor_width;
			game.snake[i].width = game.seg_cor_height;			
			continue;
		}				
		
		else if (nextRect.x == currentRect.x && nextRect.y < currentRect.y && prevRect.x > currentRect.x && prevRect.y == currentRect.y) {
			vdp_spriteSetFrame(SPRITE_START + i, 4); // Southwest corner
			game.snake[i].width = game.seg_cor_width;
			game.snake[i].width = game.seg_cor_height;			
			continue;
		}
		else if (nextRect.x > currentRect.x && nextRect.y == currentRect.y && prevRect.x == currentRect.x && prevRect.y < currentRect.y) {
			vdp_spriteSetFrame(SPRITE_START + i, 4); // Southwest corner
			game.snake[i].width = game.seg_cor_width;
			game.snake[i].width = game.seg_cor_height;			
			continue;
		}				

	}
	
	//Tail
	
	if (game.snake[game.snake_length].x < game.snake[game.snake_length - 1].x && game.snake[game.snake_length].y == game.snake[game.snake_length - 1].y)
		vdp_spriteSetFrame(SPRITE_START + game.snake_length, 9); // Pointing west (going east)
	else if (game.snake[game.snake_length].x > game.snake[game.snake_length - 1].x && game.snake[game.snake_length].y == game.snake[game.snake_length - 1].y)
		vdp_spriteSetFrame(SPRITE_START + game.snake_length, 7); // Pointing east (going west)
	else if (game.snake[game.snake_length].x == game.snake[game.snake_length - 1].x && game.snake[game.snake_length].y < game.snake[game.snake_length - 1].y)
		vdp_spriteSetFrame(SPRITE_START + game.snake_length, 6); // Pointing north (going south)
	else if (game.snake[game.snake_length].x == game.snake[game.snake_length - 1].x && game.snake[game.snake_length].y > game.snake[game.snake_length - 1].y)
		vdp_spriteSetFrame(SPRITE_START + game.snake_length, 8); // Pointing south (going north)
	vdp_spriteShow(SPRITE_START + game.snake_length);

	//Check for collisions with yourself before rendering anything
	
	for (j = 1; j < game.snake_length; j++) {
		if (check_collision(game.snake[0], game.snake[j]) == TRUE) {
			play_sound(0, 120, 200, 440);
			game.game_over = true;
			break;
		}
	}
	
	//Food eaten?
	
	if (check_collision(game.snake[0], game.current_food)) {
	
		grow_snake();
		game.current_food.x = prand(32, game.screen_width - 32);
		game.current_food.y = prand(32, game.screen_height - 32);
		vdp_spriteMoveTo(SPRITE_FOOD, game.current_food.x, game.current_food.y);
		if (game.tick > 100) game.tick--;
		
	}
	
	//Refresh the snake and other sprites
	
	vdp_spriteActivateTotal(SPRITE_START + game.snake_length + 1);
	vdp_spriteRefresh();
	vdp_spriteActivateTotal(0);


}

void grow_snake() {
	
	
	if (game.snake_length == 100) { game.game_over = true; return; }
	else game.snake_length++;
	
	change_score();
	play_sound(0, 120, 200, 880);
	
	game.snake[game.snake_length].x = game.screen_width;
	game.snake[game.snake_length].y = game.screen_height;
	vdp_spriteClearFrames(SPRITE_START + game.snake_length);
	vdp_spriteAddFrame(SPRITE_START + game.snake_length, SNAKE_BODY_HOR);
	vdp_spriteAddFrame(SPRITE_START + game.snake_length, SNAKE_BODY_VER);
	vdp_spriteAddFrame(SPRITE_START + game.snake_length, SNAKE_BODY_NE);
	vdp_spriteAddFrame(SPRITE_START + game.snake_length, SNAKE_BODY_SE);
	vdp_spriteAddFrame(SPRITE_START + game.snake_length, SNAKE_BODY_SW);
	vdp_spriteAddFrame(SPRITE_START + game.snake_length, SNAKE_BODY_NW);
	vdp_spriteAddFrame(SPRITE_START + game.snake_length, SNAKE_TAIL_N);
	vdp_spriteAddFrame(SPRITE_START + game.snake_length, SNAKE_TAIL_E);
	vdp_spriteAddFrame(SPRITE_START + game.snake_length, SNAKE_TAIL_S);
	vdp_spriteAddFrame(SPRITE_START + game.snake_length, SNAKE_TAIL_W);	
	vdp_spriteMoveTo(SPRITE_START + game.snake_length, game.snake[game.snake_length].x, game.snake[game.snake_length].y);
	vdp_spriteShow(SPRITE_START + game.snake_length);
	game.snake[game.snake_length].height = game.snake[game.snake_length - 1].height;
	game.snake[game.snake_length].width = game.snake[game.snake_length - 1].width;
	//move_snake();
	
}

void setup_snake(uint8_t length, uint16_t start_x, uint16_t start_y,
				const char *head_n, const char *head_e, const char *head_s, const char *head_w,
				const char *body_hor, const char *body_ver,
				const char *body_ne, const char *body_se, const char *body_sw, const char *body_nw,
				const char *tail_n, const char *tail_e, const char *tail_s, const char *tail_w,
				const char *food, const char *tile) {
	
	uint8_t segment;
	bmp_info bmp;
	
	printf("Loading images...");
					
	game.vel_x = 1;
	game.vel_y = 0;
	game.snake_length = length;
	

	//First load head (4 directions)
	bmp = load_bmp_direct(head_n, SNAKE_HEAD_N);
	game.snake[0].height = bmp.bmp_height;
	game.snake[0].width = bmp.bmp_width;
	
	load_bmp_direct(head_e, SNAKE_HEAD_E);
	load_bmp_direct(head_s, SNAKE_HEAD_S);
	load_bmp_direct(head_w, SNAKE_HEAD_W);
	
	//Then load body (horizontal, vertical and corners)
	bmp = load_bmp_direct(body_hor, SNAKE_BODY_HOR);
	game.seg_hor_width = bmp.bmp_width;
	game.seg_hor_height = bmp.bmp_height;
	
	bmp = load_bmp_direct(body_ver, SNAKE_BODY_VER);
	game.seg_ver_width = bmp.bmp_width;
	game.seg_ver_height = bmp.bmp_height;
	
	bmp = load_bmp_direct(body_ne, SNAKE_BODY_NE);
	game.seg_cor_width = bmp.bmp_width;
	game.seg_cor_height = bmp.bmp_height;
	
	load_bmp_direct(body_se, SNAKE_BODY_SE);
	load_bmp_direct(body_sw, SNAKE_BODY_SW);
	load_bmp_direct(body_nw, SNAKE_BODY_NW);
	
	//And finally the tail in four directions
	load_bmp_direct(tail_n, SNAKE_TAIL_N);
	load_bmp_direct(tail_e, SNAKE_TAIL_E);
	load_bmp_direct(tail_s, SNAKE_TAIL_S);
	load_bmp_direct(tail_w, SNAKE_TAIL_W);
	
	game.snake[0].x = start_x;
	game.snake[0].y = start_y;
	vdp_spriteClearFrames(SPRITE_START + 0);
	vdp_spriteAddFrame(SPRITE_START + 0, SNAKE_HEAD_N);
	vdp_spriteAddFrame(SPRITE_START + 0, SNAKE_HEAD_E);
	vdp_spriteAddFrame(SPRITE_START + 0, SNAKE_HEAD_S);
	vdp_spriteAddFrame(SPRITE_START + 0, SNAKE_HEAD_W);
	vdp_spriteMoveTo(SPRITE_START + 0, game.snake[0].x, game.snake[0].y);
	vdp_spriteShow(SPRITE_START + 0);

	
	for (segment = 1; segment <= length; segment++) {
		game.snake[segment].height = game.seg_hor_height;
		game.snake[segment].width = game.seg_hor_width;		
		game.snake[segment].x = start_x + (-1 * game.vel_x * segment * game.seg_hor_width);
		game.snake[segment].y = start_y;
		
		vdp_spriteClearFrames(SPRITE_START + segment);
		
		vdp_spriteAddFrame(SPRITE_START + segment, SNAKE_BODY_HOR); //0
		vdp_spriteAddFrame(SPRITE_START + segment, SNAKE_BODY_VER);	//1
		vdp_spriteAddFrame(SPRITE_START + segment, SNAKE_BODY_NE);	//2
		vdp_spriteAddFrame(SPRITE_START + segment, SNAKE_BODY_SE);	//3
		vdp_spriteAddFrame(SPRITE_START + segment, SNAKE_BODY_SW);	//4
		vdp_spriteAddFrame(SPRITE_START + segment, SNAKE_BODY_NW);	//5
		vdp_spriteAddFrame(SPRITE_START + segment, SNAKE_TAIL_N);	//6
		vdp_spriteAddFrame(SPRITE_START + segment, SNAKE_TAIL_E);	//7
		vdp_spriteAddFrame(SPRITE_START + segment, SNAKE_TAIL_S);	//8
		vdp_spriteAddFrame(SPRITE_START + segment, SNAKE_TAIL_W);	//9
		
		vdp_spriteSetFrame(SPRITE_START + segment, SNAKE_BODY_HOR);
		
		vdp_spriteMoveTo(SPRITE_START + segment, game.snake[segment].x, game.snake[segment].y);
		vdp_spriteShow(SPRITE_START + segment);

	}
	
	bmp = load_bmp_direct(food, SNAKE_FOOD);
	game.current_food.width = bmp.bmp_width;
	game.current_food.height = bmp.bmp_height;
	game.current_food.x = prand(32, game.screen_width - 32);
	game.current_food.y = prand(32, game.screen_height - 32);	
	vdp_spriteAddFrame(SPRITE_FOOD, SNAKE_FOOD);
	vdp_spriteMoveTo(SPRITE_FOOD, game.current_food.x, game.current_food.y);
	vdp_spriteShowSelected();
	//vdp_bitmapDraw(SNAKE_FOOD, game.current_food.x, game.current_food.y);	
	
	bmp = load_bmp_direct(tile, BACKGROUND_TILE);
	game.bg_tile_width = bmp.bmp_width;
	game.bg_tile_height = bmp.bmp_height;
	
}

void draw_background() {

	uint8_t x, y;
	
	//vdp_bitmapSelect(BACKGROUND_TILE);
	
	for (x = 0; x < (game.screen_width / game.bg_tile_width) + 1; x++) {
		
		for (y = 0; y < (game.screen_height / game.bg_tile_height) + 1; y ++) {
		
			vdp_bitmapDraw(BACKGROUND_TILE, x * game.bg_tile_width, y * game.bg_tile_height);
			
		}
		
	}
	
}

int main(int argc, char * argv[]) {

    int i = 0, j = 0;
    UINT24 t = 0;
    uint8_t key = 0, pressed = 0, keycount;
    FIL * fo;
	uint8_t exit_num = 0;
	uint24_t millis_old;
	uint24_t millis_delta = 0;
	uint24_t next_frame = 0;
	uint24_t next_move = 0;
	char text[128];
	bmp_info bmp;
	
	timer1_begin(4608, 4); //1ms timer;
	
    vdp_clearGraphics();
	vdp_cls();
	
	vdp_mode(2);
	game.screen_width = 320;
	game.screen_height = 200;
	
	vdp_cursorDisable();
	load_font_frame();
    setup_text_sprites();
	
	setup_snake(3, 10, 10, "snake_assets/head_up.bmp","snake_assets/head_right.bmp","snake_assets/head_down.bmp","snake_assets/head_left.bmp",
	"snake_assets/body_horizontal.bmp","snake_assets/body_vertical.bmp",
	"snake_assets/body_bottomleft.bmp","snake_assets/body_topleft.bmp","snake_assets/body_topright.bmp","snake_assets/body_bottomright.bmp",
	"snake_assets/tail_up.bmp","snake_assets/tail_right.bmp","snake_assets/tail_down.bmp","snake_assets/tail_left.bmp",
	"snake_assets/apple.bmp", "snake_assets/tile.bmp");	
	
	vdp_cls();
	
	//draw_bottom_frame();
	draw_background();
	//draw_top_frame();
    vdp_spriteMoveTo(SPRITE_SCORE0, 16, game.screen_height - 11);
    vdp_spriteShowSelected();
    vdp_spriteMoveTo(SPRITE_SCORE1, 24, game.screen_height - 11);
    vdp_spriteShowSelected();
	vdp_spriteMoveTo(SPRITE_SCORE2, 32, game.screen_height - 11);
    vdp_spriteShowSelected();
    vdp_spriteSetFrame(SPRITE_SCORE0, game.score / 100);		//Hundreds
    vdp_spriteSetFrame(SPRITE_SCORE1, (game.score % 100) / 10);	//Tens
	vdp_spriteSetFrame(SPRITE_SCORE2, game.score % 10);			//Units

    keycount = getsysvar_vkeycount(); //Get initial keycount to compare against
	millis_old = timer1;
	
	
	game.game_over = false;
	game.score = 0;
	game.tick = 200;
    
	while (true) {
		
		//printf("%u\r",timer1);
		
		if (game.game_over == true) break;
		
		if (timer1 > next_move) {
			move_snake();
			next_move = timer1 + game.tick;
		}
		
		
		if (getsysvar_vkeycount() != keycount) { //New key pressed

			key = getsysvar_keyascii();
			//pressed = getsysvar_vkeydown();
			//printf("Key %u\r\n", key);
			
			if (key == 'w' || key == 11) { 
				if (game.vel_y != 1) { //game.game_over = true;
					game.vel_y = -1;
					game.vel_x = 0;
					move_snake();
					next_move = timer1 + game.tick;
				}
			}
			else if	(key == 's' || key == 10) {
				if (game.vel_y != -1) { //game.game_over = true;
					game.vel_y = 1;
					game.vel_x = 0;
					move_snake();
					next_move = timer1 + game.tick;				
				}
			}
			else if	(key == 'a' || key == 8) {
				if (game.vel_x != 1) { //game.game_over = true;
					game.vel_x = -1;
					game.vel_y = 0;
					move_snake();
					next_move = timer1 + game.tick;				
				}
			}
			else if	(key == 'd' || key == 21) {
				if (game.vel_x != -1) {//game.game_over = true;
					game.vel_x = 1;
					game.vel_y = 0;
					move_snake();
					next_move = timer1 + game.tick;				
				}
			}
			
			keycount = getsysvar_vkeycount();
			
		}
		
	}
	
	vdp_cls();
	if (game.score != 100) sprintf(text,"Game over!\nYou scored %u points.", game.score);
	else if (game.score == 100) sprintf(text,"Congratulations, you won!");
	raw_text_multi_centre(text, 100);

    return 0;
}