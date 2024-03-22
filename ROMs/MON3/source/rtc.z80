; ----------------------------------------------------------------------------
;
; DS1302 RTC API Routines for MON3 - For use with GPIO RTC Card
;
; Written By Craig Hart, 2024
;
; ----------------------------------------------------------------------------
;
; C register - API Call #
; B register - API Function
;
; Calls return C=1 if failed, C=0 if success
;

RTCAPI:
        ld a,b
        cp DSAPIFnMax           ; Valid API Number?
        jr c,APIOk
APIErr: scf                     ; set C flag = Error
        ret

APIok:  add a,a                 ; 2 byte table
        push hl
        push bc
        ld b,0
        ld c,a
        ld hl,DSAPIFunctions
        add hl,bc
        ld c,(hl)
        inc hl
        ld b,(hl)
        push bc
        pop ix
        pop bc
        pop hl
        jp (ix)

; ----------------------------------------------------------------------------
; Determine if a DS1302 is pesent
;
; If all registers return FFh, no DS1302 exists
; ----------------------------------------------------------------------------
checkDS1302Present:
        push de

        ld de,8E00H         ; clear write protect bit
        call rtc_wr
        ld de,9000H         ; clear trickle charge bits
        call rtc_wr

        ld d,81H
        call rtc_rd
        cp 5AH              ; should come back 00..59h
        jr nc, noDS1302

        ld d,8BH
        call rtc_rd
        cp 08H              ; should come back 01..07
        jr nc, noDS1302

        pop de
        or a                ; clear C flag
        ret

noDS1302:
        pop de
        scf                  ; set C flag
        ret

; ----------------------------------------------------------------------------
; Reset the DS1302 fully to a known date/time condition
; does not clear RTC bytes
; ----------------------------------------------------------------------------
resetDS1302:
        push de

        ld de,8E00H        ; clear write protect bit
        call rtc_wr
        ld de,9000H        ; clear trickle charge bits
        call rtc_wr

        ld de, 8000H       ; seconds 00
        call rtc_wr
        ld de, 8200H       ; minutes 00
        call rtc_wr
        ld de, 8490H       ; hours 01, 12 hour mode
        call rtc_wr

        ld de,8601H        ; date 01
        call rtc_wr
        ld de,8801H        ; month 01
        call rtc_wr
        ld de,8A01H        ; day 01 (Monday)
        call rtc_wr
        ld de,8C00H        ; year 00 (2000)
        call rtc_wr

        pop de
        or a               ; clear Z flag
        ret

; ----------------------------------------------------------------------------
; Returns time
;
; H = hour      ; bit 5 = am/pm flag (in 12 hr mode). 1=PM
; L = minute
; D = second
; ----------------------------------------------------------------------------
getTime:
        ld d,85H                ; hour
        call rtc_rd
        and 3FH                 ; strip off bits
        ld h,a

        ld d,83H                ; min
        call rtc_rd
        ld l,a

        ld d,81H                ; sec
        call rtc_rd
        ld d,a

        or a
        ret

; ----------------------------------------------------------------------------
; Sets time; preserves 12/24 hour mode
;
; H = hour             ; bit 5 = am/pm in 12hr mode
; L = minute
; D = second
; ----------------------------------------------------------------------------
setTime:
        ld e,d
        ld d,80H                ; secs
        call rtc_wr

        ld a,h                  ; mask off junk bits
        and 3FH
        ld h,a

        call get1224Mode        ; get 12/24 flag
        or h
        ld e,a
        ld d,84H                ; hour
        call rtc_wr

        ld e,l
        ld d,82H                ; mins
        call rtc_wr

        or a
        ret

; ----------------------------------------------------------------------------
; Returns date
;
; H = date
; L = month
; DE = year 2000..2099
; ----------------------------------------------------------------------------
getDate:
        push bc
  
        ld d,87H                ; date
        call rtc_rd
        ld h,a

        ld d,89H                ; month
        call rtc_rd
        ld l,a

        ld d,8DH                ; year
        call rtc_rd
        ld e,a
        ld d,20H                ; Add '20'xxh

        pop bc
        or a
        ret

