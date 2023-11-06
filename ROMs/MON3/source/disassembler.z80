; jims disassembler source code
; -----------------------------

; note: this file was updated so i can place it in any memory location.
; for full annotation please look at the pdf "disassembler_listing.pdf"
;
; edits by craig hart: removed junk code
; fixed two remaining fixed memory references; code can now run anywhere in address apce
; update to add in (xx),a and out (xx),a brackets
; update to add "," in call/jp/jr <flag> opcodes
; optimze by removing code such as jp => jp => dest.
;
; edit by brian chiha: formatted code
; remove extra space from call/jp/jr <flag> opcodes
; fixed missing opcode LD SP,IX and LD SP,IY
; note: LD (XY+d),n isn't working yet....

; local variables
DISRAM:     .equ 0900H
DISLINE1:   .equ DISRAM ;DIS STRING START
DISLINE2:   .equ DISRAM + 19 ;DIS SECOND LINE
DISPTR:	    .equ DISRAM + 38 ;DIS STRING END
DISFLAG:    .equ DISRAM + 40 ;DIS FLAG FOR HL,IX,IY
DISFROM:    .equ DISRAM + 41 ;DIS START ADDRESS

disStart:
        ld hl, disline1
        xor a
        ld (disflag), a
        ld (disptr), hl
        ld hl, (disfrom)
        push hl
        call l0x318a    ; write address to disline1
        ld b, 22H
        call l0x31b9    ;fill rest with spaces

        ld hl, disline1 ; patch to fix absoute memory addressing
        ld bc, 5
        add hl, bc

        ld (disptr), hl
        pop hl
        ld a, (hl)
        push hl
        ld d, 01H
        call l0x351d
        pop hl
        jr nc, l0x302e
        call l0x3031
        ld c, (hl)
        ld a, (hl)
        call nc, l0x340e
l0x302e:                        ; why jp to this code; just do it here?
        ld hl, (disfrom)
        inc hl
        ld (disfrom), hl
        ret
l0x3031:
        cp 40H
        jr c, l0x304d
        cp 0c0H
        jr c, l0x304f
        cp 0cbH
        jp z, l0x31de
        ld c, 00H
        cp 0ddH
        jr z, l0x3049
        cp 0fdH
        jr nz, l0x304d
        inc c
l0x3049:
        inc c
        jp l0x30d7
l0x304d:
        or a
        ret
l0x304f:
        push af
        call l0x3055
        jr l0x305a
l0x3055:
        ld b, 01H
        jp l0x31ff
l0x305a:
        pop af
l0x305b:
        cp 80H
        jr nc, l0x3073
        push af
        call l0x3205
        pop af
        call l0x31ac
        push af
        call l0x3106
        call l0x3164
        pop af
        ld c, a
        jp l0x3107
l0x3073:
        and 3fH
        call l0x31ac
        push af
        ld a, 86H
        add a, c
        add a, c
        add a, c
        call l0x3153
        call l0x3086
        jr l0x3092
l0x3086:
        call l0x317b
        ret nz
        ld c, 07H
        call l0x310b
        jp l0x3164
l0x3092:
        pop af
        ld c, a
        jr l0x3106
l0x3096:
        cp 40H
        jr nc, l0x30b0
        call l0x31ac
        push af
        ld a, c
        cp 07H
        jr nz, l0x30a4
        dec c
l0x30a4:
        ld a, 9EH
        add a, c
        add a, c
        add a, c
        call l0x3153
        pop af
        ld c, a
        jr l0x3106
l0x30b0:
        sub 40H
        push af
        ld b, 0B3H
        cp 40H
        jr c, l0x30c1
        ld b, 0B6H
        cp 80H
        jr c, l0x30c1
        ld b, 0B9H
l0x30c1:
        ld a, b
        call l0x3153
        pop af
        and 3FH
        call l0x31ac
        push af
        ld a, c
        call l0x319a
        call l0x3164
        pop af
        ld c, a
        jr l0x3106
