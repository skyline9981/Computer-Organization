.data
ask:	.asciiz "Please input a number: "
true:	.asciiz "It's a prime\n"
false:	.asciiz "It's not a prime\n"

.text
.globl main

main:
	li		$v0, 4
	la		$a0, ask
	syscall
	
	li		$v0, 5
	syscall
	
	move		$t0, $v0
	li		$t1, 2
	
	blt		$t0, 1, no
	beq		$t0, 1, no
	beq		$t0, 2, yes
	
	
prime:	
	beq		$t1, $t0, yes
	div		$t0, $t1
	mfhi		$t2
	beq		$t2, $zero, no
	addi		$t1, $t1, 1

	j		prime
	
yes:	
	li		$v0, 4
	la		$a0, true
	syscall
	
	j		Exit
	
no:
	li		$v0, 4
	la		$a0, false
	syscall
	
	j		Exit
	
Exit:	
	li		$v0, 10
	syscall

