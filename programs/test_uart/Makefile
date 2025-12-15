#AS=/opt/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-as 
AS=arm-none-eabi-as
#LD=/opt/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-ld
LD=arm-none-eabi-ld
STFLASH=st-flash
CHIPS=/opt/stlink/config/chips/
#OBJCOPY=/opt/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-objcopy
OBJCOPY=arm-none-eabi-objcopy
#GDB=/opt/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-gdb
GDB=gdb-multiarch
VI=vi
OPENOCD=openocd
ST_PROGRAMMER=~/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin/STM32_Programmer_CLI

SRC=src/uart.asm
TARGET=bin/uart
OBJ=$(TARGET).o
ELF=$(TARGET).elf
BIN=$(TARGET).bin

ASFLAGS=-mcpu=cortex-m4 -g -I ../inc -I inc/
OPENOCD_FLAGS=-f interface/stlink-v2.cfg -f target/stm32f3x.cfg 
FLASH_FLAGS= --reset --connect-under-reset write $(ELF) 0x08000000
ST_PROGRAMMER_FLAGS=--connect port=SWD -d 



all: link

bin: link
	$(OBJCOPY) -O binary $(ELF) $(BIN)

link: build
	$(LD) $(OBJ) bin/startup.o -o $(ELF) -T linker.ld -Map bin/uart.map

build:
	$(AS) $(ASFLAGS) -o bin/startup.o src/startup.asm -ahls > bin/startup.lst
	$(AS) $(ASFLAGS) -o $(OBJ) $(SRC) -ahls > $(TARGET).lst

openocd:
	$(OPENOCD) $(OPENOCD_FLAGS) 

debug: link
	$(GDB) $(ELF)

flash:

	$(ST_PROGRAMMER) $(ST_PROGRAMMER_FLAGS) $(ELF)

edit:
	$(VI) $(SRC)

uart:
	
	minicom -D /dev/ttyUSB0 -b 9600

clean:
	rm -f bin/*
