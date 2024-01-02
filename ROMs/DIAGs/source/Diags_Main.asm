; ----------------------------------------------------------------------------
;	TEC-1G Diagnostics
;
;	Copyright (C) 2023, Craig Hart. Distributed under the GPLv3 license
;
;	This portion of the code runs from C300h. Shadow is disabled partway
; ----------------------------------------------------------------------------

#include "Diags_includes.asm"
#include "Diags_shadow.asm"

	.ORG HIROM+HIBASE

; program counter display

	call savesp		; save PC for later (not really a call)

savesp:	ld a,(SEGMNT+9)		; High ROM jump passed - Checkpoint 9
	out (SEGS),a

	ld c,lcdCls		; clear the LCD
	call lcdCommand

	ld hl,pcmsg		; display program counter msg
	call lcdStr

	pop bc			; recover PC from earlier 'call'
	ld hl,pcBuff
	call wordToBuff
	ld hl,pcBuff
	call lcdStr

	call delay

; OK done with POST codes now - tun off 7seg

	xor a			; clear 7-seg
	out (SEGS),a

; check config register test

	ld c,lcdRow2
	call lcdCommand
	call readCfgReg

; setup defaults as selected from the config register

	in a,(SIMP3)		; set extend desired default
	and EXPAND
	ld (cfgMode),a
	out (SYSCTRL),a

; turn off shadowing test

	ld c,lcdRow3
	call lcdCommand
	ld hl,shad		; display the name of this test
	call lcdStr

	di			; no interupts while we do critical things
	ld a,(cfgMode)		; shadow off command to port ffh
	or SHADOW		; set shadow off
	ld (cfgMode),a
	out (SYSCTRL),a

; store all FF's on purpose
	ld hl,0000h
	ld de,0001h
	ld bc,00ffh		; n-1
	ld a,0ffh
	ld (hl),a
	ldir			; fill first 100h bytes with FF

; we verify this is RAM first, by reading it back and verifing the result

	ld ix,0000h
	ld de,0100h
	call crc16

	ld de,5B2Fh		; ALL FF's  -> 5B2Fh

	or a			; HL (computed) == DE (expected)?
	sbc hl,de
	add hl,de
	jr z,copyBase

	halt			; shadow fail

; if we get here, shadow works theres realy ram there
; copy base 100h bytes - so the interrupt vectors work

copyBase:
	ld hl,0c000h		; copy bottom 256 bytes of ROM to RAM at 0000
	ld de,0000h
	ld bc,0100h
	ldir
	ei			; done with critical stuff

; now check it to make sure that worked

	ld ix,0c000h		; get CRC of ROM
	ld de,0100h
	call crc16
	ld (ROMCRC),hl

	ld ix,0000h		; get CRC of RAM - should match
	ld de,0100h
	call crc16
	ld (RAMCRC),hl

	ld de,(ROMCRC)

; 16-bit compare
; IF HL equals DE, Z=1,C=0
; IF HL is less than DE, Z=0,C=1
; IF HL is more than DE, Z=0,C=0

	or a			; HL (computed) == DE (expected)?
	sbc hl,de
	add hl,de

	ld hl,pass
	jr z,shres

	ld hl,fail

; did we pass or fail?

shres:	call lcdStr
	call delay

; write protection of RAM bank 1 check

	ld c,lcdRow4
	call lcdCommand
	call wrprot

; setup menu & system state

menuInit:
	xor a
	ld (menuPos),a		; menu draw from first slot
	ld (menuSel),a		; menu selected first item
	ld hl,menuTable
	ld (menuMenu),hl	; default menu
	ld (menuNest),a		; top level
	ld a,menuLen
	ld (menuLength),a
	ld hl,menutitle
	ld (menuTitl),hl

	ld (capsval),a		; capslock off


	ld a,40h
	ld (kState),a		; no HexPad key pressed

	ld a,0ffh
	ld (kFlag),a		; hexpad key not pressed
	ld (kdelayval),a	; matrix delay on keypress


; --------------------------------------------------
;
;  MAIN MENU
;
; --------------------------------------------------

menu:	ld c,lcdCls
	call lcdCommand

	ld hl,(menuTitl)
	call lcdStr

	call drawMenu
	call getKey

	and 1fh				; Mask off Shift
	bit 4,a				; ignore keys <10h
	jr z,menu

; work out which routine to go to

	sub 10h				; make it 0, 1, 2 or 3
	rla				; *2 - 2 bytes per entry

	ld hl,menu			; save RET address on stack
	push hl

	ld hl,menuJP
	ld b,0
	ld c,a
	add hl,bc

	ld a,(hl)			; look  up hl string location in the table
	inc hl
	ld h,(hl)
	ld l,a

	jp (hl)

menuJP:	.dw isPlus, isMinus, isGo, isAddr	; JP table

;------------

isPlus:
	ld a,(menuLength)
	ld b,a
	ld a,(menuSel)
	cp b				; at max already ?
	ret z				; if max, bail
	inc a				; otherwise update
	ld (menuSel),a			; save new selection
	ld c,a				; copy A to C
	ld a,(menuPos)			; get menu display position
	add a,03			; for coming up CP
	ld b,a				; b = menu pos
	ld a,c				; a = menu sel
	cp b				; if (b+3)>a then no change
	ret c				; return if >
	ld a,(menuPos)			; update menuPos
	inc a
	ld (menuPos),a
	ret

isMinus:
	ld a,(menuSel)			; get current
	dec a				; decrease by 1
	ret m				; if result <0, exit as we aready at top
	ld (menuSel),a			; save new position
	ld c,a				; store new pos in c
	ld a,(menuPos)			; do we need to scroll the list?
	ld b,a				; b = menu pos
	ld a,c				; a = sel pos
	cp b				; compare
	ret nc				; no action if in range
	ld (menuPos),a			; otherwise update menu pos
	ret

isGo:
	ld c,lcdCls			; setup LCD
	call lcdCommand
	ld c,lcdRow2
	call lcdCommand

	ld a,(menuSel)			; display selected test name
	ld hl,(menuMenu)
	call setMenuPtr
	call lcdStr

	ld e,c				; C => E for use in a moment
	ld c,lcdRow3			; select outpout row
	call lcdCommand

	ld hl,menuRet			; save RET address on stack
	push hl
	ld h,b				; BE => HL. That's not a typo
	ld l,e
	jp (hl)				; 'call' the routine

	halt				; should never run (returns to menu)

menuRet:
	call getKeyNoScan		; no beep if no key
	jp nz,menu

keyUp:	call getKeyNoScan		; wait for release
	jp z,keyUp
	call tone			; and beep
	jp menu


isAddr:
	ld a,(menuNest)
	cp 0
	ret z				; exit if already at top level

	ld hl,menutitle			; reset title
	ld (menuTitl),hl

	ld hl,(parentMenu)		; return to top level
	ld (menuMenu),hl

	ld a,(oldMenuLen)		; reset menu length
	ld (menuLength),a

	ld a,(oldMenuPos)
	ld (menuPos),a

	ld a,(oldMenuSel)
	ld (menuSel),a

	xor a
	ld (menuNest),a
	ret
	
