# Group 60
# Issue 14 - x86 architecture software RNS extension

.data
EXIT_SUCCESS=0
SYSEXIT=60

value_rns:
    .quad 0x8ce18240          # 123456  100 0110 01110 0001100 0001001000000
value_pos:
    .quad 123456

m1: .quad  7                  # 2^3  - 1 (for relative primary)
m2: .quad  15                 # 2^4  - 1
m3: .quad  31                 # 2^5  - 1
m4: .quad  127                # 2^7  - 1
m5: .quad  8192               # 2^13 - 1

M:  .quad 3386449920          # 7 * 15 * 31 * 127 * 8192

M1: .quad 483778560           # 3386449920 / 7
M2: .quad 225763328           # 3386449920 / 15
M3: .quad 109240320           # 3386449920 / 31
M4: .quad 26664960            # 3386449920 / 127
M5: .quad 413385              # 3386449920 / 8192

#  multiplicative inversion
y1: .quad 6                   # calcs in notebook ...
y2: .quad 2                   # Mi * yi = 1(mod m1)
y3: .quad 7
y4: .quad 54
y5: .quad 2937


#  Convert positional system number to RNS number
#  RAX(rns) = ARG(pos)
.macro rns pos_num
  push %rbx
  push %rcx
  push %rbx
  push %r9

  mov \pos_num, %r9
  xor %rbx, %rbx              # rbx - result

  mov %r9, %rax
  xor %rdx, %rdx
  mov $7, %rcx
  div %rcx
  shl $29, %rdx
  mov %rdx, %rbx

  mov %r9, %rax
  xor %rdx, %rdx
  mov $15, %rcx
  div %rcx
  shl $25, %rdx
  or  %rdx, %rbx

  mov %r9, %rax
  xor %rdx, %rdx
  mov $31, %rcx
  div %rcx
  shl $20, %rdx
  or  %rdx, %rbx

  mov %r9, %rax
  xor %rdx, %rdx
  mov $127, %rcx
  div %rcx
  shl $13, %rdx
  or  %rdx, %rbx

  mov %r9, %rax
  xor %rdx, %rdx
  mov $8192, %rcx
  div %rcx
  or  %rdx, %rbx

  mov %rbx, %rax

  pop %r9
  pop %rbx
  pop %rcx
  pop %rdx
.endm

#  Convert RNS number to positional system number
#  RAX(pos) = ARG(rns)
.macro drns rns_num
  # saving registers values to stack
  push %r11
  push %r8
  push %r9
  push %rbx
  push %rdx
  push %rcx

  mov \rns_num, %r9

  mov %r9, %rax
  shr $29, %rax                  # -----------------------------XXX
  and $7, %rax                   # 00000000000000000000000000000111 (:3)
  mov %rax, %r11                 # mod 7

  # a1 * M1 x y1
  mov M1, %rax
  mul %r11
  mov y1, %rbx
  mul %rbx
  mov %rax, %r8

  mov %r9, %rax
  shr $25, %rax                  # -------------------------000XXXX
  and $15, %rax                  # 00000000000000000000000000001111 (:4)
  mov %rax, %r11                 # mod 15

  # a2 * M2 x y2  + do r8
  mov M2, %rax
  mul %r11
  mov y2, %rbx
  mul %rbx
  add %rax, %r8

  mov %r9, %rax
  shr $20, %rax                  # --------------------0000000XXXXX
  and $31, %rax                  # 00000000000000000000000000011111 (:5)
  mov %rax, %r11                 # mod 31

  # a3 * M3 x y3  + do r8
  mov M3, %rax
  mul %r11
  mov y3, %rbx
  mul %rbx
  add %rax, %r8

  mov %r9, %rax
  shr $13, %rax                  # -------------000000000000XXXXXXX
  and $127, %rax                 # 00000000000000000000000001111111 (:7)
  mov %rax, %r11                 # mod 127

  # a4 * M4 x y4  + do r8
  mov M4, %rax
  mul %r11
  mov y4, %rbx
  mul %rbx
  add %rax, %r8

  mov %r9, %rax
                                 # 0000000000000000000XXXXXXXXXXXXX
  and $8191, %rax                # 00000000000000000001111111111111 (:13)
  mov %rax, %r11                 # mod 8192

  # a5 * M5 x y5  + do r8
  mov M5, %rax
  mul %r11
  mov y5, %rbx
  mul %rbx
  add %rax, %r8

  # suma mod M
  mov M, %rbx
  xor %rdx, %rdx
  mov %r8, %rax
  div %rbx
  mov %rdx, %rax

  # geting back registers values from stack
  pop %rcx
  pop %rdx
  pop %rbx
  pop %r9
  pop %r8
  pop %r11
