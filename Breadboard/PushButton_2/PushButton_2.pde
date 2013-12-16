/*!
 * \file PushButton_2.pde
 *
 * \brief Push button with sticky state.
 *
 * Control a LED using a push button.
 *
 * \warning Connect a LED at pin 13 and a push button to analog pin 7.
 */

#define LED 13
#define BUTTON 7

int val = 0;
int oldVal = 0;
int state = 0;

void
setup ()
{
 pinMode (LED, OUTPUT); 
 pinMode (BUTTON, INPUT);
}

void
loop ()
{
  val = digitalRead (BUTTON);
  if (val == HIGH && oldVal == LOW)
  {  
    state = 1 - state;
    delay (10);
  }
  oldVal = val;
  if (state == 1)
  {
    digitalWrite (LED, HIGH);
  }
  else
  {
    digitalWrite (LED, LOW); 
  }
}
