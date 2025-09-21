CC = cc
BUILD = debug

SRC_DIR = src
OBJ_DIR = build/$(BUILD)
BIN_DIR = bin
TARGET = $(BIN_DIR)/irix-ide-motif

OBJECTS = \
    $(OBJ_DIR)/main.o \
    $(OBJ_DIR)/ui_shell.o

CFLAGS_DEBUG = -g -O0
CFLAGS_RELEASE = -O2
CFLAGS_COMMON = -I$(SRC_DIR) -I/usr/include -I/usr/include/X11 -I/usr/include/Xm

ifeq ($(BUILD),release)
CFLAGS = $(CFLAGS_COMMON) $(CFLAGS_RELEASE)
else
CFLAGS = $(CFLAGS_COMMON) $(CFLAGS_DEBUG)
endif

LDFLAGS = -L/usr/lib32 -lXm -lXt -lX11

all: $(TARGET)

$(TARGET): $(OBJ_DIR) $(OBJECTS)
	@if [ ! -d $(BIN_DIR) ]; then mkdir -p $(BIN_DIR); fi
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@

$(OBJ_DIR):
	@if [ ! -d $(OBJ_DIR) ]; then mkdir -p $(OBJ_DIR); fi

$(OBJ_DIR)/main.o: $(SRC_DIR)/main.c $(SRC_DIR)/ui_shell.h | $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $(SRC_DIR)/main.c -o $(OBJ_DIR)/main.o

$(OBJ_DIR)/ui_shell.o: $(SRC_DIR)/ui_shell.c $(SRC_DIR)/ui_shell.h | $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $(SRC_DIR)/ui_shell.c -o $(OBJ_DIR)/ui_shell.o

clean:
	rm -rf build $(BIN_DIR)

.PHONY: all clean