.endm

#  Add two RNS numbers. One in RAX, other as ARG.
#  RAX = RAX + ARG
.macro addrns rns_num
  push %rbx
  push %rcx
  push %rdx
  push %r9
  push %r10
  push %r11
  push %r12

  mov \rns_num, %r12
  mov %rax, %r9
  mov %r12, %rax
  xor %r11, %r11
  shr $29, %rax                  # -----------------------------XXX
  and $7, %rax                   # 00000000000000000000000000000111 (:3)
  mov %rax, %r10
  mov %r9, %rax
  shr $29, %rax                  # -----------------------------XXX
  and $7, %rax                   # 00000000000000000000000000000111 (:3)
  add %r10, %rax
  mov $7, %rbx
  xor %rdx, %rdx
  div %rbx
  shl $29, %rdx
  or %rdx, %r11

  mov %r12, %rax
  shr $25, %rax                  # -------------------------000XXXX
  and $15, %rax                  # 00000000000000000000000000001111 (:4)
  mov %rax, %r10
  mov %r9, %rax
  shr $25, %rax                  # -------------------------000XXXX
  and $15, %rax                  # 00000000000000000000000000001111 (:4)
  add %r10, %rax
  mov $15, %rbx
  xor %rdx, %rdx
  div %rbx
  shl $25, %rdx
  or %rdx, %r11

  mov %r12, %rax
  shr $20, %rax                  # --------------------0000000XXXXX
  and $31, %rax                  # 00000000000000000000000000011111 (:5)
  mov %rax, %r10
  mov %r9, %rax
  shr $20, %rax                  # --------------------0000000XXXXX
  and $31, %rax                  # 00000000000000000000000000011111 (:5)
  add %r10, %rax
  mov $31, %rbx
  xor %rdx, %rdx
  div %rbx
  shl $20, %rdx
  or %rdx, %r11

  mov %r12, %rax
  shr $13, %rax                  # -------------000000000000XXXXXXX
  and $127, %rax                 # 00000000000000000000000001111111 (:7)
  mov %rax, %r10
  mov %r9, %rax
  shr $13, %rax                  # -------------000000000000XXXXXXX
  and $127, %rax                 # 00000000000000000000000001111111 (:7)
  add %r10, %rax
  mov $127, %rbx
  xor %rdx, %rdx
  div %rbx
  shl $13, %rdx
  or %rdx, %r11

  mov %r12, %rax                 # 0000000000000000000XXXXXXXXXXXXX
  and $8191, %rax                # 00000000000000000001111111111111 (:13)
  mov %rax, %r10
  mov %r9, %rax
  and $8191, %rax                # 00000000000000000001111111111111 (:13)
  add %r10, %rax
  mov $8192, %rbx
  xor %rdx, %rdx
  div %rbx
  or %rdx, %r11

  mov %r11, %rax

  pop %r12
  pop %r11
  pop %r10
  pop %r9
  pop %rdx
  pop %rcx
  pop %rbx
.endm

