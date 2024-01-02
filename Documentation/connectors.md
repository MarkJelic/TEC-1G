# TEC-1G Connectors
This is a list of TEC-1G expansion port connectors and their respective pin-outs.

A note on PCB connector orientation markings. Pin 1 is identified as the pin that is not within the solid connector outline on the silkscreen, but instead has a small L on one corner, or is individually outlined. Pin 1 also has a square solder pad, the other pins are round. Lastly, the label of the connector (eg. J1) is usually placed as close as possible to Pin 1.

## J1 - Z80 Bus Vertical Connector
Follows the Z80 CPU pinout i.e. pin 1 - A11, pin 2 - A12, etc. Except for one small difference; Pin 28 is NOT the usual Refresh pin, since that function is largely not used in any modernised Z80 computers. Pin 28 has instead been repurposed for the use of the GLCD as an Inverted Read control line from the Z80. 

## J2 - Z80 Bus Horizontal Connector
Follows the Z80 CPU pinout i.e. pin 1 - A11, pin 2 - A12, etc.  This connector should ideally be a female connector to allow for direct connection of expansion cards, or the X4 Expansion Board, and IDC cables can still be connected if the user desires.

## J3 - TEC Expander
This 20 pin port is an extension of the 16 pin IO port of the Southern Cross Computer. Any peripherals made for the SCC can be plugged into the left (first 16) pins and work as intended.

The extra 4 pins have been added so peripherals like the Speech Board can be re-implemented fully, using only a single connector.

## J4 - MATRIX Keyboard
This port is for connecting the external Matrix Keyboard & Joysticks.

## J5 - FTDI
FTDI offers two options - pins orientated left-to-right, and right-to-left. This is because there are two common types of FTDI module - fit the connector that suits your type of FTDI module. Pin orientations are clearly maked on the PCB silkscreen.

DTR - not used<br>
RX - Receive Data<br>
TX - Transmit Data<br>
+5v - not used<br>
CTS - not used<br>
GND - Common Ground<br>

## J6 - IObus
Schematic Rev 1.6+

1 - GLCD-07 - Inverted Port 07h select - Reserved for future Graphical LCD<br>
2 - /PORT-F8 - Port F8h select<br>
3 - /PORT-F9 - Port F9h select<br>
4 - /PORT-FA - Port FAh select<br>
5 - /PORT-FB - Port FBh select<br>
6 - /PORT-FC - Port FCh select<br>
7 - /PORT-FD - Port FDh select<br>
8 - CART - CARTridge Detect<br>
9 - GIMP - General Input<br>
10 - /GLCD-07 - Port 07h select - Reserved for future Graphical LCD<br>

Ports F8h to FDh are free for any use by the user. Note that Ports F8h and F9h are also available on the TEC Expansder Connector.

## J7 - MEMbus
Schematic Rev 1.6+

1 - +5v
2 - /MS8 - Memory Bank 3 Select - does not observe SHADOW<br>
3 - /ROM_CS - Observes SHADOW - First 2K and Bank 3<br>
4 - /SHADOW<br>
5 - /MS2 - Memory Bank 0 Select - does not observe SHADOW<br>
6 - /MS4 - Memory Bank 1 Select - does not observe SHADOW<br>
7 - /RAM_CS - Observes SHADOW - Banks 0 and 1 only<br>
8 - PROTECT<br>
9 - /MS6 - Memory Bank 2 Select - does not observe SHADOW<br>
10 - EXPAND<br>
11 - FF-D3 - System Latch bit 3<br>
12 - FF-D4 - System Latch bit 4<br>
13 - FF-D5 - System Latch bit 5<br>
14 - FF-D6 - System Latch bit 6<br>
15 - GND<BR>

## J8 - G.INPUT
1 - GND<br>
2 - +5v<br>
3 - G.INPUT signal - SIMP-3 bit 5<br>

## J9 - JOYSTICK
The joystick port adheres to the ATARI joystick standard, supporting two fire buttons.

1 - Up<br>
2 - Down<br>
3 - Left<br>
4 - Right<br>
5 - <br>
6 - Button A<br>
7 - Button B<br>
8 - Common<br>
9 - <br>

## J10 - GPIO
This is where the SD Card, Real Rime Clock, and General Input/Output cards will be stacked.

## PROBE
This set of connectors have a 2 pronged purpose; The outer male pins are for connecting Oscilloscope or Multimeter probes to, for measuring and testing purposes. The pair of inner pins, fitted with a 2-pin female header, is used for alternate power delivery, as well as a power take-off point for the boards connected to the J10 - GPIO connector.

# Connector <-> IO Port assignment
This chart shows whih Z-80 I/O port select lines are availalbe on each I/O connector.

| Connector | F8h | F9h | FAh | FBh | FCh | FDh | FEh | FFh |
| -- | -- | -- | -- | -- | -- | -- | -- | -- |
| IObus | YES | YES | YES | YES | YES | YES | -- | -- |
| TEC Expander | YES | YES | -- | -- | -- | -- | -- | -- |
| GPIO | -- | -- | -- | YES | YES | YES | -- | -- |
| TEC-1G | -- | -- | -- | -- | -- | -- | YES* | YES* |

\* Means used on the TEC-1G mainboard internally. Not available for expansion boards.

