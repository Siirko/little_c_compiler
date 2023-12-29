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

%token <node_t>  PRINTFF INT FLOAT FOR IF ELSE NUMBER FLOAT_NUM ID LE GE EQ NE GT LT STR ADD MULTIPLY DIVIDE SUBTRACT UNARY RETURN 
%type <node_t> iterator iterator_init printf_statement main body scope return datatype expression statement init value program else body_element for_statement if_statement
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
    }
    ;

for_statement: FOR { 
        is_for = true;
    } '(' iterator_init ';' condition ';' iterator ')' scope {
        ast_t *tmp = ast_new("CONDITION", $6.node, $8.node, AST_CONDITION);
        ast_t *tmp2 = ast_new("CONDITION", $4.node, tmp, AST_CONDITION);
        $$.node = ast_new($1.name, tmp2, $10.node, AST_FOR);
        quadr_gencode(QUAD_TYPE_GOTO, 0, NULL, NULL, $6.if_block, &vec_quadr, false);
        quadr_gencode(QUAD_TYPE_LABEL, 0, NULL, NULL, $6.else_block,  &vec_quadr, false);
    }

if_statement: IF { 
        is_for = false;
        in_if_condition = true;
        ++if_counter;
    } '(' condition ')' {
        quadr_gencode(QUAD_TYPE_LABEL, 0, NULL, NULL, $4.if_block,  &vec_quadr, false);
    } scope {
        char tmp2[1024] = {0};
        sprintf(tmp2, "L%d", labels);
        quadr_gencode(QUAD_TYPE_GOTO, 0, NULL, NULL, tmp2,  &vec_quadr, false);
        if(in_if_condition)
            vec_push(&i_if_end, vec_quadr.length-1);
        quadr_gencode(QUAD_TYPE_LABEL, 0, NULL, NULL, $4.else_block,  &vec_quadr, false);
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
            quadr_gencode(QUAD_TYPE_LABEL, 0, NULL, NULL, tmp2,  &vec_quadr, false);
            int size = i_if_end.length;
            for(int i = 0; i < size; ++i)
            {
                int index = vec_pop(&i_if_end);
                free(vec_quadr.data[index].res);
                vec_quadr.data[index].res = strdup(tmp2);
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
        quadr_gencode(QUAD_TYPE_BINARY_ASSIGN, QUAD_OP_ADD, $1.name, "1", tmp, &vec_quadr, true);
        scope_t scope = get_scope(t_sym_tab, depth_scope, $1.name);
        quadr_gencode_with_scope(QUAD_TYPE_COPY, 0, tmp, NULL, $1.name, scope, &vec_quadr);
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
        scope_t scope = get_scope(t_sym_tab, depth_scope, $2.name);
        quadr_gencode_with_scope(QUAD_TYPE_COPY, 0, $5.name, NULL, $2.name, scope, &vec_quadr);
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
            scope_t scope = get_scope(t_sym_tab, depth_scope, $2.name);
            quadr_gencode_with_scope(QUAD_TYPE_COPY, 0, "0", NULL, $2.name, scope, &vec_quadr);
        }
    }
    | ID { check_variable_declaration($1.name); } '=' expression {
        $1.node = ast_new($1.name, NULL, NULL, AST_ID);
        $$.node = ast_new("=", $1.node, $4.node, AST_ASSIGNATION);
        scope_t scope = get_scope(t_sym_tab, depth_scope, $1.name);
        quadr_gencode_with_scope(QUAD_TYPE_COPY, 0, $4.name, NULL, $1.name, scope, &vec_quadr);
        if($$.is_temperorary)
        {
            temp_var = 0;
            $$.is_temperorary = false;
        }
    }
    ;

init: '=' expression {
        $$.node = $2.node;
        scope_t scope = get_scope(t_sym_tab, depth_scope, $$.name);
        quadr_gencode_with_scope(QUAD_TYPE_COPY, 0, $2.name, NULL, $$.name, scope, &vec_quadr);
        if($2.is_temperorary)
        {
            temp_var = 0;
            $2.is_temperorary = false;
        }
    }
    | ',' ID { // can't do float a = 1.2, b = 2.3; ... yet
        add_symbol_to_scope(t_sym_tab, depth_scope, "main", TYPE_VARIABLE, &data_type, yytext, counter); 
    } 
    | { 
        $$.node = ast_new("NULL", NULL, NULL, AST_NULL); 
    }
    ;

printf_statement: PRINTFF {
        add_symbol_to_scope(t_sym_tab, depth_scope, "main", TYPE_KEYWORD, &data_type, yytext, counter); 
    } '(' STR ')' ';'
    { 
        $$.node = ast_new("printf", NULL, NULL, AST_LIB_FUNCTION);
        enum data_type type = TYPE_STR;
        add_symbol_to_scope(t_sym_tab, depth_scope, "main", TYPE_CONST, &type, $4.name, counter);
        quadr_gencode(QUAD_TYPE_SYSCALL_PRINT_STR, 0, $4.name, NULL, NULL,  &vec_quadr, false);
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
        quadr_gencode(QUAD_TYPE_BINARY_ASSIGN, QUAD_OP_ADD, $1.name, $3.name, $$.name, &vec_quadr, true);
    }
    | expression SUBTRACT expression {
        $$.node = ast_new($2.name, $1.node, $3.node, AST_SUBTRACT);
        sprintf($$.name, "t%d", temp_var++);
        quadr_gencode(QUAD_TYPE_BINARY_ASSIGN, QUAD_OP_SUB, $1.name, $3.name, $$.name, &vec_quadr, true);
    }
    | expression MULTIPLY expression {
        $$.node = ast_new($2.name, $1.node, $3.node, AST_MULTIPLY);
        sprintf($$.name, "t%d", temp_var++);
        $$.is_temperorary = true;
        quadr_gencode(QUAD_TYPE_BINARY_ASSIGN, QUAD_OP_MUL, $1.name, $3.name, $$.name, &vec_quadr, true);
    }
    | expression DIVIDE expression {
        $$.node = ast_new($2.name, $1.node, $3.node, AST_DIVIDE);
        sprintf($$.name, "t%d", temp_var++);
        $$.is_temperorary = true;
        quadr_gencode(QUAD_TYPE_BINARY_ASSIGN, QUAD_OP_DIV, $1.name, $3.name, $$.name, &vec_quadr, true);
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
    if(is_for)
    {
        sprintf(if_block, "L%d", labels++);
        quadr_gencode(QUAD_TYPE_LABEL, 0, NULL, NULL, if_block,  &vec_quadr, false);
        char tmp[1024] = {0};
        sprintf(tmp, "L%d", labels);
        quadr_gencode(QUAD_TYPE_IF_NOT, op, arg1, arg2, tmp,  &vec_quadr, false);
        sprintf(else_block, "L%d", labels++);
    }
    else
    {
        char tmp[1024] = {0};
        sprintf(tmp, "L%d", labels);
        quadr_gencode(QUAD_TYPE_IF, op, arg1, arg2, tmp,  &vec_quadr, false);
        sprintf(tmp, "L%d\n", labels+1);
        quadr_gencode(QUAD_TYPE_GOTO, 0, NULL, NULL, tmp,  &vec_quadr, false);
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