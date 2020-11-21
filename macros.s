.text
.macro sysout msg, msglen
    push {r4-r11}
    mov r0, #1
    ldr r1, =\msg
    ldr r4, =\msglen
    mov r7, #4
    svc #0
    pop {r4-r11}
.endm

.macro printchar char
    // print single character
    mov r0, #1
    ldr r1, =\char
    mov r2, #1
    mov r7, #4
    svc #0
.endm
