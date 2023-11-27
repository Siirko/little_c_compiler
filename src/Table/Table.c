#include "Table.h"

void RALER(const char *err_msg,const char *format, ...){
	va_list args;
	va_start(args, format);
	vfprintf(stderr, format, args);
	va_end(args);
	perror(err_msg);
	exit(EXIT_FAILURE);
}

/* Functions to implement:
void table_initiate(Table *table);
void table_destroy(Table *table);
void table_add(Table *table, char *str);
void table_remove(Table *table, size_t index);
static void table_percolate_up(Table *table, size_t index);
size_t table_search(Table *table, char *str);
*/

/* Structure Table definition:
typedef struct Table {
	char **data;
	size_t allocated;
	size_t size;
} Table;
*/


void table_initiate(Table *table){
	table->size = 0;
	table->data = calloc(100,sizeof(char*));
	table->allocated = table->data == NULL ? 100 : 0;
}

void table_destroy(Table *table){
	for(size_t i = 0; i < table->size; i++){
		free(table->data[i]);
	}
	free(table->data);
}

static int expand(Table *table){
	
	if(table->size == table->allocated){
		// try to allocate 100 more
		table->allocated += 100;
		char **tmp = realloc(table->data, sizeof(char*)*(table->allocated+100));
		if(tmp == NULL){
			// else try to allocate 10 more
			table->allocated -= 90;
			tmp = realloc(table->data, sizeof(char*)*(table->allocated));

			if(tmp == NULL){
				// finally, try to allocate 1 more
				table->allocated -= 9;
				tmp = realloc(table->data, sizeof(char*)*(table->allocated));
				if(tmp == NULL){
					table->allocated -= 1;
					return -1; //abort 
				}
			}
			
		}

		table->data = tmp;
	}

	return 0;
}
/*
static void shift(Table *table, size_t index){
	
	char *tmp = NULL;
	for(size_t i = table->size-1; i > index; i--){
		tmp = table->data[i];
		table->data[i] = table->data[i-1];
		table->data[i-1] = tmp;
	}

}
*/

size_t table_add(Table *table, char *str){
	// extend the table if necessary

	if(expand(table) == -1){ raler("Alloc element"); return -1;}
	
	size_t n = strlen(str);
	
	//allocate memory for the string
	table->data[table->size] = malloc(sizeof(char)*(n+1));
	if(table->data[table->size] == NULL){raler("Alloc string"); return -1;}
	strncpy(table->data[table->size],str,n+1);
	table->size++;

	int cmp = 0;
	for(size_t i = 0; i<table->size-1; i++){

		cmp = strncmp(table->data[i], str, strlen(table->data[i])+1);
		//printf("cmp %s et %s \n", table->data[i], str);

		if(cmp == 0){
			//fprintf(stderr, "Error: %s already in table\n", str);
			free(table->data[table->size-1]);
			table->size--;
			return i;
		}
	}
	return table->size-1;
}

/*void table_remove(Table *table, size_t index){
	if(index >= table->size){
		return;
	}

	free(table->data[index]);
	table->data[index] = table->data[table->size-1];
	table->size--;
}
*/

void table_print(Table *table){
	printf("Table size: %zu\n", table->size);
	for(size_t i = 0; i < table->size; i++){
		printf("\t %s\n", table->data[i]);
	}
}

//search for a string in a binary data
/*size_t table_search(Table *table, char *str){
	size_t index = 0;
	while(index < table->size){
		if(strcmp(table->data[index], str) == 0){
			return index;
		}
		index++;
	}
	return -1;
}*/