; ----------------------------------------------------------------------------
; Simple DS1302 demo for the TEC-1G
; By Craig Hart, January 2024
; Version 1.3
;
; Setting time:
;               + sets hours
;               0 sets minutes
;               1 resets seconds to 00
;
;               2 toggles 12/24 hour time
;
; Setting calendar:
;               - sets day of week
;		4 sets date
;		5 sets month
;		6 sets year
;
; Special Keys:
;
; A - Reset the DS1302 to 01/01/2024, 01:00.00am & 12hr mode
; D - DUMPs the RTC RAM to LCD (Addr to exit dump mode)
; F - HALTs the TEC; any key to resume
;
; ----------------------------------------------------------------------------
		.org 4000h

; setup RTC chip

	ld de,8e00h		; clear write protect bit
	call rtc_wr
	ld de,9000h		; clear trickle charge bits
	call rtc_wr

; clear the LCD

	ld b,01
	ld c,_commandToLCD
	rst 10h

; ----------------------------------------------------------------------------
; Main Loop
; ----------------------------------------------------------------------------
clock:

; read clock and setup 7-seg buffer
 
	ld d,81h		; read seconds
	call rtc_rd
	ld (secs),a
	ld de,dispbuf+4
	ld c,_convAToSeg
	rst 10h

	ld d,83h		; read minutes
	call rtc_rd
	ld (mins),a
	ld de,dispbuf+2
	ld c,_convAToSeg
	rst 10h

	ld d,85h		; read hours
	call rtc_rd
	ld (hours),a
	bit 7,a			; 1 = 12 hour
	jr z, is24a

	bit 5,a
	jr z,notpm

	ld c,a
	ld a,(dispbuf+3)	; set decimal point for PM
	or 10h
	ld (dispbuf+3),a
	ld a,c

notpm:	and 1fh

is24a:	and 3fh
	ld de,dispbuf
	ld c,_convAToSeg
	rst 10h

; scan the 7-seg with our results

	ld c,_scanSegments	 ; disply on 7-seg displays
	ld de,dispbuf
	rst 10h

	ld c,_scanSegments	 ; disply on 7-seg displays
	ld de,dispbuf
	rst 10h

; LCD section

	ld de,lcdbuff		; buffer start
	ld a,(hours)		; get hours
	bit 7,a			; 1 = 12 hour
	jr z, is24
	and 1fh

is24:	and 3fh
	ld c,_AToString
	rst 10h

	ld a,':'		; add deliminator
	ld (de),a
	inc de

	ld a,(mins)		; get minutes
	ld c,_AToString
	rst 10h

	ld a,'.'		; add deliminator
	ld (de),a
	inc de

	ld a,(secs)		; set seconds
	ld c,_AToString
	rst 10h

	ld a,' '		; add space
	ld (de),a
	inc de

	ld a,(hours)		; work out if AM or PM, or 24 hour mode
	bit 7,a
	jr z,noampm		; skip AM/PM if 24 hour mode

	ld b,'A'

	and 20h
	jr z,isam

	ld b,'P'
 
isam:   ld a,b			; copy 2 bytes AM or PM to buffer
	ld (de),a
	inc de
	ld a,'M'
	ld (de),a
	inc de
	jr nullt

noampm:	ld a,' '		; add space
	ld (de),a
	inc de
	ld a,' '		; add space
	ld (de),a
	inc de

nullt:	xor a			; null terminate string
	ld (de),a

	ld b,2
	ld c,_commandToLCD	; B 1 (cls) or 2 (home)
	rst 10h

	ld hl,lcdbuff		; display message on LCD
	ld c,_stringToLCD
	rst 10h

; calendar
	ld b,0c0h		; Cursor to row 2
	ld c,_commandToLCD
	rst 10h

	ld d,8bh		; read day, 1-Monday
	call rtc_rd
	ld (dayofweek),a

	ld hl,days
	ld de,lcdbuff

	dec a
	ld b,a

dlop:	cp 0
	jr z,gotday

skipp:	ld a,(hl)
	inc hl
	cp 0
	jr nz,skipp

	dec b
	ld a,b
	jr dlop

gotday:
	ld a,(hl)
	cp 0
	jr z,doneday

	ld (de),a
	inc hl
	inc de
	jr gotday

