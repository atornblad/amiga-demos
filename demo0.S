USE_MATH    EQU         1

            INCLUDE     "startup.S"
            INCLUDE     "demo0init.S"
            INCLUDE     "demo0exit.S"
            ;INCLUDE     "demo0part1.S"
            INCLUDE     "demo0part2.S"
            INCLUDE     "algomusic.S"

******************************************************************
*** MAIN
******************************************************************

            SECTION code, CODE

demomain:   move.w  #$83c1, DMACON(a6)  ; Enable some DMA: audio, blitter, copper, bitplane, not disk or sprite
demopart:   move.l  partptr, a4         ; Get the init jump address of the current part section
            move.l  (a4), d0
            tst.l   d0                  ; Is it null?
            bne.s   .initpart           ; If not null, jump to it
            rts                         ; But if null, exit the whole demo!
.initpart:  move.l  d0, a3              ; Move to an address register so that we can jump to it
            move.l  a4, -(sp)           ; Store the part section pointer
            jsr     (a3)                ; Jump to the demo part init subroutine
            move.l  (sp)+, a4           ; Pull the part section pointer

demoloop:   jsr     wait136             ; Wait for raster line $136 (end of screen) (a4 not destroyed)
            move.l  a4, -(sp)           ; Store the part section pointer
            jsr     musictick           ; Do music
            move.l  (sp), a4            ; Restore a4, just in case
            addq.l  #4, a4              ; Move a4 forward to the next jump pointer (current part loop subroutine)
            move.l  (a4), a4            ; Get the loop jump address of the current part section
            jsr     (a4)                ; Jump to it
            move.l  (sp)+, a4           ; Pull the part section pointer
            tst.w   d0                  ; Does the part main loop code want to skip to the next section?
            bne.s   .endpart            ; If so, skip the click detection

            ; Exit loop on a full click
            tst.w   btn_state           ; Check latest state of button
            bne.s   .clicking           ; If pressed: go to check if released
            btst    #6, $bfe001         ; Check mouse button state
            bne     demoloop            ; If not pressed, loop
            addq.w  #1, btn_state       ; Set state to pressed
            bra     demoloop            ; Keep looping
.clicking   btst    #6, $bfe001         ; Check mouse button state
            beq     demoloop            ; If still pressed, loop
.endpart    ;move.l  partptr, d0         ; Step forward 8 bytes (two pointers)
            clr.w   btn_state
            addq.l  #8, partptr
            ;move.l  d0, partptr
            bra.s   demopart            ; And go back up to demopart, so that we can call the init


null_loop:  clr.w   d0                  ; This is a "do nothing" demo loop, only music is running
            rts

no_loop:    moveq.l #1, d0              ; This is an "exit immediately" demo loop
            rts

            SECTION vars_initialized, DATA

btn_state:  dc.w    0
partptr:    dc.l    parts

parts:      dc.l    musicinit, no_loop    ; For initialization of music (and testing)
            ;dc.l    p1init, p1loop      ; This is just for experimentation
            dc.l    p2init, p2loop      ; This is the real "part 1"
            dc.l    0


            SECTION vars, BSS           ; Uninitialized data block
bitmapaddr: ds.l    1



