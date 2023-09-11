# Diag - diagnostic and test code for the TEC-1G

### new releases 2023.bn where n is the build number. build 10 is one newer than build 9, etc.
### old releases - Diags_Main_xxx.bin

Burn to ROM at 0000 offset in the ROM itself, plug into the 1G and turn on

## changelog

### 2023.bB
 - Fix issue with LCD cursor not resetting if ADDR pressed to exit matrix test
 - turn off 8x8 at power up
 - added 8x8 tests - row and column scan, fan out, fan tail, blink, scan with scrolltext
 - fixed bank 1 wrprot test bug introduced in beta bA

### 2023.bA
 - press hexpad ADDR to exit matrix or joystick tests (In addition to matrix ESC)
 - MSX wiring type fire 2 button support ( bit D6, joystick pin 7) and "other" type (bit D5, joystick pin 9)
 - rewrote expand test to be more logical and to display results more clearly
 - rewerote ram tester, now checks >1 byte per block (32 bytes by default). Needs work to ensure it doesn't test(overwrite) its own buffers
 - all memory checks use new RAM tester routines
 - fixed bug in bank 1 protect code - forgot to test if WP actually worked (Duh!!)
 - serial/FTDI loopback jumper test - jumper Rx to Tx
 - Pi Test
 - Burn in now includes FTDI and Pi tests
 
### 2023.b9
 - added matrix keyboard test version 1. Press ESC on matrix to exit
   - controls caps lock light
   - does not properly control screen wrap/display or handle special characters: tab, enter, backspace, arrows etc.
 - added joystick test version 1. Press ESC on matrix to exit. only left joystick tested.
   - right joystick to come
   - second trigger button to come
 - centered diags version display
 - bugfixes, subroutine cleanups, general code cleanups
 - more camelCase fixups
 - Menu table size auto-calculated at assembly time
 - Menu elements can be rearranged 
 - TEC-1G font updated to match MON-3
 - removed need for menu items to be stored with leading space

### 2023.b8
 - hexpad keys made to work more like MON3 - beep on keypress, 7seg not blanked
 - hexpad test has how to exit test help message displayed
 - proper 16 bit adds when calculating offsets; allows high byte to change mid-table
 - Shift renamed Fn
 - LED Bar cycles all 8 segments
 - Shadow test now fully checks that there really is RAM and not ROM or empty space present
 - possible bug calling High ROM code before JP high is performed, fixed
 - more utility routines preserve registers
 - camelCase used correclty on most labels, equates etc.

### 2023.b7
- replaced beep sound speaker test with MON-1 tune
- split into more individual source files for ease of management, editor tolerance and modularised workflow
- added diags version info to menu. diasplays diags version strings
- hexpad test now displays the key name and also if shift is pressed, on LCD line 4
- rewrote menu and burnin to work better and be more generic/reusable
- G.INPUT status - high or low. Can test with a jumper as the pinout puts the input bit and +5v next to each other; default is pulled down to logic 0
- 7-seg burn in, indicate scanned vs. hard-on lamp tests (should be differences in brightness and current consumption)

### 2023.b6
- return matrix test to the menu
- led bar scrolls both ways, faster, 3 times over. Overrides whatever mode things are in temporarily (EXPAND, PROTECT not honoured. SHADOW is honoured)
- consistent use of delay throughout. custom delay were needed. calls dly
- fix nnnn bytesss (ram test) when a following block is smaller than a prior block (lcd refresh issue)
- tests for EXPAND to verify page switching actually works (write differnet data to each page and read it back)

### todo
- lcd tests; do a few fancy things to show off the LCD so the user can see it in action
- improve serial/FTDI port tests. Needs serial IO routines(?FDX ?Possible). not sure we can do full duplex ?
- pip sound on matrix press ?
- redo matrix code for proper debounce
- The LCD does not have a " \ " character. Produces the Yen symbol instead. Possible remap/custom char ?
- display CART signature string (risky?) [BFFFh must be 0]
- RAM test detects and does not overwtite it's own buffers
- docco ram test subroutine parameters
- matrix typing proper 2x20 edit window
- pi test scroll the result; more digits ?
- 2 joysticks to be tested

 
### general notes

Diags_Shadow.asm is the portion of code running at 0000h - this source code is rather special in that it tricks the assembler into building it in a way that will produce a single binary file for burning into a ROM, yet run from shadow space. If I didn't do it this way, the assembler would turn out a 48k+ file (code at 0000h + code at C000h) which of course wouldn't be easily usable to burn into a ROM.

There is some duplication of code and also some strange conventions such as jp (hl) instead of call. This is beacuse the code must run even without RAM fitted - so no stack operations or memory variables are permitted.

Similarly, the interupt vectors are simply 'do nothing' stubs that return control to the main program.

Diags_Main.asm runs in normal ROM space (From C300h) - by this point basic system health is confirmed and normal stack, memory variables etc. can be used.

Diags_includes.asm contains only constants (equates). These can be altered as needed for testing different hardware combinations, or even making the code run on an 8K 1F, for example.

