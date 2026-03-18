## Powering the TEC-1G with a UPS Battery Pack

Late in 2025, we found a great little UPS battery pack that with just two lithium batteries, 
was able to power the 1G, with all lights and sounds blazing, for up to 6 hours! The UPS uses a USB-C
cable to charge it and passes power through as well, so you have no need for a 9v power pack. The UPS
supplies a very smooth 5V direct to the power rails, so you don't even need a regulator or heatsink.

![Portable TEC-1G](./TEC-1GinCase-Back.jpg)

Oh, and did I mention that it makes your TEC-1G totally portable!  Couple it with the Official TEC-1G
3D Printed Case, and you have one very slick Z80 machine.

Here are the links to the Tindie Store if you want to get your hands on either product.
https://www.tindie.com/stores/tec1/

The UPS kit is a very simple one, with the UPS module that manages all the smarts of converting USB-C
into a smooth 5v, charging the two 3.7v lithium batteries, and continuing to supply power 
even if the USB-C cable is pulled out! The kit also comes with a couple of JST conectors 
so you can disconnect the Battery Pack safely if needed, and lastly comes with a bunch of 
standoffs to mount the UPS to the main PCB and have a balancing leg of standoffs on the other corner.

![UPS Kit](UPS_Kit.jpg)

Please note that if you are installing this into the official TEC-1G Case, you don't need the
standoffs as the UPS is mounted inside the case, not to the PCB directly. The JST connectors
make it easy to have either of the mounting options.

Speaking of those connectors, you solder one of those (I use the Male on the supply and 
Female on the Device, being the 1G) is to the rectangular solder pads to the right of the Battery Pack pcb,
just next to the mounting holes, marked as UPS+ (red wire) and UPS- (black wire). These are circled in blue
in the picture above. No other connections to the UPS are required, other than the USB-C cable to 
charge up the batteries.

### Installation Guide

From version 1.2 Signature Edition of the PCB, there is a dedicated set of solder points
you use for the UPS, but previous boards can also make use of it, but you have to solder it to
a different location. The important thing to remember is that you have to be able to switch
the power off, and that means the power connections of the UPS have to be before the power switch.
