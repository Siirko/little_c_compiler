#pragma once

#define AST_TOKEN_SIZE 1024
typedef struct ast
{
    char token[AST_TOKEN_SIZE];
    struct ast *left;
    struct ast *right;
} ast_t;

ast_t *ast_new(char *token, ast_t *left, ast_t *right);

void ast_free(ast_t *ast);

void ast_show(ast_t *ast);