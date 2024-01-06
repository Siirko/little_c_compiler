#ifndef MATRICE_H
#define MATRICE_H
#include <stdlib.h>
#include <stdio.h>

#include <stdnoreturn.h>
#include <errno.h>
#include <stdarg.h>


typedef struct matrix_t{
	float *M;
	int n;
	int m;
	// M[n][m]
}matrix_t;

#define matrix_element(A,i,j) A->M[]


// int *** functions return 0 if success, -1 if error

void printmat(matrix_t *A);

void unit_matrix(matrix_t *A);
void zero_matrix(matrix_t *A);

int transpose_matrix(matrix_t *T,matrix_t *A);

int add_matrix(matrix_t *R,matrix_t *A, matrix_t *B,float a, float b);

#define sub_matrix(R,A,B,a,b) add_matrix(R,A,B,a,-b)

int mult_matrix(matrix_t *R,matrix_t *A, matrix_t *B,float a, float b);
int div_matrix(matrix_t *R,matrix_t *A, matrix_t *B,float a, float b);

void mult_scal_matrix(matrix_t *A, float scal);
int div_scal_matrix(matrix_t *A, float scal);


#endif // MATRICE_H