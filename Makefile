AS = wla-huc6280
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

.PHONY: clean
.SUFFIXES: .asm
