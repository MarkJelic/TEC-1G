; KEYSCAN routine for the Matrix Keyboard
; ------------------------------------
;
; Register B is used to cycle a Low from A8 up through A15. A low indicates the Row is being scanned
; Register C is used only to set the Input port which is $FE
;
; Register E returns the key pressed, or FFH if no key pressed
; Register D returns the modifier key(s) pressed or 00h if no modifiers
; Returns values:
;   D : Shift = 01h
;       Ctrl  = 02h
;       Fn    = 04h
;	caps  = 80h
;
; sets capsval variable to 01h if capslock is on; 00h if off.


KEYSCAN:	call matscan

		ld a,e			; bail if no presses
		cp 0ffh
		jr z,nokeys

		call shstate		; get shift state

kprocess:	CALL KEY2ASC

		ld a,e
		cp 0ffh
		jr nz,kproc


nokeys:		ld a,kdelayone		; no key, so reset all states and exit
		ld (kdelayval),a

		ld a,0ffh
		ld (oldkey),a

		ret


kproc:		ld a,(oldkey)		; first push ?
		cp e
		jr z,repeat

		ld a,e			; return key in e, set as pushed
		ld (oldkey),a
		ret

repeat:		ld a,(kdelayval)
		dec a
		ld (kdelayval),a
		jr nz,noMkey

		ld a,kdelay		; reset delay value and return key in e
		ld (kdelayval),a
		ret

noMkey:		ld e,0ffh		; return no key pressed
            	ret


; --------------------------------------------
; returns
;
; E = scancode 00h - 3fh
; E = ffh = nothing pressed
; --------------------------------------------

matscan:       	LD      L,0FFh      	;Row value accumulator. Add 8 for each ROW
            	LD      E,0FFh		;Return Value if no key is pressed
            	LD      b,0FEh
		ld c,MATRIX 	  	;Port = C, A8-A15 = B. B loaded with only A8 = 0 to start.




KLINE:		call getLine

            	CPL                 	;Invert to check for zero
      		AND	$FF           	;sets flags
            	JR      Z,KDONE     	;If Zero, no key press for Address line
            	LD      H,A         	;Save key(s) pressed data in H
            	LD      A,L         	;Load A with the current ROW count*8

KBITS:		INC     A           	;Add one until data bit found
            	SRL     H           	;Shift H right until bit is detected
            	JR      NC,KBITS    	;If Carry is not set, shift again
            	LD      E,A         	;Store key detected
            	JR      NZ,KBITS    	;Keep going until all bits are checked.

KDONE:		LD      A,08H       	;
            	ADD     A,L         	;Increase L by 8 for each ROW checked
            	LD      L,A
            	RLC     B           	;Move to next address line
            	JR      C,KLINE     	;if more address lines needed repeat key check

		ret


getLine:	push de
	       	IN      A,(C)       	;Check data bus for Port C and high address B

kloopReset:
		ld e,a
		ld d,0
		
kloop:         	IN      A,(C)       	; debounce loop. have to read same input multiple times to be valid
		cp e
		jr nz, kloopReset

		inc d
		ld a,d
		cp 08h
		jr nz,kloop

		LD a,e			; restore keypress value
		pop de
		ret

; ------------------------------------------------------
; setup shift/ctrl/fn/caps state
;
; returns D = keystate
;
; must not alter E
; ------------------------------------------------------

shstate:
	      	LD BC,0FEFEh  	 	;Port = C, A8-A15 = B. B loaded with only A8 = 0

		call getLine

		cpl
		and 87h
		ld d,a			; bit encoded 1,2,4 & 80h ... shift/ctrl/fn/Caps store for use

; handle caps lock
		and 80h			; Pressing Caps?
		jr z, KLINEC		; not pressed


capspressed:	ld b,a
		ld a,(oldcaps)		; first press/held down?
		cp b
		ret z			; not first push

togglecaps:
		ld a,(capsval)		; toggle state
		xor 01h
		ld (capsval),a
;
		rrca			; update CAPS LED state - value to bit 7
		ld c,a			; set bit 7 if needed and store in c
		ld a,(cfgMode)
		and 07fh		; turn off bit	7
		or c			; turn on bit 7 if needed
		ld (cfgMode),a
		out (SYSCTRL),a
;
		ld a,b
KLINEC:		ld (oldcaps),a		; set oldcaps
		ret


; ------------------------------------------------------
; scan code to ASCII conversion
;
; prerequisite: shift state has to be accurate
;
; in: E = scancode
; out E = translated ASCII value
; ------------------------------------------------------


KEY2ASC:	ld a,e			; exit if no key pressed
		cp 0ffh
		ret z

		ld hl,keytable

; work out modified keys based on shift

		cp 3fh			; special case key 3fh
		jr z,doadd
		cp 24h			; skip next bit if < A key
		jr nc, ascloop
		cp 0eh			; and >= ' key
		jr c, ascloop

doadd:		ld a,d			; check if shift pressed
		and 1
		jr z, ascloop

		ld a,e			; shifted-key, so
		add a,40h		; add 40h to lookup value
		ld e,a

; lookup key mappings

ascloop:	ld a,(hl)
		inc hl
		cp 0ffh			; end of table?
		jr z,add1d

		cp e
		jr z, fixx

		inc hl			; skip mapped value
		jr ascloop		; try next map


fixx:		ld a,(hl)
		ld e,a			; insert new keyvalue
		ret


; if we get here its a letter or number
; only letters get a shift/caps based-adjustment
; as numbers already processed earlier

add1d:		ld a,e			; default conversion to ascii
		add a,1dh
		ld e,a

		cp 41h			; skip next bit if not a letter
		ret c

		ld a,d			; reconcile caps and shift states
		and 1
		ld b,a
		ld a,(capsval)
		xor b
		ret nz

		ld a,e
		add a,020h		; offset caps/lwr
		ld e,a
		ret


keytable:

; 'mask off' the modifier keys
		.db 00,0ffh	; Shift
		.db 01,0ffh	; Ctrl
		.db 02,0ffh	; Fn
		.db 07,0ffh	; Caps

; arrows
		.db 03,03	; up
		.db 04,04	; down
		.db 05,05	; left
		.db 06,06	; right

; always nonshifted special keys
		.db 08h,7fh	; del
		.db 09h,09h	; Tab
		.db 0ah,0dh	; Enter
		.db 0ch,1bh	; Esc
		.db 0dh,20h	; Space

; noshifted & shifted special keys
		.db 0eh,27h	; '
		.db 4eh,22h	; "
		.db 0fh,2ch	; ,
		.db 4fh,3ch	; <
		.db 10h,2dh	; -
		.db 50h,5fh	; _
		.db 11h,2eh	; .
		.db 51h,3eh	; >
		.db 12h,5ch	; \
		.db 52h,7Ch	; |
		.db 1eh,3bh	; ;
		.db 5eh,3ah	; :
		.db 20h,3dh	; =
		.db 60h,2bh	; +
		.db 3fh,2fh	; /
		.db 7fh,3fh	; ?

; shift-numbers
		.db 53h,29h	; )
		.db 54h,21h	; !
		.db 55h,40h	; @
		.db 56h,23h	; #
		.db 57h,24h	; $
		.db 58h,25h	; %
		.db 59h,5eh	; ^
		.db 5ah,26h	; &
		.db 5bh,2ah	; *
		.db 5ch,28h	; (

		.db 0ffh	; end of table

kdelay		.equ 20h	; length of key repeat delay
kdelayone	.equ 0ffh	; initial key repeat delay
