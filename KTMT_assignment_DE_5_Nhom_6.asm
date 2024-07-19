.data
Float_Format:	.asciiz	"%f"
Float_Space:	.asciiz	", "
Closing_Bracket:	.asciiz	"]\n"
Line:			.asciiz	"---------------------------------------------\n"

Print_Unsorted_Array:	.asciiz	"Unsorted Array: ["
Print_Sorted_Array:	.asciiz	"Sorted Array:   ["
Print_Current_Array:	.asciiz	"Current array:  ["

From: 			.asciiz "\nFrom "
To:			.asciiz	" to "
eol:			.asciiz	"\n"

#--------------------------------------------------------------------------------
array_length:		.word 50
my_array: 		.float -962.858, 9818.01, -6477.765, -9240.773, 6011.937, -2761.61, 2715.285, -7458.972, 9994.299, 8655.005, 4596.247, 1883.858, -9528.377, -9118.649, 7176.856, 3151.494, -281.062, 2559.125, -119.249, -4376.422, 9385.195, -1931.018, 9503.287, -2837.743, 7717.346, 521.422, 435.957, -4769.552, -7383.0, 4017.666, -5787.8, -6366.994, 43.75, 6323.169, -6442.651, -9324.26, -6760.675, -6339.054, 7000.495, -4636.416, 4248.967, -4317.137, 9780.658, 4698.3, 9573.222, 5397.591, -6001.695, -9052.361, 701.68, -2462.871
#-------------------------------------------------------------------------------
arr_store_1: 		.space 200
arr_store_2:		.space 200

#----------------------------------------------------------------------------------
.text
main:
	
	jal	print_unsorted_array	# in ra mang chua duoc sap xep
	
	li  	$v0, 4				
	la  	$a0, Line	# Prints -------------------------------
	syscall
	
	#---------------------------------------------------
	# chuan bi cac tham so
	la	$a0, my_array		# a0 luu mang 
	addi	$a1, $a1, 0		# a1 la index 0
	
	lw	$a2, array_length
	subi	$a2, $a2, 1		# a2 la index cuoi cung
	
	addi	$s1, $a1, 0		# s1 s2 se duoc su dung de in current array
	addi	$s2, $a2, 0
	
	#---------------------------------------------------
	jal	Merge_sort		# Merge sort
	
	#---------------------------------------------------
	jal 	print_sorted_array	# in mang da duoc sap xep
	
	#-----------------------------------------------------
	li  	$v0, 10			# ket thuc chuong trinh!
	syscall
#--------------------------------------------------------------------------------------------
# Ham sap xep tron (merge sort)
#
# a0 la mang
# a1 chua low index
# a2 chua high index
Merge_sort:
	beq	$a1, $a2, Stop_sorting	# low = high
					# stop sorting

	# tinh middle index
	add	$a3, $a1, $a2	
	div	$a3, $a3, 2		# a3 = middle index
	
	#	STACKS
	#   --------------
	#   |	ra	|	
	#   |	middle	|
	#   |	high	|
	#   |	low	|
	addi	$sp, $sp, -16	# tao 4 empty trog stack
	sw	$a1, 0($sp)	# luu low vao stack	
	sw	$a2, 4($sp)	# luu high vao stack
	sw	$a3, 8($sp)	# luu middle vao stack
	sw	$ra, 12($sp)	# luu return address vao stack
	
	move	$a2, $a3	# (low, mid)
				# new high = current mid

	# goi ham de quy mersort cho khoi dau tien
	jal	Merge_sort
	
	# sau khi hoan thanh merge sort cho khoi dau tien thi return o day
	
	lw	$a1, 0($sp)	# lay low truoc do ra
	lw	$a2, 4($sp)	# lay high truoc do ra
	lw	$a3, 8($sp)	# lay middle truoc do ra
	
	addi 	$a3, $a3, 1	# middle + 1
	move	$a1, $a3	# (middle + 1, high)
			
	# goi ham de quy mersort cho khoi thu hai
	jal	Merge_sort		

	# sau khi hoan thanh merge sort cho khoi thu hai thi return o day

	lw	$a1, 0($sp)	# lay low truoc do ra
	lw	$a2, 4($sp)	# lay high truoc do ra
	lw	$a3, 8($sp)	# lay middle truoc do ra
	
	# lets merge the array
	jal	Merge_array
	
	lw	$a1, 0($sp)	# lay low truoc do ra
	lw	$a2, 4($sp)	# lay high truoc do ra
	lw	$a3, 8($sp)	# lay middle truoc do ra
	lw	$ra, 12($sp)	# lay return address truoc do ra
	addi	$sp, $sp, 16	# xoa 4 empty da them vao khoi stack
	
	Stop_sorting:
		jr 	$ra

