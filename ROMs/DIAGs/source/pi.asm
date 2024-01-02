; PiSpigot. Adapted for tTSM and the TEC-1G.
;
; Original code from https://github.com/GmEsoft/Z80-MBC2_PiSpigot/tree/master
;
; With thanks to GmEsoft for open sourcing PiSpigot

;-----------------------------------------------------------------------------
; 	Settings
DEBUG	.EQU	0			; Debug mode
NDIGITS	.EQU	100			; Number of digits to compute (9674 max)

;-----------------------------------------------------------------------------
;	Send one char
PUTCH:
	call buffAddChar
	call buffToLcd

	ld a,(COUNTlcd)
	inc a
	ld (COUNTlcd),a
	cp 13h
	ret nz

	xor a
	ld (COUNTlcd),a
	ld a,0dh			; add a new line
	call buffAddChar

;	call lcdReady
;	out (LCDDATA),a
	RET				; Done

;-----------------------------------------------------------------------------
;	Display HL in decimal
PUTHL4:	LD	DE,1000			;
	CALL	PUT1HL			; Display thousands
	LD	DE,100			;
	CALL	PUT1HL			; Display hundreds
	LD	DE,10			;
	CALL	PUT1HL			; Display tens
	LD	A,L			;
	JR	PUTHL1			; Display units
PUT1HL	LD	A,0FFH			; Init counter
PUT1HL1	INC	A			; Inc counter
	SBC	HL,DE			; Try subtract
	JR	NC,PUT1HL1		; Loop while OK
	ADD	HL,DE			; Revert subtract
PUTHL1	ADD	A,'0'			; Adjust for ASCII digit
	JR	PUTCH			; Display it

;-----------------------------------------------------------------------------
;	Display A in decimal
PUTA2:	LD	B,10			;
	CALL	PUT1A			; Display tens
PUTA1:	ADD	A,'0'			; Adjust for ASCII digit
	JR	PUTCH			; Display units
PUT1A:	LD	C,0FFH			; Init counter
PUT1A1:	INC	C			; Inc counter
	SUB	B			; Try subtract
	JR	NC,PUT1A1		; Loop while OK
	ADD	A,B			; Revert subtract
	LD	B,A			; Save
	LD	A,C			; Get digit
	CALL	PUTA1			; Display it
	LD	A,B			; Restore
	RET				; Done

;-----------------------------------------------------------------------------
;	Div HL by DE
DIVHLDE:
;	Scale divisor
	XOR	A			; Init loop counter
	EX	DE,HL			; Divisor to HL
DIVL1	INC	A			; Inc counter
	RET	Z			; Overflow: return
	ADD	HL,HL			; Shift left divisor
	JR	NC,DIVL1		; Loop while not past left bound
	RR	H			; Restore scaled divisor
	RR	L			;
	LD	B,H			; Scaled Divisor to BC
	LD	C,L			;
	EX	DE,HL			; Dividend to HL
	LD	DE,0			; Clear quotient
DIVL2:	EX	DE,HL			; Shift left quotient
	ADD	HL,HL			;
	EX	DE,HL			;
	SBC	HL,BC			; Try to subtract divisor from dividend (C is cleared)
	INC	DE			; Try to Add 1 to quotient
	JR	NC,DIVJ2		; If OK, go
	DEC	DE			; Cancel addition to quotient
	ADD	HL,BC			; Cancel subtraction
DIVJ2:	SRL	B			; Shift right divisor
	RR	C			;
	DEC	A			; Dec loop counter
	JR	NZ,DIVL2		; Continue while counter > 0
	EX	DE,HL			; Quotient to HL, remainder to DE
	RET				; Done

