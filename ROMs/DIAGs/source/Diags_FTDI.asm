
; Bit Bang FTDI USB tranmit routine.  Transmit one byte via the FTDI USB serial
; connection.  It assumes a uart connection of 4800-8-N-2
; Input: A = byte to transmit
; Output: nothing
; Destroy: none
txByte:
        push af             ;save AF
        push bc             ;save BC
        push hl             ;save HL
        ld hl,BAUD          ;set HL to Baud delay
        ld c,a              ;save transmit byte in C
        ;transmit the start bit
        xor a               ;clear A
        out (DIGITS),a      ;pull D6 low
        call timeDelay      ;do a baud delay
        ;transmit the byte
        ld b,8              ;eight bits to send
        rrc c               ;move fist bit into carry flag
sendBit:
        rrc c               ;shift to bit 6
        ld a,c              ;load byte in A
        and 40H             ;mask out all bits except 6
        out (DIGITS),a      ;output the bit
        call timeDelay      ;do a baud delay
        djnz sendBit        ;send next bit
        ;transmit stop bits
        ld a,40H            ;set bit
        out (DIGITS),a      ;output the bit
        call timeDelay      ;do a baud delay
        call timeDelay      ;do a baud delay x2 (two stop bits)
        pop hl              ;restore HL
        pop bc              ;restore BC
        pop af              ;restore AF
        ret

; Bit Bang FTDI USB receive routine.  Receive one byte via the FTDI USB serial
; connection.  It assumes a uart connection of 4800-8-N-2
; Input: nothing
; Return: A = byte received
; Destroy: none
rxByte:
        push bc             ;save BC
        push hl             ;save HL
 
startBit:
        in a,(SIMP3)    ;read system input for High to Low on Bit 7
        rlca                ;put bit 7 (TX line) in carry
;        jr c,startBit       ;loop if TX line is high

        jr c,rxExit
        ;start bit detected
        ld hl,BAUD          ;set HL to Baud delay
        srl h               ;half the delay
        rr l
        call timeDelay      ;do a baud delay
        in a,(SIMP3)    ;get start bit
        rlca                ;move bit 7 into carry
        jr c,startBit       ;start bit too short, try again
        ;valid start bit detected
        ld b,8              ;eight bits to receive
getBit:
        ld hl,BAUD          ;set HL to Baud delay
        call timeDelay      ;do a baud delay
        in a,(SIMP3)    ;get data bit
        rlca                ;move bit 7 into carry
        rr c                ;rotate register C and put carry in bit 7
        djnz getBit         ;get next bit
        ld a,c              ;load byte C to A
        or a                ;clear carry flag
rxExit:
        pop hl              ;restore HL
        pop bc              ;restore BC
        ret

; Time delay.  16-bit Delay routine
; Input: HL = delay amount
; Destroy: none
timeDelay:
        push hl             ;save HL
        push de             ;save DE
        ld de,1             ;load DE with 1
        sbc hl,de           ;subtract 1 from HL
        jp nc,$-2           ;repeat subtraction until HL=0
        pop de              ;restore DE
        pop hl              ;restore HL
        ret