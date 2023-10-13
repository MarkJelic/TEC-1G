;
; TEC-1 Monitor ROM v1A (c) John Hardy 1983 - 2018
; Released under the GNU GENERAL PUBLIC LICENSE 3.0
;
; SEQUENCER at 0x05B0 written by Ken Stone
STARTRAM:       EQU     0x800
DISPLAY:        EQU     0x0ff1          ;display start (data part)
DISPLAY2:       EQU     0x0ff3          ;display address part offset
DISPLAY3:       EQU     0x0ff4          ;display address part offset
DISPLAY4:       EQU     0x0ff5          ;second last display digit
DISPLAY5:       EQU     0x0ff6          ;second last display digit
DISPLAY6:       EQU     0x0ff7          ;last display digit
ADDRESS:        EQU     0x0ff7          ;stores the address pointer
MODE:           EQU     0x0ff9          ;0 = ADDR_MODE, 67 = DATA_MODE
KEYFLAG:        EQU     0x0ffa          ;boolean, if false then it's the
                                        ;first key press after a mode change
INV_SCORE:      EQU     0x0ffa          ;variable 1 used in INVADERS
INV_GUN:        EQU     0x0ffb          ;variable 2 used in INVADERS
PORTKEYB:       EQU     0x00            ;keyboard value
PORTDIGIT:      EQU     0x01            ;bits 0-5 select display digit
PORTSPKR:       EQU     0x01            ;bit 7 selects speaker
PORTSEGS:       EQU     0x02            ;bits 0-8 select display segments
PORTSLOW:       EQU     0x03            ;output port for slow sequencer
PORTFAST:       EQU     0x04            ;output port for fast sequencer
SLOWSEQ:        EQU     0x0800          ;fast and slow sequencer data
FASTSEQ:        EQU     0x0b00          ;see SEQUENCER code
ENDOFSEQ:       EQU     0xFF            ;end of sequence
REPEATTEXT:     EQU     0x1E            ;repeat showing banner
ENDOFTEXT:      EQU     0x1F            ;end of banner
REPEATTUNE:     EQU     0x1E            ;repeat playing tune
ENDOFTUNE:      EQU     0x1F            ;end of tune
NIMMATCHES:     EQU     0x0ffa          ;nim: number of matches
                ORG     0x0000
                JP      STARTMON
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                JP      INVADERS        ;RST  not needed
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                JP      NIM             ;RST  not needed
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                JP      LUNALANDER      ;RST  not needed
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                LD      hl,TUNE1        ;BAD IDEA! not needed
                JP      STARTTUNE
                DB      0xFF
                DB      0xFF
                LD      hl,TUNE2        ;BAD IDEA! not needed
                JP      STARTTUNE
                DB      0xFF
                DB      0xFF
                RST     0x00            ;Maskable Interrupt Mode 1
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
STARTTUNE:      LD      (STARTRAM),hl   ;load address of tune from STARTRAM
                JP      PLAYTUNE
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                                        ;non-maskable interrupt: read key from keyboard into i
                                        ;destroys a    BUG: fix bug to save a
NMINT:          ORG     0x0066
                IN      a,(0x00)        ;input a from keyboard
                AND     0x1f            ;mask lower 5 bits
                LD      i,a             ;move to i register
                RET                     ;BUG: should be RETN
                                        ;b   ranches here after WRITEDISP
WRITEDISP2:     LD      sp,0x0fd0
                CALL    GETKEY          ;(blocking) get key
                CALL    BEEP            ;beep
                LD      a,(MODE)        ;a = addr/data
                CP      0x00            ;z = (MODE == ADDR_MODE)
                JP      nz,WRITEDISP3
                                        ;i   s ADDR_MODE
                LD      a,i             ;a = key
                CP      0x10
                JP      c,ADDRKEY       ;key is numeric
                JP      DATADISP        ;change to DATA_MODE
ADDRKEY:        LD      hl,ADDRESS
                CALL    GETADDRKEY      ;getkey and clear 16 bits if !KEYFLAG
                RLD                     ;rotate left nibble (hl) <- a
                INC     hl              ;point to upper byte
                RLD                     ;rotate left nibble (hl) <- a
                JP      ADDRDISP        ;change to ADDR_MODE,
WRITEDISP3:     LD      a,i             ;is DATA_MODE
                CP      0x10
                JP      c,DATAKEY       ;key is numeric
                XOR     a               ;is function key
                LD      (KEYFLAG),a     ;(KEYFLAG)=false init key after mode change
                LD      a,i             ;a = key value
                CP      0x13            ;(AD) MODE key
                JP      z,ADDRDISP
                CP      0x12            ;(GO) KEY
                JP      z,GOADDR
                CP      0x11            ;(-) KEY
                JP      z,DECADDR
                CP      0x10            ;(+) KEY
                JP      z,INCADDR
DATAKEY:        LD      hl,(ADDRESS)
                CALL    GETDATAKEY      ;getkey and clear 16 bits if !KEYFLAG
                RLD                     ;rotate left nibble (hl) <- a
                JP      DATADISP
