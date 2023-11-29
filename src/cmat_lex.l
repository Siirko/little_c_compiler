%{
    #include "cmat_yacc.h"
    int counter = 1;
%}

%option yylineno

alpha [a-zA-Z]
digit [0-9]
unary "++"|"--"

%%

"printf"                    { return PRINTFF; }
"int"                       { return INT; }
"float"                     { return FLOAT; }

"return"                    { return RETURN; }
"for"	                    { return FOR; }
"if"	                    { return IF; }
"else"	                    { return ELSE; }

[-]?{digit}+                { return NUMBER; }
[-]?{digit}+\.{digit}{1,6}  { return FLOAT_NUM; }
{alpha}({alpha}|{digit})*   { return ID; }
{unary}                     { return UNARY; }

"<="                        { return LE; }
">="                        { return GE; }
"=="                        { return EQ; }
"!="                        { return NE; }
">"	                    { return GT; }
"<"	                    { return LT; }
"+"                         { return ADD; }
"-"                         { return SUBTRACT; }
"/"                         { return DIVIDE; }
"*"                         { return MULTIPLY; }

\/\/.*                      { ; }
\/\*(.*\n)*.*\*\/           { ; } 
[ \t]*                      { ; }
[\n]                        { counter++; }
.	                    { return *yytext; }
["].*["]                    { return STR; }


%%

int yywrap() {
    return 1;
}