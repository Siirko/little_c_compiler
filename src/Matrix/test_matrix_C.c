#include "matrix.h"
#include <time.h>

noreturn void RALER(const char *err_msg,const char *format, ...){
	va_list args;
	va_start(args, format);
	vfprintf(stderr, format, args);
	va_end(args);
	if(errno!=0)
		perror(err_msg);
	else
		fprintf(stderr, "%s\n", err_msg);
	
	fflush(stderr);
	
	exit(EXIT_FAILURE);
}
#define raler(MSG) RALER(MSG,"Error on line %d in file %s with %s", __LINE__,__FILE__,__FUNCTION__)



/*
typedef struct matrix_t{
	float *M;
	int n;
	int m;
	// M[n][m]
}matrix_t;

void printmat(matrix_t *A);

void unit_matrix(Matrix *A);
void zero_matrix(Matrix *A);

void transpose_matrix(Matrix *T,Matrix *A);

void add_matrix(Matrix *R,Matrix *A, Matrix *B,float a, float b);

#define sub_matrix(R,A,B,a,b) add_matrix(R,A,B,a,-b)

void mult_matrix(Matrix *R,Matrix *A, Matrix *B,float a, float b);
void div_matrix(Matrix *R,Matrix *A, Matrix *B,float a, float b);

void mult_scal_matrix(Matrix *A, float scal);
void div_scal_matrix(Matrix *A, float scal);

*/


void ran_fill_matrix(matrix_t *A){
	//A->M[i*A->m+j]= (float)rand()%100 +1;
	int n=1;
	for(int i=0;i<A->n;i++){
		for(int j=0;j<A->m;j++)
			A->M[i*A->m+j]= n++;
	}

}

int main(void){

	// initialisation du generateur de nombres aleatoires
	srand(time(NULL));

	
	// considerons 5 matrices

	matrix_t A,B,C,D;

	// A est une matrice 3x3
	A.n=3;
	A.m=3;
	A.M=malloc(A.n*A.m*sizeof(float));
	// B est une matrice 3x3
	B.n=3;
	B.m=3;
	B.M=malloc(B.n*B.m*sizeof(float));

	// C est une matrice 6x5
	C.n=6;
	C.m=5;
	C.M=malloc(C.n*C.m*sizeof(float));

	// D est une matrice 5x6
	D.n=5;
	D.m=4;
	D.M=malloc(D.n*D.m*sizeof(float));


	// remplissage aleatoire des matrices
	ran_fill_matrix(&A);
	ran_fill_matrix(&B);
	ran_fill_matrix(&C);
	ran_fill_matrix(&D);

	// affichage des matrices

	printf("A=\n");
	printmat(&A);

	printf("B=\n");
	printmat(&B);

	printf("C=\n");
	printmat(&C);

	printf("D=\n");
	printmat(&D);

	fflush(stdout);


	// Test des operations sur les matrices

	// addition de matrices
	matrix_t R;
	R.n=A.n;
	R.m=B.m;
	R.M=malloc(R.n*R.m*sizeof(float));

	// addition de matrices
	add_matrix(&R,&A,&B,3,2);
	printf("3A+2B=\n");
	printmat(&R);

	// soustraction de matrices
	sub_matrix(&R,&A,&B,1,3);
	printf("A-3B=\n");
	printmat(&R);

	// multiplication de matrices
	mult_matrix(&R,&A,&B,1,1);
	printf("A*B=\n");
	printmat(&R);

	// multiplication par un scalaire
	mult_scal_matrix(&A,3.14);
	printf("3.14*A=\n");
	printmat(&A);

	// division par un scalaire
	div_scal_matrix(&A,3.14);
	printf("A/3.14=\n");
	printmat(&A);

	// multiplication par une matrice
	mult_matrix(&R,&A,&B,1,1);
	printf("A*B=\n");
	printmat(&R);

	// division par une matrice
	div_matrix(&R,&A,&B,1,1);
	printf("A/B=\n");
	printmat(&R);

	// transposition
	transpose_matrix(&R,&A);
	printf("A^T=\n");
	printmat(&R);

	fflush(stdout);

	// test multiplication entre matrices de tailles differentes

	// multiplication de matrices

	// reallocation de R
	R.M = realloc(R.M,(C.m)*(D.n)*(sizeof(float)));
	R.n=C.n;
	R.m=D.m;

	mult_matrix(&R,&C,&D,2,3);
	printf("2C*D=\n");
	printmat(&R);

	fflush(stdout);

	// division de matrices

	div_matrix(&R,&C,&D,2,3);
	printf("C/D=\n");
	printmat(&R);

	fflush(stdout);

	// transposition de C 
	// reallocation de R
	printf("Go to transpose\n");
	fflush(stdout);

	R.M = realloc(R.M,(C.m)*(C.n)*(sizeof(float)));
	R.n=C.m;
	R.m=C.n;
	printf("last realloc ok\n");
	fflush(stdout);

	transpose_matrix(&R,&C);
	printf("C^T=\n");
	printmat(&R);

	// liberation de la memoire

	free(A.M);
	free(B.M);
	free(C.M);
	free(D.M);
	free(R.M);

	return 0;
}
