##############################################################
# Homework #4
# name: Chun_Hung_Li
# sbuid: 110807126
##############################################################

##############################################################
# DO NOT DECLARE A .DATA SECTION IN YOUR HW. IT IS NOT NEEDED
##############################################################

.text

##############################
# Part I FUNCTIONS
##############################

# SLOT OBJECT
# 1. Slot object takes up two bytes (a half-word) in memory.
# 2. Slot objects can hold exactly one game piece
# 3. Higher addressed byte (from bits 8-15) contains the ASCII 
#    character representing the piece in that slot. 
#    Valid values are 'R', 'Y', and '.'
# 4. Lower addressed byte (from bits 0-7) contains the unsigned 
#    turn number
# 5. obj_arr[i][j] = base_address + (row_size * i) + (size_of(obj) * j)
#	 where: row_size = num_cols * size_of(obj)

# BOARD
# 1. Board will have n rows and m columns.
# 2. Board is a 2D array implemented as a single array in row-major order.
# 3. Bottom of the board comes first.

# 	int set_slot(slot[][] board, int num_rows, int num_cols, 
# 			   	 int row, int col, char c, int turn_num)
#
# 1. function takes in a 2D array num_rows by num_cols in size.
# 2. then, calculates the address of a particular slot given by (row,col).
# 3. finally, stores the given c and turn_num into the appropriate fields
#	 of the two-byte slot object in memory.

# $a0 	 = address of board
# $a1 	 = num_rows
# $a2 	 = num_cols
# $a3    = row
# $sp    = col
# 4($sp) = c
# 8($sp) = turn_num
# returns 0 (success)
# return -1 when
# 1. num_rows < 0 or num_cols < 0
# 2. row is outside range of [0, num_rows-1]
# 3. col is outside range of [0, num_cols-1]
# 4. c is not 'R', 'Y', or '.'
# 5. turn_num is outside the range [0,255]

set_slot:
    # Define your code here
    ###########################################
    check_errors_set_slot:
    	lw $t0, 0($sp)						# load col
    	lw $t1, 4($sp)						# load c
    	lw $t2, 8($sp)						# load turn_num
    	bltz $a1, error_set_slot			# if num_rows < 0, error
    	bltz $a2, error_set_slot			# if num_col < 0, error
    	bltz $a3, error_set_slot			# if row < 0, error
    	bltz $t0, error_set_slot			# if col < 0, error
    	bltz $t2, error_set_slot			# if turn_num < 0, error
    	checkR:
    		li $t3, 82						# ascii value of 'R'
    		beq $t1, $t3, postCharCheck 	# is 'R'
    	checkY:
    		li $t3, 89						# ascii value of 'Y'
    		beq $t1, $t3, postCharCheck 	# is 'Y'
    	checkBlank:
    		li $t3, 46						# ascii value of '.'
    		bne $t1, $t3, error_set_slot	# not 'R', 'Y', or '.'
    	postCharCheck:	
    	bge $a3, $a1, error_set_slot		# row not in range
    	bge $t0, $a2, error_set_slot		# col not in range
    	li $t3, 255							# 255
    	bgt $t2, $t3, error_set_slot		# turn_num too large
    calculate_address_set_slot:
	# obj_arr[i][j] = base_address + (row_size * i) + (size_of(obj) * j)
	# where: row_size = num_cols * size_of(obj)
		li $t3, 2							# size of obj (2 bytes)
		mult $a2, $t3						# row_size
		mflo $t4							# store row_size from mem
		mult $a3, $t4						# row * row_size
		mflo $t4							# store row * row_size
		mult $t3, $t0						# size of obj * col
		mflo $t5							# store size of obj * col
		add $a0, $a0, $t4					# base_address + (row_size * i)
		add $a0, $a0, $t5					# base_address + (size_of(obj) * j)
	store_contents:
		sb $t2, 0($a0)						# store turn_num
		sb $t1, 1($a0)						# store character
		move $v0, $zero						# success
		j complete_set_slot
	error_set_slot:
		li $v0, -1
	complete_set_slot:
    ##########################################
    jr $ra

