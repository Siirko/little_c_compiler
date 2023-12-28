#include "../include/mips.h"
#include "../include/hashmap.h"

void mips_data_section(hashmap_t *t_sym_tab, FILE *file)
{
    fprintf(file, ".data\n");
    // hashmap<string, vector<vector<hashmap<string, symbol_t>>>> t_sym_tab;

    // we focus only on "main" function, but in the future it will be changed
    vec_vec_hashmap_t *v_scopes = (vec_vec_hashmap_t *)hashmap_get(t_sym_tab, "main");
    int i;
    vec_hashmap_t tmp;
    vec_foreach(v_scopes, tmp, i)
    {
        if (tmp.length == 0)
            continue;
        int j;
        hashmap_t *tmp2;
        vec_foreach(&tmp, tmp2, j)
        {
            if (tmp2->count == 0)
                continue;
            hashmap_iter_t iter = {0};
            hashmap_iter_init(&iter, tmp2);
            do
            {
                if (!hashmap_iter_has_next(&iter))
                    continue;
                symbol_t *symbol = (symbol_t *)iter.node->value;
                if (symbol->type == TYPE_VARIABLE)
                    fprintf(file, "\t%s_%d_%d: .word 0\n", symbol->id, i, j);
            } while (hashmap_iter_next(&iter));
        }
    }
}