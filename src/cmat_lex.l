%{
    #include "cmat_yacc.h"
    void yyerror(const char *s);
    int counter = 1;
    char linebuf[1024];
    int column = 1;

    #define YY_USER_ACTION  do { \
        yylloc.first_line = counter; \
        yylloc.last_line = counter; \
        \
        yylloc.first_column = column; \
        column += yyleng; \
        yylloc.last_column = column; \
    } while (0);

%}

%option yylineno
%option nounput
%option noinput

alpha [a-zA-Z]
alphawith_ [a-zA-Z_]
digit [0-9]
unary "++"|"--"

%%

"printf"                    { strncpy(yylval.node_t.name, yytext, 1024); return PRINTF; }
"print"                    { strncpy(yylval.node_t.name, yytext, 1024); return PRINT; }
"int"                       { strncpy(yylval.node_t.name, yytext, 1024); return INT; }
"float"                     { strncpy(yylval.node_t.name, yytext, 1024); return FLOAT; }

"const"                     { strncpy(yylval.node_t.name, yytext, 1024); return CONST; }

"return"                    { strncpy(yylval.node_t.name, yytext, 1024); return RETURN; }
"for"	                    { strncpy(yylval.node_t.name, yytext, 1024); return FOR; }
"while"	                    { strncpy(yylval.node_t.name, yytext, 1024); return WHILE; }
"if"	                    { strncpy(yylval.node_t.name, yytext, 1024); return IF; }
"else"	                    { strncpy(yylval.node_t.name, yytext, 1024); return ELSE; }

[-]?{digit}+                { strncpy(yylval.node_t.name, yytext, 1024); return NUMBER; }
[-]?{digit}+\.{digit}{1,6}  { strncpy(yylval.node_t.name, yytext, 1024); return FLOAT_NUM; }
{alpha}({alphawith_}|{digit})*   { strncpy(yylval.node_t.name, yytext, 1024); return ID; }
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
[\n]                        { ; }
\n.* { 
    counter++; column = 1;
    strncpy(linebuf, yytext+1, sizeof(linebuf)); /* save the next line */
    yyless(1); /* give back all but the \n to rescan */
}
.	                    { return *yytext; }
["]([^"]|\\(.|\n))*["]                     { strncpy(yylval.node_t.name, yytext, 1024); return STR; }



%%

int yywrap() {
    return 1;
}