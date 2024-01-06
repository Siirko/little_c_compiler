	.file	1 "matrix.c"
	.section .mdebug.abi32
	.previous
	.nan	legacy
	.module	fp=32
	.module	nooddspreg
	.abicalls
	.text
	.rdata
	.align	2
$LC0:
	.ascii	"%f\011\000"
	.text
	.align	2
	.globl	printmat
	.set	nomips16
	.set	nomicromips
	.ent	printmat
	.type	printmat, @function
printmat:
	.frame	$fp,40,$31		# vars= 8, regs= 2/0, args= 16, gp= 8
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-40
	sw	$31,36($sp)
	sw	$fp,32($sp)
	move	$fp,$sp
	lui	$28,%hi(__gnu_local_gp)
	addiu	$28,$28,%lo(__gnu_local_gp)
	.cprestore	16
	sw	$4,40($fp)
	sw	$0,24($fp)
	.option	pic0
	b	$L2
	nop

	.option	pic2
$L5:
	sw	$0,28($fp)
	.option	pic0
	b	$L3
	nop

	.option	pic2
$L4:
	lw	$2,40($fp)
	nop
	lw	$3,0($2)
	lw	$2,40($fp)
	nop
	lw	$4,8($2)
	lw	$2,24($fp)
	nop
	mult	$4,$2
	lw	$2,28($fp)
	mflo	$4
	addu	$2,$4,$2
	sll	$2,$2,2
	addu	$2,$3,$2
	lwc1	$f0,0($2)
	nop
	cvt.d.s	$f0,$f0
	mfc1	$7,$f0
	mfc1	$6,$f1
	lui	$2,%hi($LC0)
	addiu	$4,$2,%lo($LC0)
	lw	$2,%call16(printf)($28)
	nop
	move	$25,$2
	.reloc	1f,R_MIPS_JALR,printf
1:	jalr	$25
	nop

	lw	$28,16($fp)
	lw	$2,28($fp)
	nop
	addiu	$2,$2,1
	sw	$2,28($fp)
$L3:
	lw	$2,40($fp)
	nop
	lw	$2,8($2)
	lw	$3,28($fp)
	nop
	slt	$2,$3,$2
	bne	$2,$0,$L4
	nop

	li	$4,10			# 0xa
	lw	$2,%call16(putchar)($28)
	nop
	move	$25,$2
	.reloc	1f,R_MIPS_JALR,putchar
1:	jalr	$25
	nop

	lw	$28,16($fp)
	lw	$2,24($fp)
	nop
	addiu	$2,$2,1
	sw	$2,24($fp)
$L2:
	lw	$2,40($fp)
	nop
	lw	$2,4($2)
	lw	$3,24($fp)
	nop
	slt	$2,$3,$2
	bne	$2,$0,$L5
	nop

	li	$4,10			# 0xa
	lw	$2,%call16(putchar)($28)
	nop
	move	$25,$2
	.reloc	1f,R_MIPS_JALR,putchar
1:	jalr	$25
	nop

	lw	$28,16($fp)
	nop
	move	$sp,$fp
	lw	$31,36($sp)
	lw	$fp,32($sp)
	addiu	$sp,$sp,40
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	printmat
	.size	printmat, .-printmat
	.align	2
	.globl	unit_matrix
	.set	nomips16
	.set	nomicromips
	.ent	unit_matrix
	.type	unit_matrix, @function
unit_matrix:
	.frame	$fp,16,$31		# vars= 8, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-16
	sw	$fp,12($sp)
	move	$fp,$sp
	sw	$4,16($fp)
	sw	$0,0($fp)
	.option	pic0
	b	$L7
	nop

	.option	pic2
$L12:
	sw	$0,4($fp)
	.option	pic0
	b	$L8
	nop

	.option	pic2
$L11:
	lw	$3,0($fp)
	lw	$2,4($fp)
	nop
	bne	$3,$2,$L9
	nop

	lui	$2,%hi($LC1)
	lwc1	$f0,%lo($LC1)($2)
	.option	pic0
	b	$L10
	nop

	.option	pic2
$L9:
	mtc1	$0,$f0
