.section .data

# Message used to ask for a contiue or not
cont_msg: .ascii "Would you like to do this again?"
.equ cont_msg_len,.-cont_msg

# First message to prompt for name
msg: .ascii "PLEASE enter your name: "
.equ len,.-msg

# Second message to display an error
msg2: .ascii "\rError no special characters allowed: "
.equ len2,.-msg2

# Greeting Message
msg3: .ascii "Hello there, "
.equ len3,.-msg3

# Prompt for first number
num1_msg: .ascii "Please enter the first number: "
.equ num1_msg_len,.-num1_msg 

# Prompt for second number
num2_msg: .ascii "Please enter the second number: "
.equ num2_msg_len,.-num2_msg

# Message for the sum of the two integers
sum_msg: .ascii "The sum of your two integers is: "
.equ sum_msg_len,.-sum_msg

# Messsage for the sub message
sub_msg: .ascii "The difference of your two integers is: "
.equ sub_msg_len,.-sub_msg

# Product message
prod_msg: .ascii "The product of your two integers is: "
.equ prod_msg_len,.-prod_msg

# Too big number
toobig: .ascii "That number is too big! Please try again: "
.equ toobig_len,.-toobig

# Multiplication overflow!
mul_overflow: .ascii "Your two integers would have caused an overflow!"
.equ mul_overflow_len,.-mul_overflow

# Message for division
div_msg: .ascii "The quotient of your two integers is: "
.equ div_msg_len,.-div_msg

# Message for division error 
div_zero: .ascii "\rError while dividing: the divisor is 0!"
.equ div_zero_len,.-div_zero

# Message for remainder
rem_msg: .ascii "The remainder between your two integers is: "
.equ rem_msg_len,.-rem_msg

# Message for y/n prompt
yn_msg: .ascii " (y/N): "
.equ yn_msg_len,.-yn_msg

number1: .quad 0
number2: .quad 0

.text

.global _start

_start:
	pushq %rbp
	movq %rsp, %rbp #function prologue

	movl $1, %eax
	movl $1, %edi
	leaq msg, %rsi
	movl $len, %edx
	syscall #prints msg
	
inputname:	
	movl $0, %eax
	movl $0, %edi
	leaq -64(%rbp), %rsi
	movl $56, %edx
	syscall #reads input
	movl $1, %eax
	movl $1, %edi
	leaq msg3, %rsi
	movl $len3, %edx
	syscall #prints msg
	movq %rax, %r10 #number of character
	leaq -64(%rbp), %rcx #move pointer to rcx
	
loop:
	cmpb $0x40, (%rcx)
	jbe less
	cmpb $0x60, (%rcx)
	jbe less2
	cmpb $0x7E, (%rcx)
	jbe less3
	jmp loope #check if character is below various characters, otherwise jumps to loope
less:
	cmpb $0x20, (%rcx)
	jae change
	jmp loope #check if character is above 20 (Space), otherwise jumps to loope
less2:
	cmpb $0x5B, (%rcx)
	jae change
	jmp loope #check if character is above 5B ([), otherwise jumps to loope
less3:
	cmpb $0x7B, (%rcx)
	jae change
	jmp loope #check if character is above 7B ({), otherwise jumps to loope
change:
	movl $1, %eax
	movl $1, %edi
	leaq msg2, %rsi
	movl $len2, %edx
	syscall #prints msg
	movq $0, -64(%rbp)
	jmp inputname
loope:
	cmpq $0, %r9
	ja loope2
	andl $0xFFFFFFDF, (%rcx)
	incq %r9
loope2:
	incq %rcx #increases pointer by 1 character
	cmpq %rcx, %rbp
	jae loop #check if rcx passes rbp, if not loops, if it does loops out
	movq %r10, %rdx
	movl $1, %eax
	movl $1, %edi
	leaq -64(%rbp), %rsi
	syscall #echos sentence with character changes