l0x30d7:
        ld hl, (disfrom)
        inc hl
        ld a, (hl)
        cp 0CBH
        jr z, l0x30ea
        cp 0BFH
        dec hl
        ret nc
        cp 40H
        jr nc, l0x30ed
        and a
        ret
l0x30ea:
        set 7, c
        inc hl
l0x30ed:
        inc hl
        ld a, (hl)
        push af
        ld b, 04H
        ld a, c
        ld (disflag), a
        bit 7, c
        jr nz, l0x30fb
        dec b
l0x30fb:
        call l0x31ff
        pop af
        bit 7, c
        jr nz, l0x3096
        jp l0x305b
l0x3106:
        ld a, c
l0x3107:
        cp 06H
        jr z, l0x3112
l0x310b:
        ld a, 01H
l0x310d:
        ld hl, tableREG
        jr l0x3145
l0x3112:
        ld a, (disflag)
        or a
        jr nz, l0x311e
        ld c, 08H
        ld a, 04H
        jr l0x310d
l0x311e:
        push af
        rra
        ld c, 0CH
        jr c, l0x3126
        ld c, 13H
l0x3126:
        ld a, 07H
        call l0x310d
        pop af
        rla
        ld de, (disfrom)
        jr nc, l0x3134
        dec de
l0x3134:
        ld a, (disptr)
        sub 03H
        ld (disptr), a
        ld a, (de)
        call l0x3191
        inc hl
        ld (disptr), hl
        ret
l0x3145:
        ld de, (disptr)
        add hl, bc
        ld c, a
        ldir
        ld (disptr), de
        scf
        ret
l0x3153:
        ld hl, tableOPS ; patch to fix absolute memory addressing
        sub 82H
        ld e, a
        ld d, 0
        add hl, de
        ex de, hl
        jr l0x3169
l0x315d:
        ld hl, disline2
        ld (disptr), hl
        ret
l0x3164:
        ld bc, 0006H
        jr l0x310b
l0x3169:
        ld hl, (disptr)
        ld a, (de)
        ld (hl), a
        res 7, (hl)
        inc hl
        ld (disptr), hl
        inc de
        or a
        jp m, l0x31b7
        jr l0x3169
l0x317b:
        ld a, c
        cp 04H
        jr c, l0x3182
        or a
        ret
l0x3182:
        cp 02H
        jr nz, l0x3188
        dec a
        ret
l0x3188:
        xor a
        ret
l0x318a:
        push hl
        ld a, h
        call l0x3191
        pop hl
        ld a, l
l0x3191:
        push af
        rra
        rra
        rra
        rra
        call l0x319a
        pop af
l0x319a:
        and 0FH
        add a, 90H
        daa
        adc a, 40H
        daa
        ld hl, (disptr)
        ld (hl), a
        inc hl
        ld (disptr), hl
        scf
        ret
l0x31ac:
        push af
        and 38H
        rra
        rra
        rra
        ld c, a
        pop af
        and 07H
        ret
l0x31b7:
        ld b, 01H
l0x31b9:
        ld a, 20H
        ld hl, (disptr)
l0x31be:
        ld (hl), a
        inc hl
        djnz l0x31be
        ld (disptr), hl
        ret
l0x31c6:
        ld de, (disfrom)
l0x31ca:
        push bc
        ld a, (de)
        push af
        call l0x3191
        call l0x31b7
        pop af
        inc de
        pop bc
        djnz l0x31ca
        dec de
        ld (disfrom), de
        ret
l0x31de:
        ld b, 02H
        call l0x31c6
        call l0x315d
        jp l0x3096
l0x31e9:
        and 0CFH
        cp 01H
        jr nz, l0x3236
        call l0x31fd
        call l0x3205
        call l0x320a
        call l0x3164
        jr l0x3221
l0x31fd:
        ld b, 03H
l0x31ff:
        call l0x31c6
        jp l0x315d
l0x3205:
        ld a, 83H
        jp l0x3153
l0x320a:
        ld a, c
