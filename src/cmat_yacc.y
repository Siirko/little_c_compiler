%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <ctype.h>
    #include <stdbool.h>
    #include "../include/ast.h"
    #include "../include/hashmap.h"
    #include "../include/symbol.h"
    #include "../include/quadr.h"
    
    void yyerror(const char *s);
    int yylex();
    int yywrap();
    extern char* yytext;
    extern int yylineno;

    void quadr_genrelop(char *if_block, char *else_block, char *arg1, char *arg2, enum quad_ops op);
    void check_variable_declaration(char* token);

    vec_quadr_t vec_quadr;
    ast_t *head;
    hashmap_t *t_sym_tab;
    enum data_type data_type;
    bool is_for = false;
    bool in_if_condition = false;
    extern int counter;
    int error_count = 0;
    int temp_var = 0;
    int labels = 0;
    int if_counter = 0;
    int id_if_start = 0;
    int depth_scope = 0;
    int width_scope = 0;
    vec_int_t i_if_end;
%}


%union {
    struct node {
        char name[1024];
        struct ast* node;
        _Bool is_temperorary;
    } node_t;

    struct cond_node {
        char if_block[1024];
        char else_block[1024];
        struct ast* node;
    } cond_node_t;
}

%token <node_t>  PRINT PRINTF INT FLOAT FOR IF ELSE NUMBER FLOAT_NUM ID LE GE EQ NE GT LT STR ADD MULTIPLY DIVIDE SUBTRACT UNARY RETURN 
%type <node_t> iterator iterator_init printf_statement print_statement main body scope return datatype expression statement init value program else body_element for_statement if_statement
%type <cond_node_t> condition
%left ADD SUBTRACT MULTIPLY DIVIDE

%%

program: main '(' ')' '{' body return '}' {
        $1.node = ast_new("main", $5.node, $6.node, AST_MAIN);
        $$.node = ast_new("program", NULL, $1.node, AST_ROOT);
        head = $$.node;
    }
    ;


main: datatype ID { 
        init_scope_key(t_sym_tab, "main");
        // test if 'main' is in t_sym_tab
        // vec_vec_hashmap_t v_scopes = *(vec_vec_hashmap_t *)hashmap_get(t_sym_tab, "main");
        // symbol_t *sym = hashmap_get(v_scopes.data[0].data[0], "main");
        // printf("%d\n\n", sym->type);

        add_symbol_to_scope(t_sym_tab, depth_scope, "main", TYPE_FUNCTION, &data_type, yytext, counter); 
    }
    ;

datatype: INT { data_type = TYPE_INT; }
    | FLOAT { data_type = TYPE_FLOAT; }
    ;


body: body_element
    | body body_element { $$.node = ast_new("statements", $1.node, $2.node, AST_STATEMENTS); }
    ;


body_element: for_statement
    | if_statement
    | statement ';' { $$.node = $1.node; }
    | printf_statement
    | print_statement
    ;

scope: '{' { 
        if(!is_for)
        {
            ++depth_scope;
            vec_vec_hashmap_t *v_scopes = (vec_vec_hashmap_t *)hashmap_get(t_sym_tab, "main");
            if (v_scopes->length - 1 < depth_scope)
                vec_push(v_scopes, (vec_hashmap_t){0});
            // missing a condition here
            vec_push(&v_scopes->data[depth_scope], hashmap_init(10));
        }
    } body '}' {
        $$.node = $3.node;
        --depth_scope;
        clear_empty_hashmaps(t_sym_tab, depth_scope+1, "main");
    }
    ;

for_statement: FOR { 
        is_for = true;
    } '(' iterator_init ';' condition ';' iterator ')' scope {
        ast_t *tmp = ast_new("CONDITION", $6.node, $8.node, AST_CONDITION);
        ast_t *tmp2 = ast_new("CONDITION", $4.node, tmp, AST_CONDITION);
        $$.node = ast_new($1.name, tmp2, $10.node, AST_FOR);
        quadr_arg_t res = {0};
        quadr_init_arg(&res, $6.if_block, QUADR_ARG_GOTO);
        quadr_gencode(QUAD_TYPE_GOTO, 0, (quadr_arg_t){0}, (quadr_arg_t){0}, res, &vec_quadr, false, t_sym_tab, depth_scope, "main");
        res = (quadr_arg_t){0};
        quadr_init_arg(&res, $6.else_block, QUADR_ARG_LABEL);
        quadr_gencode(QUAD_TYPE_LABEL, 0, (quadr_arg_t){0}, (quadr_arg_t){0}, res,  &vec_quadr, false, t_sym_tab, depth_scope, "main");
    }

