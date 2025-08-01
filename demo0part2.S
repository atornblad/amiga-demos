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
            move.l  bitmapaddr, a0
            lea     octants, a2

            move.w  #100, d0         ; d0 = x1
            move.w  #30, d1         ; d1 = y1 (scrapped soon)
            move.w  p2frame, d2         ; d2 = x2
            move.w  #75, d3         ; d3 = y2 (scrapped soon)
            movem.w d2-d3, -(a7)    ; Push x2, y2
            bsr     .drawdownsingle
            
            movem.w (a7)+, d0-d1    ; Pop into x1, y1
            move.w  #160, d2
            move.w  #180, d3
            bsr     .drawdownsingle

.countdown: lea     p2frame, a4
            move.w  (a4), d0
            addq.w  #1, d0
            move.w  d0, (a4)
            cmp.w   #250, d0            ; 5 seconds
            bhi.s   .p2done
            clr.w   d0
.p2done:    rts                         ; non-zero exit after 5 seconds


            ;; Knowledge source: http://www.amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node0129.html
            ;; Call with d0:x1, d1:y1, d2:x2, d3:y2, bitmap:a0, octants:a2
            ;; y2 >= y1
.drawdownsingle:
            ;; Calculate address of first word into a0
            clr.l   d4
            clr.l   d5
            move.w  d1, d4
            mulu    #20, d4
            move.w  d0, d5
            asr.w   #4, d5
            add.l   d5, d4
            asl.l   #1, d4
            move.l  a0, a1
            add.l   d4, a1

            ;; "dx" = max(abs(x2 - x1), abs(y2 - y1))
            ;; "dy" = min(abs(x2 - x1), abs(y2 - y1))
            clr.w   d7              ; Helper variable for calculating octant
            sub.w   d0, d2          ; d2 = x2 - x1 (-8)
            move.w  d2, d4
            tst.w   d4
            bpl.s   .nonegd4
            neg.w   d4
            addq    #2, d7          ; x moves to the left, d7 += 1 word
.nonegd4:                           ; d4 = abs(x2 - x1) (8)
            sub.w   d1, d3          ; d3 = abs(y2 - y1) (5)         ; Last use of d1 (y1)
            cmp.w   d4, d3
            bge.s   .d3largest
            exg     d4, d3
            addq    #4, d7          ; dx < dy: d7 += 2 words
.d3largest:                         ; d3 = dx = max(abs(x2 - x1), abs(y2 - y1)) (8)
                                    ; d4 = dy = min(abs(x2 - x1), abs(y2 - y1)) (5)
            move.w  d4, d5
            asl.w   #2, d5          ; d5 = 4 * dy
            move.w  d3, d6
            asl.w   #1, d6          ; d6 = 2 * dx

            ; Figure out octant number for bits 4-2 of BLTCON1 and put BLTCON1 into d1
            ; Last bit set is LINE
            ; d7 = 0: Octant 6 (value 0) ---- ---- ---0 00-1 $0001
            ; d7 = 1: Octant 5 (value 2) ---- ---- ---0 10-1 $0005
            ; d7 = 2: Octant 7 (value 4) ---- ---- ---1 00-1 $0011
            ; d7 = 3: Octant 4 (value 5) ---- ---- ---1 01-1 $0013

            move.w  0(a2,d7.w), d1

            ; Finally: calculate BLTSIZE (d3 + 1) << 6 | 2
            asl.w   #6, d3
            addq.w  #2, d3          ; d3 = BLTSIZE

            jsr     waitblit        ; Time to start poking BLT regs, wait for blitter first
            moveq   #-1, d7
            move.w  #$8000, BLTADAT(a6)
            move.w  d7, BLTBDAT(a6) ; ffff
            move.w  d7, BLTAFWM(a6) ; ffff
            move.w  d7, BLTALWM(a6) ; ffff
            move.w  d5, BLTBMOD(a6) ; 4 * dy
            sub.w   d6, d5
            ; If 4dy-2dx < 0 (current d5), set SIGN flag in BLTCON1(d1)
            bpl.s   .nosign
            or.w    #$0040, d1
.nosign:    ext.l   d5
            move.l  d5, BLTAPT(a6)  ; 4 * dy - 2 * dx
            sub.w   d6, d5
            move.w  d5, BLTAMOD(a6) ; 4 * dy - 4 * dx
            move.w  #40, d7
            move.w  d7, BLTCMOD(a6) ; width of bpl in bytes
            move.w  d7, BLTDMOD(a6) ; ditto
            move.l  a1, BLTCPT(a6)  ; address of first word
            move.l  a1, BLTDPT(a6)  ; ditto
            ror.w   #4, d0          ; Last 4 bits of x1 is needed until here
            and.w   #$f000, d0
                                    ; USEA+USEC+USED, Minterms = AB^C + ^AC
            or.w    #$0b4a, d0
            move.w  d0, BLTCON0(a6)
            move.w  d1, BLTCON1(a6)
            move.w  d3, BLTSIZE(a6)

            rts



            SECTION vars_initialized, DATA

p2frame     dc.w    0
octants     dc.w    $0001+2, $0009+2, $0011+2, $0015+2  ; 2 == SINGLE dot per line

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
