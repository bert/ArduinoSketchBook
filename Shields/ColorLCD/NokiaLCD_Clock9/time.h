//---------------------------------------------------------------------------
// time.h 
// iButton clock portion ported to Arduino from Maxim's SDK
// Parameters for DS1994 / DS1904 iButton Real Time Clock and Analog LCD display setup
// 
// Updated 6/13/10
//
//     Author: Jeff Miller   http://arduinofun.blogspot.com/
//     
//     Copyright 2010 Released under GPLv3 http://www.gnu.org/copyleft/gpl.html
//   
//     This program is free software: you can redistribute it and/or modify
//     it under the terms of the GNU General Public License as published by
//     the Free Software Foundation, either version 3 of the License, or
//     (at your option) any later version.
//    
//     This program is distributed in the hope that it will be useful,
//     but WITHOUT ANY WARRANTY; without even the implied warranty of
//     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//     GNU General Public License for more details: <http://www.gnu.org/licenses/>
//


//#define TIME_FAM       0x04

#define OSC            0x10

// type structure to hold time/date 
typedef struct          
{
     short  second;
     short  minute;
     short  hour;
     short  day;
     short  month;
     short  year;
} timedate;



// The "time conversion" functions

void SecondsToDate(timedate *, long);

// Analog Clock Variables

byte clock_center_x = 73;
byte clock_center_y = 65;
byte clock_radius = 55;


// Analog Clock Structure
typedef struct
{
  float angle;
  int base_x;
  int base_y;
  int base_x1;
  int base_y1;
  int end_x;
  int end_y;
  byte base_radius;
  byte hand_radius;
  long oldtime;
} analoghand;



