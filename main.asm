.include "header.inc"
.include "register.inc"

.include "esl_logo.inc"

.include "snes_init.asm"
.include "utils.asm"
.include "video.asm"

.bank 0 slot 0
.org 0
.section "MainCode"

Start:
  SnesInit

  ; Copy palette
  DmaCopy EslLogoPalBeg, CGADD, EslLogoPalEnd - EslLogoPalBeg

  ; Copy pattern
  DmaCopy EslLogoPatBeg, $0000, EslLogoPatEnd - EslLogoPatBeg

  ; Copy map
  ;DmaCopy EslLogoMapBeg, , EslLogoMapEnd - EslLogoMapBeg

      lda #$80
          sta $2115
              ldx #$0400
                  stx $2116
                      lda #$01
                          sta $2118

  jsr SetupVideo

loop: jmp loop

.ends
