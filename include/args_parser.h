#pragma once
#include <argp.h>
#include <stdbool.h>
#include <stdlib.h>

const char *argp_program_version = "Alexander Yanovskyy\nBenjamin Metzger\nJulien Brelot\nLoïc Herlin";

/* Program documentation. */
static char doc[] = "Little compiler for a subset of C language.\n";

/* The options we understand. */
static struct argp_option options[] = {{"cmat_file", 'f', "CMAT_FILE", 0, "", 0},
                                       {"tos", 's', 0, 0, "Show Symbol table", 0},
                                       {"interm_code", 'i', 0, 0, "Show Intermediate code", 0},
                                       {"ast", 'a', 0, 0, "Show Abstract Syntax tree", 0},
                                       {0}};

/* Used by main to communicate with parse_opt. */
typedef struct arguments
{
    // char *args[2];                /* arg1 & arg2 */
    char *cmat_file;
    bool show_symbol_table;
    bool show_intermediate_code;
    bool show_abstract_syntax_tree;
} arguments_t;

/* Parse a single option. */
static error_t parse_opt(int key, char *arg, struct argp_state *state)
{
    /* Get the input argument from argp_parse, which we
       know is a pointer to our arguments structure. */
    arguments_t *arguments = state->input;
    switch (key)
    {
    case ARGP_KEY_END:
        // weird
        if (state->argc != 5)
        {
            // ARGP_HELP_BUG_ADDR
            // argp_usage(state);
        }
        break;
    case 's':
        arguments->show_symbol_table = true;
        break;
    case 'i':
        arguments->show_intermediate_code = true;
        break;
    case 'a':
        arguments->show_abstract_syntax_tree = true;
        break;
    case 'f':
        arguments->cmat_file = arg;
        break;
    default:
        return ARGP_ERR_UNKNOWN;
    }

    return 0;
}

static struct argp argp = {options, parse_opt, NULL, doc, NULL, NULL, NULL};
