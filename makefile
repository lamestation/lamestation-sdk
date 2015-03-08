SPINC := openspin
LFLAGS := -L../lamestation-sdk

GRAPHICS := $(shell find . -name gfx)
OUT_GRAPHICS := $(patsubst %,$(PREFIX)/%,$(GRAPHICS))

LITFILES := $(shell git ls-files '*.spin.lit')
OBJECTS := $(LITFILES:.spin.lit=.spin)
DOCS := $(LITFILES:.spin.lit=.spin.md)
BINARIES := $(OBJECTS:.spin=.binary)

PREFIX ?= out
PREFIX_DOCS ?= $(PREFIX)/doc
PREFIX_SRC ?= $(PREFIX)/src
INSTALL_DOCS := $(patsubst %,$(PREFIX_DOCS)/%,$(DOCS))
INSTALL_SRC := $(patsubst %,$(PREFIX_SRC)/%,$(OBJECTS))

VERSION := $(shell git describe --tags)
YEAR := $(shell date +%Y)
DATE := $(shell date +%D)

all: build_code build_docs

clean:
	rm -f `find . -name \*.binary`
	rm -f `find . -name \*.spin`
	rm -f `find . -name \*.spin.md`
	rm -f `find . -name \*.spin.html`


test: build_code build_docs test_compile

build_code: $(OBJECTS)

build_docs: $(DOCS)

test_compile: $(BINARIES)

gfx:
	for f in $(GRAPHICS); \
		do \
		mkdir -p `dirname $(PREFIX_DOCS)/$$f`; \
		cp -a $$f $(PREFIX_DOCS)/$$f; \
		done

$(PREFIX_SRC)/%.spin: %.spin
	install -D -c -p -m 644 $< $@

%.spin: %.spin.lit
	lit -c --code-dir $(dir $< ) $<
	sed -i $@ \
		-e '1s@^@'\'' -------------------------------------------------------\n@g' \
		-e '1s@^@'\'' See end of file for terms of use.\n@g' \
		-e '1s@^@'\'' Copyright (c) $(YEAR) LameStation LLC\n@g' \
		-e '1s@^@'\'' Date: $(DATE)\n@g' \
		-e '1s@^@'\'' SDK Version: $(VERSION)\n@g' \
		-e '1s@^@'\'' -------------------------------------------------------\n@g' \
		-e '1s@^@'\'' $@\n@g'
#	cat license.stub >> $@

%.spin.md: %.spin.lit
	lit -m --docs-dir $(dir $< ) $<
	sed -i $@ \
		-e '1s@^@---\n@g' \
		-e '1s@^@date: $(DATE)\n@g' \
		-e '1s@^@version: $(VERSION)\n@g' \
		-e '1s@^@title: $@\n@g' \
		-e '1s@^@---\n@g' \
		-e '/<<.*>>/d'
	echo '\n```' >> $@
	cat `echo $@ | sed -e 's/.spin.md/.spin/g'` >> $@
	echo '\n```' >> $@

%.binary: %.spin
	$(SPINC) $< $(LFLAGS) 1>/dev/null

$(PREFIX_SRC)/%.spin: %.spin
	install -D -c -p -m 644 $< $@

$(PREFIX_DOCS)/%.spin.md: %.spin.md
	install -D -c -p -m 644 $< $@

install: $(INSTALL_SRC) $(INSTALL_DOCS) gfx

$(PREFIX_DOCS):
	mkdir -p $(PREFIX_DOCS)

$(PREFIX):
	mkdir -p $(PREFIX)
