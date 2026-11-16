xsize: EQU 7            ; number of columns for the board
ysize: EQU 6           ; Number of rows for the bord
xoffset: EQU 1          ; Distance from the left border
yoffset: EQU 4          ; Distance from the top border

winsize: EQU 4           ; number of connected checkers needed to win
win_player: DB 0
win_x: DB 0
win_y: DB 0
line_count: DB 0


p1_key_set: EQU $FDFE   ; Player 1 key set and its bits of each key
p1_left_bit: EQU 0
p1_drop_bit: EQU 1
p1_right_bit: EQU 2

p2_key_set: EQU $DFFE   ; Player 2 key set and its bits of each key
p2_left_bit: EQU 2
p2_drop_bit: EQU 1
p2_right_bit: EQU 0

GAMEVARS:               ; Other variables
CurrentPlayer: DB 1
CurrentXSlot: DB 1
TargetY: DB ysize-1