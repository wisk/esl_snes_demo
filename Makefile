AS = wla-65816
ASFLAGS = -oxi

LD = wlalink
LDFLAGS = -vSi

SIXPACK = sixpack
SIXPACK_FLAGS = -image -opt -v -target snes
SIXPACK_FLAGS_P8 = ${SIXPACK_FLAGS} -q 32 -format p4


ASFILES = main.asm
ICFILES = header.inc
OFILES = $(ASFILES:.asm=.o)

BMPFILES = img/esl_logo.bmp
PATFILES = $(BMPFILES:.bmp=.pat)
PALFILES = $(BMPFILES:.bmp=.pal)
NAMFILES = $(BMPFILES:.bmp=.nam)

TARGET = esl-demo.sfc


.PHONY: clean
.SUFFIXES: .asm .bmp .pat .pal .nam

all: $(TARGET)

.bmp.pat:
	$(eval PAT_FILE := $(shell echo $< | sed -e 's/.bmp/.pat/'))
	$(eval PAL_FILE := $(shell echo $< | sed -e 's/.bmp/.pal/'))
	$(eval NAM_FILE := $(shell echo $< | sed -e 's/.bmp/.nam/'))
	$(eval FILE     := $(shell echo $< | sed -e 's/.bmp//'    ))

	$(SIXPACK) $(SIXPACK_FLAGS_P8) -o $(FILE) $<
	mv $(FILE) $(PAT_FILE)

.asm.o:
	$(AS) $(ASFLAGS) $< $@

$(TARGET): $(PATFILES) $(PALFILES) $(NAMFILES) $(OFILES)
	@echo "[objects]" > link.txt
	@echo ${OFILES} >> link.txt
	$(LD) $(LDFLAGS) link.txt $(TARGET)
	@rm -f link.txt
	@mv esl-demo.sym esl-demo.symb

clean:
	rm -f ${OFILES} ${PATFILES} ${PALFILES} ${NAMFILES} *.lst *.sym

fclean: clean
	rm -f ${TARGET}
