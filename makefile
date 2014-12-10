SPINC := openspin
LFLAGS := -L.

OBJECTS := $(shell find . -name \*.spin)
BINARIES := $(OBJECTS:.spin=.binary)


all: test

clean:
	rm -f `find . -name \*.binary`

test: test_compile

test_compile: $(BINARIES)

%.binary: %.spin
	@echo -n "File encoding: "
	@FILE=$$(file $< | grep -v "ASCII" | grep -v "UTF-8"); if [ -z "$$FILE" ]; then echo 'OKAY'; else exit 1; fi
	@echo -n "Line termination: "
	@FILE=$$(file $< | grep "line terminators"); if [ -z "$$FILE" ]; then echo 'OKAY'; else exit 1 ; fi
	$(SPINC) $< $(LFLAGS) | grep -v "|-"
