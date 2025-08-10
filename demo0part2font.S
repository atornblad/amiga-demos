
            SECTION vars_initialized, DATA

p2font:     dc.l    p2fontnull          ; SPACE
            dc.l    p2fontnull          ; !
            dc.l    p2fontnull          ; "
            dc.l    p2fontnull          ; #
            dc.l    p2fontnull          ; $
            dc.l    p2fontnull          ; %
            dc.l    p2fontnull          ; &
            dc.l    p2fontnull          ; '
            dc.l    p2fontnull          ; (
            dc.l    p2fontnull          ; )
            dc.l    p2fontnull          ; *
            dc.l    p2fontnull          ; +
            dc.l    p2fontnull          ; ,
            dc.l    p2fontnull          ; -
            dc.l    p2fontnull          ; .
            dc.l    p2fontnull          ; /
            dc.l    p2fontnull          ; 0
            dc.l    p2fontnull          ; 1
            dc.l    p2fontnull          ; 2
            dc.l    p2fontnull          ; 3
            dc.l    p2fontnull          ; 4
            dc.l    p2fontnull          ; 5
            dc.l    p2fontnull          ; 6
            dc.l    p2fontnull          ; 7
            dc.l    p2fontnull          ; 8
            dc.l    p2fontnull          ; 9
            dc.l    p2fontnull          ; :
            dc.l    p2fontnull          ; ;
            dc.l    p2fontnull          ; <
            dc.l    p2fontnull          ; =
            dc.l    p2fontnull          ; >
            dc.l    p2fontnull          ; ?
            dc.l    p2fontnull          ; @
            dc.l    p2font_a            ; A
            dc.l    p2fontnull          ; B
            dc.l    p2font_c            ; C
            dc.l    p2font_d            ; D
            dc.l    p2font_e            ; E
            dc.l    p2font_f            ; F
            dc.l    p2fontnull          ; G
            dc.l    p2fontnull          ; H
            dc.l    p2font_i            ; I
            dc.l    p2fontnull          ; J
            dc.l    p2fontnull          ; K
            dc.l    p2fontnull          ; L
            dc.l    p2fontnull          ; M
            dc.l    p2font_n            ; N
            dc.l    p2fontnull          ; O
            dc.l    p2fontnull          ; P
            dc.l    p2fontnull          ; Q
            dc.l    p2fontnull          ; R
            dc.l    p2fontnull          ; S
            dc.l    p2fontnull          ; T
            dc.l    p2fontnull          ; U
            dc.l    p2fontnull          ; V
            dc.l    p2fontnull          ; W
            dc.l    p2fontnull          ; X
            dc.l    p2fontnull          ; Y
            dc.l    p2fontnull          ; Z
            dc.l    p2fontnull          ; [
            dc.l    p2fontnull          ; \
            dc.l    p2fontnull          ; ]
            dc.l    p2fontnull          ; ^
            dc.l    p2fontnull          ; _

p2fontnull: dc.w    20, 0       ; 20 px spacing, no lines

p2font_a:   dc.w    45          ; Spacing
            dc.w    7           ; Number of lines
            dc.w     0, 50
            dc.w    20,  0
            dc.w    40, 50
            dc.w    30, 50
            dc.w    22, 40
            dc.w    18, 40
            dc.w    10, 50
            dc.w     0, 50
            dc.w    3           ; 3 more lines (hole of A)
            dc.w    20, 15
            dc.w    24, 25
            dc.w    16, 25
            dc.w    20, 15
            dc.w    0           ; No more polygons

p2font_c:   dc.w    45
            dc.w    11
            dc.w    10,  0
            dc.w    40,  0
            dc.w    40, 10
            dc.w    20, 10
            dc.w    10, 25
            dc.w    20, 40
            dc.w    40, 40
            dc.w    40, 50
            dc.w    10, 50
            dc.w     0, 40
            dc.w     0, 10
            dc.w    10,  0
            dc.w    0

p2font_d:   dc.w    45
            dc.w    6       ; 6 lines (outer D)
            dc.w      0,  0
            dc.w      0, 50
            dc.w     30, 50
            dc.w     40, 40
            dc.w     40, 10
            dc.w     30,  0
            dc.w      0,  0
            dc.w    3       ; 3 lines (hole of D)
            dc.w     13, 15
            dc.w     13, 35
            dc.w     27, 25
            dc.w     13, 15
            dc.w    0

p2font_e:   dc.w    45
            dc.w    7
            dc.w     0,  0
            dc.w    40,  9
            dc.w    10, 18
            dc.w    30, 25
            dc.w    10, 32
            dc.w    40, 41
            dc.w     0, 50
            dc.w     0,  0
            dc.w    0

p2font_f:   dc.w    45
            dc.w    7
            dc.w     0,  0
            dc.w    40,  9
            dc.w    10, 18
            dc.w    30, 25
            dc.w    10, 32
            dc.w    10, 50
            dc.w     0, 50
            dc.w     0,  0
            dc.w    0

p2font_i:   dc.w    15
            dc.w    4
            dc.w     0,  0
            dc.w    10,  0
            dc.w    10, 50
            dc.w     0, 50
            dc.w     0,  0
            dc.w    0

p2font_n:   dc.w    45
            dc.w    10 
            dc.w     0,  0
            dc.w    10,  0
            dc.w    30, 25
            dc.w    30,  0
            dc.w    40,  0
            dc.w    40, 50
            dc.w    30, 50
            dc.w    10, 25
            dc.w    10, 50
            dc.w     0, 50
            dc.w     0,  0
            dc.w    0

