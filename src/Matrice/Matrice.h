#ifndef MATRICE_H
#define MATRICE_H
#include <stlib.h>
#include <stdio.h>

#include <stdnoreturn.h>
#include <errno.h>
#include <stdarg.h>
#define raler(MSG) RALER(MSG,"Error on line in file %s with %s", __LINE__,__FILE__,__FUNCTION__)

typedef struct Matrice{
	int n;
	int m;
	float **M;
	// M[n][m]
} Matrice;

typedef struct Intervalle{
	int n_debut;
	int n_fin;
	int m_debut;
	int m_fin;
} Intervalle;



Matrice *creerMatrice(int n, int m);
void detruireMatrice(Matrice *M);
void afficherMatrice(Matrice *M);
int redimensionnerMatrice(Matrice *M, int n, int m);

Matrice* LadditionnerMatrice(Matrice *A, Matrice *B, float coefA, float coefB);
Matrice* multdivMatrice(Matrice *A, Matrice *B,float coefA, float coefB,int mult);

#define multiplierMatrice(A,B) multdivMatrice(A,B,1,1,1)
#define diviserMatrice(A,B) multdivMatrice(A,B,1,1,0)
#define additionnerMatrice(A,B) LadditionnerMatrice(A,B,1,1)
#define soustraireMatrice(A,B) LadditionnerMatrice(A,B,1,-1)
#define CadditionnnerMatrice(a,A) LadditionnerMatrice(A,A,a,0)
#define CmultiplierMatrice(a,A) multdivMatrice(A,A,a,0,1)
#define CdivisererMatrice(a,A) multdivMatrice(A,A,1/a,0,0)


//suppose une chaine bien formée mais si ça va pas je gère quand même les erreurs
ll_list str_vers_LIntervalles(char *str);
static int extract_intervalle(char *str, Intervalle *I);


int TransposerMatrice(Matrice *M);

Matrice* extraireMatrice(Matrice *A, char *str);


#endif // MATRICE_H