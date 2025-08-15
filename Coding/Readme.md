# Development Options for the TEC-1G

If you are wanting to get the most out of your TEC-1G, then just playing with other people's software isn't all there is to it.

The whole purpose of the TEC-1, from it's inseption, was to be a "learning computer", that would teach the user how computers work, 
and how to take full control of them. Knowing how to put the hardware together is one part of the process, but learning how to 
program the TEC-1 is even more important, as it is with any computer system. Without software, the computer is just a hunk 
of metal and plastic that won't do anything.

## Common Terminology and Tools
1. Code Editor
2. Assembler
3. Serial Terminal Software

### Code Editor

You can use just about anything as your code editor, as Z80 Assembly language is nothing more than a text file but with a .Z80 or .ASM file extension. So you could, if you like to suffer, use Notepad or TextEdit or even Word... But there are much better alternatives out there and dispite Microsoft trying really hard to ruin it, VS Code is a preferred option amongst many coders in many programming languages.

### Assembler

This is where the options really broaden out and everyone will have a favourite and it will be the hill they die on! It also very much depends on which OS platfrom you are on, as most are not cross-platform and many only have Windows binaries, which is disapoiting.

In an effort to simplify and unify this piece of the puzzle, so that code that is released on this site can be compiled on any platform, we have chosen to standardise on using ASM80. This compiler can be used in any Internet Browser on any platform be visiting www.asm80.com
It has an integrated Code Editor as well, but it won't take you long to realise this is a slow and cumbersome way to develop code and upload it to the TEC-1G.

Thankfully the developer has released the assembler engine as a Node.js applicaiton which means that ANY platform shoud be able to install it and then use it from the command line. And this means it can be integrated into VS Code as a command line assembler that you can initiate with a single keystroke.

Please consider donating to the project so development can continue.

### Serial Terminal Software

This is yet another polarising piece of the puzzle with everyone having their favorites but in an effort to make it possible for the community to help each other, we have chosen to support CoolTerm because once again, it is available on all the major plaforms.

The Serial Terminal Software allows you to send and receive files to and from the TEC-1G via the USB cable connected to the FTDI module.


## Pick Your Poison

## Windows

## Linux

Download the VS Code binary from:  https://code.visualstudio.com/Download
Follow these instructions: https://code.visualstudio.com/docs/setup/linux
Which tell you to:
1. Go to Downloads folder and Right Click blank area and select "Open in Terminal"
2. Enter "sudo apt install ./<filename.deb>"  (Yes, you really do have to put in the dot and the slash)
3. It will ask you for your password. Enter it to complete the install.
4. Open the Mint Menu and type "VS" to find VS Code. Right Click and "Add to Panel" so it is easy to find and Start.
5. Once VS Code is installed and running, Add in the Extension: Z80 Macro-Assembler. This gives you coloured code highlighting and makes reading your code a lot easier.

![image](https://github.com/user-attachments/assets/f3a520eb-31c3-4731-83c4-f0cecf832b20)

Download CoolTerm from: https://www.freeware.the-meiers.org/
Extract All to the Downloads folder. Go into that folder and then "Open in Terminal"
Type in:  
sudo mkdir /usr/bin/CoolTerm   (you will be asked for your password)
sudo cp * /usr/bin/CoolTerm -r -f
Close the Terminal window. Browse to the folder /usr/bin/CoolTerm
Double click "coolterm" program
Dialogue box asking to set preferences comes up. Do so (I did) or select Defaults.
Once running, go to Mint Menu, type in "Cool". Right click on menu item and select "Add to Panel"

Install Node.JS - https://nodejs.org/en/download/package-manager
- installs nvm (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
- download and install Node.js (you may need to restart the terminal)
nvm install 20



## MacOS


Install Node.js:  
Visit: https://nodejs.org/en/download
You can try the manual installation instructions but the Prebuilt version simplifies the process. Simply select your platform and type of processor and then select the "MacOS Installer (.pkg)". This will download the installer to your Downloads folder. Double click on it to start the install process.
At the end it will pop up is message:
Make sure that /usr/local/bin is in your $PATH.