#	 (char piece, int turn) get_slot(slot[][] board, int num_rows,
#	 int num_cols, int row, int col)
# 1. function takes in the 2D array num_rows by num_cols in size
# 2. calculates the address of a particular slot by (row, col)
# 3. retrieves the ASCII character and the turn number
#
# $a0 = address of board
# $a1 = num_rows
# $a2 = num_cols
# $a3 = row
# $sp = col
# returns ascii character from $v0
# returns turn number read from the slot in $v1
# returns (-1,-1) on error when
# 1. num_rows < 0 or num_cols < 0
# 2. row is outside the range [0, num_rows-1]
# 3. col is outside the range [0, num_cols-1]

get_slot:
    # Define your code here
    check_errors_get_slot:
    	lw $t0, 0($sp)						# load col
		bltz $a1, error_get_slot			# if num_rows < 0, error
    	bltz $a2, error_get_slot			# if num_col < 0, error
    	bltz $a3, error_set_slot			# if row < 0, error
    	bltz $t0, error_set_slot			# if col < 0, error
    	bge $a3, $a1, error_set_slot		# row not in range
    	bge $t0, $a2, error_set_slot		# col not in range
    calculate_address_get_slot:
    	# obj_arr[i][j] = base_address + (row_size * i) + (size_of(obj) * j)
		# where: row_size = num_cols * size_of(obj)
		li $t3, 2							# size of obj (2 bytes)
		mult $a2, $t3						# row_size
		mflo $t4							# store row_size from mem
		mult $a3, $t4						# row * row_size
		mflo $t4							# store row * row_size
		mult $t3, $t0						# size of obj * col
		mflo $t5							# store size of obj * col
		add $a0, $a0, $t4					# base_address + (row_size * i)
		add $a0, $a0, $t5					# base_address + (size_of(obj) * j)
	load_contents:
		lb $v1, 0($a0)						# load turn_num
		lb $v0, 1($a0)						# load character
		j complete_get_slot
    error_get_slot:
    	li $v1, -1
    	li $v1, -1
    complete_get_slot:
    jr $ra

#	int clear_board(slot[][] board, int num_rows, int num_cols)
# 1. function will clear the board
# 2. Loop over all cells of the 2D array and call set_slot for each
# 3. Set each slot to the default state: upperbyte to '.' and lower byte to 0

# $a0 = address of board
# $a1 = num_rows
# $a2 = num_cols
# return 0 for success
# return -1 for error if
# 1. num_rows < 0 or num_cols < 0
clear_board:
    # Define your code here
    ###########################################
    check_errors_clear_board:
    	bltz $a1, error_clear_board			# if num_rows < 0, error
    	bltz $a2, error_clear_board			# if num_col < 0, error
    store_arguments_clear_board:
    	addi $sp, $sp, -4
    	sw $fp, 0($sp)
    	move $fp, $sp
    	addi $sp, $sp, -16
    	sw $ra, -4($fp)
    	sw $a0, -8($fp)
    	sw $a1, -12($fp)
    	sw $a2, -16($fp)
    	move $a3, $zero
    	move $t0, $zero
    	addi $sp, $sp, -12
    	sb $t0, 0($sp)
    	li $t0, 46
    	sb $t0, 4($sp)
    	move $t0, $zero
    	sb $t0, 8($sp)
    	mult $a1, $a2
    	mflo $t6
    	move $t7, $a0
    	move $t0, $zero
    loop_clear_board:
    	beq $a3, $a1, load_arguments_clear_board
    	inner_loop_clear_board:
    		sb $t0, 0($sp)
    		beq $a2, $t0, complete_inner_loop_clear_board
    		jal set_slot
    		move $a0, $t7
    		lb $t0, 0($sp)
    		addi $t0, $t0, 1
    		j inner_loop_clear_board
    	complete_inner_loop_clear_board:
    		addi $a3, $a3, 1
    		move $t0, $zero
    		j loop_clear_board
    load_arguments_clear_board:
    	lw $a2, -16($fp)
    	lw $a1, -12($fp)
    	lw $a0, -8($fp)
    	lw $ra, -4($fp)
    	lw $fp, 0($fp)
    	addi $sp, $sp, 32
    	li $v0, 0
    	j complete_clear_board
    error_clear_board:
    	li $v0, -1
    complete_clear_board:
    ##########################################
    jr $ra


