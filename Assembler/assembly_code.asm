main:  
    addi t2,zero,1
    lw a0 , 0(zero)  #initiate input from memory
    addi t0,zero,1   #initiate result to 1
    beq zero,zero, factorial
    add zero,zero,zero  #nop instruction
    add zero,zero,zero  #nop instruction

factorial:
    mul t0,t0, a0 
    addi a0,a0 , -1 
    add zero,zero,zero  #nop instruction
    add zero,zero,zero  #nop instruction
    bne a0,t2,factorial 
   





