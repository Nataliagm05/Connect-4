; This file contains some of the game mechanics of a Connect Four game

start_game:

game_loop:

    ; ==Player 1's turn
game_loop_player_1
    ld d, colorplayer1 ; Load player 1 color
    ld e, 1
    call turn_player ; Execute player 1 turn


    ; ==Player 2's turn
game_loop_player_2
    ld d, colorplayer2 ; Load player 2 color
    ld e, 2
    call turn_player ; Execute player 2 turn


    jp game_loop ; Repeat forever (game loop)

    ret ; Return (never reached untill win conditions are set)





; ============================ turn player function =======
turn_player:
; Input: 
;   D = current player color
; Loop vars:
;   B = grid column

    ; ==Draw initial checker
    ld a, d ; load color into a
    ld c, yoffset-3 ; Base Y position         
    call getXcentered   ; Get center column into B, B = center column
    call checker
input_loop:
    ; a is color ; b is grid coordinate ; d is color

    ; ==Wait for player input:
    call ReadKey ; will produce an output on acumulator
                 ; output: -1 (move left), 0 (drop) or 1 (move right)
    push de
    ld e, a ; save the keyboard input in e because we need a to erase the old checker

    ; == Erase checker
    ; we would erase the cheker either way if its drop or move
    ld a,0
    call checker


    ld a, e ; return the keyboard input to a from e

    ; ==Check if it is drop, and if it is, calls function DropChecker, 
    ; == if it's not, jump to check where the checker is moving.
    cp 0
    jp nz, not_drop

    pop de
    call DropChecker ; will drop the checker to the first empty space in
                     ; the column, if it's full, a message appears.
    ret

not_drop:
    pop de

    ; ==Else: move checker protocol

    ; ==Calculate new position
    add B   ; A = -1 or +1 depending on the input, so A + B will be the column we moved to

    ; ==if exceeded borders --> we dont update
    ; if new position is 0, we will not update position 
    cp $FF
    jr z, paint_new

    ; if  new position is too far to the right we will not update position
    cp xsize
    jr z, paint_new

    ; else, position is valid --> update position
    ld b, a

    ; ==draw new checker
paint_new:
; Input:
; d = color
; b = new grid position
    ld a,d
    call checker
    jr input_loop




; =============================

; ============= Column position calculator ============
getXFromColumn:
; INPUT:
;   A = column number
; OUTPUT:
;   A = x coordinates on the screen for the desired column
    push bc
    ld b, a             
    add b
    add b
    add xoffset              
    inc a ; X coordinate = 3*column index + xoffset + 1 
    pop bc
    ret

getXcentered:
; OUTPUT:
;   B = middle column number
    push af ; we save the value of the acumulator to use it for opaerations

    ld a, xsize ; Get total columns
    sra a ; Divide by 2 (center column)
    ld b,a ; b = a

    pop af ; we restore the acumulator's saved value

    ret

getYFromRow: ; A = y coordinates on the screen for the desired row
    push bc
    ld b, a
    add a
    add b
    add yoffset
    inc a ; X coordinate = 3*row index + yoffset + 1 
    pop bc
    ret

Mul8bit:
    push de
    xor a  ; a = 0

MulLoop:
    add e ; A = A+E
    dec d
    jr nz, MulLoop ; repeat D times until D=0

    pop de

    ret

SlotPointer:
    push af
    push bc
    push de

    ld d, xsize ; D = XSize
    call Mul8bit ; A = Y * XSize
    
    pop de ; Restore X, Y
    add a, d ; A = (Y * XSize) + X
    push de

    ld hl, Board ; add to the board memory location A, to find [x][y] value
    ld d, 0
    ld e, a
    add hl, de

    pop de
    pop bc
    pop af
    ret


FindTargetY:
; INPUT:
;   B = column index
; OUTPUT:
;   (IY+2) = y row where checker can drop. -1 if column is full.
        push de
        push hl
        push bc

        ld d, b
        ld e, ysize-1 ; start from bottom.
CheckSlot:  
        call SlotPointer
        ld a, (hl) ; read slot from Board, if 0, target found
        cp 0
        jr z, EndLoopFull
        dec e 
        jp p, CheckSlot
        ld a, -1 ; if column full a = -1
        ld (IY+2),a
        jr EndCheckTargetY

EndLoopFull:
        ld (IY+2), e ; position of the empty slot in the column

EndCheckTargetY:
        pop bc
        pop hl
        pop de
        ret

DropChecker:
    push af
    push bc
    push hl
    push de

 
        ld c, d ; save player color
        ld d, b ; D = column
        call FindTargetY ; find empty slot in the column
        push hl
        push de
        ld e, (IY+2) ; E = targetY
        ld a,E
        cp -1 ; if targetY = -1, drop can't happen
        pop de
        jr z, NoDrop
        ld b, D ; otherwise, obtains y coordinates to drop the checker
        call getYFromRow

        ld c,A ; C = y coordinates
        ld a, e ; A = CurrentPlayer (1 o 2)
        ld hl, ColorList
        push de
        ld d, 0
        ld e, a ; DE = player number
        add hl, de ; HL  ColorList[player]
        ld a, (hl) ; A = real color
        pop de
        push bc
        call checker ; paint new checker 
        pop bc

        ld a, e

        pop hl
        ld e, (IY+2)
        call SlotPointer ; point where the drop has happened
        
        ld (hl),a ; puts the number of the current player on Board
        ld b, a
        call checkWin
        cp 1
        jr z, PlayerWins
        call CheckFullBoard
        cp 1
        jr z, Tie
        jr EndLoopDrop

PlayerWins:
    ld a, B
    cp 1
    jp z, Player1Wins
    jp Player2Wins

Player1Wins:
    call WinPlayer1
    jr FinalScreen
Player2Wins:
    call WinPlayer2 
    jr FinalScreen  
Tie:
    call TieEnd
    jr FinalScreen

NoDrop:
        ld a,c ; check what player is playing
        cp colorplayer1
        call NoDropAdvise ; show the "can't drop" message
        jp z, game_loop_player_1 ; if player 1 was unable to drop, it plays again.
        jp game_loop_player_2 ; same for player 2



EndLoopDrop:
    pop de
    pop hl
    pop bc
    pop af
        ret

WinPlayer1:
    ld a, colorplayer1
    out($FE), a     ; Sets border color to constant color
    push ix
    push bc
    ld ix, winplayer1
    ld b, 1
    ld c, 7
    call PRINTAT
    pop bc
    pop ix
    ret
WinPlayer2:
    ld a, colorplayer2
    out($FE), a     ; Sets border color to constant color
    push ix
    push bc
    ld ix, winplayer2
    ld b, 1
    ld c, 7
    call PRINTAT
    pop bc
    pop ix
    ret
TieEnd:
    push ix
    push bc
    ld ix, tie
    ld b, 1
    ld c, 7
    call PRINTAT
    pop bc
    pop ix
    ret

FinalScreen: jr FinalScreen