doneday:
	ld a,' '
	ld (de),a
	inc de

	push de
	ld d,87h		; read date
	call rtc_rd
	ld (date),a
	pop de

;	ld de,lcdbuff

	ld c,_AToString
	rst 10h

	ld a,'/'
	ld (de),a
	inc de

	push de
	ld d,89h		; read month
	call rtc_rd
	ld (month),a
	pop de
	ld c,_AToString
	rst 10h
	ld a,'/'
	ld (de),a
	inc de

	push de
	ld d,8dh		; read year
	call rtc_rd
	ld (year),a
	call bcdToBin

	pop ix
	ld b,0
	ld c,a
	ld hl,2023
	add hl,bc

	call decimal

	xor a
	ld (ix),a

	ld hl,lcdbuff		; display message on LCD
	ld c,_stringToLCD
	rst 10h

; keystroke handling section

	ld c,_scanKeys
	rst 10h
	jp nc,nokey

trya:	cp 0ah			; A = reset clock
	jr nz,tryf
	call resetDS1302
	jp clock

tryf:	cp 0fh			; HALT ?
	jr nz, tryplu
	halt
	jp nokey

tryplu:	cp 10h			; HOURS ADJUST ?
	jr nz,tryzro

	ld a,(hours)
	bit 7,a
	jr nz,set12

set24:	inc a			; set clock in 24 hour mode
	daa
	cp 24h
	jr nz,setit

	xor a
	jr setit


set12:	ld c,a			; backup A
	and 0a0h		; the bits we want are 7 and 5
	ld d,a			; d contains needed bits
	ld a,c			; restore A

	and 1fh			; mask off junk bits
	inc a
	daa
	cp 13h
	jr nz,notwrong

	ld a,1			; wrap around to 1 (there is no 0 in hours)

notwrong:
	cp 12h			; AM/PM toggles at 12, not at 1.
	jr nz,noflip

	ld c,a			; backup A
	ld a,d			; toggle AM/PM bit
	xor 20h
	ld d,a			; save change
	ld a,c			; restore A

noflip:	or d			; add in the control bits
setit:	ld d,84h
	ld e,a
	call rtc_wr
	jr nokey





tryzro:	cp 0			; MINUTES ADJUST ?
	jr nz, tryone

	ld d,83h		; read minutes
	call rtc_rd

	inc a
	or a
	daa
	cp 60h
	jr nz,notoverflow
	xor a

notoverflow:
	ld e,a
	ld d,82h
	call rtc_wr
	jr nokey

tryone:	cp 1			; SECONDS TO 00 ?
	jr nz, trytwo

	ld de,8000h		; reset seconds to zero
	call rtc_wr
	jr nokey

trytwo:	cp 2
	jr nz, tryminus

	ld a,(hours)
	bit 7,a
	jr nz,to24

; ----------------

to12:	and 3fh		; 24 hour to 12 hour
	cp 00h
	jr nz,notmidnight
	ld a,92h	; 12am + 12 hour flag
	jr sethour

notmidnight:
	cp 12h
	jr z,setpm	; 12pm exactly?
	jr nc,ispm	; >12 ?
	or 80h		; <12, so hours same, set 12 hour flag
	jr sethour

ispm:	sub 12h		; convert to 12 hr time
	daa
setpm:	or 0a0h		; set 12 hour flag + PM fag
	jr sethour

; -------------------

to24:	and 3fh		; strip bits 7 and 6 to set 24h mode
	bit 5,a		; was it pm?
	
	jr z,fixt	; am? if so am is same as 24hr

	and 1fh		; clear PM flag
	cp 12h		; is it 12pm? no change
	jr z,sethour
	add a,12h	; adjust by adding 12 hours
	daa		; in BCD
	jr sethour

fixt:	cp 12h		; 12am = 00 hours
	jr nz,nofix
	xor a

nofix:	and 1fh		; clear PM flag

sethour:
	ld e,a		; set clock
	ld d,84h
	call rtc_wr

nokey:	jp clock

tryminus:
	cp 11h
	jr nz,tryfour
	ld a,(dayofweek)
	inc a
	cp 8
	jr nz,loadday
	ld a,1