; -----------------------------------
;  Draw the menu
; -----------------------------------

drawMenu:
	ld hl,menuLength		; setup B
	ld a,(hl)
	ld e,a
	inc e

	ld c,lcdRow2+1
	call lcdCommand
	ld a,(menuPos)
	cp e
	jr nc,putPtr

	ld hl,(menuMenu)
	call setMenuPtr
	call lcdStr

	ld c,lcdRow3+1
	call lcdCommand
	inc a
	cp e
	jr nc,putPtr
	ld hl,(menuMenu)
	call setMenuPtr
	call lcdStr

	ld c,lcdRow4+1
	call lcdCommand
	inc a
	cp e
	jr nc,putPtr
	ld hl,(menuMenu)
	call setMenuPtr
	call lcdStr

; position pointer

putPtr:	ld a,(menuPos)
	ld b,a
	ld a,(menuSel)
	sub b

; a = 0 , 1 or 2. Which row to put pointer ?
	jr nz,try3

	ld c,lcdRow2
	jr drawPointer

try3:	cp 1
	jr nz,try4

	ld c,lcdRow3
	jr drawPointer

try4:	ld c,lcdRow4

drawPointer:
	call lcdCommand

	call lcdReady
	ld a,0a5h			; pointer ASCII code (square block)
	out (LCDDATA),a

	ret

; -----------------------------------------------------
; setMenuPtr
;  call:
; A: location in menu required
; HL: menu table (4 bytes per)
;  returns :
; BC: points to jp offset
; HL: points to start of menuTable Entry currently selected
; -----------------------------------------------------

setMenuPtr:
	push af
	push de

	add a,a				; a = a *4 because 4 bytes per entry
	add a,a
	add a,2				; + 2 to get the JP first

	ld d,0
	ld e,a
	add hl,de			; add offset to find the table position we need

	ld a,(hl)			; lookup bc jp location
	inc hl
	ld b,(hl)
	ld c,a

	dec hl				; go back 3 bytes
	dec hl
	dec hl

	ld a,(hl)			; look  up hl string location in the table
	inc hl
	ld h,(hl)
	ld l,a
	pop de
	pop af
	ret

; -----------------------------------------------------
; doGPIOMenu Sets up the GPIO sub-menu
; -----------------------------------------------------

doGPIOMenu:
	ld hl,GPIOtitle
	ld (menuTitl),hl

	ld hl,(menuMenu)
	ld (parentMenu),hl
	ld hl,GPIOMenu
	ld (menuMenu),hl

	ld a,(menuLength)
	ld (oldMenuLen),a

	ld a,GPIOmenuLen
	ld (menuLength),a

	ld a,(menuPos)
	ld (oldMenuPos),a
	ld a,(menuSel)
	ld (oldMenuSel),a
	xor a
	ld (menuPos),a		; menu draw from first slot
	ld (menuSel),a		; menu selected first item

	inc a
	ld (menuNest),a		; not top level

	ret

; -----------------------------------------------------
;  LCD stuff
; -----------------------------------------------------

lcdTest:
	ld c,01
	call lcdCommand
	ld a,20h
	
lcdLoop1:
	call lcdFillChar		; cycle chars demo
	call lcdDelay
	inc a
	cp 80h
	jr nz, lcdLoop1

	ld a,0ffh		; solid block
	call lcdFillChar
	call delay

; ------
	ld c,40h		; load custom characters
	call lcdCommand

	ld b,8*8
	ld hl,lcdCustom
fillCustom:
	call lcdReady
	ld a,(hl)
	out (LCDDATA),a
	inc hl
	djnz fillCustom

	ld c,01			; draw custom screen demo
	call lcdCommand
	ld hl,lcdText
	call lcdFillBuff
	call delay
; ----
	ld b,08			; how many times

lcdAnimSq:
	ld a,0dbh		; open squares
	ld c,80h
	call lcdChar
	ld c,93h
	call lcdChar
	ld c,0d4h
	call lcdChar
	ld c,0e7h
	call lcdChar
	call lcdDelay
	call lcdDelay

	ld a,0a5h		; closed squares
	ld c,80h
	call lcdChar
	ld c,93h
	call lcdChar
	ld c,0d4h
	call lcdChar
	ld c,0e7h
	call lcdChar
	call lcdDelay
	call lcdDelay

	djnz lcdAnimSq
	call delay
; -----
	ld a,20h		; wipe effect
	ld b,40
	ld d,80h
	ld e,0e7h

wipeLoop:
	ld c,d
	call lcdChar
	ld c,e
	call lcdChar
	inc d
	dec e
	call lcdDelay
	djnz wipeLoop
	ret

; ------
lcdDelay:
	push bc
	ld c,060h
lcdDly2:
	ld b,0ffh
lcdDly:	djnz lcdDly
	dec c
	jr nz, lcdDly2
	pop bc
	ret
; ------
lcdChar:
	call lcdCommand
	call lcdReady
	out (LCDDATA),a
	ret	
; ------
lcdFillChar:
	ld b,40			; how many bytes
	ld c,80h		; postion memory
	call lcdCommand
	call lcdFill1

	ld b,40			; how many bytes
	ld c,0C0h		; postion memory
	call lcdCommand

lcdFill1:
	call lcdReady
	out (LCDDATA),a
	djnz lcdFill1
	ret
;------
lcdFillBuff:
	ld b,40
	ld c,80h		; postion memory
	call lcdCommand
	call lcdFill2

	ld b,40
	ld c,0C0h		; postion memory
	call lcdCommand

lcdFill2:
	call lcdReady
	ld a,(hl)
	out (LCDDATA),a
	inc hl
	djnz lcdFill2
	ret

; -----------------------------------------------------
;  do diag BAR LEDs actions
; -----------------------------------------------------

ledBar:
	ld b,03h		; do 3 full cycles

plp:	ld c,01h
	ld d,0a1h		; for lcd

stlp:	ld a,c			; send it up
	xor 1
	out (SYSCTRL),a
	call updateLcdBar
	call barDly
	call barDly
	sla c
	dec d
	jr nc, stlp
	ld c,40h
	ld d,09bh

strp:	ld a,c			; send it down
	xor 1
	out (SYSCTRL),a
	call updateLcdBar
	call barDly
	call barDly
	srl c
	inc d
	ld a,c
	cp 01h
	jr nz,strp

	djnz plp		; next full cycle

	xor 1
	out (SYSCTRL),a		; final segment to light
	call updateLcdBar
	call barDly
	call barDly

	ld a,(cfgMode)		; reset to normal
	out (SYSCTRL),a
	ret

barDly:	push af
	push de
	ld de,BDELAY

bDly:	dec de
	ld a,d
	or e
	jr nz,bDly
	pop de
	pop af
	ret

;------
updateLcdBar:
	push af
	push bc
	ld c,099h
	call lcdCommand
	ld hl,barText
	call lcdStr
	ld c,d
	call lcdCommand
	call lcdReady
	ld a,0ffh
	out (LCDDATA),a
	pop bc
	pop af
	ret

