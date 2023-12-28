#pragma once
#include "quadr.h"
#include <stdio.h>

/**
 * @brief Generate .data section
 */
void mips_data_section(hashmap_t *t_sym_tab, FILE *file);

/**
 * @brief Generate all MIPS code
 */
void mips_gen(hashmap_t *t_sym_tab, vec_quadr_t *vec_quadr, FILE *file);