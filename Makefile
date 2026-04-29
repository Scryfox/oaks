TARGET_EXEC		:= demo

DEVKIT			:= /opt/devkitpro

BUILD_DIR		:= build
SRC_DIRS		:= source

SRCS			:= $(shell find $(SRC_DIRS) -name '*.c' -or -name '*.s')
OBJS			:= $(SRCS:%=$(BUILD_DIR)/%.o)

INC_DIRS		:= $(shell find $(SRC_DIRS) -type d)

GBA_INC_DIRS	:= $(patsubst %, $(DEVKIT)/%/include, $(shell ls $(DEVKIT) | grep ^lib))
INC_FLAGS		:= $(addprefix -I,$(INC_DIRS) $(GBA_INC_DIRS))

GBA_LIB_DIRS	:= $(patsubst %, $(DEVKIT)/%/lib, $(shell ls $(DEVKIT) | grep ^lib))
GBA_LIBS		:= $(shell find $(GBA_LIB_DIRS) -name 'lib*.a' -printf '%P ')
LIB_FLAGS		:= $(addprefix -L,$(GBA_LIB_DIRS)) $(patsubst lib%.a, -l%, $(GBA_LIBS))

CROSS			:= arm-none-eabi-
AS				:= $(CROSS)as
CC				:= $(CROSS)gcc
LD				:= $(CROSS)gcc
OBJCOPY			:= $(CROSS)objcopy

MODEL			:= -mthumb-interwork -mthumb -DDEV
SPECS			:= -specs=gba.specs

ASFLAGS			:= -mthumb-interwork
CFLAGS			:= $(INC_FLAGS) $(MODEL) -O2 -Wall -g
LDFLAGS			:= $(SPECS) $(MODEL) $(LIB_FLAGS) -g

IMG_DIR			:= images
SPRITE_DIR		:= $(IMG_DIR)/sprites
BG_DIR			:= $(IMG_DIR)/backgrounds

SPRITE_IMGS			:= $(shell find $(SPRITE_DIR) -name '*.png')
SPRITE_PAL_BINS		:= $(patsubst %.png, $(BUILD_DIR)/%.pal.bin, $(SPRITE_IMGS))
SPRITE_MAP_BINS		:= $(patsubst %.png, $(BUILD_DIR)/%.map.bin, $(SPRITE_IMGS))
SPRITE_TILE_BINS		:= $(patsubst %.png, $(BUILD_DIR)/%.img.bin, $(SPRITE_IMGS))
SPRITE_BINS		:= $(SPRITE_PAL_BINS) $(SPRITE_MAP_BINS) $(SPRITE_TILE_BINS)

BG_IMGS			:= $(shell find $(BG_DIR) -name '*.png')
BG_PAL_BINS		:= $(patsubst %.png, $(BUILD_DIR)/%.pal.bin, $(BG_IMGS))
BG_MAP_BINS		:= $(patsubst %.png, $(BUILD_DIR)/%.map.bin, $(BG_IMGS))
BG_TILE_BINS		:= $(patsubst %.png, $(BUILD_DIR)/%.img.bin, $(BG_IMGS))
BG_BINS		:= $(BG_PAL_BINS) $(BG_MAP_BINS) $(BG_TILE_BINS)

PROD_PREFIX		:= prod_

.PHONEY: clean dev run

all:
	@echo $(BG_DIR)

dev: $(BUILD_DIR)/$(TARGET_EXEC).gba

$(BUILD_DIR)/$(TARGET_EXEC).gba: $(BUILD_DIR)/$(TARGET_EXEC).bin $(BUILD_DIR)/$(TARGET_EXEC).gbfs
	cat $(BUILD_DIR)/$(TARGET_EXEC).bin $(BUILD_DIR)/$(TARGET_EXEC).gbfs > $(BUILD_DIR)/$(TARGET_EXEC).gba
	gbafix -tScryfox $(BUILD_DIR)/$(TARGET_EXEC).gba

$(BUILD_DIR)/$(TARGET_EXEC).gbfs: $(BG_BINS) $(SPRITE_BINS)
	gbfs $@ $(filter-out ".bin", $^)

$(BUILD_DIR)/$(BG_DIR)/%.pal.bin: $(BG_DIR)/%.png | $(BUILD_DIR)/$(BG_DIR)
	grit $^ -W1 -gt -gB4 -mR4 -mLs -ftb -o $@

$(BUILD_DIR)/$(SPRITE_DIR)/%.pal.bin: $(SPRITE_DIR)/%.png | $(BUILD_DIR)/$(SPRITE_DIR)
	grit $^ -W1 -gt -gB4 -ftb -o $@

$(BUILD_DIR)/$(TARGET_EXEC).bin: $(BUILD_DIR)/$(TARGET_EXEC).elf
	$(OBJCOPY) -O binary $(BUILD_DIR)/$(TARGET_EXEC).elf $(BUILD_DIR)/$(TARGET_EXEC).bin
	padbin 256 $(BUILD_DIR)/$(TARGET_EXEC).bin

$(BUILD_DIR)/$(TARGET_EXEC).elf: $(OBJS)
	$(info	Objects are $^)
	$(CC) $^ $(LDFLAGS) -o $(BUILD_DIR)/$(TARGET_EXEC).elf

$(BUILD_DIR)/%.c.o: %.c | $(BUILD_DIR)/$(SRC_DIRS)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR):
	@mkdir -p $@

$(BUILD_DIR)/$(BG_DIR): $(BUILD_DIR)
	@mkdir -p $@

$(BUILD_DIR)/$(SPRITE_DIR): $(BUILD_DIR)
	@mkdir -p $@

$(BUILD_DIR)/$(SRC_DIRS): $(BUILD_DIR)
	@mkdir -p $@

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

run: $(BUILD_DIR)/$(TARGET_EXEC).gba
	mgba $(BUILD_DIR)/$(TARGET_EXEC).gba

clean: 
	rm -r build