.macro	print_float(%x)
li $v0, 2
mov.s $f12, %x
syscall
.end_macro

.macro print_int (%%x)
li $v0, 1
add $a0, $zero, %%x
syscall
.end_macro

.macro print_str(%%str)
.data
str: .asciiz %%str
.text
li $v0, 4
la $a0, str
syscall
.end_macro

.macro exit(%%x)
li $v0, 17
add $a0, $zero, %%x
syscall
.end_macro

# Macros opérations matricielles

.macro	print_mat(%x,%y,%z)
la $t0, %x
lw $t1, %y
lw $t2, %z

subi $sp $sp,12
sw $t0, 0($sp)
sw $t1, 4($sp)
sw $t2, 8($sp)
jal printmat

.end_macro

.macro	transpose_mat(%M1,%M2,%n,%m)

la $t0, %M1
la $t1, %M2
lw $t2, %n
lw $t3, %m

subi $sp, $sp, 16        # Allouer de l'espace pour 3 mots (12 octets) sur la pile
sw $t0, 0($sp)           # Sauvegarde de $t0 à l'adresse actuelle du pointeur de pile
sw $t1, 4($sp)           # Sauvegarde de $t1 à l'adresse actuelle + 4 octets
sw $t2, 8($sp)           # Sauvegarde de $t2 à l'adresse actuelle + 8 octets
sw $t3, 12($sp)          # Sauvegarde de $t3 à l'adresse actuelle + 12 octets

jal transpose_matrix

.end_macro

.macro	add_mat(%M1,%M2,%M3,%n,%m)

la $t0, %M1
la $t1, %M2
la $t2, %M3
lw $t3, %n
lw $t4, %m

subi $sp, $sp, 20        # Allouer de l'espace pour 3 mots (12 octets) sur la pile
sw $t0, 0($sp)           # Sauvegarde de $t0 à l'adresse actuelle du pointeur de pile
sw $t1, 4($sp)           # Sauvegarde de $t1 à l'adresse actuelle + 4 octets
sw $t2, 8($sp)           # Sauvegarde de $t2 à l'adresse actuelle + 8 octets
sw $t3, 12($sp)          # Sauvegarde de $t3 à l'adresse actuelle + 12 octets
sw $t4, 16($sp)          # Sauvegarde de $t4 à l'adresse actuelle + 16 octets

jal add_matrix

.end_macro

.macro	sub_mat(%M1,%M2,%M3,%n,%m)

la $t0, %M1
la $t1, %M2
la $t2, %M3
lw $t3, %n
lw $t4, %m

subi $sp, $sp, 20        # Allouer de l'espace pour 3 mots (12 octets) sur la pile
sw $t0, 0($sp)           # Sauvegarde de $t0 à l'adresse actuelle du pointeur de pile
sw $t1, 4($sp)           # Sauvegarde de $t1 à l'adresse actuelle + 4 octets
sw $t2, 8($sp)           # Sauvegarde de $t2 à l'adresse actuelle + 8 octets
sw $t3, 12($sp)          # Sauvegarde de $t3 à l'adresse actuelle + 12 octets
sw $t4, 16($sp)          # Sauvegarde de $t4 à l'adresse actuelle + 16 octets

jal sub_matrix

.end_macro

.macro	mult_mat(%M1,%M2,%M3,%n,%m,%p)

la $t0, %M1
la $t1, %M2
la $t2, %M3
lw $t3, %n
lw $t4, %m
lw $t5, %p

subi $sp, $sp, 24        # Allouer de l'espace pour 3 mots (12 octets) sur la pile
sw $t0, 0($sp)           # Sauvegarde de $t0 à l'adresse actuelle du pointeur de pile
sw $t1, 4($sp)           # Sauvegarde de $t1 à l'adresse actuelle + 4 octets
sw $t2, 8($sp)           # Sauvegarde de $t2 à l'adresse actuelle + 8 octets
sw $t3, 12($sp)          # Sauvegarde de $t3 à l'adresse actuelle + 12 octets
sw $t4, 16($sp)          # Sauvegarde de $t4 à l'adresse actuelle + 16 octets
sw $t5, 20($sp)          # Sauvegarde de $t5 à l'adresse actuelle + 20 octets


