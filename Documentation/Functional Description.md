# TEC-1G Functional Description

Also known as "how it works".

The TEC-1G can be broken up into several sections, and each considered as to how it plays its role in the overall system

## Power Supply

A classic TEC-1 type linear 7805 based power supply has been provided, however we strongly suggest a heatsink on the 7805 and some monitoring - the 1G has more chips to power so the current consumption will be higher than a classic TEC-1. It is suggested that a drop-in 7805 equivilant switching regulator or USB power be considered instead.
The TEC-1G can also be powered by USB; a USB-B socket is provided. Power is switched automatically from USB to linear using a switch built into the linear power input socket BJ1 - as long as a plug is inserted into BJ1, linear power mode is selected.
The power on/off switch and indicator LED complete the power supply.
The Probe connector supplies power for a logic probe, and serves as the GND hookup point for an oscilloscope or multimeter. Probe can also be used as a feed-in source of an external +5v supply if the 1G is to be powered by an external source.

## CPU Clock Generation

CPU Clock is generated either by a crystal oscillator module, or the classic TEC-1 variable speed oscillator, built around U1, a 4049 hex inverter.

Clock mode is selectable with slide switch SW2 - SLOW being TEC-1 variable clock, and FAST being the Crystal module.

MON-3 is written with a 4.0MHz crystal in mind - which is the maximum clock speed of the Z80A CPU. This speed defines the FTDI serial baud rate, 7-seg scanning rate, sound note pitch and duration, etc. The 1G has not been tsted above 4.0MHz but should work OK at up to 8MHz with a Z80H CPU; however FTDI serial, timing etc. will be affected.

## CPU RESET Signal

The traditional R-C network for CPU RESET is offered as standard, however the option exists for using a dedicated power monitor/reset chip - the Dallas DS1233. Further more, the latch chips that rely on the RESET are now driven by a buffered RESET signal, provided by U5D.

## Z80 CPU

The Z80 is configured identially to the TEC-1 and is quite conventional.
An LED - L2 has been added to the HALT signal as an aid to troubleshooting and to provide and easy to monitor output for debugging purposes. The programmer can insert HALT opcodes where possible program trouble exists, and if the LED comes on, you can know that program flow reached a HALT point. Pressing a 74c923 key resumes program flow. This can be handy for quickly troubleshooting conditional JPs, for example.

## IO Decoders

U10 duplicates the TEC-1's traditional 74LS138 IO decoder, decoding IO ports 00 to 07. However the 1G has the addition of a diode OR-gate formed from D#,D4,D5 and D6 +R12. The OR-gate ensures that no unwanted IO address wrap-around occurs. 
U11a and U12 work to decode IO address range F8h to FFh, in support of new onboard peripherals and future expansion.

## Memory Decoder & Memory Managment Unit

### Memory Address Decoders

U3 acts as a memory address decoder, providng select lines for eech 16k memory block.
D1, D2 and R11 form a NOR gate to create a select signal to the MMU indicating the bottom 32k is being accessed.
U4 acts as a comparitor, detecting if the bottom 2k of memory is being accessed, but only when /SHADOW is active. This signal is used as another input to the MMU.
If /SHADOW is low, the comparitor outputs a low whenever memory in the first 2k 000h to 07ffh is accessed. If /SHADOW is high, the output is always high.

### Memory Management Unit (MMU)

U5A, B and C and U6 A, B and D form an MMU controlleing the Bank 0, 1 and 3 Chip Select lines for the memory chips.

Note that Bank 2 is not part of the MMU and appears at address 8000h to BFFFh at all times.

## Memory Protection

U14 detects memory writes to bank 1 in combination with the PROTECT signal, and either passes or blocks /WR to the RAM chip.
If PROTECT is high, /WR is held high at all times using bank 1 accesses only. If /PROTECT is low, /WR is passed to the memory chip normally.

## ROM and RAM

U7 is the system ROM containing MON-3 or any earlier TEC monitor. This can be any (E)EPROM from 2k to 32k in size, and it is mapped to bank 3 at all times; the first 2k is also mapped to the start of bank 0 (0000h to 07FFh) when shadow is active.
The ROM SIZE Jumpers map the various address lines and the Hi/Low switch allows for TEC-1 Hi/Lo (MON1B/2) selection when a 4k 2732 chip is used; when a 32k chip is used it selects which half of the chip is mapped into Bank 3 (the other half of the chip is inaccessible).
If burning your own ROM, place older moniotrs at the stat of the ROM, from 0000h onwards, so that they will be SHADOWed to 0000h
U8 is the primary system ram, mapped to banks 0 and 1, and subject to the above SHADOW and PROTECT 
U9 is the expansion memory socket, and is mapped into bank 2. Any memory chip from 8k to 32k can be fitted here; if a 32k chip is fitted then bankswitching using the EXTEND signal selects which half of the memory is mapped into bank 2 (the other half is inaccessible unless the EXTEND signl is flipped, which swaps halves). EXTEND has no affect if a memory devices less than 32k in size is fitted.

## 
