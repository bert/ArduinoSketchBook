// *****************************************************************************************
// LCDSetRect.c
//
// Draws a rectangle in the specified color from (x1,y1) to (x2,y2)
// Rectangle can be filled with a color if desired
//
// Inputs: x = row address (0 .. 131)
//         y = column address (0 .. 131)
//         fill = 0=no fill, 1-fill entire rectangle
//         color = 12-bit color value for lines rrrrggggbbbb
//         rrrr = 1111 full red
//                   :
//         0000 red is off
//
//         gggg = 1111 full green
//                   :
//         0000 green is off
//
//         bbbb = 1111 full blue
//                   :
//         0000 blue is off
// Returns: nothing
//
// Notes:
//
// The best way to fill a rectangle is to take advantage of the "wrap-around" featute
// built into the Philips PCF8833 controller. By defining a drawing box, the memory can
// be simply filled by successive memory writes until all pixels have been illuminated.
//
// 1. Given the coordinates of two opposing corners (x0, y0) (x1, y1)
// calculate the minimums and maximums of the coordinates
//
//   xmin = (x0 <= x1) ? x0 : x1;
//   xmax = (x0 > x1) ? x0 : x1;
//   ymin = (y0 <= y1) ? y0 : y1;
//   ymax = (y0 > y1) ? y0 : y1;
//
// 2. Now set up the drawing box to be the desired rectangle
//
//   LCDCommand(PASET); // set the row boundaries
//   LCDData(xmin);
//   LCDData(xmax);
//   LCDCommand(CASET); // set the column boundaries
//   LCDData(ymin);
//   LCDData(ymax);
//
// 3. Calculate the number of pixels to be written divided by 2
//
//   NumPixels = ((((xmax - xmin + 1) * (ymax - ymin + 1)) / 2) + 1)
//
//   You may notice that I added one pixel to the formula.
//   This covers the case where the number of pixels is odd and we
//   would lose one pixel due to rounding error. In the case of
//   odd pixels, the number of pixels is exact.
//   in the case of even pixels, we have one more pixel than
//   needed, but it cannot be displayed because it is outside
//   the drawing box.
//
// We divide by 2 because two pixels are represented by three bytes.
// So we work through the rectangle two pixels at a time.
//
// 4. Now a simple memory write loop will fill the rectangle
//
//   for (i = 0; i < ((((xmax - xmin + 1) * (ymax - ymin + 1)) / 2) + 1); i++) {
//     LCDData((color >> 4) & 0xFF);
//     LCDData(((color & 0xF) << 4) | ((color >> 8) & 0xF));
//     LCDData(color & 0xFF);
//     }
//
// In the case of an unfilled rectangle, drawing four lines with the Bresenham line
// drawing algorithm is reasonably efficient.
//
// Author: James P Lynch July 7, 2007
// *****************************************************************************************

#include "LCD_driver.h"

void LCDSetRect(int x0, int y0, int x1, int y1, unsigned char fill, int color) {
  int xmin, xmax, ymin, ymax;
  int i;

  // check if the rectangle is to be filled
  if (fill == FILL) {
  // best way to create a filled rectangle is to define a drawing box
  // and loop two pixels at a time
  // calculate the min and max for x and y directions
    xmin = (x0 <= x1) ? x0 : x1;
    xmax = (x0 > x1) ? x0 : x1;
    ymin = (y0 <= y1) ? y0 : y1;
    ymax = (y0 > y1) ? y0 : y1;
    // specify the controller drawing box according to those limits
    // Row address set (command 0x2B)
    LCDCommand(PASET);
    LCDData(xmin);
    LCDData(xmax);
    // Column address set (command 0x2A)
    LCDCommand(CASET);
    LCDData(ymin);
    LCDData(ymax);
    // WRITE MEMORY
    LCDCommand(RAMWR);
    // loop on total number of pixels / 2
    for (i = 0; i < ((((xmax - xmin + 1) * (ymax - ymin + 1)) / 2) + 1); i++) {
    // use the color value to output three data bytes covering two pixels
      LCDData((color >> 4) & 0xFF);
      LCDData(((color & 0xF) << 4) | ((color >> 8) & 0xF));
      LCDData(color & 0xFF);
     }
    } else {
    // best way to draw un unfilled rectangle is to draw four lines
    LCDSetLine(x0, y0, x1, y0, color);
    LCDSetLine(x0, y1, x1, y1, color);
    LCDSetLine(x0, y0, x0, y1, color);
    LCDSetLine(x1, y0, x1, y1, color);
  }
}
