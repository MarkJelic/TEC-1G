; TEC-1G TMS9918A demo - 8-sprite maxed-out version with flicker balancing
; Target CPU   : Z80
; Origin       : 8000h
; VDP ports    : data=BEh  control=BFh
; Display mode : TMS9918A Graphics I, 16x16 sprites enabled
;
; Overview
; --------
; This demo combines several classic TMS9918A effects within the limits of
; Graphics I mode and 16 KiB VRAM:
;
; 1) Animated plasma / rainbow style tile field in the background.
; 2) Large 16x96 "TEC-1G" logo built from 12x2 character cells.
; 3) Smooth pixel scroll of the logo using 8 precomputed sub-pixel phases.
; 4) Bidirectional bounce of the scrolling logo across the screen.
; 5) Colour-cycling text by rewriting the colour table groups used by the logo.
; 6) Eight sprite entries that are flicker-balanced by rotating priority order
;    each frame. The TMS9918A can only display four sprites per scanline, so
;    this technique spreads the loss more evenly across sprites.
;
; VRAM layout
; -----------
; Pattern table          0000h
; Name table             0800h
; Colour table           2000h
; Sprite attribute table 1B00h
; Sprite pattern table   3800h
;
; Program size  : 2617 bytes
; End address   : 0x8a38
;
; Notes
; -----
; - The logo phase selects one of 8 banks of 24 character patterns.
; - Sprite flicker balancing is done by changing the order in which the 8
;   logical sprites are emitted to the sprite attribute table each frame.
; - Backdrop colour is cycled from PHASE via register 7.
;
        ORG     08000h

START:  LD      SP,08FFFh
        CALL    INITVDP
        CALL    LOADPAT
        CALL    LOADCOL
        CALL    LOADSPRPAT
        XOR     A
        LD      (PHASE),A
        LD      (DIR),A
        LD      A,014h
        LD      (COLPOS),A
        XOR     A
        LD      (TIMER),A

MAIN:   CALL    DRAWBG
        CALL    DRAWTEXT
        CALL    UPDATELETTERCOL
        CALL    DRAWSPRITES
        CALL    UPDATEBG
        CALL    DELAY
        CALL    UPDATESCROLL
        JR      MAIN

; ------------------------------------------------------------
; Initialise VDP registers from REGTAB
; ------------------------------------------------------------
INITVDP:
        LD      HL,REGTAB
        LD      B,08h
        LD      C,00h
IVLP:   LD      A,(HL)
        OUT     (0BFh),A
        LD      A,C
        OR      080h
        OUT     (0BFh),A
        INC     HL
        INC     C
        DJNZ    IVLP
        RET

; ------------------------------------------------------------
; Load character pattern table for background + all text phases.
; ------------------------------------------------------------
LOADPAT:
        LD      HL,0000h
        CALL    SETWADDR
        LD      HL,PATTERNS
        LD      BC,0700h
LP1:    LD      A,(HL)
        OUT     (0BEh),A
        INC     HL
        DEC     BC
        LD      A,B
        OR      C
        JR      NZ,LP1
        RET

; ------------------------------------------------------------
; Initialise colour table.
; ------------------------------------------------------------
LOADCOL:
        LD      HL,2000h
        CALL    SETWADDR
        LD      HL,COLTABSTART
        LD      BC,0020h
LC1:    LD      A,(HL)
        OUT     (0BEh),A
        INC     HL
        DEC     BC
        LD      A,B
        OR      C
        JR      NZ,LC1
        RET

; ------------------------------------------------------------
; Load sprite pattern generator data at 3800h.
; ------------------------------------------------------------
LOADSPRPAT:
        LD      HL,3800h
        CALL    SETWADDR
        LD      HL,SPRITEPAT
        LD      BC,0080h
LSP1:   LD      A,(HL)
        OUT     (0BEh),A
        INC     HL
        DEC     BC
        LD      A,B
        OR      C
        JR      NZ,LSP1
        RET

; ------------------------------------------------------------
; Draw plasma/rainbow background into the 32x24 name table.
; Each row starts from a shifted phase to create diagonal motion.
; ------------------------------------------------------------
DRAWBG:
        LD      HL,0800h
        CALL    SETWADDR
        LD      D,018h
        LD      A,(PHASE)
        LD      E,A