;-----------------------------------------------------------------------------
;	Long Div HL by DE
LDIVHLDE:
;	Scale divisor
	LD	B,4			; Non-null dividend byte counter
	EX	DE,HL			; Divisor to HL, low word
	EXX				;
	EX	DE,HL			; idem, high word
	LD	A,D			; Get dividend high byte (3)
	OR	A			; Check it
	LD	A,E			; Get dividend next byte (2)
	EXX				;
	JR	NZ,LDIVJ0		; Go if divid high byte is not null
	DEC	B			; dec byte counter
	OR	A			; Check divid next byte (2)
	JR	NZ,LDIVJ0		; Go if divid next byte (2) is not null
	DEC	B			; dec byte counter
	OR	D			; Check divid next byte (1)
	JR	NZ,LDIVJ0		; Go if divid next byte (1) is not null
	DEC	B			; dec byte counter
LDIVJ0:	LD	A,B			; mult byte counter by 8
	ADD	A,A			;
	ADD	A,A			;
	ADD	A,A			;
	LD	B,A			;
	XOR	A			; Init loop counter
LDIVL1:	DEC	B			; Dec byte counter
	JR	Z,LDIVJ1		; exit loop when zero
	INC	A			; Inc counter
	RET	Z			; Overflow: return

	ADD	HL,HL			; Shift left divisor, low word
	EXX				;
	ADC	HL,HL			; Idem, high word
	EXX				;

	JR	NC,LDIVL1		; Loop while not past left bound

LDIVJ1:	EXX				;
	RR	H			; Restore scaled divisor, high word
	RR	L			;
	LD	B,H			; Scaled divisor to BC, high word
	LD	C,L			;
	EX	DE,HL			; Dividend to HL, high word
	LD	DE,0			; Clear quotient, high word
	EXX				;
	RR	H			; Restore scaled divisor, low word
	RR	L			;
	LD	B,H			; Scaled divisor to BC, low word
	LD	C,L			;
	EX	DE,HL			; Dividend to HL, low word
	LD	DE,0			; Clear quotient, low word

LDIVL2:	EX	DE,HL			; Shift left quotient, high word
	ADD	HL,HL			;
	EX	DE,HL			;
	EXX				;
	EX	DE,HL			; Idem, high word
	ADC	HL,HL			;
	EX	DE,HL			;
	EXX				;

	SBC	HL,BC			; Try to subtract divisor from dividend, low word (C is cleared)
	EXX
	SBC	HL,BC			; Idem, high word
	EXX

	INC	DE			; Try to Add 1 to quotient
	JR	NC,LDIVJ2		; If OK, go
	DEC	DE			; Cancel addition to quotient

	ADD	HL,BC			; Cancel subtraction, low word
	EXX				;
	ADC	HL,BC			; Idem, high word
	EXX				;

LDIVJ2:	EXX				;
	SRL	B			; Shift right divisor, high word
	RR	C			;
	EXX				;
	RR	B			; Idem, low word
	RR	C			;

	DEC	A			; Dec loop counter
	JR	NZ,LDIVL2		; Continue while counter > 0

	EX	DE,HL			; Quotient to HL, remainder to DE, low word
	EXX				;
	EX	DE,HL			; idem, high word
	EXX				;

	RET				; Done

