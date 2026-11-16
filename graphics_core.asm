paint_board:
        push af
        push bc
        push de
        push hl

;Paint border
        ld a, border_color
        out($FE), a     ; Sets border color to constant color

;Paint columns
initVARcolumn:
        ld b, xoffset   ; saves xoffset in b
        ld c, yoffset   ; saves yoffset in c
        ld a, board_color     ; saves color in a
        ld d, ysize * 3 + 1     ; multiplies ysize by three and then adds one in order to get the 
                                ; number of vertical dots the board will measure

initLoopVarscolumn:
        ld h, xsize + 1   ; H will serve as a counter for the number of columns we shall draw

forLoopcolumn:
        call column     ; Draws a d lenght column from (b,c) using the column function

        ld e, A         ; Temporarily saves a on e because we will need a to perform an addition
        ld a, B         ; Loads b into a
        add 3           ; Adds 3 to get to the next columns coordinates. Note that we add 3 because 
                        ; our grid is designed to have two by two spaces so we have to jump not to 
                        ; the next dot, but two ahead of it

        ld b,A          ; Updates b to the new coordinate for the next column
        ld a, e         ; Restores a (the color) from where we stored it

        dec h                   ; Decreases the counter of columns since we finished painting it and 
                                ; setting next's columns variables
        jr nz, forLoopcolumn    ; Jumps back to the start of this loop until our counter (h) triggers 
                                ; the z flag

; Paint (horizontal) lines

; Set a, b, c and d to corresponding values 
initVARline:
        ld b, xoffset   ; saves xoffset in b
        ; ld c, yoffset would not be necessary
        ; ld a, color would not be necessary  
        ld d, xsize * 3 + 1     ; Sets d to the length of the horizontal lines required

initLoopVarsline:
        ld h, ysize+1           ; H will serve as a counter for the munber of rows we need

forLoopline:
        call line               ; Calls line to draw a line lenght d from (b,c) using line function

        ld e, A                 ; Uses e as a temporary storage for a
        ld a, c                 ; Loads c into a to add to it
        add 3                   ; Adds three, so now: a = c+3
        ld c,A                  ; Updates c to c + 3
        ld a, e                 ; Restores a

        dec h                   ; Decrement line counter
        jr nz, forLoopline      ; Jumps back to the start of this loop until zf is triggered

        pop hl
        pop de
        pop bc
        pop af

        ret

DrawAllGridCheckers:
    push af
    push bc
    push de
    push hl
    
    ld e, 0                         ; Start at row 0

draw_row_loop:
    ld d, 0                         ; start at column 0

draw_col_loop:

    call SlotFromBoard              ; Get checker info from board position (D, E)
    
    ; Only draw if slot is not empty (color != 0)
    cp 0
    jr z, skip_draw_checker
    
    ; Draw the checker
    call checker                    ; Uses B, C, A from SlotFromBoard

skip_draw_checker:
    ; Move to next column
    inc d
    ld a, d
    cp xsize                        ; Check if we've done all columns
    jr nz, draw_col_loop

    inc e                           ; Move to the next row
    ld a, e
    cp ysize                        ; Check if we've done all rows
    jr nz, draw_row_loop
    
    pop hl
    pop de
    pop bc
    pop af
    ret

SlotFromBoard:
    push hl
    push de

    call SlotPointer            ; HL points to Board[Y][X], x and y given in D and E
    ld a, (hl)                  ; A = board value (0, 1, or 2)
    
    
    ld hl, ColorList            ;hl = first value in ColorList, hl= 0
    ld d, 0                     
    ld e, a                     ; store in e the value of the board, this will be the color of the ckecker or black
    add hl, de                  ; HL = ColorList + value
    ld a, (hl)                  ; A = actual color

    pop de                      ; Restore D=X, E=Y
    push af                     ; Save color
    
    ld a, d                     ; A = column
    ld b, a                     ; B = screen X
    
    ld a, e                     ; A = row
    call getYFromRow            ; return in A the screen value of Y
    ld c, a                     ; C = screen Y
    
    pop af 
    pop hl
    ret
