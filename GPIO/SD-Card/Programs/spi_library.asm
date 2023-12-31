; ----------------------------------------------------------------------------
; 	Libraries for SPI2C board.
;
;	Copyright (C) 2023, Craig Hart. Distributed under the GPLv3 license.
;
;	https://github.com/1971Merlin/SPI2C
;
; ----------------------------------------------------------------------------

; ----------------------------------------------------------------------------
; Common Parameters
;
; change the ports according to the hardware in use
; ----------------------------------------------------------------------------

spiport	.equ 42h	; IO port our SPI "controller" lives on
			; 42h for SC-1 using the onboard 74HC138
			; user selected for TEC-1

spics1	.equ 0fbh
spics2	.equ 0efh
spics3	.equ 0dfh
spics4	.equ 0bfh
spics5	.equ 07fh

; ----------------------------------------------------------------------------
; SPI Routines
; ----------------------------------------------------------------------------

spiidle	.equ 0f5h	; Idle state

; SPI port bits out
;
; bit 0 - MOSI
; bit 1 - CLK
; bit 2 - CS1
; bit 3 - D/C
; bit 4 - CS2
; bit 5 - CS3
; bit 6 - CS4
; bit 7 - CS5

; SPI port bits in
;
; bit 3 - MISO
;
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

	rrca		; bit -> carry
	rrca		; bit -> carry
	rrca		; bit -> carry
	rrca		; bit -> carry
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
