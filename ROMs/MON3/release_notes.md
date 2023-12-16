# Release Notes

### V1.0
File: MON3-1G_BC23-10.bin

- Initial Release
  
### V1.1
File: MON3-1G_BC23-11.bin

- Feature
  -  `random` API routine

### V1.2
File MON3-1G_BC23-12.bin

- **Feature**
  - Terminal Monitor
  - added `setDisStart` API routine
  - added `getDisNext` API routine
  - added `getDisassembly` API routine
  - added `matrixScanASCII` API routine
  - Fn-AD key now returns back to Main Menu from Data Entry mode
  - Remove AD,GO mapping from Up and Down Arrows on the Matrix Keyboard
  - Display Intel Hex Load on LCD when an Intel Hex Load is performed
- **Bug Fix**
  - Remove cursor on LCD if reset performed
  - Unused Fn 0-F slots now return ERROR on the Seven Segments
  - Reset-Fn (Cold boot) works always on the HexPad even if the Matrix Keyboard is active
  - `scanKeys` and `scanKeysWait` key press return value includes function key if pressed.  Bit 5 is set.
  - `getProtect` API call fixed
  - `beep` API call always will sound a beep regardless of Monitor Key Beep settings
  - fixed Caps Lock routines to work properly