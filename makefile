CC ?= gcc
CFLAGS ?= -Wall -g -Wno-unused-variable
LDLIBS ?=  

EXEC = main
LEXICAL_FILE := lexical

SRC_PATH = ./src
OBJ_PATH = ./obj
BIN_PATH = ./bin
INCLUDE_PATH ?= ./include

SOURCES  := $(wildcard $(SRC_PATH)/*.c)
INCLUDES := $(wildcard $(INCLUDE_PATH)/*.h)
OBJECTS  := $(SOURCES:$(SRC_PATH)/%.c=$(OBJ_PATH)/%.o)


all: $(BIN_PATH)/$(EXEC)

$(BIN_PATH)/$(EXEC): $(OBJECTS) $(SRC_PATH)/$(LEXICAL_FILE).c
	mkdir -p $(BIN_PATH)
	$(CC) -o $@ $(OBJECTS) $(LDLIBS) $(SRC_PATH)/$(LEXICAL_FILE).c -I$(INCLUDE_PATH) $(CFLAGS)
	@echo "Linking complete!"

$(OBJECTS): $(OBJ_PATH)/%.o : $(SRC_PATH)/%.c
	mkdir -p $(OBJ_PATH)
	$(CC) -o $@ -c $< $(CFLAGS) -I$(INCLUDE_PATH)

$(SRC_PATH)/$(LEXICAL_FILE).c: $(SRC_PATH)/$(LEXICAL_FILE).l
	flex -o $(SRC_PATH)/$(LEXICAL_FILE).c $(SRC_PATH)/$(LEXICAL_FILE).l

.PHONY: clean
clean:
	rm -fr $(OBJ_PATH)
	rm -fr $(BIN_PATH)
	rm -fr $(SRC_PATH)/$(LEXICAL_FILE).c