$L10:
	lw	$2,16($fp)
	nop
	lw	$3,0($2)
	lw	$2,16($fp)
	nop
	lw	$4,8($2)
	lw	$2,0($fp)
	nop
	mult	$4,$2
	lw	$2,4($fp)
	mflo	$4
	addu	$2,$4,$2
	sll	$2,$2,2
	addu	$2,$3,$2
	swc1	$f0,0($2)
	lw	$2,4($fp)
	nop
	addiu	$2,$2,1
	sw	$2,4($fp)
$L8:
	lw	$2,16($fp)
	nop
	lw	$2,8($2)
	lw	$3,4($fp)
	nop
	slt	$2,$3,$2
	bne	$2,$0,$L11
	nop

	lw	$2,0($fp)
	nop
	addiu	$2,$2,1
	sw	$2,0($fp)
$L7:
	lw	$2,16($fp)
	nop
	lw	$2,4($2)
	lw	$3,0($fp)
	nop
	slt	$2,$3,$2
	bne	$2,$0,$L12
	nop

	nop
	nop
	move	$sp,$fp
	lw	$fp,12($sp)
	addiu	$sp,$sp,16
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	unit_matrix
	.size	unit_matrix, .-unit_matrix
	.align	2
	.globl	zero_matrix
	.set	nomips16
	.set	nomicromips
	.ent	zero_matrix
	.type	zero_matrix, @function
zero_matrix:
	.frame	$fp,16,$31		# vars= 8, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-16
	sw	$fp,12($sp)
	move	$fp,$sp
	sw	$4,16($fp)
	sw	$0,0($fp)
	.option	pic0
	b	$L14
	nop

	.option	pic2
$L17:
	sw	$0,4($fp)
	.option	pic0
	b	$L15
	nop

	.option	pic2
$L16:
	lw	$2,16($fp)
	nop
	lw	$3,0($2)
	lw	$2,16($fp)
	nop
	lw	$4,8($2)
	lw	$2,0($fp)
	nop
	mult	$4,$2
	lw	$2,4($fp)
	mflo	$4
	addu	$2,$4,$2
	sll	$2,$2,2
	addu	$2,$3,$2
	sw	$0,0($2)
	lw	$2,4($fp)
	nop
	addiu	$2,$2,1
	sw	$2,4($fp)
$L15:
	lw	$2,16($fp)
	nop
	lw	$2,8($2)
	lw	$3,4($fp)
	nop
	slt	$2,$3,$2
	bne	$2,$0,$L16
	nop

	lw	$2,0($fp)
	nop
	addiu	$2,$2,1
	sw	$2,0($fp)
$L14:
	lw	$2,16($fp)
	nop
	lw	$2,4($2)
	lw	$3,0($fp)
	nop
	slt	$2,$3,$2
	bne	$2,$0,$L17
	nop

	nop
	nop
	move	$sp,$fp
	lw	$fp,12($sp)
	addiu	$sp,$sp,16
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	zero_matrix
	.size	zero_matrix, .-zero_matrix
	.align	2
	.globl	transpose_matrix
	.set	nomips16
	.set	nomicromips
	.ent	transpose_matrix
	.type	transpose_matrix, @function
transpose_matrix:
	.frame	$fp,16,$31		# vars= 8, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-16
	sw	$fp,12($sp)
	move	$fp,$sp
	sw	$4,16($fp)
	sw	$5,20($fp)
	lw	$2,16($fp)
	nop
	lw	$3,4($2)
	lw	$2,20($fp)
	nop
	lw	$2,8($2)
	nop
	bne	$3,$2,$L19
	nop

	lw	$2,16($fp)
	nop
	lw	$3,8($2)
	lw	$2,20($fp)
	nop
	lw	$2,4($2)
	nop
	beq	$3,$2,$L20
	nop

$L19:
	li	$2,-1			# 0xffffffffffffffff
	.option	pic0
	b	$L21
	nop

	.option	pic2
$L20:
	sw	$0,0($fp)
	.option	pic0
	b	$L22
	nop

	.option	pic2
$L25:
	sw	$0,4($fp)
	.option	pic0
	b	$L23
	nop

	.option	pic2
