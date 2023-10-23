musicRoutine: ld de, noteTable

GetNote:	ld a, (de)		; load a note from the user's table
		and 1fh
		cp 1fh			; 1F = Terminator and return to caller
		ret z
		cp 1eh			; 1E = Terminator and loop (play it again)
		jp z,musicRoutine	; Back to start
		cp 0
		jp z,mPause		; 0 = silence
		ld b,a
		inc de
		push de
		ld hl, NotePitchTable
		call FetchTableValue
		push af
		ld a,b
		ld hl,NoteLengthTable
		call FetchTableValue
		ld l,a
		ld h,0
		pop af
		ld c, a
		call PlayNote		; HL = length, C = Note Pitch
		pop de
		jp GetNote		; load a note from the user's table

FetchTableValue:
		ld e,a
		ld d,0
		add hl,de
		ld a,(hl)
		ret

mPause:		push de
		ld de,8000h

innerloop:	dec de
		ld a,d
		or e
		jp nz,innerloop
		pop de
		inc de
		jp GetNote		; load a note from the user's table



; HL = length, C = Note Pitch
PlayNote:	add hl,hl		; Pad it out for 4MHz
		add hl,hl
		add hl,hl
		add hl,hl

		ld de, 1
		xor a
		out (SEGS), a		; clear display segments
		dec a

loc19B:		out (DIGITS), a
		ld b, c

loc19E:		djnz $
		xor 80h
		sbc hl,de
		jr nz, loc19B
		ret



NotePitchTable: .db 8Ch, 83h, 7Ch, 75h, 70h, 67h, 62h, 5Ch, 57h, 52h, 4Eh
		.db 48h, 45h, 41h, 3Ch, 39h, 36h, 32h, 2Fh, 2Ch, 2Ah, 27h
		.db 25h, 23h

NoteLengthTable:.db 19h, 1Ah, 1Ch, 1Dh, 1Eh, 20h, 23h, 25h, 27h, 29h, 2Ch
		.db 2Eh, 31h, 33h, 37h, 3Ah, 3Dh, 41h, 45h, 49h, 4Dh, 52h
		.db 57h, 5Ch

noteTable:	.db 06h, 06h, 0Ah, 0Dh, 06h, 0Dh, 0Ah, 0Dh, 12h, 16h, 14h, 12h
		.db 0Fh, 11h, 12h, 0Fh, 0Dh, 0Dh, 0Dh, 0Ah, 12h, 0Fh, 0Dh
		.db 0Ah, 08h, 06h, 08h, 0Ah, 0Fh, 0Ah, 0Dh, 0Fh, 06h, 06h, 0Ah, 0Dh
		.db 06h, 0Dh, 0Ah, 0Dh, 12h, 16h, 14h, 12h, 0Fh, 11h, 12h
		.db 0Fh, 0Dh, 0Dh, 0Dh, 0Ah, 12h, 0Fh, 0Dh, 0Ah, 08h, 06h, 08h
		.db 0Ah, 06h, 12h, 00h, 1Fh

