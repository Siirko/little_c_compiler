#include "Liste.h"

/*
typedef struct List{
	struct List *suivant;
	void *data;
}List;


List* creerList();
void detruireList(List *L);


int appendList(List *L, void *data);
int popList(List *L, void* cpy);
void* getList(List *L, size_t index);

*/

List* creeList(){
	List *L = malloc(sizeof(List));
	if(L == NULL){
		perror("malloc");
		return NULL;
	}
	L->suivant = NULL;
	L->data = NULL;
	return L;
}

void detruireList(List *L){
	if(L != NULL){
		free(L->data);
		detruireList(L->suivant);
	}
	free(L);
}



int appendList(List *L, void *data){
	if(L == NULL){
		perror("appendList");
		return -1;
	}

	if(L->data == NULL){
		L->data = data;
		return 0;
	}

	for(; L->suivant != NULL; L = L->suivant)

	L->suivant = malloc(sizeof(List));
	if(L->suivant == NULL){
		perror("malloc");
		return -1;
	}
	L->data = data;
	L->suivant-> = NULL;
	return 0;
}


int popList(List *L, void* cpy){
	if(L == NULL){
		perror("popList");
		return -1;
	}

	if(L->data == NULL) return 0;

	for(; L->suivant != NULL; L = L->suivant);

	memcpy(cpy, L->data, sizeof(void*));
	free(L->data);
	L->data = NULL;
	free(L->suivant);
	return 0;

}
void* getList(List *L, size_t index);
