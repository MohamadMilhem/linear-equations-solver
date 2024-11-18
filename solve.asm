.data


.text

solveSystems:
	# For each system solve
	# pointer is a3
	move $a3, $s0
	
	LoopSolve:
		# number of vars is stored in s7
		lw $s7, 0($a3)
		
		# matrix A to registers
		lw $t0, 8($a3)
		lw $t1, 12($a3)
		lw $t2, 16($a3)
		lw $t3, 20($a3)
		lw $t4, 24($a3)
		lw $t5, 28($a3)
		lw $t6, 32($a3)
		lw $t7, 36($a3)
		lw $t8, 40($a3)
		
		# matrix B to registers
		lw $a0, 44($a3)
		lw $a1, 48($a3)
		lw $a2, 52($a3)
		
		beq $s7, -1, underDet
		beq $s7, 0, Invalid
		beq $s7, 2, solve2x2
		beq $s7, 3, solve3x3
		
	continueSolve:
		
		lw $a3, 56($a3)
		bnez $a3, LoopSolve
		
		# if next is null end
		jr $ra
underDet:
	# HERE in underDet
	# Save $ra
	sub $sp, $sp, 4
	sw $ra, 0($sp)
	
	jal AddNewSolutionNode
	li $t7, -1
	sw $t7, 0($v0)
	
	
	# resotre $ra
	lw $ra, 0($sp)
	add $sp, $sp, 4
	j continueSolve
		
Invalid:
	# HERE in invalid
	# Save $ra
	sub $sp, $sp, 4
	sw $ra, 0($sp)
	
	jal AddNewSolutionNode
	
	sw $zero, 0($v0)
	
	
	# resotre $ra
	lw $ra, 0($sp)
	add $sp, $sp, 4
	j continueSolve
	
solve2x2:
	# HERE in solve2x2
	# calc det of A (stored in $t9)
	mul $t7, $t0, $t4
	mul $t8, $t1, $t3
	
	sub $t9, $t7, $t8
	
	# check invald case
	beqz $t9, Invalid
	 
	# calc det of A1(stored in $k0)
	mul $t7, $a0, $t4
	mul $t8, $t1, $a1
	
	sub $k0, $t7, $t8
	# calc det of A2(stored in $k1)
	mul $t7, $t0, $a1
	mul $t8, $a0, $t3
	
	sub $k1, $t7, $t8
	
	# TODO: Divide and store
	# Move values
	mtc1 $t9, $f4
	mtc1 $k0, $f6
	mtc1 $k1, $f8
	
	# convert to floating point
	cvt.s.w $f4, $f4
	cvt.s.w $f6, $f6
	cvt.s.w $f8, $f8
	
	# divide 
	div.s $f10, $f6, $f4
	div.s $f12, $f8, $f4
	
	# Move back integer registers
	mfc1 $k0, $f10
	mfc1 $k1, $f12
	
	# printing 
	#mtc1 $k0, $f12
	#li $v0, 2
	#syscall

    	# Print a newline
    	#li $v0, 11              # Load syscall code 11 (print character)
    	#li $a0, 10              # Load ASCII code for newline into $a0
    	#syscall	

	#mtc1 $k1, $f12
	#li $v0, 2
	#syscall

    	# Print a newline
    	#li $v0, 11              # Load syscall code 11 (print character)
    	#li $a0, 10              # Load ASCII code for newline into $a0
    	#syscall	
    	
    	# storing in the solutions_linked_list
    	
	# Save $ra
	sub $sp, $sp, 4
	sw $ra, 0($sp)
	
	jal AddNewSolutionNode
	
	# copying the number of vars to solution linked list.
	lw $s2, 0($a3)
	sw $s2, 0($v0)
	
	# copying the names of vars to solution linked list.
	lw $s2, 4($a3)
	sw $s2, 4($v0)
	
	# Filling the answers into the node
	sw $k0, 8($v0)
	sw $k1, 12($v0)
	
	
	# resotre $ra
	lw $ra, 0($sp)
	add $sp, $sp, 4 
    	
	j continueSolve
	
