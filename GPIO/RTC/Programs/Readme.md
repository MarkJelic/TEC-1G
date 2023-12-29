# TEC-1G GPIO Real Time Clock
### Sample Programs

[Simple Clock Demo](./ClockDemo/) by Craig Hart

## MON3 API Extension for Real Time Clock
The Real Time Clock API extensions were added to MON3 from version 1.3

**rtcExist** is a variable/location in the reserved System RAM.

It is set to TRUE or FALSE on _hardBoot, as the system checks if a RTC is present or not.
The quickest way to test if the RTC is present would be this code:

| API Name | Description | Command | Notes |
|---|---|---|---|
| $81 | Read Seconds | Bit 7 = 0, Bits 6 - 4 = 10s of Seconds, Bits 3 - 0 = Seconds | Binary Coded Decimal |






### Reading Data
| Register | Description | Command | Notes |
|---|---|---|---|
| $81 | Read Seconds | Bit 7 = 0, Bits 6 - 4 = 10s of Seconds, Bits 3 - 0 = Seconds | Binary Coded Decimal |
| $83 | Read Minutes | Bit 7 = 0, Bits 6 - 4 = 10s of Minutes, Bits 3 - 0 = Seconds | Binary Coded Decimal |
| $85 | Read Hours (24) | Bit 7 - 6 = 0, Bits 5 - 4 = 10s of Hours, Bits 3 - 0 = Hours | Binary Coded Decimal |
| $87 | Read Date | Bit 7 - 6 = 0, Bits 5 - 4 = 10s of Date, Bits 3 - 0 = Day | Binary Coded Decimal |
| $89 | Read Month | Bit 7 - 5 = 0, Bit 4 = 10s of Month, Bits 3 - 0 = Month | Binary Coded Decimal |
| $8B | Read Day | Bit 7 - 3 = 0, Bits 2 - 0 = Day | Binary Coded Decimal |
| $8D | Read Year | Bit 7 - 4 = 10s of Years, Bits 3 - 0 = Years | Binary Coded Decimal |
| $C1 | Read PRAM Byte | Location $01 |  |
| $C3 | Read PRAM Byte | Location $02 |  |
| $C5 | Read PRAM Byte | Location $03 |  |
| .. | .. | .. | (increase Register +2) |
| $FD | Read PRAM Byte | Location $31 |  |

### WRITING Data
| Register | Data | Command | Notes |
|---|---|---|---|
| $8E | Set Write Protect | Bit 7: 1=ON, 0=Off. Bits 6-0 = 0 | Must be cleared before attempting Writes |
| $80 | Write Seconds | Bit 7 = 0, Bits 6 - 4 = 10s of Seconds, Bits 3 - 0 = Seconds | Binary Coded Decimal |
| $82 | Write Minutes | Bit 7 = 0, Bits 6 - 4 = 10s of Minutes, Bits 3 - 0 = Seconds | Binary Coded Decimal |
| $84 | Write Hours (24) | Bit 7 - 6 = 0, Bits 5 - 4 = 10s of Hours, Bits 3 - 0 = Hours | Binary Coded Decimal |
| $86 | Write Date | Bit 7 - 6 = 0, Bits 5 - 4 = 10s of Date, Bits 3 - 0 = Day | Binary Coded Decimal |
| $88 | Write Month | Bit 7 - 5 = 0, Bit 4 = 10s of Month, Bits 3 - 0 = Month | Binary Coded Decimal |
| $8A | Write Day | Bit 7 - 3 = 0, Bits 2 - 0 = Day | Binary Coded Decimal |
| $8C | Write Year | Bit 7 - 4 = 10s of Years, Bits 3 - 0 = Years | Binary Coded Decimal |
| $C0 | Write PRAM Byte | Location $01 |  |
| $C2 | Write PRAM Byte | Location $02 |  |
| $C4 | Write PRAM Byte | Location $03 |  |
| .. | .. | .. | (increase Register +2) |
| $FC | Write PRAM Byte | Location $31 |  |