loadday:
	ld e,a
	ld d,08ah
	call rtc_wr

refrsh:	ld b,01				; clear screen to clean up
	ld c,_commandToLCD
	rst 10h

	jr nokey


tryfour:
	cp 4
	jr nz, tryfive

	ld a,(date)
	inc a
	daa
	cp 32h
	jr nz, loaddate
	ld a,1
loaddate:
	ld e,a
	ld d,86h
	call rtc_wr
	jr refrsh


tryfive:
	cp 5
	jr nz, trysix
	
	ld a,(month)
	inc a
	daa
	cp 13h
	jr nz, loadmonth
	ld a,1
loadmonth:
	ld e,a
	ld d,88h
	call rtc_wr
	jr refrsh

trysix:	cp 6
	jr nz, tryd
	
	ld a,(year)
	inc a
	daa
loadyear:
	ld e,a
	ld d,8ch
	call rtc_wr
	jr refrsh

tryd:	cp 0dh
	jr nz, nokey
	call dumpram
	jr nokey


; -------



; ----------------------------------------------------------------------------
; Subroutines
; ----------------------------------------------------------------------------

; ----------------------------------------------------------------------------
; Reset the DS1302 fully
; ----------------------------------------------------------------------------

resetDS1302:
	ld de,8e00h		; clear write protect bit
	call rtc_wr
	ld de,9000h		; clear trickle charge bits
	call rtc_wr

	ld de, 8000h		; seconds 00
	call rtc_wr
	ld de, 8200h		; minutes 00
	call rtc_wr
	ld de, 8490h		; hours 01, 12 hour mode
	call rtc_wr

	ld de,8601h		; date 01
	call rtc_wr
	ld de,8801h		; month 01
	call rtc_wr
	ld de,8a01h		; day 01 (Monday)
	call rtc_wr
	ld de,8c01h		; year 01 (2024)
	call rtc_wr

	ret

; ----------------------------------------------------------------------------
; display the RTC RAM bytes (31 bytes)
; ----------------------------------------------------------------------------
dumpram:
	call rtcram_rd		; get the bytes

	ld hl,rambuff		; fill LCD buffer with spaces
	ld de,rambuff+1
	ld a,20h
	ld (hl),a
	ld bc,159
	ldir

	ld b,7			; setup fill defaults
	xor a
	ld (bcount),a
	ld de,rambuff
	ld hl,rtcram

fillBuff:
	ld a,(bcount)		; fill LCD buffer with the data
	ld c,_AToString
	rst 10h
	ld a,':'
	ld (de),a
	inc de
	ld a,' '
	ld (de),a
	inc de

	push bc
	ld b,5
	ld a,(bcount)		; last line has 1 byte only
	cp 1eh
	jr nz,writeLine
	ld b,1

writeLine:
	ld a,(hl)
	ld c,_AToString
	rst 10h
	ld a,' '
	ld (de),a
	inc de
	inc hl
	djnz writeLine

	pop bc

	ld a,' '
	ld (de),a
	inc de

	ld a,(bcount)
	add a,5
	ld (bcount),a

	djnz fillBuff

; ---- ok now buffer is ready. paint it to LCD & do scrolling etc.

	ld b,01				; clear LCD
	ld c,_commandToLCD
	rst 10h

	ld hl,rambuff			; setup defaults
	ld (rambuffPtr),hl
	xor a
	ld (rambuffPage),a


dbuff:	ld hl,(rambuffPtr)		; send buffer to LCD
	call blatline
 	ld b,0c0h
	ld c,_commandToLCD
	rst 10h
	call blatline
 	ld b,94h
	ld c,_commandToLCD
	rst 10h
	call blatline
 	ld b,0d4h
	ld c,_commandToLCD
	rst 10h
	call blatline

	ld c,_scanKeysWait
	rst 10h
	
	cp 10h				; plus
	jr nz,tryneg

	ld a,(rambuffPage)
	inc a
	cp 4
	jr nz,updatePtr
	ld a,3
	jr updatePtr


tryneg:	cp 11h				; minus
	jr nz,tryaddr

	ld a,(rambuffPage)
	dec a
	jp p,updatePtr
	xor a
	jr updatePtr

