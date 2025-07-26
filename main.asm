#Main

.data
size: .word 36
title: .asciiz "\n===================\nMULTIPLICATION GAME\n==================="
intro: .asciiz "\nInstructions:\n* Use your multiplication facts to beat the computer.\n* You and the computer take turns changing one number factor at a time.\n* Get 4 in a row before the computer and you win.\n"
promptStart: .asciiz "\nPress any key to start: "
newLine: .asciiz "\n"
debugWin: .asciiz "You won!"
debugLose: .asciiz "You lost!"

.text
.globl main

main:
set_up:
	li $s0, 1 # s0 is ***Factor 1***
	li $s1, 1 # s1 is ***Factor 2***
	
	# I actually might not need this, last saved reg i can free up
	lw $s3, size # Size of rows/columns
	
	# Note you DO need to use s registers so you can declare them out here
	addi $s5, $zero, 0 # ***s5 holds the player product***
	addi $s7, $zero, 0 # ***s7 holds the enemy product***
	
	addi $s4, $zero, 0 # ***s4 is the index for player claims***
	addi $s6, $zero, 0 # ***s6 is the index for enemy claims***
	
	li $a1, 0 # Trigger for marking player claims

gameStart:
	# Title and instructions
	#li $v0, 4
	#la $a0, title
	#syscall
	
	jal display # Call display
	
	li $v0, 4
	la $a0, intro
	syscall
	
	# User input to start
	li $v0, 4
	la $a0, promptStart
	syscall
	li $v0, 12
	syscall

# ***a3 will mark a win*** 0 = no win, 1 = player win, 2 = computer win
gameLoop:
	# /n
	li $v0, 4
	la $a0, newLine
	syscall
	
	# Win Check
	jal winCheckRow
	jal winCheckVertical
	beq $a3, 1, playerWin
	beq $a3, 2, computerWin
	
	# Enemy turn
	li $a2, 0 # ***a2 is argument determining that player turn will be run instead of search player claims***
	jal enemyTurn
	# /n
	li $v0, 4
	la $a0, newLine
	syscall
	jal display
	
	# Win Check
	jal winCheckRow
	jal winCheckVertical
	beq $a3, 1, playerWin
	# /n
	li $v0, 4
	la $a0, newLine
	syscall
	beq $a3, 2, computerWin
	
	# Player turn
	li $a2, 0 # ***a2 is argument determining that player turn will be run instead of search player claims***
	jal playerTurn
	
	j gameLoop

playerWin:
	jal display # Call display
	
	li $v0, 4
	la $a0, debugWin
	syscall
	
	j endGame

computerWin:
	li $v0, 4
	la $a0, debugLose
	syscall
	
	j endGame

endGame:
	# Exit program
	li $v0, 10
	syscall
