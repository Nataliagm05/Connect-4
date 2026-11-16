; Temp variables
temp_player: DB 0
temp_col: DB 0
temp_row: DB 0
temp_dx: DB 0
temp_dy: DB 0
temp_sd1n: DB 0
temp_sd2n: DB 0
keeps_iterating: DB 0
sd1n: DB 0
sd2n: DB 0
save_x: DB 0
save_y: DB 0


; ============================================

; CheckFullBoard: 
; Output: a = 1 if board is full, else 0
CheckFullBoard:
    ; save regs
    push de
    push hl
    push bc

    ld d, 0 ; counter
    ld e, 0
CheckSlotFull:
    call SlotPointer
    ld a, (hl)      ; load slot value
    cp 0
    jp z, EndLoopNotFullBoard   ; if empty slot is found then board is not full

    inc d           ; move one slot
    ld a, d
    cp xsize        ; if all slots are full then board is full
    jp nz, CheckSlotFull
    ld a, 1         ; FULL
    jp EndCheck

EndLoopNotFullBoard:
    ld a, 0         ; NOT FULL

EndCheck:
    pop bc
    pop hl
    pop de
    ret


; ============================================

; checkHorizontal
; Output: 1 if horizontal win exists, else 0
checkHorizontal:
    push bc
    push de
    push hl
    
    ; store parameters
    ld (temp_player), a
    ld a, d
    ld (temp_col), a
    ld a, e
    ld (temp_row), a
    
    ld b, 1                 ; count = 1
    
    ; Counting to the left
    ld a, (temp_col)
    dec a
    ld c, a

count_left:
    ld a, c
    cp 0
    jp m, count_right_start ; stop if column < 0
    
    ld d, c
    ld a, (temp_row)
    ld e, a
    call SlotPointer
    
    ld a, (hl)
    ld hl, temp_player
    cp (hl)                     ; if checkers different color:
    jr nz, count_right_start    ; jump to count_right_start
                                ; else:
    inc b                       ; inc counter
    dec c
    jr count_left

count_right_start:
    ld a, (temp_col)
    inc a
    ld c, a
;---------
count_right:
    ld a, c
    cp xsize
    jr nc, check_horizontal_result  ; Stop if out of boundery
    
    ld d, c
    ld a, (temp_row)
    ld e, a
    call SlotPointer
    
    ld a, (hl)
    ld hl, temp_player
    cp (hl)
    jr nz, check_horizontal_result
    
    inc b
    inc c
    jr count_right

check_horizontal_result:
    ld a, b
    cp winsize                  ; enough checkers in a row?
    jr nc, has_horizontal_win
    xor a                       ; no win
    jr horizontal_exit

has_horizontal_win:
    ld a, 1                     ; Win

horizontal_exit:
    pop hl
    pop de
    pop bc
    ret


; ============================================
; checkVertical
; Output: 1 if there is a vertical win, else 0
checkVertical:
    push bc
    push de
    push hl
    
    ; store parameters
    ld (temp_player), a
    ld a, d
    ld (temp_col), a
    ld a, e
    ld (temp_row), a
    
    ld b, 1                 ; count = 1
    
    ; Count upwards
    ld a, (temp_row)
    dec a
    ld c, a

count_up:
    ld a, c
    cp 0
    jp m, count_down_start
    
    ld a, (temp_col)
    ld d, a
    ld e, c
    call SlotPointer
    
    ld a, (hl)
    ld hl, temp_player
    cp (hl)
    jr nz, count_down_start
    
    inc b
    dec c
    jr count_up

;--------
count_down_start:
    ld a, (temp_row)
    inc a
    ld c, a

count_down:
    ld a, c
    cp ysize
    jr nc, check_vertical_result
    
    ld a, (temp_col)
    ld d, a
    ld e, c
    call SlotPointer
    
    ld a, (hl)
    ld hl, temp_player
    cp (hl)
    jr nz, check_vertical_result
    
    inc b
    inc c
    jr count_down

check_vertical_result:
    ld a, b
    cp winsize
    jr nc, has_vertical_win
    xor a           ; no win
    jr vertical_exit

has_vertical_win:
    ld a, 1     ; win

vertical_exit:
    pop hl
    pop de
    pop bc
    ret


; ============================================
; checkSemiDiagonal
; output: a = number of consecutive pieces on the diagonal
checkSemiDiagonal:
    push bc
    push de
    push hl
    
    ld (temp_player), a
    ld a, b
    ld (temp_dx), a
    ld a, c
    ld (temp_dy), a
    
    ld b, 0                 ; consecutiveCheckers = 0
    ld a, 1
    ld (keeps_iterating), a

