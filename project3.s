.data
    emptyString: .asciiz "Input is empty." #if string input is empty
    longString: .asciiz "Input it is too long." #if string has over 4 charcters
    invalidString: .asciiz "Invalid base-35 number." #if string has characters not in set
    userInput: .space 1000
.text
    main:
        li $v0, 8 #read string
        la $a0, userInput #store the address of string
        li $a1, 500 #create enough space for string input
        syscall
        add $t0, $0, 0 #initialize $t0 register
        add $t1, $0, 0 #initialize $t1 register

        la $t2, userInput #load string addr into $t2 register
        lb $t0, 0($t2)