; -----------------------------------------------------
;  do some 7-seg scrolling text stuff
; -----------------------------------------------------

segs:	xor a			; setup starting location
	ld (segptr),a


scrol:	ld hl,SCRSEG		; set message location

	ld a,(segptr)		; add start char offset
	ld c,a
	ld b,0
	add hl,bc

	ld de,segbuf		; load display buffer
	ld bc,6			; 6 bytes
	ldir

	ld de,0100h		; how many scans / how long

scllp2:	call scan7Seg		; light the segs
	dec de
	ld a,d
	or e
	jr nz, scllp2

	ld a,(segptr)		; 'scroll' the message
	inc a
	ld (segptr),a
	cp 016h			; message done ?
	jr nz, scrol
	ret

; -----------------------------------------------------
;  do 7-seg lamp test
; -----------------------------------------------------

segs2:	ld a,0ffh		; load display buffer all on
	ld hl,segbuf
	ld b,6

sfill1:	ld (hl),a
	inc hl
	djnz sfill1

	ld hl,burnScan
	call lcdStr

	ld de,0600h		; how many scans / how long

scllp3:	call scan7Seg

	dec de
	ld a,d
	or e
	jr nz, scllp3

	ld a,00h		; load display buffer all off
	ld hl,segbuf
	ld b,6

sfill2:	ld (hl),a
	inc hl
	djnz sfill2

	ld c,lcdRow3
	call lcdCommand
	ld hl,blankString
	call lcdStr

	ld de,0200h		; how many scans / how long

scllp1:	call scan7Seg

	dec de
	ld a,d
	or e
	jr nz, scllp1

	ld c,lcdRow3
	call lcdCommand
	ld hl,burnLatch
	call lcdStr

; hard on

	ld a,03fh
	out (DIGITS),a

	ld a,0ffh
	out (SEGS),a

	call delay
	call delay

	xor a
	out (DIGITS),a
	out (SEGS),a

	ld c,lcdRow3
	call lcdCommand
	ld hl,blankString
	call lcdStr
	call delay
	ret

; ----------------------------------------------------------------
;  Bank 1 write protection test
; ----------------------------------------------------------------

; out: rTestResult: 0=pass, 1 = fail

wrprot:
	ld hl,wpchk		; test name
	call lcdStr

; 0 fill - needed to make sure initial ram contents is not conflicting junk

	ld a,01h
	out (SYSCTRL),a
	ld a,00h
	ld hl,RAMBL1
	ld (hl),a
	ld de,RAMBL1+1
	ld bc,3FFFh		; 16k-1 byte
	ldir			; fill
	ld a,(cfgMode)		; return to normal
	out (SYSCTRL),a

; fill with 55h and read back

	ld hl,RAMBL1		; should be RW to begin with
	ld a,55h
	ld (rTestByte),a
	ld (rTestLoc),hl
	call rBlockTest
	ld a,(rTestResult)
	cp 1			; this test should pass. if 1, we failed
	jr z,wFail

	ld a,(cfgMode)		; PROTECT on
	or PROTECT
	out (SYSCTRL),a

; fill with aah and read back. Should return 00h == fail

	ld hl,RAMBL1		; should fail now
	ld a,0aah
	ld (rTestByte),a
	ld (rTestLoc),hl
	call rBlockTest
	ld a,(rTestResult)
	cp 1			; this test should fail. if 0, we failed
	jr nz,wFail

	ld hl,pass
	jr wpres

wFail:	ld hl,fail

wpres:	ld a,(cfgMode)		; return to normal
	out (SYSCTRL),a

	call lcdStr
	call delay
	ret

; ----------------------------------------------------------------
;  Read config register test
; ----------------------------------------------------------------

readCfgReg:
	ld hl,cfgst
	call lcdStr
	ld hl,cfgst2
	in a,(SIMP3)		; read CFG register
	call toAscii
	ld a,'h'		; put rest of string into RAM
	ld (hl),a
	inc hl
	ld a,0
	ld (hl),a
	ld hl,cfgst2
	call lcdStr
	call delay
	ret

; ----------------------------------------------------------------
;  Read general input bit test
; ----------------------------------------------------------------

readGinput:
	ld hl,ginpStr
	call lcdStr
	ld hl,lo
	in a,(SIMP3)		; read CFG register
	and 20h
	jr z,inpMsg
	ld hl,hi

inpMsg:	call lcdStr
	call delay
	ret

; ----------------------------------------------------------------
;  Test the speaker
; ----------------------------------------------------------------

speaker:
	call musicRoutine
	ret

; ----------------------------------------------------------------
;  Beep sounds
; no registers needed or altered
; ----------------------------------------------------------------

pip:	push af
	push bc
	push hl

	ld c,0c0h		; pitch
	ld l,021h		; length
	xor a
	jr tlp2

tone:
	push af
	push bc
	push hl

	ld c,0c0h		; pitch
	ld l,081h		; length
	xor a
tlp2:	out (DIGITS),a
	ld b,c
tone2:	djnz tone2
	xor 80h
	dec l
	jr nz,tlp2

	ld b,0ffh
dly2:	djnz dly2

	pop hl
	pop bc
	pop af
	ret

; ----------------------------------------------------------------
;  Burn in
; ----------------------------------------------------------------

burn:	ld hl,0000h
	ld (burnLoops),hl

; setup key to exit by vectoring NMI back to cold start
; burn in always runs with shadow disabled

	ld a,(cfgMode)		; shadow off
	or SHADOW
	out (SYSCTRL),a

	ld a,0c3h		; setup JP instr for NMI
	ld (0066h),a
	ld hl,0000h
	ld (067h),hl

bloop:	xor a
	ld (menuSel),a

bloopIn:
	call bfsh

	ld a,(menuSel)
	ld hl,burnTable
	call setMenuPtr

	ld a,h			; look for 0000 to end a pass
	or l
	jr z,blDone

	ld h,b
	ld l,c

	ld bc,bptr		; set return address on stack
	push bc
	jp (hl)			; this is really a call to the test


bptr:	ld hl,menuSel		; step through the tests
	inc (hl)
;	ld (menuSel),a
	jr bloopIn


blDone:	ld hl,(burnLoops)	; step through the loops (forever)
	inc hl
	ld (burnLoops),hl

	jr bloop



bfsh:	ld c,lcdCls		; clear the LCD
	call lcdCommand

	ld hl,burnst
	call lcdStr

	ld hl,pcBuff		; loop counter display
	ld bc,(burnLoops)
	call wordToBuff

	dec hl			; mask off the 'h'
	xor a
	ld (hl),a

	ld hl,pcBuff
	call lcdStr

	ld c,lcdRow2
	call lcdCommand

	ld a,(menuSel)
	ld hl,burnTable
	Call setMenuPtr
	call lcdStr

	ld c,lcdRow3
	call lcdCommand

	ret

; ----------------------------------------------------------------
;  HexPad Check; shift-ADDR exits
; ----------------------------------------------------------------

