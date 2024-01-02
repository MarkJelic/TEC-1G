; ----------------------------------------------------------------
; .equ ates
; ----------------------------------------------------------------

; IO ports
KEYB:		.equ 00h
DIGITS:		.equ 01h
SEGS:		.equ 02h
SIMP3:		.equ 03h
LCDCMD:		.equ 04h
LCDDATA:	.equ 84h
ex8X:		.equ 05h
ex8Y:		.equ 06h
GLCD_INST:	.equ 07H	;Graphics LCD Instruction
GLCD_DATA:	.equ 87H	;Graphics LCD Data
spiport:	.equ 0fdh	; IO port our SPI "controller" lives on
RTC:		.equ 0fch	; New to the 1G - RTC GPIO Board
SDIO:	 	.equ 0fdh	; New to the 1G - 8bit I/O GPIO Board
MATRIX:		.equ 0feh	; New to the 1G - Matrix Keyboard
SYSCTRL:	.equ 0ffh	; New to the 1G - System Control Latch

; SYSCTRL  port bits
SHADOW:		.equ 01h
PROTECT:	.equ 02h
EXPAND:		.equ 04h
CAPSL:		.equ 20h

; LCD commands
lcdCls:		.equ 01h
lcdRow1:	.equ 080h
lcdRow2:	.equ 0c0h
lcdRow3:	.equ 094h
lcdRow4:	.equ 0d4h

; Memory Locations
RAMST:		.equ 0800h	; Start of RAM Memory (2k)
RAMBL1:		.equ 4000h	; Second bank of RAM; Bank 1
RAMEND:		.equ 7FFFh	; End of RAM Memory (32k)
STAKLOC:	.equ 4000h	; top of not-protected RAM - stack is dec then push

HIROM:		.equ 0C000h	; Area where 16k ROM lives; Bank 3
HIBASE:		.equ 0300h	; Area where 'High' ROM code really starts

; Timing constants
SDELAY:		.equ 0F000h	; POST message delay time
BDELAY:		.equ 04000h	; LED Bar delay time

; Memory Test Constants
ADINC:		.equ 0100h	; RAM check block jump size. Tests RAM in blocks of this size
RTBLK:		.equ 40h	; RAM block size to test - must not clash with test buffer

; SIO Baud
BAUD:		.equ 1BH	 ;BAUD 4800 Delay
;BAUD:		.equ 0BH	 ;BAUD 9600 Delay

; GLCD
V_DELAY_US:	.equ 000AH   ;Delay for 76us on your system

; SD Card
spics1:		.equ 0fbh
spiidle:	.equ 05h	; Idle state
