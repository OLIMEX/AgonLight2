//
// Title:	        Agon Video BIOS - Teletext Mode
// Author:        	Lennart Benschop
// Created:       	06/05/2023
// Last Updated:	07/05/2023
//
// Modinfo: 
// 07/05/2023:    Added support for windowing (cls and scroll methods). Implemented flash
// 11/06/2023:    Fixed hold graphics semantics
// 13/06/2023:    Refactored the code, made all private member variables prefix m_
// 18/10/2023:    Integrated into the new VDP code. canvas is a global variable (unique pointer).

#pragma once

#include "ttxtfont.h"
#include "agon_palette.h"
#include "agon_screen.h"

#define COLOUR_BLACK   0x00
#define COLOUR_RED     0x30
#define COLOUR_GREEN   0x0C
#define COLOUR_YELLOW  0x3C
#define COLOUR_BLUE    0x03
#define COLOUR_MAGENTA 0x33
#define COLOUR_CYAN    0x0F
#define COLOUR_WHITE   0x3F

// State flags representing how a character must be displayed.
#define TTXT_STATE_FLAG_FLASH    0x01
#define TTXT_STATE_FLAG_CONCEAL  0x02
#define TTXT_STATE_FLAG_HEIGHT   0x04 // Double height active.
#define TTXT_STATE_FLAG_GRAPH    0x08
#define TTXT_STATE_FLAG_SEPARATE 0x10
#define TTXT_STATE_FLAG_HOLD     0x20
#define TTXT_STATE_FLAG_DHLOW    0x40 // We are on the lower row of a double-heigh.

#define IS_CONTROL(c)  ((c & 0x60)==0)

// Type of operation for process_lline.
typedef enum {
  AGON_TTXT_OP_SCAN,     // Scan a text row to set attributes for next character displayed.
  AGON_TTXT_OP_UPDATE,   // Update a control code in the row, redraw row from column position (possibly also rows below for double-height).
  AGON_TTXT_OP_FLASH,    // Update the flashing characters in the row.
  AGON_TTXT_OP_REPAINT,  // Repaint the entire row (but never rows below), as these will be repainted by separate calls.
} agon_ttxt_op_t;


// The teletext video class
//
class agon_ttxt {	
public:
  int init(void);
  unsigned char get_screen_char(int x, int y);
  void draw_char(int x, int y, unsigned char c);
  void scroll();
  void cls();
  void flash(bool f);
  void set_window(int left, int bottom, int right, int top);
private:
  fabgl::FontInfo m_font;
  // Font bitmaps for normal height, top half of double height, bottom half of double height.
  unsigned char *m_font_data_norm, *m_font_data_top, *m_font_data_bottom; 
  unsigned char *m_screen_buf; // Buffer containing all bytes in teletext page.
  char m_dh_status[25]; // Double-height status per row: 0 none, 1 top half, 2 bottom half.
  int m_lastRow, m_lastCol;
  unsigned char m_stateFlags;
  RGB888 m_fg;
  RGB888 m_bg;
  int m_left, m_bottom, m_right, m_top;
  bool m_flashPhase;
  void set_font_char(unsigned char dst, unsigned char src);
  void set_graph_char(unsigned char dst, unsigned char pat, bool contig);
  void setgrpbyte(int index, char dot, bool contig, bool inner);
  void display_char(int col, int row, unsigned char c);
  unsigned char translate_char(unsigned char c);
  void process_line(int row, int col, agon_ttxt_op_t op);
};

agon_ttxt ttxt_instance; // Single instance of this object.
bool ttxtMode = false;   // Flag to indicate that teletext mode is active.

// Translated displayable character to index in font (128..255 represent block graphics).
unsigned char agon_ttxt::translate_char(unsigned char c)
{
  switch (c)
  { // Translate some characters from ASCII to their code point in the Teletext font.
    case '#':
      c = '_';
      break;
    case '_':
      c = '`';
      break;
    case '`':
      c = '#';
      break;
  }  
  c = c & 0x7f;
  if ((m_stateFlags & TTXT_STATE_FLAG_GRAPH) && (c & 0x20)) // select graphics for chars 0x20--0x3f, 0x60--0x7f/
  { 
    if (m_stateFlags & TTXT_STATE_FLAG_SEPARATE)
      c = c + 128;
    else
      c = c + 96;
  }
  return c;  
}

