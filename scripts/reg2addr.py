from loc2addr import *
import sys

# Path to the register-to-slice mapping db file generated after build
DB_FILE = '../build/reg_slice_map.db'

def get_reg2loc(reg_name):
    loc_list = []
    with open(DB_FILE, 'r') as f:
        line = f.readline()
        while line:
            entry = line.strip().split(' ')
            if entry[0] == reg_name:
                for loc in entry[1:]:
                    slc, lut = loc.split('/')
                    if lut in ['A6LUT', 'B6LUT', 'C6LUT', 'D6LUT']:
                        loc_list.append(loc)
                break
            line = f.readline()
    return loc_list

if __name__ == '__main__':
    assert(len(sys.argv) == 2)

    loc_list = get_reg2loc(sys.argv[1])
    if not loc_list:
        print('Couldn\'t find slice locations for register: ' + sys.argv[1])
        exit(1)

    # assuming same frames configure all the slices in the register
    addr_list = get_loc2addr(loc_list[0])
    if not addr_list:
        print('Couldn\'t find frame addresses for register: ' + sys.argv[1])
        exit(1)

    for addr in addr_list:
        print('0x{:08x}'.format(addr))
