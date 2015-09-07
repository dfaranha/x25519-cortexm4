#!/usr/bin/env python3
import serial
import subprocess

# Change this to the address of your serial device
ser = serial.Serial('/dev/tty.usbserial-A603UBMV', 230400, timeout=2)

def is_equal(a,b,n,p):
    for i in range(32):
        if a[i] != b[i]:
            print()
            printhex(a)
            printhex(b)
            printhex(n)
            printhex(p)
            return False
    return True

def printhex(x):
    for b in x:
        print("{:02x} ".format(b), end="")
    print()

def parsebytes(b):
    ret = []
    for idx in range(0,64,2):
        ret.append(int(b[idx:idx+2],16))
    return ret

if __name__ == "__main__":
    failures = 0
    empties = 0
    for idx in range(100000):
        vals = subprocess.check_output(["./test_device"])
        (q,n,p) = vals.split()

        q = parsebytes(q)
        n = parsebytes(n)
        p = parsebytes(p)
        ser.write(n)
        ser.write(p)
        response = list(ser.read(32))
        cycles = int.from_bytes(ser.read(4), byteorder="little")
        if len(response) == 0:
            empties += 1
            continue

        if cycles != 1816351:
            print("Nonstandard cycles: {}".format(cycles))

        if not is_equal(response, q,n,p):
            failures += 1
            continue

        if idx % 100 == 0:
            print(idx)

    if failures > 0:
        print("There were {} failures".format(failures))
    if empties > 0:
        print("There were {} empty results".format(empties))
    if empties == 0 and failures == 0:
        print("All went well")