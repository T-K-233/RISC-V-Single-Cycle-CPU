
# GPIO base address
li s0, 0x10010000

# delay amount
li s1, 1000000

# led status
li s2, 0x1

sw s2, 0(s0)

loop:
  li t0, 0
delay:
  addi t0, t0, 1
  blt t0, s1, delay

  # update LED state
  sw s2, 0(s0)

  # alternate the LED state
  li t0, 1
  sub s2, t0, s2

  j loop

