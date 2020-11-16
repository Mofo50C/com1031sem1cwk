.text
.global main

main:
	push {r4-r7, lr}
	mov r0, #0
	mov r1, #0
	mov r2, #0
	mov r3, #0
__main_loop:
	ldr r5, =done
	ldrb r4, [r5]  // r4 = [done]
	cmp r4, #255
	beq __main_loop_e
	bl _play_again
	b __main_loop
__main_loop_e:
	pop {r4-r7, lr}
	//exit
	mov r7, #1
	svc #0

_play_again:
	push {r4-r7, lr}
	// send output
	mov r0, #1
	ldr r1, =in_msg
	mov r2, #in_msg_len
	mov r7, #4
	svc #0

	// read input
	mov r0, #0
	ldr r1, =in_buf
	mov r2, #2
	mov r7, #3
	svc #0
	
	// check if input is n
	ldrb r4, [r1]
	cmp r4, #110
	bne __not_done
	ldr r4, =done
	mov r5, #255
	strb r5, [r4]  // [done] = #255
__not_done:
	pop {r4-r7, lr}
	bx lr

.data
//vars
done: .byte 0 // boolean TRUE = 255, FALSE = 0

//strings
in_msg: .string "Do you want to play again? (y/n): "
in_msg_len = .-in_msg

.bss
in_buf: .skip 3