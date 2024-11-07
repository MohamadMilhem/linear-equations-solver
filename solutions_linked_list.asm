# this assembly file contains all the function related to handling the creation of new nodes in the solution's 
#linked list


.text
	# Returns: 
	# s1 - address of linked list if not existing
	# v0 - address of new node 
AddNewSolutionNode: 
	
	beq $s1, $zero, CreateList #If head node does not exist, create new list
	
	li $v0, 9 #syscall to allocate memory (allocates # of bytes in $a0)
	li $a0, 24 #allocate 24 bytes for each set of solutions
	syscall
	sw $zero, 20($v0) #let the address of the next node be null
	
	#traverse list to store last element
	move $t1, $s1 #move head to temporary location
	FindLast:	
		lw $t2, 20($t1) #store address of next node in $t2
		beq $t2, $zero, Append #if address of next node is null, we can "Append" to the list
		move $t1, $t2 #loop to the next node
		j FindLast
		
	Append:
		sw  $v0, 56($t2) #make the previous node point to the new node
		jr $ra
		
	
	CreateList:
		li $v0, 9 #syscall to allocate memory (allocates # of bytes in $a0)
		li $a0, 60 #allocate 60 bytes for each system of equations
		syscall 
		move $s0, $v0 
		sw $zero, 56($s0)
		jr $ra
		
