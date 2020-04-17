lui gp, 4096
addi s11, x0, 0

loop:

lw s0, 0(s11)
lw s1, 1(s11)
lw s2, 2(s11)
lw s3, 3(s11)
lw s4, 4(s11)
lw s5, 5(s11)
lw s6, 6(s11)
lw s7, 7(s11)

sw s0, 0(gp)
sw s1, 1(gp)
sw s2, 2(gp)
sw s3, 3(gp)
sw s4, 4(gp)
sw s5, 5(gp)
sw s6, 6(gp)
sw s7, 7(gp)

addi s11, s11, 8

jal x0, loop