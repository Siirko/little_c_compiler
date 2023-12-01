#include "../include/ast.h"
#include "../include/hashmap.h"
#include "../include/symbol.h"
#include <stdio.h>

extern int yyparse();
extern FILE *yyin;
extern hashmap_t *symbol_table;
extern ast_t *head;

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

    symbol_table = hashmap_init(10); // will be rezised internally if needed
    yyparse();
    fclose(yyin);

    show_symbol_table(symbol_table);
    ast_show(head);

    hashmap_free(symbol_table);
    free(symbol_table);

    ast_free(head);
    return 0;
}