## Startup Test Sequence

Clears the system latch port FFh to value 00h. This ensures that if a JP 0000h executes, ROM always regains contol - even if RAM is bad or if SHADOW was previously disabled.

JP's to 0100h

Sets IM1 but disables interrupts

Sets stack to 3FFFh in readiness, but doesn't use it yet. 3FFFh in case write protect is being funky.

Plays a startup tone

Logs Checkpoint 0

Runs a series of tests, outputs a digit to the right-most 7-seg display as it does each test. The display is not scanned, it's set statically at full brighness. These are called checkponts, consider them the same as POST diagnostic codes on a PC.

### Checkpoint List

- 0 - start of diagnostics (Powered up, minimal activity)
- 1 - LCD not found (Error Halt)
- 2 - LCD found
- 3 - LCD Written to
- 4 - RAM check Failed
- 5 - RAM check Passed
- 6 - Stack Passed
- 7 - Interrupts Enabled
- 8 - JP to high ROM failed  (Error Halt)
- 9 - JP to high ROM passed
- D - CARTridge detected
- E - SHIFT key pressed (Error Halt)
- F - 74c923 key pressed (Error Halt)

Any fatal errors result in HALT being executed - HALT light will come on.

Checkpoints E and F only occur if a key being pressed is detected as the diagnostics starts up.

Checkpint D is displayed only if the CARTridge line is detected as active.

After checkpoint 9, all further info is conveyed via the LCD, as the system is considered healthy enough to run normal code.

The checks are somewhat self-evident ; e.g. displaying the Program counter confirms the JP to C300h worked.

### RAM Check

Quickly verifies there is R/W memory at the first and last byte of the expected RAM memory space (0800h and 7FFFh) by writing a test pattern and reading it back.

### Stack test

Pushes the memory location of the start of the next block of code onto the stack, then does a RET which pops it off the stack. If code worked, the stack must work. Stack location is set at 3FFFh - the top of memory that can't be PROTECTed.

### Config register test

The config register value is reading back the bits of port 03h - the value will change as the config dipswitches are changed.

The system default config respects the position of the EXPAND dipswitch & sets the system latch port FFh accordingly.

### Shadow ROM test

- disables interrupts
- turns off shadow
- fills the first 100h bytes with FFh
- CRC16 checksums that block to make sure it really worked. HALTs if failed.
- copies the zero-page data from ROM at C000h to RAM at 0000h (so interrupt vectors still function)
- enables interrupts
- takes a CRC16 checksum of the 100h bytes at both 0000h and C000h
- Test passes if checksums match

Writing FFh followed by the checksumming ensures that actual RAM was written to and not just the ROM still there. By checksumming the FFs to ensure they are really written, guarantees it is RAM and not ROM or empty space we are accessing.

### Bank 1 WP test

Bank 1 Write Protect toggles the WP line and verifies memory is/isn't writeable at 4000h

### Main Menu

We then arrive at a menu - select a test with + and - on the HexPad and press GO

Note: to exit the HexPad test - Shift+ADDR

Note: The RAM test is not super comprehensive, but is good enough to work out how many Kb are fitted. It is not meant to thoroughly check the actual RAM chip, nor does it look for address clashes (i.e. address decoder errors). Modern RAM is considered reliable enough. The default TEC-1G result on Diags startup should be 32768 bytes found unless the expansion is also populated wth a 32k RAM chip, in which case its 49152 bytes.
Each RAM memory block displayed is accompanied with a beep - two beeps, two blocks found. Read the LCD carefully for block info.

Toggling the SHADOW, PROTECT and EXPAND lines and running the RAM test will demonstate (by the different memory sizes reported) that these controls work --> when PROTECT is active, bank 1 does not act as RAM, so it's not found, as expected. When SHADOW is active, the bottom 2k canont be seen. With EXPAND if a second RAM chip is fitted, the RAM test will see it as a seond memory block.

The burn in check runs all non-interactive tests in a loop - with a counter keeping track of passes completed. Press any HexPad key to reboot the machine.

## assumptions and notes

- TEC-1G hardware only; may also work on older hardware if enough RAM is fitted.
- Assumes 32k RAM fitted at U8; will work with 16k but not less due stack location. 8k not supported anyhow!!!
- Will run at least partly without any working RAM at all
- LCD must be fitted to progress beyond first couple of tests; LCD is considered essential. 20x4 LCD assumed; works with 16x2 but a lot of info is missing
- Will work at any clock speed
- does not need matrix latch chips (74xx245), 74c923 keyboard chip, System Input 74xx373 or the display latches (2x 74xx273) fitted to run at least something useful
- FTDI test requires a loopback jumper connected between the Tx and Rx pins. The FTDI module must be removed

## build process

Assemble Diags_Main.asm - it pulls in everything else needed.

I have used TASM as my assembler; I used the -80 -b commandline parameters to turn out a binary file that is ready to burn

Code should assemble with most Z80 assemblers with little to no modification.

Burn the resulting binary into a ROM and plug into the ROM socket of the 1G, power up and enjoy.
