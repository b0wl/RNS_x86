.data
EXIT_SUCCESS=0
SYSEXIT=60

value:
    .quad 0x8ce18240		      #123456	100 0110 01110 0001100 0001001000000

m1: .quad  7									# 2^3  - 1 (dla względnego pierwszeństwa)
m2: .quad  15									# 2^4  - 1
m3: .quad  31									# 2^5  - 1
m4: .quad  127								# 2^7  - 1
m5: .quad  8192								# 2^13 - 1

M:	.quad 3386449920					# 7 * 15 * 31 * 127 * 8192

M1: .quad 483778560						# 3386449920 / 7
M2: .quad 225763328						# 3386449920 / 15
M3: .quad 109240320						# 3386449920 / 31
M4: .quad 26664960						# 3386449920 / 127
M5: .quad 413385							# 3386449920 / 8192

# odwrotnosc multiplikatywna
y1: .quad 6                   # notki w zeszycie ...
y2: .quad 2                   # Mi * yi = 1(mod m1)
y3: .quad 7
y4: .quad 54
y5: .quad 2937


.macro drns rns_num
  # saving registers values to stack
  push %r11
  push %r12
  push %r13
  push %r14
  push %r15
  push %r8
  push %rbx

  mov \rns_num, %rax
  shr $29, %rax									#-----------------------------XXX
  and $7, %rax									#00000000000000000000000000000111 (:3)
  mov %rax, %r11								#mod 7

  mov \rns_num, %rax
  shr $25, %rax		  						#-------------------------000XXXX
  and $15, %rax		  						#00000000000000000000000000001111 (:4)
  mov %rax, %r12								#mod 15

  mov \rns_num, %rax
  shr $20, %rax									#--------------------0000000XXXXX
  and $31, %rax		  						#00000000000000000000000000011111 (:5)
  mov %rax, %r13								#mod 31

  mov \rns_num, %rax
  shr $13, %rax									#-------------000000000000XXXXXXX
  and $127, %rax								#00000000000000000000000001111111 (:7)
  mov %rax, %r14								#mod 127

  mov \rns_num, %rax
  															#0000000000000000000XXXXXXXXXXXXX
  and $8191, %rax								#00000000000000000001111111111111 (:13)
  mov %rax,%r15									#mod 8192

  # r11 <- X mod 7     - a1
  # r12 <- X mod 15    - a2
  # r13 <- X mod 31    - a3
  # r14 <- X mod 127   - a4
  # r15 <- X mod 8192  - a5

  # CRT
  # r8 - suma

  ## a1 * M1 x y1
  mov M1, %rax
  mul %r11
  mov y1, %rbx
  mul %rbx
  mov %rax, %r8

  ## a2 * M2 x y2  + do r8
  mov M2, %rax
  mul %r12
  mov y2, %rbx
  mul %rbx
  add %rax, %r8

  ## a3 * M3 x y3  + do r8
  mov M3, %rax
  mul %r13
  mov y3, %rbx
  mul %rbx
  add %rax, %r8

  ## a4 * M4 x y4  + do r8
  mov M4, %rax
  mul %r14
  mov y4, %rbx
  mul %rbx
  add %rax, %r8

  ## a5 * M5 x y5  + do r8
  mov M5, %rax
  mul %r15
  mov y5, %rbx
  mul %rbx
  add %rax, %r8

  ## suma mod M
  mov M, %rbx
  mov $0, %rdx
  mov %r8, %rax
  div %rbx
  mov %rdx, %rax

  # geting back registers values from stack
  pop %rbx
  pop %r8
  pop %r15
  pop %r14
  pop %r13
  pop %r12
  pop %r11
.endm

.macro mulrns rns_num
  push %r11
  push %r12
  push %r13
  push %r14
  push %r15
  push %r8
  push %rbx

  pop %rbx
  pop %r8
  pop %r15
  pop %r14
  pop %r13
  pop %r12
  pop %r11
.endm

.text
.global main
main:
  movq %rsp, %rbp #for correct debugging
  drns value
bb:
  movq $SYSEXIT, %rax
  movq $EXIT_SUCCESS, %rdi
  syscall