BGROW:  LD      B,020h
        LD      A,E
BGCOL:  AND     01Fh
        OUT     (0BEh),A
        INC     A
        DJNZ    BGCOL
        LD      A,E
        ADD     A,003h
        LD      E,A
        DEC     D
        JR      NZ,BGROW
        RET

; ------------------------------------------------------------
; Draw the large 12x2-cell TEC-1G logo. PHASE selects which 24-pattern
; bank is used so that the logo can move one pixel at a time.
; ------------------------------------------------------------
DRAWTEXT:
        LD      A,(PHASE)
        LD      D,A
        ADD     A,A
        ADD     A,A
        ADD     A,A
        LD      E,A
        ADD     A,A
        ADD     A,E
        ADD     A,020h
        LD      E,A              ; E = 32 + phase*24

        LD      A,(COLPOS)
        LD      C,A
        LD      B,00h
        LD      HL,0940h         ; row 10
        ADD     HL,BC
        CALL    SETWADDR
        LD      B,00Ch
TXT1:   LD      A,E
        OUT     (0BEh),A
        INC     E
        DJNZ    TXT1

        LD      A,(COLPOS)
        LD      C,A
        LD      B,00h
        LD      HL,0960h         ; row 11
        ADD     HL,BC
        CALL    SETWADDR
        LD      B,00Ch
TXT2:   LD      A,E
        OUT     (0BEh),A
        INC     E
        DJNZ    TXT2
        RET

; ------------------------------------------------------------
; Cycle the logo colours by rewriting 24 colour groups starting at 2004h.
; ------------------------------------------------------------
UPDATELETTERCOL:
        LD      HL,2004h
        CALL    SETWADDR
        LD      A,(TIMER)
        AND     00Fh
        LD      C,A
        LD      B,00h
        LD      HL,COLORSEQ
        ADD     HL,BC
        LD      BC,0018h
ULC1:   LD      A,(HL)
        OUT     (0BEh),A
        INC     HL
        DEC     BC
        LD      A,B
        OR      C
        JR      NZ,ULC1
        RET

; ------------------------------------------------------------
; Draw 8 sprite entries with flicker balancing.
;
; TIMER&7 chooses which logical sprite is written first. This rotates the
; priority order from frame to frame so the same sprite does not always
; disappear first when more than four share a scanline.
; ------------------------------------------------------------
DRAWSPRITES:
        LD      HL,1B00h
        CALL    SETWADDR
        LD      A,(TIMER)
        AND     007h
        LD      E,A              ; start logical sprite index
        LD      D,008h           ; output 8 entries
SPLP:   LD      A,E
        AND     007h
        LD      C,A
        LD      B,00h

        LD      HL,OFFTAB
        ADD     HL,BC
        LD      A,(HL)
        LD      B,A              ; motion phase offset stored in B

        LD      A,(TIMER)
        ADD     A,B
        AND     03Fh
        LD      C,A
        LD      B,00h

        LD      HL,YTAB
        ADD     HL,BC
        LD      A,(HL)
        OUT     (0BEh),A

        LD      HL,XTAB
        ADD     HL,BC
        LD      A,(HL)
        OUT     (0BEh),A

        LD      A,E
        AND     007h
        LD      C,A
        LD      B,00h

        LD      HL,PATTAB
        ADD     HL,BC
        LD      A,(HL)
        OUT     (0BEh),A

        LD      HL,COLSPR
        ADD     HL,BC
        LD      A,(HL)
        OUT     (0BEh),A

        INC     E
        DEC     D
        JR      NZ,SPLP

        LD      A,0D0h           ; sprite list terminator (Y=208)
        OUT     (0BEh),A
        RET

; ------------------------------------------------------------
; Cycle backdrop colour through VDP register 7 using PHASE low nibble.
; ------------------------------------------------------------
UPDATEBG:
        LD      A,(PHASE)
        AND     00Fh
        OUT     (0BFh),A
        LD      A,087h
        OUT     (0BFh),A
        RET

