/*!
 * \file ADXL-335_1.pde
 *
 * \brief Log the values of X-, Y- and Z-axis to Serial.
 *
 * \author Rasool Talib Husainy.
 *\

const int x = A1;
const int y = A2; 
const int z = A3;

void
setup ()
{
  Serial.begin(250000); 
}

void
loop ()
{
  int x_adc_value;
  int y_adc_value;
  int z_adc_value; 

  x_adc_value = analogRead (x);
  y_adc_value = analogRead (y);
  z_adc_value = analogRead (z);

  Serial.print ("x = ");
  Serial.print (x_adc_value);
  Serial.print ("\t\t");
  Serial.print ("y = ");
  Serial.print (y_adc_value);
  Serial.print ("\t\t");
  Serial.print ("z = ");
  Serial.print (z_adc_value);
  Serial.print ("\t\t");

  Serial.print ("\n\n");
  delay (10);
}