// Display char at text column and row, c is font index.
void agon_ttxt::display_char(int col, int row, unsigned char c)
{
  if ((m_stateFlags & TTXT_STATE_FLAG_CONCEAL) ||
      ((m_stateFlags & TTXT_STATE_FLAG_DHLOW) && !(m_stateFlags & TTXT_STATE_FLAG_HEIGHT)) ||
      ((m_stateFlags & TTXT_STATE_FLAG_FLASH) && !m_flashPhase))
    c = 32;
  canvas->setPenColor(m_fg);
  canvas->setBrushColor(m_bg);
  canvas->drawChar(col*16, row*m_font.height, c);
}


// Process one line of text, parsing control codes.
// row -- rown number 0..24
// col -- process line up to column n.
// redraw, redraw the characters.
// do_flash. redraw only the characters that are flashing (redraw parameter must be false).
void agon_ttxt::process_line(int row, int col, agon_ttxt_op_t op)
{
  int maxcol;
  int old_dhstatus;
  bool redraw = (op == AGON_TTXT_OP_REPAINT);
  unsigned char heldGraph;
  do {
    if (op == AGON_TTXT_OP_SCAN) 
      maxcol = col;
    else
      maxcol = 40;
    m_font.data = m_font_data_norm;
    if (m_dh_status[row] == 2) 
      m_stateFlags = TTXT_STATE_FLAG_DHLOW;
    else
      m_stateFlags = 0;
    old_dhstatus = m_dh_status[row];
    if ((op == AGON_TTXT_OP_UPDATE) && m_dh_status[row] == 1)
    {
       // If we update a control character in the line, reconsider its double height status and that of the line below.
       m_dh_status[row] = 0;
       if (row < 24) m_dh_status[row+1] = 0;        
    }
    m_bg = colourLookup[COLOUR_BLACK];
    m_fg = colourLookup[COLOUR_WHITE];
    heldGraph = 0;

    for (int i=0; i<maxcol; i++)
    {
      unsigned char c = m_screen_buf[row*40+i];
      if (op == AGON_TTXT_OP_UPDATE && i==col) redraw = true; // Start redrawing updated line.
      if (IS_CONTROL(c))
      {
        // These control codes already take effect in the same cell (for held graphics or for background colour)
        switch(c & 0x7f)
        { 
        case 0x09:
          m_stateFlags &= ~TTXT_STATE_FLAG_FLASH;        
          if (op == AGON_TTXT_OP_FLASH) redraw = false;        
          break;
        case 0x0c:
          m_stateFlags &= ~TTXT_STATE_FLAG_HEIGHT;
          heldGraph=0;
          m_font.data = m_font_data_norm;
          break;                
        case 0x0d:
          m_stateFlags |= TTXT_STATE_FLAG_HEIGHT;
          heldGraph = 0;
          if (m_dh_status[row] == 0)
          {
            m_dh_status[row] = 1;
            if (row<24) {
              m_dh_status[row+1] = 2;
            }
            m_font.data = m_font_data_top;
          } else if (m_dh_status[row] == 1)
          {
            m_font.data = m_font_data_top;
          }
          else
          {
            m_font.data = m_font_data_bottom;
          }
          break;
        case 0x18:
          m_stateFlags |= TTXT_STATE_FLAG_CONCEAL;
          break;
        case 0x1C: 
          m_bg = colourLookup[COLOUR_BLACK];
          break;
        case 0x1D: 
          m_bg = m_fg;
          break;
        case 0x1E:
          m_stateFlags |= TTXT_STATE_FLAG_HOLD;
          break;
        }
        if (redraw)
        {
          if (heldGraph && (m_stateFlags & TTXT_STATE_FLAG_HOLD))
            display_char(i, row, heldGraph);
          else
            display_char(i, row, ' ');
        }
        // Thse control codes will take effect in the next cell.
        switch(c & 0x7f)
        { 
        case 0x01: 
          m_fg = colourLookup[COLOUR_RED];
          heldGraph = 0;
          m_stateFlags &= ~TTXT_STATE_FLAG_GRAPH;
          m_stateFlags &= ~TTXT_STATE_FLAG_CONCEAL;
          break;
        case 0x02: 
          m_fg = colourLookup[COLOUR_GREEN];
          heldGraph=0;
          m_stateFlags &= ~TTXT_STATE_FLAG_GRAPH;
          m_stateFlags &= ~TTXT_STATE_FLAG_CONCEAL;
          break;
        case 0x03: 
          m_fg = colourLookup[COLOUR_YELLOW];
          heldGraph=0;
          m_stateFlags &= ~TTXT_STATE_FLAG_GRAPH;
          m_stateFlags &= ~TTXT_STATE_FLAG_CONCEAL;
          break;
        case 0x04: 
          m_fg = colourLookup[COLOUR_BLUE];
          heldGraph=0;
          m_stateFlags &= ~TTXT_STATE_FLAG_GRAPH;
          m_stateFlags &= ~TTXT_STATE_FLAG_CONCEAL;
          break;
        case 0x05: 
          m_fg = colourLookup[COLOUR_MAGENTA];
          heldGraph=0;
          m_stateFlags &= ~TTXT_STATE_FLAG_GRAPH;
          m_stateFlags &= ~TTXT_STATE_FLAG_CONCEAL;
          break;
        case 0x06: 
          m_fg = colourLookup[COLOUR_CYAN];
          heldGraph=0;
          m_stateFlags &= ~TTXT_STATE_FLAG_GRAPH;
          m_stateFlags &= ~TTXT_STATE_FLAG_CONCEAL;
          break;
        case 0x07: 
          m_fg = colourLookup[COLOUR_WHITE];
          heldGraph=0;
          m_stateFlags &= ~TTXT_STATE_FLAG_GRAPH;
          m_stateFlags &= ~TTXT_STATE_FLAG_CONCEAL;
          break;
        case 0x08:
          m_stateFlags |= TTXT_STATE_FLAG_FLASH;
          if (op==AGON_TTXT_OP_FLASH) redraw = true;        
          break;
          case 0x11: 
          m_fg = colourLookup[COLOUR_RED];
          m_stateFlags |= TTXT_STATE_FLAG_GRAPH;
          m_stateFlags &= ~TTXT_STATE_FLAG_CONCEAL;
          break;
        case 0x12: 
          m_fg = colourLookup[COLOUR_GREEN];
          m_stateFlags |= TTXT_STATE_FLAG_GRAPH;
          m_stateFlags &= ~TTXT_STATE_FLAG_CONCEAL;
          break;
        case 0x13: 
          m_fg = colourLookup[COLOUR_YELLOW];
          m_stateFlags |= TTXT_STATE_FLAG_GRAPH;
          m_stateFlags &= ~TTXT_STATE_FLAG_CONCEAL;
          break;
        case 0x14: 
          m_fg = colourLookup[COLOUR_BLUE];
          m_stateFlags |= TTXT_STATE_FLAG_GRAPH;
          m_stateFlags &= ~TTXT_STATE_FLAG_CONCEAL;
          break;
        case 0x15: 
          m_fg = colourLookup[COLOUR_MAGENTA];
          m_stateFlags |= TTXT_STATE_FLAG_GRAPH;
          m_stateFlags &= ~TTXT_STATE_FLAG_CONCEAL;
          break;
        case 0x16: 
          m_fg = colourLookup[COLOUR_CYAN];
          m_stateFlags |= TTXT_STATE_FLAG_GRAPH;
          m_stateFlags &= ~TTXT_STATE_FLAG_CONCEAL;
          break;
        case 0x17: 
          m_fg = colourLookup[COLOUR_WHITE];
          m_stateFlags |= TTXT_STATE_FLAG_GRAPH;
          m_stateFlags &= ~TTXT_STATE_FLAG_CONCEAL;
          break;
        case 0x19:
          m_stateFlags &= ~TTXT_STATE_FLAG_SEPARATE;
          break;
        case 0x1A:
          m_stateFlags |= TTXT_STATE_FLAG_SEPARATE;
          break;
        case 0x1F:
          m_stateFlags &= ~TTXT_STATE_FLAG_HOLD;
          break;                   
        }
      }
      else 
      {
        c = translate_char(c);
        if (c>=128) heldGraph = c; else heldGraph = 0;
        if (redraw)
        {
          this->display_char(i, row, c);
        } 
      }
    }
    row += 1;
    col = 0;
  } while (old_dhstatus != m_dh_status[row-1]); // If the double height status changed, draw next row too.
}

