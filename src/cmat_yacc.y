%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <unistd.h>
    #include <ctype.h>
    #include <stdbool.h>
    #include "../include/hashmap.h"
    #include "../include/symbol.h"
    #include "../include/quadr.h"
    #include "../include/utils.h"


    int yylex();
    int yywrap();
    extern char* yytext;
    extern int yylineno;


    void quadr_genrelop(char *if_block, char *else_block, char *arg1, char *arg2, enum quad_ops op);
    symbol_t *check_variable_declaration(char* token);
    bool check_function_declaration(char* token);
    
    extern char linebuf[1024];
    extern int counter;

    vec_quadr_t vec_quadr;
    hashmap_t *t_sym_tab;
    enum data_type data_type;
    char current_function[1024] = {0};
    bool is_for = false;
    bool is_while = false;
    bool in_if_condition = false;
    int error_count = 0;
    int temp_var = 0;
    int labels = 0;
    int if_counter = 0;
    int depth_scope = 0;
    vec_int_t i_if_end;
%}

%define parse.error verbose

%union {
    struct node {
        char name[1024];
        _Bool is_temperorary;
        _Bool is_null;
        _Bool is_variable;
        _Bool is_function;
    } node_t;

    struct cond_node {
        char if_block[1024];
        char else_block[1024];
    } cond_node_t;
}
%{
    void yyerror(const char *msg);
    void init_arg_expression(enum quad_ops op_exp, struct node *n1, struct node *n3, struct node *nn);    
%}

%token <node_t> PRINT PRINTF 
%token <node_t> ID STR INT FLOAT FLOAT_NUM NUMBER
%token <node_t>  IF ELSE LE GE EQ NE GT LT
%token <node_t> ADD MULTIPLY DIVIDE SUBTRACT UNARY
%token <node_t> FOR WHILE RETURN

%type <node_t> iterator iterator_init 
%type <node_t> printf_statement print_statement
%type <node_t> program body scope return
%type <node_t> function function_call function_call_args function_call_arg function_args function_arg function_body
%type <node_t> datatype expression init inits value
%type <node_t> statement body_element for_statement while_statement if_statement else

%type <cond_node_t> condition 
%left ADD SUBTRACT 
%left MULTIPLY DIVIDE
%locations
%%

program: function program
    | function
    ;

function: datatype ID { 
        init_scope_key(t_sym_tab, $2.name);
        add_symbol_to_scope(t_sym_tab, depth_scope, $2.name, TYPE_FUNCTION, &data_type, yytext, counter);
        sprintf(current_function, "%s", $2.name);
        
        _Bool is_main = strcmp(current_function, "main") == 0;
        static int main_counter = 0;
        if(is_main && main_counter++ > 0)
            yyerror("Main function already declared");

        quadr_arg_t res = {0};
        quadr_init_arg(&res, current_function, QUADR_ARG_LABEL, TYPE_STR);
        quadr_gencode(is_main ? QUAD_TYPE_LABEL : QUAD_TYPE_LABEL_FUNCTION, 0, (quadr_arg_t){0}, (quadr_arg_t){0}, 
                        res, &vec_quadr,  t_sym_tab, depth_scope, current_function);
        depth_scope = 0;
    } '(' function_args ')' '{' function_body '}'
    ;

function_body:  body return 
    | return
    ;

function_args: function_arg
    | function_args ',' function_arg
    ;

function_arg: datatype ID {
        add_symbol_to_scope(t_sym_tab, depth_scope, current_function, TYPE_VARIABLE, &data_type, yytext, counter);
        quadr_arg_t arg1 = {0};
        quadr_init_arg(&arg1, $2.name, QUADR_ARG_STR, data_type);
        quadr_gencode(QUAD_TYPE_PARAM_FUNCTION, 0, arg1, (quadr_arg_t){0}, (quadr_arg_t){0}, &vec_quadr,  t_sym_tab, depth_scope, current_function);
    }
    | %empty
    ;
   

datatype: INT { data_type = TYPE_INT; }
    | FLOAT { data_type = TYPE_FLOAT; }
    ;


body: body_element
    | body body_element
    | body error body_element
    ;


body_element: for_statement
    | while_statement
    | if_statement
    | statement ';'
    | printf_statement
    | print_statement
    ;

