# SD Card File System Structure - TEC-FS

The TEC-FS disk format / file system is proprietory to the TEC and not compatible with FAT or CP/M. This was done for simplicity and efficiency; it is very complex to implement a full file system; this "minimal" system TEC-FS is more than adequate for normal use in saving, loading and managing files.

The file system will work on any "block" type device that supports 512 byte sectors. The initial implementation has been built around SD cards, however there is no reason that CompactFlash could not also work, for example. We will use the term "SD Card" here, but any block device applies equally.

The file system requires around 8 megabytes of total storage -- modern SD Cards of course hold many gigabytes; therefore most of the card's space is "unused".

Note: This code is written for "type 02" or SDHC cards. Using very, very old SD cards (<2Gb) is not supported. A 16Gb SD card can be purchased for around ten to fifteen dollars. Attempting to support older cards simply does not make good sense.

## Basic Features
- Supports up to 128 files per SD card
- Any file length (up to maximum supported)
- Maximum of 64k in any single file
- Can save & load any contiguous area of TEC memory
- up to 20 character filenames
- Files are date/timestamped (future feature, requires GPIO RTC card)

## Disk Structure
The disk structure is designed to keep minimal compatability with windows computers, such that if the SD Card is plugged into a PC, nothing "bad" will happen to either the PC or the data. At this stage, inserting the SD card will prompt Windows to format the SD - simply choose cancel.

Files are also stored (starting) at fixed sector locations. This makes the need for a PC style FAT not necessary - it is not as efficient, but as noted earlier we are using only a tiny percentage of available space, in any case.

| Sector  | Purpose  |
| ------- | -------- |
| 0       | MBR      |
| 63      | not used |
| 64..79  | FCB      |
| 80..127 | not used |
| 128     | file #1  |
| 256     | file #2  |
| 384     | file #3  |
| 512     | File n   |

## MBR Structure
The signature is used to verify that the SD Card is formatted to suit TEC-1G/MON3.

| offset | length | Field              | Type   | Value    |
| ------ | ------ | ------------------ | ------ | -------- |
| 0      | 6      | signature          | string | "TEC-1G" |
| 6      | 20     | volume label       | ASCIIZ | "SD Card Storage 000",0 |
| 26     | 7      | date & time        | DS1302 | 00,00,01,01,01,01,00 |
| 33     | 1      | filename sectors   | binary | 16 |
| 34     | 412    | spare              | binary | all 00   |
| 446    | 64     | partiton table     | binary | all 00   |
| 510    | 2      | signature          | binary | 55 AA    |
|        | 512    | total bytes        |        |          |

## FCB Structure
An FCB is a File Control Block - used to keep track of each file's attributes.

A start address of FFFF indicates the file is not in use.

Table Version is to be incremented as new FCB parameters are added, so future software can identify the save version accordingly.

The expand byte is for future use - indicates if the EXPAND memory is what has been saved. An Expand save would be 32k; TEC bank 2/Expand=0 followed by TEC bank 2/Expand=1

| offset | length | File FCB entry   | Type   | Value               |
| ------ | ------ | ---------------- | ------ | ------------------- |
| 0      | 20     | Filename         | ASCIIZ | "FILE NUMBER 0000000",0 |
| 20     | 2      | start address    | binary | FFFFh               |
| 22     | 2      | length           | binary | 0000h               |
| 24     | 1      | expand           | binary | 0                   |
| 25     | 7      | date & time      | DS1302 | 00,00,01,01,01,01,00 |
| 32     | 4      | start SD Sector  | binary | 00000000            |
| 36     | 2      | \# of SD Sectors | binary | 0000                |
| 38     | 25     | spare            | binary | all 00              |
| 63     | 1      | table version    | binary | 00                  |
|        | 64     | total bytes      |        |                     |

## The Math
512 bytes per sector - SD Cards (and virtually all block based storage media) all support this sector size by default.

1 MBR sector

64 bytes per FCB Entry; 512/64 = 8 FCBs per sector

128 files per device

128/8 = 16 FCB sectors required

64k per file (maximum)

64k/512 = 128 sectors per file (maximum)

63+48=111 spare sectors

total storage capacity required: 1 + 63 + 16 + 48 + (128*128) = 16512 sectors needed

** just over 8Mb of space required **