l0x320b:
        push af
        and 30H
        call l0x35a6
        add a, 1AH
        ld b, 00H
        ld c, a
        ld a, 02H
        ld hl, tableREG
        call l0x3145
        pop af
        ld c, a
        ret
l0x3221:
        ld hl, (disfrom)
        ld a, (hl)
        push hl
        call l0x3191
        pop hl
        dec hl
        ld a, (hl)
        push hl
        call l0x3191
        pop hl
        inc hl
        ld (disfrom), hl
        ret
l0x3236:
        and 0C7H
        cp 06H
        jr nz, l0x3254
        ld b, 02H
        call l0x32be
        ld a, c
        call l0x31ac
        ld b, 00H
        call l0x35e7
        call l0x3164
l0x324d:
        ld hl, (disfrom)
        ld a, (hl)
        jp l0x3191
l0x3254:
        ld a, c
        push af
        and 0EFH
        cp 0AH
        jr nz, l0x327b
        ld b, 01H
        call l0x32be
        ld a, c
        ld bc, 0007H
        call l0x310b
        call l0x3164
l0x326b:
        ld bc, 0008H
        call l0x310b
        pop af
        call l0x320b
        ld bc, 000BH
        jp l0x310b
l0x327b:
        cp 02H
        jr nz, l0x3290
        ld b, 01H
        call l0x32be
        call l0x3603
l0x3287:
        call l0x3164
        ld bc, 0007H
        jp l0x310b
l0x3290:
        cp 22H
        jr nz, l0x32c4
        ld b, 03H
        call l0x32be
        call l0x32af
        call l0x3164
        pop af
l0x32a0:
        bit 4, a
        jr nz, l0x32a7
l0x32a4:
        jp l0x35cd
l0x32a7:
        ld a, 01H
        ld bc, 0007H
        jp l0x310d
l0x32af:
        ld bc, 0008H
        call l0x310b
        call l0x3221
        ld bc, 000BH
        jp l0x310b
l0x32be:
        call l0x31ff
        jp l0x3205
l0x32c4:
        cp 2AH
        jr nz, l0x32d6
        ld b, 03H
        call l0x32be
        pop af
        call l0x32a0
        call l0x3164
        jr l0x32af
l0x32d6:
        and 0CFH
        cp 03H
        jr nz, l0x32eb
        call l0x32e3
        pop af
        jp l0x320b
l0x32e3:
        call l0x3055
        ld a, 0BCH
l0x32e8:
        jp l0x3153
l0x32eb:
        cp 0BH
        jr nz, l0x32fb
        call l0x32f6
        pop af
        jp l0x320b
l0x32f6:
        ld a, 0BFH
        jp l0x3511
l0x32fb:
        and 0C7H
        cp 04H
        jr nz, l0x330b
        call l0x32e3
        pop af
l0x3305:
        call l0x31ac
        jp l0x3106
l0x330b:
        cp 05H
        jr nz, l0x3315
        call l0x32f6
        pop af
        jr l0x3305
l0x3315:
        ld a, c
        and 0CFH
        cp 09H
        jr nz, l0x332b
        ld a, 86H
        call l0x3511
        call l0x32a4
        call l0x3164
        pop af
        jp l0x320b
l0x332b:
        pop af
        cp 10H
        jr nz, l0x334b
        ld a, 0D9H
l0x3332:
        push af
        ld b, 02H
        call l0x31ff
        pop af
        call l0x3153
        jp l0x35f3
l0x334b:
        cp 18H
        jr nz, l0x3353
        ld a, 0D5H
        jr l0x3332
l0x3353:
        ld a, c
        and 0C7H
        or a
        jr nz, l0x3377
        ld a, c
        push af
        ld b, 02H
        call l0x31ff
        ld a, 0D5H
        call l0x3153
        pop af
        call l0x336c
        call fixcomma
        jp l0x35f3

