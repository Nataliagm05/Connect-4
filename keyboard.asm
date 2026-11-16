ReadKey:
; INPUT: D = player color
;        E = player number
; OUTPUT: A = -1 if left, 1 if right or 0 if dropped
; checks whose turn it is based on the color stored in register D,
; scans his keys, and waits for their release to return.
; returns -1 if key pressed means left
; returns  1 if key pressed means right
; returns  0 if key pressed means drop
; all register except for the accumulator are returned the same
    ; Check who is playing
    push bc
    ld a, d                  ; this has to be updated again because we will loop around this label
    cp colorplayer1          ; remembering a is currently the player's color
    jp z, scan_p1_keys      ; If player 1 -> check A/S/D keys
    jp scan_p2_keys        ; Else player 2 -> check I/O/P keys


;------------------------------------------------
scan_p1_keys:
; Defines the keys to read
    ld bc, p1_key_set

scan_p1_loop:
; Only scans keys and returns output depending on the keyboard input

    in a, (c)

    bit p1_left_bit, a                 ; Check key left
    jp z, wr_p1_left

    bit p1_drop_bit, a                 ; Check key drop
    jp z, wr_p1_drop

    bit p1_right_bit, a                ; Check key right
    jp z, wr_p1_right

    jp scan_p1_loop                    ; No input, keep looping


scan_p2_keys:
; Defines the keys to read
    ld bc, p2_key_set

scan_p2_loop:
; Only scans keys and returns output depending on the keyboard input

    in a, (c)

    bit p2_left_bit, a                 ; Check key left
    jp z, wr_p2_left

    bit p2_drop_bit, a                 ; Check key drop
    jp z, wr_p2_drop

    bit p2_right_bit, a                ; Check key right
    jp z, wr_p2_right

    jp scan_p2_loop                    ; No input, keep looping



;-------------------------------------------- wait realease labels:
wr_p1_left:
    in a, (c)
    bit p1_left_bit, a
    jr z, wr_p1_left   ; Wait while A pressed
    
    ld a, -1
    jr end_scan

wr_p1_drop:
    in a, (c)
    bit p1_drop_bit, a
    jr z, wr_p1_drop   ; Wait while A pressed
    
    ld a, 0
    jr end_scan

wr_p1_right:
    in a, (c)
    bit p1_right_bit, a
    jr z, wr_p1_right   ; Wait while D pressed
    
    ld a, 1
    jr end_scan

wr_p2_left:   
    in a, (c)
    bit p2_left_bit, a
    jr z, wr_p2_left   ; Wait while I pressed
    
    ld a, -1
    jr end_scan
    
wr_p2_drop:
    in a, (c)
    bit p2_drop_bit, a
    jr z, wr_p2_drop   ; Wait while I pressed
    
    ld a, 0
    jr end_scan

wr_p2_right:
    in a, (c)
    bit p2_right_bit, a
    jr z, wr_p2_right   ; Wait while P pressed
    
    ld a, 1
    ;jr end_scan Not necessary because end_scan is right beneath 

end_scan:
    pop bc
    ret
;================================ End scan keys function ======