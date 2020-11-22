.include "macros.s"
.include "tools.s"
.text

.macro print_word
    ldr r0, =reveal_msg
    bl printf
    ldr r0, =current_word
    bl puts
.endm

.macro print_attempts
    push {r4}
    ldr r0, =debug_attempts
    ldr r4, =attempts
    ldrb r1, [r4]
    bl printf
    pop {r4}
.endm

@ .global main

@ main:
@     bl _run
@     mov r7, #1
@     svc #0


_file_not_found:
    ldr r0, =file_error
    bl printf
    mov r7, #1
    svc #0


_get_hang_gfx:
    push {r4-r11, lr}
    ldr r4, =attempts
    // dynamically gets the correct hang man file from number of attempts
    ldr r0, =hang_file_name
    ldr r1, =hang_file_format
    ldrb r2, [r4]
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
    bl puts
    pop {r4-r11, lr}
    bx lr


/*
    gets a random word from words.txt
*/
_get_new_word:
    push {r4-r11, lr}
    ldr r4, =current_word  // save string_buffer
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


// re initialises game variables
_init_game_vars:
    push {r4-r11, lr}
    mov r5, #0
    ldr r4, =win
    strb r5, [r4]  // set win to False
    ldr r4, =lose
    strb r5, [r4]  // set lose to False
    ldr r4, =gameover
    strb r5, [r4]  // set gameover to False
    ldr r4, =attempts
    strb r5, [r4]  // set attempts to 0
    ldr r0, =current_word
    mov r1, #0
    mov r2, #17
    bl _fill_string_amt  // fills current_word with null
    ldr r0, =guess
    mov r1, #0
    mov r2, #17
    bl _fill_string_amt  // fills guess with null
    ldr r0, =misses
    mov r1, #0
    mov r2, #8
    bl _fill_string_amt  // fills misses with null
    ldr r0, =hang_buffer
    mov r1, #0
    mov r2, #97
    bl _fill_string_amt  // empties hang_buffer
    pop {r4-r11, lr}
    bx lr


// checks if input character is a 0
_check_exit:
    push {r4-r11, lr}
    ldr r4, =input_buffer
    ldrb r5, [r4]
    cmp r4, #48
    bne __checkExit_skip
    // gameover =  True;
    mov r6, #255
    ldr r7, =gameover
    strb r6, [r7]
__checkExit_skip:
    pop {r4-r11, lr}
    bx lr


// handle player inputs before passing on to update
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
    bl _to_upper  // converts to upper case
    pop {r4-r11, lr}
    bx lr


// helper to add correct word to the guesses string
_add_to_guess:
    push {r4-r11, lr}
    mov r4, r0
    ldr r5, =input_buffer
    ldrb r6, [r5]
    ldr r7, =guess
    add r7, r4
    strb r6, [r7]
    pop {r4-r11, lr}
    bx lr


// updates game state
// most of logic goes here
_update:
    push {r4-r11, lr}
    ldr r4, =input_buffer
    ldrb r5, [r4]
    ldr r6, =current_word
    @ print_word
    mov r0, r6
    mov r1, r4
    bl _str_contains  // input_buffer in current_word
    cmp r0, #0
    beq __checkGuess_skip  // branches if input_buffer is not in current_word
    mov r7, #0  // index = 0
__checkGuess_loop:
    ldrb r9, [r6], #1  // load current word into r9
    cmp r9, #0  // exit loop if null
    beq __checkGuess_loop_e
    cmp r5, r9
    moveq r0, r7
    bleq _add_to_guess  // update guesses to include newly input char
    add r7, #1  // index++
    b __checkGuess_loop  // iterate
__checkGuess_loop_e:
    ldr r0, =guess
    ldr r1, =current_word
    bl _str_equals  // check if guess and current_word are equal
    cmp r0, #0
    beq __checkGuess_return  // return if _str_equals() == False
    ldr r4, =gameover
    ldr r5, =win
    mov r6, #255
    strb r6, [r4]  // gameover = True
    strb r6, [r5]  // win = True
    b __checkGuess_return
