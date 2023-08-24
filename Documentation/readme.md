# Full Documentation - Coming Soon™

When designing the TEC-1G, several principals were kept foremost in mind:

1. Must remain compatible with the Talking Electronics TEC family. Older MONitors must run, unchanged, on the new hardware.
2. Existing peripherals must work, where sensible to do so. Peripherals such as the DAT board, RAM stack & Crystal Oscillator are now part of the base design.
3. Must address design limitations inherent in older models e.g. memory wrap, lack of IO port selects, elminate 'flying wires', use robust connectors, offer modern interfacing and expansion options.
4. Must remain simple to understand. This forbade the use of fancy custom chips. Everything is built from simple 74xx series logic, that can be understood at the fundamental level.
5. Through-hole construction to be retained. Must be buildable by a hobbyist without specialist tools.
6. Must enable modern software development - adequate RAM, PC serial link, full QWERTY keyboard are must-haves.
7. Existing TEC software should run with as litte alteration as possible.
8. The whole machine will be produced under an open source licence, freely distributable. Source code, schematics, gerbers etc. will all be made available and fully documented. This represernts the first time TEC system software has been freely distributed.
9. The classic, look, feel, operation and overall "vibe" of the TEC heritage must remain obvious. This heritage has informed the PCB layout, for example.

We think we have achieved these goals and produced a TEC that will offer much more value and usability today, compared to the rather limited original machine.

## Major Features

- Full TEC-1 hardware and software compatability; runs all previous MONitors without modification
- Flexible memory options; 32K RAM, 16k ROM in default configuration. Up to 64k RAM + 16k ROM supported.
- Support for multiple configuration options and memory types from 2k to 32k memory devices
- RAM write protection for improved software development
- Shadow Memory and bank switching capabilities
- 20x4 LCD screen as primary display device
- Diagnostic & LED bar indicator for system state
- Z80A CPU running at 4.0MHz; 'slow' clock support for older monitors retained
- Full QWERTY MATRIX keyboard & joystick options
- Upgraded key options for onboard hex keypad; supports Gateron Low Profile switches with optional backlighting, as well as standard 12mm tactile buttons
- Improved RESET circuit for reliable start up and system stability
- USB B or 9-12v AC/DC power sources
- Serial interface using an optional FTDI/FT232 adaptor for USB communication with a PC or terminal
- Future support for SD card mass storage interface
- Native Z-80 expansion bus connectors supporting a full range of peripherals
- 'TEC-Deck' expansion connectors for future daughterboards
- 'TEC Expander' port for compatability with existing TEC peripherals
- HALT status LED

## Documentation Files

[Circuit Functional Description](Functional%20Description.md)

Z80 IO Ports](ioports.md)

[Memory Map](memmap.md)

[Expansion and Device Connectors](connectors.md)
