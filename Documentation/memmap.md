# TEC-1G Memory Map

## Hardware Memory System

The TEC-1G supports an extremely flexible memory map, which can be broken down into four major blocks or *Banks*, each 16k in size.

### Memory Banks

Bank 0 - $0000 to $03FF - 16k RAM with first 2k over-shadowed by the first 2k of bank 3 at power-up

Bank 1 - $4000 to $7FFF - 16k RAM which can be PROTECT write-protected

Bank 2 - $8000 to $BFFF - 16k Uncommitted. Can be ROM or RAM with EXPAND page switching. Future Cartridge port space.

Bank 3 - $C000 to $FFFF - 16k MON-3 ROM or other MONitor ROM (out of a possible 32k chip, that can be manually switched between hi/lo halves of 32k)

The above memory map is fully compatible at power-on with the TEC-1; therefore all older MONitors that run from a 2K EPROM (e.g. BMON, JMON, MON-2 and MON-1B) will all work without modification.

![TEC-1G Memory Map Diagram](Memory%20Map.png)

### Recommended Memory Configuration

The 'default' assumed configuration for a newly built TEC-1G, is:

- U7: 32k MON-3 ROM chip fitted. ROM Bank 3
- U8: 32k RAM fitted RAM Banks 0 and 1
- U9: left empty. Bank 2 unoccupied

Note that U7 can also accept a TEC-1 2k or 4k ROM with any previous MONitor if you wish to run older software.

### Memory Banks - Special Features

Each memory bank has certain unique special features, which are described below.

#### SHADOW Memory - Bank 0

To maintain TEC compatibility, the first 2K of Bank 0 is, at power on or RESET, is over-shadowed by the first 2k of bank 3. Hence, the first 2k of ROM appears at both $0000 and $C000 simultaneously.

Shadow can be turned off via the System Latch, giving a continuous 32k of RAM across banks 0 and 1.

#### PROTECT RAM Write Protect - Bank 1
Bank 1 by default behaves as normal RAM memory at power on and RESET.

By setting the PROTECT bit of the System Latch, Bank 1 can be made READ-ONLY. This allows a degree of protection for software or data in RAM against memory corruption due to e.g. buffer overflow, stack crash, etc.

If the Protect dip-switch is set by the user, MON-3 will set PROTECT when user code is launched, and un-select PROTECT while MON-3 is running. This allows seamless memory protection with no change to user code.

PROTECT is designed for programmers while developing code, to work in a 'safe' space and not loose your work while debugging.

#### EXPAND Page Switching & Cartridge - Bank 2
Bank 2 supports installing a RAM or ROM chip of up to 32k in size in the U9 position. However, because Bank 2 is only 16k in size, only half of a 32k chip can appear in Bank 2 at any time.

The highest address line of the 32k chip (A14) can be toggled using the System Latch under software control, to select which half of the chip appears in bank 3. Software is free to switch between chip halves at any time.

This software-selectable memory-chip control is also known in 1G language, as *page switching*.

It is planned that a 'game cartridge' type system will be made available for the TEC-1G - plugging in a cartridge will place it's onboard ROM in Bank 2, and on power up the cartridge's ROM code will execute instead of MON-3. *This is a future planned additon - more details will be added as this future project is developed further, and are of course subject to change.*

** If the device in U9 is 16k or less in size, or U9 is empty, EXPAND has no effect.

#### ROM Lo/Hi - Bank 3
The MON-3 MONitor ROM is designed to remain permanently fitted in bank 3. MON-3 provides system control and utility routines that user software can call upon using a standard software interface, or API.

To support a 32k ROM chip (or, a TEC-1 4k ROM), a ROM Lo/Hi swich is provided at SW6. This selects the upper or lower half of a 32k or 4K ROM chip, just like on the TEC-1.

** Note that the ROM SIZE jumpers must be set for the intended type of ROM chip - 24 pin (2k/4k) or 28 pin (8k to 32k).

### MON-3 Variables Memory Space

MON-3 sets aside $1000 bytes (2K0 of RAM from $0800 to $0FFF, for its internal purposes such as display buffering, keyboard state etc.

The contents of this RAM area are checked at startup, and if found to be corrupt or missing, overwritten with safe defaults. If a checksum test passes, the memory is left intact, meaning user settings and selections can survive a RESET.

## ROM Memory space

All of Bank 3 between $C000 and $FFFF is set aside as ROM space, and is occupied by MON-3 and associated software included in the ROM image (demos, games, etc)

## User Memory Space

User Program Memory occupies Bank 1, starting at $4000 and ending at $7FFF - providing 16k of write-Protected RAM. The PROTECT signal is used to write-protect the RAM memory space, but can be turned off in MON-3 by config dipswitch, and controlled by user software if so desired. Mon-3's default location for editing program code is $4000. This replaces the prior use of $0800 or $0900 in earlier monitors.

MON-3 variables and Stack are located in Bank 0 between $0800 and $0FFF. This area should not be accessed by user programs, however if corrupted, MON-3 will reload default values upon reset, to ensure that MON-3 can always restart to a usable condition. Earlier monitors placed the stack at undocumented locations. With MON-3, you always know where your stack is.

The Z80 'zero page' interupt vectors and MON-3 core startup code are located between $0000 and $07FF. This memory space can be configired as RAM and altered by software to support advanced features such as Z80 INT interrupt support, however newcomers to the TEC-1G should consider this memory area 'off limits'.

The balance of Bank 0 is user RAM memory space, located between $1000 and $3FFF. This space is suggested for use as user variables, data buffers and the like.

| Bank | Address | Size | Purpose |
|------|---------|------|---------|
| Bank 3 | $C000 | 16k |MON-3 ROM |
| Bank 2 | $8000 | 16k | EXPAND space - unoccupied |
| Bank 1 | $4000 | 16k | Protected User RAM - program code, constants |
| Bank 0 | $1000 | 12k | Unprotected User RAM - variables & data |
| Bank 0 | $0800 | 2k | MON-3 Variables & Stack |
| Bank 0 | $0000 | 2k | MON-3 Shadow ROM |

The TEC-1G ofers a more mature programmer's model, with Code and Data separated into their own distinct memory areas. PROTECT further assists programmers by ensuring your hard-entered code is not destroyed by an errant software bug. PROTECT works automatically and does not normally need any user program code to function.

## Other Memory Map Notes

U9 can accept an up to 32k ROM or RAM chip to extend system capacity via Bank 2. Note that future planned add-ons may also use Bank 2.

If a further 32k RAM chip is fitted to U9, the TEC-1 can support a full 64k of RAM, however only 48k is accessible without using EXPAND bankswitching.

## A note on CP/M

Careful consideration was given to the question of whether the TEC-1G should be able to run CP/M, or not.

It was decided NOT to <b>specifically</b> aim for CP/M compatability, for a number of reasons:

- There are many Z80 based CP/M machines on the market. The 1G should not simply become another Z80 'textbook design'. If you want a CP/M box, there are plenty to choose from. The TEc-1G isn't intended to be one of them
- CP/M is an advanced OS generally requring disk drives, terminals, a full 64k of RAM + additional bankswitched memory, and calls for a greater user skillset, both to get up and going, and to use effectively. This is contrary to the design goal of simplicity and ease of understanding
- Any attempt to do CP/M "well" would end up in so many compromises that the design goal of staying true and compatible with the TEC-1 family would be lost
- CP/M would not be practically usable on a hex keypad and 4-line LCD in any case

Having said all that, there is likely no reason that CP/M could not be adapted for the 1G, and we would certainly welcome any attempt to do so. We leave this as "An exercise left up to the reader" as so many good textbooks like to say.

