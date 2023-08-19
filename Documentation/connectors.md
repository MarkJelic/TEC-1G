todo: renumber to suit release PCB.


# TEC-1G Connectors

This is a list of TEC-1G expansion port connectors and their respective pin-outs.

A note on PCB connector orientation markings. Pin 1 is identified as the pin that is not within the solid connector outline on the silkscreen, but instead has a small L on one corner, or is individually outlined. Pin 1 also has a square solder pad, the other pins are round. Lastly, the label of the connector (eg. J1) is usually placed as close as possible to Pin 1.

## J1 - Z80 Bus Vertical Connector

Follows the Z80 CPU pinout i.e. pin 1 - A11, pin 2 - A12, etc. Except for one small difference; Pin 28 is NOT the usual Refresh pin, since that function is largely not used in any modernised Z80 computers. Pin 28 has instead been repurposed for the use of the GLCD as an Inverted Read control line from the Z80. 

## J2 - Z80 Bus Horizontal Connector

Follows the Z80 CPU pinout i.e. pin 1 - A11, pin 2 - A12, etc.  This connector should ideally be a female connector to allow for direct connection of expansion cards, or the X4 Expansion Board, and IDC cables can still be connected if the user desires.

## J3 - TEC Expander

This 20 pin port is an extension of the 16 pin IO port of the Southern Cross Computer. Any peripherals made for the SCC can be progged into the left (first 16) pins and work as intended. The extra 4 pins have been added so peripherals like the Speach Board can be re-implemented fully.

## J4 - MATRIX Keyboard

## J5 - FTDI
FTDI offers two options - pins orientated left-to-right, and right-to-left. This is because there are two common types of FTDI module - fit the connector that suits your type of FTDI module. Pin orientations are clearly maked on the PCB silkscreen.

DTR - not used<br>
RX - Receive data<br>
TX - Transmit Data<br>
+5v - not used<br>
CTS - not used<br>
GND - Common Ground<br>

## J6 - IObus

## J7 - MEMbus

## J8 - GIMPUT

1 - GND<br>
2 - +5v<br>
3 - GIMP signal to SIMP-3 (LOL!)<br>

## J9 - JOYSTICK

The joystick port adheres to the ATARI joystick standard, supporting two fire buttons.

## J10 - GPIO

This is where the SD Card, Real Rime Clock, and General Input/Output cards will be stacked

## PROBE

This set of connectors have a 2 pronged purpose; The outer male pins are for connecting Oscilliscope or Multimeter probes to, for measureing and testing purposes. The pair of inner pins, fitted with a 2-pin female header, is used for alternate power delivery, as well as support for the boards connected to the J10 - GPIO connector.
