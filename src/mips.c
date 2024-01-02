#include "../include/mips.h"
#include "../include/hashmap.h"
#include "../include/utils.h"
#include <ctype.h>

void mips_data_section(hashmap_t *t_sym_tab, FILE *file)
{
    fprintf(file, ".data\n");
    // hashmap<string, vector<vector<hashmap<string, symbol_t>>>> t_sym_tab;

    // we focus only on "main" function, but in the future it will be changed
    vec_vec_hashmap_t *v_scopes = (vec_vec_hashmap_t *)hashmap_get(t_sym_tab, "main");
    vec_hashmap_t *tmp;
    for (int i = 0; i < v_scopes->length; i++)
    {
        tmp = &v_scopes->data[i];
        if (tmp->length == 0)
            continue;
        int j;
        hashmap_t *tmp2;
        vec_foreach(tmp, tmp2, j)
        {
            // toss empty hashmaps because grammar is not perfect
            // it adds empty hashmaps to symbol table when a new scopes is detected
            // even if there's no created variables
            if (tmp2->count == 0)
            {
                hashmap_free(tmp2);
                free(tmp2);
                vec_splice(tmp, j, 1);
                continue;
            }
            hashmap_iter_t iter = {0};
            hashmap_iter_init(&iter, tmp2);
            do
            {
                if (!hashmap_iter_has_next(&iter))
                    continue;
                symbol_t *symbol = (symbol_t *)iter.node->value;
                if (symbol->type == TYPE_VARIABLE || symbol->type == TYPE_ITERATOR)
                {
                    fprintf(file, "\t%s_%d_%d: .word 0\n", symbol->id, i, j);
                }
            } while (hashmap_iter_next(&iter));
        }
    }
}

void mips_copy_assign(quadr_t quadr, FILE *file)
{
    bool arg1_int = is_str_integer(quadr.arg1);
    // Debug purposes
    char buf[1024] = {0};
    sprintf(buf, "\t# %s", quad_type_str[quadr.type]);
    fprintf(file, buf, quadr.res, quadr.arg1);
    ////////////////////////////////////////////////
    if (quadr.is_tmp)
    {
        if (arg1_int)
            fprintf(file, "\tli $%s, %s\n", quadr.res, quadr.arg1);
        else
            fprintf(file, "\tlw $%s, $%s\n", quadr.res, quadr.arg1);
        fprintf(file, "\tsw $%s, %s\n\n", quadr.res, quadr.res);
    }
    else
    {
        // this is really bad but we will stick that
        // and we will fix it later
        if (quadr.arg1[0] == 't')
            fprintf(file, "\tlw $t0, $%s\n", quadr.arg1);
        else if (arg1_int)
            fprintf(file, "\tli $t0, %s\n", quadr.arg1);
        else
            fprintf(file, "\tlw $t0, %s_%d_%d\n", quadr.arg1, quadr.scope.depth, quadr.scope.width);
        fprintf(file, "\tsw $t0, %s_%d_%d\n\n", quadr.res, quadr.scope.depth, quadr.scope.width);
    }
}

void mips_binary_assign(quadr_t quadr, FILE *file)
{
    //
    // bool arg1_int = is_str_integer(quadr.arg1);
    // bool arg2_int = is_str_integer(quadr.arg2);

    // Debug purposes
    char buf[1024] = {0};
    sprintf(buf, "\t# %s", quad_type_str[quadr.type]);
    fprintf(file, buf, quadr.res, quadr.arg1, quad_op_str[quadr.op], quadr.arg2);
    ////////////////////////////////////////////////
}

void mips_if_assign(quadr_t quadr, FILE *file, bool is_not)
{
    // load arg and arg2 to $t0 and $t1
    fprintf(file, "\tlw $t0, %s_%d_%d\n", quadr.arg1, quadr.scope.depth, quadr.scope.width);
    fprintf(file, "\tlw $t1, %s_%d_%d\n", quadr.arg2, quadr.scope.depth, quadr.scope.width);
    switch (quadr.op)
    {
    case QUAD_OP_LT:
    {
        if (!is_not)
            fprintf(file, "\tblt $t0, $t1, %s\n", quadr.res);
        else
            fprintf(file, "\tbge $t0, $t1, %s\n", quadr.res);
        break;
    }
    case QUAD_OP_LE:
    {
        if (!is_not)
            fprintf(file, "\tble $t0, $t1, %s\n", quadr.res);
        else
            fprintf(file, "\tbgt $t0, $t1, %s\n", quadr.res);
        break;
    }
    case QUAD_OP_GT:
    {
        if (!is_not)
            fprintf(file, "\tbgt $t0, $t1, %s\n", quadr.res);
        else
            fprintf(file, "\tble $t0, $t1, %s\n", quadr.res);
        break;
    }
    case QUAD_OP_GE:
    {
        if (!is_not)
            fprintf(file, "\tbge $t0, $t1, %s\n", quadr.res);
        else
            fprintf(file, "\tblt $t0, $t1, %s\n", quadr.res);
        break;
    }
    case QUAD_OP_EQ:
    {
        if (!is_not)
            fprintf(file, "\tbeq $t0, $t1, %s\n", quadr.res);
        else
            fprintf(file, "\tbne $t0, $t1, %s\n", quadr.res);
        break;
    }
    case QUAD_OP_NE:
    {
        if (!is_not)
            fprintf(file, "\tbne $t0, $t1, %s\n", quadr.res);
        else
            fprintf(file, "\tbeq $t0, $t1, %s\n", quadr.res);
        break;
    }
    default:
        break;
    }
}
// void (*mips_gen_func[])(quadr_t, FILE *) = {
//     [QUAD_TYPE_COPY] = mips_copy_assign,
//     [QUAD_TYPE_BINARY_ASSIGN] = mips_binary_assign,
// };

void mips_gen(hashmap_t *t_sym_tab, vec_quadr_t *vec_quadr, FILE *file)
{
    mips_data_section(t_sym_tab, file);
    fprintf(file, ".text\n");
    fprintf(file, "main:\n");
    int i;
    quadr_t quadr;
    vec_foreach(vec_quadr, quadr, i)
    {
        switch (quadr.type)
        {
        case QUAD_TYPE_GOTO:
        {
            fprintf(file, "\tj %s\n", quadr.res);
            break;
        }
        case QUAD_TYPE_LABEL:
        {
            fprintf(file, quad_type_str[quadr.type], quadr.res);
            break;
        }
        case QUAD_TYPE_COPY:
        {
            mips_copy_assign(quadr, file);
            break;
        }
        case QUAD_TYPE_BINARY_ASSIGN:
        {
            mips_binary_assign(quadr, file);
            break;
        }
        case QUAD_TYPE_IF:
        {
            mips_if_assign(quadr, file, false);
            break;
        }
        case QUAD_TYPE_IF_NOT:
        {
            mips_if_assign(quadr, file, true);
            break;
        }
        default:
            break;
        }
    }
}