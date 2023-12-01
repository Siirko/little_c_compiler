%{
    #include "cmat_yacc.h"
    int counter = 1;
%}

%option yylineno

alpha [a-zA-Z]
digit [0-9]
unary "++"|"--"

%%

"printf"                    { strncpy(yylval.node_t.name, yytext, 1024); return PRINTFF; }
"int"                       { strncpy(yylval.node_t.name, yytext, 1024); return INT; }
"float"                     { strncpy(yylval.node_t.name, yytext, 1024); return FLOAT; }

"return"                    { strncpy(yylval.node_t.name, yytext, 1024); return RETURN; }
"for"	                    { strncpy(yylval.node_t.name, yytext, 1024); return FOR; }
"if"	                    { strncpy(yylval.node_t.name, yytext, 1024); return IF; }
"else"	                    { strncpy(yylval.node_t.name, yytext, 1024); return ELSE; }

[-]?{digit}+                { strncpy(yylval.node_t.name, yytext, 1024); return NUMBER; }
[-]?{digit}+\.{digit}{1,6}  { strncpy(yylval.node_t.name, yytext, 1024); return FLOAT_NUM; }
{alpha}({alpha}|{digit})*   { strncpy(yylval.node_t.name, yytext, 1024); return ID; }
{unary}                     { strncpy(yylval.node_t.name, yytext, 1024); return UNARY; }

"<="                        { strncpy(yylval.node_t.name, yytext, 1024); return LE; }
">="                        { strncpy(yylval.node_t.name, yytext, 1024); return GE; }
"=="                        { strncpy(yylval.node_t.name, yytext, 1024); return EQ; }
"!="                        { strncpy(yylval.node_t.name, yytext, 1024); return NE; }
">"	                    { strncpy(yylval.node_t.name, yytext, 1024); return GT; }
"<"	                    { strncpy(yylval.node_t.name, yytext, 1024); return LT; }
"+"                         { strncpy(yylval.node_t.name, yytext, 1024); return ADD; }
"-"                         { strncpy(yylval.node_t.name, yytext, 1024); return SUBTRACT; }
"/"                         { strncpy(yylval.node_t.name, yytext, 1024); return DIVIDE; }
"*"                         { strncpy(yylval.node_t.name, yytext, 1024); return MULTIPLY; }

\/\/.*                      { ; }
\/\*(.*\n)*.*\*\/           { ; } 
[ \t]*                      { ; }
[\n]                        { counter++; }
.	                    { return *yytext; }
["].*["]                    { strncpy(yylval.node_t.name, yytext, 1024); return STR; }


%%

int yywrap() {
    return 1;
}