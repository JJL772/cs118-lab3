.section .data

msg: .ascii "PLEASE enter your name: "
.equ len,.-msg

msg2: .ascii "Error no special characters allowed: "
.equ len2,.-msg2

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
	
	movq %rbp, %rsp
	pop %rbp #function epilogue
	movl $60, %eax
	syscall #exit
