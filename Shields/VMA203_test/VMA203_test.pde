/*!
 * \file sketchbook/Shields/VMA203_test/VMA203_test.pde
 *
 * \brief Test program for the Velleman VMA203 LCD module.
 *
 * \author Bert Timmerman <bert.timmerman@xs4all.nl> for debugging
 * the example file from Velleman <http://www.velleman.eu>.
 *
 * \note Uses the LiquidCrystal library.
 *
 * <hr>
 *
 * <h1><b>Copyright.</b></h1>\n
 *
 * Licensed under the terms of the GNU General Public
 * License, version 2 or later.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#include <LiquidCrystal.h>

LiquidCrystal lcd (8, 9, 4, 5, 6, 7);

int lcd_key = 0;
int adc_key_in = 0;

#define btnRIGHT  0
#define btnUP     1
#define btnDOWN   2
#define btnLEFT   3
#define btnSELECT 4
#define btnNONE   5

int
read_LCD_buttons ()
{
  /* Read the key value from the sensor.
   * My buttons when read re centered at these values: 0, 144, 329, 504, 741.
   * We add approximately 50 to those values and see if we are close.
   */
  adc_key_in = analogRead (0);
  /* Test for no button pressed for speed reasons.*/

  /* For v1.0 use these thresholds. */
  if (adc_key_in > 1000) return btnNONE;
  if (adc_key_in < 50)   return btnRIGHT;
  if (adc_key_in < 195)  return btnUP;
  if (adc_key_in < 380)  return btnDOWN;
  if (adc_key_in < 555)  return btnLEFT;
  if (adc_key_in < 790)  return btnSELECT;

  /* For v1.1 use these thresholds. */
  /*
  if (adc_key_in > 1000) return btnNONE;
  if (adc_key_in < 50)   return btnRIGHT;
  if (adc_key_in < 250)  return btnUP;
  if (adc_key_in < 450)  return btnDOWN;
  if (adc_key_in < 650)  return btnLEFT;
  if (adc_key_in < 850)  return btnSELECT;
  */

  return btnNONE;
}

void
setup ()
{
  lcd.begin (16,2);
  lcd.setCursor (0,0);
  lcd.print ("Push the buttons");
}

void
loop ()
{
  lcd.setCursor (9,1); /* Position 9 of the second row. */
  lcd.print (millis () / 1000);
  lcd.setCursor (0,1);
  lcd_key = read_LCD_buttons ();
  switch (lcd_key)
  {
    case btnRIGHT:
    {
      lcd.print ("RIGHT ");
      break;
    }
    case btnLEFT:
    {
      lcd.print ("LEFT  ");
      break;
    }
    case btnUP:
    {
      lcd.print ("UP    ");
      break;
    }
    case btnDOWN:
    {
      lcd.print ("DOWN  ");
      break;
    }
    case btnSELECT:
    {
      lcd.print ("SELECT");
      break;
    }
    case btnNONE:
    {
      lcd.print ("NONE  ");
      break;
    }
  }
}

/* EOF */