jal mult_matrix

.end_macro

.macro	div_mat(%M1,%M2,%M3,%n,%m,%p)

la $t0, %M1
la $t1, %M2
la $t2, %M3
lw $t3, %n
lw $t4, %m
lw $t5, %p

subi $sp, $sp, 24        # Allouer de l'espace pour 3 mots (12 octets) sur la pile
sw $t0, 0($sp)           # Sauvegarde de $t0 à l'adresse actuelle du pointeur de pile
sw $t1, 4($sp)           # Sauvegarde de $t1 à l'adresse actuelle + 4 octets
sw $t2, 8($sp)           # Sauvegarde de $t2 à l'adresse actuelle + 8 octets
sw $t3, 12($sp)          # Sauvegarde de $t3 à l'adresse actuelle + 12 octets
sw $t4, 16($sp)          # Sauvegarde de $t4 à l'adresse actuelle + 16 octets
sw $t5, 20($sp)          # Sauvegarde de $t5 à l'adresse actuelle + 20 octets


jal div_matrix

.end_macro

.macro	scal_mult_mat(%x,%M,%n,%m)

lw $t0, %x
la $t1, %M
lw $t2, %n
lw $t3, %m

subi $sp, $sp, 16       # Allouer de l'espace pour 3 mots (12 octets) sur la pile
sw $t0, 0($sp)           # Sauvegarde de $t0 à l'adresse actuelle du pointeur de pile
sw $t1, 4($sp)           # Sauvegarde de $t1 à l'adresse actuelle + 4 octets
sw $t2, 8($sp)           # Sauvegarde de $t2 à l'adresse actuelle + 8 octets
sw $t3, 12($sp)          # Sauvegarde de $t3 à l'adresse actuelle + 12 octets

jal scal_mult_matrix

.end_macro

.macro	scal_div_mat(%x,%M,%n,%m)

lw $t0, %x
la $t1, %M
lw $t2, %n
lw $t3, %m

subi $sp, $sp, 16       # Allouer de l'espace pour 3 mots (12 octets) sur la pile
sw $t0, 0($sp)           # Sauvegarde de $t0 à l'adresse actuelle du pointeur de pile
sw $t1, 4($sp)           # Sauvegarde de $t1 à l'adresse actuelle + 4 octets
sw $t2, 8($sp)           # Sauvegarde de $t2 à l'adresse actuelle + 8 octets
sw $t3, 12($sp)          # Sauvegarde de $t3 à l'adresse actuelle + 12 octets

jal scal_div_matrix

.end_macro
	
	
.data

# Matrice M de taille 3x3 initialisée à 0
.align 2
M1: .float 1.0:9
# Entiers n et m
M1_n: .word 3
M1_m: .word 3
.align 2
M2: .float 1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0 #2.0:9
M2_n: .word 3
M2_m: .word 3
.align 2
M3: .float 10.0,9.0,8.0,7.0,6.0,5.0,4.0,3.0,2.0#3.0:9
M3_n: .word 3
M3_m: .word 3
.align 2
I3: .float 1.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,1.0#3.0:9
I3_n: .word 3
I3_m: .word 3

# Chaîne de caractères pour le retour à la ligne
breakline: .asciiz "\n"

.text

printmat:
    # Restauration des registres sauvegardés
    lw      $t0, 0($sp)        # Restaurer M depuis la pile, t0 = &M
    lw      $t1, 4($sp)        # Restaurer n depuis la pile, t1 = n
    lw      $t2, 8($sp)        # Restaurer m depuis la pile, t2 = m
    addi    $sp, $sp, 12       # Restaurer $ra et $fp

    li $t3, 0 # $t3 = i = 0
    for_printmat1: # for (i = 0; i < n; i++)
        bge $t3, $t1, for_printmat1_end # branch if (i >= n)

        li $t4, 0 # $t4 = j = 0
        for_printmat2: # for (j = 0; j < m; j++)
            bge $t4, $t2, for_printmat2_end # branch if (j >= m)

            mul  $t5, $t2, $t3 # $t5 = i × m
            addu $t5, $t5, $t4 # $t5 = i × m + j
            sll  $t5, $t5, 2    # $t5 = (i × m + j) × 4

            addu $t5, $t0, $t5 # $t5 = &M + (i × m + j) × 4

            # Affichage de l'indice de la matrice
            print_str("M[")
            print_int($t3)
            print_str("][")
            print_int($t4)
            print_str("] = \t")

            # Utilisation de print_float pour afficher la valeur de la matrice
            l.s $f12, 0($t5) # $f12 = M[i][j]
            print_float($f12)
            print_str("\t")

            addi $t4, $t4, 1 # j++
            b for_printmat2
        for_printmat2_end:

        print_str("\n")

        addi $t3, $t3, 1 # i++
        b for_printmat1
    for_printmat1_end:

    jr $ra