scope: '{' { 
        if(!is_for)
        {
            ++depth_scope;
            vec_vec_hashmap_t *v_scopes = (vec_vec_hashmap_t *)hashmap_get(t_sym_tab, current_function);
            if (v_scopes->length - 1 < depth_scope)
                vec_push(v_scopes, (vec_hashmap_t){0});
            // missing a condition here
            vec_push(&v_scopes->data[depth_scope], hashmap_init(10));
        }
    } body '}' {
        --depth_scope;
        clear_empty_hashmaps(t_sym_tab, depth_scope+1, current_function);
    }
    ;

while_statement: WHILE { 
        is_while = true; 
    } '(' condition ')' {
       
    } scope {
        quadr_arg_t res = {0};
        quadr_init_arg(&res, $4.if_block, QUADR_ARG_GOTO, TYPE_STR);
        quadr_gencode(QUAD_TYPE_GOTO, 0, (quadr_arg_t){0}, (quadr_arg_t){0}, res, &vec_quadr,  t_sym_tab, depth_scope, current_function);

        res = (quadr_arg_t){0};
        quadr_init_arg(&res, $4.else_block, QUADR_ARG_LABEL, TYPE_STR);
        quadr_gencode(QUAD_TYPE_LABEL, 0, (quadr_arg_t){0}, (quadr_arg_t){0}, res,  &vec_quadr,  t_sym_tab, depth_scope, current_function);
        is_while = false;
    }

for_statement: FOR { 
        is_for = true;
    } '(' iterator_init ';' condition ';' iterator ')' scope {
        quadr_arg_t res = {0};
        quadr_init_arg(&res, $6.if_block, QUADR_ARG_GOTO, TYPE_STR);
        quadr_gencode(QUAD_TYPE_GOTO, 0, (quadr_arg_t){0}, (quadr_arg_t){0}, res, &vec_quadr,  t_sym_tab, depth_scope, current_function);
        res = (quadr_arg_t){0};
        quadr_init_arg(&res, $6.else_block, QUADR_ARG_LABEL, TYPE_STR);
        quadr_gencode(QUAD_TYPE_LABEL, 0, (quadr_arg_t){0}, (quadr_arg_t){0}, res,  &vec_quadr,  t_sym_tab, depth_scope, current_function);
    }

if_statement: IF { 
        is_for = false;
        in_if_condition = true;
        ++if_counter;
    } '(' condition ')' {
        quadr_arg_t res = {0};
        quadr_init_arg(&res, $4.if_block, QUADR_ARG_LABEL, TYPE_STR);
        quadr_gencode(QUAD_TYPE_LABEL, 0, (quadr_arg_t){0}, (quadr_arg_t){0}, res,  &vec_quadr,  t_sym_tab, depth_scope, current_function);
    } scope {
        char tmp2[1024] = {0};
        sprintf(tmp2, "L%d", labels);
        quadr_arg_t res = {0};
        quadr_init_arg(&res, tmp2, QUADR_ARG_GOTO, TYPE_STR);
        quadr_gencode(QUAD_TYPE_GOTO, 0, (quadr_arg_t){0}, (quadr_arg_t){0}, res,  &vec_quadr,  t_sym_tab, depth_scope, current_function);
        if(in_if_condition)
            vec_push(&i_if_end, vec_quadr.length-1);
        res = (quadr_arg_t){0};
        quadr_init_arg(&res, $4.else_block, QUADR_ARG_LABEL, TYPE_STR);
        quadr_gencode(QUAD_TYPE_LABEL, 0, (quadr_arg_t){0}, (quadr_arg_t){0}, res,  &vec_quadr,  t_sym_tab, depth_scope, current_function);
    }
    else

