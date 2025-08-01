******************************************************************
*** EXIT
******************************************************************

            SECTION code, CODE

            ; demoexit called with exec.library in a6, graphics.library in a5
demoexit:   move.l  bitmapaddr, a1
            move.l  #40*256*2, d0
            jsr     FreeMem(a6)

            rts
