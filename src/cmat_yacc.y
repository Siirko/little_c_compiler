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

    ast_t *head;
    hashmap_t* symbol_table;
    quadr_t* list_quadruples;
    enum data_type data_type;
    bool is_for = false;
    bool in_if_condition = false;
    extern int counter;
    int error_count = 0;
    int temp_var = 0;
    int labels = 0;
    int if_counter = 0;
%}


%union {
    struct node {
        char name[1024];
        struct ast* node;
    } node_t;

    struct relop_node {
        char name[1024];
        int type;
        struct ast* node;
    } relop_node_t;

    struct cond_node {
        char if_block[1024];
        char else_block[1024];
        struct ast* node;
    } cond_node_t;
}

%token <node_t>  PRINTFF INT FLOAT FOR IF ELSE NUMBER FLOAT_NUM ID LE GE EQ NE GT LT STR ADD MULTIPLY DIVIDE SUBTRACT UNARY RETURN 
%type <node_t> iterator printf_statement main body return datatype expression statement init value program else body_element for_statement if_statement
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
        add_symbol(symbol_table, TYPE_FUNCTION, &data_type, yytext, counter); 
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

for_statement: FOR { 
        add_symbol(symbol_table, TYPE_KEYWORD, &data_type, yytext, counter); 
        is_for = true;
    } '(' statement ';' condition ';' iterator ')' '{' body '}' {
        ast_t *tmp = ast_new("CONDITION", $6.node, $8.node, AST_CONDITION);
        ast_t *tmp2 = ast_new("CONDITION", $4.node, tmp, AST_CONDITION);
        $$.node = ast_new($1.name, tmp2, $11.node, AST_FOR);
        quadr_gencode(QUAD_TYPE_GOTO, 0, NULL, NULL, $6.if_block, list_quadruples);
        quadr_gencode(QUAD_TYPE_LABEL, 0, NULL, NULL, $6.else_block, list_quadruples);
    }

if_statement: IF { 
        add_symbol(symbol_table, TYPE_KEYWORD, &data_type, yytext, counter); 
        is_for = false;
        in_if_condition = true;
        ++if_counter;
    } '(' condition ')' {
        quadr_gencode(QUAD_TYPE_LABEL, 0, NULL, NULL, $4.if_block, list_quadruples);
    }'{' body '}' {
        char tmp2[1024] = {0};
        sprintf(tmp2, "L%d", labels);
        quadr_gencode(QUAD_TYPE_GOTO, 0, NULL, NULL, tmp2, list_quadruples);
        quadr_gencode(QUAD_TYPE_LABEL, 0, NULL, NULL, $4.else_block, list_quadruples);
    }
    else {
        ast_t *tmp = ast_new($1.name, $4.node, $8.node, AST_IF);
        $$.node = ast_new("if-else", tmp, $11.node, AST_IF_ELSE);
    }