##############################
# Part II FUNCTIONS
##############################

load_board:
    # Define your code here
    ###########################################
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    addi $sp, $sp, -4
    sw $fp, 0($sp)
    move $fp, $sp
    addi $sp, $sp, -2312
    addi $fp, $fp, -2300
    move $t0, $a0
    move $t2, $a1
    move $a0, $a1
    move $a1, $zero
    move $a2, $zero
    li $v0, 13
    syscall
    move $t1, $v0
    li $v0, 14
    move $a0, $t1
    move $a1, $fp
    li $a2, 2300
   	move $t6, $v0
    syscall
    li $v0, 16
    move $a0, $t1
    syscall
    move $a0, $t0
    move $a1, $t2
    
    #num_rows
    lbu $t0, 0($fp)
    addi $t0, $t0, -30
    addi $fp, $fp, 1
    lbu $t1, 0($fp)
    addi $t1, $t1, -30
    addi $fp, $fp, 1
    li $t2, 10
    mult $t0, $t2
    mflo $t0
    add $s0, $t0, $t1
    move $a1, $s0
    beqz $s0, error_load_board
    
    #num_cols
    lbu $t1, 0($fp)
    addi $t1, $t1, -30
    addi $fp, $fp, 1
    lbu $t2, 0($fp)
    addi $t2, $t2, -30
    addi $fp, $fp, 1
    li $t3, 10
    mult $t1, $t3
    mflo $t1
    add $s1, $t1, $t2
    move $a2, $s1
    beqz $s1, error_load_board
    
    #nextline
    addi $fp, $fp, 1
	li $t8, 5
    li $t7, 5
    loop_load_board:
    	beq $t6, $t7, pre_complete_load_board
    	lbu $t0, 0($fp)
    	addi $t0, $t0, -30
    	addi $fp, $fp, 1
    	lbu $t1, 0($fp)
    	addi $t1, $t1, -30
    	addi $fp, $fp, 1
    	li $t2, 10
    	mult $t0, $t2
    	mflo $t0
    	add $a3, $t0, $t1
    	
    	lbu $t0, 0($fp)
    	addi $t0, $t0, -30
    	addi $fp, $fp, 1
    	lbu $t1, 0($fp)
    	addi $t1, $t1, -30
    	addi $fp, $fp, 1
    	li $t2, 10
    	mult $t0, $t2
    	mflo $t0
    	add $t8, $t0, $t1
    	sw $t8, 0($sp)
    	
    	lbu $t0, 0($fp)
    	addi $fp, $fp, 1
    	sw $t0, 4($sp)
    	
    	lbu $t0, 0($fp)
    	addi $t0, $t0, -30
    	addi $fp, $fp, 1
    	lbu $t1, 0($fp)
    	addi $t1, $t1, -30
    	addi $fp, $fp, 1
    	lbu $t2, 0($fp)
    	addi $t2, $t2, -30
    	addi $fp, $fp, 2
    	li $t3, 100
    	mult $t0, $t3
    	mflo $t0
    	li $t4, 10
    	mult $t1, $t4
    	mflo $t1
    	add $t0, $t0, $t1
    	add $t0, $t0, $t2
    	blez $t0, error_load_board
    	sw $t0, 8($sp)
    	jal set_slot
    	bltz $v0, error_load_board
    	addi $t7, $t7, 1
    	j loop_load_board
    
    pre_complete_load_board:
    	move $v0, $s0
    	move $v1, $s1
    	j complete_load_board
    error_load_board:
    	li $v0, -1
    	li $v1, -1
    	j complete_load_board
    ##########################################
    complete_load_board:
    	addi $sp, $sp, 2312
    	lw $fp, 0($sp)
    	addi $sp, $sp, 4
    	lw $ra, 0($sp)
    	addi $sp, $sp, 4
    jr $ra