GOADDR:         LD      hl,(ADDRESS)
                JP      (hl)            ;jump (ADDRESS)
DECADDR:        LD      hl,(ADDRESS)    ;(ADDRESS)--
                DEC     hl
                LD      (ADDRESS),hl
                JP      DATADISP
INCADDR:        LD      hl,(ADDRESS)    ;(ADDRESS)++
                INC     hl
                LD      (ADDRESS),hl
                JP      DATADISP
ADDRDISP:       LD      a,0x00          ;0
                LD      b,0x04          ;4 digits
                LD      hl,DISPLAY2     ;display+2 offset for address
                JR      WRITEDISP
DATADISP:       LD      a,0x67          ;01100111
                LD      b,0x02          ;two digits
                LD      hl,DISPLAY      ;display+0 offset for data
                                        ;goto WRITEDISP (fall-thru)
                                        ;subroutine: write HEX values for ADDRESS and (ADDRESS)
                                        ;updates mode i.e. data or address
                                        ;show focus for mode with decimal points
                                        ;a = mode data (67) or address (0)
                                        ;b = num decimal points to focus
                                        ;hl = offset into display to focus
WRITEDISP:      LD      (MODE),a
                EXX
                LD      de,(ADDRESS)    ;de = ADDRESS value
                CALL    WRITEADDR
                LD      a,(de)          ;a = (ADDRESS) value
                CALL    WRITEDATA
                EXX
DPLOOP:         SET     4,(hl)          ; set decimal point
                INC     hl
                DJNZ    DPLOOP
                JP      WRITEDISP2
                                        ;subroutine: write HEX value of de to DISPLAY+2
                                        ;destroys a, hl
WRITEADDR:      LD      hl,DISPLAY2
                LD      a,e
                CALL    WRITEHEX
                LD      a,d
                CALL    WRITEHEX
                RET
                                        ;subroutine: write HEX value of a to DISPLAY
                                        ;destroys a, hl
WRITEDATA:      LD      hl,DISPLAY      ;hl = DISPLAY
                CALL    WRITEHEX        ;write a to (hl)
                RET
                                        ;subroutine: write HEX value of a to (hl)
                                        ;destroys a
                                        ;hl = h1 + 2
WRITEHEX:       PUSH    af              ;save a
                CALL    HEX2SEGS        ;convert lower HEX nibble to segments
                LD      (hl),a          ;write a to (hl)
                INC     hl              ;hl++
                POP     af              ;restore a
                RRCA                    ;shift upper HEX nibble to lower
                RRCA
                RRCA
                RRCA
                CALL    HEX2SEGS        ;convert lower HEX nibble to segments
                LD      (hl),a          ;write to (hl)
                INC     hl              ;hl++
                RET                     ;return
                                        ;subroutine: convert number in a to segments
                                        ;a    = HEXSEGTBL[a]
HEX2SEGS:       PUSH    hl              ;save hl
                LD      hl,HEXSEGTBL    ;hl = HEXSEGTBL
                AND     0x0f            ; a && 0xF
                ADD     a,l             ; hl = hl + a
                LD      l,a
                LD      a,(hl)          ;HEXSEGTBL[a]
                POP     hl              ;restore hl
                RET                     ;return
                                        ;subroutine: scan display while watching for keypress
                                        ;i = key
                                        ;destroys a
GETKEY:         LD      a,0xff
                LD      i,a             ;i == FF ie. NOKEY
                CALL    SCANDISP        ;scan the display
                LD      a,i
                CP      0xff
                RET     nz              ;if (i != NOKEY) return i
                JP      GETKEY
                                        ;subroutine: display each digit in turn
                                        ;destroys b, c, a
SCANDISP:       PUSH    ix              ;save ix, ix == DISPLAY???
                LD      bc,0x0601       ;b = numdigits, c = 1
L145:           LD      a,(ix+0)        ;a = (ix)
                OUT     (PORTSEGS),a    ;out segments
                INC     ix              ;ix++
                LD      a,c             ;a = c
                OUT     (PORTDIGIT),a   ;out digit
                SLA     a               ;shift left to next digit
                LD      c,a             ;c = a
                LD      a,0x0a          ;a = 0A (10)
SDDELAY:        DEC     a               ;a--
                JP      nz,SDDELAY      ;loop delay???
                OUT     (PORTDIGIT),a   ;a = 0, turn off digits?
                DJNZ    L145            ;loop until b == 0
                POP     ix              ;restore ix
                RET                     ;return
HEXSEGTBL:      DB      0xEB            ;0 7 SEGMENTS FOR NUMBERS
                DB      0x28            ;1
                DB      0xCD            ;2
                DB      0xAD            ;3
                DB      0x2E            ;4
                DB      0xA7            ;5
                DB      0xE7            ;6
                DB      0x29            ;7
                DB      0xEF            ;8
                DB      0x2F            ;9
                DB      0x6F            ;A
                DB      0xE6            ;B
                DB      0xC3            ;C
                DB      0xEC            ;D
                DB      0xC7            ;E
                DB      0x47            ;F
                                        ;subroutine: getkey, check KEYFLAG
                                        ;if !(KEYFLAG) then blanks (hl) and (hl+1)
                                        ;returns key in a
                                        ;destroys: b
