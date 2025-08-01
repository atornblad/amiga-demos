            SECTION code, CODE

p2init:     move.l  bitmapaddr, d0      ; Set the bitmap address in the copper list
            move.w  d0, (p2cprbmps+6)
            swap    d0
            move.w  d0, (p2cprbmps+2)

            move.l  #p2copper, COP1LC(a6)
            clr.w   COPJMP1(a6)
            rts

p2loop:     ;; CLEAR THE SCREEN
            jsr     waitblit
            move.l  bitmapaddr, a0      ; Just to see if anything is visible...
            move.l  a0, BLTDPT(a6)
            move.w  #$0100, BLTCON0(a6)         ; Use only D channel (destination), zero minterm
            move.w  #$0000, BLTCON1(a6)
            move.w  #0, BLTDMOD(a6)             ; No modulo
            move.w  #(256<<6+20), BLTSIZE(a6)   ; 256 rows by 20 words cleared, starts blitter
            ; jsr     waitblit                  ; Don't wait for blit until it's time to write
                                                ; the first data to the BLT registers!

            ;; Draw some lines
            ;; Draw line from (20, 30) -- (40, 75)
            ;; Assumption, y2>=y1, always!
            ;; Knowledge source: http://www.amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node0129.html
            move.w  #20, d0         ; d0 = x1
            move.w  #30, d1         ; d1 = y1 (scrapped soon)
            move.w  #40, d2         ; d2 = x2
            move.w  #75, d3         ; d3 = y2 (scrapped soon)

            ;; "dx" = max(abs(x2 - x1), abs(y2 - y1))
            ;; "dy" = min(abs(x2 - x1), abs(y2 - y1))
            sub.w   d0, d2          ; d2 = x2 - x1 (-8)
            move.w  d2, d4
            tst.w   d4
            bpl.s   .nonegd4
            neg.w   d4
.nonegd4:                           ; d4 = abs(x2 - x1) (8)
            sub.w   d1, d3          ; d3 = abs(y2 - y1) (5)
            cmp.w   d4, d3
            bge.s   .d3largest
            exg     d4, d3
.d3largest:                         ; d3 = max(abs(x2 - x1), abs(y2 - y1)) (8)
                                    ; d4 = min(abs(x2 - x1), abs(y2 - y1)) (5)




.countdown: lea     p2frame, a4
            move.w  (a4), d0
            addq.w  #1, d0
            move.w  d0, (a4)
            cmp.w   #250, d0            ; 5 seconds
            bhi.s   .p2done
            clr.w   d0
.p2done:    rts                         ; non-zero exit after 5 seconds

            SECTION vars_initialized, DATA

p2frame     dc.w    0

            SECTION copper, DATA_C

p2copper:   CMOVE   FMODE,      $0000   ; Enable slow fetch mode for AGA compatibility
            CMOVE   BPLCON0,    $0200   ; Turn off bitplanes
                                        ; TODO: DIWSTRT, DIWSTOP, DDFSTRT, DDFSTOP
            CMOVE   COLOR0,     $0fff   ; White background
            CMOVE   COLOR1,     $0000   ; Black foreground

p2cprbmps:  CMOVE   BPL1PTH,    0       ; Placeholder for bitplane address
            CMOVE   BPL1PTL,    0

            CMOVE   DDFSTRT,    $0038   ; Left edge of display data fetch
            CMOVE   DDFSTOP,    $00d0   ; Right edge of display data fetch (320 pixels wide)

            CMOVE   BPL1MOD,    0       ; Odd bitplane modulo
            CMOVE   BPL2MOD,    0       ; Even bitplane modulo

            CWAIT   $2c, 3

            CMOVE   BPLCON0,    $1200   ; Turn on one bitplane
            CMOVE   COLOR0,     $0999

            CPALWAIT
            CWAIT   $2c, 3
            CMOVE   BPLCON0,    $0200   ; Turn off bitplanes (0 bitplanes on)
            CMOVE   COLOR0,     $0fff

            CEND                        ; End of copper list
