.include "header.inc"
.include "register.inc"

.include "esl_logo.inc"

.include "snes_init.asm"
.include "utils.asm"
.include "video.asm"

.bank 0 slot 0
.org 0
.section "MainCode"

.define VblankValue $1f00
.define MosaicValue $1f02

VblankHandler:
  php

  sep #$10

  lda hdmaWaveEffectOffset
  ina

  cmp #$e0
  bcc store_wave_offset

  lda #$00
  pha
  lda hdmaWaveType
  cmp #$02
  bne set_horiz_wave

  lda #$04
  sta hdmaWaveType
  pla
  bra store_wave_offset

set_horiz_wave:
  lda #$02
  sta hdmaWaveType
  pla

store_wave_offset:
  sta hdmaWaveEffectOffset

  rep #$10

  jsr hdmaUpdateWaveEffect

  rep #$10      ; 16-bit x,y
  sep #$20      ; 8-bit a

  lda VblankValue
  ina
  sta VblankValue

  and #$07        ; Slow down the mosaic effect
  bne skip_mosaic

  lda MosaicValue

  cmp #$1f
  beq inc_mosaic

  cmp #$10
  beq inc_mosaic

  cmp #$0f
  bpl dec_mosaic

inc_mosaic:
  ina
  and #$0f
  sta MosaicValue
  bra update_mosaic

dec_mosaic:
  dea
  ora #$10
  sta MosaicValue

update_mosaic:
  asl a
  asl a
  asl a
  asl a
  and #$f0
  ora #$0f
  ;sta MOSAIC

skip_mosaic:

  plp

  rti

Start:
  SnesInit

  stz VblankValue
  stz MosaicValue

  lda #$80
  sta NMITIMEN

  rep #$10      ; 16-bit x,y
  sep #$20      ; 8-bit a

  ; Copy palette using the CPU
  ldx #$0000
pal_cpy:
  lda.w EslLogoPalBeg, x
  sta CGDATA
  inx
  cpx #$200
  bne pal_cpy


  ; Copy pattern
  vramLoadData EslLogoPatBeg, $1000, EslLogoPatEnd - EslLogoPatBeg

  ; Copy map
  vramLoadData EslLogoMapBeg, $400, EslLogoMapEnd - EslLogoMapBeg

  jsr bgSetup

  jsr hdmaSetupWaveEffect

loop:
  ;wai
  jmp loop

.ends

.emptyfill $00
