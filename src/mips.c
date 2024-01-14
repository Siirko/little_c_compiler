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
    if (quadr.arg1.type == QUADR_ARG_RETURN_FUNCTION)
        fprintf(file, "\tmove $%s, $%s\n", tmp_reg, quadr.arg1.val);
    else if (arg1_int && quadr.res.data_type != TYPE_FLOAT)
        fprintf(file, "\tli $t0, %s\n", quadr.arg1.val);
    else if (quadr.arg1.type != QUADR_ARG_TMP_VAR &&
             (arg1_float || (quadr.res.data_type == TYPE_FLOAT && quadr.arg1.data_type == TYPE_INT)))
    {
        float f = strtof(quadr.arg1.val, NULL);
        fprintf(file, "\tli $t0, 0x%08X\n", *(unsigned int *)&f);
    }
    else if (arg1_tmp)
    {
        if (strcmp(quadr.arg1.val, tmp_reg) == 0)
            tmp_reg[1]++;
        if (quadr.arg1.data_type == TYPE_FLOAT || quadr.res.data_type == TYPE_FLOAT)
        {
            fprintf(file, "\ts.s $%s, %s_%s_%d_%d\n", quadr.arg1.val, quadr.res.val,
                    quadr.res.scope.function_name, quadr.res.scope.depth, quadr.res.scope.width);
            return;
        }
        else
            fprintf(file, "\tmove $%s, $%s\n", tmp_reg, quadr.arg1.val);
    }
    // else if (quadr.res.data_type == TYPE_INT)
    // {
    //     printf("%s %d %d\n", quadr.arg1.val, quadr.arg1.data_type);
    //     fprintf(file, "\tmtc1 $%s, $%s\n", tmp_reg, tmp_reg_float);
    //     fprintf(file, "\tcvt.w.s $%s, $%s\n", tmp_reg_float, tmp_reg_float);
    //     fprintf(file, "\tmfc1 $%s, $%s\n", tmp_reg, tmp_reg_float);
    // }
    else
        fprintf(file, "\tlw $t0, %s_%s_%d_%d\n", quadr.arg1.val, quadr.arg1.scope.function_name,
                quadr.arg1.scope.depth, quadr.arg1.scope.width);

    // printf("res_val:%s res_type:%d res_data_type:%d\n", quadr.res.val, quadr.res.type,
    // quadr.res.data_type); printf("arg1_val:%s arg1_type:%d arg1_data_type:%d\n\n", quadr.arg1.val,
    // quadr.arg1.type,
    //        quadr.arg1.data_type);

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
    else if (quadr.res.data_type == TYPE_INT && quadr.arg1.data_type == TYPE_FLOAT)
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

enum quad_op_type
{
    OP_TYPE_INT,
    OP_TYPE_FLOAT,
};

const enum quad_op_type op_type_int[] = {[TYPE_INT] = OP_TYPE_INT, [TYPE_FLOAT] = OP_TYPE_FLOAT};

const char *quadr_op_str[][2] = {[QUAD_OP_ADD] = {"add", "add.s"},
                                 [QUAD_OP_SUB] = {"sub", "sub.s"},
                                 [QUAD_OP_MUL] = {"mul", "mul.s"},
                                 [QUAD_OP_DIV] = {"div", "div.s"}};

void mips_operation_gen(quadr_t *quadr, FILE *file, char *tmp_reg_int, char *tmp_reg_float, enum quad_ops op,
                        enum quad_op_type op_type)
{
    // J'ajoute un pensement sur une fracture qui ne peut être refermé ....
    // #société
    if (op == QUAD_OP_DIV || op == QUAD_OP_SUB)
    {
        if (quadr->arg1.type == QUADR_ARG_TMP_VAR)
        {
            char reg = op_type == OP_TYPE_INT ? 't' : 'f';
            fprintf(file, "\t%s $%c1, $%c1, $%c0\n", quadr_op_str[op][op_type], reg, reg, reg);
            goto end;
        }
    }
    // case where f2 and f1 are tmp var
    // example: f2 = f1 + f
    if (quadr->res.type == QUADR_ARG_TMP_VAR && quadr->arg1.type == QUADR_ARG_TMP_VAR)
    {
        if (quadr->arg1.val[0] == 't' && op_type != OP_TYPE_INT)
            quadr->arg1.val[0] = 'f';
        fprintf(file, "\t%s $%s, $%s, $%s\n", quadr_op_str[op][op_type], quadr->res.val, quadr->arg1.val,
                quadr->res.val);
    }
    else if (op_type == OP_TYPE_INT)
    {
        if (quadr->res.val[1] == '0')
            fprintf(file, "\t%s $%s, $t0, $t1\n", quadr_op_str[op][op_type], quadr->res.val);
        else
            fprintf(file, "\t%s $%s, $t0, $%s\n", quadr_op_str[op][op_type], quadr->res.val, quadr->res.val);
    }
    else
        fprintf(file, "\t%s $%s, $f0, $%s\n", quadr_op_str[op][op_type], quadr->res.val, quadr->res.val);

end:
    if (op_type == OP_TYPE_FLOAT)
        fprintf(file, "\tmov.s $f0, $%s\n", quadr->res.val);
    else
        fprintf(file, "\tmove $t0, $%s\n", quadr->res.val);
}

