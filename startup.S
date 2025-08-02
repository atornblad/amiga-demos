;------ exec.library
EXECBASE:       equ $4
ATTNFLAGS:      equ 296
ATTNFLAGS_LO:   equ 297
Supervisor:     equ -30
AllocMem:       equ -198
AllocAbs:       equ -204
FreeMem:        equ -210
OldOpenLibrary: equ -408
CloseLibrary:   equ -414
MEMF_ANY:       equ $00000
MEMF_PUBLIC:    equ $00001
MEMF_CHIP:      equ $00002
MEMF_FAST:      equ $00004
MEMF_CLEAR:     equ $10000
MEMF_CLEARCHIP: equ $10002

;------ graphics.library

;------ hardware
DMABASE:        equ $dff000
DMACONR:        equ $002
VPOSR:          equ $004
VHPOSR:         equ $006
INTENAR:        equ $01c
BLTCON0:        equ $040
BLTCON1:        equ $042
BLTAFWM:        equ $044
BLTALWM:        equ $046
BLTCPT:         equ $048
BLTCPTH:        equ BLTCPT
BLTCPTL:        equ (BLTCPTH+2)
BLTBPT:         equ $04c
BLTBPTH:        equ BLTBPT
BLTBPTL:        equ (BLTBPTH+2)
BLTAPT:         equ $050
BLTAPTH:        equ BLTAPT
BLTAPTL:        equ (BLTAPTH+2)
BLTDPT:         equ $054
BLTDPTH:        equ BLTDPT
BLTDPTL:        equ (BLTDPTH+2)
BLTSIZE:        equ $058
BLTCMOD:        equ $060
BLTBMOD:        equ $062
BLTAMOD:        equ $064
BLTDMOD:        equ $066
BLTCDAT:        equ $070
BLTBDAT:        equ $072
BLTADAT:        equ $074
COP1LC:         equ $080
COP2LC:         equ $084
COPJMP1:        equ $088
COPJMP2:        equ $08a
DDFSTRT:        equ $092
DDFSTOP:        equ $094
DMACON:         equ $096
INTENA:         equ $09a
INTREQ:         equ $09c
AUD0LC:         equ $0a0
AUD0LEN:        equ $0a4
AUD0PER:        equ $0a6
AUD0VOL:        equ $0a8
AUD1LC:         equ $0b0
AUD1VOL:        equ $0b8
AUD2LC:         equ $0c0
AUD2VOL:        equ $0c8
AUD3LC:         equ $0d0
AUD3VOL:        equ $0d8
BPL1PTH:        equ $0e0
BPL1PTL:        equ $0e2
BPL2PTH:        equ $0e4
BPL2PTL:        equ $0e6
BPL3PTH:        equ $0e8
BPL3PTL:        equ $0ea
BPL4PTH:        equ $0ec
BPL4PTL:        equ $0ee
BPLCON0:        equ $100
BPLCON1:        equ $102
BPL1MOD:        equ $108
BPL2MOD:        equ $10a
COLOR0:         equ $180
COLOR1:         equ $182
COLOR2:         equ $184
COLOR3:         equ $186
COLOR4:         equ $188
COLOR5:         equ $18a
COLOR6:         equ $18c
COLOR7:         equ $18e
COLOR8:         equ $190
COLOR9:         equ $192
COLOR10:        equ $194
COLOR11:        equ $196
COLOR12:        equ $198
COLOR13:        equ $19a
COLOR14:        equ $19c
COLOR15:        equ $19e
FMODE:          equ $1fc

CWAIT       MACRO
            dc.b    (\1&$ff)
            dc.b    ((\2&$ff)*2+1)
            dc.w    $fffe
            ENDM

CPALWAIT    MACRO
            dc.w    $ffdf, $fffe
            ENDM

CEND        MACRO
            dc.w    $ffff, $fffe
            ENDM

CMOVE       MACRO
            dc.w    (\1&$1ff)
            dc.w    \2
            ENDM

;------ Interrupts
VBINTVECTOR:    equ $6c

            SECTION code, CODE

startup:    move.l  EXECBASE, a6
            sub.l   a4, a4                  ; Initial guess of VBR (Vector Base Register)

            btst    #0, ATTNFLAGS_LO(a6)    ; Check if 68010 or higher is present
            beq.s   .cpuidentified          ; Bit not set: 68000

            lea     .getvbr(pc), a5         ; Run .getvbr subroutine in Supervisor mode
            jsr     Supervisor(a6)

