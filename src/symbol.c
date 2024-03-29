#include "../include/symbol.h"
#include "../include/utils.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// to remove anoying warnings inused
// i placed this here. Same for quadr.c

#define X(a, b) [a] = b,
const char *symbol_type_str[] = {SYMBOL_TYPE_MAP};
const char *data_type_str[] = {DATA_TYPE_MAP};
#undef X

void clear_empty_hashmaps(hashmap_t *symbol_table, int current_depth, char *function_name)
{
    vec_vec_hashmap_t *v_scopes = (vec_vec_hashmap_t *)hashmap_get(symbol_table, function_name);
    vec_hashmap_t *tmp = &v_scopes->data[current_depth];
    for (int i = tmp->length - 1; i >= 0; --i)
    {
        if (tmp->data[i]->count == 0)
        {
            hashmap_free(tmp->data[i]);
            free(tmp->data[i]);
            vec_splice(tmp, i, 1);
        }
    }
}

scope_t get_scope(hashmap_t *symbol_table, int current_depth, char *key, char *function_name)
{
    scope_t scope = {
        .depth = current_depth,
        .width = -1,
        .function_name = strdup(function_name),
    };
    // symbol_table is a hashmap<string, vector<vector<hashmap<string, symbol_t>>>>
    vec_vec_hashmap_t *v_scopes = (vec_vec_hashmap_t *)hashmap_get(symbol_table, function_name);
    int current_size_scope = v_scopes->data[current_depth].length - 1;
    if (current_size_scope < 0)
        return scope;
    // clear_hashmap(v_scopes, current_depth);
    for (int i = current_depth; i >= 0; --i)
    {
        vec_hashmap_t *tmp = &v_scopes->data[i];
        for (int j = tmp->length - 1; j >= 0; --j)
        {
            if (hashmap_get(tmp->data[j], key) != NULL)
            {
                scope.depth = i;
                scope.width = j;
                return scope;
            }
            // if we are in the current scope, we only check the last hashmap
            // else we check all the hashmap from the last to the first
            if (i == current_depth)
                break;
        }
    }
    // should never happen
    return scope;
}

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

void free_func_args(char *id, void *func_args)
{
    vec_data_type_t *vec_data_type = (vec_data_type_t *)func_args;
    vec_deinit(vec_data_type);
}

int get_function_total_args(char *id, hashmap_t *func_args)
{
    vec_data_type_t *vec_data_type = (vec_data_type_t *)hashmap_get(func_args, id);
    if (vec_data_type == NULL)
        return -1;
    if (vec_data_type->length == 1)
        if (vec_data_type->data[0] == -1)
            return 0;
    // printf("%s %d\n", id, vec_data_type->length);
    return vec_data_type->length;
}

enum data_type get_data_type_from_function(char *id, int index, hashmap_t *func_args)
{
    vec_data_type_t *vec_data_type = (vec_data_type_t *)hashmap_get(func_args, id);
    if (vec_data_type == NULL)
        return TYPE_NAD;
    if (index >= vec_data_type->length)
        return TYPE_NAD;
    if (vec_data_type->data == NULL)
        return TYPE_NAD;
    return vec_data_type->data[index];
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
    printf("%-20s%-20s%-20s%-20d\n", s->id, symbol_type_str[s->type], data_type_str[s->data_type], s->line);
}

void show_symbol_table(hashmap_t *symbol_table)
{
    hashmap_iter_t iter = {0};
    hashmap_iter_init(&iter, symbol_table);
    do
    {
        if (!hashmap_iter_has_next(&iter))
            continue;
        char *key = iter.node->key;
        printf(ANSI_COLOR_MAGENTA ANSI_BOLD "Table of Symbols for: %s\n" ANSI_RESET, key);
        vec_vec_hashmap_t v_scopes = *(vec_vec_hashmap_t *)hashmap_get(symbol_table, key);
        int i;
        vec_hashmap_t tmp;
        printf("%-20s%-20s%-20s%-20s\n", "ID", "TYPE", "DATA_TYPE", "LINE");
        vec_foreach(&v_scopes, tmp, i)
        {
            if (tmp.length == 0)
                continue;
            printf("\nScope %d\n", i);
            printf("+-------------------------------------------------------------+\n");
            int j;
            hashmap_t *tmp2;
            vec_foreach(&tmp, tmp2, j)
            {
                if (tmp2->count == 0)
                    continue;
                hashmap_iterate(tmp2, show_symbol);
                printf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
            }
        }

    } while (hashmap_iter_next(&iter));
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