if_statement: IF { 
        is_for = false;
        in_if_condition = true;
        ++if_counter;
    } '(' condition ')' {
        quadr_arg_t res = {0};
        quadr_init_arg(&res, $4.if_block, QUADR_ARG_LABEL);
        quadr_gencode(QUAD_TYPE_LABEL, 0, (quadr_arg_t){0}, (quadr_arg_t){0}, res,  &vec_quadr, false, t_sym_tab, depth_scope, "main");
    } scope {
        char tmp2[1024] = {0};
        sprintf(tmp2, "L%d", labels);
        quadr_arg_t res = {0};
        quadr_init_arg(&res, tmp2, QUADR_ARG_GOTO);
        quadr_gencode(QUAD_TYPE_GOTO, 0, (quadr_arg_t){0}, (quadr_arg_t){0}, res,  &vec_quadr, false, t_sym_tab, depth_scope, "main");
        if(in_if_condition)
            vec_push(&i_if_end, vec_quadr.length-1);
        res = (quadr_arg_t){0};
        quadr_init_arg(&res, $4.else_block, QUADR_ARG_LABEL);
        quadr_gencode(QUAD_TYPE_LABEL, 0, (quadr_arg_t){0}, (quadr_arg_t){0}, res,  &vec_quadr, false, t_sym_tab, depth_scope, "main");
    }
    else {
        ast_t *tmp = ast_new($1.name, $4.node, $7.node, AST_IF);
        $$.node = ast_new("if-else", tmp, $9.node, AST_IF_ELSE);
    }

else: ELSE scope {
        $$.node = ast_new($1.name, NULL, $2.node, AST_ELSE);
        if(in_if_condition && --if_counter == 0)
        {
            char tmp2[1024] = {0};
            sprintf(tmp2, "L%d", labels);
            quadr_arg_t res = {0};
            quadr_init_arg(&res, tmp2, QUADR_ARG_LABEL);
            quadr_gencode(QUAD_TYPE_LABEL, 0, (quadr_arg_t){0}, (quadr_arg_t){0}, res,  &vec_quadr, false, t_sym_tab, depth_scope, "main");
            int size = i_if_end.length;
            for(int i = 0; i < size; ++i)
            {
                int index = vec_pop(&i_if_end);
                free(vec_quadr.data[index].res.val);
                vec_quadr.data[index].res.val = strdup(tmp2);
            }
            in_if_condition = false;
            ++labels;
        }
    }
    | { $$.node = NULL; }
    ;


iterator: ID { 
        check_variable_declaration($1.name);
    } UNARY {
        $1.node = ast_new($1.name, NULL, NULL, AST_ID);
        $3.node = ast_new($3.name, NULL, NULL, AST_UNARY);
        $$.node = ast_new("ITERATOR", $1.node, $3.node, AST_ITERATOR);
        char tmp[1024] = {0};
        sprintf(tmp, "t%d", temp_var);
        
        quadr_arg_t arg1 = {0};
        quadr_init_arg(&arg1, $1.name, QUADR_ARG_STR);
        quadr_arg_t _arg1 = {0};
        quadr_init_arg(&_arg1, $1.name, QUADR_ARG_STR);

        quadr_arg_t arg2 = {0};
        quadr_init_arg(&arg2, "1", QUADR_ARG_INT);
        
        quadr_arg_t res = {0};
        quadr_init_arg(&res, tmp, QUADR_ARG_TMP_VAR);
        quadr_arg_t _res = {0};
        quadr_init_arg(&_res, tmp, QUADR_ARG_TMP_VAR);

        quadr_gencode(QUAD_TYPE_BINARY_ASSIGN, QUAD_OP_ADD, arg1, arg2, res, &vec_quadr, true, t_sym_tab, depth_scope, "main");
        quadr_gencode(QUAD_TYPE_COPY, 0, _res, (quadr_arg_t){0}, _arg1, &vec_quadr, false, t_sym_tab, depth_scope, "main");
        temp_var = 0;
    }