# a0 = address of board
# a1 = num_rows
# a2 = num cols
# a3 = address of filename
save_board:
    # Define your code here
    ###########################################
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    addi $sp, $sp, -4
    sw $fp, 0($sp)
    move $fp, $sp
    li   $v0, 13
    move $s0, $a0
    move $a0, $a3
    move $s3, $a3
    move $s1, $a1
    li $a1, 1
    move $s2, $a2
    li $a2, 0
    mult $s1, $s2
    mflo $s4
    li $t0, 9
    mult $s4, $t0
    mflo $s4
    li $t0, 5
    add $s4, $s4, $t0
    li $t0, -1
    mult $s4, $t0
    mflo $s5
    addi $s5, $s5, -4
    add $sp, $sp, $s5
    addi $s5, $s5, 4
    add $fp, $fp, $s5
  	syscall            # open a file (file descriptor returned in $v0)
  	bltz $s1, error_save_board
    bltz $s2, error_save_board
    bltz $v0, error_save_board
  	move $s6, $v0      # save the file descriptor 
  	
  	li $t0, 10
  	#num_rows
    div $a1, $t0
    mflo $t1			# quotient
    mfhi $t2			# remainder
    addi $t1, $t1, 30	
    addi $t2, $t2, 30
    sb $t1, 0($fp)
    addi $fp, $fp, 1
    sb $t2, 0($fp)
    addi $fp, $fp, 1
    
    #num_cols
    div $a2, $t0
    mflo $t1			# quotient
    mfhi $t2			# remainder
    addi $t1, $t1, 30	
    addi $t2, $t2, 30
    sb $t1, 0($fp)
    addi $fp, $fp, 1
    sb $t2, 0($fp)
    addi $fp, $fp, 1
  	
  	li $t0, 0
    sb $t0, 0($fp)
    addi $fp, $fp, 1
    move $t9, $s0
    move $t7, $zero
    move $t8, $zero
    move $s3, $zero
  	loop_save_board:
  		beq $t7, $s1, complete_loop_save_board
  		inner_loop_save_board:
  			beq $t8, $s2, complete_inner_loop_save_board
  			lb $t0, 1($s0)
  			beq $t0, 46, skip_save_board
  			addi $s3, $s3, 1
  			move $a0, $t9
  			move $a1, $s1
  			move $a2, $s2
  			move $a3, $t6
  			sb $t8, 0($sp)
  			jal get_slot
  			li $t0, 10
  			#num_rows
    		div $t7, $t0
    		mflo $t1			# quotient
    		mfhi $t2			# remainder
    		addi $t1, $t1, 30	
    		addi $t2, $t2, 30
    		sb $t1, 0($fp)
    		addi $fp, $fp, 1
    		sb $t2, 0($fp)
    		addi $fp, $fp, 1
    
    		#num_cols
    		div $t8, $t0
    		mflo $t1			# quotient
    		mfhi $t2			# remainder
    		addi $t1, $t1, 30	
    		addi $t2, $t2, 30
    		sb $t1, 0($fp)
    		addi $fp, $fp, 1
    		sb $t2, 0($fp)
    		addi $fp, $fp, 1
    		sb $v0, 0($fp)
    		li $t3, 100
    		div $v1, $t3
    		mflo $t4
    		mfhi $t5
    		li $t3, 10
    		div $t5, $t3
    		mflo $t5
    		mfhi $t6
    		addi $fp, $fp, 1
    		sb $t4, 0($fp)
    		addi $fp, $fp, 1
    		sb $t5, 0($fp)
    		addi $fp, $fp, 1
    		sb $t6, 0($fp)
    		addi $fp, $fp, 1
    		move $t0, $zero
    		sb $t0, 0($fp)
    		addi $fp, $fp, 1
  			skip_save_board:
  				addi $s0, $s0, 2
  				addi $t8, $t8, 1
  			j inner_loop_save_board
  		complete_inner_loop_save_board:
  			move $t8, $zero
  			addi $t7, $t7, 1
  		j loop_save_board
  	complete_loop_save_board:
  	###############################################################
  	# Write to file just opened
  		add $fp, $fp, $s5
  		li   $v0, 15       # system call for write to file
  		move $a0, $s6      # file descriptor 
  		move   $a1, $fp	   # address of buffer from which to write
  		move   $a2, $s4    # hardcoded buffer length
  		syscall            # write to file
  		bltz $v0, error_save_board
  	###############################################################
  	# Close the file 
  		move $s0, $s3
  		j skip_error
  		error_save_board:
			li $s0, -1
		skip_error:
  		li   $v0, 16       # system call for close file
  		move $a0, $s6      # file descriptor to close
  		syscall            # close file
  		move $v0, $s0
  		add $sp, $sp, $s4
  		lw $fp, 0($sp)
    	addi $sp, $sp, 4
    	lw $ra, 0($sp)
    	addi $sp, $sp, 4
  		j complete_save_board
  	###############################################################
	complete_save_board:
    ##########################################
    jr $ra

