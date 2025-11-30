            SECTION code, CODE

p2init:     move.l  bitmapaddr, d0      ; Set the bitmap address in the copper list
            move.w  d0, (p2cprbmps+6)
            swap    d0
            move.w  d0, (p2cprbmps+2)

            move.l  #p2copper, COP1LC(a6)
            move.l  #p2cprbmps, COP2LC(a6)
            clr.w   COPJMP1(a6)
            
            lea     p2sine, a5
            move.l  #p2text, p2textptr

            ;; INITIAL BITPLANE ADDRESSES
            move.l   bitmapaddr, d1
            move.w  d1, (p2cprbmps+6)
            move.w  d1, (p2cprbmps+14)
            move.w  d1, (p2cprbmps+22)
            move.w  d1, (p2cprbmps+30)
            swap    d1
            move.w  d1, (p2cprbmps+2)
            move.w  d1, (p2cprbmps+10)
            move.w  d1, (p2cprbmps+18)
            move.w  d1, (p2cprbmps+26)
            swap    d1

            ;; CLEAR THE SCREEN
            jsr     waitblit

            ; These four pokes are harmless for the clear, but necessary for the line and fill
            moveq   #-1, d7
            move.w  #$8000, BLTADAT(a6)
            move.w  d7, BLTBDAT(a6) ; ffff
            move.w  d7, BLTAFWM(a6) ; ffff
            move.w  d7, BLTALWM(a6) ; ffff

            move.l  d1, BLTDPT(a6)
            move.w  #$0100, BLTCON0(a6)         ; Use only D channel (destination), zero minterm
            move.w  #$0000, BLTCON1(a6)
            move.w  #0, BLTDMOD(a6)             ; No modulo
            move.w  #(85<<6+20), BLTSIZE(a6)    ; 84 rows by 20 words cleared, starts blitter

            rts

p2in:       move.w  p2incount, d4
            moveq.l #P2INCYCLES, d0
            sub.w   d4, d0
            moveq.l #BACK_R, d1
            mulu    d0, d1
            divu    #P2INCYCLES, d1
            moveq.l #BACK_G, d2
            mulu    d0, d2
            divu    #P2INCYCLES, d2
            moveq.l #BACK_B, d3
            mulu    d0, d3
            divu    #P2INCYCLES, d3
            and.w   #$00f, d1
            lsl.w   #8, d1
            and.w   #$00f, d2
            lsl.w   #4, d2
            and.w   #$00f, d3
            or.w    d2, d1
            or.w    d3, d1
            move.w  d1, p2edgecolorscopper+2

            subq.w  #1, d4
            move.w  d4, p2incount
            tst.w   d4
            beq.s   .exit
            clr.w   d0
            rts
.exit       moveq.l #1, d0
            rts

p2out:      move.w  p2outcount, d0
            moveq.l #BACK_R, d1
            mulu    d0, d1
            divu    #P2OUTCYCLES, d1
            moveq.l #BACK_G, d2
            mulu    d0, d2
            divu    #P2OUTCYCLES, d2
            moveq.l #BACK_B, d3
            mulu    d0, d3
            divu    #P2OUTCYCLES, d3
            and.w   #$00f, d1
            lsl.w   #8, d1
            and.w   #$00f, d2
            lsl.w   #4, d2
            and.w   #$00f, d3
            or.w    d2, d1
            or.w    d3, d1
            move.w  d1, p2edgecolorscopper+2

            subq.w  #1, d0
            move.w  d0, p2outcount
            tst.w   d0
            beq.s   .exit
            clr.w   d0
            rts
.exit       moveq.l #1, d0
            rts

p2loop:     ;; Which copper list?
;            tst.w   p2usealtcopper
;            bne.s   .usealtcopper
;            move.l  #p2copper, COP1LC(a6)
;            bra.s   .usecopperdone
;.usealtcopper:
;            move.l  #p2altcopper, COP1LC(a6)
;.usecopperdone:

            ;; Double buffering
            move.w  p2frame, d0
            moveq   #1, d1
            moveq   #1, d2
            and.w   d0, d1              ; d1: 0 or 1 - which buffer to show
            addq.w  #1, d0
            and.w   d0, d2              ; d2: 0 or 1 - which buffer to draw in

            mulu.w  #40*85, d1         ; Scroller section is 85 lines high
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

            mulu.w  #40*85, d2
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
            move.w  #(85<<6+20), BLTSIZE(a6)    ; 84 rows by 20 words cleared, starts blitter
            ; jsr     waitblit                  ; Don't wait for blit until it's time to write
                                                ; the first data to the BLT registers!

            ;; Draw some lines
            move.l  d2, a0
            lea     octants, a2

            ;; TODO: Indirect pointer to p2text, increment when each char pops out off the left edge
            move.l  p2textptr, a4
            tst.b   (a4)            ; No text left?
            beq     .p2exit         ; Skip to next part
            move.w  p2polyoffset, d6 ; X coordinate