transpose_matrix:
    # Restauration des registres sauvegardés
    lw   $t0, 0($sp)      # Restaurer M depuis la pile, t0 = &T
    lw   $t1, 4($sp)      # Restaurer M depuis la pile, t1 = &A
    lw   $t2, 8($sp)      # Restaurer n depuis la pile, t2 = n
    lw   $t3, 12($sp)     # Restaurer m depuis la pile, t3 = m
    addi $sp, $sp, 16      # Restaurer $ra et $fp

    li   $t4, 0            # $t4 = i = 0
    for_transpose_matrix1:
        bge  $t4, $t3, for_transpose_matrix1_end # branch if (i >= m)

        li   $t5, 0            # $t5 = j = 0
        for_transpose_matrix2:
            bge  $t5, $t2, for_transpose_matrix2_end # branch if (j >= n)

            mul  $t6, $t2, $t4    # $t6 = i × n
            addu $t6, $t6, $t5    # $t6 = i × n + j
            sll  $t6, $t6, 2      # $t6 = (i × n + j) × 4
            addu $t6, $t0, $t6    # $t6 = &T + (i × n + j) × 4

            mul  $t7, $t3, $t5    # $t7 = j × m
            addu $t7, $t7, $t4    # $t7 = j × m + i
            sll  $t7, $t7, 2      # $t7 = (j × m + i) × 4
            addu $t7, $t1, $t7    # $t7 = &A + (j × m + i) × 4

            # T[i][j] = A[j][i]
            lw   $t8, 0($t7)      # $t8 = A[j][i]
            sw   $t8, 0($t6)      # T[i][j] = A[j][i]

            addi $t5, $t5, 1      # j++
            b    for_transpose_matrix2
        for_transpose_matrix2_end:

        addi $t4, $t4, 1      # i++
        b    for_transpose_matrix1
    for_transpose_matrix1_end:

    jr   $ra

add_matrix:
    # Restauration des registres sauvegardés
    lw      $t0, 0($sp)        # Restaurer T depuis la pile, t0 = &T
    lw      $t1, 4($sp)        # Restaurer A depuis la pile, t1 = &A
    lw      $t2, 8($sp)        # Restaurer B depuis la pile, t2 = &B
    lw      $t3, 12($sp)       # Restaurer n depuis la pile, t3 = n
    lw      $t4, 16($sp)       # Restaurer m depuis la pile, t4 = m
    addi    $sp, $sp, 20       # Restaurer $ra et $fp

    li $t5, 0 # $t5 = i = 0
    for_add_matrix1: # for (i = 0; i < n; i++)
        bge $t5, $t3, for_add_matrix1_end # branch if (i >= n)

        li $t6, 0 # $t6 = j = 0
        for_add_matrix2: # for (j = 0; j < m; j++)
            bge $t6, $t4, for_add_matrix2_end # branch if (j >= m)

            mul  $t7, $t4, $t5    # $t7 = i × m
            addu $t7, $t7, $t6    # $t7 = i × m + j
            sll  $t7, $t7, 2      # $t7 = (i × m + j) × 4

            addu $s0, $t1, $t7    # $s0 = &A + (i × m + j) × 4
            addu $s1, $t2, $t7    # $s1 = &B + (i × m + j) × 4
            addu $t7, $t0, $t7    # $t7 = &T + (i × m + j) × 4

            # T[i][j] = A[i][j] + B[i][j]
            l.s   $f0, 0($s0)      # $f0 = A[i][j]
            l.s   $f1, 0($s1)      # $f1 = B[i][j]

            add.s  $f0, $f0, $f1    # $f0 = A[i][j] + B[i][j]
            swc1 $f0, 0($t7)     # T[i][j] = A[i][j] + B[i][j]

            addi $t6, $t6, 1 # j++
            b for_add_matrix2
        for_add_matrix2_end:

        addi $t5, $t5, 1 # i++
        b for_add_matrix1
    for_add_matrix1_end:

    jr $ra

