        DEVICE ZXSPECTRUM48
	SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION
        org $8000               ; Program is located from memory address $8000 = 32768

begin:          di              ; Disable Interrupts
                ld sp,0         ; Set stack pointer to top of ram (RAMTOP)

;-------------------------------------------------------------------------------------------------
; Before starting, the color of each player can be changed by changing colorplayer1 
; and colorplayer2 values in colors.asm
; Also, this game can be played with other winning conditions (N-in a row) and board sizes.
; This can be changed by modifying winsize, xsize and ysize values in game_variables.asm. 
; xoffset and y offset can be modified there too.

; Board building algorithm, includes basic_gfx.asm
        ld IY, GAMEVARS
mainloop:
        call paint_board

        call start_game


;-------------------------------------------------------------------------------------------------
endofcode:      jr endofcode    ; Infinite loop
Board: defs xsize*ysize,0

        ; Visual includes:
        include "graphics_basic.asm"            ; Inludes basic graphics functions
        include "graphics_core.asm"             ; Includes specific graphic functions for the game
        include "colors.asm"                    ; Includes constants that determine all the colors on screen
        include "TextDemo.asm"


        ; Game mechanic includes:
        include "game_variables.asm"            ; Includes game variables for board size, offset, etc
        include "keyboard.asm"               ; Includes the functions needed to read the keyboard input
        include "game_logic_flow.asm"           ; Includes the intruction or function flow
        include "logic_checks.asm"       ; Includes the checker handling logic.

