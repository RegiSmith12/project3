.data
    emptyInput: .asciiz "Input is empty." #if string input is empty
    longInput: .asciiz "Input it is too long." #if string has over 4 charcters
    invalidInput: .asciiz "Invalid base-35 number." #if string has characters not in set
    userInput: .space 1000