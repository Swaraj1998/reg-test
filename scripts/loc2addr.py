import sys
import json

DB_JSON = '../build/slice_lut_db_min.json'

def get_loc2addr(loc_str):
    slc, lut = loc_str.split('/')

    with open(DB_JSON) as f:
        db = json.load(f)
    
    sliceinfo = db[slc]
    if lut == 'A6LUT':
        lutframes = sliceinfo['alut']['frames']
    elif lut == 'B6LUT':
        lutframes = sliceinfo['blut']['frames']
    elif lut == 'C6LUT':
        lutframes = sliceinfo['clut']['frames']
    elif lut == 'D6LUT':
        lutframes = sliceinfo['dlut']['frames']
    else:
        print('Unrecognized LUT: ' + lut)
        return None

    addr_list = []
    for fr in lutframes:
        addr_list.append(int(sliceinfo['baseaddr'], 16) + fr)
    return addr_list

if __name__ == "__main__":
    assert len(sys.argv) == 2

    addr_list = get_loc2addr(sys.argv[1])

    # print('Frame addresses for location ' + sys.argv[1] + ': ')
    for addr in addr_list:
        print('0x{:08x}'.format(addr))
