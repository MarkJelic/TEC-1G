## Mon 3 User Guide

MON3 is the monitor for the TEC-1G.  
A comprehensive User Guide has been provided that details how to use MON3.  Please see the [Mon3 User Guide](./MON3_User_Guide_v1.pdf) in this folder.

## File Links
| File | Description | Version |
|---|---|---|
| [MON3 for TEC-1G](MON3-1G_BC23-11.bin) | Download and burn to a 16k ROM | 1.0 |
| [MON3 User Guide](./MON3_User_Guide_v1.pdf) | MON3 User Guide in PDF format | 1.0 |

## MON 3 Usage (Brief)

- Two modes, Menu and Data entry.  Press 'AD' to exit Menu and change to data entry mode and 'Fn-0' to get back to the main menu.
- Hard reset by either power on or Holding FN down when Reset is pressed and released.
- Matrix Keyboard support.  Key emulate HexPad, 0-F, Plus=Right arrow, Minus=Left Arrow, GO= Enter, AD= ESC.
- Monitor Reserved RAM is between 0000H-0FFFH.  Do not try to manually update this area.  If something gets buggered, a HARD Reset will fix most issues.
- If DIP is set to PROTECT on, when the GO button is pressed, all code between address 4000H and 7FFFH will be READ ONLY and protected from altering code.  This feature will protect your code if an accidental update occurs.  If your code needs updatable RAM, then use memory between 1000H-3FFFH.
- If DIP is set to EXPAND on, monitor will honour this option on Hard Reset.  Expand sets A14 to HIGH on the Expansion Socket.  Allowing to Page Swap a 32K ROM/RAM in 16K chunks.
- Menu mode
  - press +/- to move to option.  GO to execute option and AD to quit into Data entry mode.
  - Menu Items
    - Intel HEX Load - Upload Z80 code in Intel HEX format
    - Smart Block Copy - Move a block of code with 2 byte address updates
    - Block Backup - Move a block of code
    - Export Z80 Assembly - Display Z80 Assembly on Serial Terminal
    - Export Raw Data - Download binary data
    - Export Hex Dump - Display a HEX Dump on Serial Terminal
    - Import Binary File - Upload a binary file
    - Tiny Basic - Tiny Basic via Serial Terminal
    - Music Routine - Play some musical notes.  See Issue #10 for details
    - Setting - Update BEEP, Auto Address Increment and EXPAND setting
    - Credits - TEC-1G Contributors
- Data Entry mode
  - Familiar TEC data/address mode.  +/- to Move to new address, 'AD' to switch to Address or Data change mode.  GO to execute code at the current editing location
  - Auto address increment (can be switched off), Auto key repeat when key is held down.
  - Decimal Place dots move on Nibble entry to indicate which nibble has been entered.
  - Decimal Place dots also indicate which part Address or Data is currently editable.
  - Pressing AD button twice will reset the data entry at that location and a new byte can be entered.  Do this when an incorrect byte has been entered to stop the address from auto incrementing. 
  - LCD View displays Hex Dump of five bytes behind the current editing address and 10 bytes ahead of the current editing address.  The current Z80 Instruction is shown on the fourth line.
  - Function + Button (0-F) will run code
    - Fn-0 = Switch to menu Mode
    - Fn-1 = Intel Hex Load.  Screen waits for data via SIO.  Load Progress is shown with indication on 7Seg.  Pass/Fail displayed at end of load.  Press any key to exit back to monitor.
    - Fn-B = Block Backup
    - Fn-C = Smart Block Copy
    - Fn-D = Switch data editing view from Hex Dump to Disassembly and back.  Disassembly view displays the next four instructions, use + key to move forward and - key to moving backward.
    - Fn-E = Toggle EXPAND option
    - Fn-Plus = Insert a NOP at the current editing location.  This routine will also adjust all 2 byte address references 
    - Fn-Minus = Delete a byte at the current editing location.  This routine will also adjust all 2 byte address references 
  - Breakpoints.  Insert a F7H or RST 30H to break execution and display registers on the LCD screen.  Press 'GO' to continue code execution or 'AD' to quit back to monitor.
- RST instructions
  - RST 00 (C7) - Reset Monitor
  - RST 08 (CF) - Key wait and press.  Simulator a HALT instruction
  - RST 10 (D7) - API Entry call.  Set register C to API number, and other registers if needed based on call.  See [API](api.md)
  - RST 18 (DF) - Unused
  - RST 20 (E7) - Scan 7Segs and Key Scan.  To be called in a repeating loop, check for Zero flag for key press.
  - RST 28 (EF) - LCD Busy check.  Must be called before any LCD command is sent to the LCD to ensure LCD is not busy.
  - RST 30 (F7) - Breakpoint.  View current CPU registers, 'GO' to continue execution of code, 'AD' to exit back to monitor
  - RST 38 (FF) - Maskable interrupt handler.  Jumps here with Interrupts Enabled (EI), Interrupt mode 1 (IM 1) and when the INT pin on the CPU goes low.  Replace memory location _0892H_ with address of user defined routine: IE: 0892: XX YY where YYXX is address of routine.
  - NMI - Non Maskable interrupt handler.  Jumps here on NMI pin on the CPU goes low.  Replace memory location _0894H_ with user defined jump routine: IE: 0894: XX YY where YYXX is address of routine.
  
- A Music/Sound Routine is provided.  It works similar to the music routine on MON1.  To access via a parameter window to choose start location of music data, go to address _E025_ and hit "GO".  See Talking Electronics Magazine issue #10.

 Note reference table is as follows:
| Note | Value | Note | Value |
| --- | --- | --- | --- |
|  G  | 01H |  F# | 0CH |
|  G# | 02H |  G  | 0DH |
|  A  | 03H |  G# | 0EH |
|  A# | 04H |  A  | 0FH |
|  B  | 05H |  A# | 10H |
|  C  | 06H |  B  | 11H |
|  C# | 07H |  C  | 12H |
|  D  | 08H |  C# | 13H |
|  D# | 09H |  D  | 14H |
|  E  | 0AH |  D# | 15H |
|  F  | 0BH |  E  | 16H |
| Exit| 1FH |  F  | 17H |
|  |  |  F# | 18H |


- Graphical LCD library.  If using the TEC-DECK Graphical LCD (GLCD) add-on, a suite of routines to interface with the GLCD has been provide.  The Routines can be called from the GLCD API `RST 18H`.   For information on using these routines see the [Mon3 User Guide](./MON3_User_Guide_v1.pdf).


   
  
