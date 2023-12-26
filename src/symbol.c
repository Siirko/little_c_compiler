#include "../include/symbol.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void add_symbol(hashmap_t *symbol_table, enum symbol_type type, enum data_type *data_type, char *yytext,
                int counter)
{
    symbol_t symbol = {
        .type = type,
        .data_type = type == TYPE_KEYWORD ? TYPE_NAD : *data_type,
        .line = counter,
    };
    memcpy(symbol.id, yytext, strlen(yytext) + 1);

    if (hashmap_get(symbol_table, yytext) == NULL)
        hashmap_insert(symbol_table, yytext, &symbol, sizeof(struct symbol));
}

void show_symbol(char *id, void *symbol)
{
    symbol_t *s = (symbol_t *)symbol;
    printf("%-10s%-10s%-10s%-10d\n", s->id, symbol_type_str[s->type], data_type_str[s->data_type], s->line);
}

void show_symbol_table(hashmap_t *symbol_table)
{
    printf("%-10s%-10s%-10s%-10s\n", "ID", "TYPE", "DATA_TYPE", "LINE");
    hashmap_iterate(symbol_table, show_symbol);
}

int cmp_symbol(const void *a, const void *b)
{
    int line_a = ((symbol_t *)a)->line;
    int line_b = ((symbol_t *)b)->line;
    if (line_a < line_b)
        return -1;
    else if (line_a > line_b)
        return 1;
    else
        return 0;
}