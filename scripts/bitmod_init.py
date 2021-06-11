#!/usr/bin/env python3

# Copyright (C) 2021 Swaraj Hota

import sys
import json
import argparse

DB_JSON = '../build/slice_lut_db_min.json'

WORDS_PER_FRAME = 101
FRAME_ADDR_CMD = 0x30002001

def get_frame_offset_in_file(f, faddr):
    f.seek(0)
    while True:
        word = f.read(4)
        if word == b'':
            break
        # Find frame address command
        if int.from_bytes(word, 'big') == FRAME_ADDR_CMD:
            word = f.read(4)
            # Match with the frame address
            if int.from_bytes(word, 'big') == faddr:
                if f.tell() < (8 + WORDS_PER_FRAME*4 + 4):
                    continue
                f.seek(-(8 + WORDS_PER_FRAME*4 + 4), 1)
                f.read(4)    # FDRI command
                return f.tell()
    return -1

def edit_in_frame_init(f, foffset, initoffset, bit_val_dict):
    f.seek(foffset + initoffset*4)
    w1, w2 = f.read(4), f.read(4)
    init_words = int.from_bytes(w2+w1, 'big')
    for bitp in bit_val_dict:
        if bit_val_dict[bitp] == 1:
            init_words |= (1 << bitp)
        else:
            init_words &= ~(1 << bitp)
    f.seek(-8, 1)
    w1 = init_words & 0xffffffff
    w2 = (init_words >> 32) & 0xffffffff
    f.write(w1.to_bytes(4, 'big'))
    f.write(w2.to_bytes(4, 'big'))

def get_bit_val_dict(frame, initbits, initval):
    bit_val_dict = dict()
    for (i, pair) in enumerate(initbits):
        frno, bitp = pair.split('_')
        frno, bitp = int(frno), int(bitp)
        if frno == frame:
            bit_val_dict[bitp] = 1 if initval & (1 << i) != 0 else 0
    return bit_val_dict

def get_init_value(f, foffset, initoffset, initbits, lutframes):
    initval = 0
    for fr in lutframes:
        f.seek(foffset[fr] + initoffset*4)
        w1, w2 = f.read(4), f.read(4)
        init_words = int.from_bytes(w2+w1, 'big')
        for (i, pair) in enumerate(initbits):
            frno, bitp = pair.split('_')
            frno, bitp = int(frno), int(bitp)
            if frno == fr:
                bitval = 1 if init_words & (1 << bitp) != 0 else 0
                initval |= (bitval << i)
    return initval

def icap_crc(addr, data, crc):
    val = (addr << 32) | data
    poly = 0x82F63B78 << 1  # CRC-32C (Castagnoli)

    for i in range(37):
        if (val & 1) != (crc & 1):
            crc ^= poly

        crc >>= 1
        val >>= 1

    return crc

def icap_ecc(idx, data, ecc):
    off = idx * 32;

    if idx > 0x25:	# avoid 0x800
        off += 0x1360
    elif idx > 0x6:	# avoid 0x400
        off += 0x1340
    else:		# avoid lower
        off += 0x1320

    if idx == 0x32:	# mask ECC
        data &= 0xFFFFE000

    for i in range(32):
        if (data & 1) == 1:
            ecc ^= off + i
        data >>= 1

    if idx == 0x64:	# last index
        v = ecc & 0xFFF
        v ^= v >> 8
        v ^= v >> 4
        v ^= v >> 2
        v ^= v >> 1
        ecc ^= (v & 1) << 12

    return ecc

