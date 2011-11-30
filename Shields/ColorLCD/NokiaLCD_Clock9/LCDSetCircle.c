// *************************************************************************************
// LCDSetCircle.c
//
// Draws a line in the specified color at center (x0,y0) with radius
//
// Inputs: x0 = row address (0 .. 131)
// y0 = column address (0 .. 131)
// radius = radius in pixels
// color = 12-bit color value rrrrggggbbbb
//
// Returns: nothing
//
// Author: Jack Bresenham IBM, Winthrop University (Father of this algorithm, 1962)
// From Jim Lynch Nokia 6100 tutorial
//
// Note: taken verbatim Wikipedia article on Bresenham's line algorithm
// http://www.wikipedia.org
//
// *************************************************************************************


void LCDSetCircle(int x0, int y0, int radius, int color) {
  int f = 1 - radius;
  int ddF_x = 0;
  int ddF_y = -2 * radius;
  int x = 0;
  int y = radius;
  
 
  LCDSetPixel(color, x0, y0 + radius);
  LCDSetPixel(color, x0, y0 - radius);
  LCDSetPixel(color, x0 + radius, y0);
  LCDSetPixel(color, x0 - radius, y0);
  while(x < y) {
    if(f >= 0) {
      y--;
      ddF_y += 2;
      f += ddF_y;
      }
    x++;
    ddF_x += 2;
    f += ddF_x + 1;
    LCDSetPixel(color, x0 + x, y0 + y);
    LCDSetPixel(color, x0 - x, y0 + y);
    LCDSetPixel(color, x0 + x, y0 - y);
    LCDSetPixel(color, x0 - x, y0 - y);
    LCDSetPixel(color, x0 + y, y0 + x);
    LCDSetPixel(color, x0 - y, y0 + x);
    LCDSetPixel(color, x0 + y, y0 - x);
    LCDSetPixel(color, x0 - y, y0 - x);


  }
}
