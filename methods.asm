.macro PrintCharToFile (%char)
	.data
	myLabel: .space 1
	.text
	sb %char, myLabel
	li $v0, 15
	la $a1, myLabel   
	li $a2, 1
	syscall
.end_macro


.data 

# Menu Massges
welcomeMessage: .asciiz "\nWelcome, please choose on the following options (from 1 to 2) or press E or e to exit.\n"
readFileMessage: .asciiz "1. Read input File.\n"
printAnswersMessage: .asciiz "2. Print answers.\n"


# Debug messages
reachReadfile : .asciiz "Reached ReadFile.\n"
reachPrintAnswers: .asciiz "Reached printAnswers.\n"


# Error Messages
invalidSystemMessage : .asciiz "The correspoinding systems is invalid.\n"
CantOpenFileMessage : .asciiz "Couldn't open the input file.\n"
theSystemIsUnderdetemineteMessage : .asciiz "The system is underdetermined.\n"

# Output file name and buffer.
filename: .asciiz "C:/Users/moham/OneDrive/Desktop/Computer Engineering/ENCS4370 (Architecture)/Project1/linear-equations-solver/TEST/output.txt"
buffer:   .space 32  # for floating point number
smallBuffer: .space 1 # for printing one char.
multiplier: .float 100.0


.text 
# print menu
printMenu:
	la $a0, welcomeMessage
	li $v0, 4
	syscall
	
	la $a0, readFileMessage
	li $v0, 4
	syscall
	
	la $a0, printAnswersMessage
	li $v0, 4
	syscall 
	
	jr $ra

# print message with address stored in a0
print:
	li $v0, 4
	syscall
	jr $ra

	
# printing answers
printAnswers:

	# Print a newline
    	li $v0, 11              # Load syscall code 11 (print character)
    	li $a0, 10              # Load ASCII code for newline into $a0
    	syscall
	# For each system print
	# pointer is a3
	move $a3, $s1
	
	LoopPrint:
		# number of vars is stored in s7
		lw $s7, 0($a3)
		
		
		bgt $s7, 0, ContinuePrint
		beq $s7, -1, PrintUnderdetermind 
		
		la $a0, invalidSystemMessage
		li $v0, 4
		syscall		
		b NewIteration
		
	PrintUnderdetermind:
		la $a0, theSystemIsUnderdetemineteMessage
		li $v0, 4
		syscall		
		b NewIteration	
	
		
	ContinuePrint:
		move $t0, $zero # iterator for the names
		move $t1, $zero # iterator for the values.
		varLoop:
			beq $t0, $s7, NewIteration # if finish vars proceed to next system.
			addi $t3, $a3, 4	    # possion t3 on the start of names segment.
			add $t3, $t3, $t0	    # add the index to t3.
	
			lb $t4, 0($t3)
			
			addi $t3, $a3, 8 	    # possitoin t3 on the start of values segment.
			add $t3, $t3, $t1	    # add the index to t3 (values).
		
			lw $t5, 0($t3)
		
			# printing 
			# Print var name
    			li $v0, 11              # Load syscall code 11 (print character)
    			move $a0, $t4
			syscall
			
			# print the equal sign '='
			li $v0, 11              # Load syscall code 11 (print character)
    			li $a0, 61
			syscall
			
			
			# print the value as float
			mtc1 $t5, $f12
			li $v0, 2
			syscall

    			# Print a newline
    			li $v0, 11              # Load syscall code 11 (print character)
    			li $a0, 10              # Load ASCII code for newline into $a0
    			syscall	
    			
    			addi $t0, $t0, 1
    			addi $t1, $t1, 4
    			b varLoop
	NewIteration:
	    	# Print a newline
    		li $v0, 11              # Load syscall code 11 (print character)
    		li $a0, 10              # Load ASCII code for newline into $a0
    		syscall	
		lw $a3, 20($a3)
		bnez $a3, LoopPrint
		
		# if next is null end

		
	jr $ra

