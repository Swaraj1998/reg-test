import sys
import subprocess
import argparse
from loc2addr import *
from reg2addr import *

CFGIF_PATH = 'xilinx-devcfg/'

if __name__ == '__main__':

    parser = argparse.ArgumentParser(
            description='Tool to access custom registers in Zynq FPGA using PDR')
    parser.add_argument('reg_name', help='register instance name')
    parser.add_argument('reg_index', help='register index [0-63]')
    parser.add_argument('-w', '--write', help='write value to register')
    parser.add_argument('-r', '--read', action='store_true',
            help='read value from register')
    args = parser.parse_args()

    loc_list = get_reg2loc(args.reg_name)

    # assuming same frames configure all the slices of the register
    addr_list = get_loc2addr(loc_list[0])
    assert len(addr_list) == 4

    comm_devc = subprocess.run(['python', CFGIF_PATH + 'devcfg.py', 'read',
        hex(min(addr_list)), str(len(addr_list))])
    if comm_devc.returncode != 0:
        print('Error @ devcfg.py')
        exit(1)
