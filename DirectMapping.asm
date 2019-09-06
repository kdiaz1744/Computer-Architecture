.data
	Intro:		.asciiz "Enter how many Blocks in the Cache are needed: "
	Add:		.asciiz	"Enter the addresses\nTo finish the program, type (-1): \n"
	miss:		.asciiz	"\nThe number of Miss for this Cache is: "
	hit:		.asciiz	"The number of Hit for this Cache is: "
.text
	#Asks the user to enter the number of Cache Blocks.
	li $v0, 4
	la $a0, Intro
	syscall
	
	#Get the user input (Number of Cache Blocks)
	li $v0, 5
	syscall
	
	#Move value to a safe place
	#$s0 = Number of blocks asked for
	move $s0, $v0
	
	#*********************************************************************************
	# If user input is divisible by 2, continue. If not, exit.			 *
	#This was done because a suggestion from a book mentioned that you can avoid some*
	#errors doing this.							         *
	#*********************************************************************************	
	jal check
	
	#Allocate the space in memory for Cache Block
	#Pass the address of the space allocated.
	sll $a0, $v0, 2
	li $v0, 9
	syscall
	
	#Since $v0 & $a0 can change periodically, we are safe-keeping the values
	move $s1, $v0		#$s1 will be initialized with the address space
	move $t5, $a0		#$t5 will contain the bytes space allocated

	li $v0, 4
	la $a0, Add		#print message
	syscall
	
	#From here on is the implementation of the allocating function Direct Mapping
	DMFunction:
	li $v0, 5
	syscall
	
	jal Finish		#if user input is -1, exit
	
	#*************************************************************************************
	# The way this works is that by dividing the Address value by the block amount, and  *
	#saving the remainder in a variable, you can use that variable to correctly 	     *
	#allocate it in a cache block.							     *
	#*************************************************************************************
	div $t0, $v0, $s0	#Div $t0 = User Value % Cache Block
	mfhi $t0		# Remainder
	mul $t0, $t0, 4		# $t4 * 4 = setting the space in the block
	add $s1, $s1, $t0	#moving to the desired direction
	
	#***********************************************************************************
	# This part checks whether there's going to be a miss or hit with the cache, using *
	#the value inputed. This loads the Word value in the position $s1 to register $t2. *
	#if there's a hit in the cache, go to "Hit" and don't replace the value(hit++), if *
	#it's a miss, then store the value in the adress specified.			   *
	#***********************************************************************************
	lw  $t2, 0($s1) 		#$t2 = Word in position $s1
	beq $t2, $v0, Hit		
	sw  $v0, 0($s1)
	addi $s7, $s7, 1		# miss++
	
	jal updateV
	
	j DMFunction
	


# Below are the operational procedures of the main code above
	
	check:			#checks if user input is acceptable
	andi $t6, $v0, 1
	beq  $t6, 1, Exit
	jr $ra
	
	Hit:			#if a Hit happens, increment counter
	addi $s6, $s6, 1	# hit++
	jal updateV
	j DMFunction
	
	Display:		#displays values of hit & miss
	li $v0, 4
	la $a0, hit
	syscall
		
	li $v0, 1
	add $a0,$zero,$s6
	syscall
	
	li $v0, 4
	la $a0, miss
	syscall
	
	li $v0, 1
	add $a0,$zero,$s7
	syscall
	
	j Exit
	
	updateV:		#updates values and space at the moment
	mul $t2, $t0, -1
	add $s1, $s1, $t2
	jr $ra
	
	Finish:			#checks if user is done inputing values
	beq $v0, -1, Display
	jr $ra	
	
	Exit:
	li $v0, 10
	syscall
	
	