# Ghep 2 mang da duoc sap xep lai voi nhau
# sap xep chung va ghep lai voi nhau
#
# a0 = mang
# a1 = low
# a2 = high
# a3 = middle
Merge_array:
	sw	$a0, 0($sp)	# luu array vao stack de thuc hien viec in current array
	
	# in ra v? trí hi?n t?i
	li	$v0, 4
	la	$a0, From	# From
	syscall
	
	li	$v0, 1
	move	$a0, $a1	# low
	syscall
	
	li	$v0, 4
	la	$a0, To		# to
	syscall
	
	li	$v0, 1
	move	$a0, $a2	# high
	syscall
	
	li	$v0, 4
	la	$a0, eol	# \n
	syscall
	
	
	
	# in vi tri hien tai
	li	$v0, 4
	la	$a0, Print_Current_Array	# Print : "Current Array: ["
	syscall
	
	# lay lai mang de tien hanh merge
	lw	$a0, 0($sp)

	# t0 = N1 = middle - low + 1
	sub	$t0, $a3, $a1
	addi	$t0, $t0, 1
	
	# t1 = N2 = high - mid
	sub	$t1, $a2, $a3

	# t2 = first store array 
	# t3 = second store array
	la	$t2, arr_store_1
	la	$t3, arr_store_2

	# Tao ra 2 temp array de ho tro viec sap xep
	mul	$t4, $a1, 4
	add	$t4, $a0, $t4	# dia chi cua first_array[ low ]
	
	mul	$t5, $a3, 4
	add	$t5, $a0, $t5	# dia chi cua first_array[ mid ]
 
	Copy_first_array_to_store_1:
		slt	$s7, $t5, $t4	# s7 = 0 khi low < mid	
					# s7 = 1 khi low >= mid (da copy het mang)
		bnez	$s7, First_copy_end
		
		lwc1	$f8, 0($t4) 	# lay dia chi first_array[ current ]
		swc1	$f8, 0($t2)	# luu vao first_store[ current ]
	
		addi	$t4, $t4, 4	# tang ca hai len index ke tiep
		addi	$t2, $t2, 4
		
		j	Copy_first_array_to_store_1

		First_copy_end:
			# chuan bi copy mang thu hai
			addi	$s5, $a3, 1	# mid + 1

			mul	$s5, $s5, 4
			add	$t4, $a0, $s5	# dia chi cua second_array[ mid + 1 ]
	
			mul	$s5, $a2, 4
			add	$t5, $a0, $s5	# dia chi cua second_array[ high ]
			
	Copy_second_array_to_store_2:
		slt	$s7, $t5, $t4	# s7 = 0 khi low < mid	
					# s7 = 1 khi low >= mid (da copy het mang)
		bnez	$s7, Second_copy_end
		
		lwc1	$f8, 0($t4)	# lay dia chi second_array[ current ]
		swc1	$f8, 0($t3)	# luu vao second_store[ current ]
		
		addi	$t4, $t4, 4	# tang ca hai len index ke tiep
		addi	$t3, $t3, 4
		
		j	Copy_second_array_to_store_2	
		
		Second_copy_end:
	
	Compare_and_merge:
		# t2 = first store array 
		# t3 = second store array
		la	$t2, arr_store_1
		la	$t3, arr_store_2
	
		# t0 = N1
		# t1 = N2
	
		# luu a0 = array vao trong stack
		sw	$a0, -4($sp)
	
		# khoi tao cho t4 = i = 0
		# va t5 = j = 0
		move	$t4, $0
		move	$t5, $0
	
		# thiet lap cho a0 = array[ low ]
		mul	$t6, $a1, 4
		add	$a0, $a0, $t6
	
		# t0 = N1	t4 = i
		# t1 = N2	t5 = j
		# while (i < N1 && j < N2)
		First_loop_compare_and_insert:
			beq	$t0, $t4, first_loop_end
			beq	$t1, $t5, first_loop_end
		
			lwc1	$f8, 0($t2)	# f8 = arr_store_1[ i ]
			lwc1	$f10, 0($t3)	# f10 = arr_store_2[ j ]
			
			c.lt.s	$f10, $f8	# f10 < f8
			bc1t	Store_2_come_in	# cap nhat array neu phia truoc > phia sau (sai)
			
			# IMPORTANT, CORE CODE---------------------------------------------------------
			swc1	$f8, 0($a0)	# Dua phan tu dung truoc (so be hon) vao array
						# my_array[ current ] = store_1[ i ]
			
			addi	$t2, $t2, 4	# store_1 -> next
			addi	$t4, $t4, 1	# i -> next
						# tien toi phan tu tiep theo cua mang dau tien (dung truoc)
	
			j	go_next_without_j_increase
	
			Store_2_come_in:
				swc1	$f10, 0($a0)	# Dua phan tu dung sau (o array 2nd va < store_1[ current ]) vao array
				addi	$t3, $t3, 4	# store_2 -> next
				addi	$t5, $t5, 1	# j -> next
							# tien toi phan tu tiep theo cua mang thu hai (dung sau)
				
			go_next_without_j_increase:
				addi	$a0, $a0, 4	# my_array[ current ] -> next
				j	First_loop_compare_and_insert
			
			first_loop_end:
	#-----------------------------------------------------------------------------------------------------------------------
		# while (i < N1)
		Second_loop_insert_lef_over_in_store_1:
			beq	$t4, $t0, Second_loop_end
			
			lwc1	$f8, 0($t2)	# lay ra store_1[ current ] 
			swc1	$f8, 0($a0)	# dua vao my_array
			
			addi	$t2, $t2, 4	# store_1 -> next
			addi	$a0, $a0, 4	# my_array -> next
			addi	$t4, $t4, 1	# i++
			
			j	Second_loop_insert_lef_over_in_store_1
			
			Second_loop_end:
