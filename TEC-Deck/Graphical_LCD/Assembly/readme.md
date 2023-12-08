# GLCD Assembly Instructions

## List of Parts

| QTY | Part | Usage |
|---|---|---|
| 1	| 330R/470R Resistor	| Brightness |
| 1	| SPDT Micro Slide Switch	| Backlight |
| 1	| 10K Var. Resistor (V)	| Contrast |
| 1	| 20pin Round Pin Strip Male| LCD Screen |
| 1	| 20pin Round Pin Strip Female | PCB |
| 1	| 10pin Square Pin Strip Male | IOBus |
| 1	| 16pin Square Pin Strip Male | MEMBus |
| 1	| 20pin x 2row Square Pin Strip Male | Z80Bus |
| 2	| Nylon M3 Screw | Under PCB |
| 2	| 10mm Nylon Standoffs | Under LCD Screen |
| 2	| Nylon Nuts | Top of LCD Screen |
| 1	| 128x64 Graphical LCD | You know, the thing... |

!(Parts Photo)[./TEC-1G_GLCD_Kit.jpg]

## Assembly Order

1. First step is to solder in the connections the GLCD makes to the TEC-1G; The Z80Bus, MEMBus and the IOBus.

  The best way to ensure the pins will be perfectly vertical and line up with the sockets on the motherboard is to actually insert those pins into the sockets
  that are on the TEC-1G motherboard. Fit the 10x square-pinned strip into the IOBus sockets. Fit the 16x square-pinned strip into the MEMBus. 
  And finally fit the double 20x square-pinned strip into the 40pin Z80Bus socket.

With these in place, plonk the GLCD PCB on top of the ends of the pin strips, and then solder them all into place before attempting to remove the
GLCD board for the remainder of the component placement and soldering.

2. With the GLCD Card removed from the TEC-Deck, you can finish soldering in the 20pin female machined strip, then the 470 ohm resistor,
   the micro slide switch and finally the vertical contrast potentiometer.

3. The last thing to solder is the male 20pin round machined strip onto the GLCD screen itself.

4. Before connecting the GLCD to the PCB, you need to have the supports it needs, installed. Two M3 screws go through the bottom of the GLCD PCB.
They may need cutting down and if quired, just use a pair of fine side-cutters. They screw into the 5mm offsets on from the underside of the GLCD PCB.

5. Now it is time to plug the GLCD into the socket on the Card and then secure the GLCD down with the two M3 Nuts. You are done.

Install the GLCD Card onto the Tec_Deck and start programming. Some test code can be found here.
