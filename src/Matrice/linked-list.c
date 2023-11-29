#include "linked-list.h"




ll_list * ll_create(void) {
    ll_list * list = malloc(sizeof(ll_list));
    if(list==NULL)
        return NULL;
    list->first = NULL;
    list->size = 0;
    return list;
}

void ll_append(ll_list *list, int value) {
    ll_node * new_element = malloc(sizeof(ll_node));
    if(new_element == NULL) {
        fprintf(stderr, "Allocation error in ll_append\n");
        exit(1);
    }
    new_element->next = NULL;
    new_element->value = value;

    if(list->first == NULL) {
        list->first = new_element;
        list->size++;
        return;
    }

    ll_node *it = list->first;
    while(it->next != NULL) {
        it = it->next;
    }
    it->next = new_element;
    list->size++;
}

int ll_get(const ll_list *list, unsigned int value_idx) {
    if(list ==NULL)
        return -1;
    ll_node *it = list->first;

    for(unsigned int i = 0; i < value_idx; i++) {
        it = it->next;
    }
    return it->value;
}

void free_node(ll_node *n){
    if(n!=NULL){
        free_node(n->next);
    }
    free(n);
}

void ll_free(ll_list *list) {
    if(list==NULL)
        return;
    free_node(list->first);
    free(list);
}

size_t ll_size(ll_list *l){
    if(l==NULL)
        return 0; 
    return l->size;
}

void ll_prepend(ll_list *list, int value){
    if(list==NULL)
        return;

    ll_node *n = (ll_node*) malloc(sizeof(ll_node));
    n->value = value;
    n->next = list->first;
    
    list->first = n;
    list->size++;

}


int ll_first(ll_list *l){
    if(l==NULL)
        return -1;
    else if( l->first ==NULL)
        return -1;
    else return l->first->value;
}

int ll_last(ll_list *l){
    if(l==NULL)
        return -1;
    else if( l->first ==NULL)
        return -1;
    else{
        ll_node *n= l->first;
        int v=n->value;
        while (n!=NULL)
        {
            v=n->value;
            n = n->next;
            
        }
        return v;
    }
}

void ll_pop_last(ll_list *l){
    if(l==NULL)
        return ;
    else if( l->first == NULL)
        return;
    else if(l->first->next == NULL){
        free(l->first);
        l->first = NULL;
        l->size--;
    }

    else{
        ll_node *n= l->first;
        ll_node *previous= l->first;
        while (n->next!=NULL)
        {
            previous = n;
            n=n->next;
            
        }
        free(n);
        previous->next =NULL;
        l->size--;
    }
}

void ll_pop_first(ll_list *l){
    if(l==NULL)
        return ;
    else if( l->first == NULL)
        return;
    else{
        ll_node *n= l->first->next;
        free(l->first);
        l->first = n;
        l->size--;
    }
}


void ll_insert(ll_list *l, int value, int idx){
    if(idx==0)
        ll_prepend(l,value);
    else if(l==NULL)
        return;
    else if( idx<0 || idx> l->size)
        return;

    ll_node *n = l->first; 
    for(int i=1;i<idx;i++){
        n = n->next;
    }
    ll_node *t = n->next;
    ll_node *new = (ll_node *) malloc(sizeof(ll_node));

    if(new == NULL)
        return;
    new->value = value;
    new->next = t;
    n->next = new;
    l->size++;
        
}

/**
 * remove the element at index `idx`
 */
void ll_remove(ll_list *l, int idx){
    if(idx==0)
        ll_pop_first(l);
    if(l==NULL)
        return;
    else if(idx<0 || idx> l->size)
        return;
    
    ll_node *n = l->first;
    ll_node *previous= l->first;

    for (int i=0;i<idx;i++)
    {
        previous = n;
        n=n->next;
        
    }
    
    previous->next =n->next;
    free(n);

    l->size--;
}
