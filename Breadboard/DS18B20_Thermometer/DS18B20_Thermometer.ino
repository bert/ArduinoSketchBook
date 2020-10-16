/*!
 * \file breadboard/DS18B20_Thermometer/DS18B20_Thermomter.ino
 *
 * \author Konstantin Dimitrov
 */

#include <OneWire.h>
#include <DallasTemperature.h>

/* Data wire is plugged into pin 2 on the Arduino.*/
#define ONE_WIRE_BUS 2

/* Setup a oneWire instance to communicate with any OneWire devices
 * (not just Maxim/Dallas temperature ICs).*/
OneWire oneWire (ONE_WIRE_BUS);

/* Pass our oneWire reference to Dallas Temperature.*/
DallasTemperature sensors (&oneWire);

/* Interval at which to measure (milliseconds).*/
const unsigned long interval = (1200000);

/* Store the last time a temperature was taken.*/
unsigned long previousMillis = 0;


void
setup (void)
{
  /* Start serial port.*/
  Serial.begin (9600);
  Serial.println ("### DS18B20 Temperature ###");
  /* Start up the library.*/
  sensors.begin ();
}


void
loop (void)
{
  unsigned long currentMillis = millis();
  if (currentMillis - previousMillis >= interval)
  {
    /* Save the last time you measured the temperature.*/
    previousMillis = currentMillis;
    /* Call sensors.requestTemperatures() to issue a global temperature
     * request to all devices on the bus.*/
    sensors.requestTemperatures ();
    /* Print date and time.*/ 
//  Serial.print ("dd-mm-yyyy hh:mm  ");
    Serial.println (sensors.getTempCByIndex (0));
    /* Why "byIndex" ?
     * You can have more than one IC on the same bus. 
     * 0 refers to the first IC on the wire.*/
  }
}
