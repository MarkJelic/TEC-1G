# Errata

## TEC-1G Full Kit - Z80Bus Headers
2/Jun/2024: We have had a rethink on the right-most Z80Bus connector, found on the right edge of the PCB. I used to supply a right-angled version of that connector, allowing you to plug in directly any Z80Bus cards and have them parallel to the main PCB... Which is fine if you keep the TEC-1G flat on a table. But with the advent of cases being 3D printed to elevate and ange the PCB to face you, having a Z80Bus card floating out to the right, unsupported, was not a good idea. Hence, we changed it to a Vertical style of IDC connector. This still allows you to plug in a Z80Bus card directly, without the strain of gravity on the pins. Also, if you are using an X4 Board, then you can easily use an IDC cable to connect the two PCBs, and have the X4 lay flat on the table.

Also, the Z80Bus connector set next to the Z80 does not need to be an IDC socket as such, but the outer edge one *does*, to ensure firm connections of cards or cables. The inner one is only used for TEC Deck cards which use simple pin headers. Hence, please install the 40 pin headers supplied in the kit, as pictured below.

The silkscreen on the board will be updated in future print runs of the PCB.

![Z80Bus Headers](/pictures/Z80Bus_Headers.jpg)


## TEC-1G Full Kit - FTDI Module
5/May/2024: The FTDI Module that provides serial via USB connection to your personal computer, is able to be used in both 3.3v and 5v systems with just a simple change of jumper settings on the module. It has come to light that these are by default jumpered to 3.3v and if installed on the TEC-1G in 3.3v mode, communications will be garbled and could damege the FTDI module. Please change those jumpers over to the 5v option before attaching it to the TEC-1G.

I recommend you hard-solder the module into place by first desoldering the installed RA pins, then soldering a new set of straight through pins on the underside, then attaching it to the TEC-1G main board. I also recommend hard-coupling the 5v option with little jumper wires. See the photo below for clarity. You should also cut off the 6 pins that allow programming of the FTDI module, to ensure clearance from any GPIO board installed above it.
![FTDI_Module-Installed](https://github.com/MarkJelic/TEC-1G/assets/13119623/e6274ab8-48a5-4dfd-b4b8-a8880055fb49)


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
