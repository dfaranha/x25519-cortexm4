CC=gcc -Wall -std=c99
binaries=test_scalarmult test_device
DEPS=add.c copy.c cswap.c from_bytes.c invert.c mul.c mul121665.c scalarmult.c sqr.c sub.c to_bytes.c

all: scalarmult device

.PHONY: clean
clean:
	rm -f *.o $(binaries)

scalarmult:
	$(CC) -O3 -o test_scalarmult test_scalarmult.c $(DEPS)

device:
	$(CC) -O3 -o test_device test_device.c $(DEPS)