hexPad:
	ld a,' '		; setup the blank line
	ld b,20
	ld hl,hexPadBuff

fLoop:	ld (hl),a
	inc hl
	djnz fLoop
	xor a
	ld (hl),a		; 21st byte null terminated

	ld c,lcdRow1
	call lcdCommand
	ld hl,hexExit
	call lcdStr

	ld c,lcdRow3
	call lcdCommand
	ld hl,hexMsg
	call lcdStr

	call getKey

	xor 20h			; flip bit 5
	cp 033h
	ret z

	ld e,a
	ld hl,pcBuff
	call toAscii

	xor a			; null terminate it
	ld (hl),a

	ld hl,pcBuff
	call lcdStr

	ld c,lcdRow4		; goto row 4 and blank it
	call lcdCommand

	ld hl,hexPadBuff
	call lcdStr

	ld c,lcdRow4
	call lcdCommand

	ld a,e
	bit 5,a
	jr z,noSh

	ld hl,fnMsg
	call lcdStr

noSh:	ld a,e
	and 01fh		; mask shift
	cp 10h
	jr c, notFunc

	sub 10h			; make it 0..3

	ld b,a			; multiply by 6
	sla a
	sla a
	add a,b
	add a,b

	ld c,a
	ld b,0

	ld hl,plusMsg		; find our string
	add hl,bc

	call lcdStr
	jp hexPad

notFunc:
	ld hl,cfgst2		; 0-F
	call toAscii
	ld (hl),0

	ld hl,cfgst2+1
	call lcdStr

	jp hexPad

; ----------------------------------------------------------------
;  FTDI Check; ESC or ADDR exits
; ----------------------------------------------------------------

FTDI:
	call setupBuff
	call buffToLcd
	ld a,40h
	out (DIGITS),a		; init serial
	ld a,44h
	out (SEGS),a		; disco blue = FTDI active

ftdiLoop:
	call rxByte		; FTDI in
	jr nc,outRx

	call getKeyNoScan	; HexPad Key ?
	jr nc, ftdiLoop		; ignore key held down
	jr z, hexKey		; process if key pressed

;including mtrix makes the serial too slow, and drops bits
;mat:	call KEYSCAN		; Matrix Key ?
;	ld a,e			; was there a keypress ?
;	cp 0ffh
;	jr z,ftdiLoop
;	cp 01bh			; exit if ESC pressed
;	ret z
;	call txByte		; send it

	jr ftdiLoop

hexKey:
	cp 13h			; exit if ADDR pressed
	ret z
	and 0fh			; convert to 0..F
	add a,90h
	daa
	adc a,40h
	daa
	call txByte		; send it
	jr ftdiLoop

outRx:	call buffAddChar
	call buffToLcd
	jr ftdiLoop


; ----------------------------------------------------------------
;  disco tests - non-interactive
; ----------------------------------------------------------------

disco:	ld b,8
	ld c,01h		; led segment
	ld d,03h		; how many full loops
	ld e,0			; string pointer 0..8..16..24

	ld a,40h
	out (DIGITS),a

disco1:
	push bc

	ld b,0			; setup string pointer
	ld c,e
	ld hl,red
	add hl,bc

	ld a,e			; move string pointer
	add a,8
	and 1fh
	ld e,a

	ld c,lcdRow3
	call lcdCommand
	call lcdStr

	pop bc

	ld a,c
	out (SEGS),a

	call barDly
	call barDly
	call barDly
	call barDly

	sla c
	djnz disco1

	ld c,01h
	ld b,8
	dec d
	jr nz,disco1

;-----------------

fadeIn:
	ld e,3

pwmRepeatLoop:
	xor a
	ld (rVal),a
	ld (gVal),a
	ld (bVal),a

	ld d,55h

pwmOuterLoop:
	call pwmDisco

	ld h,020h
shDely:	dec h
	jr nz, shDely

incDiscoValues:
	ld a,(rVal)
	inc a
	ld (rVal),a

	ld a,(gVal)
	inc a
	inc a
	ld (gVal),a

	ld a,(bVal)
	inc a
	inc a
	inc a
	ld (bVal),a

	dec d				; full range of brightness
	jr nz,pwmOuterLoop

	dec e				; repeat thw whole thing e times
	jr nz,pwmRepeatLoop

	xor a				; turn them off
	out (DIGITS),a
	out (SEGS),a
	ret

; ----------------------------------------------------------------
;  disco tests - interactive for user
; ----------------------------------------------------------------

discoInteractive:
	xor a
	out (SEGS),a
	ld (rVal),a
	ld (gVal),a
	ld (bVal),a
	ld a,40h
	out (DIGITS),a

	ld hl,discoInt
	call lcdStr

pwmInteractiveLoop:
	call pwmDisco
	call getKeyNoScan
	jr nz, pwmInteractiveLoop

	and 01fh
	cp 13h
	jr z,pwmInteractiveExit

	cp 7			; ignore unwanted keys
	jr nc,pwmInteractiveLoop
	cp 3
	jr z,pwmInteractiveLoop

	call pip		; key beep

	bit 2,a			; up?
	jr nz, upPwm

dnPwm:	ld d,0ffh		; + ff same as as - 1
	jr setHL

upPwm:	and 03h
	ld d,01h

setHL:	ld hl,rVal
	ld c,a
	ld b,0
	add hl,bc

updateVal:
	ld a,(hl)
	add a,d
	ld (hl),a

	ld hl,decimalBuff
	ld a,(rVal)
	call toAscii
	ld a,(gVal)
	call toAscii	
	ld a,(bVal)
	call toAscii

	ld hl,decimalBuff
	ld c,96h
	call digUpdate
	ld c,9bh
	call digUpdate
	ld c,0a1h
	call digUpdate

	jp pwmInteractiveLoop

pwmInteractiveExit:
	xor a
	out (DIGITS),a
	out (SEGS),a
	ret

digUpdate:
	call lcdCommand
	call lcdReady
	ld a,(hl)
	out (LCDDATA),a
	inc hl
	call lcdReady
	ld a,(hl)
	out (LCDDATA),a
	inc hl
	ret

;--------------------

pwmDisco:
	xor a
	out (SEGS),a
	ld a,40h
	out (DIGITS),a
	ld b,0ffh

pwmInnerLoop:
	ld c,0

setR:
	ld a,(rVal)
	cp b
	jr c,setG
	ld c,11h

setG:	ld a,(gVal)
	cp b
	jr c,setB
	ld a,c
	add a,22h
	ld c,a

setB:	ld a,(bVal)
	cp b
	jr c,setDisco
	ld a,c
	add a,44h
	ld c,a

setDisco:
	ld a,c
	out (SEGS),a
	djnz pwmInnerLoop
	ret

; ----------------------------------------------------------------
;  Matrix Keyboard Check; ESC or ADDR exits
; ----------------------------------------------------------------

matrix:
	ld c,0fh		; LCD cursor on + blink on
	call lcdCommand
	call setupBuff
	call buffToLcd

matrixLoop:
	call getKeyNoScan
	jr nz, ks
	cp 13h			; exit if ADDR pressed
	jr z,mExit

