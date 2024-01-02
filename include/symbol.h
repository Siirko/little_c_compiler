#pragma once
#include "hashmap.h"

// X macros for a map with enum as key and value
#define SYMBOL_TYPE_MAP                                                                                      \
    X(TYPE_ITERATOR, "iterator")                                                                             \
    X(TYPE_VARIABLE, "variable")                                                                             \
    X(TYPE_CONST, "const")                                                                                   \
    X(TYPE_FUNCTION, "function")                                                                             \
    X(TYPE_KEYWORD, "keyword")

#define DATA_TYPE_MAP                                                                                        \
    X(TYPE_INT, "int")                                                                                       \
    X(TYPE_STR, "str")                                                                                       \
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

#define SYMBOL_MAX_SIZE 1024

typedef struct symbol
{
    char id[SYMBOL_MAX_SIZE];
    enum symbol_type type;
    enum data_type data_type;
    int line;
} symbol_t;

typedef struct scope
{
    int depth;
    int width;
} scope_t;

void init_scope_key(hashmap_t *symbol_table, char *key);

scope_t get_scope(hashmap_t *symbol_table, int current_depth, char *key, char *function_name);

void add_symbol_to_scope(hashmap_t *symbol_table, int scope, char *key, enum symbol_type type,
                         enum data_type *data_type, char *yytext, int counter);

void add_symbol(hashmap_t *symbol_table, enum symbol_type type, enum data_type *data_type, char *yytext,
                int counter);

void show_symbol(char *id, void *symbol);

void free_scopes(char *id, void *scopes);

void show_symbol_table(hashmap_t *symbol_table);

int cmp_symbol(const void *a, const void *b);
