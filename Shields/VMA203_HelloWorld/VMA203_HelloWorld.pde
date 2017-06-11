/*!
 * \file sketchbook/Shields/VMA203_HelloWorld/VMA203_HelloWorld.pde
 *
 * \brief LiquidCrystal Library - Hello World.
 * 
 * Demonstrates the use a 16x2 LCD display.
 * The LiquidCrystal library works with all LCD displays that are
 * compatible with the Hitachi HD44780 driver.
 * There are many of them out there, and you can usually tell them by
 * the 16-pin interface.
 *
 * This sketch prints "hello world!" to the LCD and shows the time.
 *
 * The circuit:\n
 * LCD RS pin to digital pin 8
 * LCD Enable pin to digital pin 9
 * LCD D4 pin to digital pin 4
 * LCD D5 pin to digital pin 5
 * LCD D6 pin to digital pin 6
 * LCD D7 pin to digital pin 7
 * LCD R/W pin to ground
 *
 * Library originally added 18 Apr 2008
 * by David A. Mellis
 * library modified 5 Jul 2009
 * by Limor Fried (http://www.ladyada.net)
 * example added 9 Jul 2009
 * by Tom Igoe
 * modified 22 Nov 2010
 * by Tom Igoe
 *
 * This example code is in the public domain.
 *
 * http://www.arduino.cc/en/Tutorial/LiquidCrystal
 */

/* Include the library code. */
#include <LiquidCrystal.h>

/* Initialize the library with the numbers of the interface pins. */
LiquidCrystal lcd (8, 9, 4, 5, 6, 7);

void
setup ()
{
  /* Set up the LCD's number of columns and rows. */
  lcd.begin (16, 2);
  /* Print a message to the LCD. */
  lcd.print ("hello world ;-)");
}

void
loop ()
{
  /* Set the cursor to column 0, line 1.
   * (note: line 1 is the second row, since counting begins with 0).
   */
  lcd.setCursor (0, 1);
  /* Print the number of seconds since reset. */
  lcd.print (millis()/1000);
}

/* EOF */

