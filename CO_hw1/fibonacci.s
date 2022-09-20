.data
ask:	.asciiz "Please input a number: "

.text
.globl main

main:
	li	$v0, 4
	la	$a0, msg1
	syscall
	
	li	$v0, 5
	syscall
	
	move	$t0, $v0
	
	li	$t1, 0
	li	$t2, 1
	li	$t3, 0
	li	$t4, 1
	
	beq	$t0, 0, print0
	beq	$t0, 1, print1
	
loop:
	add	$t3, $t1, $t2
	move	$t1, $t2
	move	$t2, $t3
	addi	$t4, $t4, 1
	beq	$t4, $t0, print
	j	loop
		
print:
	move	$a0, $t2
	li	$v0, 1
	syscall
	j	Exit
	
print0:	
	li	$a0, 0
	li	$v0, 1
	syscall
	j	Exit
	
print1:	
	li	$a0, 1
	li	$v0, 1
	syscall
	j	Exit
	
Exit:
	li	$v0, 10
	syscall