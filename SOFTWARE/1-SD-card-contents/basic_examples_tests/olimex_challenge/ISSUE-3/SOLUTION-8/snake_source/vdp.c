#include <defines.h>
#include "vdp.h"
#include "mos-interface.h"

// Generic functions

void write16bit(UINT16 w)
{
	putch(w & 0xFF); // write LSB
	putch(w >> 8);	 // write MSB	
}

void write32bit(UINT32 l)
{
	UINT32 temp = l;
	
	putch(temp & 0xFF); // write LSB
	temp = temp >> 8;
	putch(temp & 0xFF);
	temp = temp >> 8;
	putch(temp & 0xFF);
	temp = temp >> 8;
	putch(temp & 0xFF);
	return;	
}

void vdp_mode(unsigned char mode)
{
    putch(22);
    putch(mode);
}

void vdp_getMode(void) {
	putch(23);
	putch(0);
	putch(0x86);
}

void vdp_setPaletteColor(UINT8 index, UINT8 color, UINT8 r, UINT8 g, UINT8 b) {
	putch(0x13); // VDU palette
	putch(index);
	putch(color); // 255 - set R/G/B colors, or <80 color lookup table
	putch(r);
	putch(g);
	putch(b);
}

// Text functions
void vdp_cls()
{
    putch(12);
}

void vdp_cursorHome()
{
    putch(30);
}

void vdp_cursorUp()
{
    putch(11);
}

void vdp_cursorGoto(unsigned char x, unsigned char y)
{
    putch(31); // TAB
    putch(x);
    putch(y);
}

void vdp_fgcolour(unsigned char colorindex) {
	putch(17); // COLOUR
	putch(colorindex);	
}

void vdp_bgcolour(unsigned char colorindex) {
	putch(17); // COLOUR
	putch(colorindex | 0x80);	
}

//
// Graphics functions
//

void vdp_clearGraphics()
{
    putch(16);    
}

void vdp_plotColour(unsigned char colorindex)
{
    putch(18); // GCOL
    putch(1);
	putch(colorindex);
}

// internal function
void vdp_plot(unsigned char mode, unsigned int x, unsigned int y)
{
    putch(25); // PLOT
    putch(mode);
    putch(x & 0xFF);
    putch(x >> 8);
    putch(y & 0xFF);
    putch(y >> 8);
}

void vdp_plotMoveTo(unsigned int x, unsigned int y)
{
	vdp_plot(0x04,x,y);
}

void vdp_plotLineTo(unsigned int x, unsigned int y)
{
	vdp_plot(0x05,x,y);
}

void vdp_plotPoint(unsigned int x, unsigned int y)
{
	vdp_plot(0x40,x,y);
}

void vdp_plotTriangle(unsigned int x, unsigned int y)
{
	vdp_plot(0x50,x,y);
}

void vdp_plotCircleRadius(unsigned int r)
{
	vdp_plot(0x90,r,0);
}

void vdp_plotCircleCircumference(unsigned int x, unsigned int y)
{
	vdp_plot(0x95,x,y);
}

void vdp_plotSetOrigin(unsigned int x, unsigned int y)
{
    putch(29); //Graphics ORIGIN
    putch(x & 0xF);
    putch(x >> 8);
    putch(y & 0xF);
    putch(y >> 8);
}

// Bitmap VDP functions
void vdp_bitmapSelect(UINT8 id)
{
	putch(23); // vdu_sys
	putch(27); // sprite command
	putch(0);  // select command
	putch(id); // bitmap_id
	return;	
}

void vdp_bitmapSendDataSelected(UINT16 width, UINT16 height, UINT32 *data)
{
	UINT16 n;
	
	putch(23); // vdu_sys
	putch(27); // sprite command
	putch(1);  // send data to selected bitmap
	
	write16bit(width);
	write16bit(height);
	
	for(n = 0; n < (width*height); n++)
	{
		write32bit(data[n]);
		//delayms(1);
	}
	return;		
}

void vdp_bitmapSendData(UINT8 id, UINT16 width, UINT16 height, UINT32 *data)
{
	vdp_bitmapSelect(id);
	vdp_bitmapSendDataSelected(width, height, data);
	return;	
}

void vdp_bitmapDrawSelected(UINT16 x, UINT16 y)
{
	putch(23); // vdu_sys
	putch(27); // sprite command
	putch(3);  // draw selected bitmap
	
	write16bit(x);
	write16bit(y);
	
	return;
}

void vdp_bitmapDraw(UINT8 id, UINT16 x, UINT16 y)
{
	vdp_bitmapSelect(id);
	vdp_bitmapDrawSelected(x,y);
	return;	
}

void vdp_bitmapCreateSolidColorSelected(UINT16 width, UINT16 height, UINT32 abgr)
{
	putch(23); // vdu_sys
	putch(27); // sprite command
	putch(2);  // define in single color command
	
	write16bit(width);
	write16bit(height);
	write32bit(abgr);
	return;		
}

void vdp_bitmapCreateSolidColor(UINT8 id, UINT16 width, UINT16 height, UINT32 abgr)
{
	vdp_bitmapSelect(id);
	vdp_bitmapCreateSolidColorSelected(width, height, abgr);
	return;	
}

