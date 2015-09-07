#include <stdio.h>
#include "scalarmult.h"
#include <stdint.h>

uint64_t rdrand_get() {
    uint64_t x;
    unsigned char err = 1;
	do
	{
        __asm (".byte 0x48; .byte 0x0f; .byte 0xc7; .byte 0xf0; setc %1"
                  : "=a" (x), "=qm" (err));
	} while (err != 1);
	return x;
}

void genvalue(unsigned char *x) {
    uint64_t *xptr = (uint64_t *)x;

    for (int idx = 0; idx < 4; ++idx)
        xptr[idx] = rdrand_get();
}

void printbytes(unsigned char const *b) {
    for (int idx = 1; idx < 33; ++idx) {
        printf("%02x", b[idx - 1]);
    }
    printf("\n");
}

int main() {
    unsigned char q[32], n[32], p[32];
    genvalue(n);
    genvalue(p);

    scalarmult(q, n, p);

    printbytes(q);
    printbytes(n);
    printbytes(p);
}
