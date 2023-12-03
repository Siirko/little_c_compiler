#include "../include/quadr.h"
#include "../include/utils.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void quad_gencode(enum quad_types type, enum quad_ops op, char *arg1, char *arg2, char *res,
                  quadr_hv_t *quadruples)
{
    quadr_t quad = {
        .type = type,
        .op = op,
        .arg1 = arg1,
        .arg2 = arg2,
        .res = res,
    };
    // vec_push(quadruples->quads, quad);
}

void print_quad(quadr_t quad)
{
    printf("e\n");
    // if (quad->type == QUAD_TYPE_BINARY_ASSIGN)
    //     printf(quad_type_str[quad->op], quad->res, quad->arg1, quad->arg2);
    // else if (quad->type == QUAD_TYPE_UNARY_ASSIGN)
    //     printf(quad_type_str[quad->op], quad->res, quad->arg1, quad->arg2);
    // else if (quad->type == QUAD_TYPE_COPY)
    //     printf(quad_type_str[quad->op], quad->res, quad->arg1);
    // else if (quad->type == QUAD_TYPE_GOTO)
    //     printf(quad_type_str[quad->op], atoi(quad->arg1));
    // else if (quad->type == QUAD_TYPE_IF)
    //     printf(quad_type_str[quad->op], quad->arg1, quad->arg2, atoi(quad->res));
    // else if (quad->type == QUAD_TYPE_IF_ELSE)
    //     printf(quad_type_str[quad->op], quad->arg1, quad->arg2, atoi(quad->res), atoi(quad->arg1));
    // else if (quad->type == QUAD_TYPE_CALL)
    //     printf(quad_type_str[quad->op]);
    // else
    //     printf("Unknown quad type\n");
}

void quad_gentmp(char *id)
{
    // static int tmp_count = 0;
    // int len = sprintf(id, "t%d", tmp_count++);
    // id[len] = '\0';
}