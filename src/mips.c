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

void mips_macro_print_str(FILE *file)
{
    fprintf(file, ".macro print_str(%%str)\n"
                  ".data\n"
                  "str: .asciiz %%str\n"
                  ".text\n"
                  "li $v0, 4\n"
                  "la $a0, str\n"
                  "syscall\n"
                  ".end_macro\n\n");
}

void mips_copy_assign(quadr_t quadr, FILE *file)
{
    bool arg1_int = quadr.arg1.type == QUADR_ARG_INT;
    bool arg1_tmp = quadr.arg1.type == QUADR_ARG_TMP_VAR;
    bool res_tmp = quadr.res.type == QUADR_ARG_TMP_VAR;

    char tmp_reg[3] = "t0";
    // Debug purposes
    char buf[1024] = {0};
    sprintf(buf, "\t# %s", quad_type_str[quadr.type]);
    fprintf(file, buf, quadr.res.val, quadr.arg1.val);
    ////////////////////////////////////////////////
    if (arg1_int)
        fprintf(file, "\tli $t0, %s\n", quadr.arg1.val);
    else if (arg1_tmp)
    {
        if (strcmp(quadr.arg1.val, tmp_reg) == 0)
            tmp_reg[1]++;
        fprintf(file, "\tmove $%s, $%s\n", tmp_reg, quadr.arg1.val);
    }
    else
        fprintf(file, "\tlw $t0, %s_%d_%d\n", quadr.arg1.val, quadr.arg1.scope.depth, quadr.arg1.scope.width);

    if (res_tmp)
    {
        if (strcmp(quadr.res.val, tmp_reg) == 0)
            tmp_reg[1]++;
        if (arg1_tmp)
            fprintf(file, "\tmove $%s, $%s\n\n", quadr.res.val, quadr.arg1.val);
        else
            fprintf(file, "\tsw $%s, $%s\n\n", tmp_reg, quadr.res.val);
    }
    else if (arg1_tmp && !res_tmp)
        fprintf(file, "\tsw $%s, %s_%d_%d\n\n", tmp_reg, quadr.res.val, quadr.res.scope.depth,
                quadr.res.scope.width);
    else
        fprintf(file, "\tsw $t0, %s_%d_%d\n\n", quadr.res.val, quadr.res.scope.depth, quadr.res.scope.width);
}

void mips_binary_assign(quadr_t quadr, FILE *file)
{
    bool arg1_int = quadr.arg1.type == QUADR_ARG_INT;
    bool arg2_int = quadr.arg2.type == QUADR_ARG_INT;

    bool res_tmp = quadr.res.type == QUADR_ARG_TMP_VAR;
    bool arg1_tmp = quadr.arg1.type == QUADR_ARG_TMP_VAR;
    bool arg2_tmp = quadr.arg2.type == QUADR_ARG_TMP_VAR;

    char tmp_reg[3] = "t0";

    // Debug purposes
    char buf[1024] = {0};
    sprintf(buf, "\t# %s", quad_type_str[quadr.type]);
    fprintf(file, buf, quadr.res.val, quadr.arg1.val, quad_op_str[quadr.op], quadr.arg2.val);
    ////////////////////////////////////////////////

    // loading arg1 to $t0
    if (arg1_tmp)
    {
        if (strcmp(quadr.arg1.val, "t0") == 0)
            tmp_reg[1]++;
        fprintf(file, "\tmove $%s, $%s\n", tmp_reg, quadr.arg1.val);
        quadr.arg1.val = strdup(tmp_reg);
    }
    else if (arg1_int)
        fprintf(file, "\tli $t0, %s\n", quadr.arg1.val);
    else
        fprintf(file, "\tlw $t0, %s_%d_%d\n", quadr.arg1.val, quadr.arg1.scope.depth, quadr.arg1.scope.width);

    // loading arg2 to $t1
    if (arg2_tmp)
    {
        if (strcmp(quadr.arg2.val, "t1") == 0)
            tmp_reg[1]++;
        fprintf(file, "\tmove $%s, $%s\n", tmp_reg, quadr.arg2.val);
        quadr.arg2.val = strdup(tmp_reg);
    }
    else if (arg2_int)
    {
        tmp_reg[1]++;
        fprintf(file, "\tli $%s, %s\n", tmp_reg, quadr.arg2.val);
    }
    else
    {
        tmp_reg[1]++;
        fprintf(file, "\tlw $%s, %s_%d_%d\n", tmp_reg, quadr.arg2.val, quadr.arg2.scope.depth,
                quadr.arg2.scope.width);
    }

    // performing operation
    switch (quadr.op)
    {
    case QUAD_OP_ADD:
    {
        if (res_tmp && !arg1_tmp && !arg2_tmp)
            fprintf(file, "\tadd $%s, $t0, $t1\n", quadr.res.val);
        else if (res_tmp && arg1_tmp && !arg2_tmp)
            fprintf(file, "\tadd $%s, $%s, $t2\n", quadr.res.val, quadr.arg1.val);
        else if (res_tmp && !arg1_tmp && arg2_tmp)
            fprintf(file, "\tadd $%s, $t0, $%s\n", quadr.res.val, quadr.arg2.val);
        else if (res_tmp && arg1_tmp && arg2_tmp)
            fprintf(file, "\tadd $%s, $%s, $%s\n", quadr.res.val, quadr.arg1.val, quadr.arg2.val);
        break;
    }
    case QUAD_OP_SUB:
    {
        if (res_tmp)
            fprintf(file, "\tsub $%s, $t0, $t1\n", quadr.res.val);
        else
            fprintf(file, "\tsub $%s, $t0, $t1\n", tmp_reg);
        break;
    }
    case QUAD_OP_MUL:
    {
        if (res_tmp)
            fprintf(file, "\tmul $%s, $t0, $t1\n", quadr.res.val);
        else
            fprintf(file, "\tmul $%s, $t0, $t1\n", tmp_reg);
        break;
    }
    case QUAD_OP_DIV:
    {
        if (res_tmp)
            fprintf(file, "\tdiv $%s, $t0, $t1\n", quadr.res.val);
        else
            fprintf(file, "\tdiv $%s, $t0, $t1\n", tmp_reg);
        break;
    }
    default:
        break;
    }

    if (arg1_tmp)
        free(quadr.arg1.val);
    if (arg2_tmp)
        free(quadr.arg2.val);
}

