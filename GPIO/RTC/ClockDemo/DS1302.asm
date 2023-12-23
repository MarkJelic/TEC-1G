; ----------------------------------------------------------------------------
; Simple DS1302 demo for the TEC-1G
; By Craig Hart, December 2023
; Version 1.1
; ----------------------------------------------------------------------------
			.org 4000h

; setup RTC chip

	ld de,8e00h		; clear write protect bit
	call rtc_wr
	ld de,9000h		; clear trickle charge bits
	call rtc_wr

; set a starting time - values in E

	ld de, 8000h		; seconds 00
	call rtc_wr
	ld de, 8200h		; minutes 00
	call rtc_wr
	ld de, 84b2h		; hours 12. bit 7=1=1 hr clock. bit 5=1=PM set
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
	and 1fh			; mask off bits we don't need
	ld de,dispbuf
	ld c,_convAToSeg
	rst 10h

; scan the 7-seg with our results

	ld c,_scanSegments	 ; disply on 7-seg displays
	ld de,dispbuf
	rst 10h

; LCD section

	ld de,lcdbuff		; buffer start
	ld a,(hours)		; get hours
	and 1fh			; mask off hour bits that aren't digits
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

	ld hl,amStr

	ld a,(hours)		; work out if AM or PM
	and 20h
	jr z,isam

	ld hl,pmStr
 
isam:   ld bc,2			; copy 2 bytes AM or PM to buffer
	ldir

	xor a			; null terminate string
	ld (de),a

	ld b,02			; move to top left of LCD
	ld c,_commandToLCD
	rst 10h

	ld hl,lcdbuff		; display message on LCD
	ld c,_stringToLCD
	rst 10h

; keystroke handling section

	ld c,_scanKeys
	rst 10h
	jr nc,nokey
	cp 0fh			; HALT ?
	jr nz, tryplu
	halt
	jr nokey

tryplu:	cp 10h			; HOURS ADJUST ?
	jr nz,tryzro

	ld d,85h		; read hours
	call rtc_rd

	ld c,a			; backup A
	and 0e0h		; the bits we want are 7,6 and 5
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
	ld d,84h
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
	jr nz, nokey

	ld de,8000h		; reset seconds to zero
	call rtc_wr

nokey:	jp clock

; ----------------------------------------------------------------------------
; Subroutines
; ----------------------------------------------------------------------------

; ----------------------------------------------------------------------------
; Write cycle. Writes 2 bytes
; D = command/register
; E = data byte
; ----------------------------------------------------------------------------
rtc_wr:
	ld c,RTCport
	ld a,10h		; raise CS, enable data in
	out (c),a
  
	call bytelpW		; write D to select the register
	ld d,e
	call bytelpW		; write E - the data

	xor a			; drop CS
	out (c),a

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
; write one byte to the DS1302
; ----------------------------------------------------------------------------
bytelpW:
	ld b,8
 
blp:    srl d			; data bit 0 to carry
	ld a,20h
	rra			; carry to data bit 7
	out (c),a		; setup bus - drops clock
	or 40h			; raise CLK
	out (c),a
	djnz blp
	ret

; ----------------------------------------------------------------------------
; Read one byte from the DS1302
; byte read is returned in D
; ----------------------------------------------------------------------------
bytelpR:
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
	ret

; ----------------------------------------------------------------------------
; constants
; ----------------------------------------------------------------------------

#include "mon3_includes.asm"	; include TEC-1G API calls

RTCport:	.equ 0fch
amStr:		.db "AM"
pmStr:		.db "PM"

; ----------------------------------------------------------------------------
; Variables
; ----------------------------------------------------------------------------
		.org 1000h

dispbuf:	.block 6
hours:		.block 1
mins:		.block 1
secs:		.block 1

lcdbuff	 .block 16

		.end
