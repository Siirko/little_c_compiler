#include "../include/args_parser.h"
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
// extern vec_vec_hashmap_t v_scopes;
extern hashmap_t *t_sym_tab;

struct arguments arguments;

void cmat_init()
{
    symbol_table = hashmap_init(10); // will be rezised internally if needed
    vec_init(&vec_quadr);
    vec_init(&i_if_end);
}

void cmat_free(void)
{
    hashmap_free(symbol_table);
    free(symbol_table);

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
    t_sym_tab = hashmap_init(10);
    // vec_push(&v_scopes, (vec_hashmap_t){0});
    // vec_push(&v_scopes.data[0], hashmap_init(10));
    // int value = 42;
    // hashmap_insert(v_scopes.data[0].data[0], "test", &value, sizeof(int));
    // printf("%d\n", *(int *)hashmap_get(v_scopes.data[0].data[0], "test"));

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

    vec_vec_hashmap_t v_scopes = *(vec_vec_hashmap_t *)hashmap_get(t_sym_tab, "main");
    int i;
    vec_hashmap_t tmp;
    vec_foreach(&v_scopes, tmp, i)
    {
        printf("Scope %d\n", i);
        printf("---------\n");
        int j;
        hashmap_t *tmp2;
        vec_foreach(&tmp, tmp2, j)
        {
            hashmap_iterate(tmp2, show_symbol);
            printf("\n");
        }
    }

    if (arguments.show_symbol_table)
        show_symbol_table(symbol_table);
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
