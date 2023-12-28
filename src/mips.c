#include "../include/mips.h"
#include "../include/hashmap.h"

void mips_data_section(hashmap_t *t_sym_tab, FILE *file)
{
    fprintf(file, ".data\n");
    // hashmap<string, vector<vector<hashmap<string, symbol_t>>>> t_sym_tab;

    // we focus only on "main" function, but in the future it will be changed
    vec_vec_hashmap_t *v_scopes = (vec_vec_hashmap_t *)hashmap_get(t_sym_tab, "main");
    vec_hashmap_t *tmp;
    for (int i = 0; i < v_scopes->length; i++)
    {
        tmp = &v_scopes->data[i];
        if (tmp->length == 0)
            continue;
        int j;
        hashmap_t *tmp2;
        vec_foreach(tmp, tmp2, j)
        {
            // clean empty hashmaps
            if (tmp2->count == 0)
            {
                hashmap_free(tmp2);
                free(tmp2);
                vec_splice(tmp, j, 1);
                continue;
            }
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

void mips_gen(hashmap_t *t_sym_tab, vec_quadr_t *vec_quadr, FILE *file)
{
    mips_data_section(t_sym_tab, file);
    fprintf(file, ".text\n");
    fprintf(file, "main:\n");
    int i;
    quadr_t quadr;
    vec_foreach(vec_quadr, quadr, i)
    {
        //
    }
}