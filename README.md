# Assignment2:  Complete Applications

## Part A : Mathematical Functions

### Task 1 : ReLU

* Definition : 
    Implement the `ReLU` function, which applies the transformation:
    $$
        \text{ReLU}(a) = \max(a, 0)
    $$
Each element of the input array will be individually processed by setting negative values to 0.
#### relu.s
First I use a loop to calculate the number of times to the number of elements in the array. In the loop, since each element is 4 bytes, I use `slli t3, t1, 2` to perform the shift. Then update the element address and load it. After reading, determine whether the value is greater than 0 or less than 0. If it is greater than 0, the original value will be retained. If it is less than 0, it will be set to 0, and finally stored back.
```s
.globl relu

.text
# ==============================================================================
# FUNCTION: Array ReLU Activation
#
# Applies ReLU (Rectified Linear Unit) operation in-place:
# For each element x in array: x = max(0, x)
#
# Arguments:
#   a0: Pointer to integer array to be modified
#   a1: Number of elements in array
#
# Returns:
#   None - Original array is modified directly
#
# Validation:
#   Requires non-empty array (length ≥ 1)
#   Terminates (code 36) if validation fails
#
# Example:
#   Input:  [-2, 0, 3, -1, 5]
#   Result: [ 0, 0, 3,  0, 5]
# ==============================================================================
relu:
    li t0, 1             
    blt a1, t0, error     
    li t1, 0             

loop_start:
    # TODO: Add your own implementation
    beq t1 , a1, loop_end               # for t1 from 0 to a1-1
    # Load value every 4 bytes
    slli t3, t1, 2                      # one number has 4 bytes (sizeof(int))
    add t2, t3, a0 
    lw t4, 0(t2)
    
    # if t4 > 0
    bge t4, x0, loop_continue
    # if t4 < 0
    add t4 ,x0, x0
    sw t4, 0(t2)
    
loop_continue:
    addi t1, t1, 1
    j loop_start

loop_end:

    # Epilogue

	ret
error:
    li a0, 36          
    j exit        

```
### Task 2 : ArgMax
* Definition : implement the `argmax` function, which returns the index of the largest element in a given vector. If multiple elements share the largest value, return the smallest index. This function operates on 1D vectors.
#### argmax.s
In the function, I use `t1` as a counter to record the number of times until it matches the number of elements in the array. Each element is checked from small to large in the loop, and the updated the position of the first maximum element is stored in `t3` .
```sas.globl argmax
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
```