GETADDRKEY:     CALL    GETDATAKEY      ;get key
                RET     nz              ; if ((KEYFLAG) == false) {
                INC     hl              ;
                LD      a,0x00          ;
                LD      (hl),a          ;   (hl+1) = 0
                DEC     hl
                                        ; }
                LD      a,i             ;
                RET                     ;return (a=key)
                                        ;subroutine: getkey, check KEYFLAG
                                        ;if !(KEYFLAG) then blanks (hl)
                                        ;returns key in a
                                        ;destroys: b
GETDATAKEY:     LD      a,i
                LD      b,a             ;b = key
                LD      a,(KEYFLAG)
                CP      0x00
                LD      a,b
                RET     nz              ; if ((KEYFLAG) == false){
                XOR     a               ;
                LD      (hl),a          ;   (hl) = 0
                DEC     a
                LD      (KEYFLAG),a     ;   (KEYFLAG) = true
                                        ; }
                LD      a,b             ;
                RET                     ;return a=key
                NOP
BEEP:           LD      c,0x0a          ;c = 0A (10)
                LD      hl,0x0050       ;hl = 50 (80)
                                        ;fall thru to PLAYTONE
                                        ;subroutine: play tone, freq c, duration h1
                                        ;destroys: hl, de, a, b
PLAYTONE:       ADD     hl,hl           ;hl = hl + h1
                LD      de,0x0001       ;de = 1
                XOR     a               ;a = 0
                OUT     (PORTSEGS),a    ;clear segments
                DEC     a               ;a = FF
MTLOOP:         OUT     (PORTDIGIT),a   ;all digitis on?
                LD      b,c             ;b = c
MTDELAY:        DJNZ    MTDELAY         ;delay?
                XOR     0x80            ;invert bit 7 of a (clear carry?)
                SBC     hl,de           ;hl = hl - 1
                JR      nz,MTLOOP
                RET
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
PLAYTUNE:       ORG     0x01B0
                LD      de,(STARTRAM)   ;de = address of tune
PTLOOP1:        LD      a,(de)          ;a = (de); a = note
                AND     0x1f            ;mask lower 5 bits
                CP      0x1f            ;if (a == ENDOFTUNE)
                RET     z               ;    return
                NOP
                NOP
                CP      0x1e            ;if (a == REPEATTUNE)
                JP      z,PLAYTUNE      ;  goto PLAYTUNE
                CP      0x00            ;if (a == SILENCE)
                JP      z,PTSILENCE     ;  goto PTSILENCE
                LD      b,a             ;b = note
                INC     de              ;de++
                PUSH    de              ;save de
                LD      hl,FREQWL       ;hl = frequency wave length
                CALL    TBLOOKUP        ;a = lookup note
                PUSH    af              ;save a
                LD      a,b             ;a = note
                LD      hl,FREQNC       ;h1 = frequency num cycles
                CALL    TBLOOKUP        ;a = lookup note
                LD      l,a
                LD      h,0x00          ;hl = num cycles
                POP     af              ;restore a
                LD      c,a             ;c = wave length
                CALL    PLAYTONE        ;c and hl
                POP     de              ;save de
                JP      PTLOOP1         ;play next note
                                        ;subroutine: lookup offset in table
                                        ;a = offset
                                        ;hl = table
                                        ;result in a
                                        ;destroys e, d
TBLOOKUP:       LD      e,a             ;e = offset
                LD      d,0x00          ;d = 0
                ADD     hl,de           ;hl = hl + de
                LD      a,(hl)          ;a = table + offset
                RET                     ;return
PTSILENCE:      PUSH    de              ;save de
                LD      de,0x1000       ;delay count = 1000
PTLOOP2:        DEC     de              ;de--
                LD      a,d
                OR      e               ;if (de != 0)
                JP      nz,PTLOOP2      ;  goto PTLOOP2
                POP     de              ;restore de
                INC     de              ;de++
                JP      PTLOOP1         ;play next note
FREQWL:         ADC     a,h
                ADD     a,e
                LD      a,h
                LD      (hl),l
                LD      (hl),b
                LD      h,a
                LD      h,d
                LD      e,h
                LD      d,a
                LD      d,d
                LD      c,(hl)
                LD      c,b
                LD      b,l
                LD      b,c
                INC     a
                ADD     hl,sp
                LD      (hl),0x32
                CPL
                INC     l
                LD      hl,(0x2527)
                INC     hl