.cpuidentified:
            lea     .gfxname(pc), a1        ; Open graphics library
            jsr     OldOpenLibrary(a6)
            tst.l   d0
            beq     .errorexit
            move.l  d0, a5                  ; a5 = graphicsbase

            movem.l a5-a6, -(sp)            ; save a5 and a6
            bsr.l   demoinit                ; Allow demo code to do some OS-friendly stuff before it's all shut down
            movem.l (sp)+, a5-a6            ; restore a5 and a6
                                            ; TODO: If demoinit returns non-zero in d0, close graphics library and quit

            ; Save interrupt and dma bits
            lea.l   DMABASE, a6
            move.w  INTENAR(a6), -(sp)      ; Push INTENAR
            move.w  DMACONR(a6), -(sp)      ; Push DMACONR
            move.l  VBINTVECTOR(a4), -(sp)  ; Push VBINTVECTOR

            bsr     .waiteof                ; Wait for the end of the frame
            bsr     .alloff                 ; Turn off all interrupts and dma

            ; Call the demo main
            movem.l a4-a6, -(sp)            ; Push dmabase, graphics.library, and VBR
            jsr     demomain                ; Call main demo code
            movem.l (sp)+, a4-a6            ; Pop dmabase, bfx, VBR

            ; Restore everything
            bsr     .waiteof                ; Wait for the end of the frame
            bsr     .alloff                 ; Turn off all interrupts and dma

            move.l  (sp)+, VBINTVECTOR(a4)  ; Restore VBINTVECTOR
            move.l  38(a5), COP1LC(a6)      ; Restore system copper lists
            move.l  50(a5), COP2LC(a6)

            move.w  #$8000, d2
            move.w  (sp)+, d0               ; Restore DMACON
            or.w    d2, d0
            move.w  d0, DMACON(a6)

            move.w  (sp)+, d0               ; Restore INTENA
            or.w    d2, d0
            move.w  d0, INTENA(a6)

            move.l  a5, a6                  ; Restore OS screen (graphics.library)
            move.l  34(a6), a1
            jsr     -222(a6)                ; TODO: Find graphics.library function definitions

            move.l  a6, -(sp)               ; push gfxbase
            move.l  a6, a5
            move.l  EXECBASE, a6
            bsr.l   demoexit                ; allow demo to clean up in OS-friendly way

            move.l  (sp)+, a1               ; pop gfxbase to a1 and close graphics.library
            move.l  EXECBASE, a6
            jsr     CloseLibrary(a6)

.niceexit:  lea.l   DMABASE, a6
            clr.w   AUD0VOL(a6)
            clr.w   AUD1VOL(a6)
            clr.w   AUD2VOL(a6)
            clr.w   AUD3VOL(a6)

            moveq.l #0, d0
            rts

.errorexit: moveq.l #103, d0
            rts

.getvbr:    dc.w    $4e7a, $c801            ; 68010+ opcode "movec VBR, a4"
            rte                             ; return from Supervisor mode

.gfxname:   dc.b    "graphics.library", 0, 0

.alloff:    move.w  #$7fff, d2
            move.w  d2, DMACON(a6)
            move.w  d2, INTENA(a6)
            move.w  d2, INTREQ(a6)
            rts

.waiteof:   move.w  #$4000, INTENA(a6)      ; Turn off interrupts completely
            bsr     waitblit                ; Wait for blitter to finish

wait136:
            move.w  #$135, d0               ; Wait for line $135
waitlined0:
.waitrast:  move.l  VPOSR(a6), d1
            ; move.w  d1, COLOR0(a6)          ; Debug
            lsr.l   #8, d1
            and.w   #$1ff, d1
            cmp.w   d0, d1
            bne.s   .waitrast
.waitnext:  move.l  VPOSR(a6), d1           ; Then wait for line $135 to end
            lsr.l   #8, d1
            and.w   #$1ff, d1
            cmp.w   d0, d1
            beq.s   .waitnext
            rts

waitblit:   ;tst.w   (a6)                   ; This instruction is only necessary for A1000 compatibility
.loop:
            ;move.w  d3, COLOR0(a6)          ; Debug
            ;addq.w  #3, d3
            btst    #6, 2(a6)
            bne.s   .loop
            rts
