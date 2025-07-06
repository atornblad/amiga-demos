            INCLUDE     "startup.S"
            INCLUDE     "demo0init.S"
            INCLUDE     "demo0exit.S"

******************************************************************
*** MAIN
******************************************************************

demomain:   move.l  bitmapaddr, d0      ; Set the bitmap address in the copper list
            move.w  d0, (cprbmps+6)
            swap    d0
            move.w  d0, (cprbmps+2)

            move.w  #$83cf, DMACON(a6)  ; Enable some DMA: audio, blitter, copper, bitplane, not disk or sprite
            move.l  #copper, COP1LC(a6)

.btnrellp:  btst    #6, $bfe001         ; First wait for user to release mouse button after double-clicking
            beq     .btnrellp

demoloop:   bsr     Wait138             ; Wait for raster line $138 (end of screen)

            move.w  top_y, d0
            move.w  top_dy, d1
            add.w   d1, d0
            move.w  d0, top_y
            cmp.w   #$700, d0
            bhi.s   .decr
            addq    #1, d1
            bra.s   .sdone
.decr       subq    #1, d1
.sdone      move.w  d1, top_dy

            asr.w   #4, d0
            move.b  d0, topy_cpr
            addq    #3, d0
            move.b  d0, topy2_cpr

            ; Exit loop on a full click
            tst.w   btn_state
            bne.s   .clicking
            btst    #6, $bfe001         ; Check mouse button state
            bne     demoloop            ; If not pressed, loop
            addq.w  #1, btn_state
            bra     demoloop
.clicking   btst    #6, $bfe001         ; Check mouse button state
            beq     demoloop            ; If still pressed, loop
            rts




            SECTION vars_initialized, DATA
    
top_y:      dc.w    $03c0
top_dy:     dc.w    0
btn_state:  dc.w    0

            SECTION vars, BSS           ; Uninitialized data block
bitmapaddr: ds.l    1

            SECTION copper, DATA_C



copper:     CMOVE   FMODE,      $0000   ; Enable slow fetch mode for AGA compatibility
            CMOVE   BPLCON0,    $0200   ; Turn off bitplanes
                                        ; TODO: DIWSTRT, DIWSTOP, DDFSTRT, DDFSTOP
            CMOVE   COLOR0,     $0000   ; Black background
            CMOVE   COLOR1,     $08af   ; Blueish foreground

topy_cpr:   CWAIT   $3c, 3
            CMOVE   COLOR0,     $0129   ; Dark blue background

            CMOVE   DDFSTRT,    $0038   ; Left edge of display data fetch
            CMOVE   DDFSTOP,    $00d0   ; Right edge of display data fetch (320 pixels wide)

            CMOVE   BPL1MOD,    0       ; Odd bitplane modulo
            CMOVE   BPL2MOD,    0       ; Even bitplane modulo
cprbmps:    CMOVE   BPL1PTH,    0       ; Placeholder for bitplane address
            CMOVE   BPL1PTL,    0

topy2_cpr:  CWAIT   $3f, 3
            CMOVE   COLOR0,     $023a   ; Dark blue background

            CMOVE   BPLCON0,    $1200   ; Turn on one bitplane

            CPALWAIT
            CWAIT   $19, 3              ; Wait for line $119
            CMOVE   COLOR0,     $034b   ; Dark blue background
            CMOVE   BPLCON0,    $0200   ; Turn off bitplanes (0 bitplanes on)
            CWAIT   $1c, 3
            CMOVE   COLOR0,     $0000   ; Black background

            CEND                        ; End of copper list

