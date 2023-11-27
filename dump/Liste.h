#infdef LISTE_H
#define LISTE_H

#include <stlib.h>


typedef struct List{
	struct List *suivant;
	void *data;
}List;



List* creerList();
void detruireList(List *L);

int appendList(List *L, void *data);
int popList(List *L, void* cpy);
void* getList(List *L, size_t index);

#endif // LISTE_H