ks:	call KEYSCAN

	ld a,e			; was there a keypress ?
	cp 0ffh
	jr z,matrixLoop

	call pip

	cp 01bh			; ESC = quit
	jr z,mExit

	call buffAddChar
	call buffToLcd

	jp matrixLoop

mExit:
	ld c,0ch		; LCD Cursor off + blink off
	call lcdCommand
	ret

; ---------------------------------------------------------------------------

setupBuff:
	ld hl,tBuff
	ld b,tBuffSize
	ld a,20h
fillSpace:
	ld (hl),a
	inc hl
	djnz fillSpace
	xor a
	ld (tBuffPtr),a
	ret
;----
buffAddChar:
	cp 0dh			; enter
	jr z,enter
	cp 07h
	cp 07h			; bell
	jr z,ascii7
	cp 09h			; tab
	jr z,tab
	cp 7fh			; backspace
	jr z,bksp
	jr normalChar

;special characters handling here
; enter
enter:	ld a,(tBuffPtr)
	cp 20
	jr c,noScroll		; is row 4 already

	ld de,tBuff		; 4 => 3
	ld hl,tBuff+20
	ld bc,20
	ldir

	ld hl,tBuff+20		; blank out 4
	ld a,20h
	ld b,20
fillSpace2:
	ld (hl),a
	inc hl
	djnz fillSpace2

noScroll:
	ld a,20
	ld (tBuffPtr),a
	ret
; bell
ascii7:	call tone
	ret
; tab
tab:	ld a,20h
	call normalChar
	call normalChar
	call normalChar
	call normalChar
	ret

; backspace
bksp:	
	ld a,(tBuffPtr)
	cp 0
	ret z
	dec a			; already incremented earlier!
	ld (tBuffPtr),a
	ld hl,tBuff
	ld c,a
	ld b,0
	add hl,bc
	ld (hl),20h
	ret

normalChar:
	push af
	ld a,(tBuffPtr)
	cp tBuffSize-1
	jr nz,buffInsChar

	ld hl,tBuff+1		; make room
	ld de,tBuff
	ld b,0
	ld c,tBuffSize
	dec bc
	ldir
	dec a
	ld (tBuffPtr),a

buffInsChar:
	ld hl,tBuff
	ld c,a
	ld b,0
	add hl,bc
	inc a
	ld (tBuffPtr),a		; next char for next time
	pop af
	ld (hl),a
	ret
;----
buffToLcd:
	push bc
	push hl

	ld c,lcdRow3
	call lcdCommand
	ld hl,tBuff
	ld b,tBuffSize/2
	call loadLcd

	ld c,lcdRow4
	call lcdCommand
	ld b,tBuffSize/2
	call loadLcd

; position cursor

	ld a,(tBuffPtr)
	add a,94h		; start of row 3
	cp 0a8h
	jr c,noAdd

	add a,2ch		; start of row 4

noAdd:	ld c,a			; position cursor
	call lcdCommand

	pop bc
	pop hl
	ret

loadLcd:
	call lcdReady
	ld a,(hl)
	out (LCDDATA),a
	inc hl
	djnz loadLcd
	ret

; ----------------------------------------------------------------
;  Joystick Check; ESC exits
; ----------------------------------------------------------------

joy:
	ld a,10			; setup home position
	ld (joyX),a
	ld a,2
	ld (joyY),a
	ld a,20h
	ld a,'*'
	ld (joyChar),a


joyLoop:
	ld c,30h		; input speed control
bL:	ld b,0ffh
jDelay:	
	djnz jDelay
	dec c
	jr nz,bL

	call getKeyNoScan
	jr nz, ms
	cp 13h			; exit if ADDR pressed
	ret z

ms:	call matscan

	ld a,e			; get key
 	cp 0ch			; ESC = quit
	ret z

	cp 0ffh			; nokey
	jr z,joyLoop

u:	cp 18h			; up
	jr nz,d
	ld a,(joyY)
	dec a
	jp m,update		; min 0
	ld (joyY),a
	jr update

d:	cp 19h
	jr nz,l
	ld a,(joyY)
	inc a
	cp 4
	jr z,l
	ld (joyY),a
	jr update

l:	cp 1ah
	jr nz,r
	ld a,(joyX)
	dec a
	jp m,update		; min 0
	ld (joyX),a
	jr update

r:	cp 1bh
	jr nz,fire
	ld a,(joyX)
	inc a
	cp 20			; max 20
	jr z,update
	ld (joyX),a
	jr update

fire:	cp 01ch
	jr nz,fire2
	ld a,(joyChar)
	inc a
	and 2fh			; valid chars are 28h...2Fh
	or 08h
	ld (joyChar),a
	jr update

fire2:	cp 01eh			; fire 2 to exit (MSX)
	jp z,mExit
	cp 01dh
	jp z,mExit		; fire 2 to exit (Atari/Amiga)
	jp joyLoop

update:
	ld a,(joyX)
	ld c,a

	ld a,(joyY)
	add a,80h
	cp 80h
	jr z,joyOut

	cp 81h			; row 2
	jr nz,is3
	add a,0c0h-81h

is3:	cp 82h			; row 3
	jr nz,is4
	add a,94h-82h

is4:	cp 83h			; row 4
	jr nz,joyOut
	add a,0d4h-83h

joyOut:
	add a,c			; add in X

	ld c,lcdCls		; clear lcd
	call lcdCommand

	ld c,a
	call lcdCommand		; position cursor
	ld a,(joyChar)

	call lcdReady		; draw symbol
	out (LCDDATA),a

	jp joyLoop

; ----------------------------------------------------------------
;  8x8 checks / demo
; ----------------------------------------------------------------

ex8:
	ld b,0ffh	; V bar
	ld c,01h
exlp:	call e8anim
	sla c
	jr nc,exlp

	ld b,01h	; H bar
	ld c,0ffh
eylp:	call e8anim
	sla b
	jr nc,eylp

	ld a,01		; Fan Out
fanout:	out (ex8X),a
	out (ex8Y),a
	call barDly
	sla a
	inc a
	jr nc, fanout

	sla a

fanin:	out (ex8X),a	; And pick up our tail
	out (ex8Y),a
	call barDly
	sla a
	cp 0
	jr nz,fanin

blinky: ld b,03h	; strobe on and off

blilp:	xor a
	out (ex8X),a
	out (ex8Y),a
	call barDly
	dec a
	out (ex8X),a
	out (ex8Y),a
	call barDly
	call barDly
	djnz blilp

scrollText:			; scrolltext please
	ld hl,e8x8Buff
	xor a
	ld b,8		; 8 bytes
blankBuff:		; setup blank buffer
	ld (hl),a
	inc hl
	djnz blankBuff

	xor a		; starting values
	ld (scByte),a
	inc a
	ld (scBit),a

e8x8scanLoop:
	ld hl,e8x8Buff	; do a scan
	call ex8Scan

	ld e,0		; table rows (number of bytes in a character)

