# Multiplication Game

.data
numbers: .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 15, 16, 18, 20, 21, 24, 25, 27, 28, 30, 32, 35, 36, 40, 42, 45, 48, 49, 54, 56, 63, 64, 72, 81
title: .asciiz "\n===================\nMULTIPLICATION GAME\n==================="
rowBorder: .asciiz "\n+----+----+----+----+----+----+\n"
edgeLeft: .asciiz "| "
edgeRight: .asciiz " |"
edgeRightLTen: .asciiz "  |"
inbetween: .asciiz " | "
inbtnLessTen:.asciiz "  | "
newLine: .asciiz "\n"
playerMarker: .asciiz "PL"
enemyMarker: .asciiz "EN"
debug1: .asciiz "-debug1- "
debug2: .asciiz "-debug2- "

temp: .word

.text
.globl display

# ---DISPLAY START---
# ***$t4 holds current array value***
# Can't use $t5-$t7 here bc search is being called
display: 
	li $t2, 0 # Outer counter
	li $t3, 0 # Border trigger
	
	# Title again
	li $v0, 4
	la $a0, title
	syscall
	
	# Line separating rows
	li $v0, 4
	la $a0, rowBorder
	syscall
	
	la $s2, numbers # Load array
	# Put first value of array in $t4
	lw $t4, 0($s2) # ***$t4 holds current array value***

loop_outer:
	bge $t2, 6, return_main # If outer counter reaches 6
	li $t1, 0 # Set inner counter to 0 each loop
	
loop_inner:
	beq $t1, $t3, left_edge # First loop, jump to left edge
	bge $t1, 6, border_row # Last loop, jump to right edge
	
	li $a1, 0 # Reset a1
	
	# NEED TO SAVE $ra and $t4 WITH STACK POINTER
	subu $sp, $sp, 8
	sw $t4,0($sp)
	sw $ra,4($sp)
	
	li $a2,1 # Argument 2: Signal that search program is needed
	jal playerTurn # Search: Return 1 (in $a1) if current value claimed by player
	jal enemyTurn # Search: Return 2 (in $a1) if current value claimed by computer
	
	sw $t7,0($sp) # Retrieve temp value of array holder
	lw $t4,0($sp) # Put it back into $t4
	lw $ra,4($sp) # Get address in main back
	addi $sp, $sp, 8 # Reset stack pointer
	
	beq $a1, 1, claimedP # Print player marker if triggered
	beq $a1, 2, claimedE # Print enemy marker if triggered
	
	# Print currently selected number
	li $v0, 1
	move $a0, $t4
	syscall
# Break so printing current number can be skipped
continue:
	addi $s2, $s2, 4 # Move to next in numbers array
	lw $t4, 0($s2) # Load next array value into $t4
	addi $t1, $t1, 1 # Increment counter
	
	beq $t1, $t3, right_edge # Print right edge line of row
	bge $t1, 6, border_row # print row border between rows
	
	# If number is less than 10, use different seperator
	blt $t4, 11, lessThanTen
contSeparate: # Another break to skip lessThanTen conditional
	# Put " | " between each number
	li $v0, 4
	la $a0, inbetween
	syscall
	
	li $a1, 0 # Reset marker trigger
	j loop_inner

border_row:
	li $v0, 4
	la $a0, rowBorder
	syscall

next_outer:
	addi $t2, $t2, 1 # increment outer counter
	li $a1, 0 # Reset player marker trigger
	j loop_outer #loop

left_edge:
	#print left edge
	li $v0, 4
	la $a0, edgeLeft
	syscall
	
	addi $t3, $t3, 6 # Prepare for right edge
	
	j loop_inner

right_edge:
	# If number is less than 10, use different edge
	blt $t4, 11, rightEdgeLessTen
redgCont: #Gap in order to skip rightEdgeLessTen
	#Print " |" to make the right border of the row
	li $v0, 4
	la $a0, edgeRight
	syscall
	
	subi , $t3, $t3, 6 # Reset for next row's left edge
	
	j loop_inner

rightEdgeLessTen:
	bge $a1, 1, redgCont # If printing player marker ignore rightEdgeLessTen
	#Print "  |" to make the right border of the row
	li $v0, 4
	la $a0, edgeRightLTen
	syscall
	
	subi , $t3, $t3, 6 # Reset for next row's left edge
	
	j loop_inner

lessThanTen:
	bge $a1, 1, contSeparate # If printing marker ignore lessThanTen
	
	li $v0, 4
	la $a0, inbtnLessTen
	syscall
	
	j loop_inner

# If player has claimed the value
claimedP:
	#Print player marker
	la $a0, playerMarker
	li $v0, 4
	syscall
	#Jump back to display but skip printing number
	j continue

# If player has claimed the value
claimedE:
	#Print enemy marker
	la $a0, enemyMarker
	li $v0, 4
	syscall
	#Jump back to display but skip printing number
	j continue

return_main:
	la $s2, numbers # Reset for use in other files
	jr $ra