.textloop:  cmp.w   #324, d6      ; Is next glyph off screen?
            bgt.s   .textend
            clr.l   d7              ; Get one char
            move.b  (a4)+, d7
            tst.w   d7              ; End of text?
            beq.s   .textend
            sub.w   #32, d7         ; No glyphs before SPACE
            asl.w   #2, d7          ; Multiply by size of pointer
            add.l   #p2font, d7     ; Point to glyph pointer
            move.l  d7, a3
            move.l  (a3), a3        ; Point to glyph

            ;; TODO: Use kerning table (64x64 bytes)
            move.w  (a3)+, d0       ; Get glyph width
            move.W  d0, d1
            add.w   d6, d1          ; d0 is not right edge of glyph
            tst.w   d1              ; Is glyph completely off screen?
            bpl.s   .notoffscr
            move.l  a4, p2textptr   ; Move text start ptr forward
            add.w   d0, d6          ; Move left edge forward
            move.w  d6, p2polyoffset ; Store new poly offset
            bra.s   .textloop
.notoffscr: move.w  d0, -(sp)       ; Push glyph width

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
            movem.l d2-d3/d6-d7/a3, -(sp)      ; Push x2, y2, x coord, loop, pointer
            bsr     .drawsingle
            movem.l (sp)+, d0-d1/d6-d7/a3      ; Pop x1, y1, x coord, loop, pointer
            subq.w  #1, d7
            bne.s   .onepoly
            bra.s   .polysloop

.polysend:  add.W   (sp)+, d6       ; Add glyph width to x offset
            bra.s   .textloop
.textend:
            ;; FILL
            ;; This is a naive fill that fills the entire width of the screen
            ;; from y=24 to y=106 (including)
            ;; For this scene, which fills the entire width, this works fine!
            jsr     waitblit
            move.w  #$09f0, BLTCON0(a6)     ; USEA, USED, D=A
            move.w  #$0012, BLTCON1(a6)     ; EFE + DESC
            move.w  #0, BLTAMOD(a6)         ; No modulo because we fill entire width
            move.w  #0, BLTDMOD(a6)
            lea.l   (40*84+38)(a0), a1
            move.l  a1, BLTAPT(a6)
            move.l  a1, BLTDPT(a6)
            move.w  #(85<<6+20), BLTSIZE(a6)

            move.w  p2speed, d0
            sub.w   d0, p2polyoffset

.countdown: lea     p2frame, a4
            move.w  (a4), d0
            addq.w  #1, d0
            move.w  d0, (a4)

            ; TEMPORARY: switch between coppers
            ;move.w  d0, d1
            ;add.w   #17, d1
            ;and.w   #64, d1
            ;move.w  d1, p2usealtcopper

            ; TEMPORARY: Jitter
            ; TODO: Controled by music
            move.w  d0, d1
            sub.w   #100, d1
            bmi.s   .jittersetdone
            and.w   #112, d1
            move.w  d1, d2
            and.w   #96, d2
            and.w   #16, d1
            beq.s   .jitterclear
            cmp.w   #32, d2
            beq.s   .jitterclear
            move.w  #1, p2jitter
            bra.s   .jittersetdone
.jitterclear:
            clr.w   p2jitter
.jittersetdone:

            cmp.w   #2500, d0           ; 50 seconds
            bhi.s   .p2done
            clr.w   d0
.p2done:    rts                         ; non-zero exit after 5 seconds
.p2exit:    moveq   #1, d0
            rts

.transformd2d3:
            ; Don't touch d0, d1, d6, d7, a3
            ; First add the d6 x offset
            add.w   d6, d2
            ; Add 18 px to y offset
            add.w   #18, d3

            ; Then a SINE effect based on the X coordinate
            ; a5 must point to p2sine

            ;; EXPERIMENT:
            ;; d4 = SIN(frame + x) * (x + CONSTANT) + frame
            move.w  d2, d4
            move.w  p2frame, d5
            add.w   #100, d5
            add.w   d5, d4
            and.W   #255, d4
            lsl.w   #1, d4
            move.w  (a5,d4.w), d4
            muls.w  d2, d4
            asr.w   #5, d4
            add.w   #100, d4
            add.w   p2frame, d4

            ;lsl.w   #2, d5
            ;add.w   d5, d4
            and.w   #255, d4
            lsl.w   #1, d4
            move.w  (a5,d4.w), d4
            add.w   d4, d3

            ;; EXPERIMENT 2:
            ; x = x * (x + 512 - 160) / (512 + 160)
            move.w  d2, d4
            add     #512-160, d4
            muls    d4, d2
            divs    #512+160, d2

            bra.s   .nojitter
            ; Then a random jitter every 2 frames in one way and every 4 frames in another
            tst.w   p2jitter
            beq.s   .nojitter
            move.w  p2frame, d4
            asr.w   #2, d4
            mulu    #17, d4
            add.w   d3, d4
            mulu    #5, d4
            add.w   d2, d4
            mulu    #3, d4
            move.w  p2frame, d5
            addq    #1, d5
            asr.w   #1, d5
            mulu    #3, d5
            add.w   d2, d5
            mulu    #7, d5
            eor.w   d5, d4

            and.w   #6, d4
            and.w   #2, d5
            add.w   d4, d2
            add.w   d5, d3
            subq.w  #3, d2
            subq.w  #1, d3