iterator_init: datatype ID {
        ++depth_scope;
        vec_vec_hashmap_t *v_scopes = (vec_vec_hashmap_t *)hashmap_get(t_sym_tab, "main");
        if (v_scopes->length - 1 < depth_scope)
            vec_push(v_scopes, (vec_hashmap_t){0});
        // missing a condition here
        vec_push(&v_scopes->data[depth_scope], hashmap_init(10));
        add_symbol_to_scope(t_sym_tab, depth_scope, "main", TYPE_ITERATOR, &data_type, yytext, counter); 
    } '=' value {
        $2.node = ast_new($2.name, NULL, NULL, AST_ID);
        $$.node = ast_new("declaration", $2.node, $5.node, AST_DECLARATION);

        quadr_arg_t arg1 = {0};
        quadr_init_arg(&arg1, $5.name, $5.is_temperorary ? QUADR_ARG_TMP_VAR : QUADR_ARG_STR);

        quadr_arg_t res = {0};
        quadr_init_arg(&res, $2.name, $2.is_temperorary ? QUADR_ARG_TMP_VAR : QUADR_ARG_STR);

        quadr_gencode(QUAD_TYPE_COPY, 0, arg1, (quadr_arg_t){0}, res, &vec_quadr, false, t_sym_tab, depth_scope, "main");
        if($5.is_temperorary)
        {
            temp_var = 0;
            $5.is_temperorary = false;
        }
    }

statement: datatype ID {
        add_symbol_to_scope(t_sym_tab, depth_scope, "main", TYPE_VARIABLE, &data_type, yytext, counter); 
    } init {
        $2.node = ast_new($2.name, NULL, NULL, AST_ID);
        $$.node = ast_new("declaration", $2.node, $4.node, AST_DECLARATION);
        if($4.node->type == AST_NULL)
        {
            quadr_arg_t arg1 = {0};
            quadr_init_arg(&arg1, "0", QUADR_ARG_INT);

            quadr_arg_t res = {0};
            quadr_init_arg(&res, $2.name, QUADR_ARG_STR);

            quadr_gencode(QUAD_TYPE_COPY, 0, arg1, (quadr_arg_t){0}, res, &vec_quadr, false, t_sym_tab, depth_scope, "main");
        }
    }
    | ID { check_variable_declaration($1.name); } '=' expression {
        $1.node = ast_new($1.name, NULL, NULL, AST_ID);
        $$.node = ast_new("=", $1.node, $4.node, AST_ASSIGNATION);

        quadr_arg_t arg1 = {0};
        quadr_init_arg(&arg1, $4.name, $4.is_temperorary ? QUADR_ARG_TMP_VAR : QUADR_ARG_STR);

        quadr_arg_t res = {0};
        quadr_init_arg(&res, $1.name, $1.is_temperorary ? QUADR_ARG_TMP_VAR : QUADR_ARG_STR);

        quadr_gencode(QUAD_TYPE_COPY, 0, arg1, (quadr_arg_t){0}, res, &vec_quadr, false, t_sym_tab, depth_scope, "main");
        if($4.is_temperorary || $1.is_temperorary)
            temp_var = 0;
        if($4.is_temperorary)
            $4.is_temperorary = false;
        if($1.is_temperorary)
            $1.is_temperorary = false;
    }
    ;

