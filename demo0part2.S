            SECTION code, CODE

p2init:     move.l  bitmapaddr, d0      ; Set the bitmap address in the copper list
            move.w  d0, (p2cprbmps+6)
            swap    d0
            move.w  d0, (p2cprbmps+2)

            move.l  #p2copper, COP1LC(a6)
            clr.w   COPJMP1(a6)
            
            lea     p2sine, a5

            rts

p2loop:     ;; Double buffering
            move.w  p2frame, d0
            moveq   #1, d1
            moveq   #1, d2
            and.w   d0, d1              ; d1: 0 or 1 - which buffer to show
            addq.w  #1, d0
            and.w   d0, d2              ; d2: 0 or 1 - which buffer to draw in

            mulu.w  #40*256, d1
            add.l   bitmapaddr, d1
            move.w  d1, (p2cprbmps+6)
            move.w  d1, (p2cprbmps+14)
            move.w  d1, (p2cprbmps+22)
            move.w  d1, (p2cprbmps+30)
            swap    d1
            move.w  d1, (p2cprbmps+2)
            move.w  d1, (p2cprbmps+10)
            move.w  d1, (p2cprbmps+18)
            move.w  d1, (p2cprbmps+26)

            mulu.w  #40*256, d2
            add.l   bitmapaddr, d2

            ;; CLEAR THE SCREEN
            ;; TODO: Keep track of how much to clean up for each buffer
            jsr     waitblit

            ; These four pokes are harmless for the clear, but necessary for the line and fill
            moveq   #-1, d7
            move.w  #$8000, BLTADAT(a6)
            move.w  d7, BLTBDAT(a6) ; ffff
            move.w  d7, BLTAFWM(a6) ; ffff
            move.w  d7, BLTALWM(a6) ; ffff

            move.l  d2, BLTDPT(a6)
            move.w  #$0100, BLTCON0(a6)         ; Use only D channel (destination), zero minterm
            move.w  #$0000, BLTCON1(a6)
            move.w  #0, BLTDMOD(a6)             ; No modulo
            move.w  #(84<<6+20), BLTSIZE(a6)    ; 84 rows by 20 words cleared, starts blitter
            ; jsr     waitblit                  ; Don't wait for blit until it's time to write
                                                ; the first data to the BLT registers!

            ;; Draw some lines
            move.l  d2, a0
            lea     octants, a2

            lea     p2polys, a3
.polysloop: move.w  (a3)+, d7       ; Number of lines
            tst.w   d7
            beq.s   .polysend
            ; TODO: Swap the order of the stored coordinates so that we can
            ;       read y,x into d1-d0 or d3-d2 using MOVEM
            move.w  (a3)+, d2
            move.w  (a3)+, d3
            bsr     .transformd2d3
            move.w  d2, d0
            move.w  d3, d1
.onepoly:   move.w  (a3)+, d2
            move.w  (a3)+, d3
            bsr     .transformd2d3
            movem.l d2-d3/d7/a3, -(sp)      ; Push x2, y2, loop, pointer
            bsr     .drawsingle
            movem.l (sp)+, d0-d1/d7/a3      ; Pop x1, y1, loop, pointer
            subq.w  #1, d7
            bne.s   .onepoly
            bra.s   .polysloop

.polysend:

            ;; FILL
            ;; This is a naive fill that fills the entire width of the screen
            ;; from y=24 to y=106 (including)
            ;; For this scene, which fills the entire width, this works fine!
            jsr     waitblit
            move.w  #$09f0, BLTCON0(a6)     ; USEA, USED, D=A
            move.w  #$0012, BLTCON1(a6)     ; EFE + DESC
            move.w  #0, BLTAMOD(a6)         ; No modulo because we fill entire width
            move.w  #0, BLTDMOD(a6)
            lea.l   (40*83+38)(a0), a1
            move.l  a1, BLTAPT(a6)
            move.l  a1, BLTDPT(a6)
            move.w  #(84<<6+20), BLTSIZE(a6)

            sub.w   #3, p2polyoffset
            cmp.w   #-320, p2polyoffset
            bgt.s   .polyoffsetdone
            add.w   #640, p2polyoffset
