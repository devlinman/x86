#!/usr/bin/env python3


num = [50, 48, 48, 51]

len = len(num)


def cals(num, len):
    if len != 0:
        n = num[len - 1] - 48
        n = 10 ** (len - 1) * n
        print(n)
        return cals(len - 1, num) + n
    else:
        return 0


ber = cals(num, len)
print("---")
print(ber)
