SetupVideo:
  php

  stz BGMODE ; Set video mode 0, 8x8 tiles, 4 color bg 1,2,3,4

  lda #$04  ; 
  sta BG1SC ; bg1 tmap size to 32x32

  stz BG12NBA ; bg1's character vram offset to 0x0

  lda #$01 ; enable bg1
  sta TM

  lda #$ff
  sta BG1VOFS
  sta BG1VOFS

  lda #$0f
  sta INIDISP

  plp
  rts
