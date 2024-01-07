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
    X(QUAD_TYPE_RETURN_MAIN, "exit(%s)\n")                                                                   \
    X(QUAD_TYPE_RETURN_FUNCTION, "RETURN FUNCTION %s\n")                                                     \
    /* param x */                                                                                            \
    /* call y, n*/                                                                                           \
    /* ex: param a, param b, call sqrt, 2*/                                                                  \
    X(QUAD_TYPE_PARAM_CALL, "param %s\n")                                                                    \
    X(QUAD_TYPE_PARAM_FUNCTION, "func_param %s\n")                                                           \
    X(QUAD_TYPE_CALL, "call %s, %s\n")                                                                       \
    X(QUAD_TYPE_LABEL, "\n%s:\n")                                                                            \
    X(QUAD_TYPE_LABEL_FUNCTION, "\nFUNCTION %s:\n")                                                          \
    X(QUAD_TYPE_SYSCALL_PRINT_STR, "print_str(%s)\n")                                                        \
    X(QUAD_TYPE_SYSCALL_PRINT_INT, "print_int(%s)\n")                                                        \
    X(QUAD_TYPE_SYSCALL_PRINT_FLOAT, "print_float(%s)\n")

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

typedef struct quadr_arg
{
    char *val;
    enum quadr_arg_types
    {
        QUADR_ARG_STR,
        QUADR_ARG_INT,
        QUADR_ARG_FLOAT,
        QUADR_ARG_TMP_VAR,
        QUADR_ARG_LABEL,
        QUADR_ARG_GOTO,
    } type;
    // only used when
    // QUAD_TYPE_BINARY_ASSIGN|QUAD_TYPE_UNARY_ASSIGN|QUAD_TYPE_COPY
    scope_t scope;
} quadr_arg_t;

typedef struct quadr
{
    enum quad_types type;
    enum quad_ops op;
    quadr_arg_t arg1;
    quadr_arg_t arg2;
    quadr_arg_t res;
    bool is_tmp;
} quadr_t;

typedef vec_t(quadr_t) vec_quadr_t;

void quadr_init_arg(quadr_arg_t *arg, char *val, enum quadr_arg_types type);

void quadr_gencode(enum quad_types type, enum quad_ops op, quadr_arg_t arg1, quadr_arg_t arg2,
                   quadr_arg_t res, vec_quadr_t *vec_quadruples, bool is_tmp, hashmap_t *t_sym_tab,
                   int depth_scope, char *key);

void print_quad(quadr_t quad);

void quad_gentmp(char *id);