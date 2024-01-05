# SD Card Support for TEC-1G

This folder contains SD card support code.

Initial dev is based on using the SPI2C card, until the real hardware is ready. Code is based on the schematic of proposed board.

Initial code performs the following functions:

- Initialises hardware; places SD card into SPI mode
- Issuses card reset sequence
  - CMD0
  - CMD8
  - ACMD41
- Reads card CID and CSD
  - CMD58
  - CMD10
  - CMD9
- Displays card information; size is read only if a type 02 card -> modern SDHC cards are typically all type 02.
- Reads block 0 (512 bytes) into TEC memory at 1000h
  - CMD17

More to come.

-----

## SPI SD Card Programming

### SPI Commands
Each SD command consists of 6 bytes; \<command\> \<data\> \<data\> \<data\> \<data\> \<CRC7 checksum\>

The command byte is always  `01XXXXXX` where X is the command number (00..3F)

The commands are called CMD0 thru CMD59 (and are numbered in decimal). There are also advanced commands called ACMD. To issue an ACMD, first issue CMD55. The CMD55 simply tells the SD that an ACMD is following next.

The CRC7 checksum is only used during initial setup when in SPI mode. Once setup, commands only need to set checksum bit 0, to `1`. Hence, there is no need for a CRC7 routine -- the few commands we need a CRC for, we can hard code into our program as the command fields are fixed.

Note the whole command packet always starts with a `0` bit and ends with a `1` bit

The \<data\> fields are comand-specific - see SD specs for spcifics.

> Not all SD commands work in SPI mode; see the specs documentation for valid commands.

### SPI Command Responses
Each command returns between one and 5 bytes of response data. This is returned before any other data the comnmand may request. i.e. it is the status of the comand itself. The responses are called result types R1 thru R7.

#### Result Types 
- R1 - 1 byte
- R1b - A per R1, then zero or more 00 bytes; keep reading until a nonzero value is read.
- R2 - 2 bytes
- R3 - 5 bytes
- R4, R5, R6 (not used in SPI mode)
- R7 - 5 bytes

All error codes return R1 as their first byte.

#### R1
After initial setup, Result R1 should normally aways come back as 00h. A nonzero result indicates an error condition. R1 bits are defined as follows:

````
bit 0 - in idle (not initialised) state
bit 1 - erase reset
bit 2 - illegal command
bit 3 - com crc error
bit 4 - erase sequence error
bit 5 - address error
bit 6 - parameter error
bit 7 - 0
````

### SPI Blocks
When reading blocks of data with SPI Block commands eg CMD17, each block is framed as follows:

\<1 byte : Start Marker : Always $FE\> \<n bytes of data\> \<2 bytes : CRC16 checksum\>

Hence, if the specs say a data block returns 16 bytes, there are actually 19 bytes returned.
-----
## SPI port bits out
````
bit 0 - MOSI
bit 1 - CLK
bit 2 - CS1
````
## SPI port bits in
````
SPI2C
bit 3 - MISO

IO SD Card
bit 7 - MISO
````
