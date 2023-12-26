#pragma once

#define AST_TOKEN_SIZE 1024

enum ast_type
{
    AST_NULL = -1,
    AST_INTEGER,
    AST_FLOAT,
    AST_ID,
    AST_ADD,
    AST_SUBTRACT,
    AST_MULTIPLY,
    AST_DIVIDE,
    AST_ASSIGNATION,
    AST_ITERATOR,
    AST_IF_ELSE,
    AST_UNARY,
    AST_IF,
    AST_ELSE,
    AST_FOR,
    AST_RELOP,
    AST_CONDITION,
    AST_STATEMENTS,
    AST_DECLARATION,
    AST_LIB_FUNCTION,
    AST_FUNCTION,
    AST_RETURN,
    AST_MAIN,
    AST_ROOT
};
typedef struct ast
{
    enum ast_type type;
    char token[AST_TOKEN_SIZE];
    struct ast *left;
    struct ast *right;
} ast_t;

ast_t *ast_new(char *token, ast_t *left, ast_t *right, enum ast_type type);

void ast_free(ast_t *ast);

void ast_show(ast_t *ast);