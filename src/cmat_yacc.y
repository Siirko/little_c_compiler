%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <ctype.h>
    #include "../include/hashmap.h"
    #include "../include/symbol.h"
    
    void yyerror(const char *s);
    int yylex();
    int yywrap();
    extern char* yytext;

    hashmap_t* symbol_table;
    enum data_type data_type;
    extern int counter;
%}

%token PRINTFF
%token IF ELSE RETURN
%token INT FLOAT 
%token FOR 
%token NUMBER FLOAT_NUM
%token LE GE EQ NE GT LT
%token ADD MULTIPLY DIVIDE SUBTRACT

%left ADD SUBTRACT MULTIPLY DIVIDE

%token ID STR UNARY

%%

program: main '(' ')' '{' body return '}'
    ;


main: datatype ID { 
        add_symbol(symbol_table, TYPE_FUNCTION, &data_type, yytext, &counter); 
    }
    ;

datatype: INT { data_type = TYPE_INT; }
    | FLOAT { data_type = TYPE_FLOAT; }
    ;


body: body_element
    | body body_element
    ;


body_element: for_statement
    | if_statement
    | statement ';'
    | printf_statement
    ;

for_statement: FOR { 
        add_symbol(symbol_table, TYPE_KEYWORD, &data_type, yytext, &counter); 
    } '(' statement ';' condition ';' statement ')' '{' body '}'

if_statement: IF { 
        add_symbol(symbol_table, TYPE_KEYWORD, &data_type, yytext, &counter); 
    } '(' condition ')' '{' body '}' else

else: ELSE { 
        add_symbol(symbol_table, TYPE_KEYWORD, &data_type, yytext, &counter); 
    } '{' body '}'
    |
    ;


statement: datatype ID { 
        add_symbol(symbol_table, TYPE_VARIABLE, &data_type, yytext, &counter); 
    } init
    | ID '=' expression 
    | ID relop expression
    | ID UNARY 
    | UNARY ID
    ;

init: '=' value
    |
    ;

printf_statement: PRINTFF { add_symbol(symbol_table, TYPE_KEYWORD, &data_type, yytext, &counter); } '(' STR ')' ';';

condition: value relop value 
    ;


expression: expression ADD expression
    | expression SUBTRACT expression
    | expression MULTIPLY expression
    | expression DIVIDE expression
    | value
    ;

relop: LT
    | GT
    | LE
    | GE
    | EQ
    | NE
    ;

value: NUMBER { add_symbol(symbol_table, TYPE_CONST, &data_type, yytext, &counter); }
    | FLOAT_NUM { add_symbol(symbol_table, TYPE_CONST, &data_type, yytext, &counter); }
    | ID
    ;

return: RETURN { add_symbol(symbol_table,TYPE_KEYWORD, &data_type, yytext, &counter); } value ';' 
    |
    ;

%%

void yyerror(const char* msg) {
    fprintf(stderr, "%s\n", msg);
}