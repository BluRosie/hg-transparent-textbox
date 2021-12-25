.text
.align 2
.thumb

.global WindowClose
WindowClose:
ldr r0, =0x04000050
mov r1, #0x0
strh r1, [r0]
mov r0, r5
add r0, #0xD2
ldrb r1, [r0, #0x0]
mov r0, #0x40
ldr r2, =0x02041198 + 1
bx r2