#-----------------------------------------------------------------------------------------------------------------------
		# while (j < N2)
		Third_loop_insert_left_over_in_store_2:
			beq	$t1, $t5, Third_loop_end
			
			lwc1	$f8, 0($t3)	# lay ra store_2[ current ]
			swc1	$f8, 0($a0)	# dua vao my_array
		
			addi	$t3, $t3, 4	# store_2 -> next
			addi	$a0, $a0, 4	# my_array -> next
			addi	$t5, $t5, 1	# j++
			
			j 	Third_loop_insert_left_over_in_store_2
		
			Third_loop_end:
				lw	$a0, -4($sp)
				
				addi	$sp, $sp, -12
				sw	$ra, 0($sp)
				sw	$a1, 4($sp)
				sw	$a2, 8($sp)
				add	$a1, $0, $s1
				add	$a2, $0, $s2 
	
				jal	print_current_array
	
				lw	$ra, 0($sp)
			
				lw	$a1, 4($sp)
				lw	$a2, 8($sp)
				addi	$sp, $sp, 12	
	
				jr	$ra	
				
#----------------------------------------------------------------------------------------
# SUPPORT FUNCTIONS
#----------------------------------------------------------------------------------------
print_current_array:
	# a0 -> mang
	# a1 -> low 
	# a2 -> high 
	
	# luu mang vao stack
	sw	$a0, -4($sp)
	
	# t7 = low
	addi	$t7, $a1, 0
	
	# t6 = my_array[ current ]
	mul	$t6, $a1, 4
	add	$t6, $t6, $a0
	
	#li  	$v0, 4				
	#la  	$a0, Line			# Prints -------------------------------
	#syscall
	
	#li  	$v0, 4				
	#la  	$a0, Print_Current_Array	# Print : "Current Array: ["
	#syscall
	
