; ----------------------------------------------------------------
;  EQU ates
; ----------------------------------------------------------------

; IO ports

KEYB	.EQU 00h
DIGITS	.EQU 01h
SEGS	.EQU 02h
SIMP3	.EQU 03h
LCDCMD	.EQU 04h
LCDDATA	.EQU 84h
ex8X    .EQU 05h
ex8Y    .EQU 06h
SDIO	.EQU 0fdh	; New to the 1G
MATRIX	.EQU 0feh	; New to the 1G/Matrix expansion
SYSCTRL	.EQU 0ffh	; New to the 1G

; SYSCTRL  port bits

SHADOW	.EQU 01h
PROTECT	.EQU 02h
EXPAND	.EQU 04h
CAPSL	.EQU 20h

; LCD commands

lcdCls	.EQU 01h

lcdRow1	.EQU 080h
lcdRow2	.EQU 0c0h
lcdRow3	.EQU 094h
lcdRow4	.EQU 0d4h

; Memory Locations

RAMST	.EQU 0800h	; Start of RAM Memory (2k)
RAMBL1	.EQU 4000h	; Second bank of RAM; Bank 1
RAMEND	.EQU 7FFFh	; End of RAM Memory (32k)
STAKLOC	.EQU 4000h	; top of not-protected RAM - stack is dec then push

HIROM	.EQU 0C000h	; Area where 16k ROM lives; Bank 3
HIBASE	.EQU 0300h	; Area where 'High' ROM code really starts

; Timing constants

SDELAY	.EQU 0F000h	; POST message delay time
BDELAY	.EQU 04000h	; LED Bar delay time

; Memory Test Constants

ADINC	.equ 0100h	; RAM check block jump size. Tests RAM in blocks of this size
RTBLK   .equ 40h        ; RAM block size to test - must not clash with test buffer

; SIO Baud
BAUD:       .equ    1BH         ;BAUD 4800 Delay
;BAUD:       .equ    0BH         ;BAUD 9600 Delay
