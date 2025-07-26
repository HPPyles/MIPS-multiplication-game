# Player turn

.data
playerClaimed: .space 144
numAdisplay: .asciiz "\nNumber A: "
numBdisplay: .asciiz "\nNumber B: "
newLine: .asciiz "\n"
selectFactor: .asciiz "Type 1 to change factor A and 2 to change factor B: "
newFactor: .asciiz "Type a number from 1-9 to change the factor: "
error: .asciiz "ERROR, playerTurn.asm, $a2 not defined properly"
debug1: .asciiz "-debug1- "
debug2: .asciiz "-debug2- "
debug3: .asciiz "-debug3- "

# s0 is ***Factor 1***
# s1 is ***Factor 2***

.text
.globl playerTurn

playerTurn:
	beq $a2, 0, play
	beq $a2, 1, searchPClaim
	#If code goes past this in this function something is wrong, show error message
	li $v0, 4
	la $a0, error
	syscall
	
	jr $ra

play:
	subu $sp, $sp, 4
	sw $ra,0($sp)
	jal displayFactors
	
	# /n
	li $v0, 4
	la $a0, newLine
	syscall
	
	#Prompt
	li $v0, 4
	la $a0, selectFactor
	syscall
	# Get choice in factor to change
inputOne:
	li $v0, 12
	syscall
	addi $v0, $v0, -48
	blt $v0, 1, inputOne
	bgt $v0, 2, inputOne
	# Store choice in temp register
	move $t0, $v0 # ***t0 holding choice of A or B***
	
	# /n
	li $v0, 4
	la $a0, newLine
	syscall
	
	# Prompt for new factor
	li $v0, 4
	la $a0, newFactor
	syscall
	# Get new factor
inputTwo:
	li $v0, 12
	syscall
	addi $v0, $v0, -48
	
	blt $v0, 1, inputTwo
	bgt $v0, 9, inputTwo
	
	# Move new number into selected factor
	beq $t0, 1, changeA # If choice is A, go to changeA
	beq $t0, 2, changeB # If choice is B, go to changeB

# Store claimed value in player claims array
numberChange:
	mul $s5, $s0, $s1 # Multiply the factors, ***s5 holds the product***
	
	move $t1, $s5 # use $t1 in order to save result for search trigger
	
	# ***s4 is the Index of player spaces array***
	sb $t1, playerClaimed($s4) # Put product in array
	addi $s4, $s4, 4

# Retrieve previous location in file from stack pointer and return
return_main:
	lw $ra,0($sp)
	addi $sp, $sp, 4
	
	jr $ra

changeA:
	move $s0, $v0
	j numberChange

changeB:
	move $s1, $v0
	j numberChange

displayFactors:
	# Number A: 
	li $v0, 4
	la $a0, numAdisplay
	syscall
	# Current factor 1
	li $v0, 1
	move $a0, $s0
	syscall
	
	# Number B: 
	li $v0, 4
	la $a0, numBdisplay
	syscall
	# Current factor 2
	li $v0, 1
	move $a0, $s1
	syscall
	# New line
	li $v0, 4
	la $a0, newLine
	syscall
	
	jr $ra

return: 
	jr $ra

#Search array of spaces claimed by player
# ***s4 is the Index of player spaces array***
# ***s5 holds the product***
# ***t5 holds currently checked value of claimed array***
searchPClaim:
	li $t6, 0 # ***t6 is temp index for moving through search***
	subu $s4, $s4, 4 # $s4 is always prepared for next value, need to move back to last initialized

searchLoop:
	lw $t7, ($sp) # Copy saved value for current overall array value into $t7
	
	# USER HAS CLAIMED NOTHING
	beq $s5, 0, return_display # Go straight to return bc nothing has been pulled from array
	
	# Once player has claimed a space
	lb $t5, playerClaimed($t6) #set temp to value in claimed array at temp index
	
	beq $t5, $t7, found # If $t5 = $t7[which is $t4] -> wrapUp; If argument equals current value of claimed array, go to found
	
	beq $t6, $s4, wrapUp # if the temp index equals the current player claim index, return to previous file
	
	sb $t5, playerClaimed($t6) # Put current value of claimed array back
	addi $t6, $t6, 4 # increment temp index
	j searchLoop # loop

found:
	li $a1, 1

wrapUp:
	sb $t5, playerClaimed($t6) # Put current value of claimed array back
	
return_display:
	addi $s4, $s4, 4 # Reset $s4 to being prepared for next run of play
	jr $ra
