.macro print_str(%str)
.data
str: .asciiz %str
.text
li $v0, 4
la $a0, str
syscall
.end_macro

.macro print_int (%x)
li $v0, 1
add $a0, $zero, %x
syscall
.end_macro

.macro exit(%x)
li $v0, 17
add $a0, $zero, %x
syscall
.end_macro

.macro print_float (%x)
li $v0, 2
mov.s $f12, %x
syscall
.end_macro

.data
	a_main_0_0: .word 0
	b_main_0_0: .word 0
	c_main_1_1: .word 0
	d_main_1_1: .word 0
	a_main_2_1: .word 0
	b_main_2_1: .word 0
.text
.globl main

main:
	# a = 1
	li $t0, 1
	sw $t0, a_main_0_0

	# b = 2
	li $t0, 2
	sw $t0, b_main_0_0

	lw $t0, a_main_0_0
	lw $t1, b_main_0_0
	bgt $t0, $t1, L0
	j L1


L0:
	print_str("not here\n")
	j L6

L1:
	# c = 3
	li $t0, 3
	sw $t0, c_main_1_1

	# d = 4
	li $t0, 4
	sw $t0, d_main_1_1

	lw $t0, c_main_1_1
	lw $t1, d_main_1_1
	beq $t0, $t1, L2
	j L3


L2:
	print_str("No")
	j L6

L3:
	print_str("Hello ")
	# a = 1
	li $t0, 1
	sw $t0, a_main_2_1

	# b = 2
	li $t0, 2
	sw $t0, b_main_2_1

	lw $t0, a_main_2_1
	lw $t1, b_main_2_1
	bne $t0, $t1, L4
	j L5


L4:
	print_str("World!\n")
	j L6

L5:
	print_str("No")

L6:
	print_str("The end!\n")
	exit(0)
