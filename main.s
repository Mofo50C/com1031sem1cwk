.include "game.s"
.text
.global main

main:
	push {r4-r7, lr}
	mov r0, #0
	mov r1, #0
	mov r2, #0
	mov r3, #0
	ldr r0, =welcome_message
	bl puts
__main_loop:
	ldr r5, =done
	ldrb r4, [r5]  // r4 = [done]
	cmp r4, #255  // check if done is True
	beq __main_loop_e
	bl _run  // run main game
	bl _play_again  // check for playing again
	b __main_loop
__main_loop_e:
	ldr r0, =goodbye_msg
	bl puts
	pop {r4-r7, lr}
	//exit
	mov r7, #1
	svc #0


// does logic to check if player wants to play again
_play_again:
	push {r4-r7, lr}
	// send output
	mov r0, #1
	ldr r1, =play_again_msg
	ldr r2, =play_again_msglen
	mov r7, #4
	svc #0
	// read input
	mov r0, #0
	ldr r1, =in_buf
	mov r2, #2
	mov r7, #3
	svc #0
	// strip new line from input
	ldr r0, =in_buf
	bl _strip_lf
	// check if input is n
	ldr r4, =in_buf
	ldrb r5, [r4]
	cmp r5, #110
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
play_again_msg: .string "Do you want to play again? (y/n): "
play_again_msglen = .-play_again_msg
welcome_message: .string "Hangman game in ARM Assembly by Mohammad Foroughi"
goodbye_msg: .string "Thank you for playing...Goodbye!"

.bss
in_buf: .skip 3