init: '=' expression {
        $$.node = $2.node;

        quadr_arg_t arg1 = {0};
        quadr_init_arg(&arg1, $2.name, $2.is_temperorary ? QUADR_ARG_TMP_VAR : QUADR_ARG_STR);

        quadr_arg_t res = {0};
        quadr_init_arg(&res, $$.name, $$.is_temperorary ? QUADR_ARG_TMP_VAR : QUADR_ARG_STR);

        quadr_gencode(QUAD_TYPE_COPY, 0, arg1, (quadr_arg_t){0}, res, &vec_quadr, false, t_sym_tab, depth_scope, "main");
        if($2.is_temperorary)
        {
            temp_var = 0;
            $2.is_temperorary = false;
        }
    }
    | ',' ID { // can't do float a = 1.2, b = 2.3; ... yet
        add_symbol_to_scope(t_sym_tab, depth_scope, "main", TYPE_VARIABLE, &data_type, yytext, counter); 
        $$.node = ast_new($2.name, NULL, NULL, AST_ID);
        quadr_arg_t arg1 = {0};
        quadr_init_arg(&arg1, "0", QUADR_ARG_INT);
        
        quadr_arg_t res = {0};
        quadr_init_arg(&res, $2.name, QUADR_ARG_STR);
        
        quadr_gencode(QUAD_TYPE_COPY, 0, arg1, (quadr_arg_t){0}, res, &vec_quadr, false, t_sym_tab, depth_scope, "main");
    } 
    | { 
        $$.node = ast_new("NULL", NULL, NULL, AST_NULL); 
    }
    ;

printf_statement: PRINTF {
        add_symbol_to_scope(t_sym_tab, depth_scope, "main", TYPE_KEYWORD, &data_type, yytext, counter); 
    } '(' STR ')' ';'
    { 
        $$.node = ast_new("printf", NULL, NULL, AST_LIB_FUNCTION);
        enum data_type type = TYPE_STR;
        add_symbol_to_scope(t_sym_tab, depth_scope, "main", TYPE_CONST, &type, $4.name, counter);
        quadr_arg_t arg1 = {0};
        quadr_init_arg(&arg1, $4.name, QUADR_ARG_STR);
        quadr_gencode(QUAD_TYPE_SYSCALL_PRINT_STR, 0, arg1, (quadr_arg_t){0}, (quadr_arg_t){0},  &vec_quadr, false, t_sym_tab, depth_scope, "main");
    }
    ;

print_statement: PRINT {
        add_symbol_to_scope(t_sym_tab, depth_scope, "main", TYPE_KEYWORD, &data_type, yytext, counter); 
    } '(' ID { check_variable_declaration($1.name); } ')' ';' 
    {
        $$.node = ast_new("print", NULL, NULL, AST_LIB_FUNCTION);
        quadr_arg_t arg1 = {0};
        switch(data_type)
        {
            case TYPE_INT:
            {
                quadr_init_arg(&arg1, $4.name, QUADR_ARG_INT);
                quadr_gencode(QUAD_TYPE_SYSCALL_PRINT_INT, 0, arg1, (quadr_arg_t){0}, (quadr_arg_t){0},  &vec_quadr, false, t_sym_tab, depth_scope, "main");
                break;
            }
            case TYPE_FLOAT:
            {
                quadr_init_arg(&arg1, $4.name, QUADR_ARG_FLOAT);
                quadr_gencode(QUAD_TYPE_SYSCALL_PRINT_FLOAT, 0, arg1, (quadr_arg_t){0}, (quadr_arg_t){0},  &vec_quadr, false, t_sym_tab, depth_scope, "main");
                break;
            }
            default:
            {
                fprintf(stderr, "Error: can't print %s at line %d\n", $4.name, counter);
                error_count++;
                break;
            }
        }
    }
    ;

condition: value LT value {
        $$.node = ast_new($2.name, $1.node, $3.node, AST_RELOP);
        quadr_genrelop($$.if_block, $$.else_block, $1.name, $3.name, QUAD_OP_LT);
    }
    | value GT value {
        $$.node = ast_new($2.name, $1.node, $3.node, AST_RELOP);
        quadr_genrelop($$.if_block, $$.else_block, $1.name, $3.name, QUAD_OP_GT);
    }
    | value LE value {
        $$.node = ast_new($2.name, $1.node, $3.node, AST_RELOP);
        quadr_genrelop($$.if_block, $$.else_block, $1.name, $3.name, QUAD_OP_LE);
    }
    | value GE value {
        $$.node = ast_new($2.name, $1.node, $3.node, AST_RELOP);
        quadr_genrelop($$.if_block, $$.else_block, $1.name, $3.name, QUAD_OP_GE);
    }
    | value EQ value {
        $$.node = ast_new($2.name, $1.node, $3.node, AST_RELOP);
        quadr_genrelop($$.if_block, $$.else_block, $1.name, $3.name, QUAD_OP_EQ);
    }
    | value NE value {
        $$.node = ast_new($2.name, $1.node, $3.node, AST_RELOP);
        quadr_genrelop($$.if_block, $$.else_block, $1.name, $3.name, QUAD_OP_NE);
    }
    ;


