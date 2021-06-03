.org 0
10

.org 10
ldm r0, 14 #  [0] loop label = 6
ldm r1, 4  #  [2] iterations = 4

.org 14
iadd r2, 4 #  [4] loop
dec r1     #  [6]
jz r2      #  [7] break
jmp r0     #  [8] loop
nop        #  [9] r2 should be 0x10
