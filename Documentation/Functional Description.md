# TEC-1G Functional Description

Also known as "how it works".

When designing the TEC-1G, several principals were kept foremost in mind:

1. Must remain compatible with the Talking Electronics TEC family. Older MONitors must run, unchanged, on the new hardware.
2. Existing peripherals must work, where sensible to do so*. Peripherals such as the DAT board, RAM stack & Crystal Oscillator are now part of the base design, as is the MON select switch. The 8x8 LED display, speech module, relay driver board, and the input output module all work.
3. Must address design limitations inherent in older models e.g. memory wrap, lack of IO port selects, elminate 'flying wires', use robust connectors, offer modern interfacing and expansion options.
4. Must remain simple to understand. This forbade the use of fancy custom chips. Everything is built from simple 74xx series logic, that can be understood at the fundamental level.
5. Through-hole construction to be retained. Must be buildable by a hobbyist without specialist tools.
6. Must enable modern software development - adequate RAM, PC serial link, full QWERTY keyboard are must-haves.
7. Existing TEC software should run with as litte alteration as possible.
8. The whole machine will be produced under an open source licence, freely distributable. Source code, schematics, gerbers etc. will all be made available and fully documented. This represernts the first time TEC system software has been freely distributed.
9. The classic, look, feel, operation and overall "vibe" of the TEC heritage must remain obvious. This heritage has informed the PCB layout, for example.

We think we have achieved these goals and produced a TEC that will offer much more value and usability today, compared to the rather limited original machine.

> We decided not to support the EPROM burner or NVRAM add-ons. EPROMs are now largely replaced with EEPROMS and dedicated programmers like the TL866 are cheap and readily available, and do a much better job. The printer/plotter module no longer has the plotter hardware avilable. NVRAM can be plugged directly into the 1G, however we have not allowed for battery backup at this time. 

# Hardware Design Building Blocks

The TEC-1G can be broken up into several sections or *building blocks*, and each considered individually as to how it plays its role in the overall system.

Together, each building block forms the complete TEC-1G. Some building blocks such as the Matrix Keyboard are optional whilst others are essential.

If your 1G does not work, check each section in the order given below.

A special diagnostic ROM is being produced to assist wih problem solving if your 1G doesn't work correctly when first built. Much like the Commodore 64 'Dead Test' cartridge, the diagnostics software will produce a useful output even wthout any RAM, keyboard chips or the LCD fitted. This will allow for easier troubleshooting and also gives a degree of insight into the machine's operation.

## Power Supply

The TEC-1G is designed to be powered by an external USB +5v source; a USB-B socket for power only, is therefore provided. A classic TEC-1 style linear 7805 based power supply has also been provided, however its use is depreciated.

Power is switched automatically from USB to linear using a switch built into the linear power input socket BJ1 - as long as a plug is inserted into BJ1, linear power mode is selected. BJ1 is centre positive, in keeping with the most common standard for small DC plugpacks.

**The TEC-1G is also designed for DC power input only.** D0, the 1N4002 power diode, is only designed to protect against reverse polarity, and not to act as an AC rectifier.

The power on/off switch and indicator LED complete the power supply section.

Note that we strongly suggest a heatsink on the 7805 and some monitoring of its temperature. The 1G has more chips to power vs. a classic TEC-1, so the current consumption will be higher. The 1G PCB is also more crammed full of goodness so there is also less space for copper fill heatsinking as well. Reducing the input voltage from 12v to 8v or 9v will lower the 7805 temperature noticably.

It is suggested that a drop-in 7805 equivilant switching regulator be considered if USB power is not viable.

The Probe connector supplies power for a logic probe, and serves as the GND hookup point for an oscilloscope or multimeter. Probe can also be used as a feed-in source of an external +5v supply if the 1G is to be powered by an external source.

## CPU Clock Generation

CPU Clock is generated either by a crystal oscillator module, or the classic TEC-1 variable speed oscillator, built around U1, a 4049 hex inverter.

Clock mode is selectable with slide switch SW2 - Slow being TEC-1 variable clock, and FAST being the Crystal module. The selected signal is fed to the Z80 on pin 6, and can be checked with a logic probe or oscilloscope.

MON-3 is written with a 4.0MHz crystal in mind - which is the maximum clock speed of the Z80A CPU. This speed defines the FTDI serial baud rate, 7-seg scanning rate, sound note pitch and duration, etc.

The 1G has not been tested above 4.0MHz but should work OK at up to 8MHz with a Z80H CPU; however FTDI serial, timing etc. will be affected.

## CPU RESET Signal

