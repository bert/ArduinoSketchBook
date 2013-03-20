/*
single channel voltmeter
range 0 to 5 Volts in 1023 steps
min max recorder resetable with pushbutton
LCD display driven in "4 bits" mode 
R/W operation is not used; LCD pin 5 must be connected to ground
Reset button (optional) between Arduino's digital port 6 and ground
Analog signal shall be connected to Arduino's analog port 0

no need for additional libraries

no rights, no warranty, no claim just fun
didier longueville, december 2007
*/

// hardware related constants
#define analogPin 0
#define resetPin 6
#define ledPin 13

// lcd related constants
#define nbrCharPerLine 16 // update depending on LCD, must be  at least 16 characters per line
#define nbrLines 2 // must be 2 lines at least
#define left 0
#define right 1
#define invisible 0
#define visible 1

// declare variables
int RS = 12; // registry select LCD pin 4
int EN = 11; // enable LCD pin 6
int DB[] = {5,4,3,2}; // data bits LCD pins 11, 12, 13 and 14
char stringBuffer[nbrCharPerLine + 1]; // this is the working string buffer
int analogValueMax = 0;
int analogValueMin = 1023;

void
setup (void)
{
  // Serial.begin(9600);
  for (int i = 7; i <= 13; i++)
  {
    pinMode (i, OUTPUT);
    digitalWrite (i, LOW);
  }
  pinMode (resetPin, INPUT); // define reset pin
  digitalWrite (resetPin, HIGH); // turn on pullup resistor
  LcdInitialize (); // Initialize lcd
  LcdUnderlineCursor (invisible); // hide underline cursor
}

void
loop (void)
{
  // check if the reset button has been pushed (quick and dirty)
  if (digitalRead (resetPin) == LOW)
  {
     // reset variables
    analogValueMin = 1023;
    analogValueMax = 0;
    // display status
    BufferClear (); // clear buffer
    //                        1234567890123456
    BufferInsertStringValue ("min   now   max ", 1);
    LcdSendString (1); 
    BufferClear (); // clear buffer
    //                        1234567890123456
    BufferInsertStringValue ("-.--  -.--  -.--", 1);
    LcdSendString (2); 
    delay (1000); // time to read
  }
  int analogValue = analogRead (analogPin);
  analogValueMin = min (analogValue, analogValueMin); // record min value
  analogValueMax = max (analogValue, analogValueMax); // record max value
  BufferClear (); // clear buffer
  //                        1234567890123456
  BufferInsertStringValue ("min   now   max ", 1);
  LcdSendString (1); // display converted value on line 1
  BufferClear (); // clear buffer
  //                        1234567890123456
  BufferInsertStringValue (" .     .     .  ", 1);
  BufferInsertNumValue (analogValueMin, 5, 2, 2);
  BufferInsertNumValue (analogValue, 5, 2, 8);
  BufferInsertNumValue (analogValueMax, 5, 2, 14);
  LcdSendString (2); // display converted value on line 2
  // blink status led   
  LedSendPulse (500); 
}

/*
Lcd related functions:
  LcdClearScreen
  LcdCursorHome
  LcdDisplay
  LcdInitialize
  LcdMoveCursor
  LcdScrollDisplay
  LcdSendBits
  LcdSendByte
  LcdSetLine
  LcdUnderlineCursor
*/

void
LcdClearScreen ()
{
  LcdSendCommand (B00000001, 8); // 0x01
}

void
LcdCursorHome ()
{
  LcdSendCommand (B00000010, 8); // 0x02
}

void
LcdDisplay (boolean status)
{
  if (status)
  {
    LcdSendCommand (B00001100, 8); // 0x0C Restore the display (with cursor hidden) 
  }
  else {
    LcdSendCommand (B00001000, 8); // 0x08 Blank the display (without clearing)    
  }
}

void
LcdInitialize ()
{
  delay (40); // specification says > 30ms after power on
  // function set
  LcdSendCommand (B0010, 4); // 0x2
  LcdSendCommand (B00101000, 8); // 0x28
  delayMicroseconds (50); // specification says > 39�s 
  // display on/off control
  LcdSendCommand (B00001110, 8); // 0x0E
  delayMicroseconds (50); // specification says > 39�s 
  // clear display
  LcdSendCommand (B00000001, 8); // 0x01
  delay (2); // specification says > 1.53ms 
  // entry mode set
  LcdSendCommand (B00000110, 8); // 0x06
  delay (2); //  
}

void
LcdMoveCursor (boolean dir, int steps)
{
  for (int j = 1; j <= steps; j++)
  {
    if (dir)
    {
      LcdSendCommand (B00010100, 8); // 0x14
    }
    else
    {
      LcdSendCommand (B00010000, 8);  // 0x10  
    }
  }
}