; ------------------------------------------------------------
; Short delay loop for high-speed animation.
; ------------------------------------------------------------
DELAY:  LD      BC,1400h
DL1:    DEC     BC
        LD      A,B
        OR      C
        JR      NZ,DL1
        RET

; ------------------------------------------------------------
; Update frame timer and scroll state every frame. The text bounces between
; COLPOS=0 and COLPOS=20 using the 8 sub-pixel phases.
; DIR = 0 => moving left, DIR = 1 => moving right.
; ------------------------------------------------------------
UPDATESCROLL:
        LD      A,(TIMER)
        INC     A
        LD      (TIMER),A

        LD      A,(DIR)
        OR      A
        JR      NZ,SCROLLR

        ; moving left
        LD      A,(COLPOS)
        OR      A
        JR      NZ,LEFTCHKPH
        LD      A,(PHASE)
        OR      A
        JR      NZ,LEFTCHKPH
        LD      A,001h
        LD      (DIR),A
        RET

LEFTCHKPH:
        LD      A,(PHASE)
        INC     A
        CP      008h
        JR      C,SAVELEFTPH
        XOR     A
        LD      (PHASE),A
        LD      A,(COLPOS)
        DEC     A
        LD      (COLPOS),A
        RET

SAVELEFTPH:
        LD      (PHASE),A
        RET

SCROLLR:
        LD      A,(COLPOS)
        CP      014h
        JR      NZ,RIGHTCHKPH
        LD      A,(PHASE)
        OR      A
        JR      NZ,RIGHTCHKPH
        XOR     A
        LD      (DIR),A
        RET

RIGHTCHKPH:
        LD      A,(PHASE)
        OR      A
        JR      NZ,RIGHTDEC
        LD      A,007h
        LD      (PHASE),A
        LD      A,(COLPOS)
        INC     A
        LD      (COLPOS),A
        RET

RIGHTDEC:
        DEC     A
        LD      (PHASE),A
        RET

; ------------------------------------------------------------
; Set VRAM write address from HL.
; ------------------------------------------------------------
SETWADDR:
        LD      A,L
        OUT     (0BFh),A
        LD      A,H
        OR      040h
        OUT     (0BFh),A
        RET

; ------------------------------------------------------------
; VDP register table:
; R0 = 00h  Graphics I
; R1 = C2h  display on, 16 KiB VRAM, 16x16 sprites
; R2 = 02h  name table @ 0800h
; R3 = 80h  colour table @ 2000h
; R4 = 00h  pattern table @ 0000h
; R5 = 36h  sprite attribute table @ 1B00h
; R6 = 07h  sprite pattern table @ 3800h
; R7 = 01h  backdrop = black initially
; ------------------------------------------------------------
REGTAB:
        DB      000h,0C2h,002h,080h,000h,036h,007h,001h

; Initial colour table
COLTABSTART:
        DB      041h,061h,081h,0C1h,0F1h,0F1h,0F1h,0F1h,0F1h,0F1h,0F1h,0F1h,0F1h,0F1h,0F1h,0F1h
        DB      0F1h,0F1h,0F1h,0F1h,0F1h,0F1h,0F1h,0F1h,0F1h,0F1h,0F1h,0F1h,071h,071h,071h,071h

; Cycling colour sequence used for the logo colour rewrite
COLORSEQ:
        DB      0F1h,0E1h,0D1h,0C1h,0B1h,0A1h,091h,081h,071h,061h,051h,041h,031h,021h,0F1h,0E1h
        DB      0F1h,0E1h,0D1h,0C1h,0B1h,0A1h,091h,081h,071h,061h,051h,041h,031h,021h,0F1h,0E1h
        DB      0F1h,0E1h,0D1h,0C1h,0B1h,0A1h,091h

; Per-logical-sprite motion offsets for priority rotation
OFFTAB:
        DB      000h,008h,010h,018h,020h,028h,030h,038h

; Pattern numbers for each logical sprite (16x16 sprite = 4 patterns)
PATTAB:
        DB      000h,000h,004h,004h,008h,008h,00Ch,00Ch

; Colour nibble values for each logical sprite
COLSPR:
        DB      00Fh,00Ch,00Ah,006h,00Eh,009h,007h,005h

