.data
# Important mathematical expressions
equal: .asciiz "="
minus: .asciiz "-"
plus: .asciiz "+"
dot: .asciiz "."

# Text-structure related variables
newLine: .asciiz "\n"

# File path
fileName: .asciiz "C:\\Users\\TESTUSER\\Desktop\\UniversityCoursesFiles\\uniYear4\\Architecture\\linear-equations-solver\\equations.txt"
#fileName: .space 2048
#Enter file String 
EnterFileString: .asciiz "Enter files name:"
# Buffers 
NumBuff: .space 10
fileBuff: .space 512
systemBuff: .space 2024      # Buffer to accumulate a system of equations
lineBuff: .space 512
.text
#.globl readFile:

readFile:
    	# Load file name address into $a0
    	#li $v0, 4
    	#la $a0, EnterFileString
    	#syscall 
    	
    	#li $v0, 8
    	#la $a0, fileName
    	#li $a1, 2048
    	#syscall 
    	
    	#li $v0, 4
    	#la $a0, fileName
    	#syscall 
    	
   	la $a0, fileName
    
    	# Open the file
    	li $v0, 13          # Open file syscall
    	li $a1, 0           # Open file for reading
    	syscall
    	move $s2, $v0       # Save file descriptor in $s2
    	
    	li $v0, 1
	move $a0, $s2
	syscall

    	# Check if file opened successfully
    	bltz $s2, Exit      # If $s2 is negative, exit program
 	
 # read one system of equations
ReadSysEq:
   	li $t0, -1 #initialize t0 lines counter
    	la $s3, lineBuff #initialize line buffer 
    	la $s4,systemBuff #save address of system buffer
    	
    	la $t4, newLine #load new line character address
    	lbu $t5, 0($t4) #save new line character
    	
    	move $k1, $zero #initialize character counter
    	
    	initReadEqLoop:
    		la $s3, lineBuff #initialize line buffer 
    		addi $t0,$t0, 1  #increment line counter    
    	readEqLoop:
    	   	li $v0, 14         # Read from file syscall
    	   	move $a0, $s2      # File descriptor in $a0
    		move $a1, $s3    # Buffer to store read data
    		li $a2, 1        # Max number of bytes to read
    	    	syscall
    	    	move $k0, $v0 
    	    	lbu $t2, 0($s3) #load char currently read into $t2 
    	    	
    	    	addi $s3,$s3, 1 #increment address in lineBuff
    	    	addi $k1, $k1, 1 #increment character counter
    	    	
    	    	beq $t2, 10, CopyLineToSystem #copy line to system buffer
    	    	
    	    	
    	    	j readEqLoop


CopyLineToSystem:
	la $t6, lineBuff
     	move $t1, $zero
     	CopyLineToSystemLoop: 
     		lbu $t7, 0($t6)
     		sb $t7, 0($s4)
     		addi $s4, $s4, 1 #increment systenBuff
     		addi $t6, $t6, 1 #increment lineBuff
     		beq $t7, $t5, IsEndOfSys  
     		Continue:	
     		beq $t7, $t5, initReadEqLoop ## 
     		addi $t1, $t1, 1
     		j CopyLineToSystemLoop
     	
IsEndOfSys:
	beqz $t1, ParseSys	
	j Continue

