/*
     One Wire iButton Real Time Clock Routine Originally developed for iButton DataLogger programmer using DS1904
     
     Real Time Clock Routines:
     
     GetTimeRTC(device address)
     - Get number of seconds since 1/1/1970 by accessing DS1994 Real Time Clock registers
     
     Following are ported from Maxim's iButton SDK with copyright notice listed below:
     
     - BCDtoBin(bcd) - Take one byte Binary coded decimal value and return binary value
     - IntToBCD(int) - Convert an integer to a 1 Byte Binary Coded Decimal number (99 max) 
     - SecondsToDate - Convert total seconds from 1970 from DS1993 iButton real time clock to usable time and date
          

     Update: 4/21/10
     
     Author: Jeff Miller   http://arduinofun.blogspot.com/
     
     Copyright 2010 Released under GPLv3 http://www.gnu.org/copyleft/gpl.html
   
     This program is free software: you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
     the Free Software Foundation, either version 3 of the License, or
     (at your option) any later version.
    
     This program is distributed in the hope that it will be useful,
     but WITHOUT ANY WARRANTY; without even the implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
     GNU General Public License for more details: <http://www.gnu.org/licenses/>
*/



// ----------------------------------------------------------------------------------------------------------------------
//
// GetTimeRTC - Get number of seconds since 1/1/1970 by accessing DS1994 Real Time Clock registers
//
// ----------------------------------------------------------------------------------------------------------------------
 
long GetTimeRTC(byte* addr)
{
      byte register_data[5];
      long utime;
     
      one_wire_bus.reset();
      one_wire_bus.select(addr);        // Button address
      one_wire_bus.write(0x66,1);   // read RTC DS1904
      for ( byte i = 0; i < 5; i++) { // we need 4 bytes of time data
        register_data[i] = one_wire_bus.read();
      }
      one_wire_bus.reset();
    
      utime = register_data[4];
        
      for ( byte i = 3; i > 0; i--) { // we need 4 bytes of time data
            utime = utime<<8 | register_data[i];
        }

//  Serial.println(utime, DEC);  
     
      return utime;
}



// ----------------------------------------------------------------------------------------------------------------------
//
// SecondsToDate - Ported to Arduino from Maxim Semiconductor SDK
//
// Copyright (C) 1999-2006 Dallas Semiconductor Corporation, 
// All Rights Reserved.
//
// Permission is hereby granted, free of charge, 
// to any person obtaining a copy of this software and 
// associated documentation files (the "Software"), to 
// deal in the Software without restriction, including 
// without limitation the rights to use, copy, modify, 
// merge, publish, distribute, sublicense, and/or sell 
// copies of the Software, and to permit persons to whom 
// the Software is furnished to do so, subject to the 
// following conditions:
//
// The above copyright notice and this permission notice
// shall be included in all copies or substantial portions
// of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF 
// ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
// TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
// PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL DALLAS SEMICONDUCTOR BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
// IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
// DEALINGS IN THE SOFTWARE.
//
// Except as contained in this notice, the name of 
// Dallas Semiconductor shall not be used except as stated
// in the Dallas Semiconductor Branding Policy.

// Take a 4-byte long (consisting of 
// the number of seconds elapsed since Jan. 1 1970) 
// and convert it into a timedate structure:
//
// typedef struct          
// {
//    ushort  second;
//    ushort  minute;
//    ushort  hour;
//    ushort  day;
//    ushort  month;
//    ushort  year;
// } timedate;
//
// Parameters:
//  * td     timedate struct to return the time/date.
//  x        the number of seconds elapsed since Jan 1, 1970.
//
// Returns:  
//  * td     returns the time/date in a timedate struct.
// 
// ----------------------------------------------------------------------------------------------------------------------
static int dm[] = { 0,0,31,59,90,120,151,181,212,243,273,304,334,365 };

void SecondsToDate(timedate *td, long x)
{
  
   short tmp,i,j;
   long y;

   char tsec[3], thour[3], tmin[3], tday[3], tmonth[3], tyear[3]; // time characters for LCD display 
   strcpy(date_lcd_text,""); // Ensure date and time variables are initialized to null or crashes LCD display when DL initialized
   strcpy(time_lcd_text,"");

   // check to make sure date is not over 2070 (sanity check)
   if (x > 0xBBF81E00L)
      x = 0;
   
   y = x/60;  td->second = (short)(x-60*y);       
   x = y/60;  td->minute = (short)(y-60*x);
   y = x/24;  td->hour   = (short)(x-24*y);
   x = 4*(y+731);  td->year = (short)(x/1461);
   i = (int)((x-1461*(long)(td->year))/4);  td->month = 13;
   
   do {
      td->month -= 1;
      tmp = (td->month > 2) && ((td->year & 3)==0) ? 1 : 0;
      j = dm[td->month]+tmp;
   
   } while (i < j);
   
   td->day = i-j+1;
   
   // slight adjustment to algorithm 
   if (td->day == 0) 
      td->day = 1;
   
   td->year = (td->year < 32)  ? td->year + 68 + 1900: td->year - 32 + 2000;

   // Append date into one character string

   // Convert int to char
   itoa(int (td->month), tmonth, 10); // convert int to string
   itoa(int (td->day), tday, 10); // convert int to string
   itoa(int (td->year)-2000, tyear, 10); // convert int to string 
   itoa(int (td->hour), thour, 10); // convert int to string
   itoa(int (td->minute), tmin, 10); // convert int to string 
   itoa(int (td->second), tsec, 10); // convert int to string 

   // Add a 0 to LCD if month is less then 10  (Typical of remaining time and date)
   if (td->month <10) { 
      strcpy(date_lcd_text, "0");    
      }    
   strcat(date_lcd_text, tmonth);  
   strcat(date_lcd_text, "/");  

   if (td->day <10) {
       strcat(date_lcd_text, "0");  
      }
   strcat(date_lcd_text, tday);  

// Not enough room to show the year at medium font
/* 
   strcat(date_lcd_text, "/");  

   if ( (td->year) - 2000 <10 ) {
      strcat(date_lcd_text, "0");   
      }
   strcat(date_lcd_text, tyear);  
*/  
   // Append time into one character string

   if (td->hour <10) {
       strcat(time_lcd_text, "0");    
      }
   strcat(time_lcd_text, thour);  
   strcat(time_lcd_text, ":");  

   if (td->minute <10) {
       strcat(time_lcd_text, "0");    
      }
   strcat(time_lcd_text, tmin);  
   strcat(time_lcd_text, ":");  

   if (td->second <10) {
      strcat(time_lcd_text, "0");    
      }
   strcat(time_lcd_text, tsec);  
}

// ----------------------------------------------------------------------------------------------------------------------
//
//  BCDtoBin - Take one byte Binary coded decimal value and return binary value
//
// ----------------------------------------------------------------------------------------------------------------------
int BCDToBin(byte bcd)
{
   return (((bcd & 0xF0) >> 4) * 10) + (bcd & 0x0F);
}
 
// ----------------------------------------------------------------------------------------------------------------------
//
// IntToBCD - Convert an integer to a 1 Byte Binary Coded Decimal number (99 max) 
//
// ----------------------------------------------------------------------------------------------------------------------
int IntToBCD(short num)
{
   int rtbyte;

   rtbyte = (num - ((num / 10) * 10)) & 0x0F;
   rtbyte = rtbyte | ((num / 10) << 4);
   
   return rtbyte;
}


