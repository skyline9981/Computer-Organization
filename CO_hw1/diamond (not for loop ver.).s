.data
msg1:		.asciiz "Please input a number: "
printspace:	.asciiz " "
printstar:		.asciiz "*"
new:		.asciiz "\n"

.text
.globl main

main:
	li	$v0, 4
	la	$a0, msg1
	syscall
	
	li	$v0, 5
	syscall
	
	move 	$a1, $v0		#store input
	move	$t0, $a1		#num of space
	li		$t1, 1			#num of star
	li		$t2, -1			#count the line for space
	li		$t3, 2			#count the line for star 
	li		$t5, 0			#do not print "\n" in the first line

.text
newline:
	move	$t4, $t0			#copy the input for the new line
	beq		$t5, $zero, space	#do not print "\n" in the first line
	li		$v0, 4
	la		$a0, new
	syscall 

space:
	li		$v0, 4
	la		$a0, printspace
	syscall
	
	sub		$t4, $t4, 1		
	bne		$t4, $zero, space
	move	$t4, $t1
	
star:
	li	$v0, 4
	la	$a0, printstar
	syscall
	
	add	$t5, $t5, 1
	sub	$t4, $t4, 1
	bne	$t4, $zero, star
	add	$t0, $t0, $t2
	add	$t1, $t1, $t3
	beq	$t1, -1, Exit
	bne	$t0, 1, newline
	li	$t2, 1
	li	$t3, -2
	beq	$t1, 1, Exit
	j	newline

Exit:
	li	$v0, 10
	syscall