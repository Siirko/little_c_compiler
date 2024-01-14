# CMat

Un compilateur pour le langage "CMat" (langage métier) réalisé dans le cadre du cours de *Compilation* à l'Université de Strasbourg. 

Ce projet a été réalisé par :
- Herlin Loïc
- Metzger Benjamin
- Brelot Julien 
- Yanovskyy Alexander


## Description

Ce projet est un compilateur pour le langage CMAT. On génère du code MIPS à partir d'un exécutable .cmat. 
Le compilateur est réalisé en C et en utilisant les langages Flex et Yacc pour générer des analyseurs lexicaux et syntaxiques. 

Les codes sources sont organisés dans les répertoires suivants :
- `src`: Contient les fichiers sources du compilateur en C et les fichiers .l et .y.
- `include`: Contient les fichiers d'en-tête du compilateur.
- `obj`: Stocke les fichiers objets générés lors de la compilation.
- `bin`: Contient l'exécutable du compilateur.
- `tests`: Contient les fichiers de tests pour le compilateur.

## Compilation

Pour compiler le projet, exécutez la commande suivante :

```bash
make
```
Pour nettoyer le projet, exécutez la commande suivante :

```bash
make clean
```
L'éxécutable est généré dans le répertoire `bin` sous le nom de `cmat`.

## Utilisation
L'exécutable propose l'option `-h` pour afficher l'aide :

```
$ ./bin/cmat --help                                     
Usage: cmat [OPTION...]
Little MIPS compiler for a subset of C language.

  -f, --cmat_file=CMAT_FILE
  -i, --interm_code          Show Intermediate code
  -o, --output_file=OUTPUT_FILE   MIPS Assembly file
  -s, --tos                  Show Symbol table
  -?, --help                 Give this help list
      --usage                Give a short usage message
  -V, --version              Print program version

Mandatory or optional arguments to long options are also mandatory or optional
for any corresponding short options.
```

Par conséquent il est possible de faire les commandes suivantes (vous pouvez utiliser les fichiers de tests dans le répertoire `tests`): 

## Compilation d'un fichier .c

```bash
$ ./bin/cmat -f fichier.c -o fichier.asm
``` 
Un fichier .asm sera générer si le compilateur ne détecte aucune erreur qui contient le code MIPS.

Si une erreur surviens, le compilateur affichera un message d'erreur et s'arrêtera. par exemple avec le fichier `tests/errors/out_of_scopes1.c` :

```bash
$ ./bin/cmat -f tests/errors/out_of_scopes1.c

ERROR: Variable not declared in line 4
    j = 0;
    ^
ERROR: Variable not declared in line 12
        j = 0;
        ^
ERROR: Variable not declared in line 14
    i = 0;
    ^
ERROR: Variable not declared in line 15
    j = 0;
    ^
Compilation failed with 4 errors
```
## Exécution du fichier .asm
Pour l'executer il faut utiliser le simulateur MARS fournis à la racine du projet (java doit être installé):

```bash
java -jar Mars.jar me sm nc fichier.asm
```
- me = redirige la sortie d'erreurs vers la sortie standard
- sm = commence l'execution du programme à l'étiquette main
- nc = pas de notice de copyright 

## Table des symboles
Il est possible d'afficher la table des symboles avec l'option `--tos` :

```
$ ./bin/cmat --tos -f tests/functions/add.c -o /dev/null
Table of Symbols for: add
ID                  TYPE                DATA_TYPE           LINE                

Scope 0
+-------------------------------------------------------------+
a                   variable            int                 1                   
add                 function            int                 1                   
b                   variable            int                 1                   
return              keyword             NaD                 1                   
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Table of Symbols for: main
ID                  TYPE                DATA_TYPE           LINE                

Scope 0
+-------------------------------------------------------------+
printf              keyword             NaD                 12                  
a                   variable            int                 5                   
b                   variable            int                 6                   
c                   variable            int                 7                   
d                   variable            float               8                   
return              keyword             NaD                 14                  
main                function            int                 3                   
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Table of Symbols for: addf
ID                  TYPE                DATA_TYPE           LINE                

Scope 0
+-------------------------------------------------------------+
a                   variable            float               2                   
b                   variable            float               2                   
return              keyword             NaD                 2                   
addf                function            float               2                   
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

```