// Set single byte in a font character representing a graphic.
void agon_ttxt::setgrpbyte(int index, char dot, bool contig, bool inner)
{
  unsigned char b = 0x00;
  if (dot & 1)
  {
    if (contig)
      b = 0xff;
    else if (inner)
      b = 0x7e;
  }
  m_font_data_norm[index] = b;
}


// Store the required character from the ttxt_font into the font_data_norm member.
// dst - position in font_data_norm
// src - position in ttxtfont.
// Note: the ttxtfont array contains a 16x20 font stored as 16-bit values, 
// while the target is a 16x19 or 16x20 font stored as bytes. The bottom row (blank)  will not be copied if font height = 19.
void agon_ttxt::set_font_char(unsigned char dst, unsigned char src)
{
  for (int i = 0; i < m_font.height; i++)
  {
    uint16_t w = ttxtfont[src*20 + i];
    m_font_data_norm[dst*2*m_font.height+2*i] = w & 0xff;
    m_font_data_norm[dst*2*m_font.height+2*i+1] = w >> 8;    
  }
}

// Store the required graphics character into the font_data_norm member.
// dst - position in font_data_norm
// pat - bit pattern of graphics character.
// contig - is character contiguous.
void agon_ttxt::set_graph_char(unsigned char dst, unsigned char pat, bool contig)
{
  int b1,b2,b3;
  if (m_font.height==19)
  {
    b1 = 6; b2 = 7; b3 = 6; // Heights of the graphics blocks
  }
  else
  { // font height = 20.
    b1 = 7; b2 = 6; b3 = 7;
  }
  
  // Top row outer lines
  setgrpbyte(dst*2*m_font.height+0, pat>>0, contig, false);
  setgrpbyte(dst*2*m_font.height+1, pat>>1, contig, false);
  // Inner blocks of top row
  for (int i=1; i<b1-1; i++)
  {
    setgrpbyte(dst*2*m_font.height+2*i, pat>>0, contig, true);
    setgrpbyte(dst*2*m_font.height+2*i+1, pat>>1, contig, true);
  }
  // Top row outer lines
  setgrpbyte(dst*2*m_font.height+2*b1-2, pat>>0, contig, false);
  setgrpbyte(dst*2*m_font.height+2*b1-1, pat>>1, contig, false);
  // Middle row outer lines
  setgrpbyte(dst*2*m_font.height+2*b1,   pat>>2, contig, false);
  setgrpbyte(dst*2*m_font.height+2*b1+1, pat>>3, contig, false);
  // Middle row inner lines
  for (int i=b1+1; i<b1+b2-1; i++)
  {
    setgrpbyte(dst*2*m_font.height+2*i,   pat>>2, contig, true);
    setgrpbyte(dst*2*m_font.height+2*i+1, pat>>3, contig, true);
  }
  // Middle row outer lines
  setgrpbyte(dst*2*m_font.height+2*(b1+b2-1),  pat>>2, contig, false);
  setgrpbyte(dst*2*m_font.height+2*(b1+b2-1)+1, pat>>3, contig, false);
  // Bottom row, outer lines
  setgrpbyte(dst*2*m_font.height+2*(b1+b2),   pat>>4, contig, false);
  setgrpbyte(dst*2*m_font.height+2*(b1+b2)+1, pat>>5, contig, false);
  // Bottom row, inner lines
  for (int i=b1+b2+1; i<b1+b2+b3-1; i++)
  {
    setgrpbyte(dst*2*m_font.height+2*i,   pat>>4, contig, true);
    setgrpbyte(dst*2*m_font.height+2*i+1, pat>>5, contig, true);
  }
  // Bottom row, outer lines
  setgrpbyte(dst*2*m_font.height+2*(b1+b2+b3-1), pat>>4, contig, false);
  setgrpbyte(dst*2*m_font.height+2*(b1+b2+b3-1)+1, pat>>5, contig, false);
}


