; ----------------------------------------------------------------------------
;	TEC-1G Diagnostics
;
;	Copyright (C) 2023, Craig Hart. Distributed under the GPLv3 license
;
;	This portion of the code runs from 0000h, with Shadow enabled
; ----------------------------------------------------------------------------

; 7-seg checkpoints
;
; 0 - start of diagnostics (Powered up, minimal activity)
; 1 - LCD not found
; 2 - LCD found
; 3 - LCD Written to
; 4 - RAM Failed
; 5 - RAM Passed
; 6 - Stack Passed
; 7 - Interrupts Enabled
; 8 - JP to high ROM failed
; 9 - JP to high ROM passed
; D - CARTridge detected
; E - SHIFT key pressed
; F - 74c923 key pressed


; ----------------------------------------------------------------
;  Z80 base vectors
; ----------------------------------------------------------------

	.ORG 0000h+HIROM
reset:	xor a			; ensure latch is set - for burnin reset
	out (SYSCTRL),a
	jp cold-HIROM		; JUMP to start of program


	.ORG 0038h+HIROM	; INT vector goes here
rst38:	reti

	.ORG 0066h+HIROM	; NMI vector goes here
rst66:	retn


; ----------------------------------------------------------------
;  Strings etc
; ----------------------------------------------------------------

	.ORG 0068h+HIROM

msg1:		.db " TEC-1G Diagnostics",0
msg2:		.db "  Version ",0
msg3:		.db 0a5h," RAM Check ",0
msg5:		.db 0a5h," Stack Test Pass",0
msg6:		.db 0a5h," Interrupts Enabled",0

cart:		.db 0a5h," CART ",0

cartno:		.db "not "
cartyes		.db "found",0

msgPass:	.db "Pass",0
msgFail:	.db "Fail",0

; ----------------------------------------------------------------
;  LCD initialization table
; ----------------------------------------------------------------
	.ORG 00e0h+HIROM

LCDINIT:
	.db 38h,01h,06h,0ch

; ----------------------------------------------------------------
;  7-seg constants lookup table
;
;  Also padding for later scroll routine
; ----------------------------------------------------------------

	.ORG 00e4h+HIROM
SCRSEG:	.db 00,00,00,00,00,00
SEGMNT:	.db 0EBH,28H,0CDH,0ADH	;0,1,2,3
	.db 2EH,0A7H,0E7H,29H	;4,5,6,7
	.db 0EFH,2FH,6FH,0E6H	;8,9,A,B
	.db 0C3H,0ECH,0C7H,47H	;C,D,E,F
	.db 00,00,00,00,00,00

; ----------------------------------------------------------------
;  start of proper diagnostics
;
;  at this point we have no RAM for certain
;  so no push pop call etc. ideally.
;
;  also interrupts disabled (NMI still works of course)
;
; ----------------------------------------------------------------

	.ORG 0100h+HIROM

cold:	im 1			; Setup CPU Interrupt Mode
	ld sp,STAKLOC		; Setup Stack Location
	di			; Disable Interrupts


; ensure no display segments are selected

	xor a
	out (SEGS),a
	out (ex8X),a
	out (ex8Y),a

; play the startup tone
beep:	ld c,0c0h
	ld l,081h
	xor a
tlp1:	out (DIGITS),a
	ld b,c
tone1:	djnz tone1
	xor 80h
	dec l
	jr nz,tlp1

	ld b,0ffh
dly1:	djnz dly1


	ld a,01h
	out (DIGITS),a

	ld a,(SEGMNT-HIROM)		; checkpoint 0
	out (SEGS),a

	ld hl,kchk-HIROM		; 'call' our delay routine
	jp dly


kchk:	in a,(SIMP3)			; 74c923 key pressed check
	bit 6,a
	jr nz,nokey

	ld a,(SEGMNT+0Fh-HIROM)		; checkpoint F
	out (SEGS),a

	halt


nokey:	in a,(KEYB)			; Shift check
	bit 5,a
	jr nz,cp0

	ld a,(SEGMNT+0Eh-HIROM)		; checkpoint E
	out (SEGS),a

	halt


; init LCD

cp0:	ld hl,LCDINIT-HIROM
	ld b,04h
	ld c,LCDCMD

lloop:	ld de,0500h			; write 4 bytes init with delay
ldly:	dec de
	ld a,d
	or e
	jr nz,ldly
	outi
	jr nz,lloop

	nop

lpau:	in a,(LCDDATA)			; look for space character in DDRAM
	cp 20h
	jr z,lcdok			; found the LCD

	ld a,(SEGMNT+1-HIROM)		; no LCD - checkpoint 1 fail
	out (SEGS),a
	halt				; go no further if no LCD


lcdok:	ld a,(SEGMNT+2-HIROM)		; LCD found - checkpoint 2 pass
	out (SEGS),a


	ld hl,r1-HIROM			; 'call' our delay routine
	jp dly


; start of text output to the LCD

	
r1:	ld hl,r2-HIROM
	jp lo_lcr
	
r2:	ld a,lcdRow2			; move to row 2
	out (LCDCMD),a

	ld hl,msg1-HIROM		; message to the LCD
	ld bc,r3
	jp rlo_lcdstr

; move to LCD row 3

r3:	ld hl,r4-HIROM
	jp lo_lcr
	
r4:	ld a,lcdRow3			; move to row 3
	out (LCDCMD),a

	ld hl,msg2-HIROM		; message to LCD
	ld bc,cp2x
	jp rlo_lcdstr

cp2x:

	ld hl,RELEASE
	ld bc,cp3
	jp rlo_lcdstr

