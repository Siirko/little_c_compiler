%define parse.error verbose
%{
#include <stdio.h>
#include <stdint.h>
#include "src/Table/Table.h"

#define YYDEBUG 0
extern int yydebug;

extern int yylex();
extern int yyparse();

void yyerror(const char *msg);printf


 Table T_id, T_func;
table_initiate(&T_id);
table_initiate(&T_func);

table_add(&T_func,"printf");
table_add(&T_func,"printmat");

%}

%union {
	int integer;
	float real;
	char *string;
}

%type <entier> liste_elements  ensemble operateur2 operateur1 operande expression

//%right AFFECTATION
//%left UNION INTER DIFF COMP


/* Types */
%token TYPE_INT TYPE_FLOAT TYPE_MATRIX

/* Mots clés */
%token IF ELSE FOR WHILE RETURN MAIN

/* Comparaisons */
%token IS_EQUAL
%token IS_NOT_EQUAL
%token IS_LESS_OR_EQUAL
%token IS_GREATER_OR_EQUAL
%token AND
%token OR
%token IS_LESS
%token IS_GREATER
%token NOT

/* Operations */
%token INCREMENT
%token DECREMENT
%token TRANSPOSE
%token ADD
%token SUB
%token MUL
%token DIV
%token EQUAL

/* Ponctuation */
%token OPEN_BRACKET
%token CLOSE_BRACKET
%token OPEN_PARENTHESIS
%token CLOSE_PARENTHESIS
%token OPEN_BRACE
%token CLOSE_BRACE
%token COLON
%token SEP
%token END
%token QUOTE

/* Les valeurs constantes */


%token<integer> INT
%token<real>    FLOAT
%token<string>  IDENT
%token<string>  STRING



%start code

%%


/* 
  Structure d'un fichier code 

  // Déclarations de variables globales (optionnel)

  // Déclarations de fonctions (optionnel)

  // Fonction Main



*/


/* Déclarations */

declarations : %empty
              | function code
              | variable code

code : declarations main;


type : 
     | TYPE_VOID
     | TYPE_INT 
     | TYPE_FLOAT 
     | TYPE_MATRIX 
     ;

function_args : %empty
              | type IDENT { }
              | type IDENT SEP function_args { }
              ;

function : type IDENT OPEN_PARENTHESIS function_args CLOSE_PARENTHESIS OPEN_BRACE instructions_list CLOSE_BRACE { }
         ;


return : RETURN expression { }
       | RETURN { }
       ;

main : TYPE_VOID MAIN OPEN_PARENTHESIS CLOSE_PARENTHESIS OPEN_BRACE instructions_list CLOSE_BRACE { }
     | TYPE_INT MAIN OPEN_PARENTHESIS CLOSE_PARENTHESIS OPEN_BRACE instructions_list CLOSE_BRACE { }

variable : type IDENT { }
         | type IDENT AFFECTATION IDENT { }
         | type IDENT AFFECTATION constant_expression { }
         | TYPE_MATRIX IDENT matrix { }
         ;

constant_expression : INT { }
                    | FLOAT { }
                    | STRING { }
                    | matrix { }
                    ;

element_tab :  OPEN_BRACKET INT CLOSE_BRACKET;

matrix : element_tab description_matrix { }
       ;

description_matrix : %empty {}
                   | AFFECTATION OPEN_BRACKET liste_elements CLOSE_BRACKET { }
                   | AFFECTATION OPEN_BRACKET OPEN_BRACKET liste_elements CLOSE_BRACKET SEP OPEN_BRACKET liste_elements CLOSE_BRACKET CLOSE_BRACKET { }
                   ;


liste_elements : INT { }
                | FLOAT { }
                | INT SEP liste_elements { }
                | FLOAT SEP liste_elements { }
                ;


/* Instructions */

instructions_list : %empty
                  | instruction instructions_list { }
                  ;
                  



%%

void yyerror(const char *s) {
    fprintf(stdin,"(BISON) error : \"%s\"\n", s);
}

int main(void){
    yyparse();
    return 0;
}