int agon_ttxt::init(void)
{
  int oldh = m_font.height;
  if (canvas->getHeight() >= 500)
  {
      m_font.height = 20;
  }
  else
  {
      m_font.height = 19;    
  }
  m_font.pointSize = 12;
  m_font.width = 16;
  m_font.ascent = 12;
  m_font.weight = 400;
  m_font.charset = 255;
  m_font.codepage = 1252;
  if (m_font_data_norm == NULL)
  {
    m_font_data_norm=(unsigned char*)PreferPSRAMAlloc(40*256);
    if (m_font_data_norm == NULL)
      return -1;
  }
  if (oldh != m_font.height)
  {  
    for (int i=32; i<127; i++)
      set_font_char(i, i);
    // Set the characters that differ from standard ASCII (in UK teletext char set).
    set_font_char('#', 163); // Pounds sign.
    set_font_char('[', 143); // Left arrow.
    set_font_char('\\', 189); // 1/2 fraction
    set_font_char(']', 144); // Right arrow.
    set_font_char('^', 141); // Up arrow.
    set_font_char('_', '#'); // Hash mark.
    set_font_char('`', 151); // Em-dash.
    set_font_char('{', 188); // 1/4 fraction.
    set_font_char('|', 157); // Dpuble vertical bar
    set_font_char('}', 190); // 3/4 fraction.
    set_font_char('~', 247); // Division.
    set_font_char(127, 129); // Block.
    // Positions 128..255 are for graphics characters, both contiguous and separated.
    for (int i=0; i<32; i++)
    {
      set_graph_char(128+i, i, true); // Contiguous graphics characters
      set_graph_char(160+i, i, false); // Separate graphics characters.
      set_graph_char(192+i, 32+i, true);
      set_graph_char(224+i, 32+i, false);
    }
  }
  if (m_font_data_top == NULL)
  {
    m_font_data_top=(unsigned char*)PreferPSRAMAlloc(40*256);
    if (m_font_data_top == NULL)
      return -1;
  }
  if (oldh != m_font.height)
  {
    for (int i=32; i<256; i++)
    {
      unsigned char *p = m_font_data_norm+2*m_font.height*i;
      for (int j=0; j<m_font.height; j++)
      {
        m_font_data_top[i*2*m_font.height+j*2] = *p;
        m_font_data_top[i*2*m_font.height+j*2+1] = *(p+1);
        if (j%2 == 1) p+=2;
      }
    }
  }
  if (m_font_data_bottom == NULL)
  {
    m_font_data_bottom=(unsigned char*)PreferPSRAMAlloc(40*256);
    if (m_font_data_bottom == NULL)
      return -1;
  }
  if (oldh != m_font.height)
  {
    for (int i=32; i<256; i++)
    {
      unsigned char *p = m_font_data_norm+2*m_font.height*i+(m_font.height==20?20:18);
      for (int j=0; j<m_font.height; j++)
      {
        m_font_data_bottom[i*2*m_font.height+j*2] = *p;
        m_font_data_bottom[i*2*m_font.height+j*2+1] = *(p+1);
        if (j%2 == (m_font.height==20)) p+=2;
      }
    }
  }
  if (m_screen_buf == NULL)
  {
    m_screen_buf=(unsigned char *)PreferPSRAMAlloc(1000);
    if (m_screen_buf == NULL)
      return -1;      
  }
  canvas->selectFont(&m_font);
  canvas->setGlyphOptions(GlyphOptions().FillBackground(true));
  set_window(0, 24, 39, 0);
  cls();
  return 0;
}

