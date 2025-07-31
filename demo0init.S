******************************************************************
*** INIT
******************************************************************

            SECTION code, CODE

            ; demoinit called with exec.library in a6, graphics.library in a5
demoinit:   move.l  #163840, d0                 ; Alloc some memory for bitmaps (not used yet)
            move.l  #MEMF_CLEARCHIP, d1
            jsr     AllocMem(a6)
            tst.l   d0
            beq.S   .error

            move.l  d0, bitmapaddr

            jsr     aa_init

.btnrellp:  btst    #6, $bfe001         ; First wait for user to release mouse button after double-clicking
            beq     .btnrellp

            moveq.l #0, d0
            rts

.error:     moveq.l #1, d0
            rts