;-----------------------------------------------------------------------------
;	Long MUL HL,DE (condition: HL' == 0)
;	HL':HL := HL * DE':DE
LMULHLDE16:
	CALL	LLDBCHL			; Move multiplicand HL':HL to BC':BC
	LD	HL,0			; Product, HL':HL := 0
	EXX				;
	LD	HL,0			;
	EXX				;
	LD	A,16			; Loop counter, only 16 loops because HL' == 0
LMULL1:	EXX				; Multiplicand, BC':BC >>= 1
	SRL	B			;
	RR	C			;
	EXX				;
	RR	B			;
	RR	C			;
	CALL	C,LADDHLDE		; Product += Multiplicator if multiplicand's last bit was 1
	EX	DE,HL			; product, HL':HL <<= 1
	ADD	HL,HL			;
	EX	DE,HL			;
	EXX				;
	EX	DE,HL			;
	ADC	HL,HL			;
	EX	DE,HL			;
	EXX				;
	DEC	A			; Decrement loop counter
	JR	NZ,LMULL1		; Continue while counter > 0
	RET				; Done

;-----------------------------------------------------------------------------
;	Long LD BCx,HLx
;	BC':BC := HL':HL
LLDBCHL:
	LD	B,H			; BC := HL
	LD	C,L			;
	EXX				;
	LD	B,H			; BC' := HL'
	LD	C,L			;
	EXX				;
	RET				; Done

;-----------------------------------------------------------------------------
;	Long ADD HLx,BCx
;	HL':HL += BC':BC
LADDHLBC:
	ADD	HL,BC			; HL += BC
	EXX				;
	ADC	HL,BC			; HL' += BC' + carry
	EXX				;
	RET				; Done

;-----------------------------------------------------------------------------
;	Long ADD HLx,DEx
;	HL':HL += DE':DE
LADDHLDE:
	ADD	HL,DE			; HL += DE
	EXX				;
	ADC	HL,DE			; HL' += DE' + carry
	EXX				;
	RET				; Done

;-----------------------------------------------------------------------------
;	Long ADD HLx,HLx
;	HL':HL <<= 1
LADDHLHL:
	ADD	HL,HL			; HL <<= 1
	EXX				;
	ADC	HL,HL			; HL' <<= 1 with carry
	EXX				;
	RET				; Done


;-----------------------------------------------------------------------------
;	Long MUL HLx,10L
LMULHL10:
	CALL	LLDBCHL			; BC':BC := HL':HL
	CALL	LADDHLHL		; HL':HL <<= 1		=> 2 * HL':HL
	CALL	LADDHLHL		; HL':HL <<= 1		=> 4 * HL':HL
	CALL	LADDHLBC		; HL':HL += BC':BC 	=> 5 * HL':HL
	CALL	LADDHLHL		; HL':HL <<= 1		=> 10 * HL':HL
	RET				; Done


;-----------------------------------------------------------------------------
;	Pi-Spigot OneLoop routine
OneLoop:
;	I := I * 10 DIV 3 + 16
	CALL	LMULHL10		; I *= 10
	CALL	LDIVHLDE		; I /= 3 (3 was loaded in DE':DE before call)
	LD	BC,16			;
	ADD	HL,BC			; I += 16 (6 safety digits)
	LD	(Inn),HL			; update I

;	IF ( I > LEN ) THEN I := LEN;
	EX	DE,HL			; I to DE
	LD	HL,(LENnn)		; LEN to HL
	OR	A			;
	SBC	HL,DE			; Compare I to LEN
	EX	DE,HL			; I to HL
	JR	NC,ILELEN		; if LEN < I then
	LD	HL,(LENnn)		;   I := LEN
ILELEN:	LD	(Inn),HL			; update I
	ADD	HL,HL			; I *= 2
	LD	DE,ARRAY		; ARRAY origin
	ADD	HL,DE			; ARRAY + 2 * I
	PUSH	HL			;
	POP	IX			; to IX, ARRAY pointer

;	RES := 0;
	LD	HL,0			; Clear RES
	LD	(RESnn),HL		;

;	REPEAT
REPT1:
;	X := 10 * A[I] + RES * I;
	LD	HL,(RESnn)		; RES to HL
	LD	DE,(Inn)			; I to DE
	EXX				;
	LD	HL,0			; HL' := DE' := 0
	LD	DE,0			;   low words only
	EXX				;
	CALL	LMULHLDE16		; HL':HL := HL * DE == RES * I
	EX	DE,HL			; to DE':DE (low word)
	LD	L,(IX+0)		; HL := ARRAY[I] (16 bits)
	LD	H,(IX+1)		;
	EXX				;
	EX	DE,HL			; to DE':DE (high word)
	LD	HL,0			; HL' := 0 because ARRAY[I] < 10000H
	EXX				;
	CALL	LMULHL10		; HL':HL *= 10 		( == 10 * ARRAY[I] )
	CALL	LADDHLDE		; HL':HL += DE':DE 	( += RES * I )
	PUSH	HL			; Save HL (no need to save HL')

;	K := 2*I - 1
	LD	HL,(Inn)			; I to HL (low word only because I < 8000H)
	ADD	HL,HL			; HL <<= 1		( 2*I )
	DEC	HL			; HL -= 1		( 2*I - 1 )
	EX	DE,HL			; to DE
	POP	HL			; restore HL
	EXX				;
	LD	DE,0			; DE' := 0
	EXX				;

;	RES := X DIV K;
;	A[I] := X MOD K;
	CALL	LDIVHLDE		; HL /= DE 		( X / ( 2*I - 1 ) )
	LD	(RESnn),HL		; RES := quotient
	LD	(IX+0),E		; ARRAY[I] := remainder (16 bits)
	LD	(IX+1),D		;

;	I := I - 1;
	DEC	IX			; Dec ARRAY pointer
	DEC	IX			;
	LD	HL,(Inn)			; I -= 1
	DEC	HL			;
	LD	(Inn),HL			;

;	UNTIL I <= 0;
	LD	A,H			; Check if I != 0
	OR	L			;
	JR	NZ,REPT1		; Continue if yes

	RET				; Done

;-----------------------------------------------------------------------------
;	Pi-Spigot Entry Point
pi:
;	LD	HL,SPIGOT$		; Welcome message
;	CALL	PUTS			; Display it
;	LD	HL,TIME_		; Get and save start time
;	CALL	READTIME		;


	call setupBuff
	xor a
	ld (COUNTlcd),a

	LD	IY,IY0			; Initialize variables pointer

;	N := NDIGITS;
	LD	HL,NDIGITS		; HL := Number of decimals to compute
	INC	HL			; + unit digit
	LD	(Nnn),HL			; Save to N

;	LEN = N * 10 DIV 3
	LD	DE,3			; Init DE':DE := Divisor (3)
	EXX				;
	LD	HL,0			; HL' := DE' := 0
	LD	DE,0			;
	EXX				;
	CALL	LMULHL10		; HL := 10 * N
	CALL	LDIVHLDE		; HL /= 3		( HL := 10 * N DIV 3 )
	LD	(LENnn),HL		; save to LEN

;	FOR J:=0 TO LEN DO A[J] := 2;
	INC	HL			; HL := LEN + 1
	LD	B,H			; Loop counter, BC := HL == LEN + 1
	LD	C,L			;
	ADD	HL,HL			; HL := ( LEN + 1 ) * 2
	LD	DE,ARRAY		; DE := ARRAY origin
	ADD	HL,DE			; DE += ( LEN + 1 ) * 2
	EXX				;
	LD	HL,0			; Save SP to HL'
	ADD	HL,SP			;
	EXX				;
	LD	SP,HL			; SP := HL
	LD	DE,2			; 2 to write
SPL01:	PUSH	DE			; Write 2 at SP ; SP -= 2
	DEC	BC			; Dec loop counter
	LD	A,B			;
	OR	C			;
	JR	NZ,SPL01		; Loop while counter > 0
	EXX				;
	LD	SP,HL			; Restore SP from HL'

;	NINES := 0;
	XOR	A			;
	LD	(IY+NINESS),A		; Counter of 9s := 0

;	PREDIGIT := 0;
	LD	(IY+PREDIGS),A		; Predigit := 0 (maybe useless)

;	GROUPS := 10
	LD	(IY+GROUPSS),10		; Groups of 5 digits counter (for NL)

;	GROUP := 6
	LD	(IY+GROUPS),6		; Digits counter

;	DOT := '.'
	LD	(IY+DOTS),'.'		; Dot to display after 1st digit


;	FOR J := 0 TO N DO
	LD	HL,0			; J := 0
	LD	(Jnn),HL			;
	DEC	HL			; Init decimals counter
	LD	(COUNTnn),HL		;

FORJ:
	LD	HL,(Jnn)			; HL := J

;	QI := OneLoop ( N - J );

;	I := N - J;
	EX	DE,HL			; DE := J
	LD	HL,(Nnn)			; HL := N
	OR	A			;
	SBC	HL,DE			; HL -= DE	( N - J )
	LD	DE,3			; Load divisor 3 to DE':DE
	EXX				;
	LD	HL,0			; HL' := 0	( N - J < 10000H )
	LD	DE,0			; DE' := 0
	EXX				;

	CALL	OneLoop			; Base conversion fot 1 digit

;	Q := RES DIV 10;
;	A[1] := RES MOD 10;
	LD	HL,(RESnn)		; RES == 10 * digit + remainder
	LD	DE,10			;
	CALL	DIVHLDE			; RES /= 10 (in HL with H == 0)
	LD	(ARRAY+2),DE		; Remainder in DE to ARRAY[1]

;	IF Q = 9 THEN INC(NINES);
	LD	A,L			; Examine Digit
	CP	9			; If not 9
	JR	NZ,QNOT9		;   go
	INC	(IY+NINESS)		; else count 9s
	JR	ENDIF1			; Done

;	ELSE IF Q = 10 THEN
QNOT9:	CP	10			; If not 10
	JR	NZ,QNOT10		;   go

;	OUTDIG( 1 + PREDIGIT );
;	PREDIGIT := 0;
	LD	A,(IY+PREDIGS)		; Else get digit preceding 9s
	LD	(IY+PREDIGS),0		; Clear stored value
	INC	A			; Increment digit
	CALL	OUTDIG			; Display it

;	WHILE NINES > 0 DO
;	BEGIN
;	  OUT( '0' );
;	  NINES := NINES - 1;
;	END;

	LD	A,(IY+NINESS)		; Check for 9s
	OR	A			;
	JR	Z,NOZEROS		; Go if none
WZEROS:	XOR	A			; Display 0s instead of 9s
	CALL	OUTDIG			;
	DEC	(IY+NINESS)		; Dec 9s counter
	JR	NZ,WZEROS		; Loop until all 0s displayed
NOZEROS:
	JR	ENDIF1			; Done

;	ELSE
QNOT10:
;	IF J > 0 THEN OUTDIG( PREDIGIT );
;	PREDIGIT := Q
	LD	A,(IY+JS)		; Get J
	OR	(IY+JS+1)		; Is it 0 (first loop) ?
	LD	A,(IY+PREDIGS)		; Load digit preceding 9s
	LD	(IY+PREDIGS),L		; Store new digit
	CALL	NZ,OUTDIG		; Display if not first loop

;	WHILE NINES > 0 DO
;	BEGIN
;	  OUT( '9' );
;	  NINES := NINES - 1;
;	END;
	LD	A,(IY+NINESS)		; Check for 9s
	OR	A			;
	JR	Z,NONINES		; Go if none
WNINES:	LD	A,9			; Display 9s
	CALL	OUTDIG			;
	DEC	(IY+NINESS)		; Dec 9s counter
	JR	NZ,WNINES		; Loop until all 9s displayed
NONINES:

ENDIF1:	LD	HL,(Jnn)			; Get J, main loop counter
	INC	HL			; Increment it
	LD	(Jnn),HL			; Store new value
	LD	DE,(Nnn)			; Compare with N
	OR	A			;
	SBC	HL,DE			; J == N ?
	LD	A,H			;
	OR	L			;
	JP	NZ,FORJ			; Loop until yes

	LD	A,(IY+PREDIGS)		; Display last digit preceding 8s
	CALL	OUTDIG			;

;	WHILE NINES > 0 DO
;	BEGIN
;	  OUT( '9' );
;	  NINES := NINES - 1;
;	END;
	LD	A,(IY+NINESS)		; Display following 9s if any
	OR	A			;
	JR	Z,NONINES2		;
WNINES2	LD	A,9			;
	CALL	OUTDIG			;
	DEC	(IY+NINESS)		;
	JR	NZ,WNINES2		;
NONINES2:

	call delay
	call delay
	ret

;-----------------------------------------------------------------------------
;	Display each digit of Pi, with grouping and new lines
OUTDIG:	ADD	A,'0'			; Convert to ASCII digit
	CALL	PUTCH			; Display char
	LD	A,(IY+DOTS)		; Get dot if any
	LD	(IY+DOTS),0		; Only once
	OR	A			; Is there a dot ?
	CALL	NZ,PUTCH		; If yes, display it
	LD	HL,(COUNTnn)		; Get counter
	INC	HL			; Increment it
	LD	(COUNTnn),HL		; Save it
	ret

