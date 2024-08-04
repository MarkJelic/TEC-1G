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



### Pick Your Poison

## Windows

## Linux
1.Download the VS Code binary from:  https://code.visualstudio.com/Download
Follow these instructions: https://code.visualstudio.com/docs/setup/linux
Which tell you to:
1.Go to Downloads folder and Right Click blank area and select "Open in Terminal"
2. Enter "sudo apt install ./<filename.deb>"  (Yes, you really do have to put in the dot and the slash)
3. It will ask you for your password
4. Open the Mint Menu and type "VS" to find VS Code. Right Click and "Add to Panel"
Add in the Extension: Z80 Macro-Assembler
![image](https://github.com/user-attachments/assets/f3a520eb-31c3-4731-83c4-f0cecf832b20)


Download CoolTerm from: https://www.freeware.the-meiers.org/
Extract All to the Downloads folder. Go into that folder and then "Open in Terminal"
Type in:  
sudo mkdir /usr/bin/CoolTerm   (you will be asked for your password)
sudo cp * /usr/bin/CoolTerm -r -f
Close the Terminal window. Browse to the folser /usr/bin/CoolTerm
Double click "coolterm" program
Dialogue box asking to set preferences comes up. Do so (I did) or select Defaults.
Once running, go to Mint Menu, type in "Cool". Right click on menu item and select "Add to Panel"

Install Node.JS - https://nodejs.org/en/download/package-manager
- installs nvm (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
- download and install Node.js (you may need to restart the terminal)
nvm install 20



## MacOS
