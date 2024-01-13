#pragma once
#include "vec.h"

typedef struct YYLTYPE
{
    int first_line;
    int first_column;
    int last_line;
    int last_column;
} YYLTYPE;

// had to place that here, no other idea for a cleaner way ( ͡° ͜ʖ ͡°)
typedef struct iterator_node
{
    struct node *n1;
    struct node *n3;
    YYLTYPE t1;
    YYLTYPE t3;
} iterator_node_t;
typedef vec_t(struct iterator_node) vec_iterator_node_t;