else: ELSE scope {
        if(in_if_condition && --if_counter == 0)
        {
            char tmp2[1024] = {0};
            sprintf(tmp2, "L%d", labels);
            quadr_arg_t res = {0};
            quadr_init_arg(&res, tmp2, QUADR_ARG_LABEL, TYPE_STR);
            quadr_gencode(QUAD_TYPE_LABEL, 0, (quadr_arg_t){0}, (quadr_arg_t){0}, res,  &vec_quadr,  t_sym_tab, depth_scope, current_function);
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
    ;


iterator: ID { 
        check_variable_declaration($1.name);
    } UNARY {
        char tmp[1024] = {0};
        sprintf(tmp, "t%d", temp_var);
        
        quadr_arg_t arg1 = {0};
        quadr_init_arg(&arg1, $1.name, QUADR_ARG_STR, TYPE_INT);
        quadr_arg_t _arg1 = {0};
        quadr_init_arg(&_arg1, $1.name, QUADR_ARG_STR, TYPE_INT);

        quadr_arg_t arg2 = {0};
        quadr_init_arg(&arg2, "1", QUADR_ARG_INT, TYPE_INT);
        
        quadr_arg_t res = {0};
        quadr_init_arg(&res, tmp, QUADR_ARG_TMP_VAR, TYPE_INT);
        quadr_arg_t _res = {0};
        quadr_init_arg(&_res, tmp, QUADR_ARG_TMP_VAR, TYPE_INT);

        quadr_gencode(QUAD_TYPE_BINARY_ASSIGN, QUAD_OP_ADD, arg1, arg2, res, &vec_quadr,  t_sym_tab, depth_scope, current_function);
        quadr_gencode(QUAD_TYPE_COPY, 0, _res, (quadr_arg_t){0}, _arg1, &vec_quadr,  t_sym_tab, depth_scope, current_function);
        temp_var = 0;
    }

iterator_init: datatype ID {
        ++depth_scope;
        vec_vec_hashmap_t *v_scopes = (vec_vec_hashmap_t *)hashmap_get(t_sym_tab, current_function);
        if (v_scopes->length - 1 < depth_scope)
            vec_push(v_scopes, (vec_hashmap_t){0});
        // missing a condition here
        vec_push(&v_scopes->data[depth_scope], hashmap_init(10));
        add_symbol_to_scope(t_sym_tab, depth_scope, current_function, TYPE_ITERATOR, &data_type, yytext, counter); 
    } '=' value {
        quadr_arg_t arg1 = {0};
        quadr_init_arg(&arg1, $5.name, $5.is_temperorary ? QUADR_ARG_TMP_VAR : QUADR_ARG_STR, data_type);

        quadr_arg_t res = {0};
        quadr_init_arg(&res, $2.name, $2.is_temperorary ? QUADR_ARG_TMP_VAR : QUADR_ARG_STR, data_type);

        quadr_gencode(QUAD_TYPE_COPY, 0, arg1, (quadr_arg_t){0}, res, &vec_quadr,  t_sym_tab, depth_scope, current_function);
        if($5.is_temperorary)
        {
            temp_var = 0;
            $5.is_temperorary = false;
        }
    }

statement: datatype ID {
        add_symbol_to_scope(t_sym_tab, depth_scope, current_function, TYPE_VARIABLE, &data_type, yytext, counter); 
    } inits {
        if($4.is_null)
        {
            symbol_t *symbol = check_variable_declaration($2.name);
            data_type = symbol->data_type;
            quadr_arg_t arg1 = {0};
            if(data_type == TYPE_INT)
                quadr_init_arg(&arg1, "0", QUADR_ARG_INT, TYPE_INT);
            else if(data_type == TYPE_FLOAT)
                quadr_init_arg(&arg1, "0.0", QUADR_ARG_FLOAT, TYPE_FLOAT);

            quadr_arg_t res = {0};
            quadr_init_arg(&res, $2.name, QUADR_ARG_STR, data_type);

            quadr_gencode(QUAD_TYPE_COPY, 0, arg1, (quadr_arg_t){0}, res, &vec_quadr,  t_sym_tab, depth_scope, current_function);
        }
    }
    | ID { 
        symbol_t *symbol = check_variable_declaration($1.name);
        if(symbol != NULL)
            data_type = symbol->data_type;
    } '=' expression {
        quadr_arg_t arg1 = {0};
        if(!$4.is_function)
            quadr_init_arg(&arg1, $4.name, $4.is_temperorary ? QUADR_ARG_TMP_VAR : QUADR_ARG_STR, data_type);
        else
            quadr_init_arg(&arg1, "v0", QUADR_ARG_RETURN_FUNCTION, data_type);
        quadr_arg_t res = {0};
        quadr_init_arg(&res, $1.name, $1.is_temperorary ? QUADR_ARG_TMP_VAR : QUADR_ARG_STR, data_type);

        quadr_gencode(QUAD_TYPE_COPY, 0, arg1, (quadr_arg_t){0}, res, &vec_quadr,  t_sym_tab, depth_scope, current_function);
        if($4.is_temperorary || $1.is_temperorary)
            temp_var = 0;
        if($4.is_temperorary)
            $4.is_temperorary = false;
        if($1.is_temperorary)
            $1.is_temperorary = false;
    }
    ;

inits: init
    | inits ',' init
    ;

init: '=' expression {
        quadr_arg_t arg1 = {0};
        enum data_type data_type_tmp;
        if($2.is_variable && !$2.is_temperorary && !$2.is_function)
        {
            symbol_t *symbol = check_variable_declaration($2.name);
            data_type_tmp = symbol!= NULL ? symbol->data_type : data_type;
        }
        else
        {
            if(is_str_float($2.name))
                data_type_tmp = TYPE_FLOAT;
            else
                data_type_tmp = data_type;
        }
        quadr_init_arg(&arg1, $2.name, $2.is_temperorary ? QUADR_ARG_TMP_VAR : QUADR_ARG_STR, data_type_tmp);

        quadr_arg_t res = {0};
        quadr_init_arg(&res, $$.name, $$.is_temperorary ? QUADR_ARG_TMP_VAR : QUADR_ARG_STR, data_type);

        quadr_gencode(QUAD_TYPE_COPY, 0, arg1, (quadr_arg_t){0}, res, &vec_quadr,  t_sym_tab, depth_scope, current_function);
        if($2.is_temperorary)
        {
            temp_var = 0;
            $2.is_temperorary = false;
        }
    }
    | ID {
        // symbol_t *symbol = check_variable_declaration($1.name);
        // if(symbol != NULL)
        //     data_type = symbol->data_type;
        add_symbol_to_scope(t_sym_tab, depth_scope, current_function, TYPE_VARIABLE, &data_type, yytext, counter); 
        quadr_arg_t arg1 = {0};
        if(data_type == TYPE_INT)
            quadr_init_arg(&arg1, "0", QUADR_ARG_INT, TYPE_INT);
        else if(data_type == TYPE_FLOAT)
            quadr_init_arg(&arg1, "0.0", QUADR_ARG_FLOAT, TYPE_FLOAT);
        
        quadr_arg_t res = {0};
        quadr_init_arg(&res, $1.name, QUADR_ARG_STR, data_type);
        
        quadr_gencode(QUAD_TYPE_COPY, 0, arg1, (quadr_arg_t){0}, res, &vec_quadr,  t_sym_tab, depth_scope, current_function);
    } 
    /* | ID '=' expression {
        add_symbol_to_scope(t_sym_tab, depth_scope, current_function, TYPE_VARIABLE, &data_type, yytext, counter);
        quadr_arg_t arg1 = {0};
        quadr_init_arg(&arg1, $3.name, $3.is_temperorary ? QUADR_ARG_TMP_VAR : QUADR_ARG_STR);

        quadr_arg_t res = {0};
        quadr_init_arg(&res, $1.name, QUADR_ARG_STR);

        quadr_gencode(QUAD_TYPE_COPY, 0, arg1, (quadr_arg_t){0}, res, &vec_quadr,  t_sym_tab, depth_scope, current_function);
        if($3.is_temperorary)
        {
            temp_var = 0;
            $3.is_temperorary = false;
        }
    } */
    | %empty { 
        $$.is_null = true;
    }
    ;



printf_statement: PRINTF {
        add_symbol_to_scope(t_sym_tab, depth_scope, current_function, TYPE_KEYWORD, &data_type, yytext, counter); 
    } '(' STR ')' ';'
    { 
        quadr_arg_t arg1 = {0};
        quadr_init_arg(&arg1, $4.name, QUADR_ARG_STR, TYPE_STR);
        quadr_gencode(QUAD_TYPE_SYSCALL_PRINT_STR, 0, arg1, (quadr_arg_t){0}, (quadr_arg_t){0},  &vec_quadr, t_sym_tab, depth_scope, current_function);
    }
    ;

print_statement: PRINT '(' ID { 
        symbol_t *symbol = check_variable_declaration($3.name);
        if(symbol != NULL)
            data_type = symbol->data_type;
    } ')' ';' 
    {
        quadr_arg_t arg1 = {0};
        switch(data_type)
        {
            case TYPE_INT:
            {
                quadr_init_arg(&arg1, $3.name, QUADR_ARG_INT, TYPE_INT);
                quadr_gencode(QUAD_TYPE_SYSCALL_PRINT_INT, 0, arg1, (quadr_arg_t){0}, (quadr_arg_t){0},  &vec_quadr,  t_sym_tab, depth_scope, current_function);
                break;
            }
            case TYPE_FLOAT:
            {
                quadr_init_arg(&arg1, $3.name, QUADR_ARG_FLOAT, TYPE_FLOAT);
                quadr_gencode(QUAD_TYPE_SYSCALL_PRINT_FLOAT, 0, arg1, (quadr_arg_t){0}, (quadr_arg_t){0},  &vec_quadr,  t_sym_tab, depth_scope, current_function);
                break;
            }
            default:
            {
                yyerror("Invalid type");
                break;
            }
        }
    }
    ;

condition: value LT value {
        quadr_genrelop($$.if_block, $$.else_block, $1.name, $3.name, QUAD_OP_LT);
    }
    | value GT value {
        quadr_genrelop($$.if_block, $$.else_block, $1.name, $3.name, QUAD_OP_GT);
    }
    | value LE value {
        quadr_genrelop($$.if_block, $$.else_block, $1.name, $3.name, QUAD_OP_LE);
    }
    | value GE value {
        quadr_genrelop($$.if_block, $$.else_block, $1.name, $3.name, QUAD_OP_GE);
    }
    | value EQ value {
        quadr_genrelop($$.if_block, $$.else_block, $1.name, $3.name, QUAD_OP_EQ);
    }
    | value NE value {
        quadr_genrelop($$.if_block, $$.else_block, $1.name, $3.name, QUAD_OP_NE);
    }
    ;



expression: expression ADD expression {
        init_arg_expression(QUAD_OP_ADD, &$1, &$3, &$$);
    }
    | expression SUBTRACT expression {
        init_arg_expression(QUAD_OP_SUB, &$1, &$3, &$$);
    }
    | expression MULTIPLY expression {
        init_arg_expression(QUAD_OP_MUL, &$1, &$3, &$$);
    }
    | expression DIVIDE expression {
        if(!$3.is_variable && $3.name[0] == '0')
            yyerror("Division by zero");
        else if($3.is_variable)
        {
            // need to check the data of the variable
        }
        else
            init_arg_expression(QUAD_OP_DIV, &$1, &$3, &$$);
    }
    | value
    | function_call
    ;

function_call: ID { 
        $1.is_function = check_function_declaration($1.name);
    } '(' function_call_args ')' {
        quadr_arg_t res = {0};
        quadr_init_arg(&res, $1.name, QUADR_ARG_STR, TYPE_STR);
        quadr_gencode(QUAD_TYPE_CALL, 0, (quadr_arg_t){0}, (quadr_arg_t){0}, res, &vec_quadr,  t_sym_tab, depth_scope, current_function);
    }
    ;

function_call_args: function_call_arg
    | function_call_args ',' function_call_arg
    ;

function_call_arg: expression {
        quadr_arg_t arg1 = {0};
        quadr_init_arg(&arg1, $1.name, $1.is_temperorary ? QUADR_ARG_TMP_VAR : QUADR_ARG_STR, data_type);
        quadr_gencode(QUAD_TYPE_PARAM_CALL, 0, arg1, (quadr_arg_t){0}, (quadr_arg_t){0}, &vec_quadr,  t_sym_tab, depth_scope, current_function);
        if($1.is_temperorary)
        {
            temp_var = 0;
            $1.is_temperorary = false;
        }
    }
    ;




value: NUMBER { $$.is_variable = false; }
    | FLOAT_NUM { $$.is_variable = false; }
    | ID { 
        check_variable_declaration($1.name);
        $$.is_variable = true;
     }
    ;

return: RETURN { 
        add_symbol_to_scope(t_sym_tab, depth_scope, current_function, TYPE_KEYWORD, &data_type, yytext, counter); 
    } expression ';' {
        quadr_arg_t arg1 = {0};

        quadr_init_arg(&arg1, $3.name, $3.is_temperorary ? QUADR_ARG_TMP_VAR : QUADR_ARG_STR, data_type);

        _Bool is_main = strcmp(current_function, "main") == 0;
        quadr_gencode(is_main ? QUAD_TYPE_RETURN_MAIN : QUAD_TYPE_RETURN_FUNCTION, 0, arg1, (quadr_arg_t){0}, (quadr_arg_t){0},  
                        &vec_quadr,  t_sym_tab, depth_scope, current_function);
    }
    ;

%%

void quadr_genrelop(char *if_block, char *else_block, char *arg1, char *arg2, enum quad_ops op)
{
    // need to retrieve the type of arg1 and arg2
    quadr_arg_t _arg1 = {0};
    quadr_init_arg(&_arg1, arg1, QUADR_ARG_STR, data_type);

    quadr_arg_t _arg2 = {0};
    quadr_init_arg(&_arg2, arg2, QUADR_ARG_STR, data_type);


    if(is_for || is_while)
    {
        sprintf(if_block, "L%d", labels++);
        quadr_arg_t res = {0};
        quadr_init_arg(&res, if_block, QUADR_ARG_LABEL, TYPE_STR);

        quadr_gencode(QUAD_TYPE_LABEL, 0, (quadr_arg_t){0}, (quadr_arg_t){0}, res,  &vec_quadr,  t_sym_tab, depth_scope, current_function);
        char tmp[1024] = {0};
        sprintf(tmp, "L%d", labels);
        
        res = (quadr_arg_t){0};
        quadr_init_arg(&res, tmp, QUADR_ARG_LABEL, TYPE_STR);
        
        quadr_gencode(QUAD_TYPE_IF_NOT, op, _arg1, _arg2, res, &vec_quadr,  t_sym_tab, depth_scope, current_function);
        sprintf(else_block, "L%d", labels++);
    }
    else
    {
        char tmp[1024] = {0};
        sprintf(tmp, "L%d", labels);

        quadr_arg_t res = {0};
        quadr_init_arg(&res, tmp, QUADR_ARG_LABEL, TYPE_STR);

        quadr_gencode(QUAD_TYPE_IF, op, _arg1, _arg2, res, &vec_quadr,  t_sym_tab, depth_scope, current_function);
        sprintf(tmp, "L%d\n", labels+1);

        res = (quadr_arg_t){0};
        quadr_init_arg(&res, tmp, QUADR_ARG_LABEL, TYPE_STR);

        quadr_gencode(QUAD_TYPE_GOTO, 0, (quadr_arg_t){0}, (quadr_arg_t){0}, res,  &vec_quadr,  t_sym_tab, depth_scope, current_function);
        sprintf(if_block, "L%d", labels++);
        sprintf(else_block, "L%d", labels++);
    }
}

void init_arg_expression(enum quad_ops op_exp, struct node *n1, struct node *n3, struct node *nn)
{
    char var = data_type == TYPE_INT ? 't' : 'f';
    sprintf(nn->name, "%c%d", var, ++temp_var);
    nn->is_temperorary = true;
    enum data_type data_type_tmp;
    if(n1->is_temperorary)
    {
        if(n1->name[0] == 'f')
            data_type_tmp = TYPE_FLOAT;
        else
            data_type_tmp = TYPE_INT;
    }
    else if(n1->is_variable)
    {
        symbol_t *symbol = check_variable_declaration(n1->name);
        data_type_tmp = symbol != NULL ? symbol->data_type : data_type;
    }
    else
    {
        if(is_str_float(n1->name))
            data_type_tmp = TYPE_FLOAT;
        else
            data_type_tmp = data_type;
    }
        
    quadr_arg_t arg1 = {0};
    quadr_init_arg(&arg1, n1->name, n1->is_temperorary ? QUADR_ARG_TMP_VAR : QUADR_ARG_STR, data_type_tmp);
    
    if(n3->is_temperorary)
    {
        if(n3->name[0] == 'f')
            data_type_tmp = TYPE_FLOAT;
        else
            data_type_tmp = TYPE_INT;
    }
    else if(n3->is_variable)
    {
        symbol_t *symbol = check_variable_declaration(n3->name);
        data_type_tmp = symbol != NULL ? symbol->data_type : data_type;
    }
    else
    {
        if(is_str_float(n3->name))
            data_type_tmp = TYPE_FLOAT;
        else
            data_type_tmp = data_type;
    }
    quadr_arg_t arg2 = {0};
    quadr_init_arg(&arg2, n3->name, n3->is_temperorary ? QUADR_ARG_TMP_VAR : QUADR_ARG_STR, data_type_tmp);


    if(nn->is_temperorary)
    {
        if(nn->name[0] == 'f')
            data_type_tmp = TYPE_FLOAT;
        else
            data_type_tmp = TYPE_INT;
    }
    else if(nn->is_variable)
    {
        symbol_t *symbol = check_variable_declaration(nn->name);
        data_type_tmp = symbol != NULL ? symbol->data_type : data_type;
    }
    else
        data_type_tmp = data_type;
    quadr_arg_t res = {0};
    quadr_init_arg(&res, nn->name, QUADR_ARG_TMP_VAR, data_type_tmp);
    // This for the backends, it force that the tmp variable is arg1 and not arg2
    if(n1->is_temperorary)   
        quadr_gencode(QUAD_TYPE_BINARY_ASSIGN, op_exp, arg1, arg2, res, &vec_quadr,  t_sym_tab, depth_scope, current_function);
    else if(n3->is_temperorary)
        quadr_gencode(QUAD_TYPE_BINARY_ASSIGN, op_exp, arg2, arg1, res, &vec_quadr,  t_sym_tab, depth_scope, current_function);
    else
        quadr_gencode(QUAD_TYPE_BINARY_ASSIGN, op_exp, arg1, arg2, res, &vec_quadr,  t_sym_tab, depth_scope, current_function);
    temp_var = 0;
}

symbol_t *check_variable_declaration(char* token) {
    vec_vec_hashmap_t *v_scopes = (vec_vec_hashmap_t *)hashmap_get(t_sym_tab, current_function);
    int current_size_scope = v_scopes->data[depth_scope].length - 1;
    if (current_size_scope < 0)
        return NULL;
    for(int i = depth_scope; i >= 0; --i)
    {
        vec_hashmap_t *tmp = &v_scopes->data[i];
        for(int j = tmp->length - 1; j >= 0; --j)
        {
            symbol_t *symbol = (symbol_t*)hashmap_get(tmp->data[j], token);
            if(symbol != NULL)
                return symbol;
            // if we are in the current scope, we only check the last hashmap
            // else we check all the hashmap from the last to the first
            if(i == depth_scope)
                break;
        }
    }
    yyerror("Variable not declared");
    printf("%s\n", current_function);
    return NULL;
}

bool check_function_declaration(char* token) {
    vec_vec_hashmap_t *v_scopes = (vec_vec_hashmap_t *)hashmap_get(t_sym_tab, current_function);
    if(v_scopes != NULL)
        return true;
    yyerror("Function not declared");
    printf("%s\n", current_function);
    return false;
}

void yyerror(const char* msg) {
    fprintf(stderr, ANSI_COLOR_CYAN "ERROR: %s: " ANSI_RESET
                         ANSI_BOLD  "'%s' " ANSI_RESET
                     ANSI_UNDERLINE "in line %d\n" ANSI_RESET, msg, yytext, yylineno);
    
    if(yylloc.first_line)
    {
        /* fprintf(stderr, "%d.%d-%d.%d: error\n", yylloc.first_line, yylloc.first_column,
        yylloc.last_line, yylloc.last_column); */
        fprintf(stderr, "%s\n", linebuf);
        int len = yylloc.last_column - yylloc.first_column;
        for(int i = 0; i < yylloc.first_column-1; ++i)
            fprintf(stderr, " ");
        for(int i = 0; i < len; ++i)
            if(i == 0)
                fprintf(stderr, "^");
            else
                fprintf(stderr, "~");
        fprintf(stderr, "\n");
    }
    error_count++;
}
