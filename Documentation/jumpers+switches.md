# TEC-1G - Jumpers & Switches

## EPROM - Pin 1
Make sure Pin 1 of the EPROM (whether it is the 28 or the 24 pin package) is situated at the bottom Right.<br>
![EPROM ZIF Socket](images/EPROM_Pin1.jpg)<br>

## EPROM Jumpers
The highlighted positions (three jumpers down on the "28 pin") will configure the chip to run MON3. Use the A14 and A15 switches/jumpers to switch between the monitors.<br>
![EPROM](images/Jumpers_ROM.jpg)<br>

## EXPAND Jumpers
For 32K chips like the 62256 or the upcoming 32K FRAM, the highlighted jumpers or switches need to be set.<br>
![EXPAND](images/Jumpers_EXPAND.jpg)<br>

## NMI Jumper & Wire Link
To enable the 923 doing an NMI (as done in MON1 and MON2), this jumper needs to connect pins as highlighted. Also, don't forget the wire link you need for clock signal.<br>
![NMI](images/Jumpers_NMI.jpg)<br>

## Speed Switch
You CANNOT have both the SPEED switch and the Max4544 chip installed.<br>
![Speed](images/Switches_SPEED.jpg)<br>

## Speaker Jumper & LEDs<br>
No need to place a shunt on the Groundwalker jumper, unless you have cut the track on the bottom of the PCB.<br>
![Speaker](images/Jumpers_SPKR.jpg)<br>

## Config Switch
These are the recommended settings. These are explained in the MON3 User Guide.<br>
![Speaker](images/Switches_CONFIG.jpg)<br>

## G.IMP
Shorting the highlighted pins makes the Break Point routine skip through as if you pressed the Go button.<br>
![GIMP](images/GIMP.jpg)<br>
