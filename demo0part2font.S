
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
            dc.l    p2font_dot          ; .
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
            dc.l    p2font_b            ; B
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
            dc.l    p2font_o            ; O
            dc.l    p2fontnull          ; P
            dc.l    p2fontnull          ; Q
            dc.l    p2font_r            ; R
            dc.l    p2fontnull          ; S
            dc.l    p2font_t            ; T
            dc.l    p2fontnull          ; U
            dc.l    p2fontnull          ; V
            dc.l    p2fontnull          ; W
            dc.l    p2fontnull          ; X
            dc.l    p2font_y            ; Y
            dc.l    p2fontnull          ; Z
            dc.l    p2fontnull          ; [
            dc.l    p2font_kern         ; \
            dc.l    p2fontnull          ; ]
            dc.l    p2fontnull          ; ^
            dc.l    p2fontnull          ; _

p2fontnull: dc.w    20, 0       ; 20 px spacing, no lines

p2font_kern:dc.W    -5, 0

p2font_dot: dc.w    20
            dc.w    4
            dc.w     5, 40
            dc.w    15, 40
            dc.w    15, 50
            dc.w     5, 50
            dc.w     5, 40
            dc.w    0

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

p2font_b:   dc.W    45
            dc.w    5
            dc.w     0,  0
            dc.w    40,  10
            dc.W    30,  25
            dc.w    40,  40
            dc.w     0,  50
            dc.w     0,   0
            dc.w    3
            dc.w    15, 10
            dc.w    25, 15
            dc.w    15, 20
            dc.w    15, 10
            dc.w    3
            dc.w    15, 30
            dc.w    25, 35
            dc.w    15, 40
            dc.w    15, 30
            dc.w    0

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

p2font_i:   dc.w    20
            dc.w    4
            dc.w     0,  0
            dc.w    12,  0
            dc.w    12, 50
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

p2font_o:   dc.w    45
            dc.w    6
            dc.w    10,  0
            dc.w    30,  0
            dc.w    40, 25
            dc.w    30, 50
            dc.w    10, 50
            dc.w     0, 25
            dc.w    10,  0
            dc.w    3
            dc.w    20, 15
            dc.w    26, 35
            dc.w    14, 35
            dc.w    20, 15
            dc.w    0

p2font_r:   dc.w    45
            dc.w    9
            dc.w     0,  0
            dc.w    30,  5
            dc.w    40, 15
            dc.w    25, 25
            dc.w    40, 50
            dc.w    30, 50
            dc.w    10, 30
            dc.w    10, 50
            dc.w     0, 50
            dc.w     0, 0
            dc.w    3
            dc.w    17, 12
            dc.w    23, 15
            dc.w    17, 18
            dc.w    17, 12
            dc.w    0

p2font_t:   dc.w    45
            dc.w    8
            dc.w     0,  0
            dc.w    40,  0
            dc.w    40, 10
            dc.w    25, 10
            dc.w    25, 50
            dc.w    15, 50
            dc.w    15, 10
            dc.w     0, 10
            dc.w     0,  0
            dc.w    0;

p2font_y:   dc.w    45
            dc.w    9
            dc.w     0,  0
            dc.w    10,  0
            dc.w    20, 20
            dc.w    30,  0
            dc.w    40,  0
            dc.w    25, 30
            dc.w    25, 50
            dc.w    15, 50
            dc.w    15, 30
            dc.w     0,  0
            dc.w    0