FREQNC:         ADD     hl,de
                LD      a,(de)
                INC     e
                DEC     e
                LD      e,0x20
                INC     hl
                DEC     h
                DAA
                ADD     hl,hl
                INC     l
                LD      l,0x31
                INC     sp
                SCF
                LD      a,(0x413d)
                LD      b,l
                LD      c,c
                LD      c,l
                LD      d,d
                LD      d,a
                LD      e,h
                DJNZ    0x0229
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
TUNE1:          ORG     0x0230
                DB      0x06,0x06
                DB      0x0A
                DB      0x0D
                DB      0x06,0x0D
                DB      0x0A
                DB      0x0D
                DB      0x12
                DB      0x16,0x14
                DB      0x12
                DB      0x0F
                DB      0x11,0x12,0x0F
                DB      0x0D
                DB      0x0D
                DB      0x0D
                DB      0x0A
                DB      0x12
                DB      0x0F
                DB      0x0D
                DB      0x0A
                DB      0x08
                DB      0x06,0x08
                DB      0x0A
                DB      0x0F
                DB      0x0A
                DB      0x0D
                DB      0x0F
                DB      0x06,0x06
                DB      0x0A
                DB      0x0D
                DB      0x06,0x0D
                DB      0x0A
                DB      0x0D
                DB      0x12
                DB      0x16,0x14
                DB      0x12
                DB      0x0F
                DB      0x11,0x12,0x0F
                DB      0x0D
                DB      0x0D
                DB      0x0D
                DB      0x0A
                DB      0x12
                DB      0x0F
                DB      0x0D
                DB      0x0A
                DB      0x08
                DB      0x06,0x08
                DB      0x0A
                DB      0x06,0x12
                DB      0x00
                DB      0x1E
SHOWTEXT:       ORG     0x0270
                LD      iy,(STARTRAM)   ;iy = text_ptr
                LD      ix,DISPLAY      ;ix = display_ptr
                                        ;clear display
                LD      b,0x06          ;b = num of display digits
                LD      hl,DISPLAY      ;hl = display_ptr
STXT1:          LD      (hl),0x00       ;(hl) = SPACE
                INC     hl              ;hl++
                DJNZ    STXT1           ;loop until b == 0
STXTLOOP:       LD      b,0x06          ;b = num of display digits
                LD      de,DISPLAY6     ;de = last display digit
                LD      hl,DISPLAY5       ;hl = second last display digit
                                        ;shift display one digit to the left
STXT2:          LD      a,(hl)          ;a = (hl)
                LD      (de),a          ;(de) = a
                DEC     hl              ;hl--
                DEC     de              ;de--
                DJNZ    STXT2
                LD      a,(iy+0)        ;a = (iy) ;text char
                INC     iy              ;iy++
                AND     0x1f            ;mask lower 5 bits
                CP      0x1f            ;if a == ENDOFTEXT
                RET     z               ;  return
                CP      0x1e            ;if a == REPEATTEXT
                JR      z,SHOWTEXT        ;  goto SHOWTEXT
                LD      hl,CHAR7SEGTBL  ;hl = char_7segment_table
                CALL    TBLOOKUP        ;convert char to 7segments
                LD      (DISPLAY),a     ;store in first digit
                                        ;scan display 128 times
                LD      a,0x80          ;a = 80
STXT3:          PUSH    af              ;save a
                CALL    SCANDISP        ;scan display
                POP     af              ;restore a
                DEC     a               ;if (a-- != 0)
                JR      nz,STXT3        ;  goto STXT3
                JR      STXTLOOP        ;repeat shifting and scanning
CHAR7SEGTBL:    DB      0x00            ;00 SPACE
                DB      0x6F            ;01 A
                DB      0xE6            ;02 B
                DB      0xC3            ;03 C
                DB      0xEC            ;04 D
                DB      0xC7            ;05 E
                DB      0x47            ;06 F
                DB      0xE3            ;07 G
                DB      0x6E            ;08 H
                DB      0x28            ;09 I
                DB      0xE8            ;0A J
                DB      0xCE            ;0B K
                DB      0xC2            ;0C L
                DB      0x6B            ;0D N
                DB      0xEB            ;0E O
                DB      0x4F            ;0F P
                DB      0x2F            ;10 Q
                DB      0x43            ;11 R
                DB      0xA7            ;12 S
                DB      0x46            ;13 T
                DB      0xEA            ;14 U
                DB      0xE0            ;15 V
                DB      0xAE            ;16 Y
                DB      0xCD            ;17 Z
                DB      0x04            ;18 -
                DB      0x10            ;19 .
                DB      0x18            ;1A !
                DB      0x00
                DB      0x00
                DB      0x00
