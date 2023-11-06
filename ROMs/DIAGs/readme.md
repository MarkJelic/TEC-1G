# Diags - Diagnostic, Test and Demo ROM for the TEC-1G

## Release 1.0
Burn to ROM at 0000 offset in the ROM itself, plug into the 1G and turn on. Requires a 16k ROM for correct results.

# General Notes
Diags_Shadow.asm is the portion of code running at 0000h - this source code is rather special in that it tricks the assembler into building it in a way that will produce a single binary file for burning into a ROM, yet run from shadow space. If I didn't do it this way, the assembler would turn out a 48k+ file (code at 0000h + code at C000h) which of course wouldn't be easily usable to burn into a ROM.

There is some duplication of code and also some strange conventions such as jp (hl) instead of call. This is beacuse the code must run even without RAM fitted - so no stack operations or memory variables are permitted.

Similarly, the interupt vectors are simply 'do nothing' stubs that return control to the main program.

Diags_Main.asm runs in normal ROM space (From C300h) - by this point basic system health is confirmed and normal stack, memory variables etc. can be used.

Diags_includes.asm contains only constants (equates). These can be altered as needed for testing different hardware combinations, or even making the code run on an 8K 1F, for example.

## Startup Test Sequence
Clears the system latch port FFh to value 00h. This ensures that if a JP 0000h executes, ROM always regains control - even if RAM is bad or if SHADOW was previously disabled.

JP's to 0100h

Sets IM1 but disables interrupts

Sets stack to 3FFFh in readiness, but doesn't use it yet. 3FFFh is used in case write protect is not working as expected

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
- 6 - Stack Check Passed
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

The checks are somewhat self-evident ; e.g. displaying the Program counter confirms the JP to C300h worked and we are running from native ROM memory, not shadow.

### RAM Check
Quickly verifies there is R/W memory at the first and last byte of the expected RAM memory space (0800h and 7FFFh) by writing a test pattern and reading it back. This is only a quick check to verify that RAM memory is present as expected, but is not a full memory test.

### Stack test
Pushes the memory location of the start of the next block of code onto the stack, then does a RET which pops it off the stack. If code worked, the stack must work. Stack location is previously set at 3FFFh - the top of memory that can't be PROTECTed.

### Config register test
The config register value is reading back the bits of port 03h - the value will change as the config dipswitches are changed or various other system operation bits are active.

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
We then arrive at the main menu - select a test with + and - on the HexPad and press GO to perform the test. Results are displayed on the LCD and/or the relevant device is activated. Once completed, the test exists back to the menu.

Note: to exit the HexPad and Joystick tests - press **Shift+ADDR**

Note: The RAM test is not super comprehensive, but is good enough to work out how many Kb are fitted. It is not meant to thoroughly check the actual RAM chip, nor does it look for address clashes (i.e. address decoder errors). Modern RAM is considered reliable enough. The default TEC-1G result on Diags startup should be 32768 bytes found unless the expansion socket is also populated wth a 32k RAM chip, in which case its 49152 bytes.
Each RAM memory block displayed is accompanied with a beep - two beeps, two blocks found. Read the LCD carefully for block info.

Toggling the SHADOW, PROTECT and EXPAND lines and running the RAM test will demonstate (by the different memory sizes and block(s) reported) that these controls work.

# Experiments with Diags
## Burn-in Mode
The burn in check runs all non-interactive tests in a continuous loop - with a counter keeping track of passes completed. Press any HexPad key to reboot the machine.

This is useful for confirm the machine is operating reliably and stably; any lock-up, crash, display corruption or other deviation could indicate a machine fault of some sort. Typically a machine is left running burn-in for a few hours or even overnight, and later checked to see things are still running as expected.

Common causes of random burn-in failures include insufficient or bad power from the power supply; faulty RAM, dry joints/poor assembly, bad ICs or an unstable CPU clock. Obviosly there are many potential cusues but burn-in is a good way to 'exercise' the machine by making it use all of it's components fully, so as to be sure it works reliably under any conditions.

## Disco Interactive
Press hexpad keys to adjust the R, G and B intensity of the Disco LEDs. Press ADDR to exit test.

R - 4 increase, 0 decrease
G - 5 increase, 1 decrease
B - 6 increase, 2 decrease

Note that most RGB LEDs have a stronger R output, and a weaker B output - the B value generally has to be a lot higher to get a similar light output, meaning that quite different values are needeed to get a "white" colour output.

'water clear' RGB LEDs may not be able to adequately mix the R, G and B light to achieve an overall white effect; we have found the regular frosted LEDs to be the better choice.

Also, different brands of LED have different characeristics, and so values needed to produce any given colour may vary quite a lot between brands.

## RAM tests
This is a more extensive memory test, which checks memory locations by writing various bit-patterns then reading them back. The test is non-destructive and leaves memory contents in its original state afterwards. Currently the test patters 00 FF 55 and AA are used.

This test does not check all RAM thoroughly, as e.g. it can't test itself without corrupting its own program code, nor does it test every single memory byte. The aim here is to demonstrate simple checks of e.g. address and data bus basic functions. The test is not designed to verify the memory chip itself; we assume that SRAM chips are reliable. However, the tests could be enhanced to offer this ability with some additional work.

The RAM Test respects the SHADOW, PROTECT and EXPAND states.