tryaddr:
	cp 13h
	jr nz,dbuff

	ld b,01				; clear LCD before exit
	ld c,_commandToLCD
	rst 10h
	ret

updatePtr:
	ld (rambuffPage),a

	ld hl,rambuff-20
	ld b,a
	inc b
	ld de,20

add20:	add hl,de
	djnz add20
	ld (rambuffPtr),hl
	jr dbuff

; ----

blatline:
	ld b,20
fillLcd:
	ld a,(hl)
	ld c,_charToLCD
	rst 10h
	inc hl
	djnz fillLcd
	ret

; ----------------------------------------------------------------------------
; Conversion routine - BCD to true Binary
; input:  A = BCD value
; output: A = binary value
; ----------------------------------------------------------------------------
bcdToBin:
	push bc
	ld c,a
	and 0f0h
	srl a
	ld b,a
	srl a
	srl a
	add a,b
	ld b,a
	ld a,c
	and 0fh
	add a,b
	pop bc
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

; ----------------------------------------------------------------------------
; Write cycle. Writes 2 bytes
; D = command/register
; E = data byte
; ----------------------------------------------------------------------------
rtc_wr:
	push af

	ld c,RTCport
	ld a,10h		; raise CS, enable data in
	out (c),a
  
	call bytelpW		; write D to select the register
	ld d,e
	call bytelpW		; write E - the data

	xor a			; drop CS
	out (c),a

	pop af
	ret

; ----------------------------------------------------------------------------
; Read cycle. Writes command and reads result
; D = command/register needed
; A = result
; ----------------------------------------------------------------------------
rtc_rd:
	ld c,RTCport
	ld a,10h		; raise CS, enable data out
	out (c),a
  
	call bytelpW		; write D to select the register
	call bytelpR		; read value (into D)

	xor a			; drop CS
	out (c),a

	ld a,d			; return value in A
	ret

; ----------------------------------------------------------------------------
; Read cycle. Writes command and reads result into memory using burst mode
; ----------------------------------------------------------------------------
rtcram_rd:
	ld c,RTCport
	ld a,10h		; raise CS, enable data out
	out (c),a
  
	ld d,0ffh		; ram burst
	call bytelpW		; write D to select the register

	ld b,31
	ld hl,rtcram

bRead:	call bytelpR		; read value (into D)
	ld (hl),d
	inc hl
	djnz bRead

	xor a			; drop CS
	out (c),a

	ret

; ----------------------------------------------------------------------------
; write one byte to the DS1302
; byte in D
; ----------------------------------------------------------------------------
bytelpW:
	push bc
	ld b,8
 
blp:    srl d			; data bit 0 to carry
	ld a,20h
	rra			; carry to data bit 7
	out (c),a		; setup bus - drops clock
	or 40h			; raise CLK
	out (c),a
	djnz blp
	pop bc
	ret

; ----------------------------------------------------------------------------
; Read one byte from the DS1302
; byte read is returned in D
; ----------------------------------------------------------------------------
bytelpR:
	push bc
	ld b,8
	ld d,0

blp2:
	ld a,30h
	or 40h			; raise CLK
	out (c),a
	and 0bfh		; drop CLK
	out (c),a
	in e,(c)		; read value

	srl e
	rr d
	djnz blp2
	pop bc
	ret

; ----------------------------------------------------------------------------
; constants
; ----------------------------------------------------------------------------

#include "mon3_includes.asm"	; include TEC-1G API calls

RTCport:	.equ 0fch

days:		.db "Monday",0
		.db "Tuesday",0
		.db "Wednesday",0
		.db "Thursday",0
		.db "Friday",0
		.db "Saturday",0
		.db "Sunday",0

; ----------------------------------------------------------------------------
; Variables
; ----------------------------------------------------------------------------
		.org 1000h

dispbuf:	.block 6
hours:		.block 1
mins:		.block 1
secs:		.block 1
dayofweek	.block 1
date:		.block 1
month:		.block 1
year:		.block 1

lcdbuff: 	.block 20

rtcram:		.block 31

rambuff:	.block 160
rambuffPtr:	.block 2
rambuffPage:	.block 1
bcount:		.block 1


		.end
