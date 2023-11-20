; -----------------------------------------------------------------------------------------------
;	Test code for TEC SPI2C board and SD Cards
; -----------------------------------------------------------------------------------------------

	.org 4000h	; Start of code inRAM; 2000h for SC-1 or 0900 for TEC

; Initialize the SPI bus to an idle state; CS = 1, data and cLK = 0

start:
	ld c,01			; clear LCD
	call lcdCommand

	call spi_init		; set SD interface to idle state

; toggle clk 80 times with CS *not* set
	ld b,80

sdInit:
	ld a,spiidle
	out (spiport),a
	set 1,a			; set CLK
	out (spiport),a
	nop
	res 1,a			; clear CLK
	out (spiport),a
	djnz sdInit


	ld a,spiidle		; now turn CS on - puts SD card into SPI mode
	and spics1
	out (spiport),a


sdReset:
	ld hl,spiCMD0
	call sendSPICommand	; should come back as 01 if card present
	cp 01h
	jp nz,noCard

; ----
; CMD8 - get status bits
; only newer cards suppot CMD8
; ----
	ld hl,cmd8Str
	call lcdStr

	ld hl,spiCMD8
	call sendSPICommand
	call showByte		; should be 01 if CMD8 supported
	cp 01
	jr nz,cmd8Done		; skip past if CMD8 not supported (older cards)

cmd8OK:
	ld b,4			; dump 4 bytes of CMD8 status

get5Byte:
	call readSPIByte
	call showByte
	djnz get5Byte

cmd8Done:
	halt			; pause to view CMD8 data
	ld c,01
	call lcdCommand

;------
; ACMD41 - setup card state (needs CMD55 sent first to put it into ACMD mode)
;------
sendCMD55:
	call ldelay
	ld hl,spiCMD55
	call sendSPICommand
	ld hl,spiACMD41
	call sendSPICommand	; expect to get 00; init'd. If not, init is in progress
	cp 0
	jr z, initDone
	jr sendCMD55		; try again if not ready. Can take several cycles

initDone:
; we are initialised!!

; now get CID data
	ld hl,spiCMD10
	call sendSPICommand	; check command worked (=0)
	cp 0
	jp nz,sdError

	ld bc,16		; how many bytes of data we need to get
	call readSPIBlock

	ld b,5			; PNM - name
	ld hl,sdBuff+4
showPNM:
	ld a,(hl)
	call lcdReady
	out (LCDDATA),a
	inc hl
	djnz showPNM

; now get CSD data
	ld hl,spiCMD9
	call sendSPICommand
	cp 0
	jr nz,sdError

	ld bc,16		; how many bytes of data we need to get
	call readSPIBlock

	ld hl,sdBuff
	ld b,16

; --- type 1 or 2?

	ld c,0c0h
	call lcdCommand
	ld hl,cardTypeStr
	call lcdStr

	ld a,(sdBuff+1)
	and 0c0h
	rlca
	rlca
	inc a
	call showByte
	cp 2			; type 2?
	jr nz,notType2

; ----- decode type 2 size

	ld a,(sdBuff+9)		; get size bytes
	ld h,a
	ld a,(sdBuff+10)
	ld l,a
	inc hl
	srl h
	rr l

	ld ix,sdSize
	call decimal
	xor a			; null terminate result
	ld (ix),a

	ld c,094h
	call lcdCommand

	ld hl,sdSize
	call lcdStr
	ld hl,megaBytes
	call lcdStr
	

notType2:
	halt

; now get a block of real data

	ld c,01
	call lcdCommand

	ld hl,spiCMD17
	call sendSPICommand
	cp 0
	jr nz,sdError

	ld bc,512		; how many bytes of data we need to get
	call readSPIBlock


	ld bc,512
	ld hl,sdBuff+1

dumpLoop:
	ld a,(hl)
	call showByte
	inc hl
	dec bc
	ld a,b
	or c
	jr nz,dumpLoop


; ------
; Done !
; ------


	ld a,spiidle		; return to idle state; deassert CS
	out (spiport),a

	halt

	jp start



