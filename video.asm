bgSetup:
  php

  lda #$2     ;
  sta BGMODE  ; Set video mode 3

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

; Wave Effect Values
; source from http://www.smwcentral.net/?p=viewthread&t=39300
WaveTbl_Beg
WaveTbl:
  .dw $01
  .dw $02
  .dw $03
  .dw $04
  .dw $05
  .dw $06
  .dw $07
  .dw $07
  .dw $06
  .dw $05
  .dw $04
  .dw $03
  .dw $02
  .dw $01
  .dw $00
  .dw $ffff
  .dw $fffe
  .dw $fffd
  .dw $fffc
  .dw $fffb
  .dw $fffa
  .dw $fff9
  .dw $fff9
  .dw $fffa
  .dw $fffb
  .dw $fffc
  .dw $fffd
  .dw $fffe
  .dw $ffff
WaveTbl_End

.define hdmaWaveEffectOffset $7f0000
.define hdmaWaveType         $7f0001
.define hdmaWaveCounter      $7f0002
.define hdmaWaveEffectBuffer $7f0004

; hdmaWaveEffect
hdmaSetupWaveEffect
  phb
  php

  lda #$02
  sta DMAP1
  sta DMAP2

  lda #$04
  sta A1T1L
  stz A1T1H
  sta A1T2L
  stz A1T2H

  lda #$7f
  sta A1B1
  sta A1B2

  lda #$0d
  sta BBAD1
  lda #$0e
  sta BBAD2

  lda #$02
  sta hdmaWaveType

  lda #$00
  sta hdmaWaveEffectOffset

  plp
  plb

  rts

hdmaUpdateWaveEffect:
  php

  sep #$10
  ldx #0
  ldy #0

  lda hdmaWaveEffectOffset
  sta hdmaWaveCounter

  cmp #$80
  bcc next_offset_entry

  pha
  lda #$7f
  sta hdmaWaveEffectBuffer + 0, x
  lda #$00
  sta hdmaWaveEffectBuffer + 1, x
  sta hdmaWaveEffectBuffer + 2, x

  inx
  inx
  inx

  pla
  and #$7f

  cmp #$00
  beq wave_loop

next_offset_entry:
  sta hdmaWaveEffectBuffer + 0, x
  lda #$00
  sta hdmaWaveEffectBuffer + 1, x
  sta hdmaWaveEffectBuffer + 2, x

  inx
  inx
  inx

wave_loop:

  lda #$3
  sta hdmaWaveEffectBuffer + 0, x
  adc hdmaWaveCounter
  sta hdmaWaveCounter

  lda WaveTbl + 0, y
  sta hdmaWaveEffectBuffer + 1, x
  lda WaveTbl + 1, y
  sta hdmaWaveEffectBuffer + 2, x

  inx
  inx
  inx
  iny
  iny

  cpx #WaveTbl_End - WaveTbl_Beg - 2
  bcs end_wave

  lda hdmaWaveCounter
  cmp #$e0
  bcc wave_loop


end_wave:

  lda #$00
  sta hdmaWaveEffectBuffer + 3, x

  lda hdmaWaveType
  sta HDMAEN

  plp

  rts