$L24:
	lw	$2,20($fp)
	nop
	lw	$3,0($2)
	lw	$2,20($fp)
	nop
	lw	$4,8($2)
	lw	$2,4($fp)
	nop
	mult	$4,$2
	lw	$2,0($fp)
	mflo	$4
	addu	$2,$4,$2
	sll	$2,$2,2
	addu	$3,$3,$2
	lw	$2,16($fp)
	nop
	lw	$4,0($2)
	lw	$2,16($fp)
	nop
	lw	$5,8($2)
	lw	$2,0($fp)
	nop
	mult	$5,$2
	lw	$2,4($fp)
	mflo	$5
	addu	$2,$5,$2
	sll	$2,$2,2
	addu	$2,$4,$2
	lwc1	$f0,0($3)
	nop
	swc1	$f0,0($2)
	lw	$2,4($fp)
	nop
	addiu	$2,$2,1
	sw	$2,4($fp)
$L23:
	lw	$2,16($fp)
	nop
	lw	$2,8($2)
	lw	$3,4($fp)
	nop
	slt	$2,$3,$2
	bne	$2,$0,$L24
	nop

	lw	$2,0($fp)
	nop
	addiu	$2,$2,1
	sw	$2,0($fp)
$L22:
	lw	$2,16($fp)
	nop
	lw	$2,4($2)
	lw	$3,0($fp)
	nop
	slt	$2,$3,$2
	bne	$2,$0,$L25
	nop

	move	$2,$0
$L21:
	move	$sp,$fp
	lw	$fp,12($sp)
	addiu	$sp,$sp,16
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	transpose_matrix
	.size	transpose_matrix, .-transpose_matrix
	.align	2
	.globl	add_matrix
	.set	nomips16
	.set	nomicromips
	.ent	add_matrix
	.type	add_matrix, @function
add_matrix:
	.frame	$fp,16,$31		# vars= 8, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-16
	sw	$fp,12($sp)
	move	$fp,$sp
	sw	$4,16($fp)
	sw	$5,20($fp)
	sw	$6,24($fp)
	sw	$7,28($fp)
	lw	$2,16($fp)
	nop
	lw	$3,4($2)
	lw	$2,20($fp)
	nop
	lw	$2,4($2)
	nop
	bne	$3,$2,$L27
	nop

	lw	$2,16($fp)
	nop
	lw	$3,4($2)
	lw	$2,24($fp)
	nop
	lw	$2,4($2)
	nop
	bne	$3,$2,$L27
	nop

	lw	$2,16($fp)
	nop
	lw	$3,8($2)
	lw	$2,20($fp)
	nop
	lw	$2,8($2)
	nop
	bne	$3,$2,$L27
	nop

	lw	$2,16($fp)
	nop
	lw	$3,8($2)
	lw	$2,24($fp)
	nop
	lw	$2,8($2)
	nop
	beq	$3,$2,$L28
	nop

$L27:
	li	$2,-1			# 0xffffffffffffffff
	.option	pic0
	b	$L29
	nop

	.option	pic2
$L28:
	sw	$0,0($fp)
	.option	pic0
	b	$L30
	nop

	.option	pic2
$L33:
	sw	$0,4($fp)
	.option	pic0
	b	$L31
	nop

	.option	pic2
$L32:
	lw	$2,20($fp)
	nop
	lw	$3,0($2)
	lw	$2,20($fp)
	nop
	lw	$4,8($2)
	lw	$2,0($fp)
	nop
	mult	$4,$2
	lw	$2,4($fp)
	mflo	$4
	addu	$2,$4,$2
	sll	$2,$2,2
	addu	$2,$3,$2
	lwc1	$f2,0($2)
	lwc1	$f0,28($fp)
	nop
	mul.s	$f2,$f2,$f0
	lw	$2,24($fp)
	nop
	lw	$3,0($2)
	lw	$2,24($fp)
	nop
	lw	$4,8($2)
	lw	$2,0($fp)
	nop
	mult	$4,$2
	lw	$2,4($fp)
	mflo	$4
	addu	$2,$4,$2
	sll	$2,$2,2
	addu	$2,$3,$2
	lwc1	$f4,0($2)
	lwc1	$f0,32($fp)
	nop
	mul.s	$f0,$f4,$f0
	lw	$2,16($fp)
	nop
	lw	$3,0($2)
	lw	$2,16($fp)
	nop
	lw	$4,8($2)
	lw	$2,0($fp)
	nop
	mult	$4,$2
	lw	$2,4($fp)
	mflo	$4
	addu	$2,$4,$2
	sll	$2,$2,2
	addu	$2,$3,$2
	add.s	$f0,$f2,$f0
	swc1	$f0,0($2)
	lw	$2,4($fp)
	nop
	addiu	$2,$2,1
	sw	$2,4($fp)
