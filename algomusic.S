
            SECTION code, CODE

musicinit:  move.l  #initmusic_copper, COP1LC(a6)
            clr.w   COPJMP1(a6)

            rts

musictick:  rts





            SECTION copper, DATA_C
initmusic_copper:
            CMOVE   FMODE,      $0000   ; Enable slow fetch mode for AGA compatibility
            CMOVE   BPLCON0,    $0200   ; Turn off bitplanes
                                        ; TODO: DIWSTRT, DIWSTOP, DDFSTRT, DDFSTOP
            CMOVE   COLOR0,     $0000   ; Black background

            SECTION waveforms, BSS_C
sine:       ds.b    256


