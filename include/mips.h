#pragma once
#include "quadr.h"
#include <stdio.h>

/**
 * @brief Generate .data section
 */
void mips_data_section(hashmap_t *t_sym_tab, FILE *file);