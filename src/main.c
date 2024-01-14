#include "../include/args_parser.h"
#include "../include/hashmap.h"
#include "../include/mips.h"
#include "../include/quadr.h"
#include "../include/symbol.h"
#include "../include/utils.h"
#include "../include/yacc_struct.h"
#include <stdio.h>

extern int yyparse();
extern FILE *yyin;
// hashmap<string, vector<vector<hashmap<string, symbol_t>>>> t_sym_tab;
extern hashmap_t *t_sym_tab;
extern vec_int_t i_if_end;
extern vec_quadr_t vec_quadr;
extern hashmap_t *func_args;
extern vec_iterator_node_t vec_iterator_loops;
extern int error_count;

struct arguments arguments;

void cmat_init()
{
    t_sym_tab = hashmap_init(10);
    func_args = hashmap_init(10);
    vec_init(&vec_quadr);
    vec_init(&i_if_end);
    vec_init(&vec_iterator_loops);
}

void cmat_free(void)
{
    int i;
    quadr_t quad;
    vec_foreach(&vec_quadr, quad, i)
    {
        if (quad.arg1.val != NULL)
        {
            free(quad.arg1.val);
            free(quad.arg1.scope.function_name);
        }
        if (quad.arg2.val != NULL)
        {
            free(quad.arg2.val);
            free(quad.arg2.scope.function_name);
        }
        if (quad.res.val != NULL)
        {
            free(quad.res.val);
            free(quad.res.scope.function_name);
        }
    }

    vec_deinit(&i_if_end);
    vec_deinit(&vec_quadr);
    vec_deinit(&vec_iterator_loops);

    hashmap_iterate(func_args, free_func_args);
    hashmap_iterate(t_sym_tab, free_scopes);
    hashmap_free(t_sym_tab);
    free(t_sym_tab);
}

void initiate_args(int argc, char *argv[])
{
    arguments.cmat_file = "";
    arguments.show_symbol_table = false;
    arguments.show_intermediate_code = false;
    arguments.output_file = "stdout";
    argp_parse(&argp, argc, argv, 0, 0, &arguments);
    if (!strcmp(arguments.cmat_file, ""))
    {
        printf("No file specified\n");
        exit(1);
    }
}

void check_function_errors()
{
    // detect if there is a main function
    if (hashmap_get(t_sym_tab, "main") == NULL)
    {
        fprintf(stderr, ANSI_BOLD ANSI_COLOR_RED "No main function found\n" ANSI_RESET);
        exit(1);
    }
    // // check if main function has no arguments
    // printf("%d\n", get_function_total_args("main", func_args));
    // if (get_function_total_args("main", func_args) > 0)
    // {
    //     fprintf(stderr, ANSI_BOLD ANSI_COLOR_RED "Main function must have no arguments\n" ANSI_RESET);
    //     return 1;
    // }
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
    if (error_count > 0)
    {
        fprintf(stderr, ANSI_BOLD ANSI_COLOR_RED "Compilation failed with %d errors\n" ANSI_RESET,
                error_count);
        return 1;
    }
    check_function_errors();
    if (arguments.show_intermediate_code)
    {
        int i;
        quadr_t quad;
        vec_foreach(&vec_quadr, quad, i) { print_quad(quad); }
    }
    bool is_stdout = !strcmp(arguments.output_file, "stdout");
    FILE *output_file = is_stdout ? stdout : fopen(arguments.output_file, "w");
    mips_gen(t_sym_tab, &vec_quadr, output_file);
    if (!is_stdout)
        fclose(output_file);
    cmat_free();
    return 0;
}
