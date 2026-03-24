CC = /opt/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-gcc
OBJCOPY=/opt/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-objcopy
STFLASH=/opt/stlink/bin/st-flash
CHIPS=/opt/stlink/config/chips/

CFLAGS = -mcpu=cortex-m4 -mthumb -Wall -Wextra -Wshadow -Werror -Wundef -Wfloat-equal
LDFLAGS = -T src/link.ld -nostdlib
LIBS = -lc -lm -lgcc

SRC=src/main.c
ELF=bin/main.elf
OBJ=bin/main.o
BIN=bin/bare_blinky.bin

#build target

build: $(BIN)

#convert ELf to binary
$(BIN): $(ELF)
	$(OBJCOPY) -O binary $< $@

#link object files to create elf file
$(ELF): $(OBJ)
	$(CC) $(LDFLAGS) $^ $(LIBS) -o $@

# compile C source to object file
$(OBJ): $(SRC)
	$(CC) $(CFLAGS) -c $< -o $@

# upload binary to stm32
upload: $(BIN)
	$(STFLASH) --reset write $< 0x08000000

#clean files
clean:
	rm -f bin/*
