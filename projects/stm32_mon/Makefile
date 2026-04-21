AS=arm-none-eabi-as
LD=arm-none-eabi-ld
STFLASH=st-flash
CHIPS=/opt/stlink/config/chips/
OBJCOPY=arm-none-eabi-objcopy
GDB=gdb-multiarch
VI=vi
OPENOCD=openocd
ST_PROGRAMMER=~/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin/STM32_Programmer_CLI
MINICOM=minicom

BIN_DIR=bin
SRC_DIR=src
INC_DIR=inc

TARGET := $(notdir $(patsubst %/,%,$(CURDIR)))

SRC_FILE=$(SRC_DIR)/$(TARGET).s
OBJ_FILE=$(BIN_DIR)/$(TARGET).o
ELF_FILE=$(BIN_DIR)/$(TARGET).elf
BIN_FILE=$(BIN_DIR)/$(TARGET).bin
LST_FILE=$(BIN_DIR)/$(TARGET).lst
STARTUP_FILE=$(SRC_DIR)/startup.s

ASFLAGS=-mcpu=cortex-m4 -g -I ../inc -I inc/
OPENOCD_FLAGS=-f interface/stlink-v2.cfg -f target/stm32f3x.cfg 
FLASH_FLAGS= --reset --connect-under-reset write $(ELF) 0x08000000
ST_PROGRAMMER_FLAGS=--connect port=SWD -d 
MINICOM_FLAGS=-D /dev/ttyUSB0 -b 57600
OBJCOPY_FLAGS=-O binary

.phony: all, link, build, openocd, debug, flash, edit, uart, bin, clean

all: link

link: build
	$(LD) $(OBJ_FILE) bin/startup.o bin/string.o bin/constants.o bin/ascii.o -o $(ELF_FILE) -T linker.ld -Map bin/uart.map

build:
	$(AS) $(ASFLAGS) -o bin/startup.o $(STARTUP_FILE) -ahls > bin/startup.lst
	$(AS) $(ASFLAGS) -o bin/string.o src/string.s -ahls > bin/string.lst
	$(AS) $(ASFLAGS) -o bin/constants.o src/constants.s -ahls > bin/constants.lst
	$(AS) $(ASFLAGS) -o bin/ascii.o src/ascii.s -ahls > bin/ascii.lst
	$(AS) $(ASFLAGS) -o $(OBJ_FILE) $(SRC_FILE) -ahls > $(LST_FILE)

openocd:
	$(OPENOCD) $(OPENOCD_FLAGS)

debug: link
	$(GDB) $(ELF_FILE)

flash: link

	$(ST_PROGRAMMER) $(ST_PROGRAMMER_FLAGS) $(ELF_FILE)

edit:
	$(VI) $(SRC_FILE)

uart: link
	
	$(MINICOM) $(MINICOM_FLAGS)

bin: link
	$(OBJCOPY) $(OBJCOPY_FLAGS) $(ELF_FILE) $(BIN_FILE)
	
clean:
	rm -rf $(BIN_DIR)/*
