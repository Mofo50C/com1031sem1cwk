.text

.macro sysout msg, msglen
    push {r7}
    mov r0, #1
    ldr r1, \msg
    mov r2, \msgln
    mov r7, #4
    svc #0
    pop {r7}
.endm

_init_game_vars:
    push {r4, lr}
    ldr r4, =gameover
    strb r4, #0
    ldr r4, =win
    strb r4, #0
    ldr r4, =attempts
    strb r4, #0
    pop {r4, lr}

_handle_input:
    push {r4-r11, lr}

    pop {r4-r11, lr}
    bx lr

_draw:
    push {r4-r11, lr}
    sysout =current_word, #current_word_len
    pop {r4-r11, lr}
    bx lr

_update:
    push {r4-r11, lr}

    pop {r4-r11, lr}
    bx lr

_run:
    push {r4-r11, lr}
    init_game_vars
    get_new_word =current_word
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
gameover: .skip 1  // bool gameover;
win: .skip 1  // bool win;
attempts: .skip 1  // byte attempts;

// strings
words_file: .string "words.txt"

.bss
misses: .skip 7
current_word: .skip 17
current_word_len: .skip 16
guess: .skip 17
all_words: .skip 110  // words.txt file
