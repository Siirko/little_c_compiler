#include "../include/quadr.h"
#include "../include/utils.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void quadr_gencode(enum quad_types type, enum quad_ops op, char *arg1, char *arg2, char *res,
                   quadr_t *list_quadruples)
{
    quadr_t quad = {
        .type = type,
        .op = op,
        .arg1 = arg1 != NULL ? strdup(arg1) : NULL,
        .arg2 = arg2 != NULL ? strdup(arg2) : NULL,
        .res = res != NULL ? strdup(res) : NULL,
    };
    vector_push_back(list_quadruples, quad);
}

void print_quad(quadr_t quad)
{
    if (quad.type == QUAD_TYPE_BINARY_ASSIGN)
        printf(quad_type_str[quad.type], quad.res, quad.arg1, quad_op_str[quad.op], quad.arg2);
    else if (quad.type == QUAD_TYPE_COPY)
        printf(quad_type_str[quad.type], quad.res, quad.arg1);
    else if (quad.type == QUAD_TYPE_IF || quad.type == QUAD_TYPE_IF_NOT)
        printf(quad_type_str[quad.type], quad.arg1, quad_op_str[quad.op], quad.arg2, quad.res);
    else if (quad.type == QUAD_TYPE_GOTO || QUAD_TYPE_LABEL)
        printf(quad_type_str[quad.type], quad.res);
    // else
    //     printf("Unknown quad type\n");
    // else if (quad->type == QUAD_TYPE_UNARY_ASSIGN)
    //     printf(quad_type_str[quad->op], quad->res, quad->arg1, quad->arg2);
}