void mips_if_assign(quadr_t quadr, FILE *file, bool is_not)
{
    // load arg and arg2 to $t0 and $t1
    if (quadr.arg1.type == QUADR_ARG_INT)
        fprintf(file, "\tli $t0, %s\n", quadr.arg1.val);
    else
        fprintf(file, "\tlw $t0, %s_%d_%d\n", quadr.arg1.val, quadr.arg1.scope.depth, quadr.arg1.scope.width);
    if (quadr.arg2.type == QUADR_ARG_INT)
        fprintf(file, "\tli $t1, %s\n", quadr.arg2.val);
    else
        fprintf(file, "\tlw $t1, %s_%d_%d\n", quadr.arg2.val, quadr.arg2.scope.depth, quadr.arg2.scope.width);
    switch (quadr.op)
    {
    case QUAD_OP_LT:
    {
        if (!is_not)
            fprintf(file, "\tblt $t0, $t1, %s\n", quadr.res.val);
        else
            fprintf(file, "\tbge $t0, $t1, %s\n", quadr.res.val);
        break;
    }
    case QUAD_OP_LE:
    {
        if (!is_not)
            fprintf(file, "\tble $t0, $t1, %s\n", quadr.res.val);
        else
            fprintf(file, "\tbgt $t0, $t1, %s\n", quadr.res.val);
        break;
    }
    case QUAD_OP_GT:
    {
        if (!is_not)
            fprintf(file, "\tbgt $t0, $t1, %s\n", quadr.res.val);
        else
            fprintf(file, "\tble $t0, $t1, %s\n", quadr.res.val);
        break;
    }
    case QUAD_OP_GE:
    {
        if (!is_not)
            fprintf(file, "\tbge $t0, $t1, %s\n", quadr.res.val);
        else
            fprintf(file, "\tblt $t0, $t1, %s\n", quadr.res.val);
        break;
    }
    case QUAD_OP_EQ:
    {
        if (!is_not)
            fprintf(file, "\tbeq $t0, $t1, %s\n", quadr.res.val);
        else
            fprintf(file, "\tbne $t0, $t1, %s\n", quadr.res.val);
        break;
    }
    case QUAD_OP_NE:
    {
        if (!is_not)
            fprintf(file, "\tbne $t0, $t1, %s\n", quadr.res.val);
        else
            fprintf(file, "\tbeq $t0, $t1, %s\n", quadr.res.val);
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
    mips_macro_print_str(file);
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
            fprintf(file, "\tj %s\n", quadr.res.val);
            break;
        }
        case QUAD_TYPE_LABEL:
        {
            fprintf(file, quad_type_str[quadr.type], quadr.res.val);
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
        case QUAD_TYPE_SYSCALL_PRINT_STR:
        {
            char buf[1024] = {0};
            sprintf(buf, "\t%s", quad_type_str[quadr.type]);
            fprintf(file, buf, quadr.arg1.val);
        }
        default:
            break;
        }
    }

    // syscall to exit
    fprintf(file, "\tli $v0, 10\n");
    fprintf(file, "\tsyscall\n");
}