; ----------------------------------------------------------------------------
; sets date
;
; H = date
; L = month
; DE = year (Decimal) 2000..2099
; ----------------------------------------------------------------------------
setDate:
        ld d,8CH                ; year  (just ignore '20'xxh)
        call rtc_wr

        ld d,88H                ; month
        ld e,l
        call rtc_wr
        
        ld d,86H                ; date
        ld e,h
        call rtc_wr

        or a
        ret

; ----------------------------------------------------------------------------
; Returns day in D
; returns HL points to day ASCIIZ String
; ----------------------------------------------------------------------------
getDay:
        ld d,8BH                ; day
        call rtc_rd
        and 07H
        ld d,a

        ld hl,daysList
        dec a
        cp 0
        jr z,foundDay
        ld b,a

dayloop:
        ld a,(HL)
        inc hl
        cp 0
        jr nz,dayLoop
        djnz dayLoop

foundDay:
        or a
        ret

; ----------------------------------------------------------------------------
; sets day from D - 01..07
; ----------------------------------------------------------------------------
setDay:
        ld a,d
        cp 0
        jr nz,validDay
        scf
        ret

validDay:
        push de
        and 07H
        ld e,a
        ld d,8AH                ; day
        call rtc_wr

        pop  de
        or a
        ret

; ----------------------------------------------------------------------------
; Returns 12hr / 24hr mode. A = 00h = 24 hour mode, 80h = 12 hr mode
; ----------------------------------------------------------------------------
get1224Mode:
        push de
        ld d,85H                ; hour
        call rtc_rd
        and 80H                 ; mask bits

        pop de
        or a
        ret

; ----------------------------------------------------------------------------
; Sets 12hr mode
; no prameters
; ----------------------------------------------------------------------------
set12HrMode:
        ld d,85H                ; hour
        call rtc_rd
        bit 7,a                 ; is it already 12 hr mode?
        jr z,pr12
        scf                     ; already 12 hour mode dude!
        ret

pr12:   and 3FH                ; 24 hour to 12 hour - strip bits
        cp 00H
        jr nz,notMidnight
        ld a,92H            ; 12am + 12 hour flag
        jr setHour

notMidnight:
        cp 12H
        jr z,setpm            ; 12pm exactly?
        jr nc,ispm            ; >12 ?
        or 80H                ; <12, so hours same, set 12 hour flag
        jr setHour

ispm:   sub 12H                ; convert to 12 hr time
        daa
setpm:  or 0A0H                ; set 12 hour flag + PM fag
        jr setHour

; ----------------------------------------------------------------------------
; Sets 24hr mode
; no prameters
; ----------------------------------------------------------------------------
set24HrMode:
        ld d,85H                ; hour
        call rtc_rd
        bit 7,a                 ; is it already 24 hr mode?
        jr nz,pr24
        scf                     ; already 24 hour mode dude!
        ret

pr24:   and 3FH                ; strip bits 7 and 6 to set 24h mode
        bit 5,a                ; was it pm?
        
        jr z,fixt            ; am? if so am is same as 24hr

        and 1FH                ; clear PM flag
        cp 12H                ; is it 12pm? no change
        jr z,setHour
        add a,12H            ; adjust by adding 12 hours
        daa                ; in BCD
        jr setHour

fixt:   cp 12H                ; 12am = 00 hours
        jr nz,nofix
        xor a

nofix:  and 1FH                ; clear PM flag

; sethour is a Shared function of above 2 calls
setHour:
        ld e,a                ; set clock
        ld d,84H
        call rtc_wr

        or a
        ret

; ----------------------------------------------------------------------------
; formatTime takes in a time, and outputs it as a well structured string
;
; note -- must supply bit 7 if 12hr!!!
;
; H = hour      ; bit 7 = 12/24hr. bit 5 = am/pm flag (in 12 hr mode). 1=PM
; L = minute
; D = second
;
; IY = pointer to where to write output
; ----------------------------------------------------------------------------
formatTime:
        push de
        push iy
        pop de

        ld a,h                 ; get hours
        bit 7,a            ; 1 = 12 hour
        jr z, is24
        and 1FH

