# Check for win

.data
numbers: .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 15, 16, 18, 20, 21, 24, 25, 27, 28, 30, 32, 35, 36, 40, 42, 45, 48, 49, 54, 56, 63, 64, 72, 81
debug1: .asciiz "-debug1- "
debug2: .asciiz "-debug2- "
debug3: .asciiz "-debug3- "

.text
.globl winCheckd2

# ***$t1 holds current array value***
# ***$a1 holds results of searches***
# Can't use $t5-$t7 here bc search is being called
# none available
winCheckd2:	
	li $a3, 0 # Here, ***a3 will mark a win*** 0 = no win, 1 = player win, 2 = computer win
	li $a1, 0 # ***$a1 marks claimed spots*** make sure its set up properly before starting
	li $t0, 5 # ***t0 marks beginning of each diagTwo***
	li $t1, 0 # ***t1 holds current array value***
	li $t2, 0 # If this gets to 4, the player wins
	li $t3, 0 # If this gets to 4, the computer wins
	li $t4, 0 #  If the code moves to border at any point without winning, next
	li $t8, 0 # Inner counter
	li $t9, 0 # Outer counter

# +++ CHECKING ALL POSSIBLE DIAGONAL (FIRST) WINS+++
# Check beginning of diagonal, then next 3 values. Do the same for one or both of the next 2 values. Jump to beginning of next diagTwo.
# Repeat until out of diagonal
diagTwoCheck: 
	la $s2, numbers # Start pointer at beginning of array
	addi $s2, $s2, 5 # Need to start checks at end of row
	lw $t1, 0($s2) # Start at 6 array value
	
diagTwoLoop: 
	beq $a1, 1, diagTwoMorePCheck
	beq $a1, 2, diagTwoMoreECheck
	
	li $t2, 0 # If we go here, then the value checked wasn't a marker, so reset
	li $t3, 0 # If we go here, then the value checked wasn't a marker, so reset
	
	# +++CHECK FOR MARKERS START+++ 
	li $a1, 0 # Reset a1
	
	subu $sp, $sp, 8 # NEED TO SAVE $ra and $t1 WITH STACK POINTER
	sw $t1,0($sp)
	sw $ra,4($sp)
	
	li $a2,1 # Argument 2: Signal that search program is needed
	jal playerTurn # Search: Return 1 (in $a1) if current value claimed by player
	jal enemyTurn # Serach: Return 2 (in $a1) if current value clamed by computer
	
	sw $t7,0($sp) # Retrieve temp value of array holder
	lw $t1,0($sp) # Put it back into $t1
	lw $ra,4($sp) # Get address in main back
	addi $sp, $sp, 8 # Reset stack pointer
	# +++CHECK FOR MARKERS END+++
	
	addi $t8, $t8, 1 # Increment inner counter
	
	beq $a1, 1, diagTwoMorePCheck # If player marker found in diagonal,
	beq $a1, 2, diagTwoMoreECheck # If enemy marker found in diagonal, 
	
	addi $s2, $s2, 25 # Next in diagonal
	lw $t1, 0($s2)
	bge $t1, 35, returnMain
	addi $t4, $t4, 1 # moved down 1  
	bge $t4, 7, nextDiagTwo # If we've already checked 6 values, move to next 
	
	bge $t8, 3, nextDiagTwo
	j diagTwoLoop

nextDiagTwo:
	beq $t9, 6, returnMain # if outer counter = 6, end
	addi $t9, $t9, 1 # increment outer counter
	
	addi $t0, $t0, -1 # Start of diagTwo marker moved to next diagTwo index
	la $s2, numbers # Reset $s2 to beginning of array
	add $s2, $s2, $t0 # Move $s2 to current start of diagTwo pointer
	lw $t1,0($s2) # t1 is value at beginning of the diagTwo
	li $t4, 0
	
	li $t8, 0 # Reset inner counter
	
	j diagTwoLoop

diagTwoMorePCheck:
	addi $t2, $t2, 1 # Player claim found
	beq $t2, 4, playerWinFound # Four in a row, player wins!
	
	addi $s2, $s2, 25 # Next value in diagTwo
	lw $t1, 0($s2) # put current array value in $t1
	addi $t4, $t4, 1 # moved down 1  
	bge $t4, 7, nextDiagTwo # If we've already checked 6 values, move to next 
	
	# Check if next value has player marker
	# +++CHECK FOR MARKERS START+++ 
	li $a1, 0 # Reset a1
	
	subu $sp, $sp, 8 # NEED TO SAVE $ra and $t1 WITH STACK POINTER
	sw $t1,0($sp)
	sw $ra,4($sp)
	
	li $a2,1 # Argument 2: Signal that search program is needed
	jal playerTurn # Search: Return 1 (in $a1) if current value claimed by player
	jal enemyTurn # Serach: Return 2 (in $a1) if current value clamed by computer
	
	sw $t7,0($sp) # Retrieve temp value of array holder
	lw $t1,0($sp) # Put it back into $t1
	lw $ra,4($sp) # Get address in main back
	addi $sp, $sp, 8 # Reset stack pointer
	# +++CHECK FOR MARKERS END+++
	
	addi $t8, $t8, 1
	
	beq $a1, 1, diagTwoMorePCheck # If the next value has player marker, check value after that for continuation
	#else
	addi $s2, $s2, 25 # Change to next value in diagTwo
	lw $t1, 0($s2)
	addi $t4, $t4, 1 # moved down 1  
	bge $t4, 7, nextDiagTwo # If we've already checked 6 values, move to next 
	
	bge $t8, 3, nextDiagTwo # Go to next diagTwo if finishing check from 3rd starting point in diagTwo
	j diagTwoLoop

diagTwoMoreECheck: 
	addi $t3, $t3, 1 # Computer claim found
	beq $t3, 4, enemyWinFound # Four in a row, player loses
	
	addi $s2, $s2, 25 # Next value in row
	lw $t1, 0($s2) # put current array value in $t1
	addi $t4, $t4, 1 # moved down 1  
	bge $t4, 7, nextDiagTwo # If we've already checked 6 values, move to next 
	
	# Check if next value has enemy marker
	# +++CHECK FOR MARKERS START+++ 
	li $a1, 0 # Reset a1
	
	subu $sp, $sp, 8 # NEED TO SAVE $ra and $t1 WITH STACK POINTER
	sw $t1,0($sp)
	sw $ra,4($sp)
	
	li $a2,1 # Argument 2: Signal that search program is needed
	jal playerTurn # Search: Return 1 (in $a1) if current value claimed by player
	jal enemyTurn # Serach: Return 2 (in $a1) if current value clamed by computer
	
	sw $t7,0($sp) # Retrieve temp value of array holder
	lw $t1,0($sp) # Put it back into $t1
	lw $ra,4($sp) # Get address in main back
	addi $sp, $sp, 8 # Reset stack pointer
	# +++CHECK FOR MARKERS END+++
	
	addi $t8, $t8, 1
	
	beq $a1, 2, diagTwoMoreECheck # If the next value has enemy marker, check value after that for continuation
	
	addi $s2, $s2, 25 # Change to next value in diagTwo
	lw $t1, 0($s2)
	addi $t4, $t4, 1 # moved down 1  
	bge $t4, 7, nextDiagTwo # If we've already checked 6 values, move to next 
	
	bge $t8, 3, nextDiagTwo # Go to next diagTwo if finishing check from 3rd starting point in diagTwo
	j diagTwoLoop

playerWinFound:
	li $a3, 1 # Mark player win
	jr $ra

enemyWinFound:
	li $a3, 2 # Mark computer win
	jr $ra

returnMain:
	jr $ra
