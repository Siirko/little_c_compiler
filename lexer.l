%option nounput
%option noyywrap

%%

%{
/* Les unités lexicales simples */
/* sortie -> code correspondant */


%}

%{/* KEY WORDS */%}

    %{/* Types */%}

(void) {return TYPE_VOID;}
(int) {return TYPE_INT;}
(float) {return TYPE_FLOAT;}
(matrix) {return TYPE_MATRIX;}

    %{/* Controls */%}

(if) { return IF;}
(else) { return ELSE;}
(for) { return FOR;}
(while) { return WHILE;}
(return) { return RETURN;}
(main) { return MAIN;}


%{/* NON ALPHA */%}

    %{// Comparateurs %}

== {return IS_EQUAL;}
!= {return IS_NOT_EQUAL;}
<= {return IS_LESS_OR_EQUAL;}
>= {return IS_GREATER_OR_EQUAL;}
&& {return AND;}
|| {return OR;}
< {return IS_LESS;}
> {return IS_GREATER;}
! {return NOT;}

    %{// Opérateurs %}

++ {return INCREMENT;}
-- {return DECREMENT;}
~ {return TRANSPOSE;}
+ {return ADD;}
- {return SUB;}
* {return MUL;}
/ {return DIV;}
= {return EQUAL;}

    %{// Ponctuation %}

\[ {return OPEN_BRACKET;}
\] {return CLOSE_BRACKET;}
\( {return OPEN_PARENTHESIS;}
\) {return CLOSE_PARENTHESIS;}
\{ {return OPEN_BRACE;}
\} {return CLOSE_BRACE;}
\: {return COLON;}
\, {return SEP;}
\; {return END;}
%{ //\" {return QUOTE;}%}

    %{// Autres %}

%{
/* Les valeurs constantes */
%}

((([a-z]|[A-Z])+([0-9]|_)*)+) {yyval.string =return IDENT;} 
(0|[1-9][0-9]*) { yyval.integer = return INT;}
[-+]?([0-9]*[.])?[0-9]+([eE][-+]?\d+)? {yyval.real = return FLOAT;}
(\"[[:X:]]*\")  { yyval.string = yytext; return STRING; }
[ \t\n] { /* ignore */ }

. {fprintf(stderr,"Erreur : "%s" non reconnu\n",yytext); return -1;} {/* Affiche -1-> erreur pas reconnu */}

%%

int main(int argc, char** argv){
    FILE *f = stdin;
    if(argc==2)
        f = fopen(argv[1], "r");
    if(!f)
        return -1;

    table_initiate(&t);

    yyin = f;   
    yylex();
    
    fclose(f);
    //fprintf(stdout,"%d\n",nbWord);

    printf("\nTable des symboles : \n");
    for(int i=0;i<t.size;i++){
        if(t.data[i]!=NULL)
            printf("\t %s %d\n",t.data[i],i);
    }

    table_destroy(&t);
    
    return 0;
}