is24:   and 3FH
        call AToString

        ld a,':'        ; add deliminator
        ld (de),a
        inc de

        ld a,l          ; get minutes
        call AToString

        ld a,':'        ; add deliminator
        ld (de),a
        inc de

        pop bc

        ld a,b          ; set seconds
        call AToString

        ld a,h          ; work out if AM or PM, or 24 hour mode
        bit 7,a
        jr z,noampm        ; skip AM/PM if 24 hour mode

        ld a,' '        ; add space
        ld (de),a
        inc de

        ld b,'A'

        ld a,h                  ; is it AM or PM 
        and 20H
        jr z,isam

        ld b,'P'
 
isam:   ld a,b            ; copy 2 bytes AM or PM to buffer
        ld (de),a
        inc de
        ld a,'M'
        ld (de),a
        inc de

noampm: xor a            ; null terminate string
        ld (de),a
        ret

; ----------------------------------------------------------------------------
; formatDate takes in a date, and outputs it as a well structured string
;
; H = date
; L = month
; DE = year
;
; IY = pointer to where to write output
; ----------------------------------------------------------------------------
formatDate:
        push de
        push iy
        pop de
        
        ld a,h
        call AToString
        ld a,'/'
        ld (de),a
        inc de

        ld a,l
        call AToString
        ld a,'/'
        ld (de),a
        inc de

        pop bc                  ; year now in BC
        ld a,b
        call AToString
        ld a,c
        call AToString
  
        ld a,0
        ld (de),a

        ret
        
; ----------------------------------------------------------------------------
; Input:        D = byte to return 0..30
; Output:       A = byte read
; ----------------------------------------------------------------------------
readRTCByte:
        ld a,d
        ld d,0
        cp 31
        ret nc          ;exit if greater then 30
        add a,a         ;Double in to get read index
        add a,0C1H
        ld d,a
        call rtc_rd

        or a
        ret

; ----------------------------------------------------------------------------
; Input:        DE = register and byte to write, D=0..30
; ----------------------------------------------------------------------------
writeRTCByte:
        ld a,d
        cp 31
        ret nc          ;exit if greater then 30
        add a,a         ;Double it to get write index
        add a,0C0H
        ld d,a
        call rtc_wr

        or a
        ret

; ----------------------------------------------------------------------------
; Reads all 31 RTC RAM bytes to userbuffer
; input: HL = location to write to (31 bytes to be written)
; ----------------------------------------------------------------------------
burstRTCRead:
        push bc
        push de

        ld c,RTC_PORT
        ld a,10H        ; raise CS, enable data out
        out (c),a
  
        ld d,0FFH        ; ram burst
        call bytelpW        ; write D to select the register

        ld b,31

bRead:  call bytelpR        ; read value (into D)
        ld (hl),d
        inc hl
        djnz bRead

        xor a            ; drop CS & clear CF
        out (c),a

        pop de
        pop bc
        ret

; ----------------------------------------------------------------------------
; Write cycle. Writes 2 bytes
; D = command/register
; E = data byte
; ----------------------------------------------------------------------------
rtc_wr:
        push af
        push bc
        ld c,RTC_PORT
        ld a,10H        ; raise CS, enable data in
        out (c),a
        call bytelpW        ; write D to select the register
        ld d,e
        call bytelpW        ; write E - the data
        xor a            ; drop CS
        out (c),a
        pop bc
        pop af
        ret

; ----------------------------------------------------------------------------
; Read cycle. Writes command and reads result
; D = command/register needed
; A = result
; ----------------------------------------------------------------------------
rtc_rd:
        push bc
        ld c,RTC_PORT
        ld a,10H        ; raise CS, enable data out
        out (c),a
        call bytelpW        ; write D to select the register
        call bytelpR        ; read value (into D)
        xor a            ; drop CS
        out (c),a
        ld a,d            ; return value in A
        pop bc
        ret

; ----------------------------------------------------------------------------
; write one byte to the DS1302
; byte in D
; ----------------------------------------------------------------------------
bytelpW:
        push bc
        ld b,8
 
