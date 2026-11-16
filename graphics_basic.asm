

dotXYC: ; takes two coordinates x and y and paints a
        ; dot on the atribute corresponding to those coordinates of color c. 
        ; B = X, C = Y, A = Color.

    push af     ; Saves af
    push bc     ; saves bc
    push de     ; saves de
    push hl     ; saves hl

    ; 1.- Calculate position in hl register: hl =  32*Y + X + $5800

    ld l,c      ; L = Y, l is the least significant bit part of hl
    ld h, 0     ; now hl = Y

    ; It is more eficient to do a "unwound loop" (bucle desenrollado)
    ; than to make a actual loop
    add hl,hl   ; hl_1 = hl + hl = 2*hl
    add hl,hl   ; hl_2 = 2hl + 2hl = 4hl
    add hl,hl   ; hl_3 = 4hl + 4hl = 8hl
    add hl,hl   ; hl_4 = 8hl + 8hl = 16hl
    add hl,hl   ; hl_5 = 16hl + 16hl = 32hl
    
    ; now hl = Y*32, so we need to add $5800 and X:
    ld de, $5800    ; de = $5800
    add hl, de      ; hl = 32*  Y + $5800

    ld e, b         ; we only need one reg to make e = X (b=X)
    ld d, $00       ; we reset d reg to 00 so we dont add 58 (previous value)
    add hl, de      ; hl = 32*Y + $5800 + X

    ; now that we have the coordinates decoded, lets paint the dot:
    ; For that first we need to move the value of the color to its 
    ; corresponding position:

    ; a = Color, so to get Color * 8 we do:
    add a           ; a_1 =  a  + a = 2a = Color *2
    add a           ; a_2 = 2a + 2a = 4a = Color *4 
    add a           ; a_3 = 4a + 4a = 8a = Color *8

    ; Now we set the atribute of the register corresponding to the
    ; given coordinates to the color after moving it left thrice so 
    ; as to get the intended result.

    ld (hl),a

    ; Now that the function is finished we return all the registers
    ; and flags unmodified.
    pop hl
    pop de
    pop bc
    pop af

    ret

line: ; line funciton will draw a horizantal line of color atributes.
; inputs:   B = X (x starting coordinate)
;           C = Y (y starting coordinate)
;           A = Color
;           D = desired line lenght
    ; We save the register values pushing them into the stack:
    push af     ; saves af (a and flags)
    push bc     ; saves bc
    push hl     ; saves hl
    push de     ; saves de
; Now we strart a loop to draw "d" dots
lineloop:
    call dotXYC ; Draws the dot on (x=b,y=c) with color a
    inc b       ; Increments b to prepare move the x coordinate one step.
    ; Conditional part to check if the loop should end:
    dec d       ; Decrements d
    jr nz, lineloop ; if the zero flag has not been raised, then the loop 
                    ; makes another iteration. Meaning, it will iterate 
                    ; while d > 0.
    ; Restore registers:
    pop de
    pop hl
    pop bc
    pop af

    ret

column: ; columns function will draw a vertical line of color atributes.
; inputs:   B = X (x starting coordinate)
;           C = Y (y starting coordinate)
;           A = Color
;           D = desired columns lenght
    push af     ; saves af
    push bc     ; saves bc
    push de     ; saves de
    push hl     ; saves hl

; Start the loop:
columnloop:
    call dotXYC ; draw dot on (x=b,y=c) color = c

    inc c       ; Increments c (y axis) to draw the next dot under the previous one
    dec d       ; decrements counter
    jr nz, columnloop   ; Jumps back to columnloop as long as d>0

    ; restore registers
    pop hl      ; restores hl
    pop de      ; restores de
    pop bc      ; restores bc
    pop af      ; restores af

    ret

checker: 
; INPUT:
; A is the color of the checker
; B is the column with wich we want the checker to align
    push af
    push bc
    push de
    push hl

    ld d, a
    ld a, b
    call getXFromColumn      ; Calculate X position
    
    ld b, a
    ld a, d

    call dotXYC              ; Draw checker dots (square shape)
    inc b
    call dotXYC
    inc c
    call dotXYC
    dec b
    call dotXYC

    pop hl
    pop de
    pop bc
    pop af
    ret

Delay: ; this delay is used for "can't drop" message.
    push bc
    ld b,255
delay_loop:
    djnz delay_loop
    pop bc
    ret