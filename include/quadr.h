#pragma once
#include "symbol.h"
#include "vec.h"

// https://moodle.unistra.fr/pluginfile.php/909854/mod_resource/content/2/cours5.pdf

#define QUAD_TYPES                                                                                           \
    /* x = y op z */                                                                                         \
    X(QUAD_TYPE_BINARY_ASSIGN, "%s = %s %s %s\n")                                                            \
    /* x = op y */                                                                                           \
    X(QUAD_TYPE_UNARY_ASSIGN, "%s = %s %s\n")                                                                \
    /* x = y */                                                                                              \
    X(QUAD_TYPE_COPY, "%s = %s\n")                                                                           \
    /* goto LABEL */                                                                                         \
    X(QUAD_TYPE_GOTO, "GOTO %s\n")                                                                           \
    /* if x relop y goto LABEL */                                                                            \
    X(QUAD_TYPE_IF, "\nIF (%s %s %s) GOTO %s\n")                                                             \
    X(QUAD_TYPE_IF_NOT, "\nIF NOT (%s %s %s) GOTO %s\n")                                                     \
    /* param x */                                                                                            \
    /* call y, n*/                                                                                           \
    /* ex: param a, param b, call sqrt, 2*/                                                                  \
    X(QUAD_TYPE_PARAM, "param %s\n")                                                                         \
    X(QUAD_TYPE_CALL, "call %s, %s\n")                                                                       \
    X(QUAD_TYPE_LABEL, "\n%s:\n")                                                                            \
    X(QUAD_TYPE_SYSCALL_PRINT_STR, "print_str %s\n")                                                         \
    X(QUAD_TYPE_SYSCALL_PRINT_INT, "print_int %s\n")                                                         \
    X(QUAD_TYPE_SYSCALL_PRINT_FLOAT, "print_float %s\n")

#define QUAD_OPS                                                                                             \
    X(QUAD_OP_ADD, "+")                                                                                      \
    X(QUAD_OP_SUB, "-")                                                                                      \
    X(QUAD_OP_MUL, "*")                                                                                      \
    X(QUAD_OP_DIV, "/")                                                                                      \
    X(QUAD_OP_LT, "<")                                                                                       \
    X(QUAD_OP_LE, "<=")                                                                                      \
    X(QUAD_OP_GT, ">")                                                                                       \
    X(QUAD_OP_GE, ">=")                                                                                      \
    X(QUAD_OP_EQ, "==")                                                                                      \
    X(QUAD_OP_NE, "!=")

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

#pragma GCC diagnostic ignored "-Wunused-variable"
#define X(a, b) [a] = b,
static const char *quad_type_str[] = {QUAD_TYPES};
static const char *quad_op_str[] = {QUAD_OPS};
#undef X
#pragma GCC diagnostic pop

typedef struct quadr
{
    enum quad_types type;
    enum quad_ops op;
    char *arg1;
    char *arg2;
    char *res;
    // only used when
    // QUAD_TYPE_BINARY_ASSIGN|QUAD_TYPE_UNARY_ASSIGN|QUAD_TYPE_COPY
    scope_t scope;
    bool is_tmp;
} quadr_t;

typedef vec_t(quadr_t) vec_quadr_t;

void quadr_gencode_with_scope(enum quad_types type, enum quad_ops op, char *arg1, char *arg2, char *res,
                              scope_t scope, vec_quadr_t *vec_quadruples);

// is_tmp is for the case where we want to generate a temporary variable ($t0, $t1, ...)
void quadr_gencode(enum quad_types type, enum quad_ops op, char *arg1, char *arg2, char *res,
                   vec_quadr_t *vec_quadruples, bool is_tmp);

void print_quad(quadr_t quad);

void quad_gentmp(char *id);