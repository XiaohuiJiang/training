.PHONY: all clean

TARGET ?= vexpress-a9
BUILD  ?= debug

SRC   = arm.h nt_safeg_syscalls.h  safeg_measures.h  t_safeg_syscalls.h \
	crt0-safeg.S  safeg.S safeg.h safeg_start.c Makefile \
	safeg_syscalls.h target/$(TARGET)/Makefile.target

include target/$(TARGET)/Makefile.target

CC      = $(TOOLPREFIX)-gcc
CXX     = $(TOOLPREFIX)-cpp
AS      = $(TOOLPREFIX)-as
LD      = $(TOOLPREFIX)-ld
OBJCOPY = $(TOOLPREFIX)-objcopy
READELF = $(TOOLPREFIX)-readelf
NM      = $(TOOLPREFIX)-nm

OBJFLAGS  += -O srec --srec-forceS3 --srec-len 32
LDFLAGS   += -mcpu=$(CPU) -msoft-float -static -nostdlib -lgcc
CFLAGS    += -mcpu=$(CPU) -msoft-float -g -Wall -Wextra -Werror -I . \
	    -DSECURE_START_ADDRESS=$(SECURE_START_ADDRESS) \
	    -DNORMAL_START_ADDRESS=$(NORMAL_START_ADDRESS) \
	    -D__TARGET_ARCH_ARM=$(ARCH_ARM)

ifdef TEXT_START_ADDRESS
  LDFLAGS += -Wl,-Ttext,$(TEXT_START_ADDRESS)
endif
ifdef DATA_START_ADDRESS
  LDFLAGS += -Wl,-Tdata,$(DATA_START_ADDRESS)
endif

ifeq ($(BUILD),debug)
	CFLAGS += -O0
else
	CFLAGS += -O2
endif

all: safeg.bin

safeg.bin: safeg.elf $(SRC)
	$(OBJCOPY) -O binary -S safeg.elf safeg.bin

safeg.elf: safeg_start.o safeg.o crt0-safeg.o
	$(CC) $(LDFLAGS) -T safeg.lds $^ -o safeg.elf

safeg.sym: safeg.elf
	$(NM) safeg.elf > safeg.sym

safeg.o: safeg.i
safeg.i: safeg.S
crt0-safeg.o: crt0-safeg.i
crt0-safeg.i: crt0-safeg.S

%.o: %.S
	$(CC) -c $(CFLAGS) $<

%.o: %.c
	$(CC) -c $(CFLAGS) $<

clean:
	@find \( -name '*.elf' -or -name '*.bin' \
	         -or -name '*~*' -or -name '*.o' -or -name '*.i' \) -print -delete
