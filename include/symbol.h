#pragma once
#include "hashmap.h"

// X macros for a map with enum as key and value
#define SYMBOL_TYPE_MAP                                                                                      \
    X(TYPE_VARIABLE, "variable")                                                                             \
    X(TYPE_CONST, "const")                                                                                   \
    X(TYPE_FUNCTION, "function")                                                                             \
    X(TYPE_KEYWORD, "keyword")

#define DATA_TYPE_MAP                                                                                        \
    X(TYPE_INT, "int")                                                                                       \
    X(TYPE_FLOAT, "float")                                                                                   \
    X(TYPE_NAD, "NaD")

#define X(a, b) a,
enum symbol_type
{
    SYMBOL_TYPE_MAP
};

enum data_type
{
    DATA_TYPE_MAP
};
#undef X

#define X(a, b) [a] = b,
static const char *symbol_type_str[] = {SYMBOL_TYPE_MAP};
static const char *data_type_str[] = {DATA_TYPE_MAP};
#undef X

typedef struct symbol
{
    char id[1024];
    enum symbol_type type;
    enum data_type data_type;
    int line;
} symbol_t;

void add_symbol(hashmap_t *symbol_table, enum symbol_type type, enum data_type *data_type, char *yytext,
                int *counter);

void show_symbol(char *id, void *symbol);

void show_symbol_table(hashmap_t *symbol_table);

int cmp_symbol(const void *a, const void *b);
