            SECTION code, CODE

            ;; Draw some lines
            ;; Draw line from (20, 30) -- (12, 35)
            ;; Assumption, y2>=y1, always!
            ;; Knowledge source: http://www.amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node0129.html

main:       move.l  #20, d0         ; d0 = x1 (20)
            move.l  #30, d1         ; d1 = y1 (30)
            move.l  #12, d2         ; d2 = x2 (12, scrapped soon)
            move.l  #35, d3         ; d3 = y2 (35, scrapped soon)

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


            rts