; Background patterns followed by all 8 text sub-pixel phase banks
PATTERNS:
        DB      077h,0CCh,011h,0FFh,0FFh,044h,099h,077h,0CCh,011h,0FFh,000h,044h,099h,077h,088h
        DB      0EEh,000h,066h,0DDh,0FFh,011h,077h,0CCh,000h,066h,0DDh,000h,011h,077h,0CCh,011h
        DB      055h,0EEh,033h,0DDh,077h,0CCh,011h,0FFh,0EEh,033h,0DDh,088h,0CCh,011h,0FFh,0AAh
        DB      0AAh,044h,077h,0CCh,0EEh,000h,033h,088h,044h,077h,0CCh,011h,000h,033h,088h,055h
        DB      077h,0CCh,011h,0FFh,0FFh,044h,099h,077h,0CCh,011h,0FFh,000h,044h,099h,077h,088h
        DB      0EEh,000h,066h,0DDh,0FFh,011h,077h,0CCh,000h,066h,0DDh,000h,011h,077h,0CCh,011h
        DB      055h,0EEh,033h,0DDh,077h,0CCh,011h,0FFh,0EEh,033h,0DDh,088h,0CCh,011h,0FFh,0AAh
        DB      0AAh,044h,077h,0CCh,0EEh,000h,033h,088h,044h,077h,0CCh,011h,000h,033h,088h,055h
        DB      077h,0CCh,011h,0FFh,0FFh,044h,099h,077h,0CCh,011h,0FFh,000h,044h,099h,077h,088h
        DB      0EEh,000h,066h,0DDh,0FFh,011h,077h,0CCh,000h,066h,0DDh,000h,011h,077h,0CCh,011h
        DB      055h,0EEh,033h,0DDh,077h,0CCh,011h,0FFh,0EEh,033h,0DDh,088h,0CCh,011h,0FFh,0AAh
        DB      0AAh,044h,077h,0CCh,0EEh,000h,033h,088h,044h,077h,0CCh,011h,000h,033h,088h,055h
        DB      077h,0CCh,011h,0FFh,0FFh,044h,099h,077h,0CCh,011h,0FFh,000h,044h,099h,077h,088h
        DB      0EEh,000h,066h,0DDh,0FFh,011h,077h,0CCh,000h,066h,0DDh,000h,011h,077h,0CCh,011h
        DB      055h,0EEh,033h,0DDh,077h,0CCh,011h,0FFh,0EEh,033h,0DDh,088h,0CCh,011h,0FFh,0AAh
        DB      0AAh,044h,077h,0CCh,0EEh,000h,033h,088h,044h,077h,0CCh,011h,000h,033h,088h,055h
        DB      0FFh,0FFh,003h,003h,003h,003h,003h,003h,0FFh,0FFh,0C0h,0C0h,0C0h,0C0h,0C0h,0C0h
        DB      0FFh,0FFh,0C0h,0C0h,0C0h,0C0h,0FFh,0FFh,0FFh,0FFh,000h,000h,000h,000h,0C0h,0C0h
        DB      03Fh,07Fh,0C0h,0C0h,0C0h,0C0h,0C0h,0C0h,0FCh,0FEh,003h,000h,000h,000h,000h,000h
        DB      000h,000h,000h,000h,000h,000h,03Fh,03Fh,000h,000h,000h,000h,000h,000h,0FCh,0FCh
        DB      003h,007h,00Fh,003h,003h,003h,003h,003h,0C0h,0C0h,0C0h,0C0h,0C0h,0C0h,0C0h,0C0h
        DB      03Fh,07Fh,0C0h,0C0h,0C0h,0C0h,0C0h,0C0h,0FCh,0FEh,003h,000h,000h,000h,000h,0FFh
        DB      003h,003h,003h,003h,003h,003h,003h,003h,0C0h,0C0h,0C0h,0C0h,0C0h,0C0h,0C0h,0C0h
        DB      0C0h,0C0h,0C0h,0C0h,0C0h,0C0h,0FFh,0FFh,000h,000h,000h,000h,000h,000h,0FFh,0FFh
        DB      0C0h,0C0h,0C0h,0C0h,0C0h,0C0h,07Fh,03Fh,000h,000h,000h,000h,000h,003h,0FEh,0FCh
        DB      03Fh,03Fh,000h,000h,000h,000h,000h,000h,0FCh,0FCh,000h,000h,000h,000h,000h,000h
        DB      003h,003h,003h,003h,003h,003h,0FFh,0FFh,0C0h,0C0h,0C0h,0C0h,0C0h,0C0h,0FFh,0FFh
        DB      0C0h,0C0h,0C0h,0C0h,0C0h,0C0h,07Fh,03Fh,0FFh,003h,003h,003h,003h,003h,0FEh,0FCh
        DB      0FFh,0FFh,007h,007h,007h,007h,007h,007h,0FFh,0FFh,081h,081h,081h,081h,081h,081h
        DB      0FFh,0FFh,080h,080h,080h,080h,0FFh,0FFh,0FEh,0FEh,001h,001h,001h,001h,081h,081h
        DB      07Fh,0FFh,080h,080h,080h,080h,080h,080h,0F8h,0FCh,006h,000h,000h,000h,000h,000h
        DB      000h,000h,000h,000h,000h,000h,07Fh,07Fh,000h,000h,000h,000h,000h,000h,0F8h,0F8h
        DB      007h,00Fh,01Fh,007h,007h,007h,007h,007h,080h,080h,081h,081h,081h,081h,081h,081h
        DB      07Fh,0FFh,080h,080h,080h,080h,080h,081h,0F8h,0FCh,006h,000h,000h,000h,000h,0FEh
        DB      007h,007h,007h,007h,007h,007h,007h,007h,081h,081h,081h,081h,081h,081h,081h,081h
        DB      080h,080h,080h,080h,080h,080h,0FFh,0FFh,001h,001h,001h,001h,001h,001h,0FEh,0FEh
        DB      080h,080h,080h,080h,080h,080h,0FFh,07Fh,000h,000h,000h,000h,000h,006h,0FCh,0F8h
        DB      07Fh,07Fh,000h,000h,000h,000h,000h,000h,0F8h,0F8h,000h,000h,000h,000h,001h,001h
        DB      007h,007h,007h,007h,007h,007h,0FFh,0FFh,081h,081h,081h,081h,081h,081h,0FEh,0FEh
        DB      081h,080h,080h,080h,080h,080h,0FFh,07Fh,0FEh,006h,006h,006h,006h,006h,0FCh,0F8h
        DB      0FFh,0FFh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,0FFh,0FFh,003h,003h,003h,003h,003h,003h
        DB      0FFh,0FFh,000h,000h,000h,000h,0FFh,0FFh,0FCh,0FDh,003h,003h,003h,003h,003h,003h
        DB      0FFh,0FFh,000h,000h,000h,000h,000h,000h,0F0h,0F8h,00Ch,000h,000h,000h,000h,000h
        DB      000h,000h,000h,000h,000h,000h,0FFh,0FFh,000h,000h,000h,000h,000h,000h,0F0h,0F0h
        DB      00Fh,01Fh,03Fh,00Fh,00Fh,00Fh,00Fh,00Fh,000h,001h,003h,003h,003h,003h,003h,003h
        DB      0FFh,0FFh,000h,000h,000h,000h,000h,003h,0F0h,0F8h,00Ch,000h,000h,000h,000h,0FCh
        DB      00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,003h,003h,003h,003h,003h,003h,003h,003h
        DB      000h,000h,000h,000h,000h,000h,0FFh,0FFh,003h,003h,003h,003h,003h,003h,0FDh,0FCh
        DB      000h,000h,000h,000h,000h,000h,0FFh,0FFh,000h,000h,000h,000h,000h,00Ch,0F8h,0F0h
        DB      0FFh,0FFh,000h,000h,000h,000h,000h,000h,0F0h,0F0h,000h,000h,000h,000h,003h,003h
        DB      00Fh,00Fh,00Fh,00Fh,00Fh,00Fh,0FFh,0FFh,003h,003h,003h,003h,003h,003h,0FDh,0FCh
        DB      003h,000h,000h,000h,000h,000h,0FFh,0FFh,0FCh,00Ch,00Ch,00Ch,00Ch,00Ch,0F8h,0F0h
        DB      0FFh,0FFh,01Eh,01Eh,01Eh,01Eh,01Eh,01Eh,0FFh,0FFh,006h,006h,006h,006h,007h,007h
        DB      0FFh,0FFh,000h,000h,000h,000h,0FEh,0FEh,0F9h,0FBh,006h,006h,006h,006h,006h,006h
        DB      0FFh,0FFh,000h,000h,000h,000h,000h,000h,0E0h,0F0h,018h,000h,000h,000h,001h,001h
        DB      000h,000h,000h,000h,000h,000h,0FFh,0FFh,000h,000h,000h,000h,000h,000h,0E0h,0E0h
        DB      01Eh,03Eh,07Eh,01Eh,01Eh,01Eh,01Eh,01Eh,001h,003h,006h,006h,006h,006h,006h,006h
        DB      0FFh,0FFh,000h,000h,000h,000h,000h,007h,0E0h,0F0h,018h,000h,000h,000h,000h,0F8h
        DB      01Eh,01Eh,01Eh,01Eh,01Eh,01Eh,01Eh,01Eh,006h,006h,006h,006h,006h,006h,007h,007h
        DB      000h,000h,000h,000h,000h,000h,0FFh,0FFh,006h,006h,006h,006h,006h,006h,0FBh,0F9h
        DB      000h,000h,000h,000h,000h,000h,0FFh,0FFh,001h,001h,000h,000h,000h,018h,0F0h,0E0h
        DB      0FFh,0FFh,000h,000h,000h,000h,000h,000h,0E0h,0E0h,000h,000h,000h,000h,007h,007h
        DB      01Eh,01Eh,01Eh,01Eh,01Eh,01Eh,0FFh,0FFh,006h,006h,006h,006h,006h,006h,0FBh,0F9h
        DB      007h,000h,000h,000h,000h,000h,0FFh,0FFh,0F8h,018h,018h,018h,018h,018h,0F0h,0E0h
        DB      0FFh,0FFh,03Ch,03Ch,03Ch,03Ch,03Ch,03Ch,0FFh,0FFh,00Ch,00Ch,00Ch,00Ch,00Fh,00Fh
        DB      0FFh,0FFh,000h,000h,000h,000h,0FCh,0FCh,0F3h,0F7h,00Ch,00Ch,00Ch,00Ch,00Ch,00Ch
        DB      0FFh,0FFh,000h,000h,000h,000h,000h,000h,0C0h,0E0h,030h,000h,000h,000h,003h,003h
        DB      000h,000h,000h,000h,000h,000h,0FFh,0FFh,000h,000h,000h,000h,000h,000h,0C0h,0C0h
        DB      03Ch,07Ch,0FCh,03Ch,03Ch,03Ch,03Ch,03Ch,003h,007h,00Ch,00Ch,00Ch,00Ch,00Ch,00Ch
        DB      0FFh,0FFh,000h,000h,000h,000h,000h,00Fh,0C0h,0E0h,030h,000h,000h,000h,000h,0F0h
        DB      03Ch,03Ch,03Ch,03Ch,03Ch,03Ch,03Ch,03Ch,00Ch,00Ch,00Ch,00Ch,00Ch,00Ch,00Fh,00Fh
        DB      000h,000h,000h,000h,000h,000h,0FFh,0FFh,00Ch,00Ch,00Ch,00Ch,00Ch,00Ch,0F7h,0F3h
        DB      000h,000h,000h,000h,000h,000h,0FFh,0FFh,003h,003h,000h,000h,000h,030h,0E0h,0C0h
        DB      0FFh,0FFh,000h,000h,000h,000h,000h,000h,0C0h,0C0h,000h,000h,000h,000h,00Fh,00Fh
        DB      03Ch,03Ch,03Ch,03Ch,03Ch,03Ch,0FFh,0FFh,00Ch,00Ch,00Ch,00Ch,00Ch,00Ch,0F7h,0F3h
        DB      00Fh,000h,000h,000h,000h,000h,0FFh,0FFh,0F0h,030h,030h,030h,030h,030h,0E0h,0C0h
        DB      0FFh,0FFh,078h,078h,078h,078h,078h,078h,0FFh,0FFh,018h,018h,018h,018h,01Fh,01Fh
        DB      0FFh,0FFh,000h,000h,000h,000h,0F8h,0F8h,0E7h,0EFh,018h,018h,018h,018h,018h,018h
        DB      0FFh,0FFh,000h,000h,000h,000h,000h,000h,080h,0C0h,060h,000h,000h,000h,007h,007h
        DB      000h,000h,000h,000h,000h,000h,0FFh,0FFh,000h,000h,001h,000h,000h,000h,080h,080h
        DB      078h,0F8h,0F8h,078h,078h,078h,078h,078h,007h,00Fh,018h,018h,018h,018h,018h,018h
        DB      0FFh,0FFh,000h,000h,000h,000h,000h,01Fh,080h,0C0h,060h,000h,000h,000h,000h,0E0h
        DB      078h,078h,078h,078h,078h,078h,078h,078h,018h,018h,018h,018h,018h,018h,01Fh,01Fh
        DB      000h,000h,000h,000h,000h,000h,0FFh,0FFh,018h,018h,018h,018h,018h,018h,0EFh,0E7h
        DB      000h,000h,000h,000h,000h,000h,0FFh,0FFh,007h,007h,000h,000h,000h,060h,0C0h,080h
        DB      0FFh,0FFh,000h,000h,000h,000h,000h,000h,080h,080h,000h,000h,000h,000h,01Fh,01Fh
        DB      078h,078h,078h,078h,078h,078h,0FFh,0FFh,018h,018h,018h,018h,018h,018h,0EFh,0E7h
        DB      01Fh,000h,000h,000h,000h,000h,0FFh,0FFh,0E0h,060h,060h,060h,060h,060h,0C0h,080h
        DB      0FFh,0FFh,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0FFh,0FFh,030h,030h,030h,030h,03Fh,03Fh
        DB      0FFh,0FFh,000h,000h,000h,000h,0F0h,0F0h,0CFh,0DFh,030h,030h,030h,030h,030h,030h
        DB      0FFh,0FFh,000h,000h,000h,000h,000h,000h,000h,080h,0C0h,000h,000h,000h,00Fh,00Fh
        DB      000h,000h,000h,000h,000h,000h,0FFh,0FFh,000h,001h,003h,000h,000h,000h,000h,000h
        DB      0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,00Fh,01Fh,030h,030h,030h,030h,030h,030h
        DB      0FFh,0FFh,000h,000h,000h,000h,000h,03Fh,000h,080h,0C0h,000h,000h,000h,000h,0C0h
        DB      0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,030h,030h,030h,030h,030h,030h,03Fh,03Fh
        DB      000h,000h,000h,000h,000h,000h,0FFh,0FFh,030h,030h,030h,030h,030h,030h,0DFh,0CFh
        DB      000h,000h,000h,000h,000h,000h,0FFh,0FFh,00Fh,00Fh,000h,000h,000h,0C0h,080h,000h
        DB      0FFh,0FFh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,03Fh,03Fh
        DB      0F0h,0F0h,0F0h,0F0h,0F0h,0F0h,0FFh,0FFh,030h,030h,030h,030h,030h,030h,0DFh,0CFh
        DB      03Fh,000h,000h,000h,000h,000h,0FFh,0FFh,0C0h,0C0h,0C0h,0C0h,0C0h,0C0h,080h,000h
        DB      0FFh,0FFh,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0FFh,0FFh,060h,060h,060h,060h,07Fh,07Fh
        DB      0FFh,0FFh,000h,000h,000h,000h,0E0h,0E0h,09Fh,0BFh,060h,060h,060h,060h,060h,060h
        DB      0FEh,0FFh,001h,000h,000h,000h,000h,000h,000h,000h,080h,000h,000h,000h,01Fh,01Fh
        DB      000h,000h,000h,000h,000h,000h,0FEh,0FEh,001h,003h,007h,001h,001h,001h,001h,001h
        DB      0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,01Fh,03Fh,060h,060h,060h,060h,060h,060h
        DB      0FEh,0FFh,001h,000h,000h,000h,000h,07Fh,000h,000h,080h,000h,000h,000h,000h,080h
        DB      0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,060h,060h,060h,060h,060h,060h,07Fh,07Fh
        DB      000h,000h,000h,000h,000h,000h,0FFh,0FFh,060h,060h,060h,060h,060h,060h,0BFh,09Fh
        DB      000h,000h,000h,000h,000h,001h,0FFh,0FEh,01Fh,01Fh,000h,000h,000h,080h,000h,000h
        DB      0FEh,0FEh,000h,000h,000h,000h,000h,000h,001h,001h,001h,001h,001h,001h,07Fh,07Fh
        DB      0E0h,0E0h,0E0h,0E0h,0E0h,0E0h,0FFh,0FFh,060h,060h,060h,060h,060h,060h,0BFh,09Fh
        DB      07Fh,001h,001h,001h,001h,001h,0FFh,0FEh,080h,080h,080h,080h,080h,080h,000h,000h

