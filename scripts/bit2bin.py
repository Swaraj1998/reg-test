#!/usr/bin/env python3

# Copyright (C) 2021 Swaraj Hota

import sys

with open(sys.argv[1], 'rb') as f:
    fout = open(sys.argv[1] + '.bin', 'wb')
    while True:
        word = f.read(4)
        if word == b'':
            break
        word = int.from_bytes(word, 'big')
        fout.write(word.to_bytes(4, 'little'))
    fout.close()
