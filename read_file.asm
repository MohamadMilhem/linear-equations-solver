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

# Buffers
charBuff: .space 1
floatNumBuff: .space 10
fileBuff: .space 1024

.text
.globl main

main:
    # Load file name address into $a0
    la $a0, fileName
    
    # Open the file
    li $v0, 13          # Open file syscall
    li $a1, 0           # Open file for reading
    syscall
    move $s2, $v0       # Save file descriptor in $s2

    # Check if file opened successfully
    bltz $s2, Exit      # If $s2 is negative, exit program

ReadLine:
    li $v0, 14          # Read from file syscall
    move $a0, $s2       # File descriptor in $a0
    la $a1, fileBuff    # Buffer to store read data
    li $a2, 1024        # Max number of bytes to read
    syscall

    # Print the buffer content
PrintFile: 
    li $v0, 4           # Print string syscall
    la $a0, fileBuff    # Address of buffer
    syscall 
    
PrintChar:
    li $v0, 11
    la $a1, fileBuff
    lb $a0, 4($a1)
    syscall 

CloseFile: 
    li $v0, 16          # Close file syscall
    move $a0, $s2       # File descriptor in $a0
    syscall 

Exit:
    li $v0, 10          # Exit program syscall
    syscall 