### Task 3.1 : Dot Product
* Definition : dot product is an operation that multiplies corresponding components of two vectors and sums the results to yield a scalar.
#### dot.s
In this function, I set `t0` to store the multiplication result and `t1` as a counter to record the number of iterations until it matches the number of elements in the array. I use the `stack pointer (sp)` to store the status. Then use `slli s3, s3, 2` and `slli s4, s4, 2`  to set the stride , as each element is 4 bytes. In the loop, I use the multiplier function named [`multiply`](#multiply-function)  to replace the `mul` instruction. Update the address of the load element after completing the multiplication.
```s
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
```
#### multiply function 
The function uses a shift-and-add approach for multiplication. In this function, input a1 as multiplicand and input a2 as multiplier, and it will return the multiplication result in a0.
```s
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
```
### Task 3.2 : Matrix Multiplication
* Definition : 
    * matrix multiplication：
$$
    C[i][j] = dot(A[i], B[:, j])
$$
Given matrices  $A$  (size  $n$ x $m$)和 $B$  (size  $m$ x $k$)，the output matrix $C$ will have dimensions $n$ x $k$ .

#### matmul.s
In this function, it is divided into an `outer loop` and an `inner loop`. The `outer loop` is calculated for the row position of the `first matrix`. `s0` is used to record which row of the first matrix should be opened from which to perform the dot product operation. The `inner loop` is The circled part uses `s1` to record which field should be used to perform dot product calculations.
```S
.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication Implementation
#
# Performs operation: D = M0 × M1
# Where:
#   - M0 is a (rows0 × cols0) matrix
#   - M1 is a (rows1 × cols1) matrix
#   - D is a (rows0 × cols1) result matrix
#
# Arguments:
#   First Matrix (M0):
#     a0: Memory address of first element
#     a1: Row count
#     a2: Column count
#
#   Second Matrix (M1):
#     a3: Memory address of first element
#     a4: Row count
#     a5: Column count
#
#   Output Matrix (D):
#     a6: Memory address for result storage
#
# Validation (in sequence):
#   1. Validates M0: Ensures positive dimensions
#   2. Validates M1: Ensures positive dimensions
#   3. Validates multiplication compatibility: M0_cols = M1_rows
#   All failures trigger program exit with code 38
#
# Output:
#   None explicit - Result matrix D populated in-place
# =======================================================
matmul:
    # Error checks
    li t0 1
    blt a1, t0, error
    blt a2, t0, error
    blt a4, t0, error
    blt a5, t0, error
    bne a2, a4, error

    # Prologue
    addi sp, sp, -28
    sw ra, 0(sp)
    
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    
    li s0, 0 # outer loop counter
    li s1, 0 # inner loop counter
    mv s2, a6 # incrementing result matrix pointer
    mv s3, a0 # incrementing matrix A pointer, increments durring outer loop
    mv s4, a3 # incrementing matrix B pointer, increments during inner loop 
    
outer_loop_start:
    #s0 is going to be the loop counter for the rows in A
    li s1, 0
    mv s4, a3
    blt s0, a1, inner_loop_start

    j outer_loop_end
    
inner_loop_start:
# HELPER FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0  
#   a1 (int*) is the pointer to the start of arr1  
#   a2 (int)  is the number of elements to use = number of columns of A, or number of rows of B 
#   a3 (int)  is the stride of arr0 = for A, stride = 1 
#   a4 (int)  is the stride of arr1 = for B, stride = len(rows) - 1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
    beq s1, a5, inner_loop_end

    addi sp, sp, -24
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    
    mv a0, s3 # setting pointer for matrix A into the correct argument value
    mv a1, s4 # setting pointer for Matrix B into the correct argument value
    mv a2, a2 # setting the number of elements to use to the columns of A
    li a3, 1 # stride for matrix A
    mv a4, a5 # stride for matrix B
    
    jal dot
    
    mv t0, a0 # storing result of the dot product into t0
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    addi sp, sp, 24
    
    sw t0, 0(s2)
    addi s2, s2, 4 # Incrememtning pointer for result matrix
    
    li t1, 4
    add s4, s4, t1 # incrememtning the column on Matrix B
    
    addi s1, s1, 1
    j inner_loop_start
    
inner_loop_end:
    # TODO: Add your own implementation
    addi s0, s0, 1          # update outer loop counter
    slli t2, a2, 2          # change m0 to next row 
    add a0, s3, t2
    mv s3, a0

    j outer_loop_start
    
outer_loop_end:
    
    # Epilogue

    #Restore sp status
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    addi sp, sp, 28
    
    jr ra

error:
    li a0, 38
    j exit

```
### Task 4 : Absolute Value
* Definition :
The absolute value of a number is its distance from zero on the number line, regardless of direction. For any real number x, the absolute value is defined as:

$$|x| = \begin{cases}
x, & \text{if } x \geq 0 \\
-x, & \text{if } x < 0
\end{cases}$$

#### abs.s
use `nge` to negate the number.
```s
.globl abs

.text
# =================================================================
# FUNCTION: Absolute Value Converter
#
# Transforms any integer into its absolute (non-negative) value by
# modifying the original value through pointer dereferencing.
# For example: -5 becomes 5, while 3 remains 3.
#
# Args:
#   a0 (int *): Memory address of the integer to be converted
#
# Returns:
#   None - The operation modifies the value at the pointer address
# =================================================================
abs:
    # Prologue
    ebreak
    # Load number from memory
    lw t0, 0(a0)
    bge t0, zero, done

    # TODO: Add your own implementation
    neg t0, t0           #Negate the number
    sw t0, 0(a0)
done:
    # Epilogue
    jr ra
```
## Part B : File Operations and Main

### Task 1 : Read Matrix
implement the function to read a binary matrix from a file and load it into memory. If any file operation fails, exit with the following codes:
* 26: Malloc error
* 27: fopen error
* 29: fread error
* 28: fclose error
#### read_matrix.s
Instead of using the `mul` instruction, uses a shift-and-add approach for multiplication.
```s
.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Binary Matrix File Reader
#
# Loads matrix data from a binary file into dynamically allocated memory.
# Matrix dimensions are read from file header and stored at provided addresses.
#
# Binary File Format:
#   Header (8 bytes):
#     - Bytes 0-3: Number of rows (int32)
#     - Bytes 4-7: Number of columns (int32)
#   Data:
#     - Subsequent 4-byte blocks: Matrix elements
#     - Stored in row-major order: [row0|row1|row2|...]
#
# Arguments:
#   Input:
#     a0: Pointer to filename string
#     a1: Address to write row count
#     a2: Address to write column count
#
#   Output:
#     a0: Base address of loaded matrix
#
# Error Handling:
#   Program terminates with:
#   - Code 26: Dynamic memory allocation failed
#   - Code 27: File access error (open/EOF)
#   - Code 28: File closure error
#   - Code 29: Data read error
#
# Memory Note:
#   Caller is responsible for freeing returned matrix pointer
# ==============================================================================
read_matrix:
    
    # Prologue
    addi sp, sp, -40
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)

    mv s3, a1         # save and copy rows
    mv s4, a2         # save and copy cols

    li a1, 0

    jal fopen

    li t0, -1
    beq a0, t0, fopen_error   # fopen didn't work

    mv s0, a0        # file

    # read rows n columns
    mv a0, s0
    addi a1, sp, 28  # a1 is a buffer

    li a2, 8         # look at 2 numbers

    jal fread

    li t0, 8
    bne a0, t0, fread_error

    lw t1, 28(sp)    # opening to save num rows
    lw t2, 32(sp)    # opening to save num cols

    sw t1, 0(s3)     # saves num rows
    sw t2, 0(s4)     # saves num cols

    # mul s1, t1, t2   # s1 is number of elements
    # FIXME: Replace 'mul' with your own implementation
    #use the multiply.s
    mv a1, t1
    mv a2, t2
    jal multiply
    mv s1, a0
    slli t3, s1, 2
    sw t3, 24(sp)    # size in bytes

    lw a0, 24(sp)    # a0 = size in bytes

    jal malloc

    beq a0, x0, malloc_error

    # set up file, buffer and bytes to read
    mv s2, a0        # matrix
    mv a0, s0
    mv a1, s2
    lw a2, 24(sp)

    jal fread

    lw t3, 24(sp)
    bne a0, t3, fread_error

    mv a0, s0

    jal fclose

    li t0, -1

    beq a0, t0, fclose_error

    mv a0, s2

    # Epilogue

    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 40

    jr ra

malloc_error:
    li a0, 26
    j error_exit

fopen_error:
    li a0, 27
    j error_exit

fread_error:
    li a0, 29
    j error_exit

fclose_error:
    li a0, 28
    j error_exit

error_exit:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 40
    j exit
```
### Task 2 : Write Matrix
implement the function to write a matrix to a binary file. Use the following exit codes for errors:
* 27: fopen error
* 30: fwrite error
* 28: fclose error
#### write_matrix.s
Instead of using the `mul` instruction, uses a shift-and-add approach for multiplication.
```s
.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Write a matrix of integers to a binary file
# FILE FORMAT:
#   - The first 8 bytes store two 4-byte integers representing the number of 
#     rows and columns, respectively.
#   - Each subsequent 4-byte segment represents a matrix element, stored in 
#     row-major order.
#
# Arguments:
#   a0 (char *) - Pointer to a string representing the filename.
#   a1 (int *)  - Pointer to the matrix's starting location in memory.
#   a2 (int)    - Number of rows in the matrix.
#   a3 (int)    - Number of columns in the matrix.
#
# Returns:
#   None
#
# Exceptions:
#   - Terminates with error code 27 on `fopen` error or end-of-file (EOF).
#   - Terminates with error code 28 on `fclose` error or EOF.
#   - Terminates with error code 30 on `fwrite` error or EOF.
# ==============================================================================
write_matrix:
    # Prologue
    addi sp, sp, -44
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)

    # save arguments
    mv s1, a1        # s1 = matrix pointer
    mv s2, a2        # s2 = number of rows
    mv s3, a3        # s3 = number of columns

    li a1, 1

    jal fopen

    li t0, -1
    beq a0, t0, fopen_error   # fopen didn't work

    mv s0, a0        # file descriptor

    # Write number of rows and columns to file
    sw s2, 24(sp)    # number of rows
    sw s3, 28(sp)    # number of columns

    mv a0, s0
    addi a1, sp, 24  # buffer with rows and columns
    li a2, 2         # number of elements to write
    li a3, 4         # size of each element

    jal fwrite

    li t0, 2
    bne a0, t0, fwrite_error

    # mul s4, s2, s3   # s4 = total elements
    # FIXME: Replace 'mul' with your own implementation
    #use the multiply.s
    mv a1, s2
    mv a2, s3
    jal multiply
    mv s4, a0
    # write matrix data to file
    mv a0, s0
    mv a1, s1        # matrix data pointer
    mv a2, s4        # number of elements to write
    li a3, 4         # size of each element

    jal fwrite

    bne a0, s4, fwrite_error

    mv a0, s0

    jal fclose

    li t0, -1
    beq a0, t0, fclose_error

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 44

    jr ra
     
fopen_error:
    li a0, 27
    j error_exit

fwrite_error:
    li a0, 30
    j error_exit

fclose_error:
    li a0, 28
    j error_exit

error_exit:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 44
    j exit
```
### Task 3 : Classification
In `classify.s`, bring everything together to classify an input using two weight matrices and the ReLU and ArgMax functions. Use the following sequence:
* 1. Matrix Multiplication:
    $hidden$_$layer$ $= matmul(m0,input)$
* 2. ReLU Activation:
    $relu(hidden$_$layer)$
* 3. Second Matrix Multiplication:
    $scores = matmul(m1, hidden$_layer)$
* 4. Classification:
    Call `argmax` to find the index of the higest score.
#### classify.s
Instead of using the `mul` instruction, uses a shift-and-add approach for multiplication.

```s
.globl classify

.text
# =====================================
# NEURAL NETWORK CLASSIFIER
# =====================================
# Description:
#   Command line program for matrix-based classification
#
# Command Line Arguments:
#   1. M0_PATH      - First matrix file location
#   2. M1_PATH      - Second matrix file location
#   3. INPUT_PATH   - Input matrix file location
#   4. OUTPUT_PATH  - Output file destination
#
# Register Usage:
#   a0 (int)        - Input: Argument count
#                   - Output: Classification result
#   a1 (char **)    - Input: Argument vector
#   a2 (int)        - Input: Silent mode flag
#                     (0 = verbose, 1 = silent)
#
# Error Codes:
#   31 - Invalid argument count
#   26 - Memory allocation failure
#
# Usage Example:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
# =====================================
classify:
    # Error handling
    li t0, 5
    blt a0, t0, error_args
    
    # Prolouge
    addi sp, sp, -48
    
    sw ra, 0(sp)
    
    sw s0, 4(sp) # m0 matrix
    sw s1, 8(sp) # m1 matrix
    sw s2, 12(sp) # input matrix
    
    sw s3, 16(sp) # m0 matrix rows
    sw s4, 20(sp) # m0 matrix cols
    
    sw s5, 24(sp) # m1 matrix rows
    sw s6, 28(sp) # m1 matrix cols
     
    sw s7, 32(sp) # input matrix rows
    sw s8, 36(sp) # input matrix cols
    sw s9, 40(sp) # h
    sw s10, 44(sp) # o
    
    # Read pretrained m0
    
    addi sp, sp, -12
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, rows
    beq a0, x0, error_malloc
    mv s3, a0 # save m0 rows pointer for later
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, cols
    beq a0, x0, error_malloc
    mv s4, a0 # save m0 cols pointer for later
    
    lw a1, 4(sp) # restores the argument pointer
    
    lw a0, 4(a1) # set argument 1 for the read_matrix function  
    mv a1, s3 # set argument 2 for the read_matrix function
    mv a2, s4 # set argument 3 for the read_matrix function
    
    jal read_matrix
    
    mv s0, a0 # setting s0 to the m0, aka the return value of read_matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    
    addi sp, sp, 12
    # Read pretrained m1
    
    addi sp, sp, -12
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, rows
    beq a0, x0, error_malloc
    mv s5, a0 # save m1 rows pointer for later
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, cols
    beq a0, x0, error_malloc
    mv s6, a0 # save m1 cols pointer for later
    
    lw a1, 4(sp) # restores the argument pointer
    
    lw a0, 8(a1) # set argument 1 for the read_matrix function  
    mv a1, s5 # set argument 2 for the read_matrix function
    mv a2, s6 # set argument 3 for the read_matrix function
    
    jal read_matrix
    
    mv s1, a0 # setting s1 to the m1, aka the return value of read_matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    
    addi sp, sp, 12

    # Read input matrix
    
    addi sp, sp, -12
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, rows
    beq a0, x0, error_malloc
    mv s7, a0 # save input rows pointer for later
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, cols
    beq a0, x0, error_malloc
    mv s8, a0 # save input cols pointer for later
    
    lw a1, 4(sp) # restores the argument pointer
    
    lw a0, 12(a1) # set argument 1 for the read_matrix function  
    mv a1, s7 # set argument 2 for the read_matrix function
    mv a2, s8 # set argument 3 for the read_matrix function
    
    jal read_matrix
    
    mv s2, a0 # setting s2 to the input matrix, aka the return value of read_matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    
    addi sp, sp, 12

    # Compute h = matmul(m0, input)
    addi sp, sp, -28
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    
    lw t0, 0(s3)
    lw t1, 0(s8)
    
    #mul a0, t0, t1 # FIXME: Replace 'mul' with your own implementation
    addi sp, sp, -8         
    sw a1, 0(sp)            
    sw a2, 4(sp)     
    mv a1, t0
    mv a2, t1
    jal multiply

    lw a1, 0(sp)               
    lw a2, 4(sp)               
    addi sp, sp, 8 
    
    slli a0, a0, 2
    jal malloc 
    beq a0, x0, error_malloc
    mv s9, a0 # move h to s9
    
    mv a6, a0 # h 
    
    mv a0, s0 # move m0 array to first arg
    lw a1, 0(s3) # move m0 rows to second arg
    lw a2, 0(s4) # move m0 cols to third arg
    
    mv a3, s2 # move input array to fourth arg
    lw a4, 0(s7) # move input rows to fifth arg
    lw a5, 0(s8) # move input cols to sixth arg
    
    jal matmul
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    
    addi sp, sp, 28
    
    # Compute h = relu(h)
    addi sp, sp, -8
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    
    mv a0, s9 # move h to the first argument
    lw t0, 0(s3)
    lw t1, 0(s8)
    
    #mul a1, t0, t1 # length of h array and set it as second argument
    # FIXME: Replace 'mul' with your own implementation
    addi sp, sp, -8         
    sw a0, 0(sp)           
    sw a2, 4(sp)     
    mv a1, t0
    mv a2, t1
    jal multiply
    mv a1, a0
    lw a0, 0(sp)             
    lw a2, 4(sp)               
    addi sp, sp, 8 

    jal relu
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    
    addi sp, sp, 8
    
    # Compute o = matmul(m1, h)
    addi sp, sp, -28
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    
    lw t0, 0(s3)
    lw t1, 0(s6)
    
    #mul a0, t0, t1 # FIXME: Replace 'mul' with your own implementation
    addi sp, sp, -8         
    sw a1, 0(sp)            
    sw a2, 4(sp)     
    mv a1, t0
    mv a2, t1
    jal multiply

    lw a1, 0(sp)               
    lw a2, 4(sp)               
    addi sp, sp, 8 
    
    slli a0, a0, 2
    jal malloc 
    beq a0, x0, error_malloc
    mv s10, a0 # move o to s10
    
    mv a6, a0 # o
    
    mv a0, s1 # move m1 array to first arg
    lw a1, 0(s5) # move m1 rows to second arg
    lw a2, 0(s6) # move m1 cols to third arg
    
    mv a3, s9 # move h array to fourth arg
    lw a4, 0(s3) # move h rows to fifth arg
    lw a5, 0(s8) # move h cols to sixth arg
    
    jal matmul
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    
    addi sp, sp, 28
    
    # Write output matrix o
    addi sp, sp, -16
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    
    lw a0, 16(a1) # load filename string into first arg
    mv a1, s10 # load array into second arg
    lw a2, 0(s5) # load number of rows into fourth arg
    lw a3, 0(s8) # load number of cols into third arg
    
    jal write_matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    
    addi sp, sp, 16
    
    # Compute and return argmax(o)
    addi sp, sp, -12
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    mv a0, s10 # load o array into first arg
    lw t0, 0(s3)
    lw t1, 0(s6)
    
    #mul a1, t0, t1 # load length of array into second arg
    # FIXME: Replace 'mul' with your own implementation
    addi sp, sp, -8         
    sw a0, 0(sp)            
    sw a2, 4(sp)     
    mv a1, t0
    mv a2, t1
    jal multiply
    mv a1, a0
    
    lw a0, 0(sp)               
    lw a2, 4(sp)               
    addi sp, sp, 8 
    
    jal argmax
    
    mv t0, a0 # move return value of argmax into t0
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    
    addi sp, sp 12
    
    mv a0, t0

    # If enabled, print argmax(o) and newline
    bne a2, x0, epilouge
    
    addi sp, sp, -4
    sw a0, 0(sp)
    
    jal print_int
    li a0, '\n'
    jal print_char
    
    lw a0, 0(sp)
    addi sp, sp, 4
    
    # Epilouge
epilouge:
    addi sp, sp, -4
    sw a0, 0(sp)
    
    mv a0, s0
    jal free
    
    mv a0, s1
    jal free
    
    mv a0, s2
    jal free
    
    mv a0, s3
    jal free
    
    mv a0, s4
    jal free
    
    mv a0, s5
    jal free
    
    mv a0, s6
    jal free
    
    mv a0, s7
    jal free
    
    mv a0, s8
    jal free
    
    mv a0, s9
    jal free
    
    mv a0, s10
    jal free
    
    lw a0, 0(sp)
    addi sp, sp, 4

    lw ra, 0(sp)
    
    lw s0, 4(sp) # m0 matrix
    lw s1, 8(sp) # m1 matrix
    lw s2, 12(sp) # input matrix
    
    lw s3, 16(sp) 
    lw s4, 20(sp)
    
    lw s5, 24(sp)
    lw s6, 28(sp)
    
    lw s7, 32(sp)
    lw s8, 36(sp)
    
    lw s9, 40(sp) # h
    lw s10, 44(sp) # o
    
    addi sp, sp, 48
    
    jr ra

error_args:
    li a0, 31
    j exit

error_malloc:
    li a0, 26
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

```
## Test Result
### .test.sh all
```s
test_abs_minus_one (__main__.TestAbs.test_abs_minus_one) ... ok
test_abs_one (__main__.TestAbs.test_abs_one) ... ok
test_abs_zero (__main__.TestAbs.test_abs_zero) ... ok
test_argmax_invalid_n (__main__.TestArgmax.test_argmax_invalid_n) ... ok
test_argmax_length_1 (__main__.TestArgmax.test_argmax_length_1) ... ok
test_argmax_standard (__main__.TestArgmax.test_argmax_standard) ... ok
test_chain_1 (__main__.TestChain.test_chain_1) ... ok
test_classify_1_silent (__main__.TestClassify.test_classify_1_silent) ... ok
test_classify_2_print (__main__.TestClassify.test_classify_2_print) ... ok
test_classify_3_print (__main__.TestClassify.test_classify_3_print) ... ok
test_classify_fail_malloc (__main__.TestClassify.test_classify_fail_malloc) ... ok
test_classify_not_enough_args (__main__.TestClassify.test_classify_not_enough_args) ... ok
test_dot_length_1 (__main__.TestDot.test_dot_length_1) ... ok
test_dot_length_error (__main__.TestDot.test_dot_length_error) ... ok
test_dot_length_error2 (__main__.TestDot.test_dot_length_error2) ... ok
test_dot_standard (__main__.TestDot.test_dot_standard) ... ok
test_dot_stride (__main__.TestDot.test_dot_stride) ... ok
test_dot_stride_error1 (__main__.TestDot.test_dot_stride_error1) ... ok
test_dot_stride_error2 (__main__.TestDot.test_dot_stride_error2) ... ok
test_matmul_incorrect_check (__main__.TestMatmul.test_matmul_incorrect_check) ... ok
test_matmul_length_1 (__main__.TestMatmul.test_matmul_length_1) ... ok
test_matmul_negative_dim_m0_x (__main__.TestMatmul.test_matmul_negative_dim_m0_x) ... ok
test_matmul_negative_dim_m0_y (__main__.TestMatmul.test_matmul_negative_dim_m0_y) ... ok
test_matmul_negative_dim_m1_x (__main__.TestMatmul.test_matmul_negative_dim_m1_x) ... ok
test_matmul_negative_dim_m1_y (__main__.TestMatmul.test_matmul_negative_dim_m1_y) ... ok
test_matmul_nonsquare_1 (__main__.TestMatmul.test_matmul_nonsquare_1) ... ok
test_matmul_nonsquare_2 (__main__.TestMatmul.test_matmul_nonsquare_2) ... ok
test_matmul_nonsquare_outer_dims (__main__.TestMatmul.test_matmul_nonsquare_outer_dims) ... ok
test_matmul_square (__main__.TestMatmul.test_matmul_square) ... ok
test_matmul_unmatched_dims (__main__.TestMatmul.test_matmul_unmatched_dims) ... ok
test_matmul_zero_dim_m0 (__main__.TestMatmul.test_matmul_zero_dim_m0) ... ok
test_matmul_zero_dim_m1 (__main__.TestMatmul.test_matmul_zero_dim_m1) ... ok
test_read_1 (__main__.TestReadMatrix.test_read_1) ... ok
test_read_2 (__main__.TestReadMatrix.test_read_2) ... ok
test_read_3 (__main__.TestReadMatrix.test_read_3) ... ok
test_read_fail_fclose (__main__.TestReadMatrix.test_read_fail_fclose) ... ok
test_read_fail_fopen (__main__.TestReadMatrix.test_read_fail_fopen) ... ok
test_read_fail_fread (__main__.TestReadMatrix.test_read_fail_fread) ... ok
test_read_fail_malloc (__main__.TestReadMatrix.test_read_fail_malloc) ... ok
test_relu_invalid_n (__main__.TestRelu.test_relu_invalid_n) ... ok
test_relu_length_1 (__main__.TestRelu.test_relu_length_1) ... ok
test_relu_standard (__main__.TestRelu.test_relu_standard) ... ok
test_write_1 (__main__.TestWriteMatrix.test_write_1) ... ok
test_write_fail_fclose (__main__.TestWriteMatrix.test_write_fail_fclose) ... ok
test_write_fail_fopen (__main__.TestWriteMatrix.test_write_fail_fopen) ... ok
test_write_fail_fwrite (__main__.TestWriteMatrix.test_write_fail_fwrite) ... ok

----------------------------------------------------------------------
Ran 46 tests in 38.184s

OK

```