void mips_binary_assign(quadr_t quadr, FILE *file)
{
    // Temporary variable is normaly always stored in arg1 !
    bool arg1_int = quadr.arg1.type == QUADR_ARG_INT;
    bool arg2_int = quadr.arg2.type == QUADR_ARG_INT;
    bool arg1_tmp = quadr.arg1.type == QUADR_ARG_TMP_VAR;

    char tmp_reg_int[3] = "t0";
    char tmp_reg_float[3] = "f0";

    // Debug purposes
    char buf[1024] = {0};
    sprintf(buf, "\t# %s", quad_type_str[quadr.type]);
    fprintf(file, buf, quadr.res.val, quadr.arg1.val, quad_op_str[quadr.op], quadr.arg2.val);

    // loading arg1 to $t0
    if (arg1_tmp)
    {
        if (quadr.arg1.data_type == TYPE_INT)
            fprintf(file, "\tmove $%s, $%s\n", quadr.arg1.val, tmp_reg_int);
        else if (quadr.arg1.data_type == TYPE_FLOAT)
            fprintf(file, "\tmov.s $%s, $%s\n", quadr.arg1.val, tmp_reg_float);
        // if we have t1 = t1 op t1
        // or f1 = f1 op f1
        // call directely the operation
        bool res_arg1 = strcmp(quadr.res.val, quadr.arg1.val) == 0;
        bool res_arg2 = strcmp(quadr.res.val, quadr.arg2.val) == 0;
        bool arg1_arg2 = strcmp(quadr.arg1.val, quadr.arg2.val) == 0;
        if (res_arg1 && res_arg2 && arg1_arg2)
        {
            quadr.arg1.val = strdup(tmp_reg_int);

            mips_operation_gen(&quadr, file, tmp_reg_int, tmp_reg_float, quadr.op,
                               op_type_int[quadr.res.data_type]);
            free(quadr.arg1.val);
            return;
        }
        quadr.arg1.val = strdup(tmp_reg_int);
    }
    else if (arg1_int)
    {
        if (quadr.arg1.data_type == TYPE_FLOAT)
        {
            fprintf(file, "\tli $%s, %s\n", tmp_reg_int, quadr.arg1.val);
            fprintf(file, "\tmtc1 $%s, $%s\n", tmp_reg_int, tmp_reg_float);
            fprintf(file, "\tcvt.s.w $%s, $%s\n", tmp_reg_float, tmp_reg_float);
        }
        else
            fprintf(file, "\tli $t0, %s\n", quadr.arg1.val);
        tmp_reg_int[1]++;
    }
    else if (quadr.res.data_type == TYPE_INT && quadr.arg1.data_type == TYPE_FLOAT &&
             quadr.arg1.type != QUADR_ARG_FLOAT)
    {
        fprintf(file, "\tl.s $%s, %s_%s_%d_%d\n", tmp_reg_float, quadr.arg1.val,
                quadr.arg1.scope.function_name, quadr.arg1.scope.depth, quadr.arg1.scope.width);
        fprintf(file, "\tcvt.w.s $%s, $%s\n", tmp_reg_float, tmp_reg_float);
        fprintf(file, "\tmfc1 $%s, $%s\n", tmp_reg_int, tmp_reg_float);
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
        if (quadr.res.data_type == TYPE_INT)
        {
            fprintf(file, "\tcvt.w.s $%s, $%s\n", tmp_reg_float, tmp_reg_float);
            fprintf(file, "\tmfc1 $%s, $%s\n", tmp_reg_int, tmp_reg_float);
        }
        tmp_reg_float[1]++;
        tmp_reg_int[1]++;
    }
    else
    {
        fprintf(file, "\tlw $t0, %s_%s_%d_%d\n", quadr.arg1.val, quadr.arg1.scope.function_name,
                quadr.arg1.scope.depth, quadr.arg1.scope.width);
        tmp_reg_int[1]++;
    }
    // printf("%s %d %d\n", quadr.res.val, quadr.res.type, quadr.res.data_type);
    // printf("%s %d %d\n", quadr.arg1.val, quadr.arg1.type, quadr.arg1.data_type);
    // printf("%s %d %d\n\n", quadr.arg2.val, quadr.arg2.type, quadr.arg2.data_type);
    if (arg2_int)
    {
        if (quadr.arg2.data_type == TYPE_FLOAT)
        {
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
    else if (quadr.res.data_type == TYPE_INT && quadr.arg2.data_type == TYPE_FLOAT &&
             quadr.arg2.type != QUADR_ARG_FLOAT)
    {
        fprintf(file, "\tl.s $%s, %s_%s_%d_%d\n", tmp_reg_float, quadr.arg2.val,
                quadr.arg2.scope.function_name, quadr.arg2.scope.depth, quadr.arg2.scope.width);
        fprintf(file, "\tcvt.w.s $%s, $%s\n", tmp_reg_float, tmp_reg_float);
        fprintf(file, "\tmfc1 $%s, $%s\n", tmp_reg_int, tmp_reg_float);
        tmp_reg_int[1]++;
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
        // tmp_reg_float[1]++;
        fprintf(file, "\tl.s $%s, %s_%s_%d_%d\n", tmp_reg_float, quadr.arg2.val,
                quadr.arg2.scope.function_name, quadr.arg2.scope.depth, quadr.arg2.scope.width);
    }
    else if (quadr.arg2.data_type == TYPE_FLOAT && quadr.arg2.type == QUADR_ARG_FLOAT)
    {
        if (strcmp(quadr.arg2.val, tmp_reg_float) == 0)
            tmp_reg_float[1]++;
        float f = strtof(quadr.arg2.val, NULL);
        fprintf(file, "\tli $%s, 0x%08X\n", tmp_reg_int, *(unsigned int *)&f);
        fprintf(file, "\tmtc1 $%s, $f%c\n", tmp_reg_int, tmp_reg_float[1]);
        if (quadr.res.data_type == TYPE_INT)
        {
            fprintf(file, "\tcvt.w.s $f%c, $f%c\n", tmp_reg_float[1], tmp_reg_float[1]);
            fprintf(file, "\tmfc1 $%s, $f%c\n", tmp_reg_int, tmp_reg_float[1]);
        }
    }
    else
    {
        // this code is a real mess hihi im loosing my mind
        if (tmp_reg_int[1] != '1')
        {
            tmp_reg_int[1]++;
            tmp_reg_float[1]++;
        }
        fprintf(file, "\tlw $%s, %s_%s_%d_%d\n", tmp_reg_int, quadr.arg2.val, quadr.arg2.scope.function_name,
                quadr.arg2.scope.depth, quadr.arg2.scope.width);
        fprintf(file, "\tmtc1 $%s, $f%c\n", tmp_reg_int, tmp_reg_int[1]);
        fprintf(file, "\tcvt.s.w $f%c, $f%c\n", tmp_reg_int[1], tmp_reg_int[1]);
    }

    mips_operation_gen(&quadr, file, tmp_reg_int, tmp_reg_float, quadr.op, op_type_int[quadr.res.data_type]);

    if (arg1_tmp)
        free(quadr.arg1.val);
}

const char *quadr_oprel_str[] = {
    [QUAD_OP_LT] = "blt", [QUAD_OP_LE] = "ble", [QUAD_OP_GT] = "bgt",
    [QUAD_OP_GE] = "bge", [QUAD_OP_EQ] = "beq", [QUAD_OP_NE] = "bne",
};

const char *quadr_oprelinv_str[] = {
    [QUAD_OP_LT] = "bge", [QUAD_OP_LE] = "bgt", [QUAD_OP_GT] = "ble",
    [QUAD_OP_GE] = "blt", [QUAD_OP_EQ] = "bne", [QUAD_OP_NE] = "beq",
};

void mips_opre_gen(quadr_t *quadr, FILE *file, enum quad_ops op, bool is_not)
{
    if (!is_not)
        fprintf(file, "\t%s $t0, $t1, %s\n", quadr_oprel_str[op], quadr->res.val);
    else
        fprintf(file, "\t%s $t0, $t1, %s\n", quadr_oprelinv_str[op], quadr->res.val);
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

    mips_opre_gen(&quadr, file, quadr.op, is_not);
}

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
    static char param_reg[3] = "a0";
    vec_foreach(vec_quadr, quadr, i)
    {
        switch (quadr.type)
        {
        case QUAD_TYPE_PARAM_CALL:
        {
            if (quadr.arg1.type == QUADR_ARG_TMP_VAR)
                fprintf(file, "\tmove $%s $%s\n", param_reg, quadr.arg1.val);
            // ex: li $a0, 2
            else if (quadr.arg1.type != QUADR_ARG_STR && quadr.arg1.type == QUADR_ARG_INT)
                fprintf(file, "\tli $%s %s\n", param_reg, quadr.arg1.val);
            // ex: lw $a0, a_0_0_0
            else if (quadr.arg1.type == QUADR_ARG_STR && quadr.arg1.data_type == TYPE_INT)
                fprintf(file, "\tlw $%s %s_%s_%d_%d\n", param_reg, quadr.arg1.val,
                        quadr.arg1.scope.function_name, quadr.arg1.scope.depth, quadr.arg1.scope.width);
            // ex: li $t0, 0x41BA6666
            //     mtc1 $t0, $f0
            //     cvt.s.w $f0, $f0
            //     mfc1 $a0, $f0
            else if (quadr.arg1.type != QUADR_ARG_STR && quadr.arg1.type == QUADR_ARG_FLOAT)
            {
                float f = strtof(quadr.arg1.val, NULL);
                fprintf(file, "\tli $t0, 0x%08X\n", *(unsigned int *)&f);
                fprintf(file, "\tmtc1 $t0, $f0\n");
                fprintf(file, "\tmfc1 $%s, $f0\n", param_reg);
            }
            // ex: l.s $f0, a_0_0_0
            //     mfc1 $a0, $f0
            else if (quadr.arg1.type == QUADR_ARG_STR && quadr.arg1.data_type == TYPE_FLOAT)
            {
                fprintf(file, "\tl.s $f0 %s_%s_%d_%d\n", quadr.arg1.val, quadr.arg1.scope.function_name,
                        quadr.arg1.scope.depth, quadr.arg1.scope.width);
                fprintf(file, "\tmfc1 $%s, $f0\n", param_reg);
            }

            param_reg[1]++;
            break;
        }
        case QUAD_TYPE_CALL:
        {
            fprintf(file, "\tjal %s\n", quadr.res.val);
            param_reg[1] = '0';
            break;
        }
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
            else if (quadr.arg1.type == QUADR_ARG_FLOAT)
            {
                float f = strtof(quadr.arg1.val, NULL);
                fprintf(file, "\tli $t0, 0x%08X\n", *(unsigned int *)&f);
                fprintf(file, "\tmtc1 $t0, $f0\n");
                fprintf(file, "\tmfc1 $v0, $f0\n");
            }
            else if (quadr.arg1.type == QUADR_ARG_TMP_VAR && quadr.arg1.val[0] == 't')
                fprintf(file, "\tmove $v0, $%s\n", quadr.arg1.val);
            else if (quadr.arg1.type == QUADR_ARG_TMP_VAR && quadr.arg1.val[0] == 'f')
                fprintf(file, "\tmfc1 $v0, $%s\n", quadr.arg1.val);
            else
                fprintf(file, "\tlw $v0, %s_%s_%d_%d\n", quadr.arg1.val, quadr.arg1.scope.function_name,
                        quadr.arg1.scope.depth, quadr.arg1.scope.width);
            fprintf(file, "\n\tlw $ra, 0($sp)\n"
                          "\taddi $sp, $sp, 4\n");
            fprintf(file, "\tjr $ra\n");
            function_arg_index = -1;
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
            if (function_arg_index == -1)
                fprintf(file, "\taddi $sp,$sp,-4\n"
                              "\tsw $ra, 0($sp)\n");
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