void
LcdScrollDisplay (boolean dir, int steps, int pause)
{
  for (int j = 1; j <= steps; j++)
  {
    if (dir)
    {
      LcdSendCommand (B00011110, 8); // 0x1E
    }
    else
    {
      LcdSendCommand (B00011000, 8); // 0x18
    }
    delay (pause);
  }
}

// set bits on Lcd and trigger enable pulse
void
LcdSendBits (int value)
{
  digitalWrite (EN, HIGH); 
  delayMicroseconds (5);  // pause 1.4 �s according to datasheet 
  for (int i = 0; i <= 3; i++)
  {
    digitalWrite (i + 9, value & 01); // set bit value
    value >>= 1; // shift bits
  }
  digitalWrite (EN, LOW); // toggle enable line transfer bits 
  delayMicroseconds (5);  // pause 1.4 �s according to datasheet 
}

// send one byte onto LCD
void
LcdSendByte (int value)
{
  constrain (value, 32, 126); // value shall be no less than 32 and no more than 126 (printable characters)
  digitalWrite (RS, HIGH);
  LcdSendBits (value >> 4); // msw
  LcdSendBits (value); // lsw
}

// send command to LCD display
void
LcdSendCommand (int value, int nbrBits)
{
  digitalWrite (RS, LOW);
  if (nbrBits == 8)
  {
    LcdSendBits (value >> 4); // msb
  }
  LcdSendBits (value); // lsb
}

void
LcdSendString (int lineIndex)
{
  constrain (lineIndex, 1, nbrLines); //line index shall be no less than 1 and no more than nbrLines
  if (lineIndex == 1)
  {
    LcdSendCommand (B10000000, 8); // 0x80
  }
  else if (lineIndex == 2)
  {
    LcdSendCommand (B11000000, 8); // 0xC0
  }
  // write working string buffer content onto LCD
  for (int i = 0; i <= nbrCharPerLine; i++)
  {
    LcdSendByte (stringBuffer[i]);    
  }
}

void
LcdSetLine (int lineIndex)
{
  constrain (lineIndex, 1, nbrLines); //line index shall be no less than 1 and no more than nbrLines
  if (lineIndex == 1)
  {
    LcdSendCommand (B10000000, 8); // 0x80
  }
  else if (lineIndex == 2) {
    LcdSendCommand(B11000000,8); // 0xC0
  }
}

void
LcdUnderlineCursor (boolean status)
{
  if (status)
  {
    LcdSendCommand (B00001110, 8); // 0x0E  
  }
  else
  {
    LcdSendCommand (B00001100, 8); // 0x0C
  }
}

/* 
led related functions:
  LedSendPulse
*/
// pulseDelay value is equal to the total pulsing time
void
LedSendPulse (int pulseDelay)
{
  digitalWrite (ledPin, HIGH);
  delay (pulseDelay / 2);
  digitalWrite (ledPin, LOW);
  delay (pulseDelay / 2);  
}

/*
working string buffer functions:
  BufferClear
  BufferInsertNumValue
  BufferInsertStringValue
*/

// clears the content of the working string buffer (global variable)
void
BufferClear ()
{
  for (int i = 1; i <= nbrCharPerLine; i++)
  {
    stringBuffer[i - 1] = 32; // blank buffer content with space characters
  }
}

// insert converted float in the working string buffer (global variable)
void
BufferInsertNumValue (int digitalValue, int fullScaleValue, int decimalPlaces, int decimalSeparatorPosition)
{
  unsigned long integerValue = ((unsigned long)( digitalValue * fullScaleValue) * PowerInteger (10, decimalPlaces)) / 1023;
  int remainder = 0;
  stringBuffer[decimalSeparatorPosition - 1] = 46;
  // decimals
  for (int i = 1; i <= decimalPlaces; i++)
  {
    int asciiCode = (integerValue % 10) + 48;
    stringBuffer[decimalSeparatorPosition + decimalPlaces - i] = asciiCode;
    integerValue /= 10;
  }  
  // integers
  int i = 0;
  do
  {
    i++;
    int asciiCode = (integerValue % 10) + 48;
    stringBuffer[decimalSeparatorPosition - 1 - i] = asciiCode;
    integerValue /= 10;
  } while (integerValue != 0);
}


// update the working string buffer (global variable)
// startingPosition is base 1
void
BufferInsertStringValue (char * s, int startingPosition)
{
  int stringLength = strlen (s)-1;
  for (int i = 0; i <= stringLength; i++)
  {
    stringBuffer[startingPosition + i - 1] = s[i];
  }
}

/*
general purpose functions:
  PowerInteger
*/

int
PowerInteger (int mantissa, int exponent)
{
  int result; // declare result variable
  if (exponent == 0)
  {
    result = 1;
  }
  else
  {
    result = mantissa;
    for (int i = 2; i <= exponent; i++)
    {
      result *= mantissa;
    }
  }
  return result;
}

