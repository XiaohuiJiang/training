# Makefile for the Linux kernel wrapper used by SafeG
# 2012 (c) Daniel Sangorrin <daniel.sangorrin@gmail.com>
.PHONY: all clean

TARGET ?= vexpress-a9

include ../target/$(TARGET)/Makefile.target

AS      = $(TOOLPREFIX)-gcc -g
LD      = $(TOOLPREFIX)-gcc -g
OBJCOPY = $(TOOLPREFIX)-objcopy

BOOTLOADER = boot.S
LD_SCRIPT  = linker.lds

OBJNAME    = nt-linux

all: $(OBJNAME).bin

$(OBJNAME).elf: boot.o $(LD_SCRIPT)
	$(LD) -Wl,-Ttext,$(NORMAL_START_ADDRESS) -T $(LD_SCRIPT) -o $@

$(OBJNAME).bin: $(OBJNAME).elf
	$(OBJCOPY) -O binary -S $(OBJNAME).elf $(OBJNAME).bin

boot.o: $(BOOTLOADER)
	$(AS) -DTYPE=$(TYPE) -D'LINUX_BOOTARGS=$(LINUX_BOOTARGS)' -c -o $@ $<

clean:
	rm -f $(OBJNAME).elf $(OBJNAME).bin boot.o *~