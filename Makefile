CC := arm-none-eabi-gcc
DEVKIT := C:/devkitpro
TARGET := demo
BUILD := build
CFLAGS := -I$(DEVKIT)/libtonc/include -I$(DEVKIT)/libgba/include -I$(DEVKIT)/libgbfs/include -g -mthumb -DDEV
SRC := source
INC := include

SOURCES := $(wildcard $(SRC)/*.c)
OBJECTS := $(patsubst $(SRC)/%.c, $(BUILD)/%.o, $(SOURCES))

IMG := images
IMAGES := $(wildcard $(IMG)/*.png)
PALBINS := $(patsubst $(IMG)/%.png, $(BUILD)/$(IMG)/%.pal.bin, $(IMAGES))
MAPBINS := $(patsubst $(IMG)/%.png, $(BUILD)/$(IMG)/%.map.bin, $(IMAGES))
IMGBINS :=$(patsubst $(IMG)/%.png, $(BUILD)/$(IMG)/%.img.bin, $(IMAGES))
GFXBINS := $(PALBINS) $(MAPBINS) $(IMGBINS)


PROD_PREFIX := prod_

dev: $(BUILD)/$(TARGET).gba

$(BUILD)/$(TARGET).gba: $(BUILD)/$(TARGET).bin $(BUILD)/$(TARGET).gbfs
	cat $(BUILD)/$(TARGET).bin $(BUILD)/$(TARGET).gbfs > $(BUILD)/$(TARGET).gba
	gbafix -tScryfox $(BUILD)/$(TARGET).gba

$(BUILD)/$(TARGET).gbfs: $(GFXBINS)
	gbfs $@ $(filter-out ".bin", $^)

# TODO: Combine these if possible or make grit only output the needed portion
$(BUILD)/$(IMG)/%.pal.bin: $(IMG)/%.png | $(BUILD)/$(IMG)
	grit $< -W1 -gt -gB4 -mR4 -mLs -ftb -o $@

$(BUILD)/$(IMG)/%.map.bin: $(IMG)/%.png | $(BUILD)/$(IMG)
	grit $< -W1 -gt -gB4 -mR4 -mLs -ftb -o $@

$(BUILD)/$(IMG)/%.img.bin: $(IMG)/%.png | $(BUILD)/$(IMG)
	grit $< -W1 -gt -gB4 -mR4 -mLs -ftb -o $@

$(BUILD)/$(TARGET).bin: $(BUILD)/$(TARGET).elf
	arm-none-eabi-objcopy -O binary $(BUILD)/$(TARGET).elf $(BUILD)/$(TARGET).bin
	padbin 256 $(BUILD)/$(TARGET).bin

$(BUILD)/$(TARGET).elf: $(OBJECTS)
	$(info	Objects are $^)
	$(CC) $^ -L$(DEVKIT)/libgba/lib -lgba -lmm \
	-L$(DEVKIT)/libtonc/lib -ltonc \
	-L$(DEVKIT)/libgbfs/lib -lgbfs \
	-specs=gba.specs -g -mthumb -o $(BUILD)/$(TARGET).elf

$(BUILD)/%.o: $(SRC)/%.c | $(BUILD)
	$(CC) -I$(INC) $(CFLAGS) -c $< -o $@

$(BUILD):
	mkdir -p $@

$(BUILD)/$(IMG): $(BUILD)
	mkdir -p $@

# prod: $(BUILD)/$(PROD_PREFIX)$(TARGET).gba

# $(BUILD)/test_$(TARGET).gba: $(BUILD)/$(PROD)$(TARGET).elf
# 	arm-none-eabi-objcopy -O binary $(BUILD)/test_$(TARGET).elf $(BUILD)/test_$(TARGET).gba

# 	padbin 256 $(BUILD)/test_$(TARGET).gba
# 	padbin 256 $(BUILD)/test_$(TARGET).elf
# 	gbafix -tTestyCoyote $(BUILD)/test_$(TARGET).gba

# $(BUILD)/test_$(TARGET).elf: source/$(TARGET).c $(BUILD)/$(TARGET).s
# 	$(CC) $^ -I$(DEVKIT)/libtonc/include \
# 	-I$(DEVKIT)/libgba/include \
# 	-I$(DEVKIT)/libgbfs/include \
# 	-L$(DEVKIT)/libgba/lib -lgba -lmm \
# 	-L$(DEVKIT)/libtonc/lib -ltonc \
# 	-L$(DEVKIT)/libgbfs/lib -lgbfs \
# 	-Wl,--undefined=demo_gbfs \
# 	-specs=gba.specs -g -mthumb -o $(BUILD)/test_$(TARGET).elf

# $(BUILD)/$(TARGET).s: $(BUILD)/$(TARGET).gbfs
# 	bin2s $^ > $(BUILD)/$(TARGET).s

run: $(BUILD)/$(TARGET).gba
	mgba $(BUILD)/$(TARGET).gba

.PHONEY: clean

clean: 
	rm -r build