wow_begin_very_cool:
	#=================================#
	# Ask the user for the numbers
	#=================================#
	movl $1, %eax
	movl $1, %edi
	leaq num1_msg, %rsi
	movq $num1_msg_len, %rdx
	syscall

	# Read the first number from the user
	call readnum
	movq %rax, number1

	# Ask for the second number
	movl $1, %eax
	movl $1, %edi
	leaq num2_msg, %rsi
	movq $num2_msg_len, %rdx
	syscall

	# Read the second number from the user
	call readnum
	movq %rax, number2

	#=================================#
	# Print out the sum of the integers
	#=================================#
	movl $1, %eax
	movl $1, %edi 
	leaq sum_msg, %rsi
	movq $sum_msg_len, %rdx
	syscall

	# Now actually add the numbers
	movq number1, %rax
	movq number2, %rbx
	addq %rbx, %rax

	# Call our printing routine
	call printnum

	# Inject a newline
	call newline
	
	#=================================#
	# Print out the difference of the
	# integers
	#=================================#
	movl $1, %eax
	movl $1, %edi
	leaq sub_msg, %rsi
	movq $sub_msg_len, %rdx
	syscall

	# Perform the subtract
	movq number1, %rax
	movq number2, %rbx
	subq %rbx, %rax

	# Call the print
	call printnum
	
	# Inject newline
	call newline
	
	#=================================#
	# Print out the product
	#=================================#
	movl $1, %eax
	movl $1, %edi
	leaq prod_msg, %rsi
	movq $prod_msg_len, %rdx
	syscall

	# Perform the multiplication
	movq number1, %rax
	movq number2, %rbx 
	cltq
	xorl %edx, %edx 
	mulq %rbx

	# Check if there are any overflow-like conditions, if not, let's continue
	cmp $0, %edx 
	jne .mul_ovf 

	call printnum
	call newline
	jmp .div

.mul_ovf:
	movl $1, %eax
	movl $1, %edi
	leaq mul_overflow, %rsi
	movq $mul_overflow_len, %rdx
	syscall

.div:
	#=================================#
	# Print out the quotient/remainder
	#=================================#
	movl $1, %eax
	movl $1, %edi
	leaq div_msg, %rsi
	movq $div_msg_len, %rdx
	syscall

	# Load the numbers again
	movq number1, %rax
	movq number2, %rbx

	# Check that the divisor is not zero
	cmp $0, %rbx
	je .big_error

	# Perform the division
	cltd
	idivl %ebx
	pushq %rdx

	# Print remainder
	call printnum
	call newline

	# Print remainder
	movl $1, %eax
	movl $1, %edi
	leaq rem_msg, %rsi
	movq $rem_msg_len, %rdx
	syscall
	
	popq %rax 
	call printnum  
	call newline 
	jmp exit

.big_error:
	movl $1, %eax
	movl $1, %edi
	leaq div_zero, %rsi
	movq $div_zero_len, %rdx
	syscall 
	call newline # Inject newline
	jmp exit

# Print out a y/n prompt with the message in rdi, len is in rsi
# Return 1 in al if the user put Y, else 0
yn_prompt:
	pushq %rbp
	movq %rsp, %rbp
	
	# Print out the user specific prompt 
	movl $1, %eax
	movq %rsi, %rdx
	movq %rdi, %rsi
	movl $1, %edi 
	syscall

	# Print out the y/n prompt
	movl $1, %eax
	movl $1, %edi
	leaq yn_msg, %rsi
	movq $yn_msg_len, %rdx
	syscall

	# Get one char from stdin
	call getch 

	# Convert to upper and compare
	orb $0x40, %al
	cmp $'y', %al
	# If user entered y, then return 1
	je .yes_yn_prompt
	# Else, return 0
	movb $0, %al
	jmp .done_yn_prompt
	
.yes_yn_prompt:
	movb $1, %al
.done_yn_prompt:
	popq %rbp 
	ret

# getch aka getchar
getch:
	pushq %rbp
	movq %rsp, %rbp

	# Read a single letter from the command line
	# We actually read into a giant prompt here since it's a good idea
	# to not leave stuff in the input buffer
	movl $0, %eax
	movl $0, %edi
	movl $128, %edx
	leaq -128(%rbp), %rsi
	syscall 

	# Store the value we just grabbed
	movb -128(%rbp), %al

	pop %rbp
	ret

