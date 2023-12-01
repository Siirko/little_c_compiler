#include "../include/ast.h"
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

ast_t *ast_new(char *token, ast_t *left, ast_t *right)
{
    ast_t *ast = calloc(sizeof(ast_t), 1);
    strncpy(ast->token, token, 1024);
    ast->left = left;
    ast->right = right;
    return ast;
}

void ast_free(ast_t *ast)
{
    if (ast == NULL)
        return;
    ast_free(ast->left);
    ast_free(ast->right);
    free(ast);
}

void print_spaces(int n)
{
    for (int i = 0; i < n; i++)
    {
        printf(" ");
    }
}

typedef struct trunks
{
    struct trunks *prev;
    char *str;
} trunks_t;

void trunks_show(trunks_t *p)
{
    if (p == NULL)
        return;
    trunks_show(p->prev);
    printf("%s", p->str);
}

void ast_show_helper(ast_t *ast, trunks_t *prev, bool is_left)
{
    if (ast == NULL)
        return;

    char *prev_str = "    ";
    trunks_t trunk = {
        .prev = prev,
        .str = prev_str,
    };

    ast_show_helper(ast->left, &trunk, true);

    if (!prev)
        trunk.str = "---";
    else if (is_left)
    {
        trunk.str = ".---";
        prev_str = "   |";
    }
    else
    {
        trunk.str = "`---";
        prev->str = prev_str;
    }

    trunks_show(&trunk);
    printf("%s\n", ast->token);

    if (prev)
        prev->str = prev_str;
    trunk.str = "   |";

    ast_show_helper(ast->right, &trunk, false);
}

void ast_show(ast_t *ast) { ast_show_helper(ast, NULL, false); }