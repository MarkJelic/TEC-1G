# ROMs for the TEC-1G

The TEC-1G is perfectly backward compatible with previous monitors and the 2k/4k ROMs they came on.
To use an old TEC-1 ROM, since they were burnt to either a 2k or 4k ROM in a 24pin package, you simply plug the 24 pin ROM into the upper part of 28pin ZIF socket. See the picture below.
![ROM_Select](https://github.com/MarkJelic/TEC-1G/assets/13119623/8d69fc73-478f-4a73-8ddb-a0395251e33d)

To enable the 1G to use a 24 pin chip (in either the ROM ZIF, or in the EXPAND socket) you need to set the three Chip Size jumpers appropriately. Move all three jumpers to the top positions for 24 pin chips, and have the jumpers down for 28 pin chips.

The Hi/Lo switch works the same as the original TEC-1, allowing you to select the top half or bottom half of a 4k or 32k ROM.

The images for the 2k / 4k ROMs can be found here on GitHub, but since the 1G now has the space for 32k ROM chips, we have recompiled the old monitors into 16K file sizes that allows for easy "combining" on burners like the GQ-4x4.

Download and burn the images you wish to use, below:<br>
MON1<br>
MON2<br>
JMON<br>
BMON<br>
MON3<br>
