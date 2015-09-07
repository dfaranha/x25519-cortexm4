# Constant time X25519 implementation for ARM Cortex-M4

This project is a constant time implementation of the X25519 elliptic curve Diffie-Hellman function for the ARM Cortex-M4 architecture. It is hand-written in assembler to extract the most performance from the device, and completes a scalar multiplication in 1816351 cycles using 628 bytes of RAM and 4140 bytes of ROM. This function accepts arbitrary public points.

## Contents

There are three directories:
* `X25519/` has the Cortex-M4 assembler functions, this is the scalar multiplier only.
* `prototype/` holds a C version of the X25519 function using the same implementation strategy.
* `launchpad/` contains the assembler version with a KEIL uVision project for the TI Tiva C series Launchpad development board.

The latter directory also houses a Python script. It tests the launchpad version by having the C scalar multiplier generate test vectors and sending them to the device. The device then performs scalar multiplication, measures the timing and sends its cycle count and resulting value back where they are compared against the known targets.

## M3

This code uses the long multipliers available on M3 and higher. However, they are not constant time on M3, and consequently neither is this implementation of X25519. If constant time performance is important to you, do not use this implementation on an M3.