#  Multiple two RNS numbers. One in RAX, other as ARG.
#  RAX = RAX * ARG
.macro mulrns rns_num
  push %rbx
  push %rcx
  push %rdx
  push %r9
  push %r10
  push %r11
  push %r12

  mov \rns_num, %r12
  mov %rax, %r9
  mov %r12, %rax
  xor %r11, %r11
  shr $29, %rax                  # -----------------------------XXX
  and $7, %rax                   # 00000000000000000000000000000111 (:3)
  mov %rax, %r10
  mov %r9, %rax
  shr $29, %rax                  # -----------------------------XXX
  and $7, %rax                   # 00000000000000000000000000000111 (:3)
  mul %r10
  mov $7, %rbx
  xor %rdx, %rdx
  div %rbx
  shl $29, %rdx
  or %rdx, %r11

  mov %r12, %rax
  shr $25, %rax                  # -------------------------000XXXX
  and $15, %rax                  # 00000000000000000000000000001111 (:4)
  mov %rax, %r10
  mov %r9, %rax
  shr $25, %rax                  # -------------------------000XXXX
  and $15, %rax                  # 00000000000000000000000000001111 (:4)
  mul %r10
  mov $15, %rbx
  xor %rdx, %rdx
  div %rbx
  shl $25, %rdx
  or %rdx, %r11

  mov %r12, %rax
  shr $20, %rax                  # --------------------0000000XXXXX
  and $31, %rax                  # 00000000000000000000000000011111 (:5)
  mov %rax, %r10
  mov %r9, %rax
  shr $20, %rax                  # --------------------0000000XXXXX
  and $31, %rax                  # 00000000000000000000000000011111 (:5)
  mul %r10
  mov $31, %rbx
  xor %rdx, %rdx
  div %rbx
  shl $20, %rdx
  or %rdx, %r11

  mov %r12, %rax
  shr $13, %rax                  # -------------000000000000XXXXXXX
  and $127, %rax                 # 00000000000000000000000001111111 (:7)
  mov %rax, %r10
  mov %r9, %rax
  shr $13, %rax                  # -------------000000000000XXXXXXX
  and $127, %rax                 # 00000000000000000000000001111111 (:7)
  mul %r10
  mov $127, %rbx
  xor %rdx, %rdx
  div %rbx
  shl $13, %rdx
  or %rdx, %r11

  mov %r12, %rax                 # 0000000000000000000XXXXXXXXXXXXX
  and $8191, %rax                # 00000000000000000001111111111111 (:13)
  mov %rax, %r10
  mov %r9, %rax
  and $8191, %rax                # 00000000000000000001111111111111 (:13)
  mul %r10
  mov $8192, %rbx
  xor %rdx, %rdx
  div %rbx
  or %rdx, %r11

  mov %r11, %rax

  pop %r12
  pop %r11
  pop %r10
  pop %r9
  pop %rdx
  pop %rcx
  pop %rbx
.endm

.macro shr_rns_step
  push %rbx
  push %rcx
  push %rdx
  push %r9
  push %r10
  push %r11

  xor %rdx, %rdx
  xor %r11, %r11

  mov %rax, %r9
  mov %rax, %r8

  shr $29, %rax                  # -----------------------------XXX
  and $7, %rax                   # 00000000000000000000000000000111 (:3)
  mov %rax, %r10
  shr %r10                       # ------------------------------11 |1
  and $1, %rax                   # -------------------------------1
  shl $2, %rax                   # -----------------------------1XX
  or %r10, %rax
  shl $29, %rax
  or %rax, %r11

  mov %r9, %rax

  shr $25, %rax                  # -------------------------000XXXX
  and $15, %rax                  # 00000000000000000000000000001111 (:4)
  mov %rax, %r10
  shr %r10                       # -----------------------------111 |1
  and $1, %rax                   # -------------------------------1
  shl $3, %rax                   # ----------------------------1XXX
  or %r10, %rax
  shl $25, %rax
  or %rax, %r11

  mov %r9, %rax

  shr $20, %rax                  # --------------------0000000XXXXX
  and $31, %rax                  # 00000000000000000000000000011111 (:5)
  mov %rax, %r10
  shr %r10                       # ----------------------------1111 |1
  and $1, %rax                   # -------------------------------1
  shl $4, %rax                   # ----------------------------1XXX
  or %r10, %rax
  shl $20, %rax
  or %rax, %r11

  mov %r9, %rax

  shr $13, %rax                  # -------------000000000000XXXXXXX
  and $127, %rax                 # 00000000000000000000000001111111 (:7)
  mov %rax, %r10
  shr %r10                       # --------------------------111111 |1
  and $1, %rax                   # -------------------------------1
  shl $6, %rax                   # -------------------------1XXXXXX
  or %r10, %rax
  shl $13, %rax
  or %rax, %r11

  mov %r9, %rax
                                 # 0000000000000000000XXXXXXXXXXXXX
  and $8191, %rax                # 00000000000000000001111111111111 (:13)
  mov %rax, %r10
  shr %r10                       # --------------------111111111111 |1
  and $1, %rax                   # -------------------------------1
  shl $12, %rax                  # -------------------1XXXXXXXXXXXX
  or %r10, %rax
  or %rax, %r11

  mov %r11, %rax

  pop %r11
  pop %r10
  pop %r9
  pop %rdx
  pop %rcx
  pop %rbx
