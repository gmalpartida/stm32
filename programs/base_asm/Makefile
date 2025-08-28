AS=/opt/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-as 
LD=/opt/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-ld
STFLASH=/opt/stlink/bin/st-flash
CHIPS=/opt/stlink/config/chips/
OBJCOPY=/opt/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-objcopy
GDB=/opt/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-gdb
VI=vi
OPENOCD=openocd

SRC=src/prog1.asm
TARGET=bin/prog1
OBJ=$(TARGET).o
ELF=$(TARGET).elf
BIN=$(TARGET).bin

ASFLAGS=-g -I ../inc -I inc/
OPENOCD_FLAGS=-f interface/stlink-v2.cfg -f target/stm32f3x.cfg 
FLASH_FLAGS= --reset write $< 0x08000000
build: $(ELF)

$(BIN): $(ELF)
	$(OBJCOPY) -O binary $< $@

$(ELF): $(OBJ)
	$(LD) $(OBJ) -o $(ELF) -Ttext=0x08000000

$(OBJ):
	$(AS) $(ASFLAGS) $(SRC) -o $(OBJ)

flash: $(BIN)
	$(STFLASH) $(FLASH_FLAGS)

openocd:
	$(OPENOCD) $(OPENOCD_FLAGS) 
debug: $(BIN)
	$(GDB) $(ELF)

edit:
	$(VI) $(SRC)

clean:
	rm -f bin/*
