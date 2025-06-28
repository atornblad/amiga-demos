            INCLUDE     "startup.S"
            INCLUDE     "demo0init.S"
            INCLUDE     "demo0exit.S"

******************************************************************
*** MAIN
******************************************************************

demomain:   move.l  bitmapaddr, d0      ; Set the bitmap address in the copper list
            move.w  d0, (cprbmps+2)
            swap    d0
            move.w  d0, (cprbmps+6)

            move.w  #$83cf, DMACON(a6)  ; Enable some DMA: audio, blitter, copper, bitplane, not disk or sprite
            move.l  #copper, COP1LC(a6)

.btnrellp:  btst    #6, $bfe001         ; First wait for user to release mouse button after double-clicking
            beq     .btnrellp

demoloop:   bsr     Wait138             ; Wait for raster line $138 (end of screen)

            btst    #6, $bfe001         ; Check mouse button state
            bne     demoloop            ; If not pressed, loop
            rts






            SECTION vars, BSS           ; Uninitialized data block
bitmapaddr: ds.l    1

            SECTION copper, DATA_C



copper:     CMOVE   FMODE,      $0000   ; Enable slow fetch mode for AGA compatibility
            CMOVE   BPLCON0,    $0200   ; One bitplane
                                        ; TODO: DIWSTRT, DIWSTOP, DDFSTRT, DDFSTOP
            CMOVE   COLOR0,     $0000   ; Black background
            CMOVE   COLOR1,     $046d   ; Blueish foreground

            CWAIT   $3c, 3
            CMOVE   COLOR0,     $0129   ; Dark blue background
            CWAIT   $3f, 3
            CMOVE   COLOR0,     $023a   ; Dark blue background
cprbmps:    CMOVE   BPL1PTH,    0       ; Placeholder for bitplane address
            CMOVE   BPL1PTL,    0
            CMOVE   BPLCON0,    $1200   ; Turn on one bitplane

            CPALWAIT
            CWAIT   $19, 3              ; Wait for line $119
            CMOVE   COLOR0,     $034b   ; Dark blue background
            CMOVE   BPLCON0,    $0200   ; Turn off bitplanes (0 bitplanes on)
            CWAIT   $1c, 3
            CMOVE   COLOR0,     $0000   ; Black background

            CEND                        ; End of copper list