sub_matrix:
    # Restauration des registres sauvegardés
    lw      $t0, 0($sp)        # Restaurer T depuis la pile, t0 = &T
    lw      $t1, 4($sp)        # Restaurer A depuis la pile, t1 = &A
    lw      $t2, 8($sp)        # Restaurer B depuis la pile, t2 = &B
    lw      $t3, 12($sp)       # Restaurer n depuis la pile, t3 = n
    lw      $t4, 16($sp)       # Restaurer m depuis la pile, t4 = m
    addi    $sp, $sp, 20       # Restaurer $ra et $fp

    li $t5, 0 # $t5 = i = 0
    for_sub_matrix1: # for (i = 0; i < n; i++)
        bge $t5, $t3, for_sub_matrix1_end # branch if (i >= n)

        li $t6, 0 # $t6 = j = 0
        for_sub_matrix2: # for (j = 0; j < m; j++)
            bge $t6, $t4, for_sub_matrix2_end # branch if (j >= m)

            mul  $t7, $t4, $t5    # $t7 = i × m
            addu $t7, $t7, $t6    # $t7 = i × m + j
            sll  $t7, $t7, 2      # $t7 = (i × m + j) × 4

            addu $s0, $t1, $t7    # $s0 = &A + (i × m + j) × 4
            addu $s1, $t2, $t7    # $s1 = &B + (i × m + j) × 4
            addu $t7, $t0, $t7    # $t7 = &T + (i × m + j) × 4

            l.s   $f0, 0($s0)      # $f0 = A[i][j]
            l.s   $f1, 0($s1)      # $f1 = B[i][j]

            sub.s  $f0, $f0, $f1  # $f0 = A[i][j] - B[i][j]
            swc1 $f0, 0($t7)      # T[i][j] = A[i][j] - B[i][j]

            addi $t6, $t6, 1 # j++
            b for_sub_matrix2
        for_sub_matrix2_end:

        addi $t5, $t5, 1 # i++
        b for_sub_matrix1
    for_sub_matrix1_end:

    jr $ra

.data 
zero_float: .float 0.0
.text

mult_matrix:
    # T[n][p] = A[n][m] * B[m][p]
    # Restauration des registres sauvegardés
    lw      $t0, 0($sp)        # Restaurer T depuis la pile, t0 = &T
    lw      $t1, 4($sp)        # Restaurer A depuis la pile, t1 = &A
    lw      $t2, 8($sp)        # Restaurer B depuis la pile, t2 = &B
    lw      $t3, 12($sp)       # Restaurer n depuis la pile, t3 = n
    lw      $t4, 16($sp)       # Restaurer m depuis la pile, t4 = m
    lw      $t5, 20($sp)       # Restaurer p depuis la pile, t5 = p
    addi    $sp, $sp, 24       # Restaurer $ra et $fp

    li $t6, 0 # $t6 = i = 0
    for_mult_matrix1: # for (i = 0; i < n; i++)
        bge $t6, $t3, for_mult_matrix1_end # branch if (i >= n)

        li $t7, 0 # $t7 = j = 0
        for_mult_matrix2: # for (j = 0; j < p; j++)
            bge  $t7, $t5, for_mult_matrix2_end # branch if (j >= p)

            l.s $f0, zero_float # $f0 = 0
            li $t8, 0
            for_mult_matrix3: # for (k = 0; k < m; k++)
                bge $t8, $t4, for_mult_matrix3_end # branch if (k >= m)

                mul  $s0, $t6, $t4    # $s0 = i × m
                addu $s0, $s0, $t8    # $s0 = i × m + k
                sll  $s0, $s0, 2      # $s0 = (i × m + k) × 4
                addu $s0, $s0, $t1    # $s0 = &A + (i × m + k) × 4

                mul  $s1, $t8, $t5    # $s1 = k × p
                addu $s1, $s1, $t7    # $s1 = k × p + j
                sll  $s1, $s1, 2      # $s1 = (k × p + j) × 4
                addu $s1, $s1, $t2    # $s1 = &B + (k × p + j) × 4

                l.s   $f1, 0($s0)      # $f1 = A[i][k]
                l.s   $f2, 0($s1)      # $f2 = B[k][j]

                mul.s $f1, $f1, $f2    # $f1 = A[i][k] * B[k][j]
                add.s $f0, $f0, $f1    # $f0 = $f0 + A[i][k] * B[k][j]

                addiu $t8, $t8, 1 # k++
                b for_mult_matrix3
            for_mult_matrix3_end:

            # T[i][j] = $f0
            mul  $t9, $t6, $t5   # $t9 = i × p
            addu $t9, $t9, $t7   # $t9 = i × p + j
            sll  $t9, $t9, 2     # $t9 = (i × p + j) × 4
            addu $t9, $t9, $t0   # $t9 = &T + (i × p + j) × 4
            s.s   $f0, 0($t9)    # T[i][j] = $f0

            addiu $t7, $t7, 1 # j++
            b for_mult_matrix2
        for_mult_matrix2_end:

        addiu $t6, $t6, 1 # i++
        b for_mult_matrix1
    for_mult_matrix1_end:

    jr $ra

