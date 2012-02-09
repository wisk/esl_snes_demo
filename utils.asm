  .macro DmaCopy ARGS SrcPtr, DstPtr, Size

  ; Set source
  ldx #\1
  stx A1T0L
  lda #:\1
  sta A1B0

  ; Set size
  ldx #\3
  stx DAS0L

  ;Set destination
  ldx #\3
  stx WMADDL
  lda #:\3
  sta WMADDH

  lda #$80
  sta BBAD0

  lda #$01
  sta DMAP0
  sta MDMAEN

.endm
