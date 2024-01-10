#include "../include/mips.h"
#include "../include/hashmap.h"
#include "../include/utils.h"
#include <ctype.h>

void mips_data_section(hashmap_t *t_sym_tab, FILE *file)
{
    fprintf(file, ".data\n");
    // hashmap<string, vector<vector<hashmap<string, symbol_t>>>> t_sym_tab;

    // we focus only on "main" function, but in the future it will be changed
    /*= (vec_vec_hashmap_t *)hashmap_get(t_sym_tab, "main") */;
    hashmap_iter_t iter = {0};
    hashmap_iter_init(&iter, t_sym_tab);
    do
    {
        if (!hashmap_iter_has_next(&iter))
            continue;
        vec_vec_hashmap_t *v_scopes = (vec_vec_hashmap_t *)iter.node->value;
        char *function_scope = iter.node->key;
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
                hashmap_iter_t iter = {0};
                hashmap_iter_init(&iter, tmp2);
                do
                {
                    if (!hashmap_iter_has_next(&iter))
                        continue;
                    symbol_t *symbol = (symbol_t *)iter.node->value;
                    if (symbol->type == TYPE_VARIABLE || symbol->type == TYPE_ITERATOR)
                    {
                        switch (symbol->data_type)
                        {
                        case TYPE_INT:
                            fprintf(file, "\t%s_%s_%d_%d: .word 0\n", symbol->id, function_scope, i, j);
                            break;
                        case TYPE_FLOAT:
                            fprintf(file, "\t%s_%s_%d_%d: .float 0.0\n", symbol->id, function_scope, i, j);
                            break;
                        default:
                            break;
                        }
                    }
                } while (hashmap_iter_next(&iter));
            }
        }
    } while (hashmap_iter_next(&iter));
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

void mips_macro_print_int(FILE *file)
{
    fprintf(file, ".macro print_int (%%x)\n"
                  "li $v0, 1\n"
                  "add $a0, $zero, %%x\n"
                  "syscall\n"
                  ".end_macro\n\n");
}

void mips_macro_print_float(FILE *file)
{
    fprintf(file, ".macro print_float (%%x)\n"
                  "li $v0, 2\n"
                  "mov.s $f12, %%x\n"
                  "syscall\n"
                  ".end_macro\n\n");
}

void mips_macro_exit(FILE *file)
{
    fprintf(file, ".macro exit(%%x)\n"
                  "li $v0, 17\n"
                  "add $a0, $zero, %%x\n"
                  "syscall\n"
                  ".end_macro\n\n");
}

void mips_copy_assign(quadr_t quadr, FILE *file)
{
    bool arg1_int = quadr.arg1.type == QUADR_ARG_INT;
    bool arg1_float = quadr.arg1.type == QUADR_ARG_FLOAT;
    bool arg1_tmp = quadr.arg1.type == QUADR_ARG_TMP_VAR;
    bool res_tmp = quadr.res.type == QUADR_ARG_TMP_VAR;

    char tmp_reg[3] = "t0";
    char tmp_reg_float[3] = "f0";
    // Debug purposes
    char buf[1024] = {0};
    sprintf(buf, "\t# %s", quad_type_str[quadr.type]);
    fprintf(file, buf, quadr.res.val, quadr.arg1.val);
    ////////////////////////////////////////////////
    if (arg1_int)
        fprintf(file, "\tli $t0, %s\n", quadr.arg1.val);
    else if (arg1_float)
    {
        // char *endptr;
        // check if strtof failed to convert
        float f = strtof(quadr.arg1.val, NULL);
        fprintf(file, "\tli $t0, 0x%08X\n", *(unsigned int *)&f);
    }
    else if (arg1_tmp)
    {
        if (strcmp(quadr.arg1.val, tmp_reg) == 0)
            tmp_reg[1]++;
        if (quadr.arg1.data_type == TYPE_FLOAT)
        {
            fprintf(file, "\ts.s $%s, %s_%s_%d_%d\n", quadr.arg1.val, quadr.res.val,
                    quadr.res.scope.function_name, quadr.res.scope.depth, quadr.res.scope.width);
            return;
        }
        else
            fprintf(file, "\tmove $%s, $%s\n", tmp_reg, quadr.arg1.val);
    }
    else
        fprintf(file, "\tlw $t0, %s_%s_%d_%d\n", quadr.arg1.val, quadr.arg1.scope.function_name,
                quadr.arg1.scope.depth, quadr.arg1.scope.width);

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
        fprintf(file, "\tsw $%s, %s_%s_%d_%d\n\n", tmp_reg, quadr.res.val, quadr.res.scope.function_name,
                quadr.res.scope.depth, quadr.res.scope.width);
    else if (quadr.res.data_type == TYPE_INT)
    {
        fprintf(file, "\tmtc1 $%s, $%s\n", tmp_reg, tmp_reg_float);
        fprintf(file, "\tcvt.w.s $%s, $%s\n", tmp_reg_float, tmp_reg_float);
        fprintf(file, "\tmfc1 $%s, $%s\n", tmp_reg, tmp_reg_float);
        fprintf(file, "\tsw $%s, %s_%s_%d_%d\n\n", tmp_reg, quadr.res.val, quadr.res.scope.function_name,
                quadr.res.scope.depth, quadr.res.scope.width);
    }
    else
        fprintf(file, "\tsw $t0, %s_%s_%d_%d\n\n", quadr.res.val, quadr.res.scope.function_name,
                quadr.res.scope.depth, quadr.res.scope.width);
}