zero_dividing:
    print_str("Erreur ! Tentative de Division par 0 !")
    exit(1)

div_matrix:
    # T[n][p] = A[n][m] / B[m][p]
    # Restauration des registres sauvegardés
    lw      $t0, 0($sp)        # Restaurer T depuis la pile, t0 = &T
    lw      $t1, 4($sp)        # Restaurer A depuis la pile, t1 = &A
    lw      $t2, 8($sp)        # Restaurer B depuis la pile, t2 = &B
    lw      $t3, 12($sp)       # Restaurer n depuis la pile, t3 = n
    lw      $t4, 16($sp)       # Restaurer m depuis la pile, t4 = m
    lw      $t5, 20($sp)       # Restaurer p depuis la pile, t5 = p
    addi    $sp, $sp, 24       # Restaurer $ra et $fp

    li $t6, 0 # $t6 = i = 0
    for_div_matrix1: # for (i = 0; i < n; i++)
        bge $t6, $t3, for_div_matrix1_end # branch if (i >= n)

        li $t7, 0 # $t7 = j = 0
        for_div_matrix2: # for (j = 0; j < p; j++)
            bge  $t7, $t5, for_div_matrix2_end # branch if (j >= p)

            l.s $f0, zero_float # $f0 = 0
            li $t8, 0
            for_div_matrix3: # for (k = 0; k < m; k++)
                bge $t8, $t4, for_div_matrix3_end # branch if (k >= m)

                mul  $s0, $t6, $t4    # $s0 = i × m
                addu $s0, $s0, $t8    # $s0 = i × m + k
                sll  $s0, $s0, 2      # $s0 = (i × m + k) × 4
                addu $s0, $s0, $t1    # $s0 = &A + (i × m + k) × 4

                mul  $s1, $t8, $t5    # $s1 = k × p
                addu $s1, $s1, $t7    # $s1 = k × p + j
                sll  $s1, $s1, 2      # $s1 = (k × p + j) × 4
                addu $s1, $s1, $t2    # $s1 = &B + (k × p + j) × 4

                l.s   $f1, 0($s0)      # $f1 = A[i][k]
                l.s   $f2, 0($s1)      # $f2 = B[k][j]

                # test s'il y a une tentative de division par zéro 
                l.s $f3, zero_float
                c.eq.s $f2, $f3
                bc1t zero_dividing

                div.s $f1, $f1, $f2    # $f1 = A[i][k] / B[k][j]
                add.s $f0, $f0, $f1    # $f0 = $f0 + A[i][k] / B[k][j]

                addiu $t8, $t8, 1 # k++
                b for_div_matrix3
            for_div_matrix3_end:

            # T[i][j] = $f0
            mul  $t9, $t6, $t5   # $t9 = i × p
            addu $t9, $t9, $t7   # $t9 = i × p + j
            sll  $t9, $t9, 2     # $t9 = (i × p + j) × 4
            addu $t9, $t9, $t0   # $t9 = &T + (i × p + j) × 4
            s.s   $f0, 0($t9)    # T[i][j] = $f0

            addiu $t7, $t7, 1 # j++
            b for_div_matrix2
        for_div_matrix2_end:

        addiu $t6, $t6, 1 # i++
        b for_div_matrix1
    for_div_matrix1_end:

    jr $ra

	