$L31:
	lw	$2,16($fp)
	nop
	lw	$2,8($2)
	lw	$3,4($fp)
	nop
	slt	$2,$3,$2
	bne	$2,$0,$L32
	nop

	lw	$2,0($fp)
	nop
	addiu	$2,$2,1
	sw	$2,0($fp)
$L30:
	lw	$2,16($fp)
	nop
	lw	$2,4($2)
	lw	$3,0($fp)
	nop
	slt	$2,$3,$2
	bne	$2,$0,$L33
	nop

	move	$2,$0
$L29:
	move	$sp,$fp
	lw	$fp,12($sp)
	addiu	$sp,$sp,16
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	add_matrix
	.size	add_matrix, .-add_matrix
	.align	2
	.globl	mult_matrix
	.set	nomips16
	.set	nomicromips
	.ent	mult_matrix
	.type	mult_matrix, @function
mult_matrix:
	.frame	$fp,24,$31		# vars= 16, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-24
	sw	$fp,20($sp)
	move	$fp,$sp
	sw	$4,24($fp)
	sw	$5,28($fp)
	sw	$6,32($fp)
	sw	$7,36($fp)
	lw	$2,24($fp)
	nop
	lw	$3,4($2)
	lw	$2,28($fp)
	nop
	lw	$2,4($2)
	nop
	bne	$3,$2,$L35
	nop

	lw	$2,24($fp)
	nop
	lw	$3,8($2)
	lw	$2,32($fp)
	nop
	lw	$2,8($2)
	nop
	bne	$3,$2,$L35
	nop

	lw	$2,28($fp)
	nop
	lw	$3,8($2)
	lw	$2,32($fp)
	nop
	lw	$2,4($2)
	nop
	beq	$3,$2,$L36
	nop

$L35:
	li	$2,-1			# 0xffffffffffffffff
	.option	pic0
	b	$L37
	nop

	.option	pic2
$L36:
	sw	$0,4($fp)
	.option	pic0
	b	$L38
	nop

	.option	pic2
$L43:
	sw	$0,8($fp)
	.option	pic0
	b	$L39
	nop

	.option	pic2
$L42:
	lw	$2,24($fp)
	nop
	lw	$3,0($2)
	lw	$2,24($fp)
	nop
	lw	$4,8($2)
	lw	$2,4($fp)
	nop
	mult	$4,$2
	lw	$2,8($fp)
	mflo	$4
	addu	$2,$4,$2
	sll	$2,$2,2
	addu	$2,$3,$2
	sw	$0,0($2)
	sw	$0,12($fp)
	.option	pic0
	b	$L40
	nop

	.option	pic2
