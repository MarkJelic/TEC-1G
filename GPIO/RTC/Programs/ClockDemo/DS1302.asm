; ----------------------------------------------------------------------------
; Simple DS1302 demo for the TEC-1G
; By Craig Hart, January 2024
; Version 1.4 - uses APIs
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
; A - Reset the DS1302 to 01/01/2000, 01:00.00am & 12hr mode
; D - DUMPs the RTC RAM to LCD (Addr to exit dump mode)
; F - HALTs the TEC; any key to resume
;
; ----------------------------------------------------------------------------
		.org 04000h

; clear the LCD
	ld b,01
	ld c,commandToLCD_
	rst 10h

; setup RTC chip
	ld c,RTCAPI_
	ld b,00			; checkDS1302Present
	rst 10h
	jr nc,clock

	ld hl,noRTC		; message & exit if not fitted
	ld c,stringToLCD_
	rst 10h
	halt
	ret

; ----------------------------------------------------------------------------
; Main Loop
; ----------------------------------------------------------------------------
clock:

; read clock and setup 7-seg buffer
 
	ld c,RTCAPI_
	ld b,02			; getTime - HL=h:m, D = secs
	rst 10h

	ld a,d
	ld (secs),a
	ld de,dispbuf+4
	ld c,convAToSeg_
	rst 10h

	ld a,l
	ld (mins),a
	ld de,dispbuf+2
	ld c,convAToSeg_
	rst 10h
	ld a,h
	ld (hours),a

	ld c,RTCAPI_
	ld b,08			; get 1224
	rst 10h

	ld b,a
	ld a,(hours)
	or b
	ld (hours),a

	bit 7,a			; 1 = 12 hour
	jr z, is24a

	ld a,(hours)
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
	ld c,convAToSeg_
	rst 10h

; scan 7-seg displays
	ld c,scanSegments_	 ; disply on 7-seg displays
	ld de,dispbuf
	rst 10h

; LCD section, time

	ld a,(oldSecs)		; did seconds change? if so refresh lcd
	ld b,a
	ld a,(secs)
	cp b
	jr z,keys

	ld (oldSecs),a		; update value

	ld b,2
	ld c,commandToLCD_	; Cursor home
	rst 10h

	ld c,RTCAPI_
	ld b,08			; get 12/24
	rst 10h
	push af

	ld c,RTCAPI_
	ld b,02
	rst 10h

	pop af			; add in 12/24 hour flag
	add a,h
	ld h,a

	ld iy,lcdbuff		; format it
	ld c,RTCAPI_
	ld b,16
	rst 10h

	ld hl,lcdbuff		; display message on LCD
	ld c,stringToLCD_
	rst 10h

; LCD section, calendar
	ld b,0c0h		; Cursor to row 2
	ld c,commandToLCD_
	rst 10h

	ld c,RTCAPI_		; get day
	ld b,06
	rst 10h
	ld c,stringToLCD_	; display day
	rst 10h

	ld iy,lcdbuff
	ld a,20h		; add space
	ld (iy),a
	inc iy

	ld c,RTCAPI_		; get date
	ld b,04
	rst 10h

	ld a,h
	ld (date),a
	ld a,l
	ld (month),a
	ld (year),de

	ld c,RTCAPI_		; format date as string
	ld b,17
	rst 10h

	ld hl,lcdbuff		; display date on LCD
	ld c,stringToLCD_
	rst 10h

; keystroke handling section
keys:
	ld c,scanKeys_
	rst 10h
	jp nc,clock

trya:	cp 0ah			; A = reset clock
	jr nz,tryf
	ld c,RTCAPI_
	ld b,01
	rst 10h
	jp clock

tryf:	cp 0fh			; HALT ?
	jr nz, tryplu
	halt
	jp clock

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

setit:	ld h,a
	ld a,(mins)
	ld l,a
	ld a,(secs)
	ld d,a