expression: expression ADD expression {
        $$.node = ast_new($2.name, $1.node, $3.node, AST_ADD);
        sprintf($$.name, "t%d", temp_var++);
        $$.is_temperorary = true;
        quadr_arg_t arg1 = {0};
        quadr_init_arg(&arg1, $1.name, $1.is_temperorary ? QUADR_ARG_TMP_VAR : QUADR_ARG_STR);
        
        quadr_arg_t arg2 = {0};
        quadr_init_arg(&arg2, $3.name, $3.is_temperorary ? QUADR_ARG_TMP_VAR : QUADR_ARG_STR);

        quadr_arg_t res = {0};
        quadr_init_arg(&res, $$.name, QUADR_ARG_TMP_VAR);
        
        quadr_gencode(QUAD_TYPE_BINARY_ASSIGN, QUAD_OP_ADD, arg1, arg2, res, &vec_quadr, true, t_sym_tab, depth_scope, "main");
    }
    | expression SUBTRACT expression {
        $$.node = ast_new($2.name, $1.node, $3.node, AST_SUBTRACT);
        sprintf($$.name, "t%d", temp_var++);
        $$.is_temperorary = true;

        quadr_arg_t arg1 = {0};
        quadr_init_arg(&arg1, $1.name, $1.is_temperorary ? QUADR_ARG_TMP_VAR : QUADR_ARG_STR);

        quadr_arg_t arg2 = {0};
        quadr_init_arg(&arg2, $3.name, $3.is_temperorary ? QUADR_ARG_TMP_VAR : QUADR_ARG_STR);

        quadr_arg_t res = {0};
        quadr_init_arg(&res, $$.name, QUADR_ARG_TMP_VAR);

        quadr_gencode(QUAD_TYPE_BINARY_ASSIGN, QUAD_OP_SUB, arg1, arg2, res, &vec_quadr, true, t_sym_tab, depth_scope, "main");
    }
    | expression MULTIPLY expression {
        $$.node = ast_new($2.name, $1.node, $3.node, AST_MULTIPLY);
        sprintf($$.name, "t%d", temp_var++);
        $$.is_temperorary = true;

        quadr_arg_t arg1 = {0};
        quadr_init_arg(&arg1, $1.name, QUADR_ARG_STR);

        quadr_arg_t arg2 = {0};
        quadr_init_arg(&arg2, $3.name, $3.is_temperorary ? QUADR_ARG_TMP_VAR : QUADR_ARG_STR);

        quadr_arg_t res = {0};
        quadr_init_arg(&res, $$.name, QUADR_ARG_TMP_VAR);

        quadr_gencode(QUAD_TYPE_BINARY_ASSIGN, QUAD_OP_MUL, arg1, arg2, res, &vec_quadr, true, t_sym_tab, depth_scope, "main");
    }
    | expression DIVIDE expression {
        $$.node = ast_new($2.name, $1.node, $3.node, AST_DIVIDE);
        sprintf($$.name, "t%d", temp_var++);
        $$.is_temperorary = true;
        
        quadr_arg_t arg1 = {0};
        quadr_init_arg(&arg1, $1.name, QUADR_ARG_STR);

        quadr_arg_t arg2 = {0};
        quadr_init_arg(&arg2, $3.name, $3.is_temperorary ? QUADR_ARG_TMP_VAR : QUADR_ARG_STR);

        quadr_arg_t res = {0};
        quadr_init_arg(&res, $$.name, QUADR_ARG_TMP_VAR);
        
        quadr_gencode(QUAD_TYPE_BINARY_ASSIGN, QUAD_OP_DIV, arg1, arg2, res, &vec_quadr, true, t_sym_tab, depth_scope, "main");
    }
    | value { 
        $$.node = $1.node;
    }
    ;



