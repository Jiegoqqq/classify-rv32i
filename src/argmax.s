.globl argmax

.text
# =================================================================
# FUNCTION: Maximum Element First Index Finder
#
# Scans an integer array to find its maximum value and returns the
# position of its first occurrence. In cases where multiple elements
# share the maximum value, returns the smallest index.
#
# Arguments:
#   a0 (int *): Pointer to the first element of the array
#   a1 (int):  Number of elements in the array
#
# Returns:
#   a0 (int):  Position of the first maximum element (0-based index)
#
# Preconditions:
#   - Array must contain at least one element
#
# Error Cases:
#   - Terminates program with exit code 36 if array length < 1
# =================================================================
argmax:
    li t6, 1
    blt a1, t6, handle_error

    lw t0, 0(a0)
    
    li t1, 0 #counter to end
    li t2, 1  
    
    slli t2, t2, 1                  # set t2=2
    add t3, x0, x0                  # set t3 to record maximum index
    
loop_start:
    beq t1, a1, loop_end
    sll t4, t1, t2
    add t4, t4, a0
    lw t5, 0(t4)
    
    ble t5, t0, loop_continue
    mv t0, t5                       # update the maximum value
    mv t3, t1                       # update the maximum index
    
loop_continue:
    addi t1, t1, 1
    j loop_start

loop_end:
    mv a0, t3                       # return the maximum index
    
    ret
    
handle_error:
    li a0, 36
    j exit
