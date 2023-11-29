#ifndef LINKED_LIST_H
#define LINKED_LIST_H

#include <stdio.h>
#include <stdlib.h>


typedef struct ll_node {
    int value;
    struct ll_node *next;
} ll_node;

typedef struct ll_list {
    struct ll_node *first;
    size_t size;
}ll_list;


/**
 * create a node with the given value
 * 
 */
ll_list * ll_create(void);

/** 
 * append an element to the list with the 
 * given value
 */
void ll_append(ll_list *list, int value);
/** 
 * prepend an element to the list with the 
 * given value
 */
void ll_prepend(ll_list *list, int value);


/** 
 * return the value at index i from the list. 
 * The behavior is undefined if there are less
 * than i+1 elements in the list.
 */
int ll_get(const ll_list *list, unsigned int i);

/** 
 * return 1 if the function succeed
 * 0 if there is an error
 */
int ll_get_safe(const ll_list *list, unsigned int i, int *value);


/** free the list
 */
void ll_free(ll_list *list);


/** return the first value
 */
int ll_first(ll_list *list);

/** return the last value
 */
int ll_last(ll_list *list);

/**
 * return  the size of the list
 */
size_t ll_size(ll_list*list);

/**
 * remove the last element
 */
void ll_pop_last(ll_list*list);
/**
 * remove the first element
 */
void ll_pop_first(ll_list*list);

/**
 * insert an element `value` in the list at index `idx`
 */
void ll_insert(ll_list*list, int value, int idx);

/**
 * remove the element at index `idx`
 */
void ll_remove(ll_list*list, int idx);

#endif // LINKED_LIST_H