The traditional R-C network for CPU RESET is offered as standard, however the option exists for using a dedicated power monitor/reset chip - the Dallas DS1233. Further more, the latch chips that rely on the RESET are now driven by a buffered RESET signal, provided by U5D.

RESET is active low, so the signal should be low when the RESET button is pressed, and high at all other times. Reset is fed to pin 26 of the Z80, and via U5D to pin 1 of the 74xx273 latches U13, U16 and U17.

## Z80 CPU

The Z80 CPU, U2, is configured identially to the TEC-1 and is quite conventionally set up. Any Z80 rated to at least 4.0MHz will work - NMOS or CMOS types both work, so Z80A, Z80B, Z80H, Z84C00x parts in 40-pin 5v DIP package, are fine.

An LED - L2 has been added to the HALT signal as an aid to troubleshooting and to provide and easy to monitor output for debugging purposes. the HALT LED should normally NOT light up duing MON-3 opreration.

The programmer can insert HALT opcodes where possible program trouble exists, and if the LED comes on, you can know that program flow reached a HALT point. Pressing a 74c923 key typically resumes program flow. This can be handy for quickly troubleshooting conditional JPs, for example.

## IO Decoders

U10 duplicates the TEC-1's traditional 74LS138 IO decoder, decoding IO ports 00 to 07. However the 1G has the addition of a diode OR-gate formed from D3,D4,D5, D6 and R12. The OR-gate ensures that no unwanted IO address wrap-around occurs. 

U11a and U12 work to decode IO address range F8h to FFh, in support of new onboard peripherals and future expansion.

## Memory Decoder & Memory Managment Unit

### Memory Address Decoders

U3 acts as a memory address decoder, providng select lines for eech 16k memory block.

D1, D2 and R11 form a NOR gate to create a select signal to the MMU indicating the bottom 32k is being accessed.

U4 acts as a 7-input comparitor, detecting if the bottom 2k of memory is being accessed: A11 to A15 must be all low, but only when /SHADOW is also active (also low). This signal is used as another input to the MMU.

If /SHADOW is low, U4 outputs (on pin 19) a low whenever memory in the first 2k 000h to 07ffh is accessed. If /SHADOW is high, the output is always high.

### Memory Management Unit (MMU)

U5A, B & C and U6 A, B & D form a simple MMU controlling the Bank 0, 1 and 3 /Chip Select lines for the memory chips U7 and U8.

Note that Bank 2 is not part of the MMU and appears at address 8000h to BFFFh at all times.

<Insert MMU truth table here>

## Memory Protection

U14 detects memory writes to bank 1 in combination with the PROTECT signal, and either passes or blocks the /WR signal to the RAM chip.

If PROTECT is high, /WR is held high when bank 1 is accessed. If /PROTECT is low, /WR is passed to the memory chip normally.

## ROM and RAM

U7 is the system ROM containing MON-3 or any earlier TEC monitor. This can be any (E)EPROM from 2k to 32k in size, and it is mapped to bank 3 at all times; the first 2k is also mapped to the start of bank 0 (0000h to 07FFh) when shadow is active.

The ROM SIZE Jumpers map the various address lines and the Hi/Low switch allows for TEC-1 Hi/Lo (MON1B/2) selection when a 4k 2732 chip is used; when a 32k chip is used it selects which half of the chip is mapped into Bank 3 (the other half of the chip is inaccessible).

If burning your own ROM, place older monitors at the start of the ROM, from 0000h onwards, so that they will be SHADOWed to 0000h.

U8 is the primary system ram, mapped to banks 0 and 1, and subject to the above SHADOW and PROTECT controls.

U9 is the expansion memory socket, and is mapped always into bank 2. Any memory chip from 8k to 32k can be fitted here; if a 32k chip is fitted then bankswitching using the EXTEND signal selects which half of the memory is mapped into bank 2 (the other half is inaccessible ; flip EEXTEND to ge tto the other half).

EXTEND has no affect if a memory device of less than 32k in size is fitted at U9, or if U9 is left vacant.

## HexPad Encoder

This part of the 1G is unchanged from the TEC-1. The 74c923 scans a matrix of 20 keys and generates a high on KDA when a key is pressed. Keyboard support is also identical to the TEC-1 with DAT board - bit 6 of port 03h holds keypressed status, thus allowing software polled keybord support. for this reason, the famous JMON resistor is not required.

Shift key support functions identially to the TEC-1, with bit 5 of port 00 reading a 0 when Shift is pressed, and a 1 if not.

Fulisik LEDs is a new feature of the 1G - if using Gateron keyswitches, LEDs can be fitted to backlight the keys; JP5 controls the backlights on/off. Resistor packs RN4, RN5, RN6 and 330R resistors R5 and R15 complete the LED current limiting. Refer to the assembly guide for suggested LED colours for each switch.

