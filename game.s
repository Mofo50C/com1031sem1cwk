.include "macros.s"
.include "tools.s"
.text
.global main

main:
    @ bl _handle_input
    mov r7, #1
    svc #0


_file_not_found:
    ldr r0, =file_error
    bl printf
    mov r7, #1
    svc #0


_get_hang_gfx:
    push {r4-r11, lr}
    mov r4, r0
    // get the correct hang man file from number of attempts
    ldr r0, =hang_file_name
    ldr r1, =hang_file_format
    mov r2, r4
    bl sprintf
    // open the correct hang man file
    ldr r0, =hang_file_name
    ldr r1, =read_mode
    bl fopen
    mov r6, r0
    cmp r0, #0  // check if the file could be found
    beq _file_not_found
    // read hang man file and load into buffer
    ldr r0, =hang_buffer
    mov r1, #1
    mov r2, #96
    mov r3, r6
    bl fread
    // close hang man file
    mov r0, r6
    bl fclose
    // get length of buffer
    ldr r0, =hang_buffer
    bl printf
    ldr r0, =new_line
    bl printf
    pop {r4-r11, lr}
    bx lr


/*
    gets a random word from words.txt

    @params: char[] *string_buffer
    @returns: void
*/
_get_new_word:
    push {r4-r11, lr}
    mov r4, r0  // save string_buffer
    mov r0, #9  // set max random int to 9
    bl _random_int_ex
    mov r5, r0  // r5 = random int
    ldr r0, =words_file
    ldr r1, =read_mode
    bl fopen
    mov r6, r0  // r6 = fd
    mov r7, #0  // count = 0
    cmp r6, #0
    beq _file_not_found
__read_line_loop:
    mov r0, r4
    mov r1, #17
    mov r2, r6
    bl fgets
    cmp r0, #0
    beq __read_line_loop_e
    cmp r7, r5  // count == random_int
    addne r7, #1
    bne __read_line_loop
__read_line_loop_e:
    mov r0, r6  // r0 = fd
    bl fclose  // fclose(fd)
    mov r0, r4
    bl _strip_lf
    bl _length
    pop {r4-r11, lr}
    bx lr


_init_game_vars:
    push {r4-r11, lr}
    mov r5, #0
    ldr r4, =gameover
    strb r4, [r5]
    ldr r4, =win
    strb r4, [r5]
    ldr r4, =attempts
    strb r4, [r5]
    ldr r0, =current_word
    mov r1, #0
    mov r2, #17
    bl _fill_string_amt
    ldr r0, =guess
    mov r1, #0
    mov r2, #17
    pop {r4-r11, lr}
    bx lr


_handle_input:
    push {r4-r11, lr}
    // ask for input
    ldr r0, =input_message
    bl _length
    mov r2, r0
    mov r0, #1
    ldr r1, =input_message
    mov r7, #4
    svc #0
    // read input
    mov r0, #0
    ldr r1, =input_buffer
    mov r2, #2
    mov r7, #3
    svc #0
    // strip white spaces and make upper case
    ldr r0, =input_buffer
    bl _strip_lf
    bl _to_upper
    pop {r4-r11, lr}
    bx lr


_update:
    push {r4-r11, lr}

    pop {r4-r11, lr}
    bx lr


_draw:
    push {r4-r11, lr}
    sysout current_word, current_word_len
    ldr r4, =attempts
    ldrb r0, [r4]
    bl _get_hang_gfx
    pop {r4-r11, lr}
    bx lr


_run:
    push {r4-r11, lr}
    bl _init_game_vars
    ldr r0, =current_word
    bl _get_new_word
    ldr r4, =current_word_len
    str r0, [r4]
    ldr r0, =guess
    mov r1, #95
    ldrb r2, [r5]
    bl _fill_string_amt
    bl _draw

__game_loop:
    ldr r5, =gameover
    ldrb r4, [r5]
    cmp r4, #255
    beq __game_loop_e
    bl _handle_input
    bl _update
    bl _draw
    b __game_loop
__game_loop_e:

    pop {r4-r11, lr}
    bx lr

.data
// vars
gameover: .byte 0  // bool gameover;
win: .byte 0  // bool win;
attempts: .byte 0  // byte attempts;
current_word_len: .byte 0

// strings
new_line: .string "\n"
words_file: .string "words.txt"
read_mode: .string "r"
file_error: .string "File not found\n"
hang_file_format: .string "hang%d.txt"
input_format: .string "%s"
input_message: .string "Guess letter: "

.bss
misses: .skip 7
current_word: .skip 17
guess: .skip 17
hang_file_name: .skip 10
hang_buffer: .skip 97
input_buffer: .skip 3

.global fopen
.global fclose
.global fgets
.global sprintf
.global fread
.global scanf
.global printf
