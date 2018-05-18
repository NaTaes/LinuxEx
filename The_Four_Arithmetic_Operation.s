.data

.balign 4
message1 : .asciz "%d + %d = %d\n" // + �޽���

.balign 4
message2 : .asciz "%d - %d = %d\n" // - �޽���

.balign 4
message3 : .asciz "%d * %d = %d\n" // * �޽���

.balign 4
message4 : .asciz "%d / %d = %d\n" // / �޽���

.balign 4
scan_pattern : .asciz "%d %d" //scanf �Է� ����

.balign 4
print_pattern : .asciz "First Number : %d\nSecond Number2 : %d\n" //printf ��� ����

.balign 4
Error_sig : .asciz "You entered an invalid value.\nPleas enter only numbers\n" //ERROR ��� ���ڿ�

.balign 4
number_read1 : .word 0 //�Է� ����1

.balign 4
number_read2 : .word 0 //�Է� ����2

.balign 4
return : .word 0 //����1

.balign 4
return2 : .word 0 //����2

.text
//���ϱ�
mysum :
	ldr r2, addr_return2
	str lr, [r2] /* comback addr */
	mov r2, r1 //r2 = r1
	mov r1, r0 //r1 = r0

	add r3, r1, r2 //r3 = r1 + r2

	ldr r0, addr_message1 //r0 = ����Ʈ�� �޽��� ������ �ּҸ� �ִ´�.
	bl printf

	ldr lr, addr_return2 //���ư� �ּҰ� ����� �ּҸ� ���Ϲ޴´�.
	ldr lr, [lr] //���ư� �ּҰ� ����� ���� lr�� ����
	bx lr
//����
mysub :
	ldr r2, addr_return2
	str lr, [r2] 
	mov r2, r1
	mov r1, r0

	sub r3, r1, r2 //r3 = r1 - r2

	ldr r0, addr_message2
	bl printf

	ldr lr, addr_return2
	ldr lr, [lr]
	bx lr
//���ϱ�
mymul :
	ldr r2, addr_return2
	str lr, [r2] 
	mov r3, #0 //r3 = 0
	mov r5, r1 // r5 = r1
//�ι�° ������ ���ڸ�ŭ loop1�� ������ ù��° ���ڸ� ���ϸ� �ȴ�. 
loop1 :
	cmp r5, #0 //�ι�° ���ڿ� 0�� ���Ѵ�.
	beq end1	//0�̶�� end1�� branch�Ѵ�.
	add r3, r3, r0 //r3 = r3 + r0
	sub r5, r5, #1 //r5 = r5 - 1
	b loop1
end1 :
	mov r2, r1 // r2 = r1
	mov r1, r0 // r1 = r0
	
	ldr r0, addr_message3
	bl printf

	ldr lr, addr_return2
	ldr lr, [lr]
	bx lr
//������
mydiv :	
	ldr r2, addr_return2
	str lr, [r2]
	
	cmp r1, #0 //r1�� 0�� ���Ѵ�.
	beq end0 //r1�� 0�̶�� �� �� ���� ������ end0���� branch�Ѵ�.
	mov r3, #0 //r3 = 0
	mov r5, r0 //r5 = r0
//ù��° ������ ������ �ι�° ������ ���� ���ش�.(0���� �۾����� ����)
loop2 :
	sub r5, r5, r1 //r5 = r5 - r1
	cmp r5, #0 // r
	blt end2 //0���� �۴ٸ� end2�� branch
	add r3, r3, #1 //r3 = r3 + 1
	b loop2
end0 :
	mov r3, #0 //r3 = 0
end2 :
	mov r2, r1 //r2 = r1
	mov r1, r0 //r1 = r0

	ldr r0, addr_message4
	bl printf

	ldr lr, addr_return2
	ldr lr, [lr]
	bx lr

.global main
main :
	ldr r3, addr_return
	str lr, [r3]

	ldr r0, addr_scan_pattern //r0 = scanf �Է� ������ �ּ�
	ldr r1, addr_num_read1 //r1 = �Է� ����1 �ּ�
	ldr r2, addr_num_read2 //r2 = �Է� ����2 �ּ�
	bl scanf

	cmp r0, #2 //���� 2���� ����� ������ �Էµȴٸ� 2�� �����Ѵ�.
	bne end_x //2�� �ƴ϶�� end_x�� branch

	ldr r0, addr_num_read1
	ldr r0, [r0]
	ldr r1, addr_num_read2
	ldr r1, [r1]
	
	mov r2, r1
	mov r1, r0
	ldr r0, addr_print_pattern
	bl printf

	ldr r0, addr_num_read1
	ldr r0, [r0]
	ldr r1, addr_num_read2
	ldr r1, [r1]
	bl mysum

	ldr r0, addr_num_read1
	ldr r0, [r0]
	ldr r1, addr_num_read2
	ldr r1, [r1]
	bl mysub

	ldr r0, addr_num_read1
	ldr r0, [r0]
	ldr r1, addr_num_read2
	ldr r1, [r1]
	bl mymul
	
	ldr r0, addr_num_read1
	ldr r0, [r0]
	ldr r1, addr_num_read2
	ldr r1, [r1]
	bl mydiv

end_o:
	mov r0, #0
	ldr lr, addr_return
	ldr lr, [lr]
	bx lr
end_x:
	ldr r0, addr_Error
	bl printf
	mov r0, #1 //r0 = 1
	mvn r0, r0 //r0 = !r0
	add r0, #1 //r0 = r0 + 1
	ldr lr, addr_return
	ldr lr, [lr]
	bx lr



addr_message1 : .word message1
addr_message2 : .word message2
addr_message3 : .word message3
addr_message4 : .word message4
addr_scan_pattern : .word scan_pattern
addr_print_pattern : .word print_pattern
addr_Error : .word Error_sig
addr_num_read1 : .word number_read1
addr_num_read2 : .word number_read2
addr_return : .word return
addr_return2 : .word return2

.global printf
.global scanf