printAnswersToFile:
	# save $ra
	addi $sp, $sp, -4
    	sw $ra, 0($sp)

	# Open File
	# Load the file name into $a0
    	la $a0, filename
    	li $v0, 13                # Syscall to open file
    	li $a1, 1                 # 1 = File write mode
    	li $a2, 0                 # Permissions 
    	syscall

    	# Save file descriptor
    	move $a0, $v0             # $t0 now contains the file descriptor

	# For each system print
	# pointer is a3
	move $a3, $s1
	
	LoopPrintFile:
		# number of vars is stored in s7
		lw $s7, 0($a3)
		
		bgt $s7, 0, ContinuePrintFile
		beq $s7, -1, PrintUnderdetermindFile 
		
		la $a1, invalidSystemMessage            # Address of buffer holding string
		li $v0, 15                		 # Syscall for file write
		li $a2, 39                		 # Number of bytes to write (Number of chars in the message.)
		syscall
		b NewIterationFile

	PrintUnderdetermindFile:
		la $a1, theSystemIsUnderdetemineteMessage            # Address of buffer holding string
		li $v0, 15                		 # Syscall for file write
		li $a2, 31               		 # Number of bytes to write (Number of chars in the message.)
		syscall
		b NewIterationFile
		
	ContinuePrintFile:
		move $k0, $zero # iterator for the names
		move $k1, $zero # iterator for the values.
		varLoopFile:
			beq $k0, $s7, NewIterationFile # if finish vars proceed to next system.
			addi $t3, $a3, 4	    # possion t3 on the start of names segment.
			add $t3, $t3, $k0	    # add the index to t3.
	
			lb $t4, 0($t3)
			
			addi $t3, $a3, 8 	    # possitoin t3 on the start of values segment.
			add $t3, $t3, $k1	    # add the index to t3 (values).
		
			lw $t5, 0($t3)
		
			# printing 
			# Print var name
    			PrintCharToFile ($t4)
			
			# print the equal sign '='
			add $t4, $zero, 61
			PrintCharToFile ($t4)
			
			
			# print the value as float
			mtc1 $t5, $f12
			c.le.s  $f0, $f12
			bc1t Positive
			add $t4, $zero, 45
			PrintCharToFile ($t4)
			mtc1 $zero, $f2 
			sub.s  $f12, $f2, $f12      # Multiply $f12 by -1.0 (negating its value)

		Positive:	
			la $a1, buffer
			jal FloatToString
			li $v0, 15
    			la $a1, buffer
    			move $a2, $v1
    			syscall

    			# Print a newline
  			add $t4, $zero, 10
			PrintCharToFile ($t4)
    			
    			addi $k0, $k0, 1
    			addi $k1, $k1, 4
    			b varLoopFile
	NewIterationFile:
	    	# Print a newline
    		add $t4, $zero, 10
		PrintCharToFile ($t4)
		
		lw $a3, 20($a3)
		bnez $a3, LoopPrintFile
		
		# if next is null end

	# Close the file
    	li $v0, 16                # Syscall to close file
    	move $a0, $t0             # File descriptor
    	syscall
    	
    	# restore $ra
    	lw $ra, 0($sp)
    	addi $sp, $sp, 4
	jr $ra
	
	
# Convert float to string
# Arguments:
# $f12 - float value to convert
# $a1 - address of buffer to store the string
# Returns:
# $v1 = the length of string store at buffer
FloatToString:

    	
    	cvt.w.s $f0, $f12   	# Convert float in $f12 to integer in $f0
    	cvt.s.w $f2,$f0
    	sub.s $f1,$f12 ,$f2 
    	lwc1 $f2, multiplier
    	mul.s $f1, $f2, $f1  	# Subtract the truncated float from the original float to get the fraction part
    	mfc1 $t0, $f0       	# Move the integer to $t0
    	li $v1,0
    
    	# Convert integer to string 
    	li $t2, 10          # Prepare divisor
    	move $t3, $a1       # Start of digits

    	loopToConvertIntToString:
    		div $t0, $t2
    		mflo $t0
    		mfhi $t1            	# Remainder (digit)
    		addiu $t1, $t1, '0' 	# Convert to ASCII
    		sb $t1, 0($t3)
    		addiu $t3, $t3, 1
    		addiu $v1, $v1, 1
    		bnez $t0, loopToConvertIntToString

     		move $t4,$t3
    		# Reverse the string
    		addiu $t3, $t3, -1  # Set $t3 to last valid character
    	reverseResult:
    		lbu $t1, 0($a1)     # Load byte from start
    		lbu $t2, 0($t3)     # Load byte from end
    		sb $t2, 0($a1)      # Store end at start
    		sb $t1, 0($t3)      # Store start at end
    		addiu $a1, $a1, 1
    		addiu $t3, $t3, -1
    		blt $a1, $t3, reverseResult

    		li $t1, 46
    		sb $t1, 0($t4)	
    		addiu $v1, $v1, 1	
    	
    		cvt.w.s $f1, $f1
		mfc1 $t0, $f1       	# Move the fraction to $t0
		li $t2, 10
		div $t0, $t2          	# Prepare divisor
		mflo $t0
    		mfhi $t1
    		addiu $t0, $t0, '0' 	# Convert to ASCII
    		addiu $t1, $t1, '0' 	# Convert to ASCII
    		sb $t0, buffer($v1)
    		addiu $v1, $v1, 1
    		sb $t1, buffer($v1)
    		addiu $v1, $v1, 1
    		
   
    	jr $ra              # Return 
