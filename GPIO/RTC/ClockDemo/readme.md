# Simple Clock Demo for TEC-1G GPIO Real Time Clock module

A basic example of working with the DS1302 RTC chip to display a simple clock on the 7-seg displays and also the LCD.

The clock is reset to 12:00.00 PM each time the program restarts, and will then 'tick' normally until the TEC is reset.

If the F key is pressed on the hexpad, the TEC will HALT - the HALT LED will light. Pressing any key resumes normal operation. Note that if you HALT the TEC for several seconds (or more), the updated time will be displayed upon resuming, proving that the DS1302 is working independently even if the TEC itself is HALTed.

This simple demonstration program doesn't allow the clock to be set while running, nor does it display the calendar (date or year). These functions could be added as an exercise in extending the program.

Note: The program assumes a DS1302 clock chip exists on port $FC. If no clock chip exists, a random (and probably invalid) time will be displayed.