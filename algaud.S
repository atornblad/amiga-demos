; Algorithmic Audio (music)

            SECTION code, CODE

aa_init:    lea.l   aa_base, a0
            move.w  #16, d0         ; There are 16 phases
.basephases:

.basehigh:  move.w  #32, d2         ; First count down (32-d0) high bytes
            sub.w   d0, d2
.basehighloop:
            move.b  #120, (a0)+
            subq.w  #1, d2
            bne     .basehighloop
.baselow:   move.w  d0, d2          ; Then count down (d0) low bytes
.baselowloop:
            move.b  #-120, (a0)+
            subq.w  #1, d2
            bne     .baselowloop
            subq.w  #1, d0
            bne     .basephases
            rts

aa_loop:    lea.l   aa_patt, a3
            tst.w   4(a3)           ; aa_tick
            bne     .not_tick0
.tick0:     move.l  #aa_base, AUD0LC(a6)
            move.w  #16, AUD0LEN(a6)
            move.w  #1000, AUD0PER(a6)
            move.w  #20, AUD0VOL(a6)
            bra     .tickdone
.not_tick0:
            move.w  #35, d0
            sub.w   4(a3), d0
            move.w  d0, AUD0VOL(a6)
.tickdone:  addq.w  #1, 4(a3)       ; aa_tick
            cmp.w   #12, 4(a3)      ; 12 ticks per note for now (no sixteenth notes!)
            bne.s   .done
.nextnote:
            clr.w   4(a3)
            addq.w   #1, 2(a3)       ; aa_note
            cmp.w   #32, 2(a3)      ; 32 notes per pattern for now
            bne.s   .done
.nextpatt:
            clr.w   2(a3)
            addq.w  #1, (a3)        ; aa_patt
            and.w   #31, (a3)
.done:
            rts

            SECTION algoaud_vars, DATA

aa_patt:    dc.w    0
aa_note:    dc.w    0
aa_tick:    dc.w    0

            SECTION algoaud_wave, BSS_C

aa_base:    ds.b    512     ; 32 bytes per loop, 16 phases
                            ; Phase  0: ¯¯¯\___/
                            ; Phase  8: ¯¯¯¯¯\_/
                            ; Phase 15: ¯¯¯¯¯¯¯\

