# TEC-1G Memory Map

The TEC-1G supports an extremely felixble memory map, which can be broken down into four major blocks or *Banks*, each 16k in size.

## Memory Banks

Bank 0 - 0000h to 03FFh - 16k RAM with first 2k shadowed to the first 2k of bank 3 at power-up

Bank 1 - 4000h to 7FFFh - 16k RAM which can be PROTECT write-protected

Bank 2 - 8000h to BFFFh - 16k Uncommitted. Can be ROM or RAM with EXPAND bankswitching. Future Cartridge port space.

Bank 3 - C000h to FFFFh - 32k MON-3 ROM or other MONitor ROM

The above memory map is fully compatible at power-on with the TEC-1; therefore all older MONitors that run from a 2K EPROM (e.g. BMON, JMON, MON-2 and MON-1B) will all work immediately.

## Recommended Memory Configuration

The 'default' assumed configuration for a newly built TEC-1G, is:

- U7: 32k MON-3 ROM chip fitted
- U8: 32k RAM fitted
- U9: left empty

Note that U7 can also accept a TEC-1 2k or 4k ROM with MON-1B/2 if you wish to run older software.

## Memory Banks - Special Features

Each memory bank has certain unique special featutes, which are described below.

### SHADOW Memory - Bank 0

To maintain TEC compatibility, the first 2K of Bank 0 is, at power on or RESET, shadowed to the first 2k of bank 3. Hence, the first 2k of ROM appears at both 0000h and C000h simultaneously.

Shadow can be turned off via the System Latch, giving a continuous 32k of RAM across banks 0 and 1.


### PROTECT RAM Write Protect - Bank 1

Bank 1 by default behaves as normal RAM memory at power on and RESET.

By setting the PROTECT bit of the System Latch, Bank 1 can be made READ-ONLY. This allows a degree of protection for software or data in RAM against memory corruption due to e.g. buffer overflow, stack crash, etc.

If the Protect dip-switch is set by the user, MON-3 will set PROTECT when user code is launched, and un-select PROTECT while MON-3 is running. This allows seamless memory protection with no change to user code.

PROTECT is designed for programmers while developing code, to work in a 'safe' space and not loose your work while debugging.


### EXPAND Bankswitching & Cartridge - Bank 2

Bank 2 supports installing a RAM or ROM chip of up to 32k in size in the U9 position. However, because bank 3 is only 16k in size, only half of a 32k chip can appear in bank 3 at any time.

The highest address line of the 32k chip (A14) can be toggled using the System Latch, to select which half of the chip appears in bank 3. Software is free to switch chip halves at any time.

This software-selectable memory-chip control is also known as *bankswitching*.

It is planned that a 'game cartridge' type system will be made available for the TEC-1G - plugging in a cartridge will place it's onboard ROM in Bank 2, and on power up the cartridge's ROM code will execute instead of MON-3. *This is a future planned additon - more details will be added as this future project is developed further, and are of course subject to change.*

** If the device in U9 is 16k or less in size, or U9 is empty, EXPAND has no effect.


### ROM Lo/Hi - Bank 3

The MON-3 MONitor ROM is designed to remain permanently fitted in bank 3. MON-3 provides system control and utility routines that user software can call upon using a standard software interface, or API.

To support a 32k ROM chip (or, a TEC-1 4k MON-1B/2 ROM), a ROM Lo/Hi swich is provided at SW6. This selects the upper or lower half of a 32k or 4K ROM CHIP, just like on the TEC-1.

** Note that the ROM SIZE jumpers must be set for the intended type of ROM chip - 24 pin (2k/4k) or 28 pin (8k to 32k).


## MON-3 Variables Memory Space

MON-3 sets aside 100h bytes of RAM from 0800h to 08FFh, for its internal purposes such as display buffering, keyboard state etc.

The contents of this RAM area are checked at startup, and if found to be corrupt or missing, overwritten with safe defaults. If a checksum test passes, the memory is left intact, meaning user settings and selections can survive a RESET.

## User Program Memory Space

User Program Memory starts at 0900h and ends at 07FFh - providing 30k of RAM. Stack and MON-3 varibles are located outside this space meaning all bytes are free for use.

PROTECT can be used to write-protect the RAM memory space between 4000h and 7FFFh if required.


# Other Memory Map Notes

U9 can accept an up to 32k ROM or RAM chip to extend system capacity via Bank 2. Note that future planned add-ons may also use Bank 2.

If a further 32k RAM chip is fitted to U9, the TEC-1 can support a full 64k of RAM, however only 48k is accessible without using EXPAND bankswitching.


# A note on CP/M

Careful consideration was given to the question of whether the TEC-1G should be able to run CP/M, or not.

It was decided NOT to aim for CP/M compatability, for a number of reasons:

- There are many Z80 based CP/M machines on the market. The 1G should not simply become another Z80 'textbook design'
- CP/M is an advanced OS generally requring disk drives, terminals RAM and a greater user skillset. This is contrary to the design goal of simplicity and ease of understanding
- Any attempt to do CP/M "well" would end up in so many compromises that the design goal of staying true and compatible with the TEC-1 family would be lost
- CP/M would not be usable on a hex keypad and 4-line LCD

Having said all that, there is likely no reason that CP/M could not be adapted for the 1G, and we would certainly welcome any attempt to do so. We leave this as "An exercise left up to the reader" so so many good textbooks like to say.

