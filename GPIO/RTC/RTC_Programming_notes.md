# DS1302 Clock, Calendar and PRAM notes for Programmers

The DS1302 register set presents sertain ambiguous choices, which this document seeks to clarify, as well as to document the format of the PRAM area.

## RTC Clock and Calendar

![DS1302 RTC egisters!](DS1302_RTC_Registers.png)

---
The TEC-1G supports both 12 and 24 hour time formats. The register layout makes this a lttle difficult to understand; this is how it works.

The hours are either 01..12 (12 hour) or 00..23 (24 hour).

Bit 7 of the hour register is a 1 if 12 hour mode is selected
bit 5 of the hour register is a 1 if it is PM (12 hour mode), or part of the hour (if 24 hour)
---
The Year register only supports 2 digits with value range of 00 too 99; hence only a 100 year span is available. This means that a 'base year' needs to be added to arrive at a Calendar year.

TEC-1G designers have determined that 2023 will be the bease year. Hence, **CalendarYear = 2023 + RTCYear**

| DS1302 Year | Calendar Year |
| :--: | :----: |
| 00 | 2023 |
| 01 | 2024 |
| 02 | 2025 |
| .. | .... |
| 99 | 2122 |

We wish future TEC-1G users all the best in resolving what happens in 2122 :)
---
The day of week register supports the range 1 to 7; as we know however the actual day that corresponds to any given date varies based on time zone. Therefore, the DS1302 simply incrmeents this value at midnight, but has no knolwege of timezones or what is 'correct'.

TEC-1G designers have followed ISO8601 which Defines Moday as the first day of the week. Therefore:

Day 1 = Monday
....
Day 7 = Sunday
---
