board_color: EQU 9  
border_color: EQU 9          ; Color of the board and border

colorplayer1: EQU 2     ; player1 is red
colorplayer2: EQU 6     ; player2 is yellow

ColorList:
    DB 0                        ; Index 0 = empty (background, black)
    DB colorplayer1             ; Index 1 = player 1 (red)
    DB colorplayer2             ; Index 2 = player 2 (yellow)