.nojitter:
            ; Clip to 0..318
            tst.w   d2
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

            move.w  (a2,d7.w), d1

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

            SECTION vars, BSS

p2textptr:  ds.l    1

            SECTION vars_initialized, DATA

P2INCYCLES  equ     27
P2OUTCYCLES  equ     27
p2frame     dc.w    0
p2jitter:   dc.w    0
p2incount: dc.w    P2INCYCLES
p2outcount: dc.w    P2OUTCYCLES
;p2usealtcopper:
;            dc.w    0
octants     dc.w    $0001+2, $0009+2, $0011+2, $0015+2  ; 2 == SINGLE dot per line
p2polyoffset:
            dc.w    325
p2speed:    dc.w    3
            ;;      Backslash is a kerning helper
p2text:     ;dc.b    "INTRO B\Y DEFIANCE... CODE B\Y ORION... F\ONT B\Y ORION...", 0
            dc.b    "AFTER 30 YEARS, "
            dc.b    "IT'S F\INALL\Y "
            dc.b    "TIME F\OR SOME NEW OLD-SCHOOL CODE "
            dc.b    "B\Y ORION OF DEF\IANCE!"
            dc.b    0
            CNOP    0, 2

            INCLUDE "demo0part2font.S"

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

EDGE:       equ     $0000
FILL:       equ     $0fff
SHADOW:     equ     $0e3c
BACK:       equ     $0cb7
BACK2:      equ     $0129
AA_FILL:    equ     $0777
AA_BACK:    equ     $0653
BACK_R:     equ     $0c
BACK_G:     equ     $0b
BACK_B:     equ     $07

p2copper:   CMOVE   FMODE,      $0000   ; Enable slow fetch mode for AGA compatibility
            CMOVE   BPLCON0,    $0200   ; Turn off bitplanes
                                        ; TODO: DIWSTRT, DIWSTOP, DDFSTRT, DDFSTOP
p2edgecolorscopper:
            CMOVE   COLOR0,     BACK
            CMOVE   COLOR1,     AA_BACK
            CMOVE   COLOR2,     AA_BACK
            CMOVE   COLOR3,     EDGE
            CMOVE   COLOR4,     AA_BACK
            CMOVE   COLOR5,     EDGE
            CMOVE   COLOR6,     EDGE
            CMOVE   COLOR7,     AA_FILL
            CMOVE   COLOR8,     AA_BACK
            CMOVE   COLOR9,     EDGE
            CMOVE   COLOR10,    EDGE
            CMOVE   COLOR11,    AA_FILL
            CMOVE   COLOR12,    EDGE
            CMOVE   COLOR13,    AA_FILL
            CMOVE   COLOR14,    AA_FILL
            CMOVE   COLOR15,    FILL

;            CMOVE   COPJMP2,    1       ; Skip the alternative colors

;p2altcopper: CMOVE  FMODE,      $0000
;            CMOVE   BPLCON0,    $0200
;p2shadowcolorscopper:
;            ; Alternative color scheme with a drop shadow
;            CMOVE   COLOR0,     BACK2
;            CMOVE   COLOR1,     FILL
;            CMOVE   COLOR2,     BACK2
;            CMOVE   COLOR3,     FILL
;            CMOVE   COLOR4,     BACK2
;            CMOVE   COLOR5,     FILL
;            CMOVE   COLOR6,     BACK2   ; Weird combination of bits
;            CMOVE   COLOR7,     FILL
;            CMOVE   COLOR8,     SHADOW
;            CMOVE   COLOR9,     BACK2   ; Weird combination of bits
;            CMOVE   COLOR10,    SHADOW
;            CMOVE   COLOR11,    FILL
;            CMOVE   COLOR12,    SHADOW
;            CMOVE   COLOR13,    FILL
;            CMOVE   COLOR14,    SHADOW
;            CMOVE   COLOR15,    FILL

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
            CMOVE   BPLCON1,    $0020   ; Shift even bitplanes one pixel to the right
            CMOVE   BPLCON2,    $0024   ; Sprites take precedent over bitplanes

            CWAIT   $2c, 3
            CMOVE   BPLCON0,    $2200   ; Turn on two bitplanes

            CWAIT   $2e, 3
            CMOVE   BPLCON0,    $4200   ; Turn on four bitplanes

            CWAIT   $81, 3
            CMOVE   BPLCON0,    $0200   ; Turn off all bitplanes

            CPALWAIT
            CWAIT   $2c, 3
            CMOVE   BPLCON0,    $0200   ; Turn off bitplanes (0 bitplanes on)

            CEND                        ; End of copper list