.polyoffsetdone:

.countdown: lea     p2frame, a4
            move.w  (a4), d0
            addq.w  #1, d0
            move.w  d0, (a4)
            cmp.w   #2500, d0           ; 50 seconds
            bhi.s   .p2done
            clr.w   d0
.p2done:    rts                         ; non-zero exit after 5 seconds


.transformd2d3:
            ; Don't touch d0, d1, d7, a3
            ; First a random jitter every 2 frames in one way and every 4 frames in another
            move.w  p2frame, d4
            asr.w   #1, d4
            ; and.w   #$00ae, d4
            mulu    #17, d4
            add.w   d3, d4
            mulu    #5, d4
            add.w   d2, d4
            mulu    #3, d4
            move.w  p2frame, d5
            addq    #1, d5
            asr.w   #1, d5
            ; and.w   #$006b, d5
            mulu    #3, d5
            add.w   d2, d5
            mulu    #7, d5
            eor.w   d5, d4
            and.w   #7, d4
            and.w   #3, d5
            add.w   d4, d2
            add.w   d5, d3
            subq.w  #3, d2
            subq.w  #1, d3

            ; Then a SINE effect based on the X coordinate
            ; a5 must point to p2sine
            move.w  d2, d4
            lsr.w   #1, d4
            move.w  p2frame, d5
            lsl.w   #2, d5
            add.w   d5, d4
            and.w   #255, d4
            lsl.w   #1, d4
            move.w  0(a5,d4.w), d4
            add.w   d4, d3

            ; Finally, we add d2polyoffset (for now, this will instead by individual by glyph)
            add.w   p2polyoffset, d2
            bmi.s   .transformnegative
            cmp.w   #319, d2
            bmi.s   .transformdone
            move.w  #318, d2
.transformdone:
            rts
.transformnegative:
            clr.w   d2
            rts


            ;; Call with d0:x1, d1:y1, d2:x2, d3:y2, bitmap:a0, octants:a2
            ;; Any y direction
.drawsingle
            cmp.w   d1, d3
            bne.s   .noskip
            rts
.noskip:    bhi.s   .noswap
            exg     d0, d2
            exg     d1, d3
.noswap:
            ;; Knowledge source: http://www.amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node0129.html
            ;; Call with d0:x1, d1:y1, d2:x2, d3:y2, bitmap:a0, octants:a2
            ;; y2 >= y1
.drawdownsingle:
            subq    #1, d3
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

            ;; dmax = max(abs(x2 - x1), abs(y2 - y1))
            ;; dmin = min(abs(x2 - x1), abs(y2 - y1))
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
.d3largest:                         ; d3 = dmax = max(abs(x2 - x1), abs(y2 - y1)) (8)
                                    ; d4 = dmin = min(abs(x2 - x1), abs(y2 - y1)) (5)
            move.w  d4, d5
            asl.w   #2, d5          ; d5 = 4 * dmin
            move.w  d3, d6
            asl.w   #1, d6          ; d6 = 2 * dmax

            ; Figure out octant number for bits 4-2 of BLTCON1 and put BLTCON1 into d1
            ; Last bit set is LINE
            ; d7 = 0: Octant 6 (value 0) ---- ---- ---0 00-1 $0001
            ; d7 = 1: Octant 5 (value 2) ---- ---- ---0 10-1 $0005
            ; d7 = 2: Octant 7 (value 4) ---- ---- ---1 00-1 $0011
            ; d7 = 3: Octant 4 (value 5) ---- ---- ---1 01-1 $0013

            move.w  0(a2,d7.w), d1

            ; Finally: calculate BLTSIZE d3 << 6 | 2
            addq.w  #1, d3
            asl.w   #6, d3
            addq.w  #2, d3          ; d3 = BLTSIZE

            jsr     waitblit        ; Time to start poking BLT regs, wait for blitter first
            move.w  d5, BLTBMOD(a6) ; 4 * dmin
            sub.w   d6, d5
            ; If 4dy-2dmax < 0 (current d5), set SIGN flag in BLTCON1(d1)
            bpl.s   .nosign
            or.w    #$0040, d1