unsigned char agon_ttxt::get_screen_char(int x, int y)
{
  x=x/m_font.width;
  y=y/m_font.height;
  if (x<0 || x>39 || y<0 || y>24)
    return 0;
  else
    return m_screen_buf[x+y*40];
}

void agon_ttxt::draw_char(int x, int y, unsigned char c)
{
  int cx=x/m_font.width;
  int cy=y/m_font.height;
  if (cx<0 || cx>39 || cy<0 || cy>24)
    return;
  unsigned char oldb = m_screen_buf[cx+cy*40];
  m_screen_buf[cx+cy*40] = c;
  // Determine how much to render.
  if (IS_CONTROL(c) || IS_CONTROL(oldb) || (cx<39 && IS_CONTROL(m_screen_buf[cx+1+cy*40])))
  {
     // If removing or adding control character, redraw line from column position.
     process_line(cy, cx, AGON_TTXT_OP_UPDATE); 
     m_lastRow = -1;
     return;
  }
  else if (cx != m_lastCol+1 || cy != m_lastRow)
  {
      // If not continuing on same line after last drawn character, parse all control chars.
      process_line(cy, cx, AGON_TTXT_OP_SCAN); 
      m_lastCol = cx;
      m_lastRow = cy;
      
  } 
  display_char(cx, cy, translate_char(c));
}