$L41:
	lw	$2,24($fp)
	nop
	lw	$3,0($2)
	lw	$2,24($fp)
	nop
	lw	$4,8($2)
	lw	$2,4($fp)
	nop
	mult	$4,$2
	lw	$2,8($fp)
	mflo	$4
	addu	$2,$4,$2
	sll	$2,$2,2
	addu	$2,$3,$2
	lwc1	$f2,0($2)
	lw	$2,28($fp)
	nop
	lw	$3,0($2)
	lw	$2,28($fp)
	nop
	lw	$4,8($2)
	lw	$2,4($fp)
	nop
	mult	$4,$2
	lw	$2,12($fp)
	mflo	$4
	addu	$2,$4,$2
	sll	$2,$2,2
	addu	$2,$3,$2
	lwc1	$f4,0($2)
	lwc1	$f0,36($fp)
	nop
	mul.s	$f4,$f4,$f0
	lwc1	$f0,40($fp)
	nop
	mul.s	$f4,$f4,$f0
	lw	$2,32($fp)
	nop
	lw	$3,0($2)
	lw	$2,32($fp)
	nop
	lw	$4,8($2)
	lw	$2,12($fp)
	nop
	mult	$4,$2
	lw	$2,8($fp)
	mflo	$4
	addu	$2,$4,$2
	sll	$2,$2,2
	addu	$2,$3,$2
	lwc1	$f0,0($2)
	nop
	mul.s	$f0,$f4,$f0
	lw	$2,24($fp)
	nop
	lw	$3,0($2)
	lw	$2,24($fp)
	nop
	lw	$4,8($2)
	lw	$2,4($fp)
	nop
	mult	$4,$2
	lw	$2,8($fp)
	mflo	$4
	addu	$2,$4,$2
	sll	$2,$2,2
	addu	$2,$3,$2
	add.s	$f0,$f2,$f0
	swc1	$f0,0($2)
	lw	$2,12($fp)
	nop
	addiu	$2,$2,1
	sw	$2,12($fp)
$L40:
	lw	$2,28($fp)
	nop
	lw	$2,8($2)
	lw	$3,12($fp)
	nop
	slt	$2,$3,$2
	bne	$2,$0,$L41
	nop

	lw	$2,8($fp)
	nop
	addiu	$2,$2,1
	sw	$2,8($fp)
$L39:
	lw	$2,24($fp)
	nop
	lw	$2,8($2)
	lw	$3,8($fp)
	nop
	slt	$2,$3,$2
	bne	$2,$0,$L42
	nop

	lw	$2,4($fp)
	nop
	addiu	$2,$2,1
	sw	$2,4($fp)
$L38:
	lw	$2,24($fp)
	nop
	lw	$2,4($2)
	lw	$3,4($fp)
	nop
	slt	$2,$3,$2
	bne	$2,$0,$L43
	nop

	move	$2,$0
$L37:
	move	$sp,$fp
	lw	$fp,20($sp)
	addiu	$sp,$sp,24
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	mult_matrix
	.size	mult_matrix, .-mult_matrix
	.align	2
	.globl	div_matrix
	.set	nomips16
	.set	nomicromips
	.ent	div_matrix
	.type	div_matrix, @function
div_matrix:
	.frame	$fp,24,$31		# vars= 16, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-24
	sw	$fp,20($sp)
	move	$fp,$sp
	sw	$4,24($fp)
	sw	$5,28($fp)
	sw	$6,32($fp)
	sw	$7,36($fp)
	lw	$2,24($fp)
	nop
	lw	$3,4($2)
	lw	$2,28($fp)
	nop
	lw	$2,4($2)
	nop
	bne	$3,$2,$L45
	nop

	lw	$2,24($fp)
	nop
	lw	$3,8($2)
	lw	$2,32($fp)
	nop
	lw	$2,8($2)
	nop
	bne	$3,$2,$L45
	nop

	lw	$2,28($fp)
	nop
	lw	$3,8($2)
	lw	$2,32($fp)
	nop
	lw	$2,4($2)
	nop
	beq	$3,$2,$L46
	nop

$L45:
	li	$2,-1			# 0xffffffffffffffff
	.option	pic0
	b	$L47
	nop

	.option	pic2
$L46:
	sw	$0,4($fp)
	.option	pic0
	b	$L48
	nop

	.option	pic2
$L53:
	sw	$0,8($fp)
	.option	pic0
	b	$L49
	nop

	.option	pic2
$L52:
	lw	$2,24($fp)
	nop
	lw	$3,0($2)
	lw	$2,24($fp)
	nop
	lw	$4,8($2)
	lw	$2,4($fp)
	nop
	mult	$4,$2
	lw	$2,8($fp)
	mflo	$4
	addu	$2,$4,$2
	sll	$2,$2,2
	addu	$2,$3,$2
	sw	$0,0($2)
	sw	$0,12($fp)
	.option	pic0
	b	$L50
	nop

	.option	pic2
