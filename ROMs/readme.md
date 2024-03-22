## File Links
| File | Description | Version |
|---|---|---|
| [Monitor 3](./MON3/) | The new main Monitor for the TEC-1G written by Brian Chiha| 1.4 |
| [Diagnostics](./DIAGs/) | Test the functionality of your TEC-1G, by Craig Hart | 1.1 |
| [BMON](./BMON/) | Run the first monitor that Brian Chiha adapted for the TEC-1 | 1.3 |
| [MON-1B](./MON1/) | The original, hand-coded monitor for the TEC-1 by John Hardy | 16K |

# ROMs for the TEC-1G

The file list above gives you links to the individual monitors that you can quickly copy to an NVRAM chip
and pop them into the TEC-1G, without having to play around with the ROM size switches.

You can also download the "combined images" that include:
 - 32k has MON-3 and DIAGs
 - 64k has MON-3, DIAGs, BMON and MON-1B


## Older ROMs

The TEC-1G is perfectly backward compatible with previous monitors and the 2k/4k ROMs they came on.
To use an old TEC-1 ROM, since they were burnt to either a 2k or 4k ROM in a 24pin package, you simply plug the 24 pin ROM into the upper part of 28pin ZIF socket. See the picture below.
![ROM_Select](https://github.com/MarkJelic/TEC-1G/assets/13119623/8d69fc73-478f-4a73-8ddb-a0395251e33d)

To enable the 1G to use a 24 pin chip (in either the ROM ZIF, or in the EXPAND socket) you need to set the three Chip Size jumpers appropriately. Move all three jumpers to the top positions for 24 pin chips, and have the jumpers down for 28 pin chips.

The Hi/Lo switch works the same as the original TEC-1, allowing you to select the top half or bottom half of a 4k or 32k ROM.

The images for the 2k / 4k ROMs can be found here on GitHub, but since the 1G now has the space for 32k & 64k ROM chips, we have recompiled the old monitors into 16K file sizes that allows for easy "combining" on burners like the GQ-4x4.

