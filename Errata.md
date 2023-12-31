# Errata

## (1) Anniversary (Blue, Purple and Black) & Open Source (v1.01 Green) Editions
1/Nov/2023: Unfortunately a mistaken connection in the schematic (from v1.09 to v1.12) has made its way through to the PCBs which will stop the LCD from being operable. This was found by Tony Leff which I appreciate him finding it so quickly.

It would have been a relatively easy fix... But the +5v flood fill on the front of the PCB makes it more tricky and it is CRITICAL that the fix is done in the following order.

1. U6 Pin 8, front of board: Cut 3 traces as circled
2. LCD pin 6, front of board: Cut 2 traces as circled
3. LCD pin 6, back of board: Cut 1 trace as circled
NOTE: For Open Source (v1.01 Green) Editions, these traces will have been cut for you before being shipped out.)

![TEC-1G Errata 1 - U6-Pin8](/pictures/PCB-Fix_U6P8.jpg)
![TEC-1G Errata 1 - U6-Pin8](/pictures/PCB-Fix_LCDp6_Top.jpg)
![TEC-1G Errata 1 - U6-Pin8](/pictures/PCB-Fix_LCDp6_Bot.jpg)

4. Test there are NO connections from U6pin8 and LCDpin6 to +5v
5. Assemble TEC-1G as normal
6. After socket is in U6 and header is in LCD, solder a longer wire (shown in BLUE) between Pin 8 of U6 NAND and Pin 6 of the LCD connector.
NOTE: As of 15/Dec/2023, a length of Kynar wire is supplied with all Open Source (v1.01 Green) PCBs.

![TEC-1G Errata 1 - LCD Enable](/pictures/Bodge_Wire.jpg)
<br>
<br>
<br>
## (2) Anniversary (Blue, Purple and Black) & Open Source (v1.01 Green) Editions
2/Nov/2023: The silkscreen at the top left identifying the Probe location has the polarity of the voltages reversed.
GND should be to the right, and +5V is to the left, closer to the USB connector.
Please use a marker to correct this potentially component damaging error.

![TEC-1G Errata 2 - Probe Polarity](/pictures/Probe_Silkscreen.jpg)
<br>
<br>
<br>
## (3) Special Edition (Black) Only
15/Dec/2023: The silkscreen for the <b>bottom</b> Disco LED is reveresed from the correct polarity.
It should read, from top to bottom, R K G B

This means you simply flip the LED around before inserting and soldering it. The cathode (long pin) should be the second pin from the top.

![TEC-1G Errata 3 - DiscoLED](/pictures/DiscoLED_Silkscreen.jpg)
