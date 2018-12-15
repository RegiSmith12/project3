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
            beq $t0, 32, ignoreHoles #if equal jump to ignoreHoles branch 
            beq $t0, 10, stringEmpty #if equal jump to stringEmpty branch 
            beq $t0, $0, stringEmpty #if equal jump to stringEmpty branch 

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
    li $v0, 1
    syscall
    
    lw $ra, 0($sp) 
    addi $sp, $sp, 4 #deallocate memory
    jr $ra
    
      end:
        move $a0, $t5 #move number to $a0
        li $v0, 1 #print number
        syscall
        li $v0, 10 #end program
        syscall
        
      stringTooLong:
           la $a0, longString #load message
           li $v0, 4 #print message
           syscall
           
           li $v0, 10 #end program
           syscall
           
      stringEmpty:
            la $a0, emptyString #load message
            li $v0, 4 #print message
            syscall

            li $v0, 10 #end program
            syscall
            
      stringInvalid:
            la $a0, invalidString #load message
             li $v0, 4 #prints message
            syscall

            li $v0, 10 #end program
            syscall

            jr $ra
            
      Base10:
   	   addi $sp, $sp, -8 #allocate memory for stack
   	   sw $ra, 0($sp) #store the return address
    	   sw $s3, 4($sp) #store the s register
    	   beq $a1, $0, return_zero #base case
    	   addi $a1, $a1, -1 #length = -1 so it starts at the end of string
           add $t0, $a0, $a1 #get address of the last byte 
    	   lb $s3, 0($t0)  #load the byte
    	   
    	   #Convert byte to digit
    	   
    	   #asciiConversions:
              blt $s3, 48, stringInvalid #the string is invalid if character is before 0 in ascii table
              blt $s3, 58, number
              blt $s3, 65, stringInvalid
              blt $s3, 90, upperCase
              blt $s3, 97, stringInvalid
              blt $s3, 122, lowerCase
              blt $s3, 128, isInvalid
              
            lowerCase:
              addi $s3, $s3, -87
              jal More
              
            upperCase:
              addi $s3, $s3, -55
              jal More
              
            number:
              addi $s3, $s3, -48
              jal More
          #mul $s3, $s3, $a2 #multiply the byte x the exponential base (starts at 1(35^0 = 1))
    	  #mul $a2, $a2, 35 #multiply the exponential base by 35 to get next power (35^1 ...)
          More:
            mul $s3, $s3, $a2 #multiply the byte x the exponential base (starts at 1(35^0 = 1))
            mul $a2, $a2, 35 #multiply the exponential base by 35 to get next power (35^1 ...)
            jal BaseTen
    #a0=str addr, a1=strlen, a2=exponential base
    
    #jal BaseTen #call function again (loop)
        add $v0, $s3, $v0   #return last byte and decimal version of the rest of number
        lw $ra, 0($sp)
        lw $s3, 4($sp)
        addi $sp, $sp, 8
        jr $ra
   return_zero:
     li $v0, 0
     lw $ra, 0($sp)
     lw $s3, 4($sp)
     addi $sp, $sp, 8
     jr $ra
            
    