WELCOME:        ORG     0x02D1
                DB      0x08            ;h
                DB      0x05            ;e
                DB      0x0c            ;l
                DB      0x0c            ;l
                DB      0x0e            ;o
                DB      0x00            ;
                DB      0x13            ;t
                DB      0x08            ;h
                DB      0x05            ;e
                DB      0x11            ;r
                DB      0x05            ;e
                DB      0x00            ;
                DB      0x13            ;t
                DB      0x08            ;h
                DB      0x09            ;i
                DB      0x12            ;s
                DB      0x00            ;
                DB      0x09            ;i
                DB      0x12            ;s
                DB      0x00            ;
                DB      0x13            ;t
                DB      0x08            ;h
                DB      0x05            ;e
                DB      0x00            ;
                DB      0x13            ;t
                DB      0x05            ;e
                DB      0x03            ;c
                DB      0x18            ;-
                DB      0x09            ;1
                DB      0x19            ;.
                DB      0x19            ;.
                DB      0x19            ;.
                DB      0x19            ;.
                DB      0x04            ;d
                DB      0x05            ;e
                DB      0x12            ;s
                DB      0x09            ;i
                DB      0x07            ;g
                DB      0x0d            ;n
                DB      0x05            ;e
                DB      0x04            ;d
                DB      0x00            ;
                DB      0x02            ;b
                DB      0x16            ;y
                DB      0x00            ;
                DB      0x0a            ;j
                DB      0x0e            ;o
                DB      0x08            ;h
                DB      0x0d            ;n
                DB      0x00            ;
                DB      0x08            ;h
                DB      0x01            ;a
                DB      0x11            ;r
                DB      0x04            ;d
                DB      0x16            ;y
                DB      0x00            ;
                DB      0x06            ;f
                DB      0x0e            ;o
                DB      0x11            ;r
                DB      0x00            ;
                DB      0x13            ;t
                DB      0x05            ;e
                DB      0x1a            ;!
                DB      0x00            ;
                DB      0x00            ;
                DB      0x00            ;
                DB      0x00            ;
                DB      0x00            ;
                DB      0x00            ;
                DB      0x1e            ; REPEATTEXT
                DB      0xff
                DB      0xff
                DB      0xff
                DB      0xff
                DB      0xff
                DB      0xff
                DB      0xff
                DB      0xff
                DB      0xff
; INVADERS game
; invaders advance towards you from the right
; you shoot invaders by pressing the 0 key
; you can only destroy the invaders the match the number on your gun
; you can only rotate the number on your gun by pressing the + key
INVADERS:       ORG     0x0320
                LD      ix,DISPLAY      ;ix = DISPLAY
                XOR     a               ;a = 0
                LD      (INV_SCORE),a   ;(INV_SCORE) = 0
                LD      (INV_GUN),a     ;(INV_GUN) = 0
                                        ;clear display
                LD      b,0x06          ;b = num_digits
                LD      hl,DISPLAY      ;hl = DISPLAY
INV10:          LD      (hl),0x00       ;clear digit
                INC     hl              ;hl++
                DJNZ    INV10           ;if (--b != 0) goto INV10
INV_LOOP:       LD      a,(DISPLAY4)    ;a = second last digit
                CP      0x00            ;if (a != 0)
                JR      nz,INV40        ;  goto INV40
                                        ;shift bottom 4 digits up
                LD      de,DISPLAY4     ;second last digit
                LD      hl,DISPLAY3     ;third last digit
                LD      b,0x04          ;num digits to shift
INV20:          LD      a,(hl)          ;get rightmost
                LD      (de),a          ;move one left
                DEC     hl              ;hl--
                DEC     de              ;de--
                DJNZ    INV20           ;if (--b != 0) goto INV20
                LD      a,r             ;load a = random from refresh
                CALL    TRI2SEG           ;convert to number?
                LD      (DISPLAY),a     ;rightmost digit
                LD      a,0x00          ;a = 0
                NOP
INV30:          PUSH    af              ;save a
                LD      a,0xff          ;a = FF
                LD      i,a             ;i = a
                LD      a,(INV_GUN)     ;a = INV_GUN
                CALL    TRI2SEG           ;convert to number?
                LD      (DISPLAY5),a    ;leftmost digit = INV_GUN
                CALL    SCANDISP        ;scan display
                LD      a,i             ;a = i
                CP      0xff            ;if key pressed
                CALL    nz,INVKEYPRESS  ;  goto INVKEYPRESS
                POP     af              ;restore a
                DEC     a               ;if (--a > 0)
                JR      nz,INV30        ;  goto INV30
                JR      INV_LOOP        ;goto INV_LOOP
INV40:          CALL    BEEP            ;beep
                                        ;clear display
                LD      b,0x06          ;b = num_digits
                LD      hl,DISPLAY      ;hl = DISPLAY
INV50:          LD      (hl),0x00       ;(hl) = 0
                INC     hl              ;hl++
                DJNZ    INV50           ;if (--b != 0) goto INV50
                LD      a,(INV_SCORE)   ;a = (INV_SCORE)
                LD      hl,DISPLAY2     ;hl = DISPLAY
                CALL    WRITEHEX        ;write hex(a) to (hl)
                CALL    GETKEY          ;wait for key
                JR      INVADERS        ;restart INVADERS
INVKEYPRESS:    CP      0x10
                JR      nz,INV60        ; if (key == "+")
                LD      a,(INV_GUN)     ;   (INV_GUN)++
                INC     a
                LD      (INV_GUN),a
                RET
                                        ;loop over invaders comparing with gun number