solve3x3:
	# HERE in solve3x3
	# calc det of A (stored in $t9)
	# First part
	mul $s2, $t4, $t8
	mul $s3, $t5, $t7
	sub $s4, $s2, $s3
	
	mul $s5, $t0, $s4
	add $t9, $zero, $s5
	# Second part
	mul $s2, $t3, $t8
	mul $s3, $t5, $t6
	sub $s4, $s2, $s3
	
	mul $s5, $t1, $s4
	sub $t9, $t9, $s5
	# Third part
	mul $s2, $t3, $t7
	mul $s3, $t4, $t6
	sub $s4, $s2, $s3
	
	mul $s5, $t2, $s4
	add $t9, $t9, $s5
	
	# check invald case
	beqz $t9, Invalid
	
	
	# calc det of A1(stored in $k0)
	# First part
	mul $s2, $t4, $t8
	mul $s3, $t5, $t7
	sub $s4, $s2, $s3
	
	mul $s5, $a0, $s4
	add $k0, $zero, $s5
	# Second part
	mul $s2, $a1, $t8
	mul $s3, $t5, $a2
	sub $s4, $s2, $s3
	
	mul $s5, $t1, $s4
	sub $k0, $k0, $s5
	# Third part
	mul $s2, $a1, $t7
	mul $s3, $t4, $a2
	sub $s4, $s2, $s3
	
	mul $s5, $t2, $s4
	add $k0, $k0, $s5
	# calc det of A2(stored in $k1)
	# First part
	mul $s2, $a1, $t8
	mul $s3, $t5, $a2
	sub $s4, $s2, $s3
	
	mul $s5, $t0, $s4
	add $k1, $zero, $s5
	# Second part
	mul $s2, $t3, $t8
	mul $s3, $t5, $t6
	sub $s4, $s2, $s3
	
	mul $s5, $a0, $s4
	sub $k1, $k1, $s5
	# Third part
	mul $s2, $t3, $a2
	mul $s3, $a1, $t6
	sub $s4, $s2, $s3
	
	mul $s5, $t2, $s4
	add $k1, $k1, $s5	
	# calc det of A3(stored in $s7)
	# First part
	mul $s2, $t4, $a2
	mul $s3, $a1, $t7
	sub $s4, $s2, $s3
	
	mul $s5, $t0, $s4
	add $s7, $zero, $s5
	# Second part
	mul $s2, $t3, $a2
	mul $s3, $a1, $t6
	sub $s4, $s2, $s3
	
	mul $s5, $t1, $s4
	sub $s7, $s7, $s5
	# Third part
	mul $s2, $t3, $t7
	mul $s3, $t4, $t6
	sub $s4, $s2, $s3
	
	mul $s5, $a0, $s4
	add $s7, $s7, $s5
	
	# TODO: DIV and store
	# Move values
	mtc1 $t9, $f4
	mtc1 $k0, $f6
	mtc1 $k1, $f8
	mtc1 $s7, $f10
	
	# convert to floating point
	cvt.s.w $f4, $f4
	cvt.s.w $f6, $f6
	cvt.s.w $f8, $f8
	cvt.s.w $f10, $f10
	
	# divide 
	div.s $f12, $f6, $f4
	div.s $f14, $f8, $f4
	div.s $f16, $f10, $f4
	
	# Move back integer registers
	mfc1 $k0, $f12
	mfc1 $k1, $f14
	mfc1 $s7, $f16
	
	# printing 
	#mtc1 $k0, $f12
	#li $v0, 2
	#syscall
	
    	# Print a newline
    	#li $v0, 11              # Load syscall code 11 (print character)
    	#li $a0, 10              # Load ASCII code for newline into $a0
    	#syscall	
	
	#mtc1 $k1, $f12
	#li $v0, 2
	#syscall
	
	
    	# Print a newline
    	#li $v0, 11              # Load syscall code 11 (print character)
    	#li $a0, 10              # Load ASCII code for newline into $a0
    	#syscall		
	
	#mtc1 $s7, $f12
	#li $v0, 2
	#syscall
	
    	# Print a newline
    	#li $v0, 11              # Load syscall code 11 (print character)
    	#li $a0, 10              # Load ASCII code for newline into $a0
    	#syscall	
	
	
	# storing in the solutions_linked_list
    	
	# Save $ra
	sub $sp, $sp, 4
	sw $ra, 0($sp)
	
	jal AddNewSolutionNode
	
	# copying the number of vars to solution linked list.
	lw $s2, 0($a3)
	sw $s2, 0($v0)
	
	# copying the names of vars to solution linked list.
	lw $s2, 4($a3)
	sw $s2, 4($v0)
	
	# Filling the answers into the node
	sw $k0, 8($v0)
	sw $k1, 12($v0)
	sw $s7, 16($v0)
	
	
	# resotre $ra
	lw $ra, 0($sp)
	add $sp, $sp, 4 
	
	j continueSolve


