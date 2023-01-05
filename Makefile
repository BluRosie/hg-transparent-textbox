# Makefile
ifeq ($(strip $(DEVKITPRO)),)
$(error "Please set DEVKITPRO in your environment. export DEVKITPRO=<path to>devkitPro)
endif

ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif

TOOLCHAIN := $(DEVKITARM)

.PHONY: clean all


ifeq ($(OS),Windows_NT)
EXE := .exe
else
EXE := .exe
endif

default: all

ROMNAME = rom.nds
BUILDROM = test.nds
####################### Tools #########################
MSGENC = tools/msgenc$(EXE)
NITROGFX = tools/nitrogfx$(EXE)
NDSTOOL = tools/ndstool$(EXE)
JSONPROC = tools/jsonproc$(EXE)
O2NARC = tools/o2narc$(EXE)
KNARC = tools/knarc$(EXE)
BLZ = tools/blz$(EXE)
ARMIPS = tools/armips$(EXE)
POKEPICTOOL = tools/pokepic$(EXE)
NARCHIVE = tools/narchive$(EXE)
####################### Seting ########################
PREFIX = bin/arm-none-eabi-
AS = $(DEVKITARM)/$(PREFIX)as
CC = $(DEVKITARM)/$(PREFIX)gcc
LD = $(DEVKITARM)/$(PREFIX)ld
OBJCOPY = $(DEVKITARM)/$(PREFIX)objcopy

LDFLAGS = rom.ld -T linker.ld
ASFLAGS = -mthumb -I ./data
CFLAGS = -mthumb -mno-thumb-interwork -mcpu=arm7tdmi -mtune=arm7tdmi -mno-long-calls -march=armv4t -Wall -Wextra -Os -fira-loop-pressure -fipa-pta

PYTHON = python3
LINK = build/linked.o
OUTPUT = build/output.bin
####################### output #########################
C_SUBDIR = src
ASM_SUBDIR = asm
ARMIPS_SUBDIR = armips/asm
INCLUDE_SUBDIR = include
BUILD = build

INCLUDE_SRCS := $(wildcard $(INCLUDE_SUBDIR)/*.h)

C_SRCS := $(wildcard $(C_SUBDIR)/*.c)
C_OBJS := $(patsubst $(C_SUBDIR)/%.c,$(BUILD)/%.o,$(C_SRCS))

ASM_SRCS := $(wildcard $(ASM_SUBDIR)/*.s)
ASM_OBJS := $(patsubst $(ASM_SUBDIR)/%.s,$(BUILD)/%.d,$(ASM_SRCS))
OBJS     := $(C_OBJS) $(ASM_OBJS)

ARMIPS_SRCS := $(wildcard $(ARMIPS_SUBDIR)/*.s)

OW_SPRITES_SRC := $(wildcard data/graphics/overworlds/*.png)
OW_SPRITES_OBJS := $(patsubst data/graphics/overworlds/*.png,build/data/graphics/overworlds/%.swav,$(OW_SPRITES_SRC))

####################### Build #########################
build/%.d:asm/%.s
	$(AS) $(ASFLAGS) -c $< -o $@

build/%.o:src/%.c
	mkdir -p build
	@echo -e "\e[32;1mCompiling $<\e[37;1m"
	$(CC) $(CFLAGS) -c $< -o $@

$(LINK):$(OBJS)
	$(LD) $(LDFLAGS) -o $@ $(C_OBJS) $(ASM_OBJS)

$(OUTPUT):$(LINK)
	$(OBJCOPY) -O binary $< $@

all: $(OUTPUT)
	rm -rf base
	mkdir -p base build
	$(NDSTOOL) -x $(ROMNAME) -9 base/arm9.bin -7 base/arm7.bin -y9 base/overarm9.bin -y7 base/overarm7.bin -d base/root -y base/overlay -t base/banner.bin -h base/header.bin
	@echo -e "\e[32;1m$(ROMNAME) Decompression successful!!\e[37;1m"
	$(NARCHIVE) extract base/root/a/0/2/8 -o build/a028/ -nf
	$(PYTHON) scripts/make.py
	$(ARMIPS) $(ARMIPS_SRCS)
	$(MAKE) move_narc
	$(NARCHIVE) create build/synth.narc build/a028/ -nf
	cp build/synth.narc base/root/a/0/2/8
	@echo -e "\e[32;1mMaking ROM..\e[37;1m"
	$(NDSTOOL) -c $(BUILDROM) -9 base/arm9.bin -7 base/arm7.bin -y9 base/overarm9.bin -y7 base/overarm7.bin -d base/root -y base/overlay -t base/banner.bin -h base/header.bin
	@echo -e "\e[32;1mDone.\e[37;1m"

clean:
	rm -rf build/*

move_narc:
	# font edit
	$(NARCHIVE) extract base/root/a/0/1/6 -o build/font -nf
	cp -r data/rawdata/font/. build/font
	$(NARCHIVE) create base/root/a/0/1/6 build/font -nf

	# textbox graphic?
	$(NARCHIVE) extract base/root/a/0/3/8 -o build/textbox -nf
	cp -r data/rawdata/textbox/. build/textbox
	$(NARCHIVE) create base/root/a/0/3/8 build/textbox -nf
