	# address
	lui s1,0xFFFFF
	
start:                                                                         	
loadSw:	
	# sw[7:0] --> a1 操作数B
	lw   s0,0x70(s1)
	andi  a1,s0,0xFF
	# sw[15:8] --> a2 操作数A
	srli s0,s0,8 
	andi  a2,s0,0xFF
	# sw[23:21] --> a3 操作符
	srli s0,s0,13
	andi  a3,s0,0x7
	
# 判断操作符
select:
	addi t0,x0,0
	beq a3,t0,andOperation
	addi t0,x0,1
	beq a3,t0,orOperation
	addi t0,x0,2
	beq a3,t0,xorOperation
	addi t0,x0,3
	beq a3,t0,sllOperation
	addi t0,x0,4
	beq a3,t0,sraOperation
	addi t0,x0,5
	beq a3,t0,complementOperation
	addi t0,x0,6
	beq a3,t0,divOperation
	
andOperation:
	and t1,a2,a1
	jal x0,output1
orOperation:
	or t1,a2,a1
	jal x0,output1
xorOperation:
	xor t1,a2,a1
	jal x0,output1
sllOperation:
	sll t1,a2,a1
	jal x0,output2
sraOperation:
	andi t2,a2,128
	beq t2,x0,nosext
	ori t2,a2,0xFFFFFF00
	sra t1,t2,a1
	andi t1,t1,0x000000FF
	jal x0,output2
nosext:	sra t1,a2,a1
	jal x0,output2
complementOperation:
	add t1,a1,x0
	beq a2,x0,output1
	srli t2,a1,7
	beq  t2,zero,output1
	# 操作数B为负，求补码
	addi a1,a1,-0x80
	xori a1,a1,-1
	addi a1,a1,1
	add t1,a1,x0
	jal x0,output1
divOperation:
	add t1,x0,x0
	andi t2,a1,128
	andi t3,a2,128
	xor t2,t2,t3
	andi t3,a1,127
	andi t4,a2,127
SUB:	
	sub t4,t4,t3
	bge t4,x0,ADD1
	add t1,t1,t2
	add t4,t4,t3
	slli t4,t4,24
	add t1,t1,t4
	jal x0,output2
ADD1:
	addi t1,t1,1
	jal x0,SUB

#显示二进制	
output1:
	andi t2,t1,1
	andi t3,t1,2
	slli t3,t3,3
	add t2,t2,t3
	andi t3,t1,4
	slli t3,t3,6
	add t2,t2,t3
	andi t3,t1,8
	slli t3,t3,9
	add t2,t2,t3
	andi t3,t1,16
	slli t3,t3,12
	add t2,t2,t3
	andi t3,t1,32
	slli t3,t3,15
	add t2,t2,t3
	andi t3,t1,64
	slli t3,t3,18
	add t2,t2,t3
	andi t3,t1,128
	slli t3,t3,21
	add t2,t2,t3
	add t1,t2,x0
	sw t1,0x00(s1)
	jal x0,start
	
#显示有符号整数
output2:
	sw t1,0x00(s1)
	jal x0,start

	
	
	