INV60:          LD      a,(DISPLAY5)    ;a = last digit (gun)
                LD      c,a             ;c = a
                LD      hl,DISPLAY4     ;hl = second last digit
                LD      b,0x05          ;b = 5 digits
INV65:          LD      a,(hl)          ;a = (hl)
                CP      c
                JR      nz,INV70        ; if (invader_num == gun_num) {
                LD      (hl),0x00       ;    clear invader
                LD      a,(INV_SCORE)   ;
                INC     a               ;    increase score
                DAA                     ;
                LD      (INV_SCORE),a   ; }
INV70:          DEC     hl              ;hl--
                DJNZ    INV65           ;if (--b != 0) goto INV65
                RET
                                        ;subroutine TRI2SEG
                                        ;convert lower 3 bits to segments
TRI2SEG:        AND     0x07            ;mask lower 3 bits (0-7) of a
                CALL    HEX2SEGS        ;a = segments(a)
                RET
                ; NIM strings used in NIM game below
NIMLOSE:        DB      0x16            ;y
                DB      0x0E            ;o
                DB      0x14            ;u
                DB      0x00
                DB      0x0C            ;l
                DB      0x0E            ;o
                DB      0x12            ;s
                DB      0x05            ;e
                DB      0x00
                DB      0x12            ;s
                DB      0x13            ;t
                DB      0x14            ;u
                DB      0x0F            ;p
                DB      0x09            ;i
                DB      0x04            ;d
                DB      0x1A            ;!
                DB      0x1F            ;ENDOFTEXT
NIMWIN:         DB      0x0E            ;o
                DB      0x08            ;h
                DB      0x00
                DB      0x0D            ;n
                DB      0x0E            ;o
                DB      0x19            ;.
                DB      0x19            ;.
                DB      0x19            ;.
                DB      0x09            ;i
                DB      0x00
                DB      0x0C            ;l
                DB      0x0E            ;o
                DB      0x12            ;s
                DB      0x13            ;t
                DB      0x1A            ;!
                DB      0x1F            ;ENDOFTEXT
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                ; NIM is a game of 23 matches played against the computer
                ; Each player takes it in turns to take 1, 2 or 3 matches.
                ; The player that is left to pick up the last match loses.
NIM:            ORG     0x03E0
                LD      ix,DISPLAY      ;ix = display[0]
                LD      a,0x23          ;23 matches in BCD
                LD      (NIMMATCHES),a  ;save in total matches
                                        ;clear display
                LD      hl,DISPLAY      ;hl = DISPLAY
                LD      b,0x06          ;num digits
NIMLOOP1:       LD      (hl),0x00       ;store 0 at DISPLAY
                INC     hl              ;point to next digit
                DJNZ    NIMLOOP1        ;b-- if b > 0 jump to NIMLOOP1
                LD      e,0x00          ; e = 0
NIMLOOP2:       CALL    NIMDISPLAY      ;render nim state
                CALL    GETKEY          ;get key (blocking)
                LD      a,i             ;a = key
                CP      0x04            ;if (key >= 4)
                JR      nc,NIMLOOP2     ;  goto NIMLOOP2
                CP      0x00            ;if (key == 0)
                JR      z,0x03f5        ;  goto NIMLOOP2
                LD      e,a             ;e = choice
                LD      a,(NIMMATCHES)  ;a = num_matches
                CP      e               ;if (num_matches <= e)
                JR      z,NIMLOSER      ;  goto NIMLOSER
                JR      c,NIMLOSER
                SUB     e               ;a = a - choice
                DAA                     ;BCD adjust
                LD      (NIMMATCHES),a  ;update
                CALL    NIMDISPLAY      ;render nim state
                LD      hl,DISPLAY5     ;
                LD      (hl),0xae       ;letter 'Y' for "you chose"
                LD      d,0x00
NIMLOOP3:       CALL    SCANDISP        ;scan LEDS 255 times
                DEC     d
                JR      nz,NIMLOOP3
                LD      a,(NIMMATCHES)  ;a = num_matches
                CP      0x01            ;if (a == 1)
                JR      z,0x0456        ;   goto NIMWINNER
                DEC     a               ;a = num_matches - 1
                DAA                     ;BCD adjust
NIMLOOP4:       SUB     0x04            ;a -= 4
                DAA                     ;BCD adjust
                JR      nc,NIMLOOP4
                ADD     a,0x04
                DAA                     ;a = (num_matches - 1) % 4
                CP      0x00            ;if (a == 0) //no move available
                JR      z,NIMRAND       ;  goto random_move
NIMRESUME:      LD      e,a             ;e = a -- computer's choice
                LD      a,(NIMMATCHES)  ;a = num_matches
                SUB     e               ;a = a - choice
                DAA                     ;BCD adjust
                LD      (NIMMATCHES),a  ;update
                LD      hl,DISPLAY5
                LD      (hl),0x28       ;letter 'I' for "I chose"
                JR      NIMLOOP2