; Sprite patterns (four 16x16 shapes)
SPRITEPAT:
        DB      018h,03Ch,07Eh,0FFh,0FFh,07Eh,03Ch,018h,018h,03Ch,07Eh,0FFh,0FFh,07Eh,03Ch,018h
        DB      018h,03Ch,07Eh,0FFh,0FFh,07Eh,03Ch,018h,018h,03Ch,07Eh,0FFh,0FFh,07Eh,03Ch,018h
        DB      07Eh,0C3h,099h,0A5h,0A5h,099h,0C3h,07Eh,07Eh,0C3h,099h,0A5h,0A5h,099h,0C3h,07Eh
        DB      07Eh,0C3h,099h,0A5h,0A5h,099h,0C3h,07Eh,07Eh,0C3h,099h,0A5h,0A5h,099h,0C3h,07Eh
        DB      018h,024h,07Eh,0DBh,0FFh,07Eh,024h,018h,018h,024h,07Eh,0DBh,0FFh,07Eh,024h,018h
        DB      018h,024h,07Eh,0DBh,0FFh,07Eh,024h,018h,018h,024h,07Eh,0DBh,0FFh,07Eh,024h,018h
        DB      0C3h,066h,03Ch,0FFh,0FFh,03Ch,066h,0C3h,0C3h,066h,03Ch,0FFh,0FFh,03Ch,066h,0C3h
        DB      0C3h,066h,03Ch,0FFh,0FFh,03Ch,066h,0C3h,0C3h,066h,03Ch,0FFh,0FFh,03Ch,066h,0C3h

