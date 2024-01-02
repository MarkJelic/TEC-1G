sd_test:
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
;	ld hl,cmd8Str
;	call lcdStr

	ld hl,spiCMD8
	call sendSPICommand
;	call showByte		; should be 01 if CMD8 supported
	cp 01
	jr nz,cmd8Done		; skip past if CMD8 not supported (older cards)

cmd8OK:
	ld b,4			; dump 4 bytes of CMD8 status

get5Byte:
	call readSPIByte
;	call showByte
	djnz get5Byte

cmd8Done:
;	halt			; pause to view CMD8 data
;	call keyPause		; pause to view CMD8 data
;	ld c,01
;	call lcdCommand

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

	ld c,lcdRow4
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

	ld c,09dh		; row 3 col 10
	call lcdCommand

	ld hl,sdSize
	call lcdStr
	ld hl,megaBytes
	call lcdStr

notType2:

; ------
; Done !
; ------
        call spi_end
	call keyPause
        ret

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
	call keyPause
	ret

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

; ----------------------------------------------------------------------------
; SPI initialization code starts here; call once at start of code
;
; idle state == 1111 0100  === MOSI, D/C and CLK low, CSx all high
; ----------------------------------------------------------------------------

spi_init:
	push af
	ld a,spiidle	; Set idle state
	out (spiport),a
	pop af
	ret

spi_end:
	push af
	xor a
	out (spiport),a
	pop af
	ret

; ----------------------------------------------------------------------------
; Routine to transmit one byte to the SPI bus
;
; c = SPI CS pin required (use the spics EQUs above)
; d = command/data 00 = command, 08 = data
; e = data byte
;
; no results returned, no registers modified
; ----------------------------------------------------------------------------
spi_wrb:
	push af
	push bc
	push de

	ld b,8		; 8 BITS

nbit:	ld a,spiidle	; starting point
	or d		; add in the command/data register select
	and c		; add in the CS pin
	bit 7,e
	jr nz, no
	res 0,a

no:	out (spiport),a	; set data bit
	set 1,a		; set CLK
	out (spiport),a
	nop
	res 1,a		; clear CLK
	out (spiport),a
	rlc e		; next bit
	djnz nbit

	pop de
	pop bc
	pop af
	ret

; ----------------------------------------------------------------------------
; Routine to read one byte from the SPI bus
;
; C = SPI CS pin required (use the spics EQUs above)
; D = command/data 00 = command, 08 = data
;
; returns result in A
; no other registers modified
; ----------------------------------------------------------------------------
spi_rdb:
	push bc
	push de
	push hl

	ld e,0		; result
	ld b,8		; 8 bits

rbit:	ld a,spiidle
	or d
	and c

	out (spiport),a	; set idle
	nop

	set 1,a		; set CLK
	out (spiport),a

	ld h,a		; backup a

	in a,(spiport)	; bit d3
	rla		; bit 7 -> carry
	rl e		; carry -> c bit 0
	ld a,h		; restore a
	res 1,a		; clear CLK
	out (spiport),a

	djnz rbit

	ld a,e

	pop hl
	pop de
	pop bc
	ret
