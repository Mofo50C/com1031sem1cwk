.text
.global main
.include "tools.s"

main:
    mov r0, #9
    bl _random_int
    mov r4, r0
    mov r7, #1
    svc #0