; Motion lookup tables
XTAB:
        DB      074h,07Eh,088h,091h,09Ah,0A3h,0ACh,0B3h,0BBh,0C1h,0C7h,0CCh,0D0h,0D4h,0D6h,0D8h
        DB      0D8h,0D8h,0D6h,0D4h,0D0h,0CCh,0C7h,0C1h,0BBh,0B3h,0ACh,0A3h,09Ah,091h,088h,07Eh
        DB      074h,06Ah,060h,057h,04Eh,045h,03Ch,035h,02Dh,027h,021h,01Ch,018h,014h,012h,010h
        DB      010h,010h,012h,014h,018h,01Ch,021h,027h,02Dh,035h,03Ch,045h,04Eh,057h,060h,06Ah

YTAB:
        DB      098h,098h,097h,095h,093h,090h,08Dh,089h,085h,081h,07Ch,076h,070h,06Bh,064h,05Eh
        DB      058h,052h,04Ch,045h,040h,03Ah,034h,02Fh,02Bh,027h,023h,020h,01Dh,01Bh,019h,018h
        DB      018h,018h,019h,01Bh,01Dh,020h,023h,027h,02Bh,02Fh,034h,03Ah,040h,045h,04Ch,052h
        DB      058h,05Eh,064h,06Bh,070h,076h,07Ch,081h,085h,089h,08Dh,090h,093h,095h,097h,098h

PHASE:  DB      000h
COLPOS: DB      014h
TIMER:  DB      000h
DIR:    DB      000h
