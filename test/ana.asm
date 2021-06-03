ldm r0, 6 ;  [2] loop label = 6
ldm r1, 4 ;  [4] iterations = 4
iadd r2, 4 ; [6]
dec r1    ;  [8]
jz r2     ;  [9] break
jmp r0    ;  [A] loop
nop       ;  [B] r2 should be 0x10
