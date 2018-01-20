/*!
 * \file Shields/ISP_test_LED/ISP_test_LED.pde
 *
 * \brief Turns on LEDs on for one second, then off for one second,
 * repeatedly.
 */

#define LED_PROG 7
#define LED_ERROR 8
#define LED_PULSE 9
#define LED_BUILTIN 13

/*!
 * \brief The setup function runs once when you press reset or power the
 * board.
 */
void
setup ()
{
  /* Initialize digital pins as an output. */
  pinMode (LED_BUILTIN, OUTPUT);
  pinMode (LED_PROG, OUTPUT);
  pinMode (LED_ERROR, OUTPUT);
  pinMode (LED_PULSE, OUTPUT);
}

/*!
 * \brief The loop function runs over and over again forever.
 */
void
loop ()
{
  digitalWrite (LED_BUILTIN, HIGH);
  digitalWrite (LED_PROG, HIGH);
  digitalWrite (LED_PULSE, HIGH);
  digitalWrite (LED_ERROR, HIGH);

  delay (1000);

  digitalWrite (LED_BUILTIN, LOW);
  digitalWrite (LED_PROG, LOW);
  digitalWrite (LED_PULSE, LOW);
  digitalWrite (LED_ERROR, LOW);

  delay (1000);
}

/* EOF */