scal_mult_matrix:
	# Restauration des registres sauvegardés
	l.s   $f0, 0($sp)       # Restaurer x depuis la pile, f0 = x
	lw    $t0, 4($sp)       # Restaurer A depuis la pile, t0 = &A
	lw    $t1, 8($sp)       # Restaurer n depuis la pile, t1 = n
	lw    $t2, 12($sp)      # Restaurer m depuis la pile, t2 = m
	addi  $sp, $sp, 16      # Restaurer $ra et $fp
	
	li    $t5, 0            # $t5 = i = 0
	for_scal_mult_matrix1:     # for (i = 0; i < n; i++)
	bge   $t5, $t1, for_scal_mult_matrix1_end # branch if (i < n)
		
		li    $t6, 0            # $t6 = j = 0
		for_scal_mult_matrix2:     # for (j = 0; j < m; j++)
			bge   $t6, $t2, for_scal_mult_matrix2_end
			
			mul   $t7, $t5, $t2     # $t7 = i × m
			addu  $t7, $t7, $t6     # $t7 = i × m + j
			sll   $t7, $t7, 2       # $t7 = (i × m + j) × 4
			addu  $t7, $t0, $t7     # $t7 = &A + (i × m + j) × 4
	
			l.s   $f1, 0($t7)       # $f1 = A[i][j]
			mul.s $f1, $f1, $f0     # $f1 = A[i][j] * x
			swc1  $f1, 0($t7)       # A[i][j] = A[i][j] *x
			
		addi  $t6, $t6, 1 # j++
		b     for_scal_mult_matrix2
		for_scal_mult_matrix2_end:
		
		addi  $t5, $t5, 1 # i++
		b     for_scal_mult_matrix1
	for_scal_mult_matrix1_end:
	
	jr    $ra

scal_div_matrix:
	# Restauration des registres sauvegardés
	l.s   $f0, 0($sp)       # Restaurer x depuis la pile, f0 = x
	lw    $t0, 4($sp)       # Restaurer A depuis la pile, t0 = &A
	lw    $t1, 8($sp)       # Restaurer n depuis la pile, t1 = n
	lw    $t2, 12($sp)      # Restaurer m depuis la pile, t2 = m
	addi  $sp, $sp, 16      # Restaurer $ra et $fp
	
	# test si division par zéro
	l.s   $f1, zero_float
	c.eq.s $f0, $f1
	bc1t  zero_dividing
	
	li    $t5, 0            # $t5 = i = 0
	for_scal_div_matrix1:       # for (i = 0; i < n; i++)
	bge   $t5, $t1, for_scal_div_matrix1_end # branch if (i < n)
		
		li    $t6, 0            # $t6 = j = 0
		for_scal_div_matrix2:       # for (j = 0; j < m; j++)
			bge   $t6, $t2, for_scal_div_matrix2_end
			
			mul   $t7, $t5, $t2     # $t7 = i × m
			addu  $t7, $t7, $t6     # $t7 = i × m + j
			sll   $t7, $t7, 2       # $t7 = (i × m + j) × 4
			addu  $t7, $t0, $t7     # $t7 = &A + (i × m + j) × 4
			
			l.s   $f1, 0($t7)       # $f1 = A[i][j]
			div.s $f1, $f1, $f0     # $f1 = A[i][j] / x
			swc1  $f1, 0($t7)       # A[i][j] = A[i][j] / x
			
		addi  $t6, $t6, 1       # j++
		b     for_scal_div_matrix2
		for_scal_div_matrix2_end:
		
	addi  $t5, $t5, 1       # i++
	b     for_scal_div_matrix1
	for_scal_div_matrix1_end:
	
	jr    $ra
	