.nosign:    ext.l   d5
            move.l  d5, BLTAPT(a6)  ; 4 * dmin - 2 * dmax
            sub.w   d6, d5
            move.w  d5, BLTAMOD(a6) ; 4 * dmin - 4 * dmax
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
p2polyoffset:
            dc.w    320
p2polys     dc.w    6       ; 6 lines (outer D)
            dc.w      5, 40-23
            dc.w      5, 90-23
            dc.w     35, 90-23
            dc.w     45, 80-23
            dc.w     45, 50-23
            dc.w     35, 40-23
            dc.w      5, 40-23

            dc.w    3       ; 3 lines (hole of D)
            dc.w     18, 55-23
            dc.w     18, 75-23
            dc.w     32, 65-23
            dc.w     18, 55-23

            dc.w    7       ; 7 lines (E)
            dc.w     50, 40-23
            dc.w     90, 49-23
            dc.w     60, 58-23
            dc.w     80, 65-23
            dc.w     60, 72-23
            dc.w     90, 81-23
            dc.w     50, 90-23
            dc.w     50, 40-23

            dc.w    7       ; 7 lines (F)
            dc.w     90, 40-23
            dc.w    130, 49-23
            dc.w    100, 58-23
            dc.w    120, 65-23
            dc.w    100, 72-23
            dc.w    100, 90-23
            dc.w     90, 90-23
            dc.w     90, 40-23

            dc.w    4       ; 4 lines (I)
            dc.w    130, 40-23
            dc.w    140, 40-23
            dc.w    140, 90-23
            dc.w    130, 90-23
            dc.w    130, 40-23

            dc.w    7       ; 7 lines (outer A)
            dc.w    140, 90-23
            dc.w    160, 40-23
            dc.w    180, 90-23
            dc.w    170, 90-23
            dc.w    162, 80-23
            dc.w    158, 80-23
            dc.w    150, 90-23
            dc.w    140, 90-23

            dc.w    3       ; 3 lines (hole of A)
            dc.w    160, 55-23
            dc.w    164, 65-23
            dc.w    156, 65-23
            dc.w    160, 55-23

            dc.w    10      ; 10 lines (N)
            dc.w    180, 40-23
            dc.w    190, 40-23
            dc.w    210, 65-23
            dc.w    210, 40-23
            dc.w    220, 40-23
            dc.w    220, 90-23
            dc.w    210, 90-23
            dc.w    190, 65-23
            dc.w    190, 90-23
            dc.w    180, 90-23
            dc.w    180, 40-23

            dc.w    11      ; 11 lines (C)

            dc.w    235, 40-23
            dc.w    265, 40-23
            dc.w    265, 50-23
            dc.w    245, 50-23
            dc.w    235, 65-23
            dc.w    245, 80-23
            dc.w    265, 80-23
            dc.w    265, 90-23
            dc.w    235, 90-23
            dc.w    225, 80-23
            dc.w    225, 50-23
            dc.w    235, 40-23

            dc.w    7       ; 7 lines (E)
            dc.w    270, 40-23
            dc.w    310, 49-23
            dc.w    280, 58-23
            dc.w    300, 65-23
            dc.w    280, 72-23
            dc.w    310, 81-23
            dc.w    270, 90-23
            dc.w    270, 40-23

            dc.w    0       ; No more polygons

; Sine table for Amiga demo
; Values are scaled to fit in -15 to 15 range
; Table contains 256 entries, each entry is a signed word (dc.w)

