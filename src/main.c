#include "../include/ast.h"
#include "../include/hashmap.h"
#include "../include/quadr.h"
#include "../include/symbol.h"
#include "../include/vector.h"
#include <stdio.h>

extern int yyparse();
extern FILE *yyin;
extern hashmap_t *symbol_table;
extern ast_t *head;
extern quadr_t *list_quadruples;

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

    list_quadruples = vector_init(quadr_t, 100); // will be rezised internally if needed

    symbol_table = hashmap_init(10); // will be rezised internally if needed
    yyparse();
    fclose(yyin);

    show_symbol_table(symbol_table);
    ast_show(head);

    for (size_t i = 0; i < vector_size(list_quadruples); i++)
        print_quad(list_quadruples[i]);

    hashmap_free(symbol_table);
    free(symbol_table);

    ast_free(head);
    for (size_t i = 0; i < vector_size(list_quadruples); i++)
    {
        free(list_quadruples[i].arg1);
        free(list_quadruples[i].arg2);
        free(list_quadruples[i].res);
    }
    vector_free(list_quadruples);
    return 0;
}
