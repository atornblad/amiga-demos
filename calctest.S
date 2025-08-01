            SECTION code, CODE

            ;; Draw some lines
            ;; Draw line from (20, 30) -- (40, 75)
            ;; Assumption, y2>=y1, always!
            ;; Knowledge source: http://www.amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node0129.html

main:       move.w  #20, d0         ; d0 = x1
            move.w  #30, d1         ; d1 = y1 (scrapped soon)
            move.w  #10, d2         ; d2 = x2
            move.w  #75, d3         ; d3 = y2 (scrapped soon)
            lea     octants, a2

            ;; Calculate address of first word into a0
            clr.l   d4
            clr.l   d5
            move.w  d1, d4
            mulu    #20, d4
            move.w  d0, d5
            asr.w   #3, d5
            add.l   d5, d4
            asl.l   #1, d4
            move.l  #0, a1 ; a0, a1
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
            ; d7 = 1: Octant 5 (value 2) ---- ---- ---0 10-1 $0009
            ; d7 = 2: Octant 7 (value 4) ---- ---- ---1 00-1 $0011
            ; d7 = 3: Octant 4 (value 5) ---- ---- ---1 01-1 $0015

            move.w  0(a2,d7.w), d1

            ; Finally: calculate BLTSIZE (d3 + 1) << 6 | 2
            asl.w   #6, d3
            addq.w  #2, d3          ; d3 = BLTSIZE

            rts
octants     dc.w    $0001, $0009, $0011, $0015
