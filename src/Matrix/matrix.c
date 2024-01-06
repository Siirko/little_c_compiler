#include "matrix.h"


/*
typedef struct matrix_t{
	float *M;
	int n;
	int m;
	// M[n][m]
}matrix_t;
*/

void printmat(matrix_t *A){
	
	for(int i=0;i<A->n;i++){
		for(int j=0;j<A->m;j++)
			printf("%f\t",A->M[i*A->m+j]);
		printf("\n");
	}
	printf("\n");
}

void unit_matrix(matrix_t *A){

	for(int i=0;i<A->n;i++){
		for(int j=0;j<A->m;j++){
			A->M[i*A->m+j]= i==j ? 1 : 0;
		}
	}

}

void zero_matrix(matrix_t *A){
	
	for(int i=0;i<A->n;i++){
		for(int j=0;j<A->m;j++)
			A->M[i*A->m+j]= 0;
	}

}

int transpose_matrix(matrix_t *T,matrix_t *A){
	
	if(T->n != A->m || T->m != A->n) return -1;

	for(int i=0;i<T->n;i++){
		for(int j=0;j<T->m;j++)
			T->M[i*T->m+j]= A->M[j*A->m+i];
	}

	return 0;
}

int add_matrix(matrix_t *R,matrix_t *A, matrix_t *B,float a, float b){
	
	if(R->n != A->n || R->n != B->n || R->m != A->m || R->m != B->m) return -1;

	for(int i=0;i<R->n;i++){
		for(int j=0;j<R->m;j++)
			R->M[i*R->m+j]= a*A->M[i*A->m+j]+b*B->M[i*B->m+j];
	}

	return 0;
}

// multiplication de matrices
// avec la formule 
// (AB)_{ij} = \sum_{k=1}^n A_{ik}B_{kj} 
int mult_matrix(matrix_t *R,matrix_t *A, matrix_t *B,float a, float b){
	
	if(R->n != A->n || R->m != B->m ||  A->m != B->n) return -1;

	for(int i=0;i<R->n;i++){
		for(int j=0;j<R->m;j++){
			R->M[i*R->m+j]= 0;
			for(int k=0;k<A->m;k++)
				R->M[i*R->m+j]+= a*A->M[i*A->m+k]*b*B->M[k*B->m+j];
		}
	}

	return 0;
}

int div_matrix(matrix_t *R,matrix_t *A, matrix_t *B,float a, float b){
	
	if(R->n != A->n || R->m != B->m ||  A->m != B->n) return -1;

	for(int i=0;i<R->n;i++){
		for(int j=0;j<R->m;j++){
			R->M[i*R->m+j]= 0;
			for(int k=0;k<A->m;k++)
				R->M[i*R->m+j]+= a*A->M[i*A->m+k]/(b*B->M[k*B->m+j]);
		}
	}

	return 0;
}

void mult_scal_matrix(matrix_t *A, float scal){
	
	for(int i=0;i<A->n;i++){
		for(int j=0;j<A->m;j++)
			A->M[i*A->m+j]*=scal;
	}
}

int div_scal_matrix(matrix_t *A, float scal){
	
	if(scal==0) return -1;

	for(int i=0;i<A->n;i++){
		for(int j=0;j<A->m;j++)
			A->M[i*A->m+j]/=scal;
	}

	return 0;
}