value: NUMBER { 
        $$.node = ast_new($1.name, NULL, NULL, AST_INTEGER);
    }
    | FLOAT_NUM { 
        $$.node = ast_new($1.name, NULL, NULL, AST_FLOAT);
    }
    | ID { 
        check_variable_declaration($1.name);
        $$.node = ast_new($1.name, NULL, NULL, AST_ID);
     }
    ;

return: RETURN { 
        add_symbol_to_scope(t_sym_tab, depth_scope, "main", TYPE_KEYWORD, &data_type, yytext, counter); 
    } expression ';' {
        $$.node = ast_new("RETURN", NULL, $3.node, AST_RETURN);
    } 
    | { $$.node = NULL; }
    ;

%%

void quadr_genrelop(char *if_block, char *else_block, char *arg1, char *arg2, enum quad_ops op)
{
    quadr_arg_t _arg1 = {0};
    quadr_init_arg(&_arg1, arg1, QUADR_ARG_STR);

    quadr_arg_t _arg2 = {0};
    quadr_init_arg(&_arg2, arg2, QUADR_ARG_STR);


    if(is_for)
    {
        sprintf(if_block, "L%d", labels++);
        quadr_arg_t res = {0};
        quadr_init_arg(&res, if_block, QUADR_ARG_LABEL);

        quadr_gencode(QUAD_TYPE_LABEL, 0, (quadr_arg_t){0}, (quadr_arg_t){0}, res,  &vec_quadr, false, t_sym_tab, depth_scope, "main");
        char tmp[1024] = {0};
        sprintf(tmp, "L%d", labels);
        
        res = (quadr_arg_t){0};
        quadr_init_arg(&res, tmp, QUADR_ARG_LABEL);
        
        quadr_gencode(QUAD_TYPE_IF_NOT, op, _arg1, _arg2, res, &vec_quadr, false, t_sym_tab, depth_scope, "main");
        sprintf(else_block, "L%d", labels++);
    }
    else
    {
        char tmp[1024] = {0};
        sprintf(tmp, "L%d", labels);

        quadr_arg_t res = {0};
        quadr_init_arg(&res, tmp, QUADR_ARG_LABEL);

        quadr_gencode(QUAD_TYPE_IF, op, _arg1, _arg2, res, &vec_quadr, false, t_sym_tab, depth_scope, "main");
        sprintf(tmp, "L%d\n", labels+1);

        res = (quadr_arg_t){0};
        quadr_init_arg(&res, tmp, QUADR_ARG_LABEL);

        quadr_gencode(QUAD_TYPE_GOTO, 0, (quadr_arg_t){0}, (quadr_arg_t){0}, res,  &vec_quadr, false, t_sym_tab, depth_scope, "main");
        sprintf(if_block, "L%d", labels++);
        sprintf(else_block, "L%d", labels++);
    }
}

void check_variable_declaration(char* token) {
    vec_vec_hashmap_t *v_scopes = (vec_vec_hashmap_t *)hashmap_get(t_sym_tab, "main");
    int current_size_scope = v_scopes->data[depth_scope].length - 1;
    if (current_size_scope < 0)
        return;
    for(int i = depth_scope; i >= 0; --i)
    {
        vec_hashmap_t *tmp = &v_scopes->data[i];
        for(int j = tmp->length - 1; j >= 0; --j)
        {
            if(hashmap_get(tmp->data[j], token) != NULL)
                return;
            // if we are in the current scope, we only check the last hashmap
            // else we check all the hashmap from the last to the first
            if(i == depth_scope)
                break;
        }
    }
    fprintf(stderr, "Variable %s is not declared at line %d\n", token, counter);
    error_count++;
}

void yyerror(const char* msg) {
  fprintf(stderr, "%s: '%s' in line %d\n", msg, yytext, yylineno);
}