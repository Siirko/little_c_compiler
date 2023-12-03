#pragma once
#include "symbol.h"

// https://moodle.unistra.fr/pluginfile.php/909854/mod_resource/content/2/cours5.pdf

#define QUAD_TYPES                                                                                           \
    /* x = y op z */                                                                                         \
    X(QUAD_TYPE_BINARY_ASSIGN, "%s = %s %s %s\n")                                                            \
    /* x = op y */                                                                                           \
    X(QUAD_TYPE_UNARY_ASSIGN, "%s = %s %s\n")                                                                \
    /* x = y */                                                                                              \
    X(QUAD_TYPE_COPY, "%s = %s\n")                                                                           \
    /* goto LABEL */                                                                                         \
    X(QUAD_TYPE_GOTO, "GOTO L%d\n")                                                                          \
    /* if x relop y goto LABEL */                                                                            \
    X(QUAD_TYPE_IF, "IF (%s %s %s) GOTO L%d\n")                                                              \
    /* if x relop y goto LABEL1 else goto LABEL2 */                                                          \
    X(QUAD_TYPE_IF_ELSE, "if (%s %s %s) GOTO L%d ELSE GOTO L%d\n")                                           \
    /* param x */                                                                                            \
    /* call y, n*/                                                                                           \
    /* ex: param a, param b, call sqrt, 2*/                                                                  \
    X(QUAD_TYPE_CALL, "")

#define QUAD_OPS                                                                                             \
    X(QUAD_OP_ADD, "+")                                                                                      \
    X(QUAD_OP_SUB, "-")                                                                                      \
    X(QUAD_OP_MUL, "*")                                                                                      \
    X(QUAD_OP_DIV, "/")                                                                                      \
    X(QUAD_OP_LT, "<")                                                                                       \
    X(QUAD_OP_LE, "<=")                                                                                      \
    X(QUAD_OP_GT, ">")                                                                                       \
    X(QUAD_OP_GE, ">=")

#define X(a, b) a,
enum quad_types
{
    QUAD_TYPES
};
enum quad_ops
{
    QUAD_OPS
};
#undef X

#define X(a, b) [a] = b,
static char *quad_type_str[] = {QUAD_TYPES};
static char *quad_op_str[] = {QUAD_OPS};
#undef X

typedef struct quadr
{
    enum quad_types type;
    enum quad_ops op;
    char *arg1;
    char *arg2;
    char *res;
} quadr_t;

typedef struct quadr_hv
{
    hashmap_t *tmp_vars;
    // vec_quadr_t *quads;
} quadr_hv_t;

void quad_gencode(enum quad_types type, enum quad_ops op, char *arg1, char *arg2, char *res,
                  quadr_hv_t *quadruples);

void print_quad(quadr_t quad);

void quad_gentmp(char *id);