blp:    srl d            ; data bit 0 to carry
        ld a,20H
        rra            ; carry to data bit 7
        out (c),a        ; setup bus - drops clock
        or 40H            ; raise CLK
        out (c),a
        djnz blp
        pop bc
        ret

; ----------------------------------------------------------------------------
; Read one byte from the DS1302
; byte read is returned in D
; ----------------------------------------------------------------------------
bytelpR:
        push bc

        ld b,8
        ld d,0

blp2:   ld a,30H
        or 40H          ; raise CLK
        out (c),a
        and 0BFH        ; drop CLK
        out (c),a
        in e,(c)        ; read value
        srl e
        rr d
        djnz blp2
        pop bc
        ret

; ----------------------------------------------------------------------------
; Conversion routine - BCD to true Binary
; input:  A = BCD value
; output: A = binary value
; ----------------------------------------------------------------------------
bcdToBin:
        push bc
        ld c,a
        and 0F0H
        srl a
        ld b,a
        srl a
        srl a
        add a,b
        ld b,a
        ld a,c
        and 0FH
        add a,b
        pop bc
        ret

; ----------------------------------------------------------------------------
; Conversion routine - Binary to BCD
; input:  A = binary value
; output: A = BCD value
; ----------------------------------------------------------------------------
binToBcd:
        push    bc
        ld    b,10
        ld    c,-1
div10:  inc    c
        sub    b
        jr    nc,div10
        add    a,b
        ld    b,a
        ld    a,c
        add    a,a
        add    a,a
        add    a,a
        add    a,a
        or    b
        pop    bc
        ret

; ----------------------------------------------------------------------------
; Stand Alone, RTC configuration and PRAM Viewer
; Setting time:
;       0 sets hours
;       1 sets minutes
;       2 resets seconds to 00
;       3 toggles 12/24 hour time
;
; Setting calendar:
;       4 sets day of week
;       5 sets date
;       6 sets month
;       7 sets year
;
; Special Keys:
;
; A - Reset the DS1302 to 01/01/2000, 01:00.00am & 12hr mode
; D - DUMPs the RTC RAM to LCD (Addr to exit dump mode) where
;       + Moves down RAM list
;       - Moves up RAM list
;       AD Exits back to RTC Setup
; Addr - Exit
; ----------------------------------------------------------------------------
RTCSetup:
; clear the LCD
        ld b,01H        ;clear LCD
        ld c,15         ;command to LCD
        rst 10H

; setup RTC chip
        call checkDS1302Present
        ;Carry set = No RTC
        jr nc,clockLoop ;RTC Found, continue with program
        ld hl,noRTC     ;Load HL with no RTC Found text
        ld c,13         ;string to LCD
        rst 10H
        ld de,segDisp
        rst 20H
        jr nc,$-4

        ret             ;exit back to calling routine
noRTC:  .db "RTC Module not found",0

; Main Loop
clockLoop:
        ; read RTC and store time
        call getRTCTime

        ; display time and date on LCD
        ld a,(RTC_OSEC) ;get old seconds
        ld b,a          ;save old seconds
        ld a,(RTC_SECS) ;get current seconds
        cp b            ;are they the same?
        jr z,keyRTC     ;yes, skip updating LCD

        ; seconds have changed, update LCD
        ld (RTC_OSEC),a ;save new seconds in old
