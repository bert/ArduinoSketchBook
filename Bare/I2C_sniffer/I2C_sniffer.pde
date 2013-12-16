/*!
 * \file I2C_sniffer.pde
 *
 * \brief Arduino I2C Sniffer.
 *
 * \author J. M. De Cristofaro
 *
 * \copyright 2011 CC-BY-SA 3.0
 *
 * \warning This code is unsupported -- use at your own risk!
 *
 * Connect one digital pin each to SCL and SDA.
 *
 * Use pins on PORTD (Arduino UNO/Duemilanove pins #0 - 7).
 *
 * \warning Do not connect to serial pins (0 & 1)!
 *
 * Connect GND on Arduino to GND of I2C bus.
 *
 * DESCRIPTION.
 * This code runs a "one-shot" capture, meaning that
 * it only captures data once and then dumps it to the
 * serial port.
 *
 * It starts capturing when it detects the SDA line has
 * gone low. It does not check the SCL line (as a proper
 * start condition detector would).
 *
 * You can adjust the capture window to suit you needs.
 * A value of 300 is long enough to catch one byte sent
 * over i2c at the 100 kbit/s standard rate. The sample
 * data is good enough to show you the sequence of events,
 * but little else.
 *
 * If you need very specific, time-aligned data, you should
 * use a logic analyzer or sampling oscilloscope.
 */

// assign pin values here
const char sda_pin = 2;
const char scl_pin = 7;

// sampling window
const int data_size = 250;

// array to contain sampled data
byte captured_data[data_size];

// housekeeping booleans
boolean captured;
boolean dumped;

void
setup ()
{
  Serial.begin (57600);
  pinMode (sda_pin, INPUT);
  pinMode (scl_pin, INPUT);
  captured = false;
  dumped = false;
  Serial.println ("Good to go, chief!");
  }

// main loop: waits for SDA to go low, then
// samples the data, then formats and dumps it
// to the serial port.
void
loop ()
{
  while (digitalRead (sda_pin)==HIGH)
  {
  }
  capture();
  if (captured == true && dumped == false)
  {
    serial_dump();
    dumped = true;
  }
}

// captures the data on PORTD and stores it in a global array
void
capture ()
{
  byte tempdata;
  for (int x = 0; x < data_size; x++)
  {
    tempdata = PIND;
    captured_data[x] = tempdata;
  }
  captured = true;
}

// reads the data out of the global array, formats it
// and outputs it to the serial port.
void
serial_dump ()
{
  byte temp;
  Serial.println ("sample, sda, sck");
  for (int x = 0; x < data_size; x++)
  {
    if (x < 10)
    {
      Serial.print ("0");
    }
    if (x < 100)
    {
      Serial.print ("0");
    }
    Serial.print (x);
    Serial.print (",     ");
    temp = bitRead (captured_data[x], sda_pin);
    if (temp == 0)
    {
      Serial.print (0);
    }
    else
    {
      Serial.print (1);
    }
    Serial.print (",   ");
    temp = bitRead (captured_data[x], scl_pin);
    if (temp == 0)
    {
      Serial.println (0);
    }
    else
    {
      Serial.println (1);
    }
  }
}

/* EOF */

