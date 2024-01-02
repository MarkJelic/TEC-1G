clock:
; setup RTC chip

	ld de,8e00h		; clear write protect bit
	call rtc_wr
	ld de,9000h		; clear trickle charge bits
	call rtc_wr

; ----------------------------------------------------------------------------
; Main Loop
; ----------------------------------------------------------------------------
clockLoop:

; read clock and setup 7-seg buffer
 
	ld hl,segbuf

	ld d,85h		; read hours
	call rtc_rd
	ld (rtcHours),a
	bit 7,a			; 1 = 12 hour
	jr z, is24a
	and 1fh

is24a:	and 3fh
        call hexSeg

	ld d,83h		; read minutes
	call rtc_rd
	ld (rtcMinutes),a
        call hexSeg

	ld d,81h		; read seconds
	call rtc_rd
	ld (rtcSeconds),a
        call hexSeg

; LCD

	ld c,lcdRow3
	call lcdCommand

	ld hl,rtcBuff

	ld a,(rtcHours)
	bit 7,a			; 1 = 12 hour
	jr z, is24
	and 1fh

is24:	and 3fh
	call toAscii
	ld a,':'
	ld (hl),a
	inc hl

	ld a,(rtcMinutes)
	call toAscii
	ld a,'.'
	ld (hl),a
	inc hl

	ld a,(rtcSeconds)
	call toAscii
	ld a,' '
	ld (hl),a
	inc hl

	ld a,(rtcHours)		; work out if AM or PM, or 24 hour mode
	bit 7,a
	jr nz,ampm		; skip AM/PM if 24 hour mode

	ld a,20h
	ld (hl),a
	inc hl
	ld (hl),a
	inc hl
	jr nullt

ampm:	ld d,'A'

	and 20h
	jr z,isam

	ld d,'P'
 
isam:   ld a,d			; copy 2 bytes AM or PM to buffer
	ld (hl),a
	inc hl
	ld a,'M'
	ld (hl),a
	inc hl

nullt:	xor a
	ld (hl),a

	ld hl,rtcBuff
	call lcdStr
;

; calendar
	ld c,lcdRow4
	call lcdCommand

	ld hl,rtcBuff

	ld d,8bh		; read day of week
	call rtc_rd
	and 07h		; mask any bad bits since we are doing a lookup
	dec a
	ld b,a

	ld de,days

dlop:	cp 0
	jr z,gotday

skipp:	ld a,(de)
	inc de
	cp 0
	jr nz,skipp

	dec b
	ld a,b
	jr dlop

gotday:
	ld a,(de)
	cp 0
	jr z,doneday

	ld (hl),a
	inc hl
	inc de
	jr gotday

doneday:
	ld a,' '
	ld (hl),a
	inc hl

	ld d,87h		; read date
	call rtc_rd
	call toAscii
	ld a,'/'
	ld (hl),a
	inc hl

	ld d,89h		; read month
	call rtc_rd
	call toAscii
	ld a,'/'
	ld (hl),a
	inc hl

	ld d,8dh		; read year
	call rtc_rd
	call bcdToBin

	push hl
	pop ix
	ld b,0
	ld c,a
	ld hl,2023
	add hl,bc

	call decimal

	xor a
	ld (ix),a

	ld hl,rtcBuff
	call lcdStr

        call scan7Seg

        call getKeyNoScan
        jp nz,clockLoop		; no key
	jp nc,clockLoop		; key repeats - ignore

        cp 13h
        ret z

	cp 02h
	jp nz,clockLoop

	ld a,(rtcHours)
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

        jp clockLoop

; ----------------------------------------------------------------------------
; Subroutines
; ----------------------------------------------------------------------------


; ----------------------------------------------------------------------------
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

; ----------------------------------------------------------------------------
; Write cycle. Writes 2 bytes
; D = command/register
; E = data byte
; ----------------------------------------------------------------------------
rtc_wr:
	ld c,RTC
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
	ld c,RTC
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