$L51:
	lw	$2,24($fp)
	nop
	lw	$3,0($2)
	lw	$2,24($fp)
	nop
	lw	$4,8($2)
	lw	$2,4($fp)
	nop
	mult	$4,$2
	lw	$2,8($fp)
	mflo	$4
	addu	$2,$4,$2
	sll	$2,$2,2
	addu	$2,$3,$2
	lwc1	$f2,0($2)
	lw	$2,28($fp)
	nop
	lw	$3,0($2)
	lw	$2,28($fp)
	nop
	lw	$4,8($2)
	lw	$2,4($fp)
	nop
	mult	$4,$2
	lw	$2,12($fp)
	mflo	$4
	addu	$2,$4,$2
	sll	$2,$2,2
	addu	$2,$3,$2
	lwc1	$f4,0($2)
	lwc1	$f0,36($fp)
	nop
	mul.s	$f4,$f4,$f0
	lw	$2,32($fp)
	nop
	lw	$3,0($2)
	lw	$2,32($fp)
	nop
	lw	$4,8($2)
	lw	$2,12($fp)
	nop
	mult	$4,$2
	lw	$2,8($fp)
	mflo	$4
	addu	$2,$4,$2
	sll	$2,$2,2
	addu	$2,$3,$2
	lwc1	$f6,0($2)
	lwc1	$f0,40($fp)
	nop
	mul.s	$f0,$f6,$f0
	div.s	$f0,$f4,$f0
	lw	$2,24($fp)
	nop
	lw	$3,0($2)
	lw	$2,24($fp)
	nop
	lw	$4,8($2)
	lw	$2,4($fp)
	nop
	mult	$4,$2
	lw	$2,8($fp)
	mflo	$4
	addu	$2,$4,$2
	sll	$2,$2,2
	addu	$2,$3,$2
	add.s	$f0,$f2,$f0
	swc1	$f0,0($2)
	lw	$2,12($fp)
	nop
	addiu	$2,$2,1
	sw	$2,12($fp)
$L50:
	lw	$2,28($fp)
	nop
	lw	$2,8($2)
	lw	$3,12($fp)
	nop
	slt	$2,$3,$2
	bne	$2,$0,$L51
	nop

	lw	$2,8($fp)
	nop
	addiu	$2,$2,1
	sw	$2,8($fp)
$L49:
	lw	$2,24($fp)
	nop
	lw	$2,8($2)
	lw	$3,8($fp)
	nop
	slt	$2,$3,$2
	bne	$2,$0,$L52
	nop

	lw	$2,4($fp)
	nop
	addiu	$2,$2,1
	sw	$2,4($fp)
$L48:
	lw	$2,24($fp)
	nop
	lw	$2,4($2)
	lw	$3,4($fp)
	nop
	slt	$2,$3,$2
	bne	$2,$0,$L53
	nop

	move	$2,$0
$L47:
	move	$sp,$fp
	lw	$fp,20($sp)
	addiu	$sp,$sp,24
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	div_matrix
	.size	div_matrix, .-div_matrix
	.align	2
	.globl	mult_scal_matrix
	.set	nomips16
	.set	nomicromips
	.ent	mult_scal_matrix
	.type	mult_scal_matrix, @function
mult_scal_matrix:
	.frame	$fp,16,$31		# vars= 8, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-16
	sw	$fp,12($sp)
	move	$fp,$sp
	sw	$4,16($fp)
	sw	$5,20($fp)
	sw	$0,0($fp)
	.option	pic0
	b	$L55
	nop

	.option	pic2
$L58:
	sw	$0,4($fp)
	.option	pic0
	b	$L56
	nop

	.option	pic2
