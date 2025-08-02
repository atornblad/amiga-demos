******************************************************************
*** INIT
******************************************************************

            SECTION code, CODE

            ; demoinit called with exec.library in a6, graphics.library in a5
demoinit:   move.l  #40*256*2, d0       ; Alloc 2 bitplanes (double buffering one bitplane)
            move.l  #MEMF_CHIP, d1
            jsr     AllocMem(a6)
            tst.l   d0
            beq.S   .error

            move.l  d0, bitmapaddr

.btnrellp:  btst    #6, $bfe001         ; First wait for user to release mouse button after double-clicking
            beq     .btnrellp

            moveq.l #0, d0
            rts

.error:     moveq.l #1, d0
            rts