semi_diag_loop:
    ld a, (keeps_iterating)
    cp 0
    jr z, semi_diag_end
    
    ; yDropPosition += DY
    ld a, (temp_dy)
    add a, e
    ld e, a
    
    ; xDropPosition += DX
    ld a, (temp_dx)
    add a, d
    ld d, a
    
    ; check yDropPosition >= 0
    ld a, e
    bit 7, a
    jr nz, set_false
    
    ; check yDropPosition < YSIZE
    cp ysize
    jr nc, set_false
    
    ; Check xDropPosition >= 0
    ld a, d
    bit 7, a
    jr nz, set_false
    
    ; Check xDropPosition < XSIZE
    cp xsize
    jr nc, set_false
    
    ; Check slot
    call SlotPointer
    ld a, (hl)
    ld hl, temp_player
    cp (hl)
    jr nz, set_false
    
    inc b       ; valid condecutive piece
    jr semi_diag_loop

set_false:
    xor a
    ld (keeps_iterating), a
    jr semi_diag_loop

semi_diag_end:
    ld a, b         ; return count
    
    pop hl
    pop de
    pop bc
    ret


; ============================================
; checkDiagonal
; checks diagonal from left (up) to right (down) (DX=1, DY=1)
checkDiagonal:
    push bc
    push de
    push hl
    
    ;save parameters
    ld (temp_player), a
    ld a, d
    ld (save_x), a
    ld a, e
    ld (save_y), a
    ld a, b
    ld (temp_dx), a
    ld a, c
    ld (temp_dy), a
    
    ; Direction 1: DX, DY
    ld a, (temp_player)
    call checkSemiDiagonal
    ld (sd1n), a
    
    ; Restore coordinates
    ld a, (save_x)
    ld d, a
    ld a, (save_y)
    ld e, a
    
    ; Direction 2: -DX, -DY
    ld a, (temp_dx)
    neg
    ld b, a
    ld a, (temp_dy)
    neg
    ld c, a
    
    ld a, (temp_player)
    call checkSemiDiagonal
    ld (sd2n), a
    
    ; return SD1N + SD2N + 1
    ld a, (sd1n)
    ld hl, sd2n
    add a, (hl)
    inc a
    
    pop hl
    pop de
    pop bc
    ret


; ============================================
; checkDiagonal2  
; checks diagonal from right (up) to left (down) (DX=1, DY=-1)
checkDiagonal2:
    push bc
    push de
    push hl

    ; save parameters    
    ld (temp_player), a
    ld a, d
    ld (temp_col), a
    ld a, e
    ld (temp_row), a
    
    ; Direction 1: DX=1, DY=-1
    ld b, 1
    ld c, 255
    ld a, (temp_player)
    call checkSemiDiagonal
    ld (temp_sd1n), a
    
    ; Restore coordinates
    ld a, (temp_col)
    ld d, a
    ld a, (temp_row)
    ld e, a
    
    ; Direction 2: DX=-1, DY=1
    ld b, 255
    ld c, 1
    ld a, (temp_player)
    call checkSemiDiagonal
    ld (temp_sd2n), a
    
    ; return SD1N + SD2N + 1
    ld a, (temp_sd1n)
    ld hl, temp_sd2n
    add a, (hl)
    inc a
    
    pop hl
    pop de
    pop bc
    ret


; ============================================
; checkWin
; uses checkHorizontal, checkVertical, checkDiagonal and checkDiagonal2 to check if there is any win condition satisfied.
; Output: a = 1 if there is a win
checkWin:
    push bc
    push de
    push hl

    ; save parameters
    ld (temp_player), a
    ld a, d
    ld (temp_col), a
    ld a, e
    ld (temp_row), a

    ; check HORIZONTAL
    ld a, (temp_col)
    ld d, a
    ld a, (temp_row)
    ld e, a
    ld a, (temp_player)
    call checkHorizontal
    cp 1
    jr z, win_found

    ; check VERTICAL
    ld a, (temp_col)
    ld d, a
    ld a, (temp_row)
    ld e, a
    ld a, (temp_player)
    call checkVertical
    cp 1
    jr z, win_found

    ; check DIAGONAL 1 (DX=1, DY=1)
    ld a, (temp_col)
    ld d, a
    ld a, (temp_row)
    ld e, a
    ld b, 1
    ld c, 1
    ld a, (temp_player)
    call checkDiagonal
    cp winsize
    jr nc, win_found

    ; check DIAGONAL 2 (DX=1, DY=-1)
    ld a, (temp_col)
    ld d, a
    ld a, (temp_row)
    ld e, a
    ld a, (temp_player)
    call checkDiagonal2
    cp winsize
    jr nc, win_found

    ; No win
    xor a
    jr win_exit

win_found:
    ld a, 1 ; win

win_exit:
    pop hl
    pop de
    pop bc
    ret