__checkGuess_skip:
    @ print_word
    // checks if input guess is already in the missed
    ldr r0, =misses
    ldr r1, =input_buffer
    bl _str_contains
    cmp r0, #255
    ldreq r0, =guessed_already
    bleq puts
    beq __checkGuess_return
    // increment attempts
    ldr r4, =attempts
    ldrb r5, [r4]
    add r5, #1
    strb r5, [r4]
    // add the miss to the incorrect letters
    ldr r0, =misses
    ldr r1, =input_buffer
    bl strcat
    @ print_word
    // check if attempts == 6 and update flags
    ldr r4, =attempts
    ldrb r5, [r4]
    cmp r5, #6
    blt __checkGuess_return
    ldr r4, =gameover
    ldr r5, =lose
    mov r6, #255
    strb r6, [r4]
    strb r6, [r5]
__checkGuess_return:
    pop {r4-r11, lr}
    bx lr


// draws game graphics
_draw:
    push {r4-r11, lr}
    // print guessed word (blank underscores)
    ldr r0, =guesses_msg
    bl printf
    ldr r0, =guess
    bl puts
    // show failed letters
    ldr r0, =misses_msg
    bl printf
    ldr r0, =misses
    bl puts
    ldr r0, =new_line
    bl printf
    // print the correct hang man state
    bl _get_hang_gfx
    ldr r4, =lose
    ldrb r5, [r4]
    cmp r5, #255
    // print defeat if lost
    ldreq r0, =defeat_msg
    bleq puts
    ldr r4, =win
    ldrb r5, [r4]
    cmp r5, #255
    // print win message if won
    ldreq r0, =victory_msg
    bleq puts
__draw_return:
    pop {r4-r11, lr}
    bx lr


// runs entire game
_run:
    push {r4-r11, lr}
    // initialises game variables for every game
    bl _init_game_vars
    // get random word
    bl _get_new_word
    ldr r4, =current_word_len
    str r0, [r4]
    // fill the guess string with underscores
    ldr r0, =guess
    mov r1, #95
    ldrb r2, [r4]
    bl _fill_string_amt
    // draw the graphics once
    bl _draw
__game_loop:
    ldr r5, =gameover
    ldrb r4, [r5]
    cmp r4, #255
    beq __game_loop_e

    bl _handle_input
    // validate input
    // load input into r4
    ldr r4, =input_buffer
    ldrb r5, [r4]
    mov r0, r4
    bl _is_capital
    cmp r0, #255  // compare input and 'A'
    beq __valid_input
    cmp r5, #48  // if exit is true
    bne __game_loop
    ldr r4, =gameover
    mov r5, #255
    strb r5, [r4]
    ldr r0, =gameover_msg
    bl puts
    b __game_loop_e
__valid_input:
    bl _update  // player input is in [A-Z], check guess
    bl _draw
    b __game_loop
__game_loop_e:
    print_word
    pop {r4-r11, lr}
    bx lr

.data
// vars
gameover: .byte 0  // bool gameover;
win: .byte 0  // bool win;
lose: .byte 0  // bool lose;
attempts: .byte 0  // byte attempts;
current_word_len: .byte 0
letter_found: .byte 0  // bool letter_found;

// strings
new_line: .string "\n"
words_file: .string "words.txt"
read_mode: .string "r"
file_error: .string "File not found\n"
hang_file_format: .string "hang%d.txt"
input_message: .string "Input character or 0 to exit: "
guesses_msg: .string "Word: "
misses_msg: .string "Misses: "
victory_msg: .string "VICTORY!"
defeat_msg: .string "DEFEAT!"
gameover_msg: .string "GAME OVER!"
reveal_msg: .string "The word was: "
debug_attempts: .string "Attempts: %d\n"
guessed_already: .string "You have already guessed this try again..."

// uninitialised vars
.bss
misses: .skip 8
current_word: .skip 17
guess: .skip 17
hang_file_name: .skip 10
hang_buffer: .skip 97
input_buffer: .skip 3

// standard C library function
.global fopen
.global fclose
.global fgets
.global sprintf
.global fread
.global scanf
.global printf
.global puts
.global strcat