void agon_ttxt::scroll()
{
  if (m_left==0 && m_right==39 && m_top==0 && m_bottom==24)
  {
    /* Do the full screen */
    memmove(m_screen_buf, m_screen_buf+40, 960);
    memset(m_screen_buf+960, ' ', 40);
    m_lastRow--;
    memmove(m_dh_status, m_dh_status+1, 24);
    if (m_dh_status[23] == 1) 
      m_dh_status[24] = 2;
    else
      m_dh_status[24] = 0;
     canvas->scroll(0, -m_font.height);
     if (m_dh_status[0] == 2)
     {
        m_dh_status[0] = 1;
        process_line(0, 0, AGON_TTXT_OP_UPDATE);
        m_lastRow = -1;
     }     
  }
  else
  {
    for (int row = m_top; row < m_bottom; row++)
    {
      memcpy(m_screen_buf+40*row+m_left,m_screen_buf+40*(row+1)+m_left , m_right+1-m_left);
    }
    memset(m_screen_buf+40*m_bottom+m_left, ' ', m_right + 1 - m_left);
    memset(m_dh_status, 0, 25);
    for (int row = 0; row < 25; row++)
    {    
      process_line(row, 40, AGON_TTXT_OP_REPAINT);
    }    
  }
}

void agon_ttxt::cls()
{
  m_lastRow = -1;
  m_lastCol = -1;
  if (m_left==0 && m_right==39 && m_top==0 && m_bottom==24)
  {
      /* Do the full screen */
      memset(m_screen_buf, ' ', 1000);
      memset(m_dh_status, 0, 25);
      canvas->clear();
  }
  else
  {
    for (int row=m_top; row <= m_bottom; row++)
    {
      memset(m_screen_buf+40*row+m_left, ' ', m_right + 1 - m_left);
    }
    memset(m_dh_status, 0, 25);
    for (int row=0; row < 25; row++)
    {
      this->process_line(row, 40, AGON_TTXT_OP_REPAINT);
    }
  }
}


void agon_ttxt::flash(bool f)
{
  m_flashPhase = f;
  bool fUpdated = false;
  RGB888 oldbg = m_bg;
  RGB888 oldfg = m_fg;
  for (int i = 0; i < 25; i++)
  {
    for (int j = 0; j < 40; j++)
    {
      if ((m_screen_buf[i*40+j] & 0x7f) == 0x08)
      {
        // Scan/redraw the line if there is any flash control code.
        process_line(i, 40, AGON_TTXT_OP_FLASH); 
        fUpdated = true;
        break; 
      }
    }
  }
  if (fUpdated)
  {
    if (m_lastRow >= 0) 
      process_line(m_lastRow, m_lastCol, AGON_TTXT_OP_SCAN);
    canvas->setBrushColor(oldbg);
    canvas->setPenColor(oldfg);
  }
}

// Set the window parametes of the Teletext mode.
// This only rules the cls and scroll methods.
void agon_ttxt::set_window(int left, int bottom, int right, int top)
{
  m_left = left;
  m_bottom = bottom;
  m_right = right;
  m_top = top;  
}