RTCUpdate:
        ld b,02H        ;set LCD Cursor to top left
        ld c,15         ;command to LCD
        rst 10H
        call getRTCTime
        
        ;format time
        ld iy,RTC_BUFF  ;get LCD buffer
        call formatTime
        ld hl,RTC_BUFF  ;get new buffer
        ld c,13         ;string to LCD
        rst 10H
        
        ; LCD section, calendar
        ld b,0C0H       ;Cursor to row 2
        ld c,15         ;command to LCD
        rst 10H
        call getDay     ;get Day as a string
        ld c,13         ;string to LCD
        rst 10H
        ld iy,RTC_BUFF  ;get LCD buffer
        ld a,' '        ;add space
        ld (iy),a
        inc iy
        call getDate
        ld a,h          ;save day
        ld (RTC_DAY),a
        ld a,l          ;save month
        ld (RTC_MONTH),a
        ld (RTC_YEAR),de    ;save year
        call formatDate
        
        ; display date on LCD
        ld hl,RTC_BUFF
        ld c,13         ;string to LCD
        rst 10H

        ; display help on LCD
        ld b,94H        ;Cursor to row 3
        ld c,15         ;command to LCD
        rst 10H
        ld hl,helpList  ;Load HL help text
        ld c,13         ;string to LCD
        rst 10H
        ld b,0D4H       ;Cursor to row 4
        ld c,15         ;command to LCD
        rst 10H
        ld c,13         ;string to LCD
        rst 10H

; keystroke handling section
keyRTC:
        ld de,segDisp
        rst 20H
        jp nc,clockLoop ;loop if no key or repeat key

        cp 13H          ;Addr key?
        ret z           ;exit program

keyTryF:
        cp 0FH          ;F = reset clock
        jr nz,keyTry0
        call resetDS1302
        jp clockLoop
keyTry0:
        or a            ;Hours adjust
        jr nz,keyTry1
        ld a,(RTC_HOURS)
        bit 7,a         ;check if 24 hours
        jr nz,set12
        inc a           ;set to next hour
        daa
        cp 24H          ;is it 24
        jr nz,saveTime
        xor a
        jr saveTime
set12:  ld c,a
        and 0A0H        ;mask out bits 7 and 5
        ld d,a
        ld a,c          ;restore A
        and 1FH         ;mask off junk bits
        inc a
        daa
        cp 13H          ;is it 13 o'clock?
        jr nz,noflip
        ld a,d          ;get AM/PM bits
        xor 20H         ;toggle bit 5
        inc a           ;make it 1 o'clock
        jr saveTime
noflip: or d            ;add AM/PM bits
saveTime:
        ld h,a          ;save adjusted hours
        ld a,(RTC_MINS) ;save minutes
        ld l,a
        ld a,(RTC_SECS) ;save seconds
        ld d,a
        ;Set the time with HL,D
stTime:
        call setTime    ;set time
        jp RTCUpdate

keyTry1:
        cp 1            ;minutes adjust
        jr nz,keyTry2
        call getTime
        ld a,l          ;get minutes
        inc a
        daa
        cp 60H          ;is it over 59?
        jr nz,$+3       ;skip xor
        xor a           ;reset to zero
        ld l,a          ;save minutes
        jr stTime

keyTry2:
        cp 2            ;seconds adjust
        jr nz,keyTry3
        call getTime
        ld d,0          ;reset to zero seconds
        jr stTime

keyTry3:
        cp 3            ;12/24 hour mode
        jr nz,keyTry4
        ld b,01H        ;clear LCD screen to fix AM/PM sign
        ld c,15         ;command to LCD
        rst 10H
        ld a,(RTC_HOURS) ;get hours
        bit 7,a         ;is it 12 hour mode?
        jr nz,to24
        call set12HrMode
        jp RTCUpdate
to24:   call set24HrMode
        jp RTCUpdate

keyTry4:
        cp 4            ;get day
        jr nz,keyTry5
        call getDay
        ld a,d
        inc a
        cp 8
        jr nz,$+4
        ld a,1
        ld d,a
        call setDay
        ld b,01H        ;clear LCD screen to fix AM/PM sign
        ld c,15         ;command to LCD
        rst 10H
        jp RTCUpdate

keyTry5:
        cp 5            ;get day of month
        jr nz,keyTry6
        ld a,(RTC_DAY)
        inc a
        daa
        cp 32H
        jr nz,$+4
        ld a,1
        ld h,a
        ld a,(RTC_MONTH)
        ld l,a
        ld de,(RTC_YEAR)
        jr setYear

keyTry6:
        cp 6            ;get month
        jr nz,keyTry7
        ld a,(RTC_MONTH)
        inc a
        daa
        cp 13H
        jr nz,$+4
        ld a,1
        ld l,a
        ld a,(RTC_DAY)
        ld h,a
        ld de,(RTC_YEAR)
        jr setYear

