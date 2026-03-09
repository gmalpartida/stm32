AS=/opt/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-as 
#AS=/opt/arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-as
LD=/opt/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-ld
#LD=/opt/arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-ld
STFLASH=/opt/stlink/bin/st-flash
CHIPS=/opt/stlink/config/chips/
OBJCOPY=/opt/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-objcopy
#OBJCOPY=/opt/arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-objcopy
GDB=/opt/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-gdb
#GDB=/opt/arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-gdb
VI=vi
OPENOCD=openocd
MINICOM=minicom

SRC=src/test.asm
TARGET=bin/test
OBJ=$(TARGET).o
ELF=$(TARGET).elf
BIN=$(TARGET).bin

ASFLAGS=-g -I ../inc -I inc/
OPENOCD_FLAGS=-f interface/stlink-v2.cfg -f target/stm32f3x.cfg 
FLASH_FLAGS= --reset write $< 0x08000000
MINICOM_FLAGS= -D /dev/ttyUSB0 -b 9600

all: link

bin: link
	$(OBJCOPY) -O binary $(ELF) $(BIN)

link: build
	$(LD) $(OBJ) -o $(ELF) -Ttext=0x08000000

build:
	$(AS) $(ASFLAGS) $(SRC) -o $(OBJ)

flash: link
	$(STFLASH) $(FLASH_FLAGS)

openocd:
	$(OPENOCD) $(OPENOCD_FLAGS) 

debug: link
	$(GDB) $(ELF)

edit:
	$(VI) $(SRC)

uart:
	$(MINICOM) $(MINICOM_FLAGS)

clean:
	rm -f bin/*
