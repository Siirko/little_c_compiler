#include "../include/ast.h"
#include "../include/hashmap.h"
#include "../include/quadr.h"
#include "../include/symbol.h"
#include <stdio.h>

extern int yyparse();
extern FILE *yyin;
extern hashmap_t *symbol_table;
extern ast_t *head;
extern vec_int_t i_if_end;
extern vec_quadr_t vec_quadr;

int main(int argc, char const *argv[])
{
    if (argc > 1)
    {
        yyin = fopen(argv[1], "r");
        if (yyin == NULL)
        {
            printf("Error opening file %s\n", argv[1]);
            return 1;
        }
    }

    vec_init(&vec_quadr);
    vec_init(&i_if_end);
    symbol_table = hashmap_init(10); // will be rezised internally if needed
    yyparse();
    fclose(yyin);

    show_symbol_table(symbol_table);
    // ast_show(head);

    int i;
    quadr_t quad;
    vec_foreach(&vec_quadr, quad, i) { print_quad(quad); }

    hashmap_free(symbol_table);
    free(symbol_table);

    ast_free(head);
    vec_foreach(&vec_quadr, quad, i)
    {
        free(quad.arg1);
        free(quad.arg2);
        free(quad.res);
    }

    vec_deinit(&i_if_end);
    vec_deinit(&vec_quadr);
    return 0;
}