NIMRAND:        LD      a,r             ;get "random" num from refresh register
                AND     0x03            ;truncate range to 0-3
                JR      z,NIMADJUST     ;if choice == 0 choice++
                JR      NIMRESUME       ;use choice
NIMLOSER:       LD      de,NIMLOSE      ;show loser text
                JP      NIMTEXT
NIMWINNER:      LD      de,NIMWIN       ;show winner text
NIMTEXT:        LD      (STARTRAM),de   ;show text
                CALL    SHOWTEXT
                CALL    GETKEY          ;wait for key
                JP      NIM
                                        ;subroutine: display nim state
                                        ;e = choice
                                        ;destroys a, hl
NIMDISPLAY:     LD      hl,DISPLAY
                LD      a,(NIMMATCHES)  ;num matches
                CALL    WRITEHEX        ;write BCD values
                INC     hl              ;blank digit
                LD      a,e
                CALL    HEX2SEGS        ;a = 7segs(e)
                LD      (hl),a          ;(hl) = 7segs
                RET                     ;return
NIMADJUST:      INC     a               ;turn 0 into 1
                JP      NIMRESUME       ;resume
                DB      0xFF
LUNAWIN:        DB      0x14            ;D
                DB      0x12            ;C
                DB      0x14            ;D
                DB      0x17            ;F
                DB      0x17            ;F
                DB      0x12            ;C
                DB      0x14            ;D
                DB      0x10            ;A#
                DB      0x1F            ;END
LUNALOSE:       DB      0x01            ;G
                DB      0x11            ;B
                DB      0x01            ;G
                DB      0x11            ;B
                DB      0x01            ;G
                DB      0x11            ;B
                DB      0x1F            ;END
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                                        ;LUNALANDER
                                        ;you must land your luna module on the moon
                                        ;as gently as possible while gravity is pulling you down.
                                        ;You can use the + key to fire your engine briefly
                                        ;this will slow down your descent but it also uses fuel
                                        ;if you run out of fuel you will crash
LUNALANDER:     ORG     0x490
                LD      ix,DISPLAY      ;ix = DISPLAY
                LD      iy,STARTRAM     ;iy = STARTRAM
                LD      a,0x50
                LD      (iy+0),a        ;(ALTITUDE) = 50
                LD      a,0x20
                LD      (iy+1),a        ;(FUEL) = 20
                XOR     a
                LD      (iy+2),a        ;(VELOCITY) = 0
                                        ;clear display
                LD      hl,DISPLAY      ;hl = DISPLAY
                LD      b,0x06          ;b = num_digits
LUNA10:         LD      (hl),0x00       ;(hl) = 0
                INC     hl              ;hl++
                DJNZ    0x04ab          ;if (--b != 0) goto LUNA10
LUNA15:         LD      d,0x80          ;d = 80
LUNA20:         LD      a,(iy+1)        ;a = (FUEL)
                LD      hl,DISPLAY      ;hl = DISPLAY
                CALL    WRITEHEX        ;write (FUEL) BCD number
                INC     hl
                INC     hl              ;hl += 2
                LD      a,(iy+0)        ;a = (ALTITUDE)
                CALL    WRITEHEX        ;write (ALTITUDE) BCD number
                LD      a,0xff          ;a = FF
                LD      i,a
                CALL    SCANDISP
                LD      a,i
                CP      0xff            ;if (keypressed)
                CALL    nz,LUNAKPRESS   ;    call LUNAKPRESS
                DEC     d               ;d--
                JP      nz,LUNA20       ;loop 128 times
                LD      a,(iy+2)        ;a = (VELOCITY)
                SUB     0x01            ;a--
                DAA                     ;BCD adjust
                LD      (iy+2),a        ;(VELOCITY) = a
                LD      b,a             ;b = a
                LD      a,(iy+0)        ;a = (ALTITUDE)
                ADD     a,b             ;a += b
                DAA                     ;BCD adjust
                CP      0x00            ;if (a == 0)
                JP      z,LWIN          ;  goto LWIN
                CP      0x60            ;if (a < 60)
                JR      nc,LLOSE         ;  goto LLOSE
                LD      (iy+0),a        ;(ALTITUDE) = a
                JP      LUNA15          ;goto LUNA15
                                        ;subroutine LUNAKPRESS
LUNAKPRESS:     LD      a,(iy+1)        ;a = (FUEL)
                CP      0x00            ;if (a == 0)
                RET     z               ;  return
                DEC     a               ;reduce fuel
                DAA                     ;BCD adjust
                LD      (iy+1),a        ;(FUEL) = a
                LD      a,(iy+2)        ;a = (VELOCITY)
                ADD     a,0x02          ;a += 2
                DAA                     ;BCD adjust
                LD      (iy+2),a        ;(VELOCITY) = a
                RET                     ;return
LLOSE:          LD      de,LUNALOSE     ;de = winning tune
                LD      ix,0x0000       ;???
                JR      LUNAPLAYTUNE    ;goto LUNAPLAYTUNE
