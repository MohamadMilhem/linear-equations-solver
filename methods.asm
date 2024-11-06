.data 

#Menu Massges
welcomeMessage: .asciiz "\nWelcome, please choose on the following options (from 1 to 2) or press E or e to exit.\n"
readFileMessage: .asciiz "1. Read input File.\n"
printAnswersMessage: .asciiz "2. Print answers.\n"


# Debug messages
reachReadfile : .asciiz "Reached ReadFile.\n"
reachPrintAnswers: .asciiz "Reached printAnswers.\n"


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


# reading file.
readFile:
	la $a0, reachReadfile
	li $v0, 4
	syscall 
	jr $ra
	
# printing answers
printAnswers:
	la $a0, reachPrintAnswers
	li $v0, 4
	syscall 
	jr $ra
