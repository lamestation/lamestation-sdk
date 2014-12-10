SPINC := openspin
LFLAGS := -L.

OBJECTS := $(shell find . -name \*.spin)
BINARIES := $(OBJECTS:.spin=.binary)


all: test

clean:
	echo $(BINARIES)


test: $(BINARIES)

%.binary: %.spin
	$(SPINC) $^ $(LFLAGS) | grep -v "|-"
