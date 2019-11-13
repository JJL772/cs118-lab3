#
# Makefile for Lab3
#
BIN = bin
SRC = $(wildcard src/*.S)
AS ?= as
LD ?= ld

ASFLAGS = --gstabs
LDFLAGS = -e _start

all: dirs
	@echo -e "\e[92m===== Building and Linking Lab3 =====\e[39m"
	$(AS) $(ASFLAGS) -o $(BIN)/main.o $(SRC)
	$(LD) -o $(BIN)/lab3 $(BIN)/main.o
	@echo -e "\e[92m=============== Done! ===============\e[39m"

dirs:
	mkdir -p $(BIN)

clean:
	rm -rf $(BIN)
