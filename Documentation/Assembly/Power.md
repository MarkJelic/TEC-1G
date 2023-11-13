# Assembly Instructions

## 3. The Power Delivery Circuit
![Overlay](./pictures/power_overlay.jpg) ![Schematic](./pictures/power_delivery_schematic.jpg)

With only nine (9) components to install in this section, this may seem too short to write up separately, but this is one of the most crucial parts of the build.
Here is the list of parts you need:

| Ref# | Part | Value |
|---|---|---|
| BJ1 | Barrel Jack | Socket 2.1mm|
|SW1 | Power Switch | DPDT Slide|
|D0 | Rectifying Diode | 1N4001-7|
|C1 | Electrolytic Capacitor | 1000uf|
|C2 | Smoothing Capacitor | 100n|
|C3 | Smoothing Capacitor | 100n|
|REG1 | 5V Regulator | L7805|
|R1 | Resistor | 330R|
|L1 | Power LED | Blue 5mm|
|USB1 | USB-B Socket | (Optional - See Notes Below)|

As with any building (the real ones we live in), you must have a solid foundation that you can rely on and be 100% certain is the bedrock of your build; so it is the same with a proper power circuit that is tested to work and delivers power correctly to where it needs to go and not where it shouldn't.

### The 7805 Regulator
The TEC-1G, as with most other Z80 machines of the time, works on a single 5v power supply. We could get a power pack and feed 5v directly into system, but those are not always easy to come by and you might find you have a 9v pack instead. Accidentally plug one of those in and you can kiss goodbye any number of chips. Hence, since the first days of the TEC-1, they have had a 5v regulator by means of the 7805.

![7805 5v Regulator](./pictures/7805.jpg)

These regulators work very reliably, up to 1.0 to 1.5 amps as long as you have edequate heat dispersal. They can generate quite a bit or heat if put them under heavy load or have to deal with a high input voltage. But they also need a high enough input voltage before they operate correctly. So overall, they are not very efficient and can make a lot of heat that did cause problems with enclosed systems like the ZX Spectrum.

To help with heat disipation, the TEC-1G has a largish flow of copper on the top of the board that will help in that regard. Make sure you use some heatsink compound (nowhere near as much as in the photo; half that would have been enough) between the board to make a better thermal contact. Then use a 3mm bolt and nut to secure it to the board.

![Too much heatsink compound!](./pictures/heatsink_compound.jpg)

When the full build is complete, keep an eye (finger) on the heat coming off the 7805 and if it is too warm to the touch, try decreasing your input voltage (minimum 7v) or you can also insert a small heatsink between the 7805 and the board. Again, use heatsink compound on any surface that touches and needs to tranfer heat, and bolt it tightly together.

![Heatsink](./pictures/heatsink.jpg)

### Buck Regulators
Now there is a new kid on the block that might be of interest and if you find the heat coming off the 7805 and heatsink is too great (you should be able to keep your finger comfortably on the regulator for at least 3 seconds) then you may want to try a "Buck Regulator". These operate at much higher efficiency (something you may want to keep in mind if you ever run the TEC-1G off batteries) of around 95%, generate next to no heat at all and are available in 1A to 3A in small form factors that are no bigger than the 7805. Worth the $5 or so you will pay for one.

![Buck Regulator](./pictures/buck_reg.jpg)

### Build Order

As with Any PCB assembly, start with the components with the least height, so that when you flip the board over to actually solder, gravity is helping keep the component pressed against the board. Don't forget to use the "One Pin Method" if you have OCD like me. (Don't judge me!)
1. Solder in the 330 ohm resistor
   
![330ohm Resistor](./pictures/resistor_330r.jpg)

2. Next comes the Rectifying Diode. Make sure you orient this the right way, lining up the band on the diode to the band indicated on the board. Get this wrong and the diode will block rather than pass through any power. (This diode also protects the TEC-1G from accidental reverse polarity plugs.)

![4001_Diode](./pictures/diode_4001.jpg)

3. The L7805 regulator is next. You need to bend the pins 90 degress (just where the pins get skinny) so that the hole in the upper metal tab lines up with the hole in the PCB. After it is soldered in place, add a small dab of heatsink compound and bolt it down the PCB. If you have the heatsink, add that in later in the build, as one of the last things due to the height it adds to the board. Don't forget to add heatsink compound to both the heatsink surfaces then bolt it all together. Clean up any excess compound with a tissue.

4. Solder in the two little 100n (104) smoothing capacitors.

![Smoothing Capacitor4001_Diode](./pictures/capacitor_104.jpg)

5. The Power Switch can be next. Make sure you press it in firmly before begenning to solder.

6. The Blue LED can go next, keeping in mind the orientation of the Cathode.

![Blue LED](./pictures/LED_5mm.jpg)

7. Next on the height line is the large 1000uf electrolytic capacitor. Keep in mind there is a polarity which has to be followed, and in this case, the capacitor has to be laid over horizontally, to keep it low enough to allow GPIO boards to be installed over the top of that section of the PCB.

8. Then the Barrel Jack socket can go in next. Don't skimp on the solder at this item, as it has to sustain power jacks being pushed and pulled out of it.

9. Last of all, the optional USB-B connector which is not supplied in the TEC-1G Kit. Read on...

### Testing
Time to crack out the multimeter!

If you have a Bench Power Supply, it would be good to use that as your power source so you can monitor how much power usage is being drawn through the 7805. If you don't, that's fine, you can still do all the tests with just a multimeter.

First up, switch her on and see if the Blue Power LED comes on. If it doesn't, check your power supply for orientation on the barrel jack. The Tip needs to be positive and the voltage really needs to be 7.5v minimum.

Leaving the power on, do some spot checking of the voltage at various ICs around the board (you will need to look up which pin is GND and which is +5v) as well as brushing the probe along non-power pins to see if there are any spurious connections to pins that should not have power.

This sort of "Testing the Power" needs to be done at the end of any big soldering session, to ensure you have not inadvertently made any shorts and the power is still stable.

The last test is to leave the board powerted up for 30 minutes or so and see if the 7805 gets warm. With just one little LED running, the 7805 should remain totally cool. Once you have all the chips installed and running, monitoring the heat of the 7805 is wise.

![Power Delivery](./pictures/power_delivery_complete.jpg)

### The USB-B Connector

Who doesn't have a USB port within 1m of them at any given moment in 2023? Not many in this day and age and thus it simply makes sense that rather than wasting time in soldering the parts listed above, you just use a pretty ubiquitous USB cable to plug directly into the TEC-1G and away you go, right?

During testing of the BETA boards, it was found that the current draw the 1G pulls exceeds what most USB ports are designed or willing to give, which caused very erratic behaviour on the 1G. In fact, the USB-B socket was very close to being removed.

If you are to use the USB-B socket as a power delivery, remember there is NO SUPPORT for this method AND if you accidentally get the polarity of voltage wrong, there is NO PROTECTION for your components at all. You best know what you are doing!




























