ifndef SPINC
	SPINC := openspin -q
endif

LFLAGS   := -L library/
FOLDERS  := library/

OBJECTS  := $(shell find $(FOLDERS) -name \*.spin )
BINARIES := $(OBJECTS:.spin=.binary)
ZIPS     := $(shell find . -name \*.zip)

PREFIX ?= .build

INSTALLS := $(patsubst %,$(PREFIX)/%,$(OBJECTS))


all: test

clean:
	rm -f $(BINARIES) $(ZIPS)
	rm -rf $(PREFIX)

media:
	./library/media/media.sh

release:
	./scripts/release.py $(RELEASE_TAG)

test: test_compile

test_compile: $(BINARIES)

%.binary: %.spin
	@FILE=$$(file $< | grep -v "ASCII" | grep -v "UTF-8"); if [ -z "$$FILE" ]; then exit 0 ; else exit 1; fi
	@FILE=$$(file $< | grep "line terminators"); if [ -z "$$FILE" ]; then exit 0 ; else exit 1 ; fi
	$(SPINC) $(LFLAGS) $<
