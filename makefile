SPINC := openspin
LFLAGS := -L.

OBJECTS := $(shell git ls-files '*.spin')
BINARIES := $(OBJECTS:.spin=.binary)

PREFIX ?= out

TOOLS_DIR := tools

INSTALLS := $(patsubst %,$(PREFIX)/%,$(OBJECTS))


all: test tools

clean: tools_clean
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

.PHONY: tools
tools:
	$(MAKE) -C $(TOOLS_DIR)/

tools_clean:
	$(MAKE) -C $(TOOLS_DIR)/ clean


$(PREFIX):
	mkdir -p $(PREFIX)
