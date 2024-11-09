.globl dot

.text
# =======================================================
# FUNCTION: Strided Dot Product Calculator
#
# Calculates sum(arr0[i * stride0] * arr1[i * stride1])
# where i ranges from 0 to (element_count - 1)
#
# Args:
#   a0 (int *): Pointer to first input array
#   a1 (int *): Pointer to second input array
#   a2 (int):   Number of elements to process
#   a3 (int):   Skip distance in first array
#   a4 (int):   Skip distance in second array
#
# Returns:
#   a0 (int):   Resulting dot product value
#
# Preconditions:
#   - Element count must be positive (>= 1)
#   - Both strides must be positive (>= 1)
#
# Error Handling:
#   - Exits with code 36 if element count < 1
#   - Exits with code 37 if any stride < 1
# =======================================================
dot:
    li t0, 1
    blt a2, t0, error_terminate  
    blt a3, t0, error_terminate   
    blt a4, t0, error_terminate  
    
    li t0, 0            
    li t1, 0 
    
    addi sp, sp, -24
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw ra, 20(sp)
    
    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3
    mv s4, a4
 
    slli s3, s3, 2
    slli s4, s4, 2 
    
loop_start:
    beq t0, s2, loop_end
    
    #load the vale of v0
    #use the multiply.s
    mv a1, s3
    mv a2, t0
    jal multiply
    add t2, a0, s0 
    lw t3, 0(t2)
    
    #load the vale of v1  
    #use the multiply.s
    mv a1, s4
    mv a2, t0
    jal multiply
    add t4, a0, s1
    lw t5, 0(t4)
    #multiply two numbers
    #use the multiply.s
    mv a1, t3
    mv a2, t5
    jal multiply
    add t1, t1, a0  
    
    addi t0, t0, 1
    j loop_start
    

    
loop_end:
    mv a0, t1

    # Epilogue
    #Restore sp status
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw ra, 20(sp)
    addi sp, sp, 24
    ret
    
################################multioly function
multiply:

    addi sp, sp, -8         
    sw t0, 0(sp)            
    sw t1, 4(sp)            
    
    li t0, 0                
    li t1, 0

multiply_loop:

    beq t1, a2, multiply_done  
    add t0, t0, a1            
    addi t1, t1, 1             
    j multiply_loop            

multiply_done:
    
    mv a0, t0                  

    lw t0, 0(sp)               
    lw t1, 4(sp)               

    addi sp, sp, 8             

    ret
        
error_terminate:
    blt a2, t0, set_error_36
    li a0, 37
    j exit

set_error_36:
    li a0, 36
    j exit