# Simply prints a newline 
newline:
	pushq %rbp
	movq %rsp, %rbp 
	# Just print a newline
	movl $1, %eax
	movl $1, %edi
	movl $1, %edx
	movb $0xa, -1(%rbp)
	leaq -1(%rbp), %rsi
	syscall
	popq %rbp
	ret

# String pointer in rsi, length in rdi
print:
	pushq %rbp
	movq %rsp, %rbp
	# Print
	movl $1, %eax
	movl %edi, %edx 
	movl $1, %edi
	syscall 
	popq %rbp
	ret

# Function to read a number
readnum:
	pushq %rbp
	movq %rsp, %rbp
.restart:
	xorq %r15, %r15
	movl $0, %eax
	movl $0, %edi
	leaq -127(%rbp), %rsi
	movl $127, %edx
	syscall

	subq $1, %rax 
	leaq -128(%rbp), %rsi
	cmpb $'-', 1(%rsi)
	jne .cont
	addq $1, %rsi
	subq $1, %rax
	movq $1, %r15
.cont:
	addq %rax, %rsi
	movq %rax, %r10 # This will be used as a counter
	# Perform an xor to clear the regs
	xorl %eax, %eax
	xorl %ecx, %ecx
	movq $1, %r13 
	movb (%rsi), %al
	subb $0x30, %al
.numloop:
	decq %r10
	# Multiply the value in al by r13
	mulq %r13
	# Add it to rcx
	addl %eax, %ecx
	jc .toobig
	# If the counter is zero, we're done
	cmp $0, %r10
	je .done
	# Decrement counter & rsi
	#decq %r10
	decq %rsi
	# Do a multiplication of r13 * 10
	movq %r13, %rax
	movq $10, %r12
	mulq %r12
	movq %rax, %r13
	movl $0, %eax
	# Get the next char ready
	movb (%rsi), %al
	subb $0x30, %al
	jmp .numloop
.done:
	# Actually not done, just need to see if it was negative
	cmpq $1, %r15
	jne .reallydone
	# Two's complement of rcx
	negq %rcx
.reallydone:
	movq %rcx, %rax
	popq %rbp
	ret

.toobig:
	movl $1, %eax
	movl $1, %ebx
	movl $toobig_len, %edx
	leaq toobig, %rsi
	syscall
	jmp .restart
# Function to print a number,
# The number to print is in rax
printnum:
	pushq %rbp
	movq %rsp, %rbp
	# Clear rdx
	xorl %edx, %edx 
	# Move 10 to rbx 
	movq $10, %rbx
	movq %rbp, %rcx
	decq %rcx 
	xorq %r15, %r15 
	# Sign extend and check if negative
	cmpl $0, %eax
	jge .printloop
	# So it's negative...
	negq %rax
	movq $1, %r15 
.printloop:
	movq $10, %r14
	divq %r14 
	addb $0x30, %dl
	movb %dl, (%rcx)
	xorl %edx, %edx
	# If the quotient is zero, stop
	cmpl $0, %eax
	je .doprint
	decq %rcx
	jmp .printloop
.doprint:
	# Handle if negative
	cmpq $0, %r15
	je .finishprint
	decq %rcx 
	movb $'-', (%rcx)
.finishprint:
	movl $1, %eax
	movl $1, %edi
	leaq (%rcx), %rsi
	movq %rbp, %r10
	subq %rcx, %r10
	movq %r10, %rdx
	syscall
	popq %rbp
	ret

exit:
	leaq cont_msg, %rdi
	movq $cont_msg_len, %rsi
	subq $128, %rsp
	call yn_prompt
	addq $128, %rsp

	# Continue if result is 1
	cmp $1, %rax 
	je wow_begin_very_cool

	movq %rbp, %rsp
	pop %rbp #function epilogue
	movl $60, %eax
	syscall #exit
