.text
// integer divides numerator by denominator, returns result, remainder
// params word: num, word: denom
_int_div:
    push {r4-r6, lr}
    mov r4, r0  // r4 = num
    mov r5, r1  // r4 = denom
    mov r6, #0  // counter
__divloop:
    cmp r4, r5
    blt __divloop_e  // if r4 < r4
    sub r4, r4, r5  // num = num - denom
    add r6, #1  // increment counter
    b __divloop
__divloop_e:
    mov r0, r6  // return counter
    mov r1, r4  // return remainder
    pop {r4-r6, lr}
    bx lr

// returns random number between 0 and limit
//params: byte limit
_random_int:
    push {r4, r5, lr}
    mov r4, r0  // r4 = limit
    add r5, r4, #1  // r5 = limit + 1
    mov r0, #0
    bl time  // time(0)
    bl srand  // srand(time(0)), starts rng
    bl rand  // returns in r0
    mov r1, r5
    bl _int_div  // rand() / (limit + 1)
    mov r0, r1  // return rand() % (limit + 1)
    pop {r4, r5, lr}
    bx lr

// extended for the use of big numbers
// returns random number between 0 and limit
// params: word limit
_random_int_ex:
    push {r4-r8, lr}
    mov r4, r0  // r4 = limit
    add r5, r4, #1  //r5 = limit+1
    ldr r0, =#0x7fffffff  // numerator = rand_max (signed intmax)
    mov r1, r5  // denominator = limit + 1
    bl _int_div  // rand_max / (limit + 1)
    mov r6, r0  // divisor = rand_max / (limit + 1)
    mov r8, #0  // result = 0
    mov r0, #0
    bl time  // call time(0)
    bl srand  // start rng srand(time(0))
__randi_loop:
    bl rand  // r0 = rand()
    mov r1, r6
    bl _int_div  // rand() / divisor
    mov r8, r0  // result = rand() / divisor
    cmp r8, r4
    bgt __randi_loop  // if result > limit
    mov r0, r8  // return result
    pop {r4-r8, lr}
    bx lr


.global time
.global srand
.global rand