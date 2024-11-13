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
    
    li t0, 0       #result
    li t1, 0       #counter
    
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

    #set the stride (4 bytes)
    slli s3, s3, 2
    slli s4, s4, 2 
    
loop_start:
    # TODO: Add your own implementation
    beq t1, s2, loop_end

    lw t2 ,0(s0)    # load the value of first array
    lw t3 ,0(s1)    # load the value of second array
    #use the multiply.s
    addi sp, sp, -8         
    sw a1, 0(sp)            
    sw a2, 4(sp)     
    mv a1, t2       #set the multiplicand
    mv a2, t3       #set the multiplier
    jal multiply

    lw a1, 0(sp)               
    lw a2, 4(sp)               
    addi sp, sp, 8 

    add t0, t0, a0  #updata the result

    add s0, s0, s3  # Skip distance in first array
    add s1, s1, s4  # Skip distance in second array

    addi t1, t1, 1
    j loop_start

    
loop_end:
    mv a0, t0

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
    
error_terminate:
    blt a2, t0, set_error_36
    li a0, 37
    j exit

set_error_36:
    li a0, 36
    j exit
# =======================================================
#multiply function
#Input 
#        a1: multiplicand
#        a2: multiplier
#Output 
#        a0: multiplication result
# =======================================================

multiply:
    addi sp, sp, -8          # Allocate stack space
    sw t0, 0(sp)              # Save t0 to stack
    sw t1, 4(sp)              # Save t1 to stack
    li      t0, 0             # result
multiply_loop:
    andi    t1, a2, 1         # check if the LSB of a2 is 1
    beqz    t1, skip_add      # skip if LSB is zero
    add     t0, t0, a1        # add multiplicand to result

skip_add:
    slli    a1, a1, 1         # left shift multiplicand
    srli    a2, a2, 1         # right shift multiplier
    bnez    a2, multiply_loop # repeat if multiplier is not zero

    mv a0, t0                 # set a0 as the answer

    lw t0, 0(sp)              # Restore t0 from stack
    lw t1, 4(sp)              # Restore t1 from stack
    addi sp, sp, 8           # Deallocate stack space

    ret                        # Return from function

# =======================================================