NoDropAdvise:
        push af
        push bc
        push ix
                ; FIRST EXAMPLE - Print a text
                ;--------------------------------------------------
                ld b, 0        ; Row in register B
                ld c, 0         ; Column in register C
                ld a, %01001101 ; Color in register A (Full 8-bit attributes: Flash, Brightness, Paper(3), Ink (3))
                ld ix, myText   ; Text, ending with 0, pointed to by IX
                call PRINTAT    ; Function to print text
                ld ix, eraseText
                ld a, %00000000
                ld b,255
DelayLoop:
                call Delay
                call Delay
                djnz DelayLoop
                ld b, 0
                call PRINTAT
        pop ix
        pop bc
        pop af

        ret         ; end of program infinite loop
    
    include "text.asm"         ; Library for text printing
                               ; Including the pixelwise definition for all characters (96 ASCII chars, from 32 (space) onwards)
                               ; Right after this include, you may add custom chars as per the two shown below.
                               ; Use the attached excel file to define these bytes easily 
brick:          defb $FF, $01, $01, $81, $FF, $10, $10, $18; Brick pixel definition, defined as the next char: char 128
smiley:         defb $3C, $42, $A5, $81, $99, $A5, $42, $3C; Smiley pixel definition, defined as the next char: char 129
                ; How to make a custom char: Shown, for readabilty sake, as a "." representing a 0, and a "@" representing a 1
                ; Smiley Example
                ; $3C --> 00111100  --> ..@@@@..
                ; $42 --> 01000010  --> .@....@.
                ; $A5 --> 10100101  --> @.@..@.@
                ; $81 --> 10000001  --> @......@
                ; $A5 --> 10100101  --> @.@..@.@
                ; $99 --> 10011001  --> @..@@..@
                ; $42 --> 01000010  --> .@....@.
                ; $3C --> 00111100  --> ..@@@@..


myText:         defm "   ", 129, " Can't Drop. Try Again. ",129,"   ",0
eraseText: defm "                                ",0
winplayer1: defm " Player 1 Wins ",0
winplayer2: defm " Player 2 Wins ",0
tie: defm " Full Board. Tie ",0