;-------------------------------------------------
; Subroutines
;-------------------------------------------------

;-------------------------------------------------
; Error Handling Routines
;-------------------------------------------------

sdError:
	ld hl,sdErrorStrNum
	call toAscii
	ld hl,sdErrorStr
	jr sdMsg
noCard:
	ld hl,noCardStr
sdMsg:
	call lcdStr
	halt
	jp start

;-------------------------------------------------
; display a byte on LCD as hex digits
; input A = byte to display
;-------------------------------------------------
showByte:
	push af
	push hl

	ld hl,byteBuff
	call toAscii

	ld hl,byteBuff
	ld a,(hl)
	call lcdReady
	out (LCDDATA),a		; to the lcd
	inc hl
	ld a,(hl)
	call lcdReady
	out (LCDDATA),a		; to the lcd
	ld a,20h		; add a space
	call lcdReady
	out (LCDDATA),a		; to the lcd

	pop hl
	pop af
	ret

; ------------------------------------------------
; sendSPICommand
; Input HL = 6 byte command
; returns A = response code
; ------------------------------------------------
sendSPICommand:
	push bc
	push de
	ld b,6
sendSPIByte:
	ld e,(hl)
	ld c,spics1
	ld d,0
	call spi_wrb
	inc hl
	djnz sendSPIByte
	call readSPIByte
	pop de
	pop bc
	ret

; ----------------------------------------------
; ReadSPIByte
;
; Returns - read value in A
; ----------------------------------------------
readSPIByte:
	push bc
	push de
	ld b,8			; wait up to 8 bytes, should need 1-2

readLoop:
	ld c,spics1
	ld d,0
	call spi_rdb		; get value in A
	cp 0ffh
	jr nz,result
	djnz readLoop

result:
	pop de
	pop bc
	ret

; ------------------------------------------------
; Read SD block input to buffer
;-------------------------------------------------

readSPIBlock:
	ld hl,sdBuff
	inc bc			; 1 byte block start marker
	inc bc			; 2 bytes CRC16 appended
	inc bc

blockLoop:
	call readSPIByte
	ld (hl),a
	inc hl
	dec bc

	ld a,b
	or c
	jr nz, blockLoop

	ret

;-------------------------------------------------
; General purpose delay loop
;-------------------------------------------------
ldelay:	push af
	push de
	ld de,0c000h

linner:	dec de
	ld a,d
	or e
	jr nz, linner

	pop de
	pop af
	ret


; lcd stuff

LCDCMD	.EQU 04h
LCDDATA	.EQU 84h

lcdReady:
	push af
lcdrlp:
	in a,(LCDCMD)		; is LCD ready?
	rlca
	jr c,lcdrlp
	pop af
	ret

lcdCommand:
	push af
	call lcdReady
	ld a,c
	out (LCDCMD),a
	pop af
	ret

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

#include "spi_library.asm"


; end of code, now comes our data region

	.org 1000h

spiCMD0:	.db 40h,0,0,0,0,95h		; reset			R1
spiCMD8		.db 48h,0,0,1,0aah,87h		; send_if_cond		R7
spiCMD9:	.db 49h,0,0,1,0aah,87h		; send_CSD		R1
spiCMD10:	.db 4ah,0,0,0,0,1h		; send_CSD		R1
spiCMD17:	.db 51h,0,0,0,0,1h		; read single block	R1
spiCMD55:	.db 77h,0,0,0,0,1		; APP_CMD		R1
spiCMD58:	.db 7ah,0,0,0,0,75h		; read OCR		R3
spiACMD41:	.db 69h,40h,0,0,0,1		; send_OP_COND		R1
cmd8Str		.db "CMD8: ",0
noCardStr:	.db "SD Card not Found",0
sdErrorStr:	.db "SD Card Error "
sdErrorStrNum:	.db "XX",0
megaBytes	.db "MB",0
cardTypeStr:	.db "SD Card type ",0

byteBuff:	.block 2
sdSize:		.block 12

	.org 2000h

sdBuff:		.block 512+1+2			; 512 + header + CRC16


	.end
