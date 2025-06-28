;------ exec.library
EXECBASE:       equ $4
ATTNFLAGS:      equ 296
ATTNFLAGS_LO:   equ 297
Supervisor:     equ -30
AllocMem:       equ -198
AllocAbs:       equ -204
FreeMem:        equ -210
OpenLibrary:    equ -408
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
COP1LC:         equ $080
COP2LC:         equ $084
DMACON:         equ $096
INTENA:         equ $09a
INTREQ:         equ $09c
BPLCON0:        equ $100
PALETTE0:       equ $180

;------ Interrupts
VBINTVECTOR:    equ $6c

startup:    bsr.w   demoinit                ; Allow demo code to do some OS-friendly stuff before it's all shut down

            move.l  EXECBASE, a6
            sub.l   a4, a4                  ; Initial guess of VBR (Vector Base Register)

            btst    #0, ATTNFLAGS_LO(a6)    ; Check if 68010 or higher is present
            beq.s   .cpuidentified          ; Bit not set: 68000

            lea     .getvbr(pc), a5         ; Run .getvbr subroutine in Supervisor mode
            jsr     Supervisor(a6)

.cpuidentified:
            lea     .gfxname(pc), a1        ; Open graphics library
            jsr     OpenLibrary(a6)
            tst.l   d0
            beq.s   .errorexit
            move.l  d0, a5                  ; a5 = graphicsbase

            ; Save interrupt and dma bits
            lea.l   DMABASE, a6
            move.w  INTENAR(a6), -(sp)      ; Push INTENAR
            move.w  DMACONR(a6), -(sp)      ; Push DMACONR
            move.l  VBINTVECTOR(a4), -(sp)  ; Push VBINTVECTOR

            bsr.s   .waiteof                ; Wait for the end of the frame
            bsr.s   .alloff                 ; Turn off all interrupts and dma

            ; Call the demo main
            movem.l a4-a6, -(sp)            ; Push dmabase, graphics.library, and VBR
            bsr.w   demomain
            movem.l (sp)+, a4-a6            ; Pop dmabase, bfx, VBR

            ; Restore everything
            bsr.s   .waiteof                ; Wait for the end of the frame
            bsr.s   .alloff                 ; Turn off all interrupts and dma

            move.l  (sp)+, VBINTVECTOR(a4)  ; Restore VBINTVECTOR
            move.l  38(a5), COP1LC(a6)      ; Restore system copper lists
            move.l  50(a5), COP2LC(a6)

            move.w  (sp)+, d0               ; Restore DMACON
            or.w    #$8000, d0
            move.w  d0, DMACON(a6)

            move.w  (sp)+, d0               ; Restore INTENA
            or.w    #$8000, d0
            move.w  d0, INTENA(a6)

            move.l  a5, a6                  ; Restore OS screen (graphics.library)
            move.l  34(a6), a1
            jsr     -222(a6)                ; TODO: Find graphics.library function definitions

            move.l  a6, a1                  ; Close graphics.library
            move.l  EXECBASE, a6
            jsr     CloseLibrary(a6)

            bsr.w   demoexit

.niceexit:  moveq.l #0, d0
            rts

.errorexit: moveq.l #103, d0
            rts

.getvbr:    dc.w    $4e7a, $c801            ; 68010+ opcode "movec VBR, a4"
            rte                             ; return from Supervisor mode

.gfxname:   dc.b    "graphics.library", 0, 0

.waiteof:   move.w  #$4000, INTENA(a6)      ; Turn off interrupts completely
            bsr.s   WaitBlit                ; Wait for blitter to finish

            move.w  #$138, d0               ; Wait for line $138
.waitrast:  move.l  VPOSR(a6), d1
            lsr.l   #8, d1
            and.w   #$1ff, d1
            cmp.w   d0, d1
            bne.s   .waitrast
            rts

.alloff:    move.w  #$7fff, d2
            move.w  d2, DMACON(a6)
            move.w  d2, INTENA(a6)
            move.w  d2, INTREQ(a6)
            rts

WaitBlit:   ;tst.w   (a6)                   ; This instruction is only necessary for A1000 compatibility
.loop:      btst    #6, 2(a6)
            bne.s   .loop
            rts
