# Errata

## 1/Nov/23: Anniversary Edition (Blue and Purple and Black)

Unfortunately a mistaken connection in the schematic (from v1.09 to v1.12) has made its way through to the PCBs which will stop the LCD from being operable. This was found by Tony Leff which I appreciate him finding it so quickly.

It would have been a relatively easy fix... But the +5v flood fill on the front of the PCB makes it morE tricky and it is CRITICAL that the fix is done in the following order.

1. U6 Pin 8, front of board: Cut 3 traces as circled
2. LCD pin 6, front of board: Cut 2 traces as circled
3. LCD pin 6, back of board: Cut 1 trace as circled

![TEC-1G Errata 1 - U6-Pin8](/pictures/PCB-Fix_U6P8.jpg)
![TEC-1G Errata 1 - U6-Pin8](/pictures/PCB-Fix_LCDp6_Top.jpg)
![TEC-1G Errata 1 - U6-Pin8](/pictures/PCB-Fix_LCDp6_Bot.jpg)

4. Test there are no connections from U6pin8 and LCDpin6 to +5v
5. Assemble TEC-1G as normal
6. After socket is in U6 and header is in LCD, solder a longer wire (shown in BLUE) between Pin 8 of U6 NAND and Pin 6 of the LCD connector.

![TEC-1G Errata 1 - LCD Enable](/pictures/Bodge_Wire.jpg)