validate_board:
    # Define your code here
    ###########################################
    # DELETE THIS CODE.
    li $v0, -200
    ##########################################
    jr $ra

##############################
# Part III FUNCTIONS
##############################

display_board:
    # Define your code here
    ###########################################
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    addi $sp, $sp, -4
    bltz $a1, error_display_board
    bltz $a2, error_display_board
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    addi $t6, $s1, -1
    move $t9, $zero
    move $t8, $zero
    move $t7, $s2
    loop_display_board:
    	bltz $t6, complete_display_board
    	inner_loop_display_board:
    		beq $t8, $t7, complete_loop_display_board
    		move $a0, $s0
    		move $a1, $s1
    		move $a2, $s2
    		move $a3, $t6
    		sb $t8, 0($sp)
    		jal get_slot
    		beq $v0, 46, not_piece
    		addi $t9, $t9, 1
    		not_piece:
    		move $a0, $v0
    		li $v0, 11
    		syscall
    		j inner_loop_display_board
    	complete_loop_display_board:
    		li $a0, 10
			li $v0, 11
			syscall
    		move $t8, $zero
    		addi $t6, $t6, -1
    	j loop_display_board
    error_display_board:
    	li $v0, -1
    complete_display_board:
    	addi $sp, $sp, 4
    	lw $ra, 0($sp)
    	addi $sp, $sp, 4
    ##########################################
    jr $ra

drop_piece:
    # Define your code here
    ###########################################
    # DELETE THIS CODE.
    li $v0, -200
    ##########################################
    jr $ra

undo_piece:
    # Define your code here
    ###########################################
    # DELETE THIS CODE.
    li $v0, -200
    li $v1, -200
    ##########################################
    jr $ra

check_winner:
    # Define your code here
    ###########################################
    # DELETE THIS CODE.
    li $v0, -200
    ##########################################
    jr $ra

##############################
# EXTRA CREDIT FUNCTION
##############################


check_diagonal_winner:
    # Define your code here
    ###########################################
    # DELETE THIS CODE.
    li $v0, -200
    ##########################################
    jr $ra



##############################################################
# DO NOT DECLARE A .DATA SECTION IN YOUR HW. IT IS NOT NEEDED
##############################################################
