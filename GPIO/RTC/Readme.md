# GPIO Real Time Clock (RTC) Board
| File | Description | Version |
|---|---|---|
| [Assembly Instructions]() | Coming Soon... | 1.0 |
| [Parts List](/TEC-1G_PartsList_v1-5.pdf) | Coming Soon...  | 1.0 |
| [Schematic](TEC-1G_GPIO_RTC_Schematic_v1-0.pdf) | It's a simple circuit, but it's honest timekeeping. | 1.0 |
| [PCB Gerbers]() | Coming Soon... | 1.0 |

## What Does it Do?
It keeps accurate real time, once set, and is battery backed. So even after you switch your TEC-1G off, 
the RTC chip will be powered and will continue to keep accurate time. Oh and it has some battery backed RAM,
a full 31 bytes for you to use for saving variables or settings between power ups.

## How Does It Work
The circuit is based around the very cheap and widely used timekeeping chip, the DS1302. 
The DS1302 uses a very simple 3 wire serial interface to communicate with it, so the extra chips you see on the board are basically
just to help with serial communications.

![RTC Circuit](./RTC_Circuit.jpg)

## Why Build It?
Since you first built the TEC-1, be it the original like I did, or the latest TEC-1G... Did you look at those six 7 Segment displays
and think:

<b>"Man, that would make a perfect digital clock!"</b>

I did, but there was never a way to keep the clock actually accurate, until now!

But there are other uses as well. With the TEC-1G GPIO SD Card, you will soon be able to save your files... 
But isn't it important to know WHEN you saved that last file, or made chnages to it?
With the RTC Board in place, you can get the correct time and write it to the file so you know when the last time you made edits.

Want more reasons? 
- How long did it take you to solve that Puzzle Game?
- Writing a game that has critical timing or has a time element to make it exciting?
- How about making an automation system for your home, turning on the Christmas lights at sunset?
- Need the sprinklers to come on at a certain time?
- Want to control your model train based on a strict timing schedule?
- What about saving some settings in the battery-backed 31 bytes?

These are just some of the reason you may want an Real Time Clock. 
For me, I want to finally be able to hang up my TEC-1G for the world to see how clever I am with a soldering iron. :)
Oh, and finally be able to answer the question I *always* get: "So what can it do?"<br>
It can be a CLOCK! That's what is can do! Now stop picking on my hobby! ;)

![TEC-1G GPIO RTC](./TEC-1G_GPIO_RTC-Board.jpg)

## Ho Do You Use It?
The clever people at <b>TEC-1 Inc.</b> will soon release an API as part of MON3.
This will allow you to set the current time, read the current time, save and read bytes out of the battery backed RAM.
All this and more, <b>Coming Soon®...</b>