LWIN:           LD      de,LUNAWIN      ;de = losing tune
LUNAPLAYTUNE:   LD      (STARTRAM),de   ;store starting address in RAM
                CALL    PLAYTUNE        ;play tune
                CALL    GETKEY          ;wait for key
                JP      LUNALANDER      ;repeat
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
TUNE2:          DB      0x0B            ; Bealach An Doirín
                DB      0x0A
                DB      0x08
                DB      0x0A
                DB      0x0A
                DB      0x0A
                DB      0x06
                DB      0x06
                DB      0x06
                DB      0x0B
                DB      0x0A
                DB      0x08
                DB      0x0A
                DB      0x0A
                DB      0x0A
                DB      0x0A
                DB      0x0A
                DB      0x0A
                DB      0x0B
                DB      0x0A
                DB      0x08
                DB      0x0A
                DB      0x0A
                DB      0x0A
                DB      0x06,0x06
                DB      0x06,0x0A
                DB      0x08
                DB      0x0A
                DB      0x0D
                DB      0x0D
                DB      0x0D
                DB      0x0D
                DB      0x0D
                DB      0x00
                DB      0x0D
                DB      0x05
                DB      0x08
                DB      0x0B
                DB      0x0B
                DB      0x0B
                DB      0x06,0x06
                DB      0x06,0x0B
                DB      0x0A
                DB      0x08
                DB      0x0A
                DB      0x0A
                DB      0x0A
                DB      0x06,0x06
                DB      0x06,0x0B
                DB      0x0A
                DB      0x06,0x08
                DB      0x08
                DB      0x08
                DB      0x08
                DB      0x08
                DB      0x0A
                DB      0x0B
                DB      0x0A
                DB      0x08
                DB      0x06,0x06
                DB      0x06,0x06
                DB      0x06,0x06
                DB      0x00
                DB      0x00
                DB      0x00
                DB      0x1E,0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
STARTMON2:      LD      hl,STARTRAM
                LD      sp,0x0fd0       ;set stack to end of ram - 32
                LD      ix,DISPLAY      ;ix = DISPLAY
                LD      (ADDRESS),hl    ;address_ptr = STARTRAM
                XOR     a
                LD      (MODE),a        ;MODE = ADDR
                LD      (KEYFLAG),a     ;KEYFLAG = false
                LD      c,0x0a          ;c = note E
                LD      hl,0x0050       ;hl = duration
                CALL    PLAYTONE        ;beep
                LD      c,0x20
                LD      hl,0x0030
                CALL    PLAYTONE        ;beep
                JP      DATADISP
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                                        ;sequencer
SEQUENCER:      ORG     0x5B0
                LD      hl,SLOWSEQ      ;hl = 800
                LD      de,FASTSEQ      ;de = B00
LOOPSEQ:        LD      a,(hl)          ;a = (hl)
                CP      ENDOFSEQ        ;if a != ENDOFSEQ
                JP      nz,SEQ2         ;  goto SEQ2
                LD      hl,SLOWSEQ      ;hl = 800
                JP      LOOPSEQ         ;goto LOOPSEQ
SEQ2:           OUT     (PORTSLOW),a    ;output to PORTSLOW
SEQ3:           LD      a,(de)          ;a = (de)
                CP      ENDOFSEQ        ;if a != ENDOFSEQ
                JP      nz,SEQ4         ;  goto SEQ4
                LD      de,FASTSEQ      ;de = FASTSEQ
                JP      SEQ3            ;goto SEQ3
SEQ4:           OUT     (PORTFAST),a    ;output a to PORTFAST
                CALL    SEQDELAY        ;delay
                INC     de              ;de++
                LD      a,(de)          ;a = (de)
                OUT     (PORTFAST),a    ;output a to PORTFAST
                CALL    SEQDELAY        ;delay
                INC     de              ;de++
                INC     hl              ;hl++
                JP      LOOPSEQ         ;loop SEQUENCE
                                        ;subroutine: delay by SEQDELAY
                                        ;destroys b, c, a
SEQDELAY:       LD      bc,0x03ff       ;bc = SEQDELAY
SEQDEL1:        DEC     bc              ;dec bc
                LD      a,b             ;a = c
                OR      c               ;if (a | c == 0)
                JP      nz,SEQDEL1      ;  loop SEQDEL1
                RET                     ;return
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
STARTMON:       ORG     0x05F0
                LD      (0x0fd8),sp     ;save sp here, why?
                LD      sp,0x0ff0       ;init stack pointer
                                        ;save all registers, why?
                PUSH    af              ;save af
                PUSH    bc              ;save bc
                PUSH    de              ;save de
                PUSH    hl              ;save hl
                PUSH    ix              ;save ix
                PUSH    iy              ;save iy
                EX      af,af'
                EXX
                PUSH    af              ;save af'
                PUSH    bc              ;save bc'
                PUSH    de              ;save de'
                PUSH    hl              ;save hl'
                LD      a,i
                PUSH    af              ;save i
                JP      STARTMON2
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF
                DB      0xFF