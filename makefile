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
	$(SPINC) $^ $(LFLAGS) | grep -v "|-"
