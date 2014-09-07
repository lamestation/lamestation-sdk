#!/usr/bin/env python

import random

length = 512

for f in range(length):
#    print f, int(random.random() * 255)
    lst = [int((length-1)*random.random()) for i in range(length)]

output = \
"""' *********************************************************
' noise.spin
' *********************************************************
PUB Addr
    return @data

DAT

data
"""

for i in range(length):
    if i % 16 == 0:
        output += "\nbyte    "

    output += "%3i" % (lst[i])

    if i % 16 != 15:
        output += ", "

print output
