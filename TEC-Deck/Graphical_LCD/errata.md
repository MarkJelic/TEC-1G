# Errata - Garbled Screen

If you get a garbled screen similar to this, there is a simple fix. 

<img src="./GLCD_garbled_screen.jpg" style="float: left;" width="300">
<img src="./GLCD_garbled_screen.jpg" width="300">

The older versions of the display did not have a capacitor installed at C6 but for some reason
they are in the latest versions, and this can cause timing ussues for the Z80.

<img src="./GLCD_v2+3_without_C6.jpg" width="400">

Check on the back of your 128x64 GLCD module and locate the capacitor marked C6, usually
mounted at the bottom left.

<img src="./GLCD_v3_with_C6.jpg" width="400">

Just get a pair of snips and cut the capacitor off. (You can try to be tidier and use a soldering
or desoldering iron... But snipping it off is fast and effective.)

<img src="./GLCD_v3_no_C6.jpg" width="400">
