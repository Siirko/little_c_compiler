%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <ctype.h>
    #include "../include/ast.h"
    #include "../include/hashmap.h"
    #include "../include/symbol.h"
    
    void yyerror(const char *s);
    int yylex();
    int yywrap();
    extern char* yytext;
    extern int yylineno;

    void check_variable_declaration(char* token);

    ast_t *head;
    hashmap_t* symbol_table;
    enum data_type data_type;
    extern int counter;
    int error_count = 0;
%}

%union {
    struct node {
        char name[1024];
        struct ast* node;
    } node_t;
}

%token <node_t>  PRINTFF INT FLOAT FOR IF ELSE NUMBER FLOAT_NUM ID LE GE EQ NE GT LT STR ADD MULTIPLY DIVIDE SUBTRACT UNARY RETURN 
%type <node_t> printf_statement main body return datatype expression statement init value relop program condition else body_element for_statement if_statement

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
    } '(' statement ';' condition ';' statement ')' '{' body '}' {
        ast_t *tmp = ast_new("CONDITION", $6.node, $8.node, AST_CONDITION);
        ast_t *tmp2 = ast_new("CONDITION", $4.node, tmp, AST_CONDITION);
        $$.node = ast_new($1.name, tmp2, $11.node, AST_FOR);
    }

if_statement: IF { 
        add_symbol(symbol_table, TYPE_KEYWORD, &data_type, yytext, counter); 
    } '(' condition ')' '{' body '}' else {
        ast_t *tmp = ast_new($1.name, $4.node, $7.node, AST_IF);
        $$.node = ast_new("if-else", tmp, $9.node, AST_IF_ELSE);
    }

else: ELSE { 
        add_symbol(symbol_table, TYPE_KEYWORD, &data_type, yytext, counter); 
    } '{' body '}' {
        $$.node = ast_new($1.name, NULL, $4.node, AST_ELSE);
    }
    | { $$.node = NULL; }
    ;


statement: datatype ID { 
        add_symbol(symbol_table, TYPE_VARIABLE, &data_type, yytext, counter); 
    } init {
        $2.node = ast_new($2.name, NULL, NULL, AST_ID);
        $$.node = ast_new("declaration", $2.node, $4.node, AST_DECLARATION);
    }
    | ID { check_variable_declaration($1.name); } '=' expression {
        $1.node = ast_new($1.name, NULL, NULL, AST_ID);
        $$.node = ast_new("=", $1.node, $4.node, AST_ASSIGNATION);
    }
    | ID { check_variable_declaration($1.name); } relop expression {
        $1.node = ast_new($1.name, NULL, NULL, AST_ID);
        $$.node = ast_new($3.name, $1.node, $4.node, AST_RELOP);
    }
    | ID { check_variable_declaration($1.name); } UNARY {
        $1.node = ast_new($1.name, NULL, NULL, AST_ID);
        $3.node = ast_new($3.name, NULL, NULL, AST_UNARY);
        $$.node = ast_new("ITERATOR", $1.node, $3.node, AST_ITERATOR);
    }
    | UNARY ID  {
        check_variable_declaration($2.name);
        $1.node = ast_new($1.name, NULL, NULL, AST_UNARY);
        $2.node = ast_new($2.name, NULL, NULL, AST_ID);
        $$.node = ast_new("ITERATOR", $1.node, $2.node, AST_ITERATOR);
    }
    ;

init: '=' expression {
        $$.node = $2.node;
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

condition: value relop value {
        $$.node = ast_new($2.name, $1.node, $3.node, AST_RELOP);
    }
    ;

relop: LT
    | GT
    | LE
    | GE
    | EQ
    | NE
    ;

expression: expression ADD expression {
        $$.node = ast_new($2.name, $1.node, $3.node, AST_ADD);
    }
    | expression SUBTRACT expression {
        $$.node = ast_new($2.name, $1.node, $3.node, AST_SUBTRACT);
    }
    | expression MULTIPLY expression {
        $$.node = ast_new($2.name, $1.node, $3.node, AST_MULTIPLY);
    }
    | expression DIVIDE expression {
        $$.node = ast_new($2.name, $1.node, $3.node, AST_DIVIDE);
    }
    | value { $$.node = $1.node; }
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
        // $1.node = ast_new("return", NULL, NULL, AST_RETURN);
        $$.node = ast_new("RETURN", NULL, $3.node, AST_RETURN);
    } 
    | { $$.node = NULL; }
    ;

%%

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