else: ELSE { 
        add_symbol(symbol_table, TYPE_KEYWORD, &data_type, yytext, counter); 
    } '{' body '}' {
        $$.node = ast_new($1.name, NULL, $4.node, AST_ELSE);
        --if_counter;
        if(in_if_condition && if_counter == 0)
        {
            char tmp2[1024] = {0};
            sprintf(tmp2, "L%d", labels);
            quadr_gencode(QUAD_TYPE_LABEL, 0, NULL, NULL, tmp2, list_quadruples);
            in_if_condition = false;
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
        quadr_gencode(QUAD_TYPE_BINARY_ASSIGN, QUAD_OP_ADD, $1.name, "1", tmp, list_quadruples);
        sprintf(tmp, "t%d", temp_var++);
        quadr_gencode(QUAD_TYPE_COPY, 0, tmp, NULL, $1.name, list_quadruples);
    }

statement: datatype ID { 
        add_symbol(symbol_table, TYPE_VARIABLE, &data_type, yytext, counter); 
    } init {
        $2.node = ast_new($2.name, NULL, NULL, AST_ID);
        $$.node = ast_new("declaration", $2.node, $4.node, AST_DECLARATION);
    }
    | ID { check_variable_declaration($1.name); } '=' expression {
        $1.node = ast_new($1.name, NULL, NULL, AST_ID);
        $$.node = ast_new("=", $1.node, $4.node, AST_ASSIGNATION);
        quadr_gencode(QUAD_TYPE_COPY, 0, $4.name, NULL, $1.name, list_quadruples);
    }
    ;

init: '=' expression {
        $$.node = $2.node;
        quadr_gencode(QUAD_TYPE_COPY, 0, $2.name, NULL, $$.name, list_quadruples);
    }
    | ',' ID { // can't do float a = 1.2, b = 2.3; ... yet
        add_symbol(symbol_table, TYPE_VARIABLE, &data_type, yytext, counter); 
    } init {
        $2.node = ast_new($2.name, NULL, NULL, AST_ID);
        $$.node = ast_new("declaration", $2.node, $4.node, AST_DECLARATION);
    }
    | { $$.node = ast_new("NULL", NULL, NULL, AST_NULL); }
    ;

printf_statement: PRINTFF { add_symbol(symbol_table, TYPE_KEYWORD, &data_type, yytext, counter); } '(' STR ')' ';'
    { 
        $$.node = ast_new("printf", NULL, NULL, AST_LIB_FUNCTION);
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
        quadr_gencode(QUAD_TYPE_BINARY_ASSIGN, QUAD_OP_ADD, $1.name, $3.name, $$.name, list_quadruples);
    }
    | expression SUBTRACT expression {
        $$.node = ast_new($2.name, $1.node, $3.node, AST_SUBTRACT);
        sprintf($$.name, "t%d", temp_var++);
        quadr_gencode(QUAD_TYPE_BINARY_ASSIGN, QUAD_OP_SUB, $1.name, $3.name, $$.name, list_quadruples);
    }
    | expression MULTIPLY expression {
        $$.node = ast_new($2.name, $1.node, $3.node, AST_MULTIPLY);
        sprintf($$.name, "t%d", temp_var++);
        quadr_gencode(QUAD_TYPE_BINARY_ASSIGN, QUAD_OP_MUL, $1.name, $3.name, $$.name, list_quadruples);
    }
    | expression DIVIDE expression {
        $$.node = ast_new($2.name, $1.node, $3.node, AST_DIVIDE);
        sprintf($$.name, "t%d", temp_var++);
        quadr_gencode(QUAD_TYPE_BINARY_ASSIGN, QUAD_OP_DIV, $1.name, $3.name, $$.name, list_quadruples);
    }
    | value { 
        $$.node = $1.node; 
    }
    ;



value: NUMBER { 
        add_symbol(symbol_table, TYPE_CONST, &data_type, yytext, counter); 
        $$.node = ast_new($1.name, NULL, NULL, AST_INTEGER);
    }
    | FLOAT_NUM { 
        add_symbol(symbol_table, TYPE_CONST, &data_type, yytext, counter); 
        $$.node = ast_new($1.name, NULL, NULL, AST_FLOAT);
    }
    | ID { 
        check_variable_declaration($1.name);
        $$.node = ast_new($1.name, NULL, NULL, AST_ID);
     }
    ;

return: RETURN { 
        add_symbol(symbol_table,TYPE_KEYWORD, &data_type, yytext, counter); 
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
        quadr_gencode(QUAD_TYPE_LABEL, 0, NULL, NULL, if_block, list_quadruples);
        char tmp[1024] = {0};
        sprintf(tmp, "L%d", labels);
        quadr_gencode(QUAD_TYPE_IF_NOT, op, arg1, arg2, tmp, list_quadruples);
        sprintf(else_block, "L%d", labels++);
    }
    else
    {
        char tmp[1024] = {0};
        sprintf(tmp, "L%d", labels);
        quadr_gencode(QUAD_TYPE_IF, op, arg1, arg2, tmp, list_quadruples);
        sprintf(tmp, "L%d\n", labels+1);
        quadr_gencode(QUAD_TYPE_GOTO, 0, NULL, NULL, tmp, list_quadruples);
        sprintf(if_block, "L%d", labels++);
        sprintf(else_block, "L%d", labels++);
    }
}

void check_variable_declaration(char* token) {
    if(hashmap_get(symbol_table, token) == NULL)
    {
        fprintf(stderr, "Variable %s is not declared at line %d\n", token, counter);
        error_count++;
    }
}

void yyerror(const char* msg) {
  fprintf(stderr, "%s: '%s' in line %d\n", msg, yytext, yylineno);
}