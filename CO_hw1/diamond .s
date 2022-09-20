.data
ask:			.asciiz "Please input a number: "
space:			.asciiz " "
star:			.asciiz "*"
new:			.asciiz "\n"

.text
.globl main

main:
	li		$v0, 4
	la		$a0, ask
	syscall
	
	li		$v0, 5
	syscall
	
	or		$s0, $v0, $zero
	li		$t0, 1
	or		$s1, $zero, $zero

outloop1:
	slt		$t1, $s0, $t0
	bne		$t1, $zero, nextloop
	li		$t1, 1

inloop:
	sub		$t2, $s0, $t0
	slt		$t3, $t2, $t1
	beq		$t3, $zero, printspace
	addi 		$t1, $t2, 1

in2loop:
	add		$t4, $s0, $t0
	slt		$t3, $t1, $t4
	bne		$t3, $zero, printstar
	jal		newline
	bne		$s1, $zero, forsec
	addi 		$t0, $t0, 1
	j		outloop1

forsec:
	addi		$t0, $t0, -1
	j 		outloop2

nextloop:
	subi		$t0, $s0, 1
	addi		$s1, $s1, 1

outloop2: 
	slti		$t3, $t0, 1
	bne		$t3, $zero, Exit
	li		$t1, 1
	j		inloop

newline:
	li		$v0, 4
	la		$a0, new
	syscall 
	jr		$ra
	
printstar:
	li		$v0, 4
	la		$a0, star
	syscall
	addi		$t1, $t1, 1
	j		in2loop

printspace:
	li		$v0, 4
	la		$a0, space
	syscall
	addi		$t1, $t1, 1
	j		inloop	

Exit:
	li		$v0, 10
	syscall
