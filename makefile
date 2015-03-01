SPINC := openspin
LFLAGS := -L.

OBJECTS := $(shell git ls-files '*.lit')
BINARIES := $(OBJECTS:.spin=.binary)

PREFIX ?= out

INSTALLS := $(patsubst %,$(PREFIX)/%,$(OBJECTS))


all: test

clean:
	rm -f `find . -name \*.binary`
	rm -rf $(PREFIX)

test: test_compile

test_compile: $(BINARIES)

%.binary: %.spin
	@FILE=$$(file $< | grep -v "ASCII" | grep -v "UTF-8"); if [ -z "$$FILE" ]; then exit 0 ; else exit 1; fi
	@FILE=$$(file $< | grep "line terminators"); if [ -z "$$FILE" ]; then exit 0 ; else exit 1 ; fi
	$(SPINC) $< $(LFLAGS) 1>/dev/null

$(PREFIX)/%.spin: %.spin
	install -D -c -p -m 644 $< $@

install: $(INSTALLS)

$(PREFIX):
	mkdir -p $(PREFIX)
