// *************************************************************************************************
// LCDSetLine.c
//
// Draws a line in the specified color from (x0,y0) to (x1,y1)
//
// Inputs: x = row address (0 .. 131)
//         y = column address (0 .. 131)
//         color = 12-bit color value rrrrggggbbbb
//                 rrrr = 1111 full red
//                             :
//                        0000 red is off
//
//                 gggg = 1111 full green
//                             :
//                        0000 green is off
//
//                        bbbb = 1111 full blue
//                             :
//                        0000 blue is off
//
// Returns: nothing
//
// Note: good write-up on this algorithm in Wikipedia (search for Bresenham's line algorithm)
//       see lcd.h for some sample color settings
//
// Authors: Dr. Leonard McMillan, Associate Professor UNC
//          Jack Bresenham IBM, Winthrop University (Father of this algorithm, 1962)
//
// Note: taken verbatim from Professor McMillan's presentation:
// http://www.cs.unc.edu/~mcmillan/comp136/Lecture6/Lines.html
//
// From Jim Lynch Nokia 6100 tutorial
//
// *************************************************************************************************
void LCDSetLine(int x0, int y0, int x1, int y1, int color) {
  int dy = y1 - y0;
  int dx = x1 - x0;
  int stepx, stepy;
  if (dy < 0) { dy = -dy; stepy = -1; } else { stepy = 1; }
  if (dx < 0) { dx = -dx; stepx = -1; } else { stepx = 1; }
  dy <<= 1; // dy is now 2*dy
  dx <<= 1; // dx is now 2*dx
  LCDSetPixel(color, x0, y0);
  if (dx > dy) {
    int fraction = dy - (dx >> 1); // same as 2*dy - dx
    while (x0 != x1) {
      if (fraction >= 0) {
        y0 += stepy;
        fraction -= dx; // same as fraction -= 2*dx
        }
      x0 += stepx;
      fraction += dy; // same as fraction -= 2*dy
      LCDSetPixel(color, x0, y0);
    }
  } else {
  int fraction = dx - (dy >> 1);
  while (y0 != y1) {
  if (fraction >= 0) {
    x0 += stepx;
    fraction -= dy;
    }
  y0 += stepy;
  fraction += dx;
  LCDSetPixel(color, x0, y0);
  }
 }
}
