CC ?= gcc
CFLAGS ?= -Wall -g
LDLIBS ?=  

EXEC = cmat
LEXICAL_FILE := cmat_lex
BISON_FILE := cmat_yacc

SRC_PATH = ./src
OBJ_PATH = ./obj
BIN_PATH = ./bin
INCLUDE_PATH ?= ./include

SOURCES  := $(wildcard $(SRC_PATH)/*.c)
INCLUDES := $(wildcard $(INCLUDE_PATH)/*.h)
OBJECTS  := $(SOURCES:$(SRC_PATH)/%.c=$(OBJ_PATH)/%.o)


all: $(BIN_PATH)/$(EXEC)

$(BIN_PATH)/$(EXEC): $(OBJECTS) $(SRC_PATH)/$(BISON_FILE).c $(SRC_PATH)/$(LEXICAL_FILE).c
	mkdir -p $(BIN_PATH)
	$(CC) -o $@ $(OBJECTS) $(CFLAGS) $(LDLIBS) $(SRC_PATH)/$(LEXICAL_FILE).c $(SRC_PATH)/$(BISON_FILE).c -I$(INCLUDE_PATH)
	@echo "Linking complete!"

$(OBJECTS): $(OBJ_PATH)/%.o : $(SRC_PATH)/%.c
	mkdir -p $(OBJ_PATH)
	$(CC) -o $@ -c $< $(CFLAGS) -I$(INCLUDE_PATH)

$(SRC_PATH)/$(LEXICAL_FILE).c: $(SRC_PATH)/$(LEXICAL_FILE).l
	flex -o $(SRC_PATH)/$(LEXICAL_FILE).c $(SRC_PATH)/$(LEXICAL_FILE).l

$(SRC_PATH)/$(BISON_FILE).c: $(SRC_PATH)/$(BISON_FILE).y
	bison -d --debug $(SRC_PATH)/$(BISON_FILE).y -o $(SRC_PATH)/$(BISON_FILE).c

test_matriceC: src/Matrix/matrix.c
	mkdir -p $(BIN_PATH)
	$(CC) -o $(BIN_PATH)/test_matrix_C $(CFLAGS) src/Matrix/matrix.c src/Matrix/test_matrix_C.c  -Iinclude

generate_matrix_S: src/Matrix/matrix.c
	cd src/Matrix
	mips-linux-gnu-gcc -S -march=r2000 -mfp32 -o src/Matrix/matrix.s src/Matrix/matrix.c
	
.PHONY: clean
clean:
	rm -fr $(OBJ_PATH)
	rm -fr $(BIN_PATH)
	rm -fr $(SRC_PATH)/$(LEXICAL_FILE).c
	rm -fr $(SRC_PATH)/$(BISON_FILE).c
	rm -fr $(SRC_PATH)/$(BISON_FILE).h
