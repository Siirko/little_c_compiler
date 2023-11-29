#ifndef TABLE_H
#define TABLE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <stdnoreturn.h>
#include <errno.h>
#include <stdarg.h>

#define raler(MSG) RALER(MSG,"Error on line in file %s with %s", __LINE__,__FILE__)

void RALER(const char *err_msg,const char *format, ...);

typedef struct Table {
	char **data;
	size_t allocated;
	size_t size;
} Table;


void table_initiate(Table *table);
void table_destroy(Table *table);
size_t table_add(Table *table, char *str);
//void table_remove(Table *table, size_t index);
//size_t table_search(Table *table, char *str);
void table_print(Table *table);



#endif // TABLE_H