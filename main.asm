.data

directory: .ascii  "C:\Users\moham\OneDrive\Desktop\Computer Engineering\ENCS4370 (Architecture)\Project1"

# Messages
errorOptNotInRange : .asciiz "\nThe option is not in the valid range.\n"
byeMessage : .asciiz "\nGood Bye!\n"


# Methods addresses
methodsTable:
	.word readFile
	.word printAnswers


.text 
.globl main
main:

menuLoop:
	jal printMenu # print the menu
	
	li $v0, 12    # read option from user console
	syscall

	beq $v0, 101, Exit # check exit condition
	beq $v0, 69, Exit
			
	sub $v0, $v0, 48   # convert opt from char to int

	
	slti $t1, $v0, 1 # set if option after conversion is less than 1
	
	la $ra, menuLoop # Loading the link register with menuloop lable to start from if the next line is executed.
	bne $t1, 0, printErrorOptNotInRange # if opt out range print error and start menu again.
	
	slti $t1, $v0, 3 # set if option is in range [1 -> 2]
	
	la $ra, menuLoop # Loading the link register with menuloop lable to start from if the next line is executed.
	beq $t1, 0, printErrorOptNotInRange  #if opt out range print error and start menu again.
	
	
	# calculating the address of the method which should be called.
	sub $t0, $v0, 1 # convert to zero-based indexing 
	sll $t0, $t0, 2 # Muliply the option by 4 to get address in method table
	

	la $t1, methodsTable # get the method table address
	addu $t0, $t0, $t1   # find the address of method to call.
	
	lw $t0, 0($t0) 	     # load function address.
	jalr $t0
	
	j menuLoop
	
printErrorOptNotInRange:
	la $a0, errorOptNotInRange
	li $v0, 4
	syscall
	jr $ra
	
Exit:
	la $a0, byeMessage
	jal print
	li $v0, 10
	syscall
	
.include "methods.asm"