p2sine:
            dc.w    0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 4, 4, 4, 5, 5
            dc.w    5, 6, 6, 6, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 10, 10
            dc.w    10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13
            dc.w    13, 13, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14
            dc.w    15, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 13
            dc.w    13, 13, 13, 13, 13, 13, 12, 12, 12, 12, 12, 11, 11, 11, 11, 10
            dc.w    10, 10, 10, 9, 9, 9, 8, 8, 8, 8, 7, 7, 7, 6, 6, 6
            dc.w    5, 5, 5, 4, 4, 4, 3, 3, 2, 2, 2, 1, 1, 1, 0, 0
            dc.w    0, 0, 0, -1, -1, -1, -2, -2, -2, -3, -3, -4, -4, -4, -5, -5
            dc.w    -5, -6, -6, -6, -7, -7, -7, -8, -8, -8, -8, -9, -9, -9, -10, -10
            dc.w    -10, -10, -11, -11, -11, -11, -12, -12, -12, -12, -12, -13, -13, -13, -13, -13
            dc.w    -13, -13, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14
            dc.w    -15, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -13
            dc.w    -13, -13, -13, -13, -13, -13, -12, -12, -12, -12, -12, -11, -11, -11, -11, -10
            dc.w    -10, -10, -10, -9, -9, -9, -8, -8, -8, -8, -7, -7, -7, -6, -6, -6
            dc.w    -5, -5, -5, -4, -4, -4, -3, -3, -2, -2, -2, -1, -1, -1, 0, 0

            SECTION copper, DATA_C

p2copper:   CMOVE   FMODE,      $0000   ; Enable slow fetch mode for AGA compatibility
            CMOVE   BPLCON0,    $0200   ; Turn off bitplanes
                                        ; TODO: DIWSTRT, DIWSTOP, DDFSTRT, DDFSTOP
            CMOVE   COLOR0,     $0fff   ; White background
            CMOVE   COLOR1,     $0777   ; Black foreground
            CMOVE   COLOR2,     $0777   ; Black foreground
            CMOVE   COLOR3,     $0000   ; Black foreground
            CMOVE   COLOR4,     $0777   ; Black foreground
            CMOVE   COLOR5,     $0000   ; Black foreground
            CMOVE   COLOR6,     $0000   ; Black foreground
            CMOVE   COLOR7,     $0777   ; Black foreground
            CMOVE   COLOR8,     $0777   ; Black foreground
            CMOVE   COLOR9,     $0000   ; Black foreground
            CMOVE   COLOR10,    $0000   ; Black foreground
            CMOVE   COLOR11,    $0777   ; Black foreground
            CMOVE   COLOR12,    $0000   ; Black foreground
            CMOVE   COLOR13,    $0777   ; Black foreground
            CMOVE   COLOR14,    $0777   ; Black foreground
            CMOVE   COLOR15,    $0fff   ; White foreground

p2cprbmps:  CMOVE   BPL1PTH,    0       ; Placeholder for bitplane addresses
            CMOVE   BPL1PTL,    0
            CMOVE   BPL2PTH,    0
            CMOVE   BPL2PTL,    0
            CMOVE   BPL3PTH,    0
            CMOVE   BPL3PTL,    0
            CMOVE   BPL4PTH,    0
            CMOVE   BPL4PTL,    0

            CMOVE   DDFSTRT,    $0038   ; Left edge of display data fetch
            CMOVE   DDFSTOP,    $00d0   ; Right edge of display data fetch (320 pixels wide)

            CMOVE   BPL1MOD,    0       ; Odd bitplane modulo
            CMOVE   BPL2MOD,    0       ; Even bitplane modulo
            CMOVE   BPLCON1,    $0010   ; Shift even bitplanes one pixel to the right
            CMOVE   BPLCON2,    $0024   ; Sprites take precedent over bitplanes

            CWAIT   $2b, 3
            CMOVE   COLOR0,     $0000

            CWAIT   $2c, 3
            CMOVE   BPLCON0,    $2200   ; Turn on two bitplanes
            CMOVE   COLOR0,     $0ccc

            CWAIT   $2d, 3
            CMOVE   BPLCON0,    $4200   ; Turn on four bitplanes

            CPALWAIT
            CWAIT   $2c, 3
            CMOVE   BPLCON0,    $0200   ; Turn off bitplanes (0 bitplanes on)
            CMOVE   COLOR0,     $0000

            CWAIT   $2d, 3
            CMOVE   COLOR0,     $0fff

            CEND                        ; End of copper list