blk:	ld hl,pacTable

	ld a,(scByte)	; which byte the the nmessage are we up to?
	rlca		; *8 becuase 8 bytes per char in table
	rlca
	rlca
	ld c,a
	ld b,0
	add hl,bc	; point HL to correct source byte

	ld d,0		; add in our row
	add hl,de

	ld a,(scBit)	; how many bits ?
	ld b,a
	ld a,(hl)	; get our data

; prestage the next part to avoid killing CF later
	ld hl,e8x8Buff	; target
	ld d,0
	add hl,de	; E is our target row

rota:	rla		;rotate bit n into CF (from bit 7 down)
	djnz rota

	ld a,(hl)	; update destination table
	rla		; rotate CF into bit 0
	ld (hl),a	; this also 'scrolls' the buffer

	inc e		; 8 rows of table to fill
	ld a,e
	cp 8
	jr nz,blk

	ld a,(scBit)	; next bit
	inc a
	ld (scBit),a
	cp 9
	jr nz, e8x8scanLoop	; one byte done?

; if here, next byte

	ld a,1
	ld (scBit),a

	ld a,(scByte)		; one byte
	inc a
	ld (scByte),a

	cp 7			; last byte done?
	jr nz, e8x8scanLoop

; blankety blank - and goodbye

	xor a			; clear display
	out (ex8X),a
	out (ex8Y),a
	ret

; subroutine

e8anim:	ld a,b
	out (ex8Y),a
	ld a,c
	out (ex8X),a
	call barDly
	ret

; ----------------------------------------------------------------
;  8x8scan
; in: HL = buffer, 8 bytes, 1 bit per byte.
; Top left: byte 0 bit 7. bottom right: byte 7, bit 0
;
;   TopL
;    7 6 5 4 3 2 1 0	Byte 0
;    7 6 5 4 3 2 1 0	Byte 1
;    7 6 5 4 3 2 1 0	Byte 2
;    7 6 5 4 3 2 1 0	Byte 3
;    7 6 5 4 3 2 1 0	Byte 4
;    7 6 5 4 3 2 1 0	Byte 5
;    7 6 5 4 3 2 1 0	Byte 6
;    7 6 5 4 3 2 1 0	Byte 7
;                BotR
;
; modifies HL
; ----------------------------------------------------------------

ex8Scan:
	push af
	push bc
	push de

	ld d,020h	; how many scans

repScan:
	push hl
	ld c,80h	; ROWS

rowScan:
	ld a,c		; select row
	out (ex8Y),a
	
	ld a,(hl)	; light it up

	ld e,a
	ld b,8		; flip A bits: memory and dspl are opposite

rexxx:	sla e		; using e as temp register
	rra
	djnz rexxx

	out (ex8X),a

	ld b,40h	; on time
onex8:	djnz onex8

	xor a		; turn off to prevent shadow
	out (ex8X),a

	inc hl		; next byte of data
	rr c		; next row down

	jr nc, rowScan

	pop hl

	dec d
	jr nz,repScan

	pop de
	pop bc
	pop af
	ret

; ----------------------------------------------------------------
;  Long delay loop
;  no registers modified
; ----------------------------------------------------------------

delay:	push af
	push bc
	push de
	ld bc, 0200h

outer:	ld de, 0200h

inner:	dec de
	ld a,d
	or e
	jr nz, inner

	dec bc
	ld a,b
	or c
	jr nz, outer

	pop de
	pop bc
	pop af
	ret

; ----------------------------------------------------------------
; Byte to ASCII
;
; input HL = memory buffer, 2 bytes
; A = byte to convert
; increments HL on exit; trashes A
; ----------------------------------------------------------------

toAscii:
	push af
	rrca
	rrca
	rrca
	rrca
	call nibbleAsc
	pop af

nibbleAsc:
	and 0fh
	add a,90h
	daa
	adc a,40h
	daa
	ld (hl),a
	inc hl
	ret

; -----------------------------------------------------------------------------
; HEXSEG - A to 7-seg at HL
; -----------------------------------------------------------------------------

hexSeg:
	push af
	rrca
	rrca
	rrca
	rrca
	call hexNibble
	pop af
	
hexNibble:
	and 0fh
	ld ix,SEGMNT
	push bc
	ld b,0
	ld c,a
	add ix,bc
	pop bc
	ld a,(ix)
	ld (hl),a
	inc hl
	ret

; ----------------------------------------------------------------
;  ASCIIZ string to LCD
;
;  Input HL = ASCIIz String
;  no registeres modified
; ----------------------------------------------------------------

lcdStr:
	push af
	push hl

lcdStrLoop:
	ld a,(hl)
	cp 0
	jr z, lcdStrDone

	call lcdReady
	out (LCDDATA),a
	inc hl
	jr lcdStrLoop

lcdStrDone:
	pop hl
	pop af
	ret

; ----------------------------------------------------------------
; check that LCD is ready for IO
;
; no inputs; no registers modified
; ----------------------------------------------------------------

lcdReady:
	push af
lcdrlp:
	in a,(LCDCMD)		; is LCD ready?
	rlca
	jr c,lcdrlp
	pop af
	ret

; ----------------------------------------------------------------
; LCD send a command
;
; Input C = command byte
; no registers modified
; ----------------------------------------------------------------

lcdCommand:
	push af
	call lcdReady
	ld a,c
	out (LCDCMD),a
	pop af
	ret

; ----------------------------------------------------------------
; bitDump: bitwise dump a register to LCD
;
; e = value to dump
; ----------------------------------------------------------------

bitDump:
	push af
	push bc
	push de

	ld c,lcdRow3
	call lcdCommand

	ld b,8

bitLoop:
	sla e

	ld a,'1'
	jr c, notOneBit
	ld a,'0'

notOneBit:
	call lcdReady
	out (LCDDATA),a

	djnz bitLoop

	pop de
	pop bc
	pop af
	ret

; ----------------------------------------------------------------
; Scan 7-segs for a while with data from buffer at segbuf
; preserves registers
; scans from 'segbuf'
; no registers modified
; ----------------------------------------------------------------

scan7Seg:
	push af
	push bc
	push hl

	ld b,20h		; scan L to R
	ld hl,segbuf

dig:	ld a,(hl)
	out (SEGS),a
	ld a,b			; grab digit to lgiht
	out (DIGITS),a

	ld b,40h		; LED on time
onDly:	djnz onDly

	inc hl
	ld b,a			; restore b after loop counter
	xor a
	out (DIGITS),a		; blank digit- fixes ghosting

	srl b
	jr nc, dig

	pop hl
	pop bc
	pop af
	ret

; ----------------------------------------------------------------
;  wordToBuff - take a WORD and covert to 'XXXXh',0 (ASCIIZ)
;
;  input - BC = value to convert, HL = buffer location (6 bytes)
;  output - updates HL to end of buffer
; ----------------------------------------------------------------

wordToBuff:
	push af
	ld a,b
	call toAscii
	ld a,c
	call toAscii
	ld a,'h'		; append the h
	ld (hl),a
	inc hl
	xor a			; append the 0 terminating byte
	ld (hl),a
	pop af
	ret

