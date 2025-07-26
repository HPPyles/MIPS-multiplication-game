# Computer turn

.data
enemyClaimed: .space 144
numAdisplay: .asciiz "\nNumber A: "
numBdisplay: .asciiz "\nNumber B: "
newLine: .asciiz "\n"
error: .asciiz "ERROR, playerTurn.asm, $a2 not defined properly"
debug1: .asciiz "-debug1- "
debug2: .asciiz "-debug2- "
debug3: .asciiz "-debug3- "

# s0 is ***Factor 1***
# s1 is ***Factor 2***

.text
.globl enemyTurn

enemyTurn:
	beq $a2, 0, enemyLogic
	beq $a2, 1, searchEClaim
	#If code goes past this in this function something is wrong, show error message
	li $v0, 4
	la $a0, error
	syscall
	
	jr $ra

# ***t2 holds what to change A or B to (X)***
# s0 is ***Factor 1/A***
# s1 is ***Factor 2/B***
enemyLogic:
	# ---DISPLAY FACTORS---
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
	# ---DISPLAY FACTORS---
	
	li $t2, 1 # Start X at 1
	li $t3, 0 # temp value for checking for valid spots

decideBLoop:
	# +++COMPUTER LOGIC HERE+++
	# What are we doing:
	# A * X(starts at 1)
	mul $t3, $s0, $t2
	# Is A * X claimed by anyone?
	# +++CHECK FOR MARKERS START+++ 
	li $a1, 0 # Reset claim marker
	
	subu $sp, $sp, 8 # NEED TO SAVE $ra and $t3 WITH STACK POINTER
	sw $t3,0($sp)
	sw $ra,4($sp)
	
	li $a2,1 # Argument 2: Signal that search program is needed
	jal playerTurn # Search: Return 1 (in $a1) if current value claimed by player
	# Search enemy claims can be called directly since its in the same file
	jal searchEClaim # Search: Return 2 (in $a1) if current value clamed by computer
	
	sw $t7,0($sp) # Retrieve temp value of array holder
	lw $t3,0($sp) # Put it back into $t3
	lw $ra,4($sp) # Get address in main back
	addi $sp, $sp, 8 # Reset stack pointer
	# +++CHECK FOR MARKERS END+++
	
	# If not, B = X
	beq $a1, 0, changeB
	# Else
	# If X == 9 (reached end of number line), jump to deciding A
	beq $t2, 9, startADecide
	# else (A * X not claimed and X!=9): X + 1, loop
	addi $t2, $t2, 1
	j decideBLoop

startADecide:
	li $t2, 1 # X starts at 1

decideALoop:
	# next section:
	# B * X(starts at 1)
	mul $t3, $s1, $t2
	# Is B * X claimed by anyone?
	# +++CHECK FOR MARKERS START+++ 
	li $a1, 0 # Reset claim marker
	
	subu $sp, $sp, 8 # NEED TO SAVE $ra and $t3 WITH STACK POINTER
	sw $t3,0($sp)
	sw $ra,4($sp)
	
	li $a2,1 # Argument 2: Signal that search program is needed
	jal playerTurn # Search: Return 1 (in $a1) if current value claimed by player
	# Search enemy claims can be called directly since its in the same file
	jal searchEClaim # Search: Return 2 (in $a1) if current value clamed by computer
	
	sw $t7,0($sp) # Retrieve temp value of array holder
	lw $t3,0($sp) # Put it back into $t3
	lw $ra,4($sp) # Get address in main back
	addi $sp, $sp, 8 # Reset stack pointer
	# +++CHECK FOR MARKERS END+++
	
	# If not, A = X
	beq $a1, 0, changeA
	# Else
	# If X == 9 (reached end of number line), jump to numberChange(?) (needs to break out loop to wherever works)
	beq $t2, 9, numberChange # Actually if it makes it to this point then there's probably a tie lol
	# else (B * X not claimed and X!=9): X + 1, loop
	addi $t2, $t2, 1
	j decideALoop
	
	# +++COMPUTER LOGIC HERE+++

# Store claimed value in player claims array
numberChange:
	mul $s7, $s0, $s1 # Multiply the factors, ***s7 holds the product***
	
	# use $t1 in order to save result for search trigger
	move $t1, $s7 # $t1 repurposed to copy and preserve $s7
	
	# ***s6 is the Index of player spaces array***
	sb $t1, enemyClaimed($s6) # Put product in array
	addi $s6, $s6, 4

# return
return: 
	jr $ra

# ***t2 holds what to change A or B to (X)***
# s0 is ***Factor 1/A***
# s1 is ***Factor 2/B***
changeA:
	move $s0, $t2
	j numberChange

changeB:
	move $s1, $t2
	j numberChange

#Search array of spaces claimed by player
# ***s6 is the Index of player spaces array***
# ***s7 holds the product***
# ***t5 holds currently checked value of claimed array***
searchEClaim:
	li $t6, 0 # ***t6 is temp index for moving through search***
	subu $s6, $s6, 4 # move index back 1

searchLoop:
	lw $t7, ($sp) # Copy saved value for current overall array value into $t7
	
	# USER HAS CLAIMED NOTHING
	beq $s7, 0, return_display # Go straight to return bc nothing has been pulled from array
	
	# Once player has claimed a space
	lb $t5, enemyClaimed($t6) #set temp to value in claimed array at temp index
	
	beq $t5, $t7, found # If $t5 = $t7[which is $t4] -> wrapUp; If argument equals current value of claimed array, go to found
	
	beq $t6, $s6, wrapUp # if the temp index equals the current player claim index, return to previous file
	
	sb $t5, enemyClaimed($t6) # Put current value of claimed array back
	addi $t6, $t6, 4 # increment temp index
	j searchLoop # loop

found:
	li $a1, 2

wrapUp:
	sb $t5, enemyClaimed($t6) # Put current value of claimed array back
	
return_display:
	addi $s6, $s6, 4 # move back to where index was
	jr $ra
