#include "../include/symbol.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// to remove anoying warnings inused
// i placed this here. Same for quadr.c

#define X(a, b) [a] = b,
const char *symbol_type_str[] = {SYMBOL_TYPE_MAP};
const char *data_type_str[] = {DATA_TYPE_MAP};
#undef X

void init_scope_key(hashmap_t *symbol_table, char *key)
{
    // symbol_table is a hashmap<string, vector<vector<hashmap<string, symbol_t>>>>
    if (hashmap_get(symbol_table, key) == NULL)
    {
        vec_vec_hashmap_t v_scopes = {0};
        vec_push(&v_scopes, (vec_hashmap_t){0});
        vec_push(&v_scopes.data[0], hashmap_init(10));
        hashmap_insert(symbol_table, key, &v_scopes, sizeof(vec_vec_hashmap_t));
    }
}

void free_scopes(char *id, void *scopes)
{
    vec_vec_hashmap_t v_scopes = *(vec_vec_hashmap_t *)scopes;
    vec_hashmap_t tmp;
    int i;
    vec_foreach(&v_scopes, tmp, i)
    {
        int j;
        hashmap_t *tmp2;
        vec_foreach(&tmp, tmp2, j)
        {
            hashmap_free(tmp2);
            free(tmp2);
        }
        vec_deinit(&tmp);
    }
    vec_deinit(&v_scopes);
}

void add_symbol_to_scope(hashmap_t *symbol_table, int scope, char *key, enum symbol_type type,
                         enum data_type *data_type, char *yytext, int counter)
{
    vec_vec_hashmap_t *v_scopes = (vec_vec_hashmap_t *)hashmap_get(symbol_table, key);
    int len = v_scopes->data[scope].length - 1;
    add_symbol(v_scopes->data[scope].data[len], type, data_type, yytext, counter);
}

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
    if (symbol == NULL)
    {
        printf("NULL\n");
        return;
    }
    symbol_t *s = (symbol_t *)symbol;
    printf("%-10s%-10s%-10s%-10d\n", s->id, symbol_type_str[s->type], data_type_str[s->data_type], s->line);
}

void show_symbol_table(hashmap_t *symbol_table)
{
    printf("%-10s%-10s%-10s%-10s\n", "ID", "TYPE", "DATA_TYPE", "LINE");
    vec_vec_hashmap_t v_scopes = *(vec_vec_hashmap_t *)hashmap_get(symbol_table, "main");
    int i;
    vec_hashmap_t tmp;
    vec_foreach(&v_scopes, tmp, i)
    {
        if (tmp.length == 0)
            continue;
        printf("Scope %d\n", i);
        printf("---------\n");
        int j;
        hashmap_t *tmp2;
        vec_foreach(&tmp, tmp2, j)
        {
            if (tmp2->count == 0)
                continue;
            hashmap_iterate(tmp2, show_symbol);
            printf("\n");
        }
    }
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