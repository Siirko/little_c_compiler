#include "../include/quadr.h"
#include "../include/utils.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void quadr_init_arg(quadr_arg_t *arg, char *val, enum quadr_arg_types type)
{
    arg->val = strdup(val);
    bool is_integer = is_str_integer(val);
    arg->type = is_integer ? QUADR_ARG_INT : type;
}

void quadr_gencode(enum quad_types type, enum quad_ops op, quadr_arg_t arg1, quadr_arg_t arg2,
                   quadr_arg_t res, vec_quadr_t *vec_quadruples, bool is_tmp, hashmap_t *t_sym_tab,
                   int depth_scope, char *key)
{
    bool is_scope_needed = false;
    if (type == QUAD_TYPE_BINARY_ASSIGN || type == QUAD_TYPE_UNARY_ASSIGN || type == QUAD_TYPE_COPY ||
        type == QUAD_TYPE_IF || type == QUAD_TYPE_IF_NOT || type == QUAD_TYPE_SYSCALL_PRINT_INT ||
        type == QUAD_TYPE_SYSCALL_PRINT_FLOAT)
        is_scope_needed = true;

    if (arg1.val != NULL)
        arg1.scope = is_scope_needed ? get_scope(t_sym_tab, depth_scope, arg1.val, key) : (scope_t){-1, -1};
    if (arg2.val != NULL)
        arg2.scope = is_scope_needed ? get_scope(t_sym_tab, depth_scope, arg2.val, key) : (scope_t){-1, -1};
    if (res.val != NULL)
        res.scope = is_scope_needed ? get_scope(t_sym_tab, depth_scope, res.val, key) : (scope_t){-1, -1};
    quadr_t quad = {
        .type = type,
        .op = op,
        .arg1 = arg1,
        .arg2 = arg2,
        .res = res,
    };
    vec_push(vec_quadruples, quad);
}

void print_quad(quadr_t quad)
{
    switch (quad.type)
    {
    case QUAD_TYPE_BINARY_ASSIGN:
        printf(quad_type_str[quad.type], quad.res.val, quad.arg1.val, quad_op_str[quad.op], quad.arg2.val);
        break;
    case QUAD_TYPE_COPY:
        printf(quad_type_str[quad.type], quad.res.val, quad.arg1.val);
        break;
    case QUAD_TYPE_IF:
    case QUAD_TYPE_IF_NOT:
        printf(quad_type_str[quad.type], quad.arg1.val, quad_op_str[quad.op], quad.arg2.val, quad.res.val);
        break;
    case QUAD_TYPE_GOTO:
    case QUAD_TYPE_LABEL:
        printf(quad_type_str[quad.type], quad.res.val);
        break;
    case QUAD_TYPE_SYSCALL_PRINT_INT:
    case QUAD_TYPE_SYSCALL_PRINT_FLOAT:
    case QUAD_TYPE_SYSCALL_PRINT_STR:
        printf(quad_type_str[quad.type], quad.arg1.val);
        break;
    default:
        printf("Unknown quad type\n");
    }
    // else
    //     printf("Unknown quad type\n");
    // else if (quad->type == QUAD_TYPE_UNARY_ASSIGN)
    //     printf(quad_type_str[quad->op], quad->res, quad->arg1, quad->arg2);
}
