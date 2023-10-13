## MON 3 Usage

- Two modes, Menu and Data entry.  Press 'AD' to exit Menu and change to data entry mode and 'Fn-0' to get back to the main menu.
- Hard reset by either power on or Holding FN down when Reset is pressed and released.
- Matrix Keyboard support.  Key emulate HexPad, 0-F, Plus=Right arrow, Minus=Left Arrow, GO=Down Arrow or Enter, AD=Up Arrow or ESC.
- Menu mode
  - press +/- to move to option.  GO to execute option and AD to quit into Data entry mode (Note: Menu isn't implemented yet!)
- Data Entry mode
  - Familiar TEC data/address mode.  +/- to Move to new address, 'AD' to switch to Address or Data change mode.  GO to execute code at the current editing location
  - Auto address increment, Auto key repeat.
  - Decimal Place dots move on Nibble entry to indicate which nibble has been entered.
  - LCD View displays Hex Dump of five bytes behind the current editing address and 10-15 bytes ahead of the current editing address
  - Function + Button (0-F) will run code
    - Fn-0 = Switch to menu Mode
    - Fn-1 = Intel Hex Load.  Screen waits for data via SIO.  Load Progress is shown with indication on 7Seg.  Pass/Fail displayed at end of load.  Press any key to exit back to monitor.
    - Fn-D = Switch data editing view from Hex Dump to Disassembly and back.  Disassembly view displays the next four lines, use + key to move forward.  Moving backward, direct address changes and editing bytes in this view could display incorrect assembly if not at the first byte of the instruction.
    - More to come...
  - Breakpoints.  Insert a F7H or RST 30H to break execution and display registers on the LCD screen.  Press 'GO' to continue code execution or 'AD' to quit back to monitor.
- RST instructions
  - RST 00 (C7) - Reset Monitor
  - RST 08 (CF) - Key wait and press.  Simulator a HALT instruction
  - RST 10 (D7) - API Entry call.  Set register C to API number, and other registers if need based on call.  See [API](api.md)
  - RST 18 (DF) - Unused
  - RST 20 (E7) - Scan 7Segs and Key Scan.  To be called in a look, check for Zero flag for key press.
  - RST 28 (EF) - LCD Busy check.  Must be called before any LCD command is sent to the LCD to ensure LCD is not busy.
  - RST 30 (F7) - Breakpoint.  View current CPU registers, 'GO' to continue execution of code, 'AD' to exit back to monitor
  - RST 38 (FF) - Maskable interrupt handler.  Jumps here on with Interrupts Enabled (EI) and Interrupt mode 1 (IM 1).  Replace memory location 0892H with user defined jump routine: IE: 0892: C3 NN NN where NN NN is address of routine
  - NMI - Non Maskable interrupt handler.  Jumps here on NMI trigger. Replace memory location 0895H with user defined jump routine: IE: 0895: C3 NN NN where NN NN is address of routine
  