cp3:	ld a,(SEGMNT+3-HIROM)		; LCD message - checkpoint 3 pass
	out (SEGS),a



; long delay

	ld bc, 0400h

l_outer:
	ld de, 0100h

l_inner:
	dec de
	ld a,d
	or e
	jr nz, l_inner

	dec bc
	ld a,b
	or c
	jr nz, l_outer

;

	ld hl,r5-HIROM
	jp lo_lcr
	
r5:	ld a,lcdCls			; clear lcd
	out (LCDCMD),a

	ld hl,msg3-HIROM		; message to LCD
	ld bc,rtsts
	jp rlo_lcdstr

; now quickly check the RAM


rtsts:	ld hl,RAMST
	ld (hl),00h
	ld a,(hl)
	cp 00h
	jr nz, ramfail

	ld (hl),0ffh
	ld a,(hl)
	cp 0ffh
	jr nz, ramfail

	ld (hl),055h
	ld a,(hl)
	cp 055h
	jr nz, ramfail


	ld hl,RAMEND
	ld (hl),00h
	ld a,(hl)
	cp 00h
	jr nz, ramfail

	ld (hl),0ffh
	ld a,(hl)
	cp 0ffh
	jr nz, ramfail

	ld (hl),0aah
	ld a,(hl)
	cp 0aah
	jr nz, ramfail

	ld hl,msgPass

	ld a,(SEGMNT+5-HIROM)		; RAM test - Checkpoint 5 pass
	out (SEGS),a

	jr ramf2

ramfail:
	ld hl,msgFail			; message to the LCD
	
	ld bc,rfail
	jp rlo_lcdstr
	
rfail:	ld a,(SEGMNT+4-HIROM)		; RAM test - Checkpoint 4 fail
	out (SEGS),a

	halt				; hopefully never execute - bad RAM


ramf2:	ld bc,rdly
	jp rlo_lcdstr

rdly:	ld hl,sttst
	jp dly


; test stack memory

sttst:	ld hl,stackPass-HIROM
	push hl
	ret				; a.k.a. POP SP

	halt				; this should never execute


; OK safe to use stack now

stackPass:
	ld a,(SEGMNT+6-HIROM)		; Stack test - Checkpoint 6 pass
	out (SEGS),a

cp6:	call lo_lcdrdy-HIROM
	ld a,lcdRow2
	out (LCDCMD),a
	ld hl,msg5-HIROM		; display stack passed on LCD
	call lo_lcdstr-HIROM

	ld hl,cp7
	jp dly

; enable interrupts

cp7:	ei				; go for interrupts

	ld a,(SEGMNT+7-HIROM)		; Interrupts enabled - Checkpoint 7
	out (SEGS),a


	call lo_lcdrdy-HIROM
	ld a,lcdRow3
	out (LCDCMD),a
	ld hl,msg6-HIROM		; display interrupts enabled on LCD
	call lo_lcdstr-HIROM

	ld hl,cp7b-HIROM
	jp dly
cp7b:	ld hl,cartChk-HIROM
	jp dly
	
	
	
; check for cartridge


cartChk:
	ld a,lcdRow4
	out (LCDCMD),a
	ld hl,cart-HIROM
	call lo_lcdstr-HIROM

	in a,(SIMP3)
	bit 4,a

	ld hl,cartno-HIROM

	jr z,cartResult
	
	ld hl,cartyes-HIROM
	ld a,(SEGMNT+0dh-HIROM)		; Cartridge found checkpoint
	out (SEGS),a

cartResult:
	call lo_lcdstr-HIROM
	

cp7c:	ld hl,cp7d-HIROM
	jp dly
cp7d:	ld hl,cp8-HIROM
	jp dly


; check if shadow works.


cp8:	jp HIROM+HIBASE

	ld a,(SEGMNT+8-HIROM)		; High ROM jump failed - Checkpoint 8
	out (SEGS),a

	halt


; ----------------------------------------------------------------
;  ASCIIZ string to LCD - no memory or stack use
;
;  HL = ASCIIz String
;  BC = return address
;
;  modifies A, HL
; ----------------------------------------------------------------

rlo_lcdstr:
	ld a,(hl)
	cp 0
	jr nz, rlo_lcdrlp

	ld h,b				; return
	ld l,c
	jp (hl)

rlo_lcdrlp:
	in a,(LCDCMD)			; is LCD ready?
	rlca
	jr c,rlo_lcdrlp

	ld a,(hl)
	out (LCDDATA),a
	inc hl
	jr rlo_lcdstr

; ----------------------------------------------------------------
;  ASCIIZ string to LCD
;
;  HL = ASCIIz String
;
;  modifies A, HL
; ----------------------------------------------------------------

lo_lcdstr:
	ld a,(hl)
	cp 0
	ret z

	call lo_lcdrdy-HIROM

	out (LCDDATA),a
	inc hl
	jr lo_lcdstr


; ----------------------------------------------------------------
;  check that LCD is ready for IO; no stack needed
; ----------------------------------------------------------------

lo_lcr:	in a,(LCDCMD)			; is LCD ready?
	rlca
	jr c,lo_lcr
	jp (hl)

; ----------------------------------------------------------------
;  check that LCD is ready for IO; needs stack working
; ----------------------------------------------------------------

lo_lcdrdy:
	push af
lo_lcdrlp:
	in a,(LCDCMD)			; is LCD ready?
	rlca
	jr c,lo_lcdrlp
	pop af
	ret

; ----------------------------------------------------------------
;  Short Delay between tests
; ----------------------------------------------------------------

dly:	ld de,SDELAY
inner4:	dec de
	ld a,d
	or e
	jr nz, inner4
	jp (hl)

	.end
