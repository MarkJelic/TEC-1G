# Simple Clock Demo for TEC-1G GPIO Real Time Clock module

A basic example of working with the DS1302 RTC chip to display a simple clock on the 7-seg displays and also the LCD.

The supplied HEX file loads the program at $4000 (Use the Intel HEX Load function to load the program into your TEC).

## Program Features

The program uses the clock in 12 hour mode, hence the AM/PM display on the LCD. A 24 hour option also exists in the DS1302 chip, however this is not used in this program.

If the F key is pressed on the hexpad, the TEC will HALT - the HALT LED will light. Pressing any key resumes normal operation. Note that if you HALT the TEC for several seconds (or more), the updated time will be displayed upon resuming, proving that the DS1302 is working independently even if the TEC itself is HALTed.

## Setting the Time
Pressing + increments the Hour (and rolls over AM/PM)

Pressing 0 increments the Minute (rolling over at 60)

Pressing 1 resets the seconds to 00.

With a minimal number of button presses, the clock can be set quite accurately. The best way to get the seconds right is to set the clock 1 minute fast, then reset the seconds to 00 as soon as the minute of the reference time source ticks over.

## Notes
The clock is reset to 12:00.00 PM each time the program restarts, and will then 'tick' normally until the TEC is reset.

This simple demonstration program doesn't display the calendar (date or year). This function could be added as an exercise in extending the program.

The program assumes a DS1302 clock chip exists on port $FC. If no clock chip exists, a random (and probably invalid) time will be displayed.