fixcomma:               ; comma fix for jp/jr <flag>, xxx
        push hl
        push af
        ld hl, (disptr)
        dec hl
        ld a, 2CH       ; ","
        ld (hl), a
        ; inc hl
        ; ld a, 20H       ; " "
        ; ld (hl), a
        inc hl
        ld (disptr), hl
        pop af
        pop hl
        ret

l0x336c:
        and 18H
l0x336e:
        rra
        rra
        rra
        add a, a
        add a, 0DDH
        jp l0x3153
l0x3377:
        ld a, c
        cp 0C3H
        jr z, l0x3391
        cp 0CDH
        jr z, l0x338d
        jr l0x33a7
l0x3389:
        and 38H
        jr l0x336e
l0x338d:
        ld a, 0C8H
        jr l0x3393
l0x3391:
        ld a, 0CCH
l0x3393:
        ld b, 03H
        push af
        call l0x31ff
        pop af
        cp 0A6H
        jr nz, l0x33a1
        jp l0x3153
l0x33a1:
        call l0x32e8
        jp l0x3221
l0x33a7:
        and 0C7H
        cp 0C0H
        jr nz, l0x33c5
        ld a, 0C5H
        ld b, 01H
        call l0x33b8
        dec hl
        ld (hl), 20H
        ret
l0x33b8:
        push bc
        push af
        call l0x31ff
        pop af
        call l0x32e8
        pop bc
        ld a, c
        jr l0x3389
l0x33c5:
        ld a, c
        and 0C7H
        cp 0C4H
        jr nz, l0x33d6
        ld a, 0C8H
l0x33ce:
        ld b, 03H
        call l0x33b8
        call fixcomma
        jp l0x3221
l0x33d6:
        cp 0C2H
        jr nz, l0x33de
        ld a, 0CCH
        jr l0x33ce
l0x33de:
        ld a, c
        and 0CfH
        cp 0C1H
        jr nz, l0x33e9
        ld a, 0CEH
        jr l0x33ee
l0x33e9:
        cp 0C5H
        ret nz
        ld a, 0D1H
l0x33ee:
        push bc
        push af
        call l0x3055
        pop af
        call l0x32e8
        pop bc
        ld a, c
        cp 0F1H
        jr z, l0x3401
        cp 0F5H
        jr nz, l0x340b
l0x3401:
        ld (hl), 41H
        inc hl
        ld (hl), 46H
        inc hl
        ld (disptr), hl
        ret
l0x340b:
        jp l0x320b
l0x340e:
        and 0C7H
        cp 0C7H
        jr nz, l0x3421
        ld a, c
        push af
        ld a, 0C2H
        call l0x3511
        pop af
        and 38H
        jp l0x3191
l0x3421:
        and 0C6H
        cp 0C6H
        ld a, c
        jr nz, l0x3440
        xor a
        call l0x34f7
        ld a, c
        push bc
        call l0x31ac
        ld a, 86H
        add a, c
        add a, c
        add a, c
        call l0x3153
l0x3439:
        call l0x3086
        pop bc
        jp l0x324d
l0x3440:
        cp 0EDH
        jp nz, l0x34e8
        ld hl, (disfrom)
        inc hl
        ld a, (hl)
        ld c, a
        and 0C7H
        cp 43H
        jr nz, l0x3471
        ld b, 04H
        call l0x31ff
        call l0x3205
        bit 3, c
        jr nz, l0x3468
        push bc
        call l0x32af
        call l0x3164
        pop bc
        jp l0x320a
l0x3468:
        call l0x320a
        call l0x3164
        jp l0x32af
l0x3471:
        ld b, 02H
        jr l0x34df
l0x3475:
        ld a, c
        and 0C7H
        cp 40H
        jr nz, l0x3496
        push bc
        ld a, 0F0H
        call l0x3153
        pop bc
        ld a, c
        call l0x31ac
        ld a, c
        call l0x310b
        call l0x3164
l0x348e:
        ld bc, 0022H
        ld a, 03H
        jp l0x310d