void mips_binary_assign(quadr_t quadr, FILE *file)
{
    // Temporary variable is normaly always stored in arg1 !
    bool arg1_int = quadr.arg1.type == QUADR_ARG_INT;
    bool arg2_int = quadr.arg2.type == QUADR_ARG_INT;
    bool res_tmp = quadr.res.type == QUADR_ARG_TMP_VAR;
    bool arg1_tmp = quadr.arg1.type == QUADR_ARG_TMP_VAR;

    char tmp_reg_int[3] = "t0";
    char tmp_reg_float[3] = "f0";

    // Debug purposes
    char buf[1024] = {0};
    sprintf(buf, "\t# %s", quad_type_str[quadr.type]);
    fprintf(file, buf, quadr.res.val, quadr.arg1.val, quad_op_str[quadr.op], quadr.arg2.val);
    ////////////////////////////////////////////////

    // loading arg1 to $t0
    if (arg1_tmp)
    {
        if (strcmp(quadr.arg1.val, "t0") == 0)
            tmp_reg_int[1]++;
        if (strcmp(quadr.arg1.val, "f0") == 0)
            tmp_reg_float[1]++;
        if (quadr.arg1.data_type == TYPE_INT)
            fprintf(file, "\tmove $%s, $%s\n", tmp_reg_int, quadr.arg1.val);
        else if (quadr.arg1.data_type == TYPE_FLOAT)
            fprintf(file, "\tmov.s $%s, $%s\n", tmp_reg_float, quadr.arg1.val);
        quadr.arg1.val = strdup(tmp_reg_int);
    }
    else if (arg1_int)
    {
        fprintf(file, "\tli $t0, %s\n", quadr.arg1.val);
        tmp_reg_int[1]++;
    }
    else if (quadr.arg1.data_type == TYPE_FLOAT && quadr.arg1.type != QUADR_ARG_FLOAT)
    {
        fprintf(file, "\tl.s $f0, %s_%s_%d_%d\n", quadr.arg1.val, quadr.arg1.scope.function_name,
                quadr.arg1.scope.depth, quadr.arg1.scope.width);
        tmp_reg_float[1]++;
    }
    else if (quadr.arg1.data_type == TYPE_FLOAT && quadr.arg1.type == QUADR_ARG_FLOAT)
    {
        float f = strtof(quadr.arg1.val, NULL);
        fprintf(file, "\tli $%s, 0x%08X\n", tmp_reg_int, *(unsigned int *)&f);
        fprintf(file, "\tmtc1 $%s, $%s\n", tmp_reg_int, tmp_reg_float);
        tmp_reg_float[1]++;
        tmp_reg_int[1]++;
    }
    else
    {
        fprintf(file, "\tlw $t0, %s_%s_%d_%d\n", quadr.arg1.val, quadr.arg1.scope.function_name,
                quadr.arg1.scope.depth, quadr.arg1.scope.width);
        tmp_reg_int[1]++;
    }

    // loading arg2 to $t1
    // if (arg2_tmp)
    // {
    //     if (strcmp(quadr.arg2.val, "t1") == 0)
    //         tmp_reg_int[1]++;
    //     if (strcmp(quadr.arg2.val, "f1") == 0)
    //         tmp_reg_float[1]++;
    //     if (quadr.arg2.data_type == TYPE_INT)
    //         fprintf(file, "\tmove $%s, $%s\n", tmp_reg_int, quadr.arg2.val);
    //     else if (quadr.arg2.data_type == TYPE_FLOAT)
    //         fprintf(file, "\tmov.s $%s, $%s\n", tmp_reg_float, quadr.arg2.val);
    //     quadr.arg2.val = strdup(tmp_reg_int);
    // }
    // else
    // printf("%s %d %d\n", quadr.res.val, quadr.res.type, quadr.res.data_type);
    // printf("%s %d %d\n\n", quadr.arg2.val, quadr.arg2.type, quadr.arg2.data_type);
    if (arg2_int)
    {
        if (quadr.arg2.data_type == TYPE_FLOAT)
        {
            tmp_reg_float[1]++;
            tmp_reg_int[1]++;
            fprintf(file,
                    "\tli $%s, %s\n"
                    "\tmtc1 $%s, $%s\n"
                    "\tcvt.s.w $%s, $%s\n",
                    tmp_reg_int, quadr.arg2.val, tmp_reg_int, tmp_reg_float, tmp_reg_float, tmp_reg_float);
        }
        else
        {
            fprintf(file, "\tli $%s, %s\n", tmp_reg_int, quadr.arg2.val);
            tmp_reg_int[1]++;
        }
    }
    else if (quadr.res.data_type != TYPE_FLOAT && quadr.arg2.type != QUADR_ARG_FLOAT &&
             quadr.arg2.data_type == TYPE_INT)
    {
        fprintf(file, "\tlw $t1, %s_%s_%d_%d\n", quadr.arg2.val, quadr.arg2.scope.function_name,
                quadr.arg2.scope.depth, quadr.arg2.scope.width);
        tmp_reg_int[1]++;
    }
    else if (quadr.arg2.data_type == TYPE_FLOAT && quadr.arg2.type != QUADR_ARG_FLOAT)
    {
        tmp_reg_float[1]++;
        fprintf(file, "\tl.s $%s, %s_%s_%d_%d\n", tmp_reg_float, quadr.arg2.val,
                quadr.arg2.scope.function_name, quadr.arg2.scope.depth, quadr.arg2.scope.width);
    }
    else if (quadr.arg2.data_type == TYPE_FLOAT && quadr.arg2.type == QUADR_ARG_FLOAT)
    {
        // tmp_reg_float[1]++;
        float f = strtof(quadr.arg2.val, NULL);
        fprintf(file, "\tli $%s, 0x%08X\n", tmp_reg_int, *(unsigned int *)&f);
        fprintf(file, "\tmtc1 $%s, $%s\n", tmp_reg_int, tmp_reg_float);
    }
    else
    {
        tmp_reg_int[1]++;
        tmp_reg_float[1]++;
        fprintf(file, "\tlw $%s, %s_%s_%d_%d\n", tmp_reg_int, quadr.arg2.val, quadr.arg2.scope.function_name,
                quadr.arg2.scope.depth, quadr.arg2.scope.width);
        fprintf(file, "\tmtc1 $%s, $%s\n", tmp_reg_int, tmp_reg_float);
        fprintf(file, "\tcvt.s.w $%s, $%s\n", tmp_reg_float, tmp_reg_float);
    }

    // ahahahahhaha im writing really horrible code but it "kinda" works :)
    // performing operation
    switch (quadr.op)
    {
    case QUAD_OP_ADD:
    {
        if (quadr.res.data_type == TYPE_INT)
        {
            if (res_tmp)
                fprintf(file, "\tadd $%s, $t0, $t1\n", quadr.res.val);
            else
                fprintf(file, "\tadd $%s, $t0, $t1\n", tmp_reg_int);
        }
        else if (quadr.res.data_type == TYPE_FLOAT)
        {
            fprintf(file, "\tadd.s $%s, $%s, $%s\n", quadr.res.val, quadr.res.val, tmp_reg_float);
        }
        break;
    }
    case QUAD_OP_SUB:
    {
        if (quadr.res.data_type == TYPE_INT)
        {
            if (res_tmp)
                fprintf(file, "\tsub $%s, $t0, $t1\n", quadr.res.val);
            else
                fprintf(file, "\tsub $%s, $t0, $t1\n", tmp_reg_int);
        }
        else if (quadr.res.data_type == TYPE_FLOAT)
        {
            fprintf(file, "\tsub.s $%s, $%s, $%s\n", quadr.res.val, quadr.res.val, tmp_reg_float);
        }
        break;
    }
    case QUAD_OP_MUL:
    {
        if (quadr.res.data_type == TYPE_INT)
        {
            if (res_tmp)
                fprintf(file, "\tmul $%s, $t0, $t1\n", quadr.res.val);
            else
                fprintf(file, "\tmul $%s, $t0, $t1\n", tmp_reg_int);
        }
        else if (quadr.res.data_type == TYPE_FLOAT)
        {
            fprintf(file, "\tmul.s $%s, $%s, $%s\n", quadr.res.val, quadr.res.val, tmp_reg_float);
        }
        break;
    }
    case QUAD_OP_DIV:
    {
        if (quadr.res.data_type == TYPE_INT)
        {
            if (res_tmp)
                fprintf(file, "\tdiv $%s, $t0, $t1\n", quadr.res.val);
            else
                fprintf(file, "\tdiv $%s, $t0, $t1\n", tmp_reg_int);
        }
        else if (quadr.res.data_type == TYPE_FLOAT)
        {
            fprintf(file, "\tdiv.s $%s, $%s, $%s\n", quadr.res.val, quadr.res.val, tmp_reg_float);
        }
        break;
    }
    default:
        break;
    }

    if (arg1_tmp)
        free(quadr.arg1.val);
}

