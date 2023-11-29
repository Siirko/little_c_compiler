#include "Matrice.h"

noreturn void RALER(const char *err_msg,const char *format, ...){
	va_list args;
	va_start(args, format);
	vfprintf(stderr, format, args);
	va_end(args);
	perror(err_msg);
	exit(EXIT_FAILURE);
}
#define raler(MSG) RALER(MSG,"Error on line in file %s with %s", __LINE__,__FILE__,__FUNCTION__)

Matrice *creerMatrice(int n, int m){
	Matrice *M = malloc(sizeof(Matrice));
	if(M == NULL){
		raler("malloc objet matrice");
	}
	
	M->M = malloc(sizeof(float)*n*m);
	perror("malloc matrice n*m");
	M->n = M->M == NULL ? 0 : n;
	M->m = M->M == NULL ? 0 : m;

	return M;
}

void detruireMatrice(Matrice *M){
	if(M != NULL){
		free(M->M);
		//free(M);
	}
}

void afficherMatrice(Matrice *M){
	for(int i = 0; i < M->n; i++){
		for(int j = 0; j < M->m; j++){
			printf("%d ", M->M[i][j]);
		}
		printf("\n");
	}
}

int redimensionnerMatrice(Matrice *M, int n, int m){
	float **RM= realloc(M->M, sizeof(float)*n*m);
	if(M->M == NULL){
		perror("realloc matrice");
		return -1;
	}
	M->n = n;
	M->m = m;
	return 0;
}

Matrice* LadditionnerMatrice(Matrice *A, Matrice *B,float coefA, float coefB){
	int ex= A == NULL || B == NULL;
	ex |= A->M == NULL || B->M == NULL;
	ex |= A->n != B->n || A->m != B->m;
	if(ex){
		perror("additionnerMatrice");
		return NULL;
	}

	Matrice *C = creerMatrice(A->n, A->m);
	if(C == NULL){
		perror("creerMatrice");
		return NULL;
	}

	for(int i = 0; i < A->n; i++){
		for(int j = 0; j < A->m; j++){
			C->M[i][j] = coefA*A->M[i][j] + coefB*B->M[i][j];
		}
	}

	return C;
}



Matrice* multdivMatrice(Matrice *A, Matrice *B,float coefA, float coefB,int mult){
	int ex= A == NULL || B == NULL;
	ex |= A->M == NULL || B->M == NULL;
	ex |= A->m != B->n || ( coefB == 0 && mult == 0);


	if(ex){
		perror("multdivMatrice");
		return NULL;
	}
	Matrice *C = creerMatrice(A->n, B->m);

	if(C == NULL){
		perror("creerMatrice");
		return NULL;
	}

	for(int i=0;i<A->n;i++){
		for(int j=0;j<B->m;j++){
			C->M[i][j]=0;
			for(int k=0;k<A->m;k++){
				C->M[i][j]+= mult==0 ? coefA*A->M[i][k]/coefB->M[k][j] : coefA*A->M[i][k]*coefB*B->M[k][j] ;
			}
		}
	}

	return C;

}

void TransposerMatrice(Matrice *M){

	Matrice *T = creeMatrice(M->m,M->n);
	if(T == NULL){
		perror("creerMatrice");
		return -1;
	}

	for(int i=0;i<M->n;i++){
		for(int j=0;j<M->m;j++){
			T->M[j][i]=M->M[i][j];
		}
	}

	return 0;

}

/*
typedef struct Intervalle{
	int n_debut;
	int n_fin;
	int m_debut;
	int m_fin;
} Intervalle;
*/


ll_list str_vers_LIntervalles(char *str){}


static int extract_intervalle(char *str, Intervalle *I){
	if(str == NULL || I == NULL){
		perror("extract_intervalle");
		return -1;
	}
	else if(strncmp(str,"[*]",4) == 0){
		return 0;
	}

	else{

		// La chaine de caractères à traiter.
		char str[] = "[2.5.3..6]";
		// La définitions de séparateurs connus.
		const char * separators = "[.]";
		char count = 0;

		// On récupére, un à un, tous les mots (token) de la phrase
		// et on commence par le premier.
		char * strToken = strtok ( str, separators );

		while ( strToken != NULL) {
			printf ( " \"%s\" ", strToken );
			// On demande le token suivant.
			strToken = strtok ( NULL, separators );

			if(count > 1)
				return -1;
			count++;
		}
		
}



Matrice* extraireMatrice(Matrice *A, char *str){
	int ex= A == NULL;
	ex |= A->M == NULL;
	ex |= A->n != B->n || A->m != B->m;
	if(ex){
		perror("extraireMatrice");
		return NULL;
	}

	Matrice *C = creerMatrice(I.n_fin-I.n_debut, I.m_fin-I.m_debut);
	if(C == NULL){
		perror("creerMatrice");
		return NULL;
	}

	for(int i = I.n_debut; i <= I.n_debut; i++){
		for(int j = I.m_debut; j <= I->m_fin; j++){
			C->M[i][j] = A->M[i][j];
		}
	}

	return C;
}



