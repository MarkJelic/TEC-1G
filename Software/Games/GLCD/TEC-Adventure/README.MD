# TEC Adventure

Z-Machine is a virtual machine that was developed by Infocom in 1979.
It plays games written in ZIL (Zork Implementation Language), which are
compiled into Story Files.  This is a Z-Machine port to be used on the
TEC-1G.

The aim of these Text Adventure Games is to move around a map using
Cardinal Directions (N, S, E, W), solve puzzles and win the game.

Included in this package are 14 Text Adventure Games that can be played
either on a Serial Terminal or using the TEC-1G GLCD Screen and Matrix
Keyboard.

## REQUIREMENTS
    MON3 V1.6 (Monitor 3)
    SD / PATA Drive Add-On Board.
    Expansion Memory.  At least 16kb in the Expansion Slot (62256 32k RAM)
Game Play:
    FTDI to USB Connection to your laptop/computer
    Serial Terminal. (I use Coolterm)
Or:
    GLCD Screen and Matrix Keyboard

## HOW TO PLAY THE GAMES

1. Copy all TECADVnn.DAT files and TECADV.hex files to the Micro SD Card or 
PATA Drive.

2. From the MON3 Main MENU, Select "Drive Access" and "Catalog".  Then select
TECADV.HEX.  This will load the Z-Engine code into the TEC-1G.

3. Enter Data Entry mode by pressing 'AD', then Goto Address 0x2000
Press 'AD' and 2000.  Then Press 'GO'

4. Select the Input/Output.  Either the GLCD and Matrix Keyboard, or Serial
Terminal.  If using a Serial Terminal, connect your computer/laptop to the 
FTDI to USB adaptor and run a Serial Terminal.

5. Select the Game to play.  The games that can be played are:

    Zork 1, Zork 2 and Zork 3<br>
    Enchanter, Sorcerer and Spellbreaker<br>
    Planetfall and Stationfall<br>
    Deadline<br>
    Hitchhikers Guide to the Galaxy<br>
    Hollywood Hijinx<br>
    Infidel<br>
    Leather Goddesses of Phobos<br>
    Suspended<br>

## NOTES

The games require access to the SD/PATA drive, this makes the game speed is
slower but still playable.  As the GLCD screen is small, to make the games
text load quicker, use the 'SUPERBRIEF' command to get shorter responses.

Movement commands can be combined in one line separated by commas or full
stop.  IE: N,N,W,W,E or S.S.E.E.D

To Pick up or drop items, the word ALL can be used, IE: GET ALL.  Also to
get ALL items except use, GET ALL BUT <items>

The Z-Engine is smart with words, it will understand flowing commands like,
PUT THE SATCHEL IN FRONT OF THE PANEL.

There is no ability to SAVE or RESTORE the games.  Sorry!.  Some games have
random things happening which might need a RESTORE. :{

Included are Command Only Walkthroughs for each game.  Feel free to use these
files to play the games.

BASIC COMMANDS
--------------
N, S, E, W, IN, OUT, UP, DOWN<br>
GET, DROP, USE, INVENTORY or I, WAIT or Z, AGAIN or G, LOOK or L<br>
TIME, SCORE, QUIT, RESTART<br>

SPECIAL COMMANDS
----------------
Below are explanations for a number of useful one-word commands. In many 
cases, these will not count as a turn. Type the command after the prompt (>) 
and press the RETURN (or ENTER) key. 

AGAIN - This will repeat your previous input. For instance, typing SHOOT 
THE LASER AT THE RADIUM-POWERED ROBOT then typing AGAIN would be like 
trying to kill the robot twice in a row. You can abbreviate AGAIN to G. 

BRIEF - This command tells the game to fully describe a location only 
the first time you enter it. On subsequent visits, the game will tell 
you only the name of the location and any objects present. The game 
will begin in BRIEF mode, and remain in BRIEF mode unless you use the 
VERBOSE or SUPERBRIEF commands. SUPERBRIEF tells the game to display 
only the name of a place you have entered, even if you have never been 
there before. In this mode, the game will not even mention which objects are 
present. Of course, you can always get a full description of your location and 
the items there by typing LOOK. In SUPERBRIEF mode, the blank line 
between turns will be eliminated. This mode is meant for players who are 
already familiar with the geography. The VERBOSE command tells 
the game that you want a complete description of each location, and the 
objects in it, every time you enter a location, even if you''ve been there 
before. 

DIAGNOSE - Will give you a report of your physical condition. 

INVENTORY - Will list what you are carrying and wearing. You can 
abbreviate INVENTORY to I. 

LOOK - This will give you a full description of your location. You can 
abbreviate LOOK to L. 

OOPS - If you mistype a word, such that the game doesn''t understand it, 
you can correct yourself at the next prompt by typing OOPS and the correct 
word. For example, if you typed HAND THE CHAIN SAW TO GARNDMA and were 
told "[I don't know the word 'garndma']" you could type OOPS GRANDMA rather than 
retyping the entire sentence. 

QUIT - This lets you stop. If you want to save your position before quitting, 
follow the instructions in the "Starting and Stopping" section on page 8. You 
can abbreviate QUIT to Q. 

RESTART - This stops the story and starts it over from the beginning. 

STATUS - This command gives you the following information: your current 
mode of descriptiveness, your score, a ranking based on that score, and the 
current time in the story. Note that your score and the time can also be found on 
your status line at the top of the screen. 

SUPERBRIEF - This command tells the game to give you the sparest level 
of description. See BRIEF above. 

TIME - This will give you the current time in the story. 

VERBOSE - This command tells the game to give you the wordiest 
level of description. See BRIEF above. 

VERSION - responds by showing you the release number and 
the serial number of your copy of the story. Please include this information if 
you ever report a ""bug"" in the story. 

WAIT - This causes time in the story to pass. Since nothing happens until you 
type a sentence and press RETURN (or ENTER), you could leave your 
computer, take a trip to Rigel Seven, then return to the story to find that 
nothing has changed. You can use WAIT to make time pass in the story without 
doing anything. For example, if you met an alien robot, you might WAIT to 
see if it will say anything; if you were aboard a moving space scooter, you 
might WAIT to see where it goes. You can abbreviate WAIT to Z. 