Note that RN4,5,6 & R5 and 15 can be omitted if not using backlighting.

## 7 Segment Display Unit

This unit is also largely unchanged from the TEC-1.

Latch chips U16 and U17 drive the 7 segment displays in a software-driven, scanned fashion. Each individual display is briefly selected and it's segments illuminated. After a brief pause, software then moves to the next display and repeats the process until all are lit. A loop repeats the whole sequence for as long as required. The illusion of constantly lit displays relies on a fast scanning speed and human persistance of vision. 

U17 drives the individual segments, whilst U16 selects the digits and also drives the speaker and FTDI Serial Transmit.

A simple transistor buffer ensures each display has an equal brightness level; no current limiting resistors are required as the output current of the latch chips is not sufficient to over-drive the LEDs.

The speaker features an LED to indicate when a sund is being produced, and can also act as a simple visual status indicator when driven by software.

A new 1G featue, is that pin 1 of the latch chips is driven by the buffered RESET signal. This ensures the displays start up blank, and also blane when RESET is pressed.

## LCD Connector

The 1G uses a similar interface idea to the TE DAT board, with support for any HD44780 chipset based LCD screen. However, we have settled on using a 40x4 display instead of the DAT's 16x2. The larger size screen offers more display space and these days is less expensive than the original 16x2's were in the 1990's.

Backlight power is also supplied, but can be disbled by cutting a marked trace on the rear of the 1G PCB. 'solder blob' pads have been provided to restore power if you wish to un-do this decision later - just solder the pads back together with a small blob of solder.

At the design level, the 1G inverts the CPU's /RD signal to generate the R/W signal for the LCD. This results in more favourable timing vs. the DAT board's use of an R-C network and the /WR signal. The LCD is more reliably detected and less prone to corruption using this method. We borrow one spare 4049 inverter gate from U1 for this purpose.

MON-3 will work with ANY size LCD e.g. 16x1, 16x2, 20x2 etc. but we strongly suggest that a 40x4 is used to obtain full functionality.

JMON will work with a 16x2 or 40x4 connected, with no issues. The HD44780 chipset is designed such that it's memory layout is identical regardless of the physical screen size.

## System Latch

A new 1G feature, is the system latch. It is an 8-bit write-only port that supplies 8 individual control signals to various parts of the 1G mainboard. The system latch is reset to 00h on power up or RESET.

U13 - 74xx273 provides the System Latch functionality and is written to at IO port FFh

The System latch controls /SHADOW,  PROTECT and EXPAND signls, as well as Caps Lock status for the Matrix keyboard. The status of the System Latch is reflected at all times in hardware by the STATUS LED Bar. Note that bit 0 is active low.

MON-3 routines manage the latch for you, however you can write to port FFh direclty if so desired.

## System Input

Another enhanced 1G feature, is the System Input port. Like the System Latch, it is an 8 bit port, but this port is read-only.

U18 - 74xx373 provides the Input port functionality and is readable from IO port 03

The Sytem Input port is used to read the status of the critical bits of the System Latch, as well as read the config dipswitch, GIMPUT and FTDI Serial Receive bits, and to detect the presence of a Cartridge (future feature).

## FTDI Port

The FTDI port acceps a standard FTDI module (purchased separately) that converts TTL signals from the 1G into RS-232, or, USB. This provides a simple software driven interface to a PC or a terminal, for data transfer or creating a 'dumb terminal'.

FTDI replaces JMON's tape routines as a backup system; MON-3 supports data transfer using Intel HEX format files and can also provide a full blown RS-232 serial terminal interface.

FTDI speed is limited to 4800bps as it is entirely software-driven and also relies on a 4.0MHz CPU clock for timing purposes. FTDI will not work with the TEC-1 slow clock.

## Matrix Keyboard and Joystick

Also new to the 1G, is a software scanned full QWERTY keyboard and two button joystick port.

U19 - 74xx245 buffers(not latches!) the keyboard matrix and is readable at IO port FEh; the matrix is scanned by use of a clever trick using the Z80 OUT (C),A instruction. In reality that instruction also places the contents of the B register onto A8-A15, creating effectively a 16 bit port.

Transistor buffers Q8 through Q15 buffer the address lines into the matrix, and any pressed key transmits that signal into U19 latch. note that a keypress is read as a 0 in any bit. Resistor arrays RN2 and RN3 ensure the no-pressed state is read as a logic 1.

The matrix connector also has facility for the Caps Lock signal to light a LED, and the Reset signal for an external reset switch.