stTime:	ld c,RTCAPI_
	ld b,03
	rst 10h
	jp clock

tryzro:	or a			; MINUTES ADJUST ?
	jr nz, tryone
	ld c,RTCAPI_
	ld b,02
	rst 10h
	ld a,l
	inc a
	daa
	cp 60h
	jr nz,notoverflow
	xor a

notoverflow:
	ld l,a
	jr stTime

tryone:	cp 1			; SECONDS TO 00 ?
	jr nz, trytwo
	ld c,RTCAPI_
	ld b,02
	rst 10h
	ld d,0			; reset seconds
	jr stTime

trytwo:	cp 2
	jr nz, tryminus

	ld b,01			; clear screen to fix up AM/PM sign
	ld c,commandToLCD_
	rst 10h

	ld a,(hours)
	bit 7,a
	jr nz,to24

to12:	ld c,RTCAPI_
	ld b,09
	rst 10h
	jp clock

to24:	ld c,RTCAPI_
	ld b,10
	rst 10h
	jp clock



tryminus:
	cp 11h
	jr nz,tryfour

	ld b,06				; get day
	ld c,RTCAPI_
	rst 10h
	ld a,d
	inc a
	cp 8
	jr nz,loadday
	ld a,1
loadday:
	ld d,a
	ld b,07
	ld c,RTCAPI_
	rst 10h

refrsh:	ld b,01				; clear screen to clean up
	ld c,commandToLCD_
	rst 10h
	jp clock

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
	ld h,a
	ld a,(month)
	ld l,a
	ld de,(year)
	jr setYear

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
	ld l,a
	ld a,(date)
	ld h,a
	ld de,(year)
	jr setYear

trysix:	cp 6
	jr nz, tryd

	ld de,(year)		; BCD add
	ld a,e
	inc a
	daa
	ld e,a
	ld (year),de


loadyear:
	ld a,(date)
	ld h,a
	ld a,(month)
	ld l,a

setYear:
	ld b,05
	ld c,RTCAPI_
	rst 10h
	jp clock

tryd:	cp 0dh
	jp nz, clock
	call dumpram
	jp clock


; ----------------------------------------------------------------------------
; Subroutines
; ----------------------------------------------------------------------------

; ----------------------------------------------------------------------------
; display the RTC RAM bytes (31 bytes)
; ----------------------------------------------------------------------------
dumpram:
	ld hl,rtcram
	ld b,13
	ld c,RTCAPI_
	rst 10h

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
	ld c,AToString_
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
	ld c,AToString_
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
	ld c,commandToLCD_
	rst 10h

	ld hl,rambuff			; setup defaults
	ld (rambuffPtr),hl
	xor a
	ld (rambuffPage),a


dbuff:	ld hl,(rambuffPtr)		; send buffer to LCD
	call blatline
 	ld b,0c0h
	ld c,commandToLCD_
	rst 10h
	call blatline
 	ld b,94h
	ld c,commandToLCD_
	rst 10h
	call blatline
 	ld b,0d4h
	ld c,commandToLCD_
	rst 10h
	call blatline

	ld c,scanKeysWait_
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
	ld c,commandToLCD_
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
	ld c,charToLCD_
	rst 10h
	inc hl
	djnz fillLcd
	ret

; ----------------------------------------------------------------------------
; constants
; ----------------------------------------------------------------------------

noRTC:		.db "RTC Module not found",0

.include "mon3_includes.asm"	; include TEC-1G API calls

; ----------------------------------------------------------------------------
; Variables
; ----------------------------------------------------------------------------
		.org 3800h

dispbuf:	ds 6
hours:		ds 1
mins:		ds 1
secs:		ds 1
date:		ds 1
month:		ds 1
year:		ds 2
oldSecs:	ds 1

lcdbuff: 	ds 20

rtcram:		ds 31

rambuff:	ds 160
rambuffPtr:	ds 2
rambuffPage:	ds 1
bcount:		ds 1


		.end