keyTry7:
        cp 7            ;get year
        jr nz,keyTry8
        ld de,(RTC_YEAR)
        ld a,e
        inc a
        daa
        ld e,a
        ld (RTC_YEAR),de
        ld a,(RTC_DAY)
        ld h,a
        ld a,(RTC_MONTH)
        ld l,a
setYear:
        call setDate
        jp RTCUpdate

keyTry8:
        cp 8            ;PRAM view
        jp nz,clockLoop
        call dumpRAM    ;Display PRAM
        jp clockLoop

; Display the contents of the RTC RAM (PRAM) bytes (31 bytes) on the LCD
dumpRAM:
        ld hl,RTC_RAM
        call burstRTCRead ;put RAM data in RTC_RAM location
        
        xor a
        ld (RAM_PTR),a
        
dumpLoop:
        ld a,(RAM_PTR)  ;get pointer (0,1 or 2)
        add a,a         ;x2
        ld b,a
        add a,a         ;x4
        add a,b         ;x6
        ld hl,RTC_RAM   ;index HL to pointer position
        add a,l
        ld l,a

        ld b,01H        ;clear LCD
        ld c,15         ;command to LCD
        rst 10H
        call displayRAMline

        ld b,0C0H       ;set second row
        ld c,15         ;command to LCD
        rst 10H
        call displayRAMline

        ld b,94H       ;set third row
        ld c,15         ;command to LCD
        rst 10H
        call displayRAMline

        ld b,0D4H       ;set forth row
        ld c,15         ;command to LCD
        rst 10H
        call displayRAMline

        ;get key input
dumpKey:
        ld de,segDisp
        rst 20H
        jr nc,dumpKey

        cp 13H          ;is it Addr?
        jr nz,keyTryPlus
        ld b,01H        ;clear LCD
        ld c,15         ;command to LCD
        rst 10H
        ret

keyTryPlus:
        cp 10H          ;is it plus key?
        jr nz,keyTryMinus
        ld a,(RAM_PTR)  ;get pointer
        cp 2            ;is it at bottom?
        jr z,dumpKey    ;yet, get key again
        inc a
        ld (RAM_PTR),a  ;save it
        jr dumpLoop

keyTryMinus:
        cp 11H          ;is it minus key?
        jr nz,dumpKey   ;get key again
        ld a,(RAM_PTR)  ;get pointer
        or a            ;is it at top?
        jr z,dumpKey    ;yet, get key again
        dec a
        ld (RAM_PTR),a  ;save it
        jr dumpLoop

displayRAMline:
        call genRAMline ;input HL, output DE
        ex de,hl
        ld c,13         ;string to LCD
        rst 10H
        ex de,hl
        ret

; fill RTC_BUFF with line to display on LCD
; someting like this 06:06 07 08 09 0A 0B
; input: HL = address of first byte to display
; outptu: DE = address of LCD ASCII line
genRAMline:
        ;get index
        ld de,RTC_RAM
        or a
        sbc hl,de       ;get index difference
        ld a,l          ;store index in a
        add hl,de       ;restore HL
        ld b,6          ;six bytes by default
        cp 1EH          ;is it on the last line?
        jr nz,$+4       ;yes, only display one byte
        ld b,1          ;one byte
        ld c,9          ;A to string
        ld de,RTC_BUFF  ;convert A to "AA"
        rst 10H
        ld a,':'        ;add colon
        ld (de),a
        inc de
RAMdisploop:
        ld a,(hl)
        inc hl
        ld c,9          ;A to string
        rst 10H
        ld a,' '        ;add space
        ld (de),a
        inc de
        djnz RAMdisploop
        dec de
        xor a
        ld (de),a       ;terminate with zero
        ld de,RTC_BUFF  ;reset to start of buffer
        ret

