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

    ast_t *head;
    hashmap_t* symbol_table;
    enum data_type data_type;
    extern int counter;
%}

%union {
    struct node {
        char name[1024];
        struct ast* node;
    } node_t;
}

%token <node_t>  PRINTFF INT FLOAT FOR IF ELSE NUMBER FLOAT_NUM ID LE GE EQ NE GT LT STR ADD MULTIPLY DIVIDE SUBTRACT UNARY RETURN 
%type <node_t> printf_statement operation main body return datatype expression statement init value relop program condition else body_element for_statement if_statement

%%

program: main '(' ')' '{' body return '}' {
        $1.node = ast_new("main", $5.node, $6.node);
        $$.node = ast_new("program", NULL, $1.node);
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
    | body body_element { $$.node = ast_new("statements", $1.node, $2.node); }
    ;


body_element: for_statement
    | if_statement
    | statement ';' { $$.node = $1.node; }
    | printf_statement
    ;

for_statement: FOR { 
        add_symbol(symbol_table, TYPE_KEYWORD, &data_type, yytext, counter); 
    } '(' statement ';' condition ';' statement ')' '{' body '}' {
        ast_t *tmp = ast_new("CONDITION", $6.node, $8.node);
        ast_t *tmp2 = ast_new("CONDITION", $4.node, tmp);
        $$.node = ast_new($1.name, tmp2, $11.node);
    }

if_statement: IF { 
        add_symbol(symbol_table, TYPE_KEYWORD, &data_type, yytext, counter); 
    } '(' condition ')' '{' body '}' else {
        ast_t *tmp = ast_new($1.name, $4.node, $7.node);
        $$.node = ast_new("if-else", tmp, $9.node);
    }

else: ELSE { 
        add_symbol(symbol_table, TYPE_KEYWORD, &data_type, yytext, counter); 
    } '{' body '}' {
        $$.node = ast_new($1.name, NULL, $4.node);
    }
    | { $$.node = NULL; }
    ;


statement: datatype ID { 
        add_symbol(symbol_table, TYPE_VARIABLE, &data_type, yytext, counter); 
    } init {
        $2.node = ast_new($2.name, NULL, NULL);
        $$.node = ast_new("declaration", $2.node, $4.node);
    }
    | ID '=' expression {
        $1.node = ast_new($1.name, NULL, NULL);
        $$.node = ast_new("=", $1.node, $3.node);
    }
    | ID relop expression {
        $1.node = ast_new($1.name, NULL, NULL);
        $$.node = ast_new($2.name, $1.node, $3.node);
    }
    | ID UNARY {
        $1.node = ast_new($1.name, NULL, NULL);
        $2.node = ast_new($2.name, NULL, NULL);
        $$.node = ast_new("ITERATOR", $1.node, $2.node);
    }
    | UNARY ID {
        $1.node = ast_new($1.name, NULL, NULL);
        $2.node = ast_new($2.name, NULL, NULL);
        $$.node = ast_new("ITERATOR", $1.node, $2.node);
    }
    ;

init: '=' value {
        $$.node = $2.node;
    }
    | ',' ID { // can't do float a = 1.2, b = 2.3; ... yet
        add_symbol(symbol_table, TYPE_VARIABLE, &data_type, yytext, counter); 
    } init {
        $2.node = ast_new($2.name, NULL, NULL);
        $$.node = ast_new("declaration", $2.node, $4.node);
    }
    | { $$.node = ast_new("NULL", NULL, NULL); }
    ;

printf_statement: PRINTFF { add_symbol(symbol_table, TYPE_KEYWORD, &data_type, yytext, counter); } '(' STR ')' ';'
    { 
        $$.node = ast_new("printf",NULL, NULL);
    }
    ;

condition: value relop value {
        $$.node = ast_new($2.name, $1.node, $3.node);
    }
    ;

expression: expression operation expression {
        $$.node = ast_new($2.name, $1.node, $3.node);
    }
    | value { $$.node = $1.node; }
    ;

operation: ADD
    | MULTIPLY
    | DIVIDE
    | SUBTRACT
    ;

relop: LT
    | GT
    | LE
    | GE
    | EQ
    | NE
    ;

value: NUMBER { 
        add_symbol(symbol_table, TYPE_CONST, &data_type, yytext, counter); 
        $$.node = ast_new($1.name, NULL, NULL);
    }
    | FLOAT_NUM { 
        add_symbol(symbol_table, TYPE_CONST, &data_type, yytext, counter); 
        $$.node = ast_new($1.name, NULL, NULL);
    }
    | ID { $$.node = ast_new($1.name, NULL, NULL); }
    ;

return: RETURN { 
        add_symbol(symbol_table,TYPE_KEYWORD, &data_type, yytext, counter); 
    } expression ';' {
        $1.node = ast_new("return", NULL, NULL);
        $$.node = ast_new("RETURN", $1.node, $3.node);
    } 
    | { $$.node = NULL; }
    ;

%%

void yyerror(const char* msg) {
    fprintf(stderr, "%s\n", msg);
}