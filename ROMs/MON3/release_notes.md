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

### V1.4
File MON3-1G_BC24-14.bin

- **Feature**
  - Real Time Clock Add-On Board Integration.  If RTC Add-On Board is connected to the GPIO socket, the RTC will be automatically detected.  Quick Jump Addresses and From/To/Destination range addresses will be saved to Non Volatile RAM (PRAM).  These values will be retained when the TEC is powered off using the battery backup on the Add-On Board.
  - RTC Configuration added to Setting Menu.  Set the Time/Date and View PRAM data.
  - RTC API routines added.
  - Data Entry Mode now displays 3 lines of 4 bytes on the LCD and three new monitor states, Data or Address mode, Nibbles entered and the current bytes ASCII value.
  - Add `stringToSerial` API routine to send multiple characters to the serial terminal.
  - Add `menuPop` API routine that will remove the current menu and replace it with its Parent menu.  If no Parent menu exist, then the Monitor mode will switch to Data Entry view.  This is equivalent to press the `AD` key on the menu but done is software.
  - If Fn-n is pressed and n isn't assigned to a routine, the message 'NoFn' will appear on the 7 segments.
  - Menus are now nested up to 4 deep.  Pressing 'AD' will return to the previous menu or into Data Entry mode if at the top menu.  Pressing 'GO' will run the routine and return to Menu mode.  This also applies to Parameter data entry.
  - When a menu item is selected, the menu item name and its routine address will be displayed on the LCD.  This will indicate to the user what routine is currently being executed.
  - Break Points can be skipped without removing `RST 30` or `F7h` from the code if a jumper is set on the G.INP headers `+` and `D5`.
  - Display welcome message on Serial Terminal on Power On or Cold Reset.
- **Bug Fix**
  - Fix grammar in main menu.
  - Removed `toggleCaps`, `toggleExpand`, `toggleProtect` and `toggleShadow` from API as the user will firstly want to check status of these flags first before setting or unsetting them.
  - Pressing `GO` on a informational menu item will not do a RESET. but only a softboot.  IE: if press `GO` on the version text in the main menu.
  - Cleaned up how `GO`,`AD` and `Reset` are handled whilst in a menu or parameter entry.
  - Pressing `GO` to run a routine removes removes GO as the last key pressed.

### V1.5
File MON3-1G_BC24-15.bin

- **Feature**
  - Upgraded Graphical LCD routines to include `drawGraphic` and Terminal Emulation routines.
  - Display "Running at: nnnn" when `GO` is pressed.  nnnn is the Address where code starts executing.
  - ~~Display welcome banner on Graphical LCD screen on Hard Reset.~~
  - Add `toggleCaps` from API for matrix keyboard.  Sorry, removed at last release.
  - `parseMatrixScan` API called added.  Accepts input from the matrix keyboard and returns equivalent ASCII.  Also handles key bounce, key repeat and Caps lock.
  - Add `LCDConfirm` API call.  Ask user to press `C` to continue.  Usually for serious memory updates.
  - Add `setGLCDTerm` and `getGLCDTerm` API call.  Check and set output to GLCD Terminal.
  - Removed TMON (Terminal Monitor) from the core monitor code. :(
  - Add `Fn-A` Restore from Backup.  Reverse of `Fn-B`
  - Add `Fn-8` Fill a selected portion of memory with NOPs
  - Add `Toggle GLCD Term` option in settings to make the GLCD act as a serial terminal.  This can also but switched on/off with `Fn-5`
  - Tiny Basic will now output to the GLCD and input from the Matrix Keyboard if GLCD is set up as a terminal.
-  **Bug Fix**
  - Control Keys now are accepted and returned on Matrix Keyboard using the `matrixScanASCII` API call.  IE: Ctrl-C will return `03H`.
  - Tiny Basic had issues with negating zero.
  - Tiny Basic will display all 256 ASCII characters using PRINT $n.
  - Reset LCD prior to hard reboot check.  This helps when using FRAM.
  - `Reset RTC & PRAM` also resets the Date and Time which puts it in a proper state to be recognised.
