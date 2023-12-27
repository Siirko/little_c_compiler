#include "../include/args_parser.h"
#include "../include/ast.h"
#include "../include/hashmap.h"
#include "../include/quadr.h"
#include "../include/symbol.h"
#include <stdio.h>

extern int yyparse();
extern FILE *yyin;
extern hashmap_t *t_sym_tab;
extern ast_t *head;
extern vec_int_t i_if_end;
extern vec_quadr_t vec_quadr;

struct arguments arguments;

void cmat_init()
{
    t_sym_tab = hashmap_init(10);
    vec_init(&vec_quadr);
    vec_init(&i_if_end);
}

void cmat_free(void)
{
    ast_free(head);

    int i;
    quadr_t quad;
    vec_foreach(&vec_quadr, quad, i)
    {
        free(quad.arg1);
        free(quad.arg2);
        free(quad.res);
    }
    vec_deinit(&i_if_end);
    vec_deinit(&vec_quadr);

    hashmap_iterate(t_sym_tab, free_scopes);
    hashmap_free(t_sym_tab);
    free(t_sym_tab);
}

void initiate_args(int argc, char *argv[])
{
    arguments.cmat_file = "";
    arguments.show_abstract_syntax_tree = false;
    arguments.show_symbol_table = false;
    arguments.show_intermediate_code = false;
    argp_parse(&argp, argc, argv, 0, 0, &arguments);
    if (!strcmp(arguments.cmat_file, ""))
    {
        printf("No file specified\n");
        exit(1);
    }
}

int main(int argc, char *argv[])
{

    initiate_args(argc, argv);
    yyin = fopen(arguments.cmat_file, "r");
    if (yyin == NULL)
    {
        printf("Error opening file %s\n", arguments.cmat_file);
        return 1;
    }

    cmat_init();
    yyparse();
    fclose(yyin);

    if (arguments.show_symbol_table)
        show_symbol_table(t_sym_tab);
    if (arguments.show_abstract_syntax_tree)
        ast_show(head);
    if (arguments.show_intermediate_code)
    {
        int i;
        quadr_t quad;
        vec_foreach(&vec_quadr, quad, i) { print_quad(quad); }
    }

    cmat_free();
    return 0;
}