if __name__ == '__main__':

    parser = argparse.ArgumentParser(
            description='Tool to edit LUT INIT values in a Xilinx Zynq bitstream')
    parser.add_argument('bitfile', help='bitstream file to edit')
    parser.add_argument('slice', help='slice location (e.g. SLICE_X26Y114)')
    parser.add_argument('-a', '--a6lut', help='new init value for A6LUT')
    parser.add_argument('-b', '--b6lut', help='new init value for B6LUT')
    parser.add_argument('-c', '--c6lut', help='new init value for C6LUT')
    parser.add_argument('-d', '--d6lut', help='new init value for D6LUT')
    parser.add_argument('-r', '--report', action='store_true',
            help='show current init values for the slice')
    parser.add_argument('--nocrc', action='store_true',
            help='Do not update Per Frame CRC')
    args = parser.parse_args()

    with open(DB_JSON) as f:
        db = json.load(f)

    sliceinfo = db[args.slice]

    lutframes = sliceinfo['alut']['frames']
    assert lutframes == sliceinfo['blut']['frames']
    assert lutframes == sliceinfo['clut']['frames']
    assert lutframes == sliceinfo['dlut']['frames']

    with open(args.bitfile, 'rb+') as f:

        foffset = dict()
        for fr in lutframes:
            faddr = int(sliceinfo['baseaddr'], 16) + fr
            # print(str(fr) + ': ' + hex(faddr))
            foffset[fr] = get_frame_offset_in_file(f, faddr)
            assert foffset[fr] != -1

        initoffset = sliceinfo['offset']
        # print(foffset)

        if args.report:
            print('Slice location: ' + args.slice)
            initbits = sliceinfo['alut']['init']
            init = get_init_value(f, foffset, initoffset, initbits, lutframes)
            print('A6LUT INIT: 0x{:016x}'.format(int(init)))
            initbits = sliceinfo['blut']['init']
            init = get_init_value(f, foffset, initoffset, initbits, lutframes)
            print('B6LUT INIT: 0x{:016x}'.format(int(init)))
            initbits = sliceinfo['clut']['init']
            init = get_init_value(f, foffset, initoffset, initbits, lutframes)
            print('C6LUT INIT: 0x{:016x}'.format(int(init)))
            initbits = sliceinfo['dlut']['init']
            init = get_init_value(f, foffset, initoffset, initbits, lutframes)
            print('D6LUT INIT: 0x{:016x}'.format(int(init)))

            # for fr in lutframes:
                # crc = 0
                # ecc = 0
                # faddr = int(sliceinfo['baseaddr'], 16) + fr
                # f.seek(foffset[fr])
                # for i in range(WORDS_PER_FRAME):
                    # word = int.from_bytes(f.read(4), 'big')
                    # crc = icap_crc(0x2, word, crc)
                    # ecc = icap_crc(i, word, ecc)
                    # if i == 0x32:
                        # actual_ecc = word #& 0x1fff
                # f.read(4)   # FAR command
                # f.read(4)   # Frame address
                # f.read(4)   # CRC command
                # crc = icap_crc(0x1, faddr, crc)
                # actual_crc = int.from_bytes(f.read(4), 'big')  # CRC value
                # print('---------------')
                # print('frame address: ' + hex(faddr))
                # print('calculated crc: ' + hex(crc))
                # print('actual crc: ' + hex(actual_crc))
                # print('calculated ecc: ' + hex(ecc))
                # print('actual ecc: ' + hex(actual_ecc))

            exit(0)

        for fr in lutframes:
            if args.a6lut is not None:
                initbits = sliceinfo['alut']['init']
                initval  = int(args.a6lut, 16)
                bit_val_dict = get_bit_val_dict(fr, initbits, initval)
                edit_in_frame_init(f, foffset[fr], initoffset, bit_val_dict)
            if args.b6lut is not None:
                initbits = sliceinfo['blut']['init']
                initval  = int(args.b6lut, 16)
                bit_val_dict = get_bit_val_dict(fr, initbits, initval)
                edit_in_frame_init(f, foffset[fr], initoffset, bit_val_dict)
            if args.c6lut is not None:
                initbits = sliceinfo['clut']['init']
                initval  = int(args.c6lut, 16)
                bit_val_dict = get_bit_val_dict(fr, initbits, initval)
                edit_in_frame_init(f, foffset[fr], initoffset, bit_val_dict)
            if args.d6lut is not None:
                initbits = sliceinfo['dlut']['init']
                initval  = int(args.d6lut, 16)
                bit_val_dict = get_bit_val_dict(fr, initbits, initval)
                edit_in_frame_init(f, foffset[fr], initoffset, bit_val_dict)

        if not args.nocrc:
            for fr in lutframes:
                    crc = 0
                    faddr = int(sliceinfo['baseaddr'], 16) + fr
                    f.seek(foffset[fr])
                    for i in range(WORDS_PER_FRAME):
                        word = int.from_bytes(f.read(4), 'big')
                        crc = icap_crc(0x2, word, crc)
                    f.read(4)   # FAR command
                    f.read(4)   # Frame address
                    f.read(4)   # CRC command
                    crc = icap_crc(0x1, faddr, crc)
                    f.write(crc.to_bytes(4, 'big'))
