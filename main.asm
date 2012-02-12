.include "header.inc"
.include "register.inc"

.include "esl_logo.inc"

.include "snes_init.asm"
.include "utils.asm"
.include "video.asm"

.bank 0 slot 0
.org 0
.section "MainCode"

VblankHandler:
  rti

Start:
  SnesInit

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

loop: jmp loop

.ends

.emptyfill $00