; ----------------------------------------------------------------
;   Get a keypress with wait & 7-seg scanning
;
; returns with a = 72c923 keycode
; trashes everything .. except BC
; ----------------------------------------------------------------

getKey:	push bc

	ld hl,t1GMsg
	ld de,segbuf
	ld bc,6
	ldir

getKeyPress:
	call scan7Seg

	ld a,(kFlag)
	inc a
	jr nz,getKeyRelease

	in a,(SIMP3)
	bit 6,a
	jr nz,getKeyPress

	in a,(KEYB)
	and 3fh
	ld b,a
	ld (kFlag),a
	call tone

getKeyRelease:
	in a,(SIMP3)
	bit 6,a
	jr z,getKeyPress

	ld a,0ffh
	ld (kFlag),a

	ld a,b
	pop bc
	ret

; ----------------------------------------------------------------
; Get a keypress without wait
;
; Z=0 no key (A trashed)
; Z=1, A = scancode
;
; C=1 first press
; C=0 key repeats
; ----------------------------------------------------------------

getKeyNoScan:
	in a,(SIMP3)
	and 40h
	jr z,keyP
	ld (kState),a		; set 40h = nopress
	ret

keyP:
	ld a,(kState)
	or a			; clear carry
	bit 6,a			; set z
	ret z			; return if key held

;	xor a			; set 0 for next time
;	ld (kState),a

	in a,(KEYB)
	and 3fh			; dump junk bits
	xor 20h			; flip bit 5
	ld (kState),a		; save keypress
	cp a			; fake to set Z flag
	scf			; first press set C flag
	ret

; ----------------------------------------------------------------
; keyPause - wait for a keypress, release & beep
; ----------------------------------------------------------------

keyPause:
	call getKeyNoScan
	jr nz,keyPause

keyPause2:
	call getKeyNoScan
	jr z,keyPause2

	call tone

	ret

; ----------------------------------------------------------------
; CRC-16-CCITT checksum
;
; Poly: &1021
; Seed: &FFFF
;
; Input:
;  IX = Data address
;  DE = Data length
;
; Output:
;  HL = CRC-16
;  IX,DE,BC,AF modified
; ----------------------------------------------------------------

crc16:	ld hl,0FFFFh
	ld c,8

crc16_read:
	ld a,h
	xor (ix+0)
        ld h,a
        inc ix
        ld b,c

crc16_shift:
        add hl,hl
        jr nc,crc16_noxor
        ld a,h
        xor 010h
        ld h,a
        ld a,l
    	xor 021h
        ld l,a

crc16_noxor:
        djnz crc16_shift
        dec de
        ld a,d
        or e
        jr nz,crc16_read
 	ret

; -----------------------------------------------------------------------------
; tShadow - toggle the SHADOW bit. Don't touch memory
; -----------------------------------------------------------------------------

tShadow:
	ld a,(cfgMode)
	xor SHADOW
	ld (cfgMode),a
	out (SYSCTRL),a
	ret

; -----------------------------------------------------------------------------
; tExpand - toggle the EXPAND bit. Don't touch memory
; -----------------------------------------------------------------------------

tExpand:
	ld a,(cfgMode)
	xor EXPAND
	ld (cfgMode),a
	out (SYSCTRL),a
	ret

; -----------------------------------------------------------------------------
; tProtect - toggle the PROTECT bit. Don't touch memory
; -----------------------------------------------------------------------------

tProtect:
	ld a,(cfgMode)
	xor PROTECT
	ld (cfgMode),a
	out (SYSCTRL),a
	ret

; -----------------------------------------------------------------------------
; ramfind - locate block(s) of RAM and display info about them
; -----------------------------------------------------------------------------

ramFind:
	ld hl,0000h		; setup start address
	ld (ramtst),hl
	xor a			; 1 = we are already a block
	ld (ramflag),a

rloop:	ld hl,(ramtst)
	call rtst		; does it work ?
	jr z,ok			; Z flag set = ram present, go on

	ld a,(ramflag)		; end of block found ?
	cp 1
	jr nz, cont

dumpp:	call dumpBlk		; end of the block was reached

	xor a
	ld (ramflag),a

	ld hl,(ramtst)		; carry on looking for next block
	jr cont

ok:	ld a,(ramflag)		; in a block ?
	cp 1
	jr z,ok2

	ld (ramst),hl		; new block!!
	ld a,1			; set flag
	ld (ramflag),a

ok2:	ld (ramend),hl		; update location of end of ram

cont:	ld bc,ADINC		; next block
	add hl,bc
	ld (ramtst),hl

	ld a,h
	or a
	jr z,rtdone		; if H=0 we are done (wrap round)
	jr rloop		; otherwise test next block

rtdone:
	ld a,(ramflag)
	or a
	ret z

	call dumpBlk		; all ram ?

doneit:	ret

; -----------------------------------------------------------------------------
; DIAGSVER - display the version numers etc
; -----------------------------------------------------------------------------

diagsVer:
	ld c,lcdRow3+6
	call lcdCommand
	ld hl,SOFTWARE
	call lcdStr
	ld c,lcdRow4+6
	call lcdCommand
	ld hl,RELEASE
	call lcdStr
	call delay
	ret

; -----------------------------------------------------------------------------
; GPIO8bitio: Test the GPIO I/O ports
; -----------------------------------------------------------------------------

GPIO8bitio:
	in a,(SDIO)
	out (SDIO),a
	ld e,a
	call bitDump
	call getKeyNoScan
	jr nz,GPIO8bitio
	cp 13h
	jr z,exitTest
	jr GPIO8bitio

exitTest:
	xor a
	out (SDIO),a
	ret

; -----------------------------------------------------------------------------
; GLCD Test: Test out the GLCD
; -----------------------------------------------------------------------------

GLCDtest:
	call initLCD

	ld bc,0000h
	ld de,7f3fh
	call drawBox

	ld b,63
	ld c,31
	ld e,30
	call drawCircle

	call plotToLCD

	call setTxtMode

	ld c,1
	call printString
	.db "TEC-1G and GLCD!",0

waitkey:
	call getKeyNoScan
	jr nz,waitkey

	cp 13h
	ret z
	jr waitkey

	ret

; -----------------------------------------------------------------------------
; FTDI - test FTDI port
; -----------------------------------------------------------------------------

ftdiLoopback:
	ld b,80h		; test 128 times

ftdiLp:
	xor a
	out (DIGITS),a

	in a,(SIMP3)
	and 80h
	jr nz,ftdiFail

	ld a,40h
	out (DIGITS),a
	in a,(SIMP3)
	and 80h
	jr z,ftdiFail

	djnz ftdiLp

	ld hl,pass
	jr ftdiResult

ftdiFail:	
	ld hl,fail

ftdiResult:
	call lcdStr
	call delay
	ret

; -----------------------------------------------------------------------------
; dumpBlk - display info abbout the RAM block found
; -----------------------------------------------------------------------------