.data
	.align 2
	test_add_matrix_M1: .float 1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0
	.align 2
	test_add_matrix_M2: .float 10.0,10.0,10.0,10.0,10.0,10.0,10.0,10.0,10.0
	.align 2
	test_add_matrix_M3: .float 100.0,100.0,100.0,100.0,100.0,100.0,100.0,100.0,100.0
	.align 2
	test_add_matrix_n: .word 3
	.align 2
	test_add_matrix_m: .word 3
	.align 2
	lambda: .float 4.5
	
.align 2	
A:  .float 6.0, 5.0, 4.0, 1.0, 2.0, 3.0
.align 2
At : .float 6.0, 1.0,5.0, 2.0, 4.0, 3.0
.align 2
B:  .float 1.0, 2.0, 3.0, 4.0, 5.0, 6.0
.align 2
T:  .float 0.0:6  # Espace pour la matrice résultante (2x3)
.align 2
P: .float 0.0:9
.align 2
A_n: .word 2
A_m: .word 3

.text
test_matrix:
	# genere 3 matrices de taille 3x3 en assembleur mips
	
	
	# print_mat (M1,test_add_matrix_n,test_add_matrix_m)
	# print_mat (M2,test_add_matrix_n,test_add_matrix_m)
	# print_mat (M3,test_add_matrix_n,test_add_matrix_m)
	
	# test la fonction add_matrix
	#la $t0, M1
	#la $t1, M2
	#la $t2, M3
	#lw $t3, M1_n
	#lw $t4, M1_m

	#subi $sp, $sp, 20        # Allouer de l'espace pour 3 mots (12 octets) sur la pile
	#sw $t0, 0($sp)           # Sauvegarde de $t0 à l'adresse actuelle du pointeur de pile
	#sw $t1, 4($sp)           # Sauvegarde de $t1 à l'adresse actuelle + 4 octets
	#sw $t2, 8($sp)           # Sauvegarde de $t2 à l'adresse actuelle + 8 octets
	#sw $t3, 12($sp)          # Sauvegarde de $t3 à l'adresse actuelle + 12 octets
	#sw $t4, 16($sp)          # Sauvegarde de $t4 à l'adresse actuelle + 16 octets

	#jal add_matrix
		
	print_str("\n Matrice M2 : \n")
	print_mat(M2,M2_n,M2_m)
	print_str("\n Matrice M3 : \n")
	print_mat(M3,M3_n,M3_m)	
		
	print_str("\n Addition M2 + M3 \n")
	add_mat(M1,M2,M3,M2_n,M2_m)
	print_mat(M1,M1_n,M1_m)
		
	
	print_str("\n Multiplication M2*M3 \n")
	mult_mat(M1,M2,M3,M2_n,M3_n,M3_m)
	print_mat(M1,M1_n,M1_m)
	
	print_str("\n Transposition M2 \n")
	transpose_mat(M1,M2,M2_n,M2_m)
	print_mat(M1,M1_n,M1_m)
	print_str("\n M2 \n")
	print_mat(M2,M2_n,M2_m)
	
	print_str("Matrice identité I3\n")
	print_mat(I3,I3_n,I3_m)
	
	print_str("\n Multiplication par un scalaire \n")
	scal_mult_mat(lambda,I3,I3_n,I3_m)
	print_mat(I3,I3_n,I3_m)
	
	print_str("\n Division par un scalaire \n")
	scal_mult_mat(lambda,I3,I3_n,I3_m)
	print_mat(I3,I3_n,I3_m)
	
	print_str("\n Afficher A \n")
	print_mat(A,A_n,A_m)
	
	print_str("\n Afficher B \n")
	print_mat(B,A_n,A_m)
	
	print_str("\n A + B \n")
	add_mat(T,A,B,A_n,A_m)
	print_mat(T,A_n,A_m)
	
	print_str("\n Transpose A \n")
	transpose_mat(T,A,A_n,A_m)
	print_mat(T,A_m,A_n)
	
	print_str("\n A \n")
	print_mat(A,A_n,A_m)
	
	print_str("\n A * B \n")
	mult_mat(P,T,B,A_m,A_n,A_m)
	print_mat(P,A_m,A_m)
	
	jr $ra

.globl	main

main:
	
	# print_mat(M1,M1_n,M1_m)
	
	jal test_matrix
	
	print_str("Fin main")
	
	exit(0)