void mips_if_assign(quadr_t quadr, FILE *file, bool is_not)
{
    // load arg and arg2 to $t0 and $t1
    if (quadr.arg1.type == QUADR_ARG_INT)
        fprintf(file, "\tli $t0, %s\n", quadr.arg1.val);
    else
        fprintf(file, "\tlw $t0, %s_%s_%d_%d\n", quadr.arg1.val, quadr.arg1.scope.function_name,
                quadr.arg1.scope.depth, quadr.arg1.scope.width);
    if (quadr.arg2.type == QUADR_ARG_INT)
        fprintf(file, "\tli $t1, %s\n", quadr.arg2.val);
    else
        fprintf(file, "\tlw $t1, %s_%s_%d_%d\n", quadr.arg2.val, quadr.arg2.scope.function_name,
                quadr.arg2.scope.depth, quadr.arg2.scope.width);
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
    mips_macro_print_int(file);
    mips_macro_exit(file);
    mips_macro_print_float(file);
    mips_data_section(t_sym_tab, file);
    fprintf(file, ".text\n"
                  ".globl main\n");
    int function_arg_index = -1;
    int i;
    quadr_t quadr;
    vec_foreach(vec_quadr, quadr, i)
    {
        switch (quadr.type)
        {
        case QUAD_TYPE_PARAM_FUNCTION:
        {
            fprintf(file, "\tsw $a%d, %s_%s_%d_%d\n", ++function_arg_index, quadr.arg1.val,
                    quadr.arg1.scope.function_name, quadr.arg1.scope.depth, quadr.arg1.scope.width);
            break;
        }
        case QUAD_TYPE_RETURN_FUNCTION:
        {
            if (quadr.arg1.type == QUADR_ARG_INT)
                fprintf(file, "\tli $v0, %s\n", quadr.arg1.val);
            else if (quadr.arg1.type == QUADR_ARG_TMP_VAR)
                fprintf(file, "\tmove $v0, $%s\n", quadr.arg1.val);
            else
                fprintf(file, "\tlw $v0, %s_%s_%d_%d\n", quadr.arg1.val, quadr.arg1.scope.function_name,
                        quadr.arg1.scope.depth, quadr.arg1.scope.width);
            fprintf(file, "\tjr $ra\n");
            break;
        }
        case QUAD_TYPE_GOTO:
        {
            fprintf(file, "\tj %s\n", quadr.res.val);
            break;
        }
        case QUAD_TYPE_LABEL_FUNCTION:
        {
            fprintf(file, "%s:\n", quadr.res.val);
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
        case QUAD_TYPE_SYSCALL_PRINT_INT:
        {
            if (quadr.arg1.type == QUADR_ARG_INT)
            {
                fprintf(file, "\tlw $t0, %s_%s_%d_%d\n", quadr.arg1.val, quadr.arg1.scope.function_name,
                        quadr.arg1.scope.depth, quadr.arg1.scope.width);
                fprintf(file, "\tprint_int($t0)\n");
            }
            else if (quadr.arg1.type == QUADR_ARG_TMP_VAR)
                fprintf(file, "\tprint_int($%s)\n", quadr.arg1.val);
            break;
        }
        case QUAD_TYPE_SYSCALL_PRINT_FLOAT:
        {
            if (quadr.arg1.type == QUADR_ARG_FLOAT)
            {
                fprintf(file, "\tl.s $f0, %s_%s_%d_%d\n", quadr.arg1.val, quadr.arg1.scope.function_name,
                        quadr.arg1.scope.depth, quadr.arg1.scope.width);
                fprintf(file, "\tprint_float($f0)\n");
            }
            else if (quadr.arg1.type == QUADR_ARG_TMP_VAR)
                fprintf(file, "\tprint_float($%s)\n", quadr.arg1.val);
        }
        case QUAD_TYPE_RETURN_MAIN:
        {
            if (quadr.arg1.type == QUADR_ARG_STR)
            {
                fprintf(file, "\tlw $t0, %s_%s_%d_%d\n", quadr.arg1.val, quadr.arg1.scope.function_name,
                        quadr.arg1.scope.depth, quadr.arg1.scope.width);
                fprintf(file, "\texit($t0)\n");
            }
            else if (quadr.arg1.type == QUADR_ARG_INT)
                fprintf(file, "\texit(%s)\n", quadr.arg1.val);
            else if (quadr.arg1.type == QUADR_ARG_TMP_VAR)
                fprintf(file, "\texit($%s)\n", quadr.arg1.val);
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
}