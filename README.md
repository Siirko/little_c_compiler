# Little C(MAT)/Mips compiler

Compiler made for university project.

## Why C(MAT) ?
Because normaly it should have matrix type but didn't had the time to implement it.

## Compilation

```bash
make
```

Executable is present in `bin` folder with the name of `cmat`.

The executable offers the option -h to display the help:

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


## Compile a .c file

```bash
$ ./bin/cmat -f fichier.c -o fichier.asm
``` 
If no errors are detected, the compiler will generate an .asm file containing the MIPS code. 
If an error occurs, the compiler will display an error message and stop. For example, with the file. `tests/errors/out_of_scopes1.c` :

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
## Execute the .asm file

```bash
java -jar Mars.jar me sm nc fichier.asm
```
- me = redirige la sortie d'erreurs vers la sortie standard
- sm = commence l'execution du programme à l'étiquette main
- nc = pas de notice de copyright 

## Table of symboles
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
