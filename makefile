ifndef SPINC
	SPINC := openspin -q
endif

LFLAGS := -L library/
FOLDERS := .

OBJECTS := $(shell find $(FOLDERS) -name \*.spin )
BINARIES := $(OBJECTS:.spin=.binary)

PREFIX ?= .build

INSTALLS := $(patsubst %,$(PREFIX)/%,$(OBJECTS))


all: test

clean:
	rm -f $(BINARIES)
	rm -rf $(PREFIX)

build_media:
	./media/media.sh

test: test_compile

test_compile: $(BINARIES)

%.binary: %.spin
	@FILE=$$(file $< | grep -v "ASCII" | grep -v "UTF-8"); if [ -z "$$FILE" ]; then exit 0 ; else exit 1; fi
	@FILE=$$(file $< | grep "line terminators"); if [ -z "$$FILE" ]; then exit 0 ; else exit 1 ; fi
	$(SPINC) $(LFLAGS) $<