; Get current time and save in local RAM.
; Returns: H = hour      ; bit 5 = am/pm flag (in 12 hr mode). 1=PM
;          L = minute
;          D = second
getRTCTime:
        call getTime
        ld a,d          ;save seconds
        ld (RTC_SECS),a
        ld a,l          ;save minutes
        ld (RTC_MINS),a

        ; check if 12 or 24 hours
        call get1224Mode    ;A = 00H, 24 hour mode, 80h, 12 hr mode
        or h            ;set bit 7 if 12 hour mode in hours data and save it
        ld h,a
        ld (RTC_HOURS),a
        ret

; Checks the state of the RTC checksum (RAM at 31 slot).  Checksum is the twos 
; compliment of the first 16 bytes of RAM.  It will then compare the result
; with the stored checksum in slot 31.
; Input: none
; Output: A = 00 if match or something else if no match
;         Zero Flag = set if calculated checksum = stored checksum
; Destroy: A
checkRTCchecksum:
        call getRTCChecksum
        ld l,a
        ld d,30
        call readRTCByte    ;get stored checksum
        sub l
        ret                 ;Zero flag set if checksum = stored checksum

; Calculate checksum for MON3 stored values.  First 16 bytes of RAM are reserved
; for MON3.  Calculate the checksum of the first 16 bytes.  Checksum is the
; twos compliment of the sum of the 16 bytes
; Input: none
; Output: A = calculated checksum
getRTCChecksum:
        push hl
        push bc
        ld hl,RTC_RAM
        call burstRTCRead   ;put RAM data in RTC_RAM location
        ld hl,RTC_RAM       ;index HL to start position
        ld b,16             ;B=16 bytes to parse
        xor a               ;A=initial checksum
checksumloop:
        ld c,(hl)           ;get RAM value
        add a,c
        inc hl              ;move to next RAM value
        djnz checksumloop
        neg                 ;get the twos compliment
        pop bc
        pop hl
        ret                 ;Zero flag set if checksum = stored checksum

; ----------------------------------------------------------------------------
; RAM Locations
; ----------------------------------------------------------------------------
RTC_BASE:   .equ    0900H       ;Start of RAM location
RTC_SECS:   .equ    RTC_BASE    ;Seconds (1-byte)
RTC_OSEC:   .equ    RTC_BASE+1  ;Old Seconds (1-byte)
RTC_MINS:   .equ    RTC_BASE+2  ;Minutes (1-byte)
RTC_HOURS:  .equ    RTC_BASE+3  ;Hours (1-byte)
RTC_DAY:    .equ    RTC_BASE+4  ;Day of Week (1-byte)
RTC_MONTH:  .equ    RTC_BASE+5  ;Month (1-byte)
RTC_YEAR:   .equ    RTC_BASE+6  ;Year (2-bytes)
RTC_BUFF:   .equ    RTC_BASE+8  ;LCD Buffer (21-bytes)
RTC_RAM:    .equ    RTC_BASE+29 ;RAM Data (31-byte)
RAM_PTR:    .equ    RTC_BASE+60 ;RAM Pointer (1-byte)

; ----------------------------------------------------------------------------
; constants
; ----------------------------------------------------------------------------
RTC_PORT:   .equ 0FCH
segDisp:        .db 0A7H,0C7H,0C6H,4BH,0C6H,0C3H
daysList:       .db "Monday",0
                .db "Tuesday",0
                .db "Wednesday",0
                .db "Thursday",0
                .db "Friday",0
                .db "Saturday",0
                .db "Sunday",0
helpList:       .db "H:M:S PM:0-3, PRAM:8",0
                .db "WD D/M/Y:4-7, RSET:F",0

DSAPIFunctions: .dw checkDS1302Present
                .dw resetDS1302
                .dw getTime
                .dw setTime
                .dw getDate
                .dw setDate
                .dw getDay
                .dw setDay
                .dw get1224Mode
                .dw set12HrMode
                .dw set24HrMode
                .dw readRTCByte
                .dw writeRTCByte
                .dw burstRTCRead
                .dw bcdToBin
                .dw binToBcd
                .dw formatTime
                .dw formatDate
                .dw RTCSetup

DSAPIFnMax:     .equ ($-DSAPIFunctions)/2