Try the following:

 - run RAM Test. Note 32k reported from 0000h - 7FFFh (Assuming a standard 32k 1G)
 - Enable PROTECT (Note PROTECT light comes on)
 - re-run RAM test. Note 16k reported from 000h - 3FFFh. This means the second 16k (Bank 1) of RAM is now not RAM any more. Protect makes it read-only, hence it is no longer RAM
 - Enable SHADOW (Leave PROTECT enabled; both PROTECT and SHADOW lights on)
 - re-run RAM test. Note 14k reported from 0800h - 3FFFh. Now the bottom 2K is not RAM thanks to shadow replacing it with the system ROM.
 - Disable PROTECT (Leave SHADOW enabled)
 - re-run RAM test. Note 30k reported - 0800h to 7FFFh. As expected.

In ths way, the functions of SHADOW and PROTECT are verified.

For those with a second RAM chip fitted to the 1G, the same tests can be re-run.
 - by Default, 48k is recognized from 0000h - BFFFh
 - Note that with PROTECT enabled, two separate 16k RAM blocks are observed - Bank 0 and Bank 2; with SHADOW and PROTECT enabled, the first block is reported as 14k in size.
 - Note that EXPAND makes no difference - The RAM test simply works with whatever memory it sees mapped into the Z80's address space and does not care which page is selected.

## Geral input bit test
Should normally read as Low. Connecting the G.Inp bit pin high or low should read accordingly. This bit will be used in a future project add-on for the 1G.

## 7-seg Lamp test
This test lights every possible segment of the 7-seg displays.

The first test 'scanning' mode uses display scanning (normal operation mode) where each of the 6 digits is lit 1/6th of the time.
The second test 'Latched' mode locks all the segments of all 6 disaplys simultaneously hard on (no scanning)

Visually, there may be little observable difference tetween the two tests; however the current drawn by the machine from the power supply should noticably increase when the segments are Latched, as there are six times as many LEDs lit vs. scanned mode.

The lack of noticeable display brightness change between the two modes demonstrates how well our eyes and brain make up for what is really 1/6th the light output of each digit.

## Speaker test
The speaker test comes with one non-obvious check: clock speed. The pitch and speed of the notes is directly related to the CPU clock speed. At 4MHz the tune plays in around 12 seconds. If you select the slow clock and adjust the speed pot while playing the tune, you can observe the tune's speed and pitch changing in real time.

Even at the fastest setting, the slow clock is somewhere around 4 to 8 times slower, showing the original TEC clock speed is around 500KHz (with some uncertainty - it's not a true linear relationship).

## Calculate Pi
This routine shows the Z80's computational skills. It uses the Spigot method to calculate Pi to 100 decimal places (Yes it really is calculating Pi in real time...not just repeating a pre-programmed value). You can check the Z80's work if you like!

3.14159265358979323 8462643383279502884 1971693993751058209 7494459230781640628 6208998628034825342 1170679

This code was taken from https://github.com/GmEsoft/Z80-MBC2_PiSpigot/tree/master and is used with thanks under the terms of the GPL v3 License.

## FTDI Tx Rx tests
Receives characters from the serial to the LCD. Acts as a simple serial typewriter.
Transmits hexpad keys to the serial port

Press **ADDR** to exit

**Note** that because this test is pseudo "full duplex" it can not handle full speed serial IO - the characters will corrupt if sent at faster than 'human typing' speed due to the delays needed when updating the LCD.

The bitbang serial is really only half duplex and has very few clock cycles to spare, so this test relies on working at 'human speed' only.

## FTDI loopback test
**Remove FTDI Module** and connect TX and RX pins with a Jumper. Test passes if signals sent on TX are received on RX.

It is _normal_ for this test to fail with an FTDI module fitted, or the FTDI socket empty!!

This test is primarily available for those who want to test the TEC stand-alone, those without an FTDI module, or simply no computer to run the FTDI Tx Rx tests with.

## Joystick port test
Wiggle the joystick or press fire to start the test; icon moves around the LCD in response to user input.

Fire changes the icon character on the LCD.

**Fire 2** or **ADDR** exits test.

## Assumptions and notes
- TEC-1G hardware only; may also partially work on older TEC hardware if enough RAM is fitted.
- Assumes 32k RAM fitted at U8; will work with 16k but not less due stack location.
- Will run at least partly without any working RAM at all. This allows for some very basic troubleshooting even with a very sick machine.
- LCD must be fitted to progress beyond first couple of tests; LCD is considered essential. 20x4 LCD assumed; works with 16x2 but a lot of info is missing.
- Will work at any clock speed, but 4.0MHz is recommended - some tests wil lbe very slow at lower clock speeds and FTI will be affected also.
- Does not need matrix latch chips (74xx245), 74c923 keyboard chip, System Input 74xx373 or the display latches (2x 74xx273) fitted to run at least something useful.
- 8x8 tests require the TEC-1G 8x8 LED display module, connected at ports 05h and 06h via the TEC Expander port. If the 8x8 is not fitted there will be a 10 second pause while the tests run.
- any test can generally be be exited with the ADDR key at any time. Hexpad test press Fn-ADDR to exit.
- any Hexpad key exits burn-in mode; Diags will reboot when pressed. This is done by patching the keyboard Interrupt Routine whilst in burn-in mode.

## Build process
Assemble Diags_Main.asm - it pulls in everything else needed.

I have used TASM as my assembler; I used the -80 -b -fFF commandline parameters to turn out a 16k binary file that is ready to burn.

Code should assemble with most Z80 assemblers with little to no modification.

Burn the resulting binary into a ROM and plug into the ROM socket of the 1G, power up and enjoy.
