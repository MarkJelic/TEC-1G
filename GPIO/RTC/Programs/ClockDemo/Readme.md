# Simple Clock Demo for TEC-1G GPIO Real Time Clock module
A basic example of working with the GPIO RTC card (DS1302 RTC chip) to display a simple clock on the 7-seg displays and also the LCD. This program does not use the MON3 API's - in fact it is being used to develop the API's; a future version will be converted to use the APIs once they are completed.

The supplied HEX file loads the program at $4000 (Use the Intel HEX Load function to load the program into your TEC).

## Program Features
The program uses the clock in either 12 or 24 hour mode, which is user-switchable at any time by pressing '2' on the hexpad.

Both the 7-seg and the LCD display informtion - the 7-seg being limited to the time only.

In 12 hour mode, PM is indicated by the '.' being lit on the minutes digit of the 7-seg display.

If the F key is pressed on the hexpad, the TEC will HALT - the HALT LED will light, the 7-seg displys will cease udating the the LCD disply will stop on the time that HALT occurred. Pressing any key resumes normal operation. Note that if you HALT the TEC for several seconds (or more), the updated time will be displayed upon resuming, proving that the DS1302 is working independently even if the TEC itself is HALTed.

## Setting the Time
\+ increments the Hour (and rolls over AM/PM, if 12 hour mode, sets 00-23 if 24 hour mode)

0 increments the Minute (rolling over at 59 minutes)

1 resets the seconds to 00

2 toggles 12/24 hour mode

With a minimal number of button presses, the clock can be set quite accurately. The best way to get the seconds right is to set the clock 1 minute fast, then reset the seconds to 00 as soon as the minute of the reference time source ticks over.

## Setting the Calendar
\- sets day of week Monday through Sunday

4 sets Date

5 sets Month

6 sets Year - 2023 to 2122

Each field 'wraps around' once maximum is reached. At this stage is is necessary to cycle through 100 years to get 'back' to the correct Year.

## Notes
The program assumes a DS1302 clock chip exists on port $FC. If no clock chip exists, a random (and probably invalid) time will be displayed.

## Changelog
1.2 - add full 12/24 hour support, ability to set calendar day/date/month/year

1.1 - add Calendar support, ptial 12/24 hour support

1.0 - first release