l0x3496:
        cp 41H
        jr nz, l0x34af
        push bc
        ld a, 0EDH
        call l0x3153
        call l0x348e
        call l0x3164
        pop bc
        ld a, c
        call l0x31ac
        ld a, c
        jp l0x310b
l0x34af:
        cp 42H
        jr nz, l0x34e8
        push bc
        ld a, c
        bit 3, a
        jr nz, l0x34c0
        ld a, 8FH
        call l0x3153
        jr l0x34c5
l0x34c0:
        ld a, 89H
        call l0x3153
l0x34c5:
        call l0x32a4
        call l0x3164
        pop bc
        jp l0x320a
l0x34cf:
        ld b, 1CH
        ld hl, (disfrom)
        inc hl
        ld a, (hl)
        ld hl, tableEXC
        ld b, 1CH
        ld d, 02H
        jr l0x3522
l0x34df:
        and 84H
        jr nz, l0x34cf
        call l0x31ff
        jr l0x3475
l0x34e8:
        cp 0D3H
        jr nz, l0x3502
        ld a, 0EDH
        call l0x34f7
        call l0x34fb
        jp l0x3287
l0x34f7:
        ld b, 02H
        jr l0x3513
l0x34fb:
        ld hl, (disptr) ; re-write to add () to in/out (xx),a
        ld a, 28H       ; "("
        ld (hl), a
        inc hl
        ld (disptr), hl
        call l0x324d
        ld hl, (disptr)
        ld a, 29H       ; ")"
        ld (hl), a
        inc hl
        ld (disptr), hl
        ret
l0x3502:
        cp 0DBH
        jr nz, l0x354b
        ld a, 0F0H
        call l0x34f7
        ld c, 00H
        call l0x3086    ; optimization, skips push/pop not needed
        jp l0x34fb
l0x3511:
        ld b, 01H
l0x3513:
        push af
        call l0x31ff
        pop af
        or a
        jp nz, l0x3153
        ret
l0x351d:
        ld b, 13H
        ld hl, tableOBT
l0x3522:
        cp (hl)
        jr z, l0x352f
l0x3525:
        inc hl
        bit 7, (hl)
        jr z, l0x3525
        inc hl
        djnz l0x3522
        scf
        ret
l0x352f:
        push hl
        ld b, d
        call l0x31ff
        pop hl
        ld de, (disptr)
l0x3539:
        inc hl
        ld a, (hl)
        ld (de), a
        inc de
        bit 7, a
        jr z, l0x3539
        ex de, hl
        dec hl
        res 7, (hl)
        inc hl
        ld (disptr), hl
        or a
        ret
l0x354b:
        ld hl, (disptr)
        cp 0DDH
        jr nz, l0x3559
        ld (hl), 44H
        inc hl
        ld a, 11H
        jr l0x3562
l0x3559:
        cp 0FDH
        jr nz, l0x3590
        ld (hl), 46H
        inc hl
        ld a, 22H
l0x3562:
        ld (disflag), a
        ld (hl), 44H
        inc hl
        inc hl
        ld (disptr), hl
        ld hl, (disfrom)
        inc hl
        ld c, (hl)
        ld a, (hl)
        ld (disfrom), hl
        cp 36H
        push hl
        call z, l0x31fd
        ld a, c
        and 0FEH
        cp 34H
        ld b, 02H
        call z, l0x31ff
        pop hl
        ld a, (hl)
        cp 0E9H
        jr z, l0x358d
        cp 0F9H
        jr z, l0x358d
        cp 0E3H
l0x358d:
        jr z, l0x360a
        ld a, c
l0x3590:
        jp l0x31e9
l0x3593:
        ld hl, (disfrom)
        dec hl
        dec hl
        ld (disfrom), hl
        call l0x3106
l0x35a6:
        rra
        rra
        rra
        cp 04H
        ret nz
        ld a, (disflag)
        rrca
        jr nc, l0x35b5
        ld a, 0F3H
        ret
l0x35b5:
        rrca
        jr nc, l0x35bb
        ld a, 0FAH
        ret
