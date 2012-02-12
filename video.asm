bgSetup:
  php

  lda #$2     ;
  sta BGMODE  ; Set video mode 2

  lda #$04    ;
  sta BG1SC   ; bg1 map address to 0x400

  lda #$01    ;
  sta BG12NBA ; bg1's character vram offset to 0x2000

  lda #$01    ; enable bg1
  sta TM

  lda #$ff
  sta BG1VOFS
  sta BG1VOFS

  lda #$0f
  sta INIDISP

  plp
  rts

.macro vramLoadData ARGS SrcPtr, DstPtr, Size
  lda #$80
  sta VMAIN   ; Set VRAM transfer mode to word-access, increment by 1

  ldx #\2     ; DstPtr
  stx VMADDL  ; Word address for accessing VRAM

  lda #:\1    ; SrcBank
  ldx #\1     ; SrcOffset
  ldy #\3     ; Size
  jsr vramDmaCopyData

.endm


vramDmaCopyData:
  phb         ; Save current bank
  php         ; Save processor state

  stx A1T0L   ; Store Data offset into DMA source offset
  sta A1B0    ; Store Data Bank into DMA source bank
  sty DAS0L   ; Store Size of the data block

  lda #$01
  sta DMAP0   ; Set DMA mode (word, normal increment)
  lda #$18
  sta BBAD0   ; Set the destination register (VRAM write register)
  lda #$01
  sta MDMAEN  ; Start DMA transfer (chan:1)

  plp         ; Restore process state
  plb         ; Restore current bank

  rts         ; Return

.macro vramLoadPalette ARGS SrcPtr, StartColor, Size
  lda #\2
  sta CGADD
  lda #:\1
  ldx #\1
  ldy \3
  jsr vramDmaCopyPalette
.endm

vramDmaCopyPalette:
  phb
  php

  stx A1T0L
  sta A1B0
  sty DAS0L

  stz DMAP0
  lda #$22
  sta BBAD0
  lda #$01
  sta MDMAEN

  plp
  plb

  rts
