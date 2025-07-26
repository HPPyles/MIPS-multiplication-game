# Check for win

.data
numbers: .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 15, 16, 18, 20, 21, 24, 25, 27, 28, 30, 32, 35, 36, 40, 42, 45, 48, 49, 54, 56, 63, 64, 72, 81
debug1: .asciiz "-debug1- "
debug2: .asciiz "-debug2- "
debug3: .asciiz "-debug3- "

.text
.globl winCheckRow

# ***$t1 holds current array value***
# ***$a1 holds results of searches***
# Can't use $t5-$t7 here bc search is being called
# no registers available
winCheckRow:	
	li $a3, 0 # Here, ***a3 will mark a win*** 0 = no win, 1 = player win, 2 = computer win
	li $a1, 0 # ***$a1 marks claimed spots*** make sure its set up properly before starting
	li $t0, 0 # ***t0 marks beginning of each row***
	li $t1, 0
	li $t2, 0 # If this gets to 4, the player wins
	li $t3, 0 # If this gets to 4, the computer wins
	li $t4, 0 # If the code moves to the end of the row at any point without winning, next row
	li $t8, 0 # Inner counter
	li $t9, 0 # Outer counter

# +++ CHECKING ALL POSSIBLE ROW WINS+++
# Check beginning of row, then next 3 values. Do the same for one or both of the next 2 values. Jump to beginning of next row. Repeat until out of rows
rowCheck: 
	# Note: I don't need to reload the array every time, I just need to reset my pointer($s2) !!!REMEMBER TO DO THIS OR YOU CANT RUN THIS MORE THAN ONCE!!!
	la $s2, numbers # Start pointer at beginning of array
	lw $t1, 0($s2) # Start at 1st array value
	
rowLoop: # If there's no markers in the first 3 values in the row: Loop 1, check, loop 2, move to next in row(2), check, loop 3, move to next in row(3), check, jump to next row (+4)
	beq $a1, 1, rowMorePCheck # If player marker found in row, check for another next to it
	beq $a1, 2, rowMoreECheck # If enemy marker found in row, check for another next to it
	
	li $t2, 0 # If we go here, then the value checked wasn't a marker, so reset
	li $t3, 0 # If we go here, then the value checked wasn't a marker, so reset
	
	# +++CHECK FOR MARKERS START+++ 
	li $a1, 0 # Reset a1
	
	subu $sp, $sp, 8 # NEED TO SAVE $ra and $t1 WITH STACK POINTER
	sw $t1,0($sp)
	sw $ra,4($sp)
	
	li $a2,1 # Argument 2: Signal that search program is needed
	jal playerTurn # Search: Return 1 (in $a1) if current value claimed by player
	jal enemyTurn # Search: Return 2 (in $a1) if current value clamed by computer
	
	sw $t7,0($sp) # Retrieve temp value of array holder
	lw $t1,0($sp) # Put it back into $t1
	lw $ra,4($sp) # Get address in main back
	addi $sp, $sp, 8 # Reset stack pointer
	# +++CHECK FOR MARKERS END+++
	
	addi $t8, $t8, 1 # Increment inner counter
	
	beq $a1, 1, rowMorePCheck # If player marker found in row, check for another next to it
	beq $a1, 2, rowMoreECheck # If enemy marker found in row, check for another next to it
	
	addi $s2, $s2, 4 # Next in array
	lw $t1,0($s2)
	addi $t4, $t4, 1 # moved down 1 in row
	bge $t4, 7, nextRow # If we've already checked 6 values, move to next row
	
	bge $t8, 3, nextRow # After 3 loops, go to next row
	j rowLoop

nextRow:
	beq $t9, 6, returnMain # if outer counter = 6, end
	addi $t9, $t9, 1 # increment outer counter
	
	addi $t0, $t0, 24 # Start of row marker moved to next row index
	la $s2, numbers # Reset $s2 to beginning of array
	add $s2, $s2, $t0 # Move $s2 to current start of row pointer
	lw $t1,0($s2) # t1 is value at beginning of the row
	li $t4, 0 # Reset position in row marker
	
	li $t8, 0 # Reset inner counter
	
	j rowLoop

rowMorePCheck:
	addi $t2, $t2, 1 # Player claim found
	beq $t2, 4, playerWinFound # Four in a row, player wins!
	
	addi $s2, $s2, 4 # Next value in row
	lw $t1, 0($s2) # put current array value in $t1
	addi $t4, $t4, 1 # moved down 1 in row
	bge $t4, 7, nextRow # If we've already checked 6 values, move to next row
	
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
	
	addi $t8, $t8, 1 # Increment inner counter
	
	beq $a1, 1, rowMorePCheck # If next value is claimed by player, check value after that
	# else
	addi $s2, $s2, 4 # move to next value in row
	lw $t1, 0($s2) # get current array value
	addi $t4, $t4, 1 # moved down 1 in row
	bge $t4, 7, nextRow
	
	bge $t8, 3, nextRow # Go to next row if finishing check from 3rd starting point in row
	j rowLoop

rowMoreECheck: 
	addi $t3, $t3, 1 # Computer claim found
	beq $t3, 4, enemyWinFound # Four in a row, player loses
	
	addi $s2, $s2, 4 # Next value in row
	lw $t1, 0($s2) # put current array value in $t1
	addi $t4, $t4, 1 # moved down 1 in row
	bge $t4, 7, nextRow # If we've already checked 6 values, move to next row
	
	li $t2, 0 # If here, then player streak reset	
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
	
	beq $a1, 2, rowMoreECheck # If next value is claimed by enemy, check value after that
	#else
	addi $s2, $s2, 4 # move to next value in row
	lw $t1, 0($s2) # get current array value
	addi $t4, $t4, 1 # moved down 1 in row
	bge $t4, 7, nextRow
	
	bge $t8, 3, nextRow # Go to next row if 3 or more checks have happened
	j rowLoop

# +++ CHECKING ALL POSSIBLE ROW WINS+++

playerWinFound:
	li $a3, 1 # Mark player win
	jr $ra

enemyWinFound:
	li $a3, 2 # Mark computer win
	jr $ra

returnMain:
	jr $ra