l0x35bb:
        ld a, 04H
        ret
        ld bc, 0008H
        call l0x310b
        call l0x35cd
        ld bc, 000BH
        jp l0x310b
l0x35cd:
        ld a, (disflag)
        ld b, 00H
        rrca
        jr nc, l0x35d9
        ld c, 0DH
        jr l0x35e2
l0x35d9:
        rrca
        jr nc, l0x35e0
        ld c, 14H
        jr l0x35e2
l0x35e0:
        ld c, 04H
l0x35e2:
        ld a, 02H
        jp l0x310d
l0x35e7:
        ld a, (disflag)
        rrca
l0x35eb:
        jr c, l0x3593
        rrca
        jr c, l0x35eb
        jp l0x3106
l0x35f3:
        ld hl, (disfrom)
        ld e, (hl)
        xor a
        bit 7, e
        jr z, l0x35fd
        cpl
l0x35fd:
        ld d, a
        inc hl
        add hl, de
        jp l0x318a
l0x3603:
        pop hl
        pop af
        push hl
        push af
        jp l0x326b
l0x360a:
        ld a, c
        call l0x351d
l0x360e:
        dec hl
        ld a, (hl)
        cp 48H
        jr nz, l0x360e
        ld (hl), 49H
        inc hl
        ld (hl), 58H
        ld a, (disflag)
        rrca
        ret c
        inc (hl)
        ret

;start of loopup tables
;org 3620
tableOPS:
        .db      49H 	;I 82 < WHERE "82H" IS THE INDEX HERE
        .db      4CH,0C4H,00H ;LD 83
        .db      41H,44H,0C4H ;ADD 86
        .db      41H,44H,0C3H ;ADC 89
        .db      53H,55H,0C2H ;SUB 8C
        .db      53H,42H,0C3H ;SBC 8F
        .db      41H,4EH,0C4H ;AND 92
        .db      58H,4FH,0D2H ;XOR 95
        .db      4FH,0D2H,00H ;OR 98
        .db      43H,0D0H,00H ;CP 9B
        .db      52H,4CH,0C3H ;RLC 9E
        .db      52H,52H,0C3H ;RRC A1
        .db      52H,0CCH,00H ;RL A4
        .db      52H,0D2H,00H ;RR A7
        .db      53H,4CH,0C1H ;SLA AA
        .db      53H,52H,0C1H ;SRA AD
        .db      53H,52H,0CCH ;SRL B0
        .db      42H,49H,0D4H ;BIT B3
        .db      52H,45H,0D3H ;RES B6
        .db      53H,45H,0D4H ;SET B9
        .db      49H,4EH,0C3H ;INC BC
        .db      44H,45H,0C3H ;DEC BF
        .db      52H,53H,0D4H ;RST C2
        .db      52H,45H,0D4H ;RET C5
        .db      43H,41H,4CH,0CCH ;CALL C8
        .db      4AH,0D0H ;JP CC
        .db      50H,4FH,0D0H ;POP CE
        .db      50H,55H,53H,0C8H ;PUSH D1
        .db      4AH,0D2H ;JR D5
        .db      45H,0D8H ;EX D7
        .db      44H,4AH,4EH,0DAH ;DJNZ D9

tableFLG:
        .db      4EH,0DAH ;NZ DD
        .db      0DAH,20H ;Z_ DF
        .db      4EH,0C3H ;NC E1
        .db      0C3H,00H ;C_E3
        .db      50H,0CFH ;PO E5
        .db      50H,0C5H ;PE E7
        .db      0D0H,00H ;P_ E9
        .db      0CDH,00H ;M_ EB
        .db      4FH,55H,0D4H ;OUT ED
        .db      49H,0CEH ;IN F0

