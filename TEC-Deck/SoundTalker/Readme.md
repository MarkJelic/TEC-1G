# SoundTalker Audio Card

- SN76489 Sound Geberator
- SP0256A-AL2 Speech Processor
- Mix in standard TEC-1 Bit-Banged sounds
- Using LM3900 Op Amp
- 4 Layer board 

This is the Schematic: ![TEC-Deck SoundTalker Schematic](TEC-Deck_SoundTalker_Schematic.pdf)

This is Beta 2, using a LM3900 for pre-amp/mixer and amplifier:
![TEC-Deck SoundTalker LM3900](TEC-Deck_SoundTalker_PCB-Render_b2-LM3900.jpg)

These are are the Back (in Green) and Front (in Red) copper layers.

![TEC-Deck SoundTalker Back+Front](SoundTalker-PCB_Back(G)+Front(R)_Layers.png)

This is the second layer (the inner layer, closest to the back layer) and is used as the Ground plane. It also runs the source traces from each sound source, so that they are effectively shielded aby copper on all four sides.

![TEC-Deck SoundTalker Layer 2](SoundTalker-PCB_Layer2_GND-(Near_Back).png)

The is the third layer (Inner layer, closer to the front of the board) and this runs the 5v plane. Note the split. Both are the same 5v source from the main motherboard, but the left hand (audio) side has an additional 10uH inductor to further smooth the 5v for the amplifier section.

![TEC-Deck SoundTalker Layer 3](SoundTalker-PCB_Layer3_5V-(Near_Front).png)
