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

### V1.3
File MON3-1G_BC23-13.bin

- **Feature**
  - Fn-0 Sets a quick jump address.  The Current editing address is stored in 1 of 3 positions.  Default to 4000H
  - Fn-1,2 and 3 will change the current editing address to the defined addresses set by Fn-0
  - Fn-4 is now assigned to the Intel Hex Load routine
- **Bug Fix**
  - `sendToSerial`, `receiveFromSerial`, `sendAssembly` and `sendHex` API routines now use HL = Start Address, DE = Length in Bytes.
  - "Export Z80 Assembly" and "Export Hex Dump" menu items will now append a Line Feed after the Carriage Return.  This will correctly place a new line on more terminals.

