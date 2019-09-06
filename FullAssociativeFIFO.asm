.data
	Intro:		.asciiz "Enter how many Blocks in the Cache are needed: "
	Add:		.asciiz	"Enter the addresses\nTo finish the program, type (-1): \n"
	hit:		.asciiz	"The number of Hit for this Cache is: "
	miss:		.asciiz	"\nThe number of Miss for this Cache is: "
.text
	#asks the user to enter the number of Cache Blocks.
	li $v0, 4
	la $a0, Intro
	syscall
	
	#Get the user input (Number of Cache Blocks)
	li $v0, 5
	syscall
	
	#Move value to a safe place
	#$s0 = Number of blocks asked for
	move $s0, $v0
	
	#We'll use add to set the Cache Block to the formula:
	# x and (y-1) where: x = input | y = Cache Blocks
	
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
	
	# $s2 will be variable we use when we want to update values later on
	# for example if Cache Block = 4, $s2 = 3
	#--> addi $s2, $s0, -1
	add $s2, $s2, $s1
	li  $t4, 1
	
	#This loop catch the sequence of address blocks
	#Store the value in free space.
	#If your are finish to go through array, Implement FIFO
	FAFunction:
	beq $t1, $s0, updateV
	li $v0, 5
	syscall
	
	jal Finish
	
	j CacheRun
	

# Below are the operational procedures of the main code above
	
	check:			#checks if user input is acceptable
	andi $t6, $v0, 1
	beq  $t6, 1, Exit
	jr $ra
	
	Finish:			#if a Hit happens, increment counter
	beq $v0, -1, Display
	jr $ra
	
	CacheRun:		#Run through the cache to check if HIT exists
	bgt $t4, $s0, MISS	#if not HIT is found, the value is a MISS
	lw  $t2, 0($s2)
	beq $v0, $t2, HIT
	addi $t4, $t4, 1
	addi $s2, $s2, 4
	j CacheRun
	
	HIT:
	addi $s7, $s7, 1
	addi $t1, $t1, 1
	j FAFunction
	
	MISS:
	#Reset the values
	mul  $t5, $s0, -4
	li   $t4, 1
	add  $s2, $s2, $t5
	
	#Preparing variables for MISS
	addi $s6, $s6, 1
	sw   $v0, 0($s1)
	addi $t1, $t1, 1
	addi $s1, $s1, 4
	j FAFunction	
	
	updateV:
	mul $t3, $s0, -4
	li  $t1, 1
	add $s1, $s1, $t3
	j FAFunction
	
	Display:
	li $v0, 4
	la $a0, hit
	syscall
		
	li $v0, 1
	add $a0,$zero,$s7
	syscall
	
	li $v0, 4
	la $a0, miss
	syscall
	
	li $v0, 1
	add $a0,$zero,$s6
	syscall
	
	Exit:
	li $v0, 10
	syscall