.endm

.macro shr_rns positions
  push %rsi
  mov \positions, %rsi

filip_tribute:
  cmp $0, %rsi
  jle exit_shr_rns

  shr_rns_step
  dec %rsi
  jmp filip_tribute

exit_shr_rns:
  pop %rsi
.endm

#  Compare two RNS numbers. One in RAX, other as ARG.
#  If RAX bigger -> RAX = 1, If RAX smaller -> RAX = -1, If equal -> RAX = 0
.macro cmprns rns_num
  push %rbx

  drns %rax
  mov %rax, %rbx
  mov \rns_num, %rax
  drns %rax
  cmp %rax, %rbx
  jl arg_greater
  je both_equal

rax_greater:
  mov $1, %rax
  jmp leave_cmprns

arg_greater:
  mov $-1, %rax
  jmp leave_cmprns

both_equal:
  xor %rax, %rax

leave_cmprns:
  pop %rbx
.endm

#  mrc from rns
#  RAX = mrc(RAX)
.macro mrs
  push %rbx
  push %rcx
  push %rdx
  push %r9
  push %r10
  push %r11
  push %r12

  mov %rax, %r12
  
  mov %r12, %rax                 # 0000000000000000000XXXXXXXXXXXXX
  and $8191, %rax                # 00000000000000000001111111111111 (:13)
  mov $m4, %r9
  mul %r9
  mov %rax, %r10
  

  mov %r12, %rax
  shr $13, %rax                  # -------------000000000000XXXXXXX
  and $127, %rax                 # 00000000000000000000000001111111 (:7)
  mov $m3, %r9
  mul %r9
  mul %r10
  mov %rax, %r10

  mov %r12, %rax
  shr $20, %rax                  # --------------------0000000XXXXX
  and $31, %rax                  # 00000000000000000000000000011111 (:5)
  mov $m2, %r9
  mul %r9
  mul %r10
  mov %rax, %r10
  
  mov %r12, %rax 
  shr $25, %rax                  # -------------------------000XXXX
  and $15, %rax                  # 00000000000000000000000000001111 (:4)
  mov $m1, %r9
  mul %r9
  mul %r10
  mov %rax, %r10
                  
  shr $29, %rax                  # -----------------------------XXX
  and $7, %rax                   # 00000000000000000000000000000111 (:3)
  mul %r10

  pop %r12
  pop %r11
  pop %r10
  pop %r9
  pop %rdx
  pop %rcx
  pop %rbx
.endm


.text
#  Main. Mainly Testing
#  Alter to show inner workings
.global main
main:
  movq %rsp, %rbp # for correct debugging

rns_check:
  rns $128

  shr_rns $2

  drns %rax

exit:
  movq $SYSEXIT, %rax
  movq $EXIT_SUCCESS, %rdi
  syscall
