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
        add $t0, $0, 0 #initialize the $t0 register
        add $t1, $0, 0 #initialize the $t1 register

        la $t2, userInput #put string addr into $t2 register
        lb $t0, 0($t2)
        beq $t0, 10, stringEmpty #check if string is enpty
        beq $t0, 0 stringEmpty

        addi $s0, $0, 35 #store number
        addi $t3, $0, 1 #iniialize new registers
        addi $t4, $0, 0
        addi $t5, $0, 0

        ignoreHoles:
            lb $t0, 0($t2) #put address in $t2 into $t0
            addi $t2, $t2, 1 #increment pointer
            addi $t1, $t1, 1 #increment counter
            beq $t0, 32, ignoreSpaces #if equal jump to ignoreHoles branch 
            beq $t0, 10, isEmpty #if equal jump to stringEmpty branch 
            beq $t0, $0, isEmpty #if equal jump to stringEmpty branch 

        lookCharacters:
            lb $t0, 0($t2)
            addi $t2, $t2, 1
            addi $t1, $t1, 1
            beq $t0, 10, restart
            beq $t0, 0, restart
            bne $t0, 32, lookCharacters
            
         lookRemaining:
            lb $t0, 0($t2)
            addi $t2, $t2, 1
            addi $t1, $t1, 1
            beq $t0, 10, restart
            beq $t0, 0, restart
            bne $t0, 32, stringInvalid #if not equal jump to stringInvalid branch
            j lookRemaining

        restart:
            sub $t2, $t2, $t1 #restart pointer
            la $t1, 0 #restart counter

        continue:
            lb $t0, 0($t2)
            addi $t2, $t2, 1
            beq $t0, 32, continue
            addi $t2, $t2, -1

        inputLength:
            lb $t0, ($t2)
            addi $t2, $t2, 1
            addi $t1, $t1, 1
            beq $t0, 10, conversionfunc
            beq $t0, 0, conversionfunc
            beq $t0, 32, conversionfunc
            beq $t1, 5, stringTooLong
            j inputLength
            
  conversionfunc:
    sub $t2, $t2, $t1 #move pointer to start of string
    addi $sp, $sp, -4 #allocate memory for stack
    sw $ra, 0($sp) #return address
    move $a0, $t2
    li $a1, 3 #string length  
    li $a2, 1 #exponential base
    jal BaseTen #function call

    #print result
    move $a0, $v0