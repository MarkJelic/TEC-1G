# Micro SD Card Support for TEC-1G

## ERRATA
The first print (Green v1.0) and second print (Blue v1.1) of the GPIO SD-Card board had errors
regarding the Disc Activity LED. The resistor should be tied to +5V, not to GND.

The best way to fix this is to mount the 330 Ohm resistor on the *underside* of the PCB.
Insert the upper leg (closest to the LED) as normal but from the underside. And the other
leg of the resistor should be soldered to Pin 20 of the 74HCT273, which is +5V.

[Photo Coming Soon...]

| File | Description | Version |
|---|---|---|
| [Schematic](TEC-1G_GPIO_SD-Card_Schematic_v1-2) | It's a simple circuit, but it's honest storage. | 1.2 |
| [Parts List](./Partslist.md) | What you need to buy (and comes in the Kit) | 1.0 |
| [Assembly Instructions](./Assembly.md) | Coming Soon... | 1.0 |
| [PCB Gerbers]() | Coming Soon... | 1.0 |
| [Sample Programs](./Programs/) | Sample code and API reference | 1.0 |

## What Does it Do?

## How Does It Work

## Why Build It?

## How Do You Use It?
The clever people at <b>TEC-1 Inc.</b> will soon release an API as part of MON3.
All this and more, <b>Coming Soon®...</b>

While you're waiting, take a read of the [SD Card Interface DS1302 Spec Sheet](./DS1302_RTC_Timekeeper.pdf) sheet to get a handle on what commands you can send it.
