LIBS  = -lalleg $(shell allegro-config --static --libs release)

SRCS=$(wildcard *.cpp)
PROGS = $(patsubst %.cpp,%,$(SRCS))
CC=g++

OUT_DIR=bin
OUT_PROGS=$(addprefix $(OUT_DIR)/,$(PROGS))

all: $(OUT_PROGS)

$(OUT_DIR)/%: %.cpp
	$(CC) -o $@ $< $(LIBS)

clean:
	rm -f $(OUT_DIR)/*
