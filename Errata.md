# Errata

## 31/10/23: Anniversary Edition (Blue and Purple)

Unfortunately a mistaken connection in the schematic (from v1.09) has made its way through to the PCBs which will stop the LCD from being operable. This was found by Tony Leff which I appreciate him finding it so quickly.

There is a relatively easy fix that entails cutting two traces on the back of the PCB, near the LCD Backlight jumper (shown in RED), and then soldering a little bodge wire between the cut traces, shown in BLUE. See the illustration below.

![TEC-1G Errata 1 - LCD Enable](/pictures/Production-1_Bodge-1_S.jpg)

For those with a little less dexterity with the soldering iron, after cutting the traces as marked in RED, you can solder a longer wire (shown in BLUE) between Pin 8 of U6 NAND and Pin 6 of the LCD connector.

![TEC-1G Errata 1 - LCD Enable](/pictures/Production-1_Bodge-1_L.jpg)
