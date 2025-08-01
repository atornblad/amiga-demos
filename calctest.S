            SECTION code, CODE

            ;; Draw some lines
            ;; Draw line from (20, 30) -- (40, 75)
            ;; Assumption, y2>=y1, always!
            ;; Knowledge source: http://www.amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node0129.html

main:       move.w  #20, d0         ; d0 = x1
            move.w  #30, d1         ; d1 = y1 (scrapped soon)
            move.w  #40, d2         ; d2 = x2
            move.w  #75, d3         ; d3 = y2 (scrapped soon)

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
            sub.w   d0, d2          ; d2 = x2 - x1 (20)
            move.w  d2, d4
            tst.w   d4
            bpl.s   .nonegd4
            neg.w   d4
.nonegd4:                           ; d4 = abs(x2 - x1) (45)
            sub.w   d1, d3          ; d3 = abs(y2 - y1) (20)         ; Last use of d1 (y1)
            cmp.w   d4, d3
            bge.s   .d3largest
            exg     d4, d3
.d3largest:                         ; d3 = dx = max(abs(x2 - x1), abs(y2 - y1)) (45)
                                    ; d4 = dy = min(abs(x2 - x1), abs(y2 - y1)) (20)
            move.w  d4, d5
            asl.w   #2, d5          ; d5 = 4 * dy
            move.w  d3, d6
            asl.w   #1, d6          ; d6 = 2 * dx

            ; TODO: Figure out octant number for bits 4-2 of BLTCON1 and put BLTCON1 into d1
            move.w  #$0001, d1

            ; Finally: calculate BLTSIZE (d3 + 1) << 6 | 2
            asl.w   #6, d3
            addq.w  #2, d3          ; d3 = BLTSIZE

            rts