print_current_array_loop:
	slt	$s4, $a2, $t7
	bne	$s4, $0, print_current_array_loop_end
	
	lwc1	$f12, 0($t6)	# load real number to f12
	li	$v0, 2		# syscall to print float
	syscall
	
	beq	$a2, $t7, next_loop
	
	li	$v0, 4		# syscall to print ", "
	la	$a0, Float_Space
	syscall
		
	next_loop:
		addi	$t6, $t6, 4	# my_array -> next
		addi	$t7, $t7, 1	# low ++
	
	j	print_current_array_loop
	
print_current_array_loop_end:
	li  	$v0, 4				
	la  	$a0, Closing_Bracket	# Prints the closing bracket 
	syscall
	
	# lay lai mang va tiep tuc
	lw	$a0, -4($sp)
	jr	$ra
#----------------------------------------------------------------------------------------		
print_unsorted_array:
    li  	$v0, 4				
    la  	$a0, Print_Unsorted_Array	# Print : "Unsorted Array: ["
    syscall

    lw	$t8, array_length
    subi	$t8, $t8, 1			# t8 = length   19
    subi	$s4, $t8, 1			# 18

    li 	$t0, -1				# counter
    la	$t1, my_array

    print_array_loop:
        # thoat neu in ra het tat ca
        bge 	$t0, $t8, exit_print_unsorted
        
        lwc1	$f12, 0($t1)	# load float number to f12
        li	$v0, 2		# syscall to print float
        syscall

        # bo qua dau space cuoi cung
        bge	$t0, $s4, skip_last_unsorted

        # in ra space
        li  	$v0, 4
        la  	$a0, Float_Space
        syscall

    skip_last_unsorted:
        # tang bien dem
        addi    $t0, $t0, 1
        addi    $t1, $t1, 4
        j       print_array_loop

    exit_print_unsorted:
        li  	$v0, 4				
        la  	$a0, Closing_Bracket	# in dau ngoac dong "]"
        syscall

        jr 	$ra

#----------------------------------------------------------------------------------------		
#----------------------------------------------------------------------------------------		
print_sorted_array:
    li  	$v0, 4				
    la  	$a0, Line			# Prints -------------------------------
    syscall

    li  	$v0, 4				
    la  	$a0, Print_Sorted_Array		# Print : "Sorted Array: ["
    syscall

    lw	$t8, array_length
    subi	$t8, $t8, 1
    subi	$s4, $t8, 1

    li 	$t0, -1				# bien dem
    la	$t1, my_array		# su dung array de luu
    
print_sorted_array_loop:
    # thoat neu in ra het
    bge $t0, $t8, exit_print_sorted
    
    # lay dia chi cua array[ index ]
    lwc1	$f12, 0($t1)	# load so thuc vao $f12
    li	$v0, 2		# syscall de in float
    syscall
    
    # bo qua space cuoi cung (beautify purpose)
    bge	$t0, $s4, skip_last_sorted
    
    # in ra space
    li  	$v0, 4				
    la  	$a0, Float_Space	
    syscall
    
skip_last_sorted:
    # tang bien dem
    addi    $t0, $t0, 1
    addi    $t1, $t1, 4
    j     	print_sorted_array_loop

exit_print_sorted:
    li  	$v0, 4				
    la  	$a0, Closing_Bracket		# in dau ngoac dong "]"
    syscall

    jr 	$ra