// Sprite VDP functions
void vdp_spriteSelect(UINT8 id)
{
	putch(23); // vdu_sys
	putch(27); // sprite command
	putch(4);  // select sprite
	putch(id);
	return;			
}

void vdp_spriteClearFramesSelected(void)
{
	putch(23); // vdu_sys
	putch(27); // sprite command
	putch(5);  // clear frames
	return;				
}

void vdp_spriteClearFrames(UINT8 bitmapid)
{
	vdp_spriteSelect(bitmapid);
	vdp_spriteClearFramesSelected();
	return;				
}

void vdp_spriteAddFrameSelected(UINT8 bitmapid)
{
	putch(23); // vdu_sys
	putch(27); // sprite command
	putch(6);  // add frame
	putch(bitmapid);
	return;	
}

void vdp_spriteAddFrame(UINT8 id, UINT8 bitmapid)
{
	vdp_spriteSelect(id);
	vdp_spriteAddFrameSelected(bitmapid);
	return;	
}

void vdp_spriteNextFrameSelected(void)
{
	putch(23); // vdu_sys
	putch(27); // sprite command
	putch(8);  // next frame
	return;			
}

void vdp_spriteNextFrame(UINT8 id)
{
	vdp_spriteSelect(id);
	vdp_spriteNextFrameSelected();
	return;
}

void vdp_spritePreviousFrameSelected(void)
{
	putch(23); // vdu_sys
	putch(27); // sprite command
	putch(9); // previous frame
	return;	
}

void vdp_spritePreviousFrame(UINT8 id)
{
	vdp_spriteSelect(id);
	vdp_spritePreviousFrameSelected();
	return;
}

void vdp_spriteSetFrameSelected(UINT8 framenumber)
{
	putch(23); // vdu_sys
	putch(27); // sprite command
	putch(10); // set current frame
	putch(framenumber);
	return;	
}

void vdp_spriteSetFrame(UINT8 id, UINT8 framenumber)
{
	vdp_spriteSelect(id);
	vdp_spriteSetFrameSelected(framenumber);
	return;
}

void vdp_spriteShowSelected(void)
{
	putch(23); // vdu_sys
	putch(27); // sprite command
	putch(11); // show sprite
	return;			
}

void vdp_spriteShow(UINT8 id)
{
	vdp_spriteSelect(id);
	vdp_spriteShowSelected();
	return;
}

void vdp_spriteHideSelected(void)
{
	putch(23); // vdu_sys
	putch(27); // sprite command
	putch(12); // hide sprite
	return;		
}

void vdp_spriteHide(UINT8 id)
{
	vdp_spriteSelect(id);
	vdp_spriteHideSelected();
	return;
}

void vdp_spriteMoveToSelected(UINT16 x, UINT16 y)
{
	putch(23); // vdu_sys
	putch(27); // sprite command
	putch(13); // move to
	write16bit(x);
	write16bit(y);
	return;	
}

void vdp_spriteMoveTo(UINT8 id, UINT16 x, UINT16 y)
{
	vdp_spriteSelect(id);
	vdp_spriteMoveToSelected(x,y);
	return;
}

void vdp_spriteMoveBySelected(UINT16 x, UINT16 y)
{
	putch(23); // vdu_sys
	putch(27); // sprite command
	putch(14); // move by
	write16bit(x);
	write16bit(y);
	return;	
}

void vdp_spriteMoveBy(UINT8 id, UINT16 x, UINT16 y)
{
	vdp_spriteSelect(id);
	vdp_spriteMoveBySelected(x,y);
	return;
}

void vdp_spriteActivateTotal(UINT8 number)
{
	putch(23); // vdu_sys
	putch(27); // sprite command
	putch(7);  // set number of sprites
	putch(number);
	return;	
}

void vdp_spriteRefresh(void)
{
	putch(23);	// vdu_sys
	putch(27);	// sprite command
	putch(15);	// refresh all sprites
	return;
}

UINT8 vdp_cursorGetXpos(void)
{
	unsigned int delay;
	
	putch(23);	// VDP command
	putch(0);	// VDP command
	putch(0x82);	// Request cursor position
	
	delay = 255;
	while(delay--);
	return(getsysvar_cursorX());

}

UINT8 vdp_cursorGetYpos(void)
{
	unsigned int delay;
	
	putch(23);	// VDP command
	putch(0);	// VDP command
	putch(0x82);	// Request cursor position
	
	delay = 255;
	while(delay--);
	return(getsysvar_cursorY());
}

char vdp_asciiCodeAt(unsigned char x, unsigned char y)
{
	unsigned int delay;
	
	putch(23);	// VDP command
	putch(0);	// VDP command
	putch(0x83);	// Request ascii code at position (x,y)
	putch(x);
	putch(0);
	putch(y);
	putch(0);
	
	delay = 64000;
	while(delay--);
	return(getsysvar_scrchar());
}

void  vdp_setpagedMode(bool mode) {
	if(mode) putch(0x0E);
	else putch(0x0F);
}

void vdp_cursorDisable(void)
{
	putch(23);
	putch(1);
	putch(0);
}

void vdp_cursorEnable(void)
{
	putch(23);
	putch(1);
	putch(1);
}

void vdp_scroll(unsigned char extent, unsigned char direction, unsigned char speed)
{
	putch(23);
	putch(7);	// scroll
	putch(extent);
	putch(direction);
	putch(speed);
}