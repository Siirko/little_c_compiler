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

#define matrix_element(A,i,j) A->M[i*A->m+j]

// int *** functions return 0 if success, -1 if error

void printmat(float *A, int n, int m);

/*
void unit_matrix(float *A, int n, int m);
void zero_matrix(float *A, int n, int m);
*/

void transpose_matrix(float *T,float *A,int n,int m);

void add_matrix(float *R,float *A, float *B,int n, int m);
void sub_matrix(float *R,float *A, float *B,int n, int m);

void mult_matrix(float* R,float *A, float *B,int n,int m,int p);
void div_matrix(float* R,float *A, float *B,int n,int m,int p);

void mult_scal_matrix(float *A,int n,int m, float scal);
void div_scal_matrix(float *A,int n,int m, float scal);

#endif // MATRICE_H