tableOBT:
        .db      00H,4EH,4FH,0D0H ;NOP
        .db      07H,52H,4CH,43H,0C1H ;RLCA
        .db      08H,45H,58H,20H,41H,46H,2CH,41H,46H,0A7H ;EX AF,AF'
        .db      0FH,52H,52H,43H,0C1H ;RRCA
        .db      17H,52H,4CH,0C1H ;RLA
        .db      1FH,52H,52H,0C1H ;RRA
        .db      27H,44H,41H,0C1H ;DAA
        .db      2FH,43H,50H,0CCH ;CPL
        .db      37H,53H,43H,0C6H ;SCF
        .db      3FH,43H,43H,0C6H ;CCF
        .db      76H,48H,41H,4CH,0D4H ;HALT
        .db      0C9H,52H,45H,0D4H ;RET
        .db      0D9H,45H,58H,0D8H ;EXX
        .db      0E3H,45H,58H,20H,28H,53H,50H,29H,2CH,48H,0CCH ;EX (SP),HL
        .db      0E9H,4AH,50H,20H,28H,48H,4CH,0A9H ;JP (HL)
        .db      0EBH,45H,58H,20H,44H,45H,2CH,48H,0CCH ;EX DE,HL
        .db      0F3H,44H,0C9H ;DI
        .db      0F9H,4CH,44H,20H,53H,50H,2CH,48H,0CCH ;LD SP,HL
        .db      0FBH,45H,0C9H ;EI

tableEXC:
        .db      44H,4EH,45H,0C7H ;NEG
        .db      45H,52H,45H,54H,0CEH ;RETN
        .db      46H,49H,4DH,20H,0B0H ;IM 0
        .db      47H,4CH,44H,20H,49H,2CH,0C1H ;LD I,A
        .db      4DH,52H,45H,54H,0C9H ;RETI
        .db      4FH,4CH,44H,20H,52H,2CH,0C1H ;LD R,A
        .db      56H,49H,4DH,20H,0B1H ;IM 1
        .db      57H,4CH,44H,20H,41H,2CH,0C9H ;LD A,I
        .db      5EH,49H,4DH,20H,0B2H ;IM 2
        .db      5FH,4CH,44H,20H,41H,2CH,0D2H ;LD A,R
        .db      67H,52H,52H,0C4H ;RRD
        .db      6FH,52H,4CH,0C4H ;RLD
        .db      0A0H,4CH,44H,0C9H ;LDI
        .db      0A1H,43H,50H,0C9H ;CPI
        .db      0A2H,49H,4EH,0C9H ;INI
        .db      0A3H,4FH,55H,54H,0C9H ;OUTI
        .db      0A8H,4CH,44H,0C4H ;LDD
        .db      0A9H,43H,50H,0C4H ;CPD
        .db      0AAH,49H,4EH,0C4H ;IND
        .db      0ABH,4FH,55H,54H,0C4H ;OUTD
        .db      0B0H,4CH,44H,49H,0D2H ;LDIR
        .db      0B1H,43H,50H,49H,0D2H ;CPIR
        .db      0B2H,49H,4EH,49H,0D2H ;INIR
        .db      0B3H,4FH,54H,49H,0D2H ;OTIR
        .db      0B8H,4CH,44H,44H,0D2H ;LDDR
        .db      0B9H,43H,50H,44H,0D2H ;CPDR
        .db      0BAH,49H,4EH,44H,0D2H ;INDR
        .db      0BBH,4FH,54H,44H,0D2H ;OTDR

tableREG:
        .db      42H,43H ;BC
        .db      44H,45H ;DE
        .db      48H,4CH ;HL
        .db      2CH,41H ;,A
        .db      28H,48H,4CH,29H ;(HL)
        .db      28H,49H,58H,2BH,20H,1FH,29H ;(IX+__)
        .db      28H,49H,59H,2BH,20H,1FH,29H ;(IY+__)

tableSREG:
        .db      42H     ;B
        .db      43H     ;C
        .db      44H     ;D
        .db      45H     ;E
        .db      48H     ;H
        .db      4CH     ;L
        .db      53H     ;S
        .db      50H     ;P
        .db      28H,43H,29H ;(C)

        .db      0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH ;FILL
