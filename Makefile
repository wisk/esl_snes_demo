AS = wla-65816
ASFLAGS = -oxi
LD = wlalink
LDFLAGS = -vSi

ASFILES = main.asm
ICFILES = header.inc
OFILES = $(ASFILES:.asm=.o)
TARGET = esl-demo.sfc

all: $(TARGET)

.asm.o:
	$(AS) $(ASFLAGS) $< $@

$(TARGET): $(OFILES)
	@echo "[objects]" > link.txt
	@echo ${OFILES} >> link.txt
	$(LD) $(LDFLAGS) link.txt $(TARGET)
	@rm -f link.txt

clean:
	rm -f ${OFILES} ${TARGET} *.lst *.sym

# sixpack -width 256 -height 200 -q 4 -image -opt -v -target snes -o esl_logo esl_logo.bmp

.PHONY: clean
.SUFFIXES: .asm
