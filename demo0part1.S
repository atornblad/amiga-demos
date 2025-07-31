            SECTION part1_code, CODE

p1init:     move.l  bitmapaddr, d0      ; Set the bitmap address in the copper list
            move.w  d0, (p1cprbmps+6)
            swap    d0
            move.w  d0, (p1cprbmps+2)

            move.l  #p1copper, COP1LC(a6)
            rts

p1loop:                               ; Move the top raster thing up and down
            move.w  p1top_y, d0         ; Y position
            move.w  p1top_dy, d1        ; Y speed (times 16)
            add.w   d1, d0              ; Add speed to position
            move.w  d0, p1top_y         ; Store Y position back
            cmp.w   #$700, d0           ; Is the position past the middle?
            bhi.s   .decr               ; If so, decrement
            addq    #1, d1              ; If not, increment...
            bra.s   .sdone              ; And done
.decr       subq    #1, d1              ; Decrement
.sdone      move.w  d1, p1top_dy        ; Store the Y speed back

            asr.w   #4, d0              ; Divide by 16
            move.b  d0, p1topy_cpr      ; Poke the copper
            addq    #3, d0              ; Add three lines
            move.b  d0, p1topy2_cpr     ; Poke the copper

            clr.w   d0                  ; Keep going until click
            rts

            SECTION vars_initialized, DATA

p1top_y:    dc.w    $03e0
p1top_dy:   dc.w    0

            SECTION copper, DATA_C

p1copper:   CMOVE   FMODE,      $0000   ; Enable slow fetch mode for AGA compatibility
            CMOVE   BPLCON0,    $0200   ; Turn off bitplanes
                                        ; TODO: DIWSTRT, DIWSTOP, DDFSTRT, DDFSTOP
            CMOVE   COLOR0,     $0000   ; Black background
            CMOVE   COLOR1,     $08af   ; Blueish foreground

p1scrtop:   CWAIT   $3c, 3

            CMOVE   DDFSTRT,    $0038   ; Left edge of display data fetch
            CMOVE   DDFSTOP,    $00d0   ; Right edge of display data fetch (320 pixels wide)

p1cprbmps:  CMOVE   BPL1PTH,    0       ; Placeholder for bitplane address
            CMOVE   BPL1PTL,    0

            CMOVE   BPL1MOD,    0       ; Odd bitplane modulo
            CMOVE   BPL2MOD,    0       ; Even bitplane modulo

p1topy_cpr: CWAIT   $3e, 3
            CMOVE   COLOR0,     $0129   ; Dark blue background

p1topy2_cpr: CWAIT   $41, 3
            CMOVE   COLOR0,     $023a   ; Dark blue background

            CMOVE   BPLCON0,    $1200   ; Turn on one bitplane

            CPALWAIT
            CWAIT   $19, 3              ; Wait for line $119
            CMOVE   COLOR0,     $034b   ; Dark blue background
            CMOVE   BPLCON0,    $0200   ; Turn off bitplanes (0 bitplanes on)
            CWAIT   $1c, 3
            CMOVE   COLOR0,     $0000   ; Black background

            CEND                        ; End of copper list

