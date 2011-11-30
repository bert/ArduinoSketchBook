/*
     One Wire iButton Data Logger Programmer

     SearchOneWireDevices() - Use this code to search for attached 1-wire addresses...
     Developed from sample code at Arduino 1 Wire web page
  
      DS18S20 (0x10 Family) Temperature sensor
      DS18B20 (0x28 Family) Temperature sensor
      DS1920  (0x10 Family) ibutton temperature only
      DS1994  (0x04 Family) ibutton clock
      DS1921G (0x21 Family) ibutton temperature datalogger
      DS1923  (0x41 Family) ibutton temperature and humidity datalogger
 
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


void SearchOneWireDevices()
{
    byte addr[8];
//    attached_devices = 0;

    while (one_wire_bus.search(addr)!=0){

      for( byte i = 0; i < 8; i++) {  // Read the device ID
        
        Serial.println(addr[0], HEX);
      
// DS1994 Family Device. Should always be attached and online unless the onboard battery dies
        if (addr[0] == 0x24) {
            onewire_clock_device[i] = addr[i];
          }
       
      }

 //     attached_devices += 1; // Keep track of number of attached devices to show clock if no other sensors are attached.
   
      if ( OneWire::crc8( addr, 7) != addr[7]) {
          Serial.print("CRC is not valid!\n");
//          device_delay_read_flag = 0;  // Ensure a re-poll of devices
//          attached_devices = 0;        // Sometimes error generates more then 2 devices causing remove iButton message incorrectly
          one_wire_bus.reset_search(); // reset search device queue
          return;
        }
    }

   // Serial.println("No more addresses.\n");
   one_wire_bus.reset_search(); // reset search device queue
   return; 
}