dumpBlk:
	ld hl,ramMsg
	call lcdStr

	ld bc,(ramst)		; dump values to screen
	ld hl,pcBuff

	call wordToBuff

	dec hl
	ld a,'-'
	ld (hl),a

	ld hl,pcBuff
	call lcdStr

	ld bc,(ramend)
	ld hl,pcBuff
	dec c			; adjust to xxffh

	call wordToBuff

	ld hl,pcBuff
	call lcdStr

	ld c,lcdRow4		; ready for bytes count
	call lcdCommand


; work out how many bytes
	ld hl,(ramend)
	ld bc,ADINC
	add hl,bc

	ld de,(ramst)
	or a
	sbc hl,de

	ld ix,decimalBuff
	call decimal
	xor a			; null terminate result
	ld (ix),a

	ld hl,decimalBuff
	call lcdStr

	ld hl,byteMsg
	call lcdStr

	ld c,lcdRow3		; ready for next block, if any
	call lcdCommand

	call tone		; bleep to indicate a result

	call delay
	call delay
	ret

; -----------------------------------------------------------------------------
; expandTest - check out the EXPAND banking
; -----------------------------------------------------------------------------

expandTest:
	xor a
	ld (pageRam),a		; 0 = ROM

p0Test:	ld c,0
	call expandPage
	ld hl,8000h
	ld (hl),055h		; test data for later
	call rtst
	jr nz,p0Result		; Z set = we got ram
	ld a,1			; mark page 0 (bit 0) as ram
	ld (pageRam),a

p0Result:
	ld hl,p0chk
	call lcdStr
	ld hl,ram
	ld a,(pageRam)
	and 1			; bit 0 only please
	call ores

p1Test:	ld c,1
	call expandPage
	ld hl,8000h
	ld (hl),0aah		; test data for later
	call rtst
	jr nz,p1Result
	ld a,(pageRam)
	or 2			; mark page 1 (bit 1) as ram
	ld (pageRam),a

p1Result:
	ld c,lcdRow4
	call lcdCommand
	ld hl,p1chk
	call lcdStr
	ld hl,ram
	ld a,(pageRam)
	and 2			; bit 1 only please
	srl a			; bit 1 -> bit 0
	call ores

	ld a,(cfgMode)		; Reset to normal
	out (SYSCTRL),a

; display banks test if both are ram only
	ld a,(pageRam)
	cp 3
	ret nz

	ld c,0a0h
	call lcdCommand
	ld hl,ptst
	call lcdStr
	ld c,0e2h
	call lcdCommand

	ld hl,fail

	ld c,0			; read back bank 0
	call expandPage
	ld hl,8000h
	ld a,055h
	cp (hl)
	jr nz,cmpres

	ld c,1			; read back bank 1
	call expandPage
	ld hl,8000h
	ld a,0aah
	cp (hl)
	jr nz,cmpres

	ld hl,pass

cmpres:	call lcdStr
	ld a,(cfgMode)		; Reset to normal
	out (SYSCTRL),a
	call delay
	ret

ores:	cp 1
	jr z, outp0

	inc hl
	inc hl
	inc hl
	inc hl

outp0:	call lcdStr
	call delay
	ret

; -----------------------------------------------------------------------------
; expandPage - select expand page
; input: C - page (0 or 1)
; -----------------------------------------------------------------------------

expandPage:
	push af
	ld a,c
	cp 0
	jr nz,page1

page0:	ld a,(cfgMode)		; force page 0
	and ~EXPAND		; ~ means invert expand
	jr pageSet

page1:	ld a,(cfgMode)		; force page 1
	or EXPAND

pageSet:
	out (SYSCTRL),a
	pop af
	ret

; -----------------------------------------------------------------------------
; RTST   checks a block of memory to see if it can store and return values
;
; the constant RTBLK defines the test size in bytes
;
; In: HL populated with test location 
; out: Z flag set if ram present
; all trashed except HL
; -----------------------------------------------------------------------------

rtst:
	ld (rTestLoc),hl
	ld a,055h
	ld (rTestByte),a
	call rBlockTest
	ld a,(rTestResult)
	cp 0
	jr nz, noram

	ld a,0aah
	ld (rTestByte),a
	call rBlockTest
	ld a,(rTestResult)
	cp 0
	jr nz, noram

	ld a,00h
	ld (rTestByte),a
	call rBlockTest
	ld a,(rTestResult)
	cp 0
	jr nz, noram

	ld a,0ffh
	ld (rTestByte),a
	call rBlockTest
	ld a,(rTestResult)
	cp 0

noram:
	ld hl,(rTestLoc)
	ret

; -----------------------------------------------------------------------------
; rBlockTest - test a block of ram for read/write
;
; IN: rTestLoc populated start address
;     rTestByte populated
;     RTBLK - #of bytes to check
;
; out: rTestResult: 0=pass, 1 = fail
;
; trashes - all registers
; -----------------------------------------------------------------------------

rBlockTest:
	di			; disable interupts

rBackup:
	ld hl,(rTestLoc)
	ld de,rTestBuff
	ld bc,RTBLK
	ldir			; copy to buffer

rFill:	ld a,(rTestByte)
	ld hl,(rTestLoc)
	ld (hl),a
	ld de,(rTestLoc)
	inc de
	ld bc,RTBLK-1
	ldir			; fill

rVerify:
	ld hl,(rTestLoc)
	ld a,(rTestByte)
	ld bc,RTBLK

rVerifyLoop:
	cpi
	jr nz,rVerifyFail
	ld d,a			; backup a
	ld a,b
	or c
	ld a,d			; restore a
	jr nz, rVerifyLoop

rVerifyPass:
	xor a
	ld (rTestResult),a	; 0 = pass
	jr rRestore

rVerifyFail:
	ld a,1
	ld (rTestResult),a	; 1 = fail

rRestore:
	ld de,(rTestLoc)
	ld hl,rTestBuff
	ld bc,RTBLK
	ldir			; restore contents

	ei
	ret

; -----------------------------------------------------------------------------
; DECIMAL - HL to decimal
; IX = memory location to store result
; trashes a, bc, de
; -----------------------------------------------------------------------------

decimal:
	ld e,1				; 1 = don't print a digit

	ld	bc,-10000
	call	Num1
	ld	bc,-1000
	call	Num1
	ld	bc,-100
	call	Num1
	ld	c,-10
	call	Num1
	ld	c,-1

Num1:	ld	a,'0'-1

Num2:	inc	a
	add	hl,bc
	jr	c,Num2
	sbc	hl,bc

	ld d,a				; backup a
	ld a,e
	or a
	ld a,d				; restore it in case
	jr z,prout			; if E flag 0, all ok, print any value

	cp '0'				; no test if <>0
	ret z				; if a 0, do nothing (leading zero)

	ld e,0				; clear flag & print it

prout:
	ld (ix),a
	inc ix
	ret

#include "glcd_library.asm"
#include "pi.asm"
#include "Diags_Music.asm"
#include "matrix_library.asm"
#include "Diags_FTDI.asm"
#include "Diags_RTC.asm"
#include "Diags_SD.asm"
#include "Diags_Strings_Variables.asm"

	.end