$L57:
	lw	$2,16($fp)
	nop
	lw	$3,0($2)
	lw	$2,16($fp)
	nop
	lw	$4,8($2)
	lw	$2,0($fp)
	nop
	mult	$4,$2
	lw	$2,4($fp)
	mflo	$4
	addu	$2,$4,$2
	sll	$2,$2,2
	addu	$2,$3,$2
	lwc1	$f2,0($2)
	lw	$2,16($fp)
	nop
	lw	$3,0($2)
	lw	$2,16($fp)
	nop
	lw	$4,8($2)
	lw	$2,0($fp)
	nop
	mult	$4,$2
	lw	$2,4($fp)
	mflo	$4
	addu	$2,$4,$2
	sll	$2,$2,2
	addu	$2,$3,$2
	lwc1	$f0,20($fp)
	nop
	mul.s	$f0,$f2,$f0
	swc1	$f0,0($2)
	lw	$2,4($fp)
	nop
	addiu	$2,$2,1
	sw	$2,4($fp)
$L56:
	lw	$2,16($fp)
	nop
	lw	$2,8($2)
	lw	$3,4($fp)
	nop
	slt	$2,$3,$2
	bne	$2,$0,$L57
	nop

	lw	$2,0($fp)
	nop
	addiu	$2,$2,1
	sw	$2,0($fp)
$L55:
	lw	$2,16($fp)
	nop
	lw	$2,4($2)
	lw	$3,0($fp)
	nop
	slt	$2,$3,$2
	bne	$2,$0,$L58
	nop

	nop
	nop
	move	$sp,$fp
	lw	$fp,12($sp)
	addiu	$sp,$sp,16
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	mult_scal_matrix
	.size	mult_scal_matrix, .-mult_scal_matrix
	.align	2
	.globl	div_scal_matrix
	.set	nomips16
	.set	nomicromips
	.ent	div_scal_matrix
	.type	div_scal_matrix, @function
div_scal_matrix:
	.frame	$fp,16,$31		# vars= 8, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-16
	sw	$fp,12($sp)
	move	$fp,$sp
	sw	$4,16($fp)
	sw	$5,20($fp)
	lwc1	$f0,20($fp)
	mtc1	$0,$f2
	nop
	c.eq.s	$f0,$f2
	nop
	bc1f	$L60
	nop

	li	$2,-1			# 0xffffffffffffffff
	.option	pic0
	b	$L61
	nop

	.option	pic2
$L60:
	sw	$0,0($fp)
	.option	pic0
	b	$L62
	nop

	.option	pic2
$L65:
	sw	$0,4($fp)
	.option	pic0
	b	$L63
	nop

	.option	pic2
$L64:
	lw	$2,16($fp)
	nop
	lw	$3,0($2)
	lw	$2,16($fp)
	nop
	lw	$4,8($2)
	lw	$2,0($fp)
	nop
	mult	$4,$2
	lw	$2,4($fp)
	mflo	$4
	addu	$2,$4,$2
	sll	$2,$2,2
	addu	$2,$3,$2
	lwc1	$f2,0($2)
	lw	$2,16($fp)
	nop
	lw	$3,0($2)
	lw	$2,16($fp)
	nop
	lw	$4,8($2)
	lw	$2,0($fp)
	nop
	mult	$4,$2
	lw	$2,4($fp)
	mflo	$4
	addu	$2,$4,$2
	sll	$2,$2,2
	addu	$2,$3,$2
	lwc1	$f0,20($fp)
	nop
	div.s	$f0,$f2,$f0
	swc1	$f0,0($2)
	lw	$2,4($fp)
	nop
	addiu	$2,$2,1
	sw	$2,4($fp)
$L63:
	lw	$2,16($fp)
	nop
	lw	$2,8($2)
	lw	$3,4($fp)
	nop
	slt	$2,$3,$2
	bne	$2,$0,$L64
	nop

	lw	$2,0($fp)
	nop
	addiu	$2,$2,1
	sw	$2,0($fp)
$L62:
	lw	$2,16($fp)
	nop
	lw	$2,4($2)
	lw	$3,0($fp)
	nop
	slt	$2,$3,$2
	bne	$2,$0,$L65
	nop

	move	$2,$0
$L61:
	move	$sp,$fp
	lw	$fp,12($sp)
	addiu	$sp,$sp,16
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	div_scal_matrix
	.size	div_scal_matrix, .-div_scal_matrix
	.rdata
	.align	2
$LC1:
	.word	1065353216
	.ident	"GCC: (Ubuntu 10.3.0-1ubuntu1) 10.3.0"
	.section	.note.GNU-stack,"",@progbits
