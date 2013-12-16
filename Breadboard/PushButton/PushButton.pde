/*!
 * \file PushButton.pde
 *
 * \brief Control a LED using a push button.\n
 * If you hold the button, the LED will glow.
 *
 * \warning Connect a LED at pin 13 and a push button to analog pin 7.
 */

#define LED 13
#define BUTTON 7

void
setup ()
{
  pinMode (LED, OUTPUT); 
  pinMode (BUTTON, INPUT);
}

void
loop ()
{
  digitalWrite (LED, digitalRead (BUTTON));
}


