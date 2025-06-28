            INCLUDE     "startup.S"

demoinit:   move.l  EXECBASE, a6          ; Allocate some memory for copper
            move.l  #16384, d0
            move.l  #MEMF_CLEARCHIP, d1
            jsr     AllocMem(a6)
            tst.l   d0
            beq.S   .error

            move.l  d0, copperaddr

            moveq.l #0, d0
            rts

.error      moveq.l #1, d0
            rts

demoexit:   move.l  EXECBASE, a6          ; Free copper memory
            move.l  copperaddr, a1
            move.l  #16384, d0
            jsr     FreeMem(a6)

            rts

demomain:   move.w  #$87e0, DMACON(a6)  ; Enable some DMA
            move.l  #copper, COP1LC(a6)
            move.w  #$0a29, PALETTE0(a6)

waitmouse:
            btst #6, $bfe001            ; Check mouse button state
            bne waitmouse               ; If not pressed, loop
            rts

            SECTION vars, DATA          ; Change this to the uninitialized type of data block
copperaddr: ds.l    1

            SECTION copper, DATA_C
copper:     dc.w    $01fc,      $0000   ; Enable slow fetch mode for AGA compatibility
            dc.w    BPLCON0,    $0200   ; Disable all bitplanes (keep only the background color)
            dc.w    PALETTE0,   $0000   ; Black background

            dc.w    $3c07,      $fffe   ; Wait for line $3c
            dc.w    PALETTE0,   $0129   ; Dark blue background
            dc.w    $3f07,      $fffe   ; Wait for line $3f
            dc.w    PALETTE0,   $023a   ; Dark blue background

            dc.w    $ffdf,      $fffe   ; Wait for end of 8 bit V resolution
            dc.w    $1907,      $fffe   ; Wait for line $139
            dc.w    PALETTE0,   $034b   ; Dark blue background
            dc.w    $1c07,      $fffe   ; Wait for line $13c
            dc.w    PALETTE0,   $0000   ; Black background

            dc.w    $ffff,      $fffe   ; End of copper list