ParseSys:
	la $s4, systemBuff 
	move $s5, $t0 #number of equations in the system
	jal AddNewEquationNode #initialize a linked list node. s0 is address of head and v0 is address of new node
	move $t0, $v0 #save address of new node in $t0
	li $s6, 0 #variables counter
	li $s7, 0 #line counter 
	li $t6, 0 #initialize Accumulator
	sw $s5, 0($t0) #store the number of variables in the node 
	
	la $t2, minus
	lbu $t9, 0($t2)#temp to swap content
	move $t2, $t9 #swap content
	
	la $t3, plus
	lbu $t9, 0($t3)#temp to swap content
	move $t3, $t9 #swap content
	
	la $t4, newLine
	lbu $t9, 0($t4)#temp to swap content
	move $t4, $t9 #swap 
	
	li $t6, 0 #integer accumulator
	lbu $t1, 0($s4) #storeletter

	li $t5, 1 #initialize sign flag
	
	move $a3, $zero #initializeBufferCounter
	
	ReadEq: 	
		beq $t1, $t2, MakeNegative #if the letter before the number is a negative sign, make $t5 negative
		ContinueFromMakeNegative:
		beq $t1, $t4, CheckMatrixB #if this is the end of the equation, the last number is an element of matrix B
		ContinueFromCheckMatrixB:
		ble $t1, 57, TestNum #check if the char is integer
		ContinueFromTestNum:
		bge $t1, 97, CheckVarSmall #check if variable small letter
		ContinueFromCheckVarSmall:
		bge $t1, 65, CheckVarCapital #check if variable capital
		ContinueFromCheckVarCapital:
		ContinueFromAddNumInA:
		
		addi $s4, $s4, 1 #increment to the next character
		lbu $t1, 0($s4) #storeletter
		addi $a3, $a3, 1 #increment char counter
		
		bge $a3, $k1, CheckFileEnd
		ContinueFromCheckFileEnd:
		bge $a3, $k1,ReadSysEq #if system read, branch back to top
		
		###################
		#li $v0, 11
		#move $a0, $t1
		#syscall 
		###########################
		j ReadEq
		
	CheckMatrixB:
		mulo $t7, $s7, 4 #start with the initial location of matrix B by mulitplying the line number by 4
		addi $t7, $t7, 44 #add distance from node beginning
		add $t7, $t7, $t0 #add node address
		mulo $t6, $t6, $t5 #multiply accumulator by sign
		sw $t6, 0($t7) #store accumulator value in matrix B
		li $t5, 1 #restore sign value
		move $t6, $zero	 #reset accumulator
		addi $s7, $s7, 1 #increment line counter 
		j ContinueFromCheckMatrixB 
	
	MakeNegative:
		li $t5, -1	
		j ContinueFromMakeNegative
	TestNum:
		bge $t1, 48, AddToIntAcc
		j ContinueFromTestNum
	AddToIntAcc:
		mulo $t6, $t6, 10
		addi $t1, $t1, -48
		add $t6, $t6, $t1
		j ContinueFromTestNum
	CheckVarSmall:
		ble $t1, 122, CheckVarInNode #checks if the variable already in the list
		j ContinueFromCheckVarSmall
	CheckVarCapital:
		ble $t1, 90, CheckVarInNode #checks if the variable already in the list
		j ContinueFromCheckVarCapital
	
	CheckVarInNode:

		addi $t7, $t0, 4 #make $t7 point at the first location in the node	
		lbu $t8, 0($t7) #point to the first location in the vars segment
		beq $t1, $t8, AddNumToNode
		
		lbu $t8, 1($t7) #point to the second location in the vars segment
		beq $t1, $t8, AddNumToNode
		
		lbu $t8, 2($t7) #point to the third location in the vars segment
		beq $t1, $t8, AddNumToNode
		
		j AddVar
	AddVar:
		addi $t7, $t0, 4 #store address of first var in node
		add $t7, $t7, $s6 #add the new node byte
		sb $t1, 0($t7) #store new var in node
		addi $s6, $s6, 1 #increment var counter
		#######################
		li $v0, 1
		move $a0, $s6
		syscall 
		######################
		lw $a0, 0($t0) #move the number of equations to $a0
		bgt $s6 ,$a0, DeclareSysUnderdetermined  #check is number of variables is greater than number of equation. 
				#If so, branch to DeclareSysUnderdetermined
		ContinueFromDeclareSysUnderdetermined:
		j AddNumToNode
		
	DeclareSysUnderdetermined:
		li $a0, -1 # -1 is the code if system underdetermined
		sw $a0, 0($t0)
		j ContinueFromDeclareSysUnderdetermined
		
	AddNumToNode:
		mulo $t7, $s7, 12 #determine the line in which we are storing the data and then store in $t7
		li $t8, 0 #start counter to find the location of matching var to store at the right column
		lbu $t9, 4($t0) #point to the first location in the vars segment
		beq $t1, $t9, StoreNumInA
		addi $t8, $t8, 1
		lbu $t9, 5($t0) #point to the first location in the vars segment
		beq $t1, $t9, StoreNumInA
		addi $t8, $t8, 1
		j StoreNumInA
		
	StoreNumInA:
		mulo $t8, $t8, 4
		add $t7, $t7, $t8 #add location in matrix
		addi $t7, $t7, 8 #actual location in node
		add $t7,$t7, $t0 #add index to location of node
		mulo $t6, $t6, $t5 #multiply accumulator by sign
		beqz $t6, storeOneVar #to store implicit 1
		sw  $t6, 0($t7) #store number in matrix A
		ReturnFromstoreOneVar:

		li $t5, 1 #restore sign value
		move $t6, $zero	 #reset accumulator
		j ContinueFromAddNumInA
		
		storeOneVar:
		li $t6, 1	
		sw  $t6, 0($t7)
		
		j ReturnFromstoreOneVar
	
  #   Print the buffer content
  
  
  	CheckFileEnd:
		beq $k0, $zero, PrintList #check for EOF	
		j ContinueFromCheckFileEnd
  
	PrintList: 
	move $t1, $s0
	
	li $v0, 1
	lw $a0, 0($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	
    	li $v0, 11
	lb $a0, 4($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	li $v0, 11
	lb $a0, 5($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	li $v0, 11
	lb $a0, 6($t1)
	syscall
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	li $v0, 11
	lb $a0, 7($t1)
	syscall
	
	li $v0, 11
	li $a0, 10
	syscall
	
	li $v0, 1
	lw $a0, 8($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	
	li $v0, 1
	lw $a0, 12($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall  
	
	li $v0, 1
	lw $a0, 16($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	li $v0, 1
	lw $a0, 20($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	li $v0, 1
	lw $a0, 24($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	li $v0, 1
	lw $a0, 28($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	
	li $v0, 1
	lw $a0, 32($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	
	li $v0, 1
	lw $a0, 36($t1)
	syscall
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	
	li $v0, 1
	lw $a0, 40($t1)
	syscall
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	  
	li $v0, 1
	lw $a0, 44($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	
	li $v0, 1
	lw $a0, 48($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	  
	li $v0, 1
	lw $a0, 52($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	li $v0, 1
	lw $a0, 56($t1)
	syscall
	
	 lw $t1, 56($t1)
	 #move $t1, $a0
	 
	 li $v0, 11
	li $a0, 10
	syscall
	
	 li $v0, 1
	lw $a0, 0($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	
    	li $v0, 11
	lb $a0, 4($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	li $v0, 11
	lb $a0, 5($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	li $v0, 11
	lb $a0, 6($t1)
	syscall
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	li $v0, 11
	lb $a0, 7($t1)
	syscall
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	li $v0, 1
	lw $a0, 8($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	
	li $v0, 1
	lw $a0, 12($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall  
	
	li $v0, 1
	lw $a0, 16($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	li $v0, 1
	lw $a0, 20($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	li $v0, 1
	lw $a0, 24($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	li $v0, 1
	lw $a0, 28($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	
	li $v0, 1
	lw $a0, 32($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	
	li $v0, 1
	lw $a0, 36($t1)
	syscall
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	
	li $v0, 1
	lw $a0, 40($t1)
	syscall
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	  
	li $v0, 1
	lw $a0, 44($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	
	li $v0, 1
	lw $a0, 48($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	  
	li $v0, 1
	lw $a0, 52($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	li $v0, 1
	lw $a0, 56($t1)
	syscall
	
		 lw $t1, 56($t1)
	 #move $t1, $a0
	 
	 li $v0, 11
	li $a0, 10
	syscall
	
	 li $v0, 1
	lw $a0, 0($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	
    	li $v0, 11
	lb $a0, 4($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	li $v0, 11
	lb $a0, 5($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	li $v0, 11
	lb $a0, 6($t1)
	syscall
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	li $v0, 11
	lb $a0, 7($t1)
	syscall
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	li $v0, 1
	lw $a0, 8($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	
	li $v0, 1
	lw $a0, 12($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall  
	
	li $v0, 1
	lw $a0, 16($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	li $v0, 1
	lw $a0, 20($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	li $v0, 1
	lw $a0, 24($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	li $v0, 1
	lw $a0, 28($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	
	li $v0, 1
	lw $a0, 32($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	
	li $v0, 1
	lw $a0, 36($t1)
	syscall
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	
	li $v0, 1
	lw $a0, 40($t1)
	syscall
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	  
	li $v0, 1
	lw $a0, 44($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	
	li $v0, 1
	lw $a0, 48($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	  
	li $v0, 1
	lw $a0, 52($t1)
	syscall 
	
	li $v0, 11
	li $a0, 10
	syscall 
	
	li $v0, 1
	lw $a0, 56($t1)
	syscall

CloseFile: 
    li $v0, 16          # Close file syscall
    move $a0, $s2       # File descriptor in $a0
    syscall 

Exit:
    li $v0, 10          # Exit program syscall
    syscall 



.include "equations_linked_list.asm"
