.data

.balign 4
message1 : .asciz "%d + %d = %d\n" // + 메시지

.balign 4
message2 : .asciz "%d - %d = %d\n" // - 메시지

.balign 4
message3 : .asciz "%d * %d = %d\n" // * 메시지

.balign 4
message4 : .asciz "%d / %d = %d\n" // / 메시지

.balign 4
scan_pattern : .asciz "%d %d" //scanf 입력 패턴

.balign 4
print_pattern : .asciz "First Number : %d\nSecond Number2 : %d\n" //printf 출력 패턴

.balign 4
Error_sig : .asciz "You entered an invalid value.\nPleas enter only numbers\n" //ERROR 출력 문자열

.balign 4
number_read1 : .word 0 //입력 변수1

.balign 4
number_read2 : .word 0 //입력 변수2

.balign 4
return : .word 0 //리턴1

.balign 4
return2 : .word 0 //리턴2

.text
//더하기
mysum :
	ldr r2, addr_return2
	str lr, [r2] /* comback addr */
	mov r2, r1 //r2 = r1
	mov r1, r0 //r1 = r0

	add r3, r1, r2 //r3 = r1 + r2

	ldr r0, addr_message1 //r0 = 프린트할 메시지 패턴의 주소를 넣는다.
	bl printf

	ldr lr, addr_return2 //돌아갈 주소가 저장된 주소를 리턴받는다.
	ldr lr, [lr] //돌아갈 주소가 저장된 값을 lr에 저장
	bx lr
//빼기
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
//곱하기
mymul :
	ldr r2, addr_return2
	str lr, [r2] 
	mov r3, #0 //r3 = 0
	mov r5, r1 // r5 = r1
//두번째 인자의 숫자만큼 loop1을 돌려서 첫번째 숫자를 더하면 된다. 
loop1 :
	cmp r5, #0 //두번째 인자와 0을 비교한다.
	beq end1	//0이라면 end1로 branch한다.
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
//나누기
mydiv :	
	ldr r2, addr_return2
	str lr, [r2]
	
	cmp r1, #0 //r1과 0을 비교한다.
	beq end0 //r1이 0이라면 뺄 수 없기 때문에 end0으로 branch한다.
	mov r3, #0 //r3 = 0
	mov r5, r0 //r5 = r0
//첫번째 인자의 수에서 두번째 인자의 수를 빼준다.(0보다 작아질때 까지)
loop2 :
	sub r5, r5, r1 //r5 = r5 - r1
	cmp r5, #0 // r
	blt end2 //0보다 작다면 end2로 branch
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

	ldr r0, addr_scan_pattern //r0 = scanf 입력 패턴의 주소
	ldr r1, addr_num_read1 //r1 = 입력 변수1 주소
	ldr r2, addr_num_read2 //r2 = 입력 변수2 주소
	bl scanf

	cmp r0, #2 //숫자 2개가 제대로 변수에 입력된다면 2를 리턴한다.
	bne